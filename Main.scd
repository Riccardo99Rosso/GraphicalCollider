(
var mainWin, userView, scrollView;
var scConstants, scWebView, srcPath,
newInstBtn, deleteInstBtn, moveBeforeInstBtn,
moveAfterInstBtn, instList;

~audioBuses = [];
~controlBuses = [];
~synthDefs = [];
~synths = [];

/*** IMPORTING ALL SCD FILES ***/
~path = thisProcess.nowExecutingPath.replace("Main.scd", "");
srcPath = ~path +/+ "src";
~scConstantsPath =  srcPath +/+ "scConstants.scd";
~scWebView = srcPath +/+ "scWebView.scd";
scConstants = FileLoader(~scConstantsPath);
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

userView.drawFunc = {
};

newInstBtn = Button(userView, Rect(37.5, 50, 100, 50))
.states_([["New Instrument", Color.black, scConstants[\instBtnColor]]])
.action = {
	var win, view, tField, width=100, height=40;
	win = Window(border: false);
	win.setInnerExtent(width, height);
	win.view.keyDownAction = {
		|doc, char, mod, unicode, keycode, key|
		[doc, char, mod, unicode, keycode, key].postln;
		if(key == 16777216){
			win.close;
		};
	};
	tField = TextField(win, Rect(0, 0, width, height))
	.font_(scConstants[\newInstFont]);
	win.front.alwaysOnTop_(true);
}
;

deleteInstBtn = Button(userView, Rect(37.5, 125, 100, 50))
.states_([["Delete Instrument", Color.black, scConstants[\instBtnColor]]]);

moveBeforeInstBtn = Button(userView, Rect(37.5, 200, 100, 50))
.states_([["Move Before", Color.black, scConstants[\instBtnColor]]]);

moveAfterInstBtn = Button(userView, Rect(37.5, 275, 100, 50))
.states_([["Move After", Color.black, scConstants[\instBtnColor]]]);

instList = ListView(userView, Rect(180,50,400,600))
.background_(scConstants[\instListBackground]);

)






























