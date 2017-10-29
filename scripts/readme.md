# Notepad2-mod AutoHotkey customization

This folder contains an example [AutoHotkey](https://autohotkey.com/) script to change key bindings and do other useful things with Notepad2 given its lack of configurability for the average user.

The script makes use of [SendMessage](https://msdn.microsoft.com/en-us/library/windows/desktop/ms644950.aspx) Windows calls to Notepad2 operations. These are listed in brief below:

Category|Function/Key|Constant
|---|---|---|
File|&New\tCtrl+N|40000
File|&Open...\tCtrl+O|40001
File|Re&vert\tF5|40002
File|&Save\tCtrl+S|40004
File|Save &As...\tF6|40005
File|Save &Copy...\tCtrl+F6|40006
File|&Read Only|40007
Launch|&New Window\tAlt+N|40011
Launch|&Empty Window\tAlt+0|40012
Launch|Execute &Document\tCtrl+L|40008
Launch|&Open with...\tAlt+L|40009
Launch|&Command...\tCtrl+R|40010
Encoding|&ANSI|40100
Encoding|&Unicode|40101
Encoding|Unicode &Big Endian|40102
Encoding|UTF-&8|40103
Encoding|UTF-8 with &Signature|40104
Encoding|&More...\tF9|40105
Encoding|&Recode...\tF8|40106
Encoding|&Default...|40107
Line Endings|&Windows (CR+LF)|40200
Line Endings|&Unix (LF)|40201
Line Endings|&Mac (CR)|40202
Line Endings|&Default...|40203
Print|Page Se&tup...|40013
Print|&Print...\tCtrl+P|40014
Generic|Propert&ies...|40015
Generic|Create &Desktop Link|40016
Favorites|&Open Favorites...\tAlt+I|40017
Favorites|&Add Current File...\tAlt+K|40018
Favorites|&Manage...\tAlt+F9|40019
Generic|Recent (&History)...\tAlt+H|40020
Generic|E&xit\tAlt+F4|40021
Edit|&Undo\tCtrl+Z|40300
Edit|&Redo\tCtrl+Y|40301
Edit|Cu&t\tCtrl+X|40302
Edit|&Copy\tCtrl+C|40303
Edit|Copy A&ll\tAlt+C|40304
Edit|Copy &Add\tCtrl+E|40305
Edit|&Paste\tCtrl+V|40306
Edit|S&wap\tCtrl+K|40307
Edit|Clear\tDel|40308
Edit|Clear Clipboar&d|40309
Edit|&Select All\tCtrl+A|40310
Lines|Move &Up\tCtrl+Shift+Up|40313
Lines|&Move Down\tCtrl+Shift+Down|40314
Lines|&Duplicate Line\tCtrl+D|40315
Lines|&Cut Line\tCtrl+Shift+X|40316
Lines|C&opy Line\tCtrl+Shift+C|40317
Lines|D&elete Line\tCtrl+Shift+D|40318
Lines|Column &Wrap...\tCtrl+Shift+W|40321
Lines|&Split Lines\tCtrl+I|40322
Lines|&Join Lines\tCtrl+J|40323
Lines|Join &Paragraphs\tCtrl+Shift+J|40324
Block|&Indent\tTab|40325
Block|&Unindent\tShift+Tab|40326
Block|&Enclose Selection...\tAlt+Q|40327
Block|&Duplicate Selection\tAlt+D|40328
Block|&Pad With Spaces\tAlt+B|40329
Block|Strip &First Character\tAlt+Z|40330
Block|Strip &Last Character\tAlt+U|40331
Block|Strip &Trailing Blanks\tAlt+W|40332
Block|Compress &Whitespace\tAlt+P|40333
Block|Merge &Blank Lines\tAlt+Y|40334
Block|&Remove Blank Lines\tAlt+R|40335
Block|&Modify Lines...\tAlt+M|40336
Block|Alig&n Lines...\tAlt+J|40338
Block|S&ort Lines...\tAlt+O|40337
String|&Uppercase\tCtrl+Shift+U|40339
String|&Lowercase\tCtrl+U|40340
String|&Invert Case\tCtrl+Alt+U|40341
String|Title &Case\tCtrl+Alt+I|40342
String|&Sentence Case\tCtrl+Alt+O|40343
String|&Tabify Selection\tCtrl+Shift+T|40345
String|U&ntabify Selection\tCtrl+Shift+S|40344
String|Ta&bify Indent\tCtrl+Alt+T|40347
String|Untabi&fy Indent\tCtrl+Alt+S|40346
Insert|&HTML/XML Tag...\tAlt+X|40348
Insert|&Encoding Identifier\tCtrl+F8|40349
Insert|Time/Date (&Short Form)\tCtrl+F5|40350
Insert|Time/Date (&Long Form)\tCtrl+Shift+F5|40351
Insert|&Filename\tCtrl+F9|40352
Insert|&Path and Filename\tCtrl+Shift+F9|40353
Special|Line Comment (&Toggle)\tCtrl+Q|40354
Special|Stream &Comment\tCtrl+Shift+Q|40355
Special|URL &Encode\tCtrl+Shift+E|40356
Special|URL &Decode\tCtrl+Shift+R|40357
Special|Esca&pe C Chars\tCtrl+Alt+E|40358
Special|&Unescape C Chars\tCtrl+Alt+R|40359
Special|C&har To Hex\tCtrl+Alt+X|40360
Special|Hex To Cha&r\tCtrl+Alt+C|40361
Special|&Find Matching Brace\tCtrl+B|40362
Special|&Select To Matching Brace\tCtrl+Shift+B|40363
Special|Select To Ne&xt\tCtrl+Alt+F2|40371
Special|Select To Pre&vious\tCtrl+Alt+Shift+F2|40372
Special|Complete Word\tCtrl+Enter|40373
Bookmarks|Toggle\tCtrl+F2|40254
Bookmarks|Goto Next\tF2|40255
Bookmarks|Goto Previous\tShift+F2|40257
Bookmarks|Clear All\tAlt+F2|40256
Bookmarks|&Find...\tCtrl+F|40364
Bookmarks|Sa&ve Find Text\tAlt+F3|40365
Bookmarks|Find Ne&xt\tF3|40366
Bookmarks|Find Pre&vious\tShift+F3|40367
Bookmarks|R&eplace...\tCtrl+H|40368
Bookmarks|Replace Ne&xt\tF4|40369
Bookmarks|&Goto...\tCtrl+G|40370
View|&Syntax Scheme...\tF12|40400
View|&2nd Default Scheme\tShift+F12|40401
View|&Customize Schemes...\tCtrl+F12|40402
View|&Default Font...\tAlt+F12|40403
View|Word W&rap\tCtrl+W|40404
View|&Long Line Marker\tCtrl+Shift+L|40405
View|Indentation &Guides\tCtrl+Shift+G|40406
View|Show &Whitespace\tCtrl+Shift+8|40407
View|Show Line &Endings\tCtrl+Shift+9|40408
View|Show Wrap S&ymbols\tCtrl+Shift+0|40409
View|Visual &Brace Matching\tCtrl+Shift+V|40410
View|Highlight C&urrent Line\tCtrl+Shift+I|40411
Mark_Occurrences|&Off|40447
Mark_Occurrences|&Blue|40448
Mark_Occurrences|&Green|40449
Mark_Occurrences|&Red|40450
Mark_Occurrences|Match &Case|40451
Mark_Occurrences|Match &Whole Words Only|40452
View|Line &Numbers\tCtrl+Shift+N|40412
View|Selection &Margin\tCtrl+Shift+M|40413
View|Code &Folding\tCtrl+Shift+Alt+F|40445
View|&Toggle All Folds\tCtrl+Shift+F|40446
View|Zoom &In\tCtrl++|40414
View|Zoom &Out\tCtrl+-|40415
View|Reset &Zoom\tCtrl+/|40416
Settings|Insert Tabs as &Spaces|40417
Settings|&Tab Settings...\tCtrl+T|40418
Settings|&Word Wrap Settings...|40419
Settings|&Long Line Settings...|40420
Settings|Auto In&dent Text|40421
Settings|Auto Close &HTML/XML\tCtrl+Shift+H|40422
Settings|Auto Complete Wo&rds|40453
Settings|&Reuse Window|40423
Settings|Sticky Window &Position|40424
Settings|&Always On Top\tAlt+T|40425
Settings|Minimi&ze To Tray|40426
Settings|Transparent &Mode\tCtrl+0|40427
Settings|Single &File Instance|40428
Settings|File &Change Notification...\tAlt+F5|40429
Window_Title|Filename &Only|40430
Window_Title|Filename and &Directory|40431
Window_Title|Full &Pathname|40432
Window_Title|&Text Excerpt\tCtrl+9|40433
ESC_Key|&None|40434
ESC_Key|&Minimize Notepad2-mod|40435
ESC_KEY|E&xit Notepad2-mod|40436
General|Sa&ve Before Running Tools|40437
General|Remember Recent F&iles|40438
General|Remember S&earch Strings|40439
General|Sh&ow Toolbar|40440
General|C&ustomize Toolbar...|40441
General|Sh&ow Statusbar|40442
General|Save Settings On E&xit|40443
General|Save Settings &Now\tF7|40444
Generic|&About...\tF1|40500

