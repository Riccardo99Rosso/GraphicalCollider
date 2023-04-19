var dict = Dictionary();
var saveFile, openFile, scConstants;

scConstants = FileLoader(~scConstantsPath);

saveFile = {
	arg path, midiDefs;
	var file, name, buffer, tmpGroups, maxId = 0, midiMap;

	path = path.replace(".gc", "");
	path = path ++ ".gc";
	buffer = path.split($/);
	buffer[(buffer.size - 1)];
	name = buffer[(buffer.size - 1)];

	tmpGroups = ~groups;
	tmpGroups.do({
		arg item, i;
		if(item[5] > maxId){
			maxId = item[5];
		};
	});
	file = File(path.standardizePath, "w");
	file.write(tmpGroups.asCompileString.replace("true", "false"));
	file.write("\n");
	file.write(maxId.asCompileString);
	file.write("\n");
	file.write(midiDefs.asCompileString);
	file.close;
	midiMap = midiDefs;

	[name];
};

openFile = {
	arg path, synthPupUpMenu, instList, minSlider, maxSlider, argValue,
	controlSlider, newSynthBtn;
	var buffer, name, toSave, file, list = [], argList = [], id, midiMap;

	buffer = path.split($/);
	buffer[(buffer.size - 1)];
	name = buffer[(buffer.size - 1)];

	file = File(path.standardizePath, "r");
	toSave = file.readAllString;
	toSave = toSave.split($\n);
	file.close;

	midiMap = Dictionary();
	~groups = this.interpret(toSave[0]);
	id = this.interpret(toSave[1]);
	id = id + 1;
	midiMap = this.interpret(toSave[2]);

	~groups.collect({
		arg item, i;
		if(i == 0){
			item[1].do({
				arg obj, j;
				argList = argList.add(obj[0]);
			});
			argValue.value = item[1][0][1];
			minSlider.value = item[2][0][0].asString;
			maxSlider.value = item[2][0][1].asString;
		};
		list = list.add(item[4]);
	});

	if(midiMap != nil){
		midiMap.keysValuesDo({
			arg key, val;
			var sliderValue, toSet, selected, synthPopUpMenuValue, myId,
			playValue;

			if(key.asString.contains("midiCtrl") == true){
				sliderValue = key.asString.replace("midiCtrl", "");
				sliderValue = sliderValue.asInteger;

				toSet = val[0];
				selected = val[1];
				synthPopUpMenuValue = val[2];
				myId = val[3];

				MIDIdef.cc(key, {
					arg ...args;
					var value, pos, min=0, max=1, group;

					value = args[0].asFloat;

					~groups.do({
						arg item, i;
						if(myId == item[5]){
							pos = i;
							min = item[2][synthPopUpMenuValue][0];
							max = item[2][synthPopUpMenuValue][1];
							group = item[0];
						};
					});

					value = value.linlin(0, 127, min.asFloat, max.asFloat).trunc(0.001);
					group.set(toSet, value);
					~groups[pos][1][synthPopUpMenuValue][1] = value;

					{
						if((pos == instList.selection[0]) &&
							(synthPopUpMenuValue == synthPupUpMenu.value)){
							argValue.value = value;
							controlSlider.value =
							value.linlin(min.asFloat, max.asFloat, 0, 1);
						}
					}.defer;

				}, sliderValue);
			};

			if(key.asString.contains("midiPlay") == true){
				playValue = key.asString.replace("midiPlay", "");
				playValue = playValue.asInteger;

				selected = val[0];
				myId = val[1];

				MIDIdef.cc(name, {
					arg ...args;
					var value, pos, type, argValueList, synth;

					value = args[0].asInteger;
					if(value == 127){
						~groups.do({
							arg item, i;
							if(myId == item[5]){
								pos = i;
							}
						});


						type = instList.items[pos].asSymbol;
						argValueList = ~groups[pos][1];
						synth = Synth(type, target: ~groups[pos][0]);
						argValueList.do({
							arg item, value, argument;

							argument = item[0].asSymbol;
							value = item[1].asFloat;
							synth.set(argument, value);
						});
						~groups[pos][3] = true;
						{
							if(pos == instList.selection[0]){
								newSynthBtn.states_([["Play",
									scConstants[\alreadySynthColor],
									scConstants[\newSynthColor]]]);
							};
						}.defer;
					};
				}, playValue);
			};
		});
	};
	instList.items_(list);
	synthPupUpMenu.items_(argList);

	[name, minSlider, maxSlider, id, midiMap];
};

dict.put(\saveFile, saveFile);
dict.put(\openFile, openFile);

dict;