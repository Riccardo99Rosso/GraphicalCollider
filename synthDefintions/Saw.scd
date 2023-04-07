(
/*
Description:
Sawtooth wave Oscillator
*/

SynthDef(\Saw, {
	arg freq=440,mul=0.5,add=0.0,out=0;
	var sig;
	sig = Saw.ar(freq,mul,add);
	Out.ar(out,sig);
}).add;
)