_A modified version (fork) of Notepad2 based on Kai Liu's and other people's patches._

# Changes compared to the official Notepad2:

* Code folding
* Support for bookmarks
* Option to mark all occurrences of a word
* Word auto-completion
* Syntax highlighting support for AutoHotkey, AutoIt3, AviSynth, Bash, CMake, Inno Setup, LaTeX, Lua, NSIS, Ruby and Tcl scripts
* Improved support for NFO ANSI art
* Support for replacing Windows Notepad using a clean, unintrusive registry-based method
* Other various minor changes and tweaks


# Supported Operating Systems:
* Windows 2000 (when compiled with WDK, which is the default build)
* XP (SP3, SP2 might or might not work), Vista, 7 and 8 both 32-bit and 64-bit


# [Screenshots] (https://github.com/XhmikosR/notepad2-mod/wiki/Screenshots)


# Notes:
* If you find any bugs or have any suggestions for the implemented lexers (and **not** only) feel free to **provide patches/pull requests**.
* I'm not interested in any **localization** of Notepad2.

#Contributors:
* Kai Liu
* RL Vision
* Aleksandar Lekov
* Bruno Barbieri

#More information:
* Source code and binaries:   https://github.com/XhmikosR/notepad2-mod
* Official Notepad2 website:  http://www.flos-freeware.ch/notepad2.html
* Code folding usage guide:   https://github.com/XhmikosR/notepad2-mod/wiki/Code-Folding-Usage
* Kai Liu's website:          http://code.kliu.org/misc/notepad2/
* Bookmark Edition website:   http://www.rlvision.com/notepad2/about.asp

# Changed keyboard shortcuts compared to Notepad2:
`Ctrl+Alt+F2`         Expand selection to next match.  
`Ctrl+Alt+Shift+F2`   Expand selection to previous match.  
`Ctrl+Shift+Enter`    New line with toggled auto indent option.  

Notepad2-mod 4.2.25 has been created with Scintilla 3.2.1 HG 3256e70613e4.  
You can use WDK 7.1, MSVC 2010 or Intel C++ Compiler XE 2011 SP1 Update 6 (or newer) to build Notepad2-mod.