(
/*
Description:
Sinusoidal Oscillator
*/

SynthDef(\Sin, {
	arg freq=440,phase=0.0,mul=0.5,add=0.0,out=0;
	var sig;

	sig = SinOsc.ar(freq,phase,mul,add);
	Out.ar(out,sig);
}).add;
)