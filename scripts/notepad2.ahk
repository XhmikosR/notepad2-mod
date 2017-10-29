#SingleInstance,force

;/* --- act only on Notepad2 Windows --- */
#IfWinActive .*Notepad2.*

;/* ===SIMPLE RECONFIGURE HOTSTRING - Execute Document=== */
;/* --- This example simply captures keystrokes using AHK and sends a different command. This is the easiest customization method. --- */

^q::send,^l ; bind Control-Q to Control-L (Execute Document)
^e::Send,^+d ; bind Control-E to Control-Shift-D (Delete Line_
return

;/* ===COPY PATH TO CLIPBOARD=== */
;/* --- There is no easy way to copy the Notepad2 active file path to the clipboard. This script accomplishes that. --- */
!c::
	clipboard=
	WinGetTitle, title, A
	
	FoundPos := RegExMatch(title, "([A-Z]\:.*?) - Notepad2.*", SubPat)
	AutoTrim,On
	if (FoundPos!=0)
		{
			if (SubPat2!="")
				clipboard=%SubPat2%\%SubPat1%
			else
				clipboard=%SubPat1%
				MsgBox "Copied!"
		}

return

;/* ===SENDMESSAGE MAPPINGS TO NOTEPAD2 FUNCTIONS=== */
;/* --- This example uses Windows SendMessage to activate Notepad2 functions. In this case, it binds Alt-G to run both Strip Trailing Blanks and Remove Blank Lines.  --- */


	!g::
		iControl_Identifier=40332 ; Strip Trailing Blanks
		SendMessage, 0x111, iControl_Identifier, 0,, A
		iControl_Identifier=40335 ; Remove Blank Lines
		SendMessage, 0x111, iControl_Identifier, 0,, A
	return

;/* ===OPEN SELECTED FILENAME IN TEXT FILE=== */
;/* --- If you select a filename in a file you're editing in Notepad2, this will open the file in Notepad2 and save you steps. --- */

!o::
	clipboard =
	send,^c
	ClipWait
	text:=clipboard
	sDir:="%A_ScriptDir%"
	NewStr := RegExReplace( text, sDir, A_ScriptDir  )
	NewStr :=RegExReplace(NewStr,"#Include ","")
;/* --- replace notepad.exe with your notepad2 executable path unless you've already replaced notepad completely. --- */
	run_parms=notepad.exe %newstr%
	Run,%run_parms%
	
return
#IfWinActive
