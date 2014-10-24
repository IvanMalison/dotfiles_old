var hint = slate.op("hint", {
  "characters" : "ASDFGHJKLQWERTYUIOPCVBN"
});

var grid = slate.op("grid", {
  grids: {
    "1920x1080": {"width": 8, "height": 6}
  }
});

var hyper = ":ctrl;shift;alt;cmd";
slate.bindAll({
  "esc:cmd": hint,
  "space:alt": grid
});
slate.bind("h" + hyper, grid);

slate.configAll({
  windowHintsIgnoreHiddenWindows: false,
  windowHintsShowIcons: true,
  windowHintsSpread: true,
  switchShowTitles: true
});