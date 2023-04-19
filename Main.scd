(
var mainWin, userView, scrollView;
var scConstants, scWebView, srcPath, scSynthDef,
newInstBtn, deleteInstBtn, moveBeforeInstBtn,
moveAfterInstBtn, instList, moveBefore = false, moveAfter = false,
toMove = nil, synthPupUpMenu, argValue, applyBtn, newSynthBtn, applyFunc,
minSlider, maxSlider, minSliderText, maxSliderText, controlSlider,
sliderControlSpec, firstBus, firstBusText, midiOn = false, midiButton, scFileManager;
var filePath = nil, new, open, save, saveAs, midiDefs, gCreator, midiSlider,
id = 0;

MIDIdef.freeAll;
midiDefs = Dictionary();
~synthDefs = [];
~groups = [];
firstBus = s.options.numInputBusChannels + s.options.numOutputBusChannels;

/*** IMPORTING ALL SCD FILES ***/
~path = thisProcess.nowExecutingPath.replace("Main.scd", "");
srcPath = ~path +/+ "src";
~scConstantsPath =  srcPath +/+ "scConstants.scd";
~scSynthDef = srcPath +/+ "scSynthDef.scd";
~scWebView = srcPath +/+ "scWebView.scd";
~scFileManager = srcPath +/+ "scFileManager.scd";
scConstants = FileLoader(~scConstantsPath);
scSynthDef = FileLoader(~scSynthDef);
scWebView = FileLoader(~scWebView);
scFileManager = FileLoader(~scFileManager);

/*** GUI GENERATIONS ***/
mainWin = Window(scConstants[\title] ++ "untitled.gc", Rect(50, 100, 1000, 700)).front;
mainWin.background = scConstants[\menuColor];

userView = UserView(mainWin);

userView.background = scConstants[\userViewBackground];

mainWin.layout_(
	VLayout(
		ToolBar(
			MenuAction("File", {
				Menu(
					MenuAction("New", {
						new.();
					})
					.shortcut_("Ctrl+n")
					.font_(scConstants[\menuFont]),
					MenuAction("Open", {
						open.();
					})
					.shortcut_("Ctrl+o")
					.font_(scConstants[\menuFont]),
					MenuAction("Save", {
						save.();
					})
					.shortcut_("Ctrl+s")
					.font_(scConstants[\menuFont]),
					MenuAction("Save as...", {
						saveAs.();
					})
					.shortcut_("Ctrl+shift+s")
					.font_(scConstants[\menuFont]),
				).front;
			}).font_(scConstants[\menuFont]),
			MenuAction("Edit",{
				Menu(
					MenuAction("SynthDef Instruments", {
						scSynthDef[\synthDefList].();
					}).font_(scConstants[\menuFont]),
					/*
					MenuAction("Algorithmic Instruments", {
					}).font_(scConstants[\menuFont]),
					*/
					MenuAction("Midi", {
						midiOn = midiOn.not;
						if((midiOn == true),
							{
								MIDIClient.init;
								MIDIIn.disconnectAll;
								MIDIIn.connectAll;
							},
							{
								MIDIdef.freeAll;
								MIDIIn.disconnectAll;
							}
						);
						midiButton.visible_(midiOn);
					}).checked_(midiOn)
					.font_(scConstants[\menuFont]),
					MenuAction("Midi Numbers", {
						var win, midiNum, name;

						win = Window("Midi Nums",
							Rect(200, Window.screenBounds.height - 200, 100, 100)
						).front.alwaysOnTop_(true);

						name = \midiCheck;

						midiNum = StaticText(win, Rect(50, 50, 50, 20))
						.string_("0")
						.font_(scConstants[\menuFont]);

						MIDIdef.cc(name, {
							arg ...args;
							var val;
							val = args[1];
							{
								midiNum.string_(val);
							}.defer;
						}, (0..500));

						win.onClose = {
							MIDIdef(name).free;
						};

					}).font_(scConstants[\menuFont]),
				).front
			}).font_(scConstants[\menuFont]),
			MenuAction("Audio",{
				Menu(
					MenuAction("Audio Drivers", {
						AudioDrivers().booter;
					}).font_(scConstants[\menuFont])
				).front
			}).font_(scConstants[\menuFont]),
			MenuAction("Help",{
				Menu(
					MenuAction("About this project", {
						scWebView[\webDoc].();
					}).font_(scConstants[\menuFont])
				).front
			}).font_(scConstants[\menuFont]),

		),
		userView
	).margins_(0).spacing_(0);
);

mainWin.onClose = {
	Window.closeAll;
	MIDIdef.freeAll;
	MIDIIn.disconnectAll;
	Server.freeAll;
};

/*** SYNTH MANAGER ***/
instList = ListView(userView, Rect(230,50,300,600))
.background_(scConstants[\instListBackground])
.font_(scConstants[\listFont])
.action_({
	arg sbs;
	var list, tmpSbs, tmpValue, toDelete, tmpGroups, tmp,
	argValueList, argList = [], valueList = [];
	if(moveBefore == true){
		tmpSbs = sbs.value;
		tmpValue = instList.items[tmpSbs];
		toDelete = instList.items[toMove];
		~groups[toMove][0].moveBefore(~groups[tmpSbs][0]);
		list = instList.items;
		list = list.insert(tmpSbs, toDelete);
		~groups = ~groups.insert(tmpSbs, ~groups[toMove]);
		if(toMove < tmpSbs,
			{
				list.removeAt(toMove);
				~groups.removeAt(toMove);
				instList.items_(list);
				instList.selection = tmpSbs - 1;
			},
			{
				toMove = toMove + 1;
				list.removeAt(toMove);
				~groups.removeAt(toMove);
				instList.items_(list);
				instList.selection = tmpSbs;
			}
		);
	};

	if(moveAfter == true){
		tmpSbs = sbs.value;
		tmpValue = instList.items[tmpSbs];
		toDelete = instList.items[toMove];
		~groups[toMove][0].moveAfter(~groups[tmpSbs][0]);
		list = instList.items;
		list = list.insert(tmpSbs + 1, toDelete);
		~groups = ~groups.insert(tmpSbs + 1, ~groups[toMove]);
		if(toMove < tmpSbs,
			{
				list.removeAt(toMove);
				~groups.removeAt(toMove);
				instList.items_(list);
				instList.selection = tmpSbs;
			},
			{
				toMove = toMove + 1;
				list.removeAt(toMove);
				~groups.removeAt(toMove);
				instList.items_(list);
				instList.selection = tmpSbs + 1;
			}
		);
	};
	if((moveBefore == false) && (moveAfter == false)){
		argValueList = ~groups[sbs.value][1];
		argValueList.do({
			arg item;
			argList = argList.add(item[0]);
			valueList = valueList.add(item[1]);
		});
		argValue.string = valueList[0];
		minSlider.value = ~groups[sbs.value][2][0][0];
		maxSlider.value = ~groups[sbs.value][2][0][1];
		synthPupUpMenu.items_(argList);
		sliderControlSpec = ControlSpec(
			minSlider.value.asFloat, maxSlider.value.asFloat, step: 0.01);
		controlSlider.value = (valueList[0].asFloat).linlin(
			minSlider.value.asFloat, maxSlider.value.asFloat, 0.00, 1.00);
		if(~groups[sbs.value][3] == true){
			newSynthBtn.states_([["Play",
				scConstants[\alreadySynthColor], scConstants[\newSynthColor]]]);
		};
		if(~groups[sbs.value][3] == false){
			newSynthBtn.states_([["Play",
				Color.white, scConstants[\newSynthColor]]]);
		};
	};
	moveBefore = false;
	moveAfter = false;
});

synthPupUpMenu = PopUpMenu(userView, Rect(570, 50, 150, 30))
.font_(scConstants[\instFont])
.background_(scConstants[\instBtnColor])
.action = {
	var controls, argList = [], index, valueList = [],
	argValueList = [];
	index = synthPupUpMenu.value;
	argValueList = ~groups[instList.selection[0]][1];
	argValueList.do({
		arg item;
		argList = argList.add(item[0]);
		valueList = valueList.add(item[1]);
	});
	minSlider.value = ~groups[instList.selection[0]][2][index][0];
	maxSlider.value = ~groups[instList.selection[0]][2][index][1];
	argValue.string = valueList[index];
	sliderControlSpec = ControlSpec(
		minSlider.value.asFloat, maxSlider.value.asFloat, step: 0.01);
	controlSlider.value = (valueList[index].asFloat).linlin(
		minSlider.value.asFloat, maxSlider.value.asFloat, 0.00, 1.00);
};

argValue = TextField(userView, Rect(570, 100, 150, 30))
.font_(scConstants[\instFont])
.background_(scConstants[\argColor])
.keyUpAction_({
	var argValueList;
	argValueList = ~groups[instList.selection[0]][1];
	argValueList[synthPupUpMenu.value][1] = argValue.value;
	~groups[instList.selection[0]][1] = argValueList;
	controlSlider.value = (argValue.value.asFloat).linlin(
		minSlider.value.asFloat, maxSlider.value.asFloat, 0.00, 1.00);
});

applyBtn = Button(userView, Rect(570, 150, 150, 30))
.font_(scConstants[\instFont])
.states_([["Apply", Color.black, scConstants[\applyBtnColor]]])
.action = {
	applyFunc.();
};

newSynthBtn = Button(userView, Rect(570, 200, 150, 70))
.font_(scConstants[\instFont])
.states_([["Play", Color.white, scConstants[\newSynthColor]]])
.action = {
	var type, controls, argList = [], valueList = [], argArray, synth,
	argValueList, sel;
	if(instList.selection[0] != nil){
		type = instList.items[instList.selection[0]].asSymbol;
		argValueList = ~groups[instList.selection[0]][1];
		synth = Synth(type, target: ~groups[instList.selection[0]][0]);
		argValueList.do({
			arg item, value, argument;

			argument = item[0].asSymbol;
			value = item[1].asFloat;
			synth.set(argument, value);
		});
		~groups[instList.selection[0]][3] = true;
		newSynthBtn.states_([["Play",
			scConstants[\alreadySynthColor], scConstants[\newSynthColor]]]);
	};
};

minSliderText = StaticText(userView, Rect(570, 260, 70, 70))
.font_(scConstants[\instFont])
.stringColor_(Color.white)
.align_(\center)
.string_("Min:");

maxSliderText = StaticText(userView, Rect(650, 260, 70, 70))
.font_(scConstants[\instFont])
.stringColor_(Color.white)
.align_(\center)
.string_("Max:");

minSlider = TextField(userView, Rect(570, 320, 70, 30))
.background_(scConstants[\argColor])
.font_(scConstants[\instFont])
.keyUpAction = {
	if(instList.selection[0] != nil){
		var rangeList;
		rangeList = ~groups[instList.selection[0]][2];
		rangeList[synthPupUpMenu.value][0] = minSlider.value;
		~groups[instList.selection[0]][2] = rangeList;
		sliderControlSpec = ControlSpec(
			minSlider.value.asFloat, maxSlider.value.asFloat, step: 0.01);
		controlSlider.value = (argValue.value.asFloat).linlin(
			minSlider.value.asFloat, maxSlider.value.asFloat, 0.00, 1.00);
	};
};

maxSlider = TextField(userView, Rect(650, 320, 70, 30))
.background_(scConstants[\argColor])
.font_(scConstants[\instFont])
.keyUpAction = {
	if(instList.selection[0] != nil){
		var rangeList;
		rangeList = ~groups[instList.selection[0]][2];
		rangeList[synthPupUpMenu.value][1] = maxSlider.value;
		~groups[instList.selection[0]][2] = rangeList;
		sliderControlSpec = ControlSpec(
			minSlider.value.asFloat, maxSlider.value.asFloat, step: 0.01);
		controlSlider.value = (argValue.value.asFloat).linlin(
			minSlider.value.asFloat, maxSlider.value.asFloat, 0.00, 1.00);
	};
};
firstBusText = StaticText(userView, Rect(570, 345, 200, 70))
.font_(scConstants[\instFont])
.stringColor_(Color.white)
.string_("First bus available: " ++ firstBus);

controlSlider = Slider(userView, Rect(770, 48, 25, 303))
.action = {
	var value;
	value = sliderControlSpec.map(controlSlider.value);
	argValue.value = value;
	synthPupUpMenu.items[synthPupUpMenu.value].asSymbol;
	~groups[instList.selection[0]][1][synthPupUpMenu.value][1] = value;
	~groups[instList.selection[0]][0].set(
		synthPupUpMenu.items[synthPupUpMenu.value].asSymbol, value);
};

sliderControlSpec = ControlSpec(
	0, 1, step: 0.01);

midiButton = Button(userView, Rect(845, 50, 100, 30))
.font_(scConstants[\instFont])
.states_([["Midi Map", Color.black, scConstants[\instBtnColor]]])
.visible_(midiOn)
.action = {
	var win, ccPlayText, ccPlay, ccSliderText, ccSlider;

	win = Window("Midi Mapping").front.alwaysOnTop_(true);
	win.setInnerExtent(250, 130);

	ccPlayText = StaticText(win, Rect(10, 10, 50, 30))
	.font_(scConstants[\instFont])
	.string_("Play: ");

	ccPlay = NumberBox(win, Rect(70, 10, 50, 30))
	.font_(scConstants[\instFont])
	.value_(-1)
	.action_({
		var name, selected, group, myId;
		if((ccPlay.value) >= 0 && (instList.selection[0] != nil)){
			name = "midiPlay" ++ ccPlay.value.asString;
			name = name.asSymbol;

			selected = instList.selection[0];
			group = ~groups[selected][0];

			myId = ~groups[selected][5];
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
					}.defer
				};

			}, ccPlay.value);

			midiDefs.put(name, [selected, myId]);
		};
	});


	ccSliderText = StaticText(win, Rect(10, 60, 50, 30))
	.font_(scConstants[\instFont])
	.string_("Slider: ");

	ccSlider = NumberBox(win, Rect(70, 60, 50, 30))
	.font_(scConstants[\instFont])
	.value_(-1)
	.action_({
		var max, min, selected, toSet, synthPopUpMenuValue, group, myId, name;
		if((ccSlider.value) >= 0 && (instList.selection[0] != nil)){

			name = "midiCtrl" ++ ccSlider.value.asString;
			name = name.asSymbol;
			MIDIdef(name).free;

			toSet = synthPupUpMenu.items[synthPupUpMenu.value].asSymbol;
			selected = instList.selection[0];
			synthPopUpMenuValue = synthPupUpMenu.value;
			group = ~groups[selected][0];

			myId = ~groups[selected][5];
			MIDIdef.cc(name, {
				arg ...args;
				var value, pos;

				value = args[0].asFloat;
				~groups.do({
					arg item, i;
					if(myId == item[5]){
						pos = i;
						min = item[2][synthPopUpMenuValue][0];
						max = item[2][synthPopUpMenuValue][1];
					}
				});

				value = value.linlin(0, 127, min.asFloat, max.asFloat).trunc(0.001);
				group.set(toSet, value);
				~groups[pos][1][synthPopUpMenuValue][1] = value;

				{
					if((pos == instList.selection[0]) &&
						(synthPopUpMenuValue == synthPupUpMenu.value)){
						argValue.value = value;
						controlSlider.value = value.linlin(min.asFloat, max.asFloat, 0, 1);
					}
				}.defer;

			}, ccSlider.value);
			midiDefs.put(name, [toSet, selected, synthPopUpMenuValue, myId]);
		};
	});
};


newInstBtn = Button(userView, Rect(37.5, 50, 150, 50))
.font_(scConstants[\instFont])
.states_([["New Instrument", Color.black, scConstants[\instBtnColor]]])
.action = {
	var win, view, tField, width=100, height=40;
	win = Window("", Rect(300, 630, 100, 100), border: false)
	.background_(scConstants[\userViewBackground]);
	win.setInnerExtent(width, height);
	win.view.keyDownAction = {
		|doc, char, mod, unicode, keycode, key|
		if(key == 16777216){
			win.close;
		};
	};
	tField = TextField(win, Rect(0, 0, width, height))
	.action_({
		arg field;
		var list, synthName, controls, argList = [], valueList = [],
		argValueList = [], rangeList = [];
		if(((~synthDefs.find([field.value])) != nil),
			{
				list = instList.items;
				if(list == nil){
					list = [];
				};
				list = list.addFirst(field.value);
				instList.items_(list);
				synthName = field.value.asSymbol;
				controls = SynthDescLib.global.at(synthName).controls;
				controls.do({
					arg item;
					argValueList = argValueList.add([item.name, item.defaultValue]);
					argList = argList.add(item.name);
					valueList = valueList.add(item.defaultValue);
					rangeList = rangeList.add([0, 1]);
				});
				synthPupUpMenu.items_(argList);
				~groups = ~groups.addFirst(
					[Group(), argValueList, rangeList, false, synthName, id]);
				id = id + 1;
				argValue.string = valueList[0];
				minSlider.value = 0;
				maxSlider.value = 1;
				newSynthBtn.states_([["Play",
					Color.white, scConstants[\newSynthColor]]]);
			}
		);
		win.close;
	})
	.font_(scConstants[\instFont])
	.palette_(QPalette.dark);
	win.front.alwaysOnTop_(true);
};

deleteInstBtn = Button(userView, Rect(37.5, 125, 150, 50))
.font_(scConstants[\instFont])
.states_([["Delete Instrument", Color.black, scConstants[\instBtnColor]]])
.action = {
	var list, selection;
	if(instList.items != nil){
		list = instList.items;
		selection = instList.selection[0];
		~groups[selection][0].free;
		~groups.removeAt(selection);
		list.removeAt(selection);
		instList.items_(list);
		if(selection > 0){
			instList.valueAction = (selection - 1);
		};
		newSynthBtn.states_([["Play",
			Color.white, scConstants[\newSynthColor]]]);
	}
};

moveBeforeInstBtn = Button(userView, Rect(37.5, 200, 150, 50))
.font_(scConstants[\instFont])
.states_([["Move Before", Color.black, scConstants[\instBtnColor]]])
.action = {
	if(instList.items != nil){
		moveAfter = false;
		moveBefore = true;
		toMove = instList.selection[0];
	}
};

moveAfterInstBtn = Button(userView, Rect(37.5, 275, 150, 50))
.font_(scConstants[\instFont])
.states_([["Move After", Color.black, scConstants[\instBtnColor]]])
.action = {
	if(instList.items != nil){
		moveBefore = false;
		moveAfter = true;
		toMove = instList.selection[0];
	}
};

scSynthDef[\loadAll].();

/*** KEYBOARD SHORTCUT ***/
userView.keyDownAction = {
	|view, char, modifiers, unicode, keycode, key|
	//[view, char, modifiers, unicode, keycode, key].postln;
	if(key != nil){
		if((modifiers == 262144) && (key == 80)){
			applyFunc.();
		};

		if((modifiers == 262144) && (key == 78)){
			new.();
		};

		if((modifiers == 393216) && (key == 83)){
			saveAs.();
		};

		if((modifiers == 262144) && (key == 83)){
			save.();
		};

		if((modifiers == 262144) && (key == 79)){
			open.();
		};
	};
};

applyFunc = {
	var type, controls, argList = [], valueList = [], argArray,
	argValueList;
	if(instList.selection[0] != nil){
		type = instList.items[instList.selection[0]].asSymbol;
		argValueList = ~groups[instList.selection[0]][1];
		argValueList.do({
			arg item;
			var value;

			value = item[1].asString;
			value = this.interpret(value);

			~groups[instList.selection[0]][0].set(
				item[0].asSymbol, value
			);
		});
	}
};

/*** FILE FUNCTIONS ***/
new = {
	filePath = nil;
	instList.items_([]);
	synthPupUpMenu.items_([]);
	argValue.value = "";
	newSynthBtn.states_([["Play", Color.white, scConstants[\newSynthColor]]]);
	minSlider.value = "";
	maxSlider.value = "";
	midiDefs = Dictionary();
	~groups = [];
	mainWin.name = scConstants[\title] ++ "untitled.gc";
	Server.freeAll;
};

saveAs = {
	Dialog.savePanel({
		arg path;
		var name;
		filePath = path;
		# name =
		scFileManager[\saveFile].(path, midiDefs);
		mainWin.name = scConstants[\title] ++ name;
	},{
	});
};

save = {
	if(filePath == nil,
		{
			Dialog.savePanel({
				arg path;
				var name;
				filePath = path;
				midiDefs.postln;
				# name=
				scFileManager[\saveFile].(path, midiDefs);
				mainWin.name = scConstants[\title] ++ name;
			},{
			});
		},
		{
			scFileManager[\saveFile].(filePath, midiDefs);
		}
	);
};

open = {
	Dialog.openPanel({
		arg path;
		var name, qwerty, done = false;
		new.();
		filePath = path;
		# name, minSlider, maxSlider, id, midiDefs =
		scFileManager[\openFile].(path, synthPupUpMenu, instList,
			minSlider, maxSlider, argValue, controlSlider, newSynthBtn);
		mainWin.name = scConstants[\title] ++ name;
		done = true;
		Routine{
			0.5.wait;
			~groups.collect({
				arg item, i;
				item[0] = Group(s.defaultGroup, 'addToTail');
			});
		}.play(AppClock)
	},{

	});
};

)












