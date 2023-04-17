(
/*
Description:
One channel Low Pass Filter
*/

SynthDef(\LPF, {
	arg in=0, freq=440, mul=1.0,
	add=0.0, out=0;
	var sig;
	
	sig = In.ar(in);
	sig = LPF.ar(sig, freq, mul, add);
	Out.ar(out, sig);
}).add;
)