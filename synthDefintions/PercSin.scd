(
/*
Description:
Percussive Sine Oscillator
*/

SynthDef(\PercSin, {
	arg freq=440.0, phase=0.0, mul=0.5, add=0.0,out=0,
	attackTime=0.01, releaseTime=1.0, level=1.0, curve=(-4.0);
	var sig, env;

	env = EnvGen.kr(Env.perc(attackTime, releaseTime, level, curve), doneAction:2);
	sig = SinOsc.ar(freq, phase, mul, add)  * env;
	Out.ar(out, sig);
}).add;
)