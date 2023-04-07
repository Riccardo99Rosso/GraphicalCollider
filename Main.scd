(
var mainWin, userView, scrollView;
var scConstants, scWebView, srcPath, scSynthDef,
newInstBtn, deleteInstBtn, moveBeforeInstBtn,
moveAfterInstBtn, instList, moveBefore = false, moveAfter = false,
toMove = nil, synthPupUpMenu, argValue, applyBtn, newSynthBtn, applyFunc;

~synthDefs = [];
~groups = [];

/*** IMPORTING ALL SCD FILES ***/
~path = thisProcess.nowExecutingPath.replace("Main.scd", "");
srcPath = ~path +/+ "src";
~scConstantsPath =  srcPath +/+ "scConstants.scd";
~scSynthDef = srcPath +/+ "scSynthDef.scd";
~scWebView = srcPath +/+ "scWebView.scd";
scConstants = FileLoader(~scConstantsPath);
scSynthDef = FileLoader(~scSynthDef);
scWebView = FileLoader(~scWebView);

/*** GUI GENERATIONS ***/
mainWin = Window(scConstants[\title], Rect(50, 100, 1000, 700)).front;
mainWin.background = scConstants[\menuColor];
//scrollView = ScrollView(mainWin);
//scrollView.resize = 5;

userView = UserView(mainWin);

userView.background = scConstants[\userViewBackground];
//userView.resize = 5;

mainWin.layout_(
	VLayout(
		ToolBar(
			MenuAction("File", {
				Menu(
					MenuAction("New", {
					})
					.shortcut_("Ctrl+n")
					.font_(scConstants[\menuFont]),
					MenuAction("Open", {
					})
					.shortcut_("Ctrl+o")
					.font_(scConstants[\menuFont]),
					MenuAction("Save", {
					})
					.shortcut_("Ctrl+s")
					.font_(scConstants[\menuFont]),
					MenuAction("Save as...", {
					})
					.shortcut_("Ctrl+shift+s")
					.font_(scConstants[\menuFont]),
					MenuAction("Reload", {
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
					MenuAction("Algorithmic Instruments", {
					}).font_(scConstants[\menuFont])
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
	moveBefore = false;
	moveAfter = false;
	argValueList = ~groups[sbs.value][1];
	argValueList.do({
		arg item;
		argList = argList.add(item[0]);
		valueList = valueList.add(item[1]);
	});
	argValue.string = valueList[0];
	synthPupUpMenu.items_(argList);
});
instList.mouseUpAction = {
	moveBefore = false;
	moveAfter = false;
};

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
	argValue.string = valueList[index];
};

argValue = TextField(userView, Rect(570, 100, 150, 30))
.font_(scConstants[\instFont])
.background_(scConstants[\argColor])
.keyUpAction_({
	var argValueList;
	argValueList = ~groups[instList.selection[0]][1];
	argValueList[synthPupUpMenu.value][1] = argValue.value;
	~groups[instList.selection[0]][1] = argValueList;
});

applyBtn = Button(userView, Rect(570, 150, 150, 30))
.font_(scConstants[\instFont])
.states_([["Apply", Color.black, scConstants[\applyBtnColor]]])
.action = {
	applyFunc.();
};

newSynthBtn = Button(userView, Rect(570, 200, 150, 70))
.font_(scConstants[\instFont])
.states_([["New Synth", Color.white, scConstants[\newSynthColor]]])
.action = {
	var type, controls, argList = [], valueList = [], argArray, synth,
	argValueList;

	type = instList.items[instList.selection[0]].asSymbol;
	argValueList = ~groups[instList.selection[0]][1];
	synth = Synth(type, target: ~groups[instList.selection[0]][0]);
	argValueList.do({
		arg item, value, argument;

		argument = item[0].asSymbol;
		value = item[1].asFloat;
		synth.set(argument, value);
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
		argValueList = [];
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
				});
				synthPupUpMenu.items_(argList);
				~groups = ~groups.addFirst([Group(), argValueList]);
				argValue.string = valueList[0];
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
		instList.selection = selection;
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
		}
	}
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

			value = item[1];
			if(value.class == String.asClass){
				if("\"".matchRegexp(value) == false){
					~groups[instList.selection[0]][0].set(
						item[0].asSymbol,
						value.asFloat);
				}
			};
		});
	}
};

)

Symbol.asClass;



























