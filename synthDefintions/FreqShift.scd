(
/*
Description:
Mono FreqShift
*/

SynthDef(\FreqShift, {
	arg in=0, freq=0.0, phase=0.0, mul=1.0, add=0.0, out=0;
	var sig;
	
	sig = In.ar(in);
	sig = FreqShift.ar(sig, freq, phase, mul, add);
	Out.ar(out, sig);

}).add;
)