(
var mainWin, userView, scrollView;
var scConstants, scWebView, srcPath;

/*** IMPORTING ALL SCD FILES ***/
~path = thisProcess.nowExecutingPath.replace("Main.scd", "");
srcPath = ~path +/+ "src";
~scConstantsPath =  srcPath +/+ "scConstants.scd";
~scWebView = srcPath +/+ "scWebView.scd";
scConstants = FileLoader(~scConstantsPath);
scWebView = FileLoader(~scWebView);

/*** GUI GENERATIONS ***/
mainWin = Window(scConstants[\title]).front;
scrollView = ScrollView(mainWin);
scrollView.resize = 5;

userView = UserView(scrollView, Rect(
	0,
	0,
	scConstants[\mainWidth],
	scConstants[\mainHeight]
));

userView.background = scConstants[\userViewBackground];
userView.resize = 5;

mainWin.layout_(
	VLayout(
		ToolBar(
			MenuAction("File", {
				"File".postln;
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
					MenuAction("About Mts", {
						scWebView[\webDoc].();
					}).font_(scConstants[\menuFont])
				).front
			}).font_(scConstants[\menuFont]),
		),
		scrollView
	).margins_(0).spacing_(0);
);

//mainWin.acceptsMouseOver = true;

)
























