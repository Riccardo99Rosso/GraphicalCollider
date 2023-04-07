var dict = Dictionary();
var scDict, synthDefList, snippet, loadAll;

snippet = {
	arg name="";
	var text;

	text = "(
/*
Description:

*/

SynthDef(\\" ++ name ++ ", {

//insert your code here

}).add;
)";

	text;
};

scDict = FileLoader(~scConstantsPath);

synthDefList = {
	var win, scroll, i=0, canvas = View(),
	createSynthDef, layout, dy = Dictionary();

	win  = Window("SynthDef Editor").front.alwaysOnTop_(true);
	scroll = ScrollView(win);

	createSynthDef = {
		arg name="UntitledSynthDef", editName = false;
		var sName;
		var view = View().background_(scDict[\synthColor]).layout_(
			HLayout(
				sName = TextField()
				.string_(name)
				.enabled_(editName)
				.font_(scDict[\synthFont]),
				Button().states_([["Code"]]).action_({
					var file, path, code, tView, tWin;

					path = scDict[\allSynthDefPath] ++
					"/" ++ sName.string ++ ".scd";
					file = File(path.standardizePath, "r");

					if((file.isOpen != false),
						{
							code = file.readAllString;
						},
						{
							code = snippet.(sName.string);
						}
					);
					file.close;

					tWin = Window(sName.string, Rect(800, 350, 500, 400));
					tView = TextView(tWin, Rect(
						0,
						0,
						tWin.bounds.width,
						tWin.bounds.height))
					.font_(scDict[\menuFont])
					.string_(code)
					.palette_(QPalette.dark);  // set all colors here


					tWin.layout_(
						VLayout(
							ToolBar(
								MenuAction("Save", {
									file = File(path.standardizePath, "w");
									file.write(tView.string);
									file.close;
								}).font_(scDict[\menuFont])
							),
							tView
						).margins_(0).spacing_(0);
					);

					tWin.onClose = {
						loadAll.();
					};

					tWin.front.alwaysOnTop_(true);

				}),
				//Button().states_([["Delete"]]).action_({view.remove; i = i - 1;})
			)
		);
		i = i + 1;
		view;
	};

	win.layout_(
		VLayout(
			ToolBar(
				MenuAction("Create SynthDef", {
					layout.insert(createSynthDef.("UntitledSynthDef", true));
				}).font_(scDict[\menuFont])
			),
			scroll
		).margins_(0).spacing_(0);
	);

	layout = VLayout();
	canvas.layout = layout;
	scroll.canvas = canvas;
	//scroll.canvas.background_(scDict[\synthTypeLabelColor]);

	dy.add(\data ->
		PathName(scDict[\allSynthDefPath])
		.entries.collect({
			arg sf;
			var file, synthDef, buffer, name;

			sf = sf.fullPath;
			sf = sf.replace(".scd", "");
			buffer = sf.split($\\);
			name = buffer[(buffer.size - 1)];
			layout.insert(createSynthDef.(name, false));
		});
	);
};

loadAll = {
	~synthDefs = [];
	PathName(scDict[\allSynthDefPath])
	.entries.collect({
		arg sf;
		var file, synthDef, name, buffer;

		sf = sf.fullPath;
		synthDef = File(sf.standardizePath, "r");
		file = synthDef.readAllString;
		this.interpret(file);

		sf = sf.replace(".scd", "");
		buffer = sf.split($\\);
		name = buffer[(buffer.size - 1)];
		~synthDefs = ~synthDefs.add(name);
		synthDef.close;
	});
};

dict.put(\synthDefList, synthDefList);
dict.put(\loadAll, loadAll);

dict;