adjust_view_down = func {
    if (getprop("/sim/current-view/pitch-offset-deg") > 0) {
	setprop("/sim/current-view/pitch-offset-deg", -2);
    } else {
	setprop("/sim/current-view/pitch-offset-deg", -8);
    }
}
adjust_view_up = func {
    if (getprop("/sim/current-view/pitch-offset-deg") < -2) {
	setprop("/sim/current-view/pitch-offset-deg", -2);
    } else {
	setprop("/sim/current-view/pitch-offset-deg", 90);
    }
}

engine_nozzle = func {
    setprop("/controls/engines/engine[0]/nozzle", arg[0]);
}

engine_throttle = func {
    nozzle = getprop("/controls/engines/engine[0]/nozzle");
    throttle = getprop("/controls/engines/engine[0]/throttle");
    alt = getprop("/position/altitude-ft");
    # pilot-g as there is no engine-g
    acc = getprop("/accelerations/pilot-g");

    if (nozzle == "A") {
	tx = throttle * 0.3;
    } elsif (nozzle == "S") {
	tx = throttle;
    } else {
	tx = (1-(1-throttle)*(1-throttle)) * 0.8 + 0.2;
    }
    if (nozzle == "H") {
	if (alt < 20000) {
	    tx = tx * (1 - (20000 - alt)/50000);
	}
    } else {
	if (alt > 25000) {
	    tx = tx * (1 - (alt - 25000)/10000);
	}
    }
    if (nozzle == "F") {
	tx = tx * 0.95;
	if (acc < -2) { tx = tx / (acc / -2); }
	if (acc > 5) { tx = tx / (acc / 5); }
    } else {
	if (acc < -0.5) { tx = tx / (acc * -2); }
	if (acc > 2) { tx = tx / (acc / 2); }
    }
    if (tx < 0) { tx = 0; }
    if (tx > 1) { tx = 1; }
    setprop("/controls/engines/engine[0]/throttleX",tx);
    settimer(engine_throttle,0.0);
}

engine_init = func {
   engine_nozzle("A");
   # schedule the 1st call
   engine_throttle();
}

engine_init();
