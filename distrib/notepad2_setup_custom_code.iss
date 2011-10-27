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
  if RegQueryStringValue(HKLM, 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe', 'Debugger', svalue) then begin
    if svalue = (ExpandConstant('"{pf}\Notepad2\Notepad2.exe" /z')) then begin
      Log('Custom Code: Notepad2 is set as the default notepad');
      Result := True;
    end
    else begin
      Log('Custom Code: Notepad2 is NOT set as the default notepad');
      Result := False;
    end;
  end;
end;


function IsOldBuildInstalled(): Boolean;
begin
  if RegKeyExists(HKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad2') AND
  FileExists(ExpandConstant('{pf}\Notepad2\Uninstall.inf')) then begin
    Log('Custom Code: The old build is installed');
    Result := True;
  end
  else begin
    Log('Custom Code: The old build is NOT installed');
    Result := False;
  end;
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
    Log('Custom Code: Settings are present');
    Result := True;
  end
  else begin
    Log('Custom Code: Settings are NOT present');
    Result := False;
  end;
end;


function UninstallOldVersion(): Integer;
var
  iResultCode: Integer;
begin
  // Return Values:
  // 0 - no idea
  // 1 - error executing the command
  // 2 - successfully executed the command

  // default return value
  Log('Custom Code: Will try to uninstall the old build');
  Result := 0;
    if Exec('rundll32.exe', 'advpack.dll,LaunchINFSectionEx "C:\Program Files\Notepad2\Uninstall.inf",DefaultUninstall,,8,N', '', SW_HIDE, ewWaitUntilTerminated, iResultCode) then begin
      Result := 2;
      Sleep(500);
      Log('Custom Code: The old build was successfully uninstalled');
    end
    else begin
      Result := 1;
      Log('Custom Code: Something went wrong when uninstalling the old build');
    end;
end;


procedure CleanUpSettings();
begin
  DeleteFile(ExpandConstant('{userappdata}\Notepad2\Notepad2.ini'));
  RemoveDir(ExpandConstant('{userappdata}\Notepad2'));
end;
