/**!
 * make.js, script to build the website for Notepad2-mod
 * Released under the terms of MIT license
 *
 * https://github.com/XhmikosR/notepad2-mod
 *
 * Copyright (C) 2013 XhmikosR
 */

(function () {
    "use strict";

    require("shelljs/make");
    var fs = require("fs"),
        CleanCSS = require("clean-css");

    //
    // make minify
    //
    target.minify = function () {
        cd(__dirname);
        echo();
        echo("### Minifying css files...");

        // pack.css

        var inCss2 = cat(["css/normalize.css",
                          "css/stylesheet.css"
        ]);

        var minifier2 = new CleanCSS({
                keepSpecialComments: 0,
                compatibility: "ie8"
            });

        fs.writeFileSync("css/pack.css", minifier2.minify(inCss2).styles, "utf8");

        echo();
        echo("### Finished css/pack.css.");
    };


    //
    // make all
    //
    target.all = function () {
        target.minify();
    };

    //
    // make help
    //
    target.help = function () {
        echo("Available targets:");
        echo("  minify  Creates the minified CSS");
        echo("  help    shows this help message");
    };

}());
