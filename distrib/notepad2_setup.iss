;* Notepad2 - Installer script
;*
;* Copyright (C) 2010-2011 XhmikosR
;*
;* This file is part of Notepad2-mod.
;*
;* See License.txt for details.

; Requirements:
; Inno Setup v5.4.2(+): http://www.jrsoftware.org/isdl.php

; $Id$


;#define ICL12
;#define VS2010
;#define WDK

; Various preprocessor checks
#if VER < 0x05040200
  #error Update your Inno Setup version
#endif


#if !defined(ICL12) && !defined(VS2010) && !defined(WDK)
  #error You need to define ICL12 or VS2010 or WDK first
#endif

#if defined(ICL12) && (defined(VS2010) || defined(WDK))
  #error You can't define ICL12 and at the same time
#endif

#if defined(VS2010) && ( defined(ICL12) || defined(WDK))
  #error You can't define WDK and at the same time
#endif

#if defined(WDK) && (defined(ICL12) || defined(VS2010))
  #error You can't use two defines at the same time
#endif



#if defined(ICL12)
  #define COMPILER "ICL12"
  #define sse2_required
#elif defined(VS2010)
  #define COMPILER "VS2010"
#elif defined(WDK)
  #define COMPILER "WDK"
#endif


#define bindir   "..\bin\" + COMPILER


#define VerMajor
#define VerMinor
#define VerBuild
#define VerRevision

#expr ParseVersion(bindir + "\Release_x86\Notepad2.exe", VerMajor, VerMinor, VerBuild, VerRevision)
#define app_version str(VerMajor) + "." + str(VerMinor) + "." + str(VerBuild) + "." + str(VerRevision)
#define app_name    "Notepad2-mod"
#define IFEO        "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe"


