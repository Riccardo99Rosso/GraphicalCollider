(
/*
Description:
FreeVerb implementation
*/

SynthDef(\FreeVerb, {
	arg in=0, out=0, mix=0.33, room=0.5,
	damp=0.5, mul=1.0, add=0.0;
	var sig;
	
	sig = In.ar(in);
	sig = FreeVerb.ar(sig, mix, room, damp, mul, add);
	Out.ar(out, sig);

}).add;
)