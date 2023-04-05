(
SynthDef(\osc,{
	arg freq = 220, amp = 0.2, mix = 1;
	var sig = Saw.ar(freq, amp) * EnvGen.kr(Env.perc());
	Out.ar(0, FreeVerb.ar(sig!2, mix));
}).add;

SynthDef("mySynth", { arg freq = 440, amp = 0.5;
    Out.ar(0, SinOsc.ar(freq) * amp);
}).add;
)
s.getDesc(\osc)

Synth(\osc, [\freq, 440])

(

Pdef(\pattern, Pbind(
	\instrument, \osc,
	\midinote, Pseq([0, 2, 5] + 60, inf),
	\dur, Pseq([1/4], inf),
	\mix, Pseq([1, 0.8, 0.4, 0], inf)
)).play(quant: 1);
)
Pdef(\pattern2, Pbind(
	\instrument, \osc,
	\midinote, Pseq([3, 6, 9, 12, 7] + 60, inf),
	\dur, Pseq([1/4], inf),
)).play(quant: 1);
SinOsc.class
Saw.class

SynthDescLib.global.synthDescs
s.numSynthDefs

x = SynthDescLib.global[\mySynth].asString;






x.