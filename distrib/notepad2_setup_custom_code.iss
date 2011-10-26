(*
;* Notepad2 - Installer script
;*
;* Copyright (C) 2010-2011 XhmikosR
;*
;* This file is part of Notepad2-mod.
;*
;* See License.txt for details.

; $Id$
*)


[Code]
////////////////////////////////////////
//  Custom functions and procedures   //
////////////////////////////////////////

// Check if Notepad2 has replaced Windows Notepad
function DefaulNotepadCheck(): Boolean;
var
  svalue: String;
begin
  if RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad2.exe', 'Debugger', svalue) then begin
    if svalue = (ExpandConstant('"{pf}\Notepad2\Notepad2.exe" /z')) then begin
      Result := True;
    end
    else begin
      Result := False;
    end;
  end;
end;


function IsOldBuildInstalled(): Boolean;
begin
  if RegKeyExists(HKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad2') AND
  FileExists(ExpandConstant('{pf}\Notepad2\Notepad2.inf')) then begin
    Result := True;
  end else
    Result := False;
end;


function IsUpgrade(): Boolean;
var
  sPrevPath: String;
begin
  sPrevPath := WizardForm.PrevAppDir;
  Result := (sPrevPath <> '');
end;


// Check if Notepad2's settings exist
function SettingsExistCheck(): Boolean;
begin
  if FileExists(ExpandConstant('{userappdata}\Notepad2\Notepad2.ini')) then begin
    Result := True;
  end else
    Result := False;
end;


function UnInstallOldVersion(): Integer;
var
  sUnInstPath: String;
  sUnInstallString: String;
  iResultCode: Integer;
begin
// Return Values:
// 0 - no idea
// 1 - can't find the registry key (probably no previous version installed)
// 2 - uninstall string is empty
// 3 - error executing the UnInstallString
// 4 - successfully executed the UnInstallString

  // default return value
  Result := 0;

  sUnInstPath := 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad2';
  sUnInstallString := '';

  // get the uninstall string of the old app
  if RegQueryStringValue(HKLM, sUnInstPath, 'UninstallString', sUnInstallString) then begin
    if sUnInstallString <> '' then begin
      sUnInstallString := RemoveQuotes(sUnInstallString);
      if Exec(sUnInstallString, '', '', SW_HIDE, ewWaitUntilTerminated, iResultCode) then begin
        Result := 4;
        Sleep(500);
      end else
        Result := 3;
      end else
        Result := 2;
  end else
    Result := 1;
end;


procedure CleanUpSettings();
begin
  DeleteFile(ExpandConstant('{userappdata}\Notepad2\Notepad2.ini'));
  RemoveDir(ExpandConstant('{userappdata}\Notepad2'));
end;