[Setup]
AppId={#app_name}
AppName={#app_name}
AppVersion={#app_version}
AppVerName={#app_name} {#app_version}
AppPublisher=XhmikosR
AppPublisherURL=http://code.google.com/p/notepad2-mod/
AppSupportURL=http://code.google.com/p/notepad2-mod/
AppUpdatesURL=http://code.google.com/p/notepad2-mod/
AppContact=http://code.google.com/p/notepad2-mod/
AppCopyright=Copyright © 2004-2011, Florian Balmer et all
VersionInfoCompany=XhmikosR
VersionInfoCopyright=Copyright © 2004-2011, Florian Balmer et all
VersionInfoDescription={#app_name} {#app_version} Setup
VersionInfoTextVersion={#app_version}
VersionInfoVersion={#app_version}
VersionInfoProductName={#app_name}
VersionInfoProductVersion={#app_version}
VersionInfoProductTextVersion={#app_version}
UninstallDisplayIcon={app}\Notepad2.exe
UninstallDisplayName={#app_name} {#app_version} ({#COMPILER})
DefaultDirName={pf}\Notepad2
LicenseFile=license.txt
OutputDir=.
OutputBaseFilename={#app_name}.{#app_version}_{#COMPILER}
SetupIconFile=Setup.ico
WizardSmallImageFile=WizardSmallImageFile.bmp
SolidCompression=yes
EnableDirDoesntExistWarning=no
AllowNoIcons=yes
ShowTasksTreeLines=yes
DisableDirPage=yes
DisableProgramGroupPage=yes
DisableReadyPage=yes
DisableWelcomePage=yes
AllowCancelDuringInstall=no
#if defined(ICL12) || defined(VS2010) || defined(USE_MSVC2010)
MinVersion=0,5.1.2600sp3
#else
MinVersion=0,5.0
#endif
ArchitecturesAllowed=x86 x64
ArchitecturesInstallIn64BitMode=x64


[Languages]
Name: en; MessagesFile: compiler:Default.isl


[Messages]
BeveledLabel={#app_name} {#app_version}  -  Compiled with {#COMPILER}
SetupWindowTitle=Setup - {#app_name} {#app_version}
#if defined(ICL12) || defined(VS2010) || defined(USE_MSVC2010)
en.WinVersionTooLowError=[name] requires Windows XP Service Pack 3 or newer to run.
#endif


[CustomMessages]
en.msg_AppIsRunning          = Setup has detected that Notepad2 is currently running.%n%nPlease close all instances of it now, then click OK to continue, or Cancel to exit.
en.msg_DeleteSettings        = Do you also want to delete Notepad2's settings?%n%nIf you plan on installing Notepad2 again then you do not have to delete them.
en.msg_SetupIsRunningWarning = Notepad2 setup is already running!
#if defined(sse_required)
en.msg_simd_sse              = This build of Notepad2 requires a CPU with SSE extension support.%n%nYour CPU does not have those capabilities.
#endif
#if defined(sse2_required)
en.msg_simd_sse2             = This build of Notepad2 requires a CPU with SSE2 extension support.%n%nYour CPU does not have those capabilities.
#endif
en.tsk_AllUsers              = For all users
en.tsk_CurrentUser           = For the current user only
en.tsk_Other                 = Other tasks:
en.tsk_ResetSettings         = Reset Notepad2's settings
;en.tsk_RemoveDefault         = Restore Windows notepad
;en.tsk_SetDefault            = Replace Windows notepad with Notepad2


[Tasks]
Name: desktopicon;        Description: {cm:CreateDesktopIcon};     GroupDescription: {cm:AdditionalIcons}; Flags: unchecked
Name: desktopicon\user;   Description: {cm:tsk_CurrentUser};       GroupDescription: {cm:AdditionalIcons}; Flags: unchecked exclusive
Name: desktopicon\common; Description: {cm:tsk_AllUsers};          GroupDescription: {cm:AdditionalIcons}; Flags: unchecked exclusive
Name: quicklaunchicon;    Description: {cm:CreateQuickLaunchIcon}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked;             OnlyBelowVersion: 0,6.01
Name: reset_settings;     Description: {cm:tsk_ResetSettings};     GroupDescription: {cm:tsk_Other};       Flags: checkedonce unchecked; Check: SettingsExistCheck()
;Name: set_default;        Description: {cm:tsk_SetDefault};        GroupDescription: {cm:tsk_Other};       Flags: checkedonce;           Check: NOT DefaulNotepadCheck()
;Name: remove_default;     Description: {cm:tsk_RemoveDefault};     GroupDescription: {cm:tsk_Other};       Flags: checkedonce unchecked; Check: DefaulNotepadCheck()


[Files]
#if defined(sse_required) || defined(sse2_required)
Source: WinCPUID.dll;                       DestDir: {tmp};                  Flags: dontcopy noencryption
#endif
Source: ..\License.txt;                     DestDir: {app};                  Flags: ignoreversion
Source: {#bindir}\Release_x64\Notepad2.exe; DestDir: {app};                  Flags: ignoreversion; Check: Is64BitInstallMode()
Source: {#bindir}\Release_x86\Notepad2.exe; DestDir: {app};                  Flags: ignoreversion; Check: NOT Is64BitInstallMode()
Source: Notepad2.ini;                       DestDir: {userappdata}\Notepad2; Flags: onlyifdoesntexist uninsneveruninstall
Source: ..\Notepad2.txt;                    DestDir: {app};                  Flags: ignoreversion
Source: ..\Readme.txt;                      DestDir: {app};                  Flags: ignoreversion
Source: ..\Readme-mod.txt;                  DestDir: {app};                  Flags: ignoreversion


[Icons]
Name: {commondesktop}\{#app_name}; Filename: {app}\Notepad2.exe; Tasks: desktopicon\common; Comment: {#app_name} {#app_version}; WorkingDir: {app}; AppUserModelID: Notepad2; IconFilename: {app}\Notepad2.exe; IconIndex: 0
Name: {userdesktop}\{#app_name};   Filename: {app}\Notepad2.exe; Tasks: desktopicon\user;   Comment: {#app_name} {#app_version}; WorkingDir: {app}; AppUserModelID: Notepad2; IconFilename: {app}\Notepad2.exe; IconIndex: 0
Name: {userappdata}\Microsoft\Internet Explorer\Quick Launch\{#app_name}; Filename: {app}\Notepad2.exe; Tasks: quicklaunchicon; Comment: {#app_name} {#app_version}; WorkingDir: {app}; IconFilename: {app}\Notepad2.exe; IconIndex: 0


[Registry]
Root: HKLM; Subkey: {#IFEO};                   ValueName: Debugger;       ValueType: string; ValueData: """{app}\Notepad2.exe"" /z"; Flags: uninsdeletevalue uninsdeletekeyifempty
;Root: HKLM; Subkey: {#IFEO};                   ValueName: Debugger;       Flags: deletevalue; Tasks: remove_default
;Root: HKLM; Subkey: {#IFEO};                   ValueName: Debugger;       Flags: uninsdeletevalue uninsdeletekeyifempty
Root: HKCR; Subkey: Applications\notepad2.exe; Valuename: AppUserModelID; ValueType: string; ValueData: Notepad2; Flags: uninsdeletekey
Root: HKCR; Subkey: Applications\notepad2.exe\shell\open\command;         ValueType: string; ValueData: """{app}\Notepad2.exe"" %1"
Root: HKCR; Subkey: *\OpenWithList\notepad2.exe;                                             ValueData: ""; Flags: uninsdeletevalue uninsdeletekeyifempty


[INI]
Filename: {app}\Notepad2.ini; Section: Notepad2; Key: Notepad2.ini; String: %APPDATA%\Notepad2\Notepad2.ini


[Run]
Filename: {app}\Notepad2.exe; Description: {cm:LaunchProgram,{#app_name}}; WorkingDir: {app}; Flags: nowait postinstall skipifsilent unchecked


[InstallDelete]
Type: files; Name: {userdesktop}\{#app_name}.lnk;   Check: NOT IsTaskSelected('desktopicon\user')   AND IsUpgrade()
Type: files; Name: {commondesktop}\{#app_name}.lnk; Check: NOT IsTaskSelected('desktopicon\common') AND IsUpgrade()
Type: files; Name: {app}\Notepad2.ini;              Check: IsUpgrade()
Type: files; Name: {app}\psvince.dll;               Check: IsUpgrade()


[UninstallDelete]
Type: files;      Name: {app}\Notepad2.ini
Type: dirifempty; Name: {app}


[Code]
// CPU detection functions
#if defined(sse_required) || defined(sse2_required)
#include "cpu_detection.iss"
#endif

// Global variables/constants and general functions
const installer_mutex_name = '{#app_name}' + '_setup_mutex';


////////////////////////////////////////
//  Custom functions and procedures   //
////////////////////////////////////////


// Check if Notepad2 is running by using its window's class name
function Notepad2IsRunningCheck(): Boolean;
var
  Wnd: HWND;
begin
  Wnd := FindWindowByClassName('Notepad2U');
  if Wnd <> 0 then begin
    Log('Custom Code: Found Notepad2`s window class name; Notepad2 is running');
    Result := True;
  end
  else begin
    Log('Custom Code: Notepad2 is NOT running');
    Result := False;
  end;
end;


// Check if Notepad2 has replaced Windows Notepad
function DefaulNotepadCheck(): Boolean;
var
  svalue: String;
begin
  if RegQueryStringValue(HKLM, '{#IFEO}', 'Debugger', svalue) then begin
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


function ShouldSkipPage(PageID: Integer): Boolean;
begin
  // Hide the license page
  if IsUpgrade() AND (PageID = wpLicense) then begin
    Result := True;
  end
  else begin
    Result := False;
  end;
end;


procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpSelectTasks then
    WizardForm.NextButton.Caption := SetupMessage(msgButtonInstall)
  else if CurPageID = wpFinished then
    WizardForm.NextButton.Caption := SetupMessage(msgButtonFinish)
end;


procedure CurStepChanged(CurStep: TSetupStep);
begin

  if CurStep = ssInstall then begin
    if IsOldBuildInstalled() then begin
      UninstallOldVersion();
    end;
  end;

  if CurStep = ssPostInstall then begin
    if IsTaskSelected('reset_settings') then begin
      CleanUpSettings();
    end;
  end;

end;


procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  // When uninstalling, ask the user to delete Notepad2's settings and logs
  if CurUninstallStep = usUninstall then begin
    if SettingsExistCheck() then begin
      if SuppressibleMsgBox(ExpandConstant('{cm:msg_DeleteSettings}'), mbConfirmation, MB_YESNO OR MB_DEFBUTTON2, IDNO) = IDYES then begin
        CleanUpSettings();
      end;
    end;
  end;
end;


procedure InitializeWizard();
begin
  WizardForm.SelectTasksLabel.Hide;
  WizardForm.TasksList.Top    := 0;
  WizardForm.TasksList.Height := PageFromID(wpSelectTasks).SurfaceHeight;
end;


function InitializeSetup(): Boolean;
var
  nMsgBoxResult: Integer;
begin
  // Create a mutex for the installer and if it's already running then show a message and stop installation
  if CheckForMutexes(installer_mutex_name) AND NOT WizardSilent() then begin
    SuppressibleMsgBox(ExpandConstant('{cm:msg_SetupIsRunningWarning}'), mbError, MB_OK, MB_OK);
    Result := False;
  end
  else begin
    Result := True;
    CreateMutex(installer_mutex_name);

    while Notepad2IsRunningCheck() AND (nMsgBoxResult <> IDCANCEL) DO begin
      nMsgBoxResult := SuppressibleMsgBox(ExpandConstant('{cm:msg_AppIsRunning}'), mbError, MB_OKCANCEL, IDCANCEL);
    end;

    if nMsgBoxResult = IDCANCEL then begin
      Result := False;
    end;

#if defined(sse_required) || defined(sse2_required)
      // Acquire CPU information
      CPUCheck();

#if defined(sse2_required)
      if Result AND NOT Is_SSE2_Supported() then begin
        SuppressibleMsgBox(CustomMessage('msg_simd_sse2'), mbError, MB_OK, MB_OK);
        Result := False;
      end;
#elif defined(sse_required)
      if Result AND NOT Is_SSE_Supported() then begin
        SuppressibleMsgBox(CustomMessage('msg_simd_sse'), mbError, MB_OK, MB_OK);
        Result := False;
      end;
#endif

#endif

  end;
end;


function InitializeUninstall(): Boolean;
var
  nMsgBoxResult: Integer;
begin
  if CheckForMutexes(installer_mutex_name) then begin
    SuppressibleMsgBox(ExpandConstant('{cm:msg_SetupIsRunningWarning}'), mbError, MB_OK, MB_OK);
    Result := False;
  end else
    Result := True;

    // Check if app is running during uninstallation
    while Notepad2IsRunningCheck() AND (nMsgBoxResult <> IDCANCEL) DO begin
      nMsgBoxResult := SuppressibleMsgBox(ExpandConstant('{cm:msg_AppIsRunning}'), mbError, MB_OKCANCEL, IDCANCEL);
    end;

    if nMsgBoxResult = IDCANCEL then begin
      Result := False;
    end;

    CreateMutex(installer_mutex_name);
end;
