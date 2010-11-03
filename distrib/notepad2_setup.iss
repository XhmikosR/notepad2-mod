;* Notepad2 - Installer script
;*
;* Copyright (C) 2010 XhmikosR
;*
;* This file is part of Notepad2.
;*
;* See License.txt for details.

; Requirements:
; Inno Setup QuickStart Pack Unicode v5.4.0(+): http://www.jrsoftware.org/isdl.php#qsp

; $Id$


;To compile the 64bit version, change the following to "true"
#define is64bit =      false

#define app_name       "Notepad2"
#define app_publisher  "XhmikosR"
#define app_copyright  "Copyright © 2004-2010, Florian Balmer"
#define app_url        "http://code.google.com/p/notepad2-mod/"
#define app_exe        "Notepad2.exe"

#define VerMajor
#define VerMinor
#define VerBuild
#define VerRevision

#expr ParseVersion("..\Release\Notepad2.exe", VerMajor, VerMinor, VerBuild, VerRevision)
#define app_version    str(VerMajor) + "." + str(VerMinor) + "." + str(VerBuild) + "." + str(VerRevision)


[Setup]
#if is64bit
UninstallDisplayName={#= app_name} v{#= app_version} x64
OutputBaseFilename={#= app_name}_{#app_version}.x64
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
#else
UninstallDisplayName={#= app_name} v{#= app_version}
OutputBaseFilename={#= app_name}_{#app_version}.x86
#endif
AppId={#= app_name}
AppName={#= app_name}
AppVersion={#app_version}
AppVerName={#= app_name} v{#app_version}
AppPublisher={#app_publisher}
AppPublisherURL={#app_url}
AppSupportURL={#app_url}
AppUpdatesURL={#app_url}
AppContact={#app_url}
AppCopyright={#app_copyright}
VersionInfoCompany={#app_publisher}
VersionInfoCopyright={#app_copyright}
VersionInfoDescription={#= app_name} v{#app_version} Setup
VersionInfoTextVersion={#app_version}
VersionInfoVersion={#app_version}
VersionInfoProductName={#app_name}
VersionInfoProductVersion={#app_version}
VersionInfoProductTextVersion={#app_version}
UninstallDisplayIcon={app}\{#app_exe}
DefaultDirName={pf}\{#app_name}
LicenseFile=..\License.txt
OutputDir=.
SetupIconFile=..\res\Notepad2.ico
WizardSmallImageFile=WizardSmallImageFile.bmp
Compression=lzma2/ultra64
InternalCompressLevel=normal
SolidCompression=yes
EnableDirDoesntExistWarning=no
AllowNoIcons=yes
ShowTasksTreeLines=yes
DisableDirPage=yes
DisableProgramGroupPage=yes
DisableReadyPage=yes
DisableWelcomePage=yes
AllowCancelDuringInstall=no
MinVersion=0,5.0


[Languages]
Name: en; MessagesFile: compiler:Default.isl


[Messages]
BeveledLabel={#app_name} v{#app_version}


[CustomMessages]
en.msg_DeleteSettings=Do you also want to delete Notepad2's settings? %nIf you plan on installing Notepad2 again then you do not have to delete them.
en.msg_SetupIsRunningWarning=Notepad2 setup is already running!
en.msg_AppIsRunning=Notepad2 is running! Please close it and run again setup.
en.tsk_AllUsers=For all users
en.tsk_CurrentUser=For the current user only
en.tsk_Other=Other tasks:
en.tsk_ResetSettings=Reset Notepad2's settings
en.tsk_RemoveDefault=Restore Windows notepad
en.tsk_SetDefault=Replace Windows notepad with Notepad2


[Tasks]
Name: desktopicon; Description: {cm:CreateDesktopIcon}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked
Name: desktopicon\user; Description: {cm:tsk_CurrentUser}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked exclusive
Name: desktopicon\common; Description: {cm:tsk_AllUsers}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked exclusive
Name: quicklaunchicon; Description: {cm:CreateQuickLaunchIcon}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked; OnlyBelowVersion: 0,6.01
Name: reset_settings; Description: {cm:tsk_ResetSettings}; GroupDescription: {cm:tsk_Other}; Check: SettingsExistCheck(); Flags: checkedonce unchecked
Name: set_default; Description: {cm:tsk_SetDefault}; GroupDescription: {cm:tsk_Other}; Check: DefaulNotepadCheck()
Name: remove_default; Description: {cm:tsk_RemoveDefault}; GroupDescription: {cm:tsk_Other}; Check: NOT DefaulNotepadCheck(); Flags: checkedonce unchecked


[Files]
Source: psvince.dll; DestDir: {app}; Flags: ignoreversion
Source: ..\License.txt; DestDir: {app}; Flags: ignoreversion
#if is64Bit
Source: ..\Release_x64\Notepad2.exe; DestDir: {app}; Flags: ignoreversion
#else
Source: ..\Release\Notepad2.exe; DestDir: {app}; Flags: ignoreversion
#endif
Source: Notepad2.ini; DestDir: {userappdata}\Notepad2; Flags: onlyifdoesntexist uninsneveruninstall
Source: notepad2.redir.ini; DestDir: {app}; DestName: Notepad2.ini; Flags: ignoreversion
Source: ..\Notepad2.txt; DestDir: {app}; Flags: ignoreversion
Source: ..\Readme-mod.txt; DestDir: {app}; DestName: Readme.txt; Flags: ignoreversion


[Icons]
Name: {commondesktop}\{#app_name}; Filename: {app}\{#app_exe}; Tasks: desktopicon\common; Comment: {#app_name} v{#app_version}; WorkingDir: {app}; AppUserModelID: Notepad2; IconFilename: {app}\{#app_exe}; IconIndex: 0
Name: {userdesktop}\{#app_name}; Filename: {app}\{#app_exe}; Tasks: desktopicon\user; Comment: {#app_name} v{#app_version}; WorkingDir: {app}; AppUserModelID: Notepad2; IconFilename: {app}\{#app_exe}; IconIndex: 0
Name: {userappdata}\Microsoft\Internet Explorer\Quick Launch\{#app_name}; Filename: {app}\{#app_exe}; Tasks: quicklaunchicon; Comment: {#app_name} v{#app_version}; WorkingDir: {app}; IconFilename: {app}\{#app_exe}; IconIndex: 0


[Registry]
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe; ValueType: string; ValueName: Debugger; ValueData: """{app}\Notepad2.exe"" /z"; Tasks: set_default
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe; ValueName: Debugger; Flags: deletevalue; Tasks: remove_default
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe; ValueName: Debugger; Flags: uninsdeletevalue uninsdeletekeyifempty
;Root: HKCR; Subkey: Applications\notepad2.exe\shell\open\command; ValueData: """{app}\Notepad2.exe"" %1"; Flags: uninsdeletevalue uninsdeletekeyifempty; Tasks: set_default


[Run]
Filename: {app}\{#app_exe}; Description: {cm:LaunchProgram,{#app_name}}; WorkingDir: {app}; Flags: nowait postinstall skipifsilent unchecked


[InstallDelete]
Type: files; Name: {userdesktop}\{#app_name}.lnk; Check: NOT IsTaskSelected('desktopicon\user') AND IsUpdate()
Type: files; Name: {commondesktop}\{#app_name}.lnk; Check: NOT IsTaskSelected('desktopicon\common') AND IsUpdate()


[UninstallDelete]
Type: dirifempty; Name: {app}


[Code]
// Include custom installer code
#include 'notepad2_setup_custom_code.iss'


// General functions
function IsModuleLoaded(modulename: AnsiString ):  Boolean;
external 'IsModuleLoaded@files:psvince.dll stdcall setuponly';


function IsModuleLoadedU(modulename: AnsiString ):  Boolean;
external 'IsModuleLoaded@{app}\psvince.dll stdcall uninstallonly';


function ShouldSkipPage(PageID: Integer): Boolean;
begin
  if IsUpdate then begin
    Case PageID of
      // Hide the license page
      wpLicense: Result := True;
    else
      Result := False;
    end;
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
    if IsOldBuildInstalled then begin
      //UnInstallOldVersion;
    end;
  end;
  if CurStep = ssPostInstall then begin
    if IsTaskSelected('reset_settings') then begin
      CleanUpSettings;
    end;
  end;
end;


procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  // When uninstalling, ask the user to delete Notepad2's settings and logs
  if CurUninstallStep = usUninstall then begin
    if SettingsExistCheck() then begin
      if MsgBox(ExpandConstant('{cm:msg_DeleteSettings}'), mbConfirmation, MB_YESNO or MB_DEFBUTTON2) = IDYES then begin
        CleanUpSettings;
      end;
    end;
  end;
end;


function InitializeSetup(): Boolean;
begin
  if IsModuleLoaded( '{#app_exe}' ) then begin
    MsgBox(ExpandConstant('{cm:msg_AppIsRunning}'), mbError, MB_OK );
    Result := False;
    Abort;
  end else
    Result := True;
    is_update := RegKeyExists(HKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{#app_name}_is1');
end;


function InitializeUninstall(): Boolean;
begin
  // Check if app is running during uninstallation
  if IsModuleLoadedU( '{#app_exe}' ) then begin
    MsgBox(ExpandConstant('{cm:msg_AppIsRunning}'), mbError, MB_OK );
    Result := False;
  end else
    Result := True;

    // Unload the psvince.dll in order to be uninstalled
    UnloadDLL(ExpandConstant('{app}\psvince.dll'));
end;
