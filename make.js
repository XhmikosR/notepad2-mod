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
        cleanCSS = require("clean-css"),
        UglifyJS = require("uglify-js"),
        ROOT_DIR = __dirname + "/";     // absolute path to project's root

    //
    // make minify
    //
    target.minify = function () {
        cd(ROOT_DIR);
        echo();
        echo("### Minifying css files...");

        // jquery.fancybox.min.css
        var inCss = cat(["css/jquery.fancybox.css",
                         "css/jquery.fancybox-thumbs.css"
        ]);

        var fancyboxMinCss = cleanCSS.process(inCss, {
            removeEmpty: true,
            keepSpecialComments: 1
        });

        fs.writeFileSync("css/jquery.fancybox.min.css", fancyboxMinCss, "utf8");

        echo();
        echo("### Finished css/jquery.fancybox.min.css.");

        // pack.css

        var inCss2 = cat(["css/stylesheet.css",
                          "css/normalize.css"
        ]);

        var packCss = cleanCSS.process(inCss2, {
            removeEmpty: true,
            keepSpecialComments: 0
        });

        fs.writeFileSync("css/pack.css", packCss, "utf8");

        echo();
        echo("### Finished css/pack.css.");

        echo();
        echo("### Minifying js files...");

        var inJs = cat(["js/jquery.mousewheel.js",
                        "js/jquery.fancybox.js",
                        "js/jquery.fancybox-thumbs.js"]);

        var minifiedJs = UglifyJS.minify(inJs, {
            compress: true,
            fromString: true, // this is needed to pass JS source code instead of filenames
            mangle: true,
            warnings: false
        });

        fs.writeFileSync("js/pack.js", minifiedJs.code, "utf8");

        echo();
        echo("### Finished js/pack.js.");
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
        echo("  minify  Creates the minified CSS and JS");
        echo("  help    shows this help message");
    };

}());
