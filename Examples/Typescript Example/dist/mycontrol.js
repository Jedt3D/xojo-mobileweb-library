"use strict";
var Example;
(function (Example) {
    class myControl extends XojoWeb.XojoVisualControl {
        constructor(id, events) {
            super(id, events);
        }
    }
    Example.myControl = myControl;
})(Example || (Example = {}));
