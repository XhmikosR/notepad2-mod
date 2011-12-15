;* Notepad2-mod - Installer script
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

; Preprocessor related stuff
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
  #define compiler "ICL12"
  #define sse2_required
#elif defined(VS2010)
  #define compiler "VS2010"
#elif defined(WDK)
  #define compiler "WDK"
#endif


#define bindir       "..\bin\" + compiler

#ifnexist SourcePath + bindir + "\Release_x86\Notepad2.exe"
  #error Compile Notepad2 x86 first
#endif

#ifnexist SourcePath + bindir + "\Release_x64\Notepad2.exe"
  #error Compile Notepad2 x64 first
#endif

#define VerMajor
#define VerMinor
#define VerBuild
#define VerRevision

#expr ParseVersion(bindir + "\Release_x86\Notepad2.exe", VerMajor, VerMinor, VerBuild, VerRevision)
#define app_version  str(VerMajor) + "." + str(VerMinor) + "." + str(VerBuild) + "." + str(VerRevision)
#define app_name     "Notepad2-mod"
#define quick_launch "{userappdata}\Microsoft\Internet Explorer\Quick Launch"
#define IFEO         "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe"


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
AppCopyright=Copyright © 2004-2011, Florian Balmer et al.
VersionInfoCompany=XhmikosR
VersionInfoCopyright=Copyright © 2004-2011, Florian Balmer et al.
VersionInfoDescription={#app_name} {#app_version} Setup
VersionInfoTextVersion={#app_version}
VersionInfoVersion={#app_version}
VersionInfoProductName={#app_name}
VersionInfoProductVersion={#app_version}
VersionInfoProductTextVersion={#app_version}
UninstallDisplayIcon={app}\Notepad2.exe
UninstallDisplayName={#app_name} {#app_version} ({#compiler})
DefaultDirName={pf}\Notepad2
LicenseFile=license.txt
OutputDir=.
OutputBaseFilename={#app_name}.{#app_version}_{#compiler}
SetupIconFile=Setup.ico
WizardImageFile=compiler:WizModernImage-IS.bmp
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
#if defined(WDK)
MinVersion=0,5.0
#else
MinVersion=0,5.1.2600sp3
#endif
ArchitecturesAllowed=x86 x64
ArchitecturesInstallIn64BitMode=x64


[Languages]
Name: en; MessagesFile: compiler:Default.isl


[Messages]
BeveledLabel     ={#app_name} {#app_version}  -  Compiled with {#compiler}
SetupAppTitle    =Setup - {#app_name}
SetupWindowTitle =Setup - {#app_name}


[CustomMessages]
en.msg_AppIsRunning          =Setup has detected that {#app_name} is currently running.%n%nPlease close all instances of it now, then click OK to continue, or Cancel to exit.
en.msg_AppIsRunningUninstall =Uninstall has detected that {#app_name} is currently running.%n%nPlease close all instances of it now, then click OK to continue, or Cancel to exit.
en.msg_DeleteSettings        =Do you also want to delete {#app_name}'s settings?%n%nIf you plan on installing {#app_name} again then you do not have to delete them.
en.msg_SetupIsRunningWarning ={#app_name} setup is already running!
#if defined(sse_required)
en.msg_simd_sse              =This build of {#app_name} requires a CPU with SSE extension support.%n%nYour CPU does not have those capabilities.
#elif defined(sse2_required)
en.msg_simd_sse2             =This build of {#app_name} requires a CPU with SSE2 extension support.%n%nYour CPU does not have those capabilities.
#endif
en.tsk_AllUsers              =For all users
en.tsk_CurrentUser           =For the current user only
en.tsk_Other                 =Other tasks:
en.tsk_ResetSettings         =Reset {#app_name}'s settings
en.tsk_RemoveDefault         =Restore Windows notepad
en.tsk_SetDefault            =Replace Windows notepad with {#app_name}


[Tasks]
Name: desktopicon;        Description: {cm:CreateDesktopIcon};     GroupDescription: {cm:AdditionalIcons}; Flags: unchecked
Name: desktopicon\user;   Description: {cm:tsk_CurrentUser};       GroupDescription: {cm:AdditionalIcons}; Flags: unchecked exclusive
Name: desktopicon\common; Description: {cm:tsk_AllUsers};          GroupDescription: {cm:AdditionalIcons}; Flags: unchecked exclusive
Name: quicklaunchicon;    Description: {cm:CreateQuickLaunchIcon}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked;             OnlyBelowVersion: 0,6.01
Name: reset_settings;     Description: {cm:tsk_ResetSettings};     GroupDescription: {cm:tsk_Other};       Flags: checkedonce unchecked; Check: SettingsExistCheck()
Name: set_default;        Description: {cm:tsk_SetDefault};        GroupDescription: {cm:tsk_Other};                                     Check: not DefaulNotepadCheck()
Name: remove_default;     Description: {cm:tsk_RemoveDefault};     GroupDescription: {cm:tsk_Other};       Flags: checkedonce unchecked; Check: DefaulNotepadCheck()


[Files]
Source: psvince.dll;                        DestDir: {app};                  Flags: ignoreversion
Source: ..\License.txt;                     DestDir: {app};                  Flags: ignoreversion
Source: {#bindir}\Release_x64\Notepad2.exe; DestDir: {app};                  Flags: ignoreversion;                         Check: Is64BitInstallMode()
Source: {#bindir}\Release_x86\Notepad2.exe; DestDir: {app};                  Flags: ignoreversion;                         Check: not Is64BitInstallMode()
Source: Notepad2.ini;                       DestDir: {userappdata}\Notepad2; Flags: onlyifdoesntexist uninsneveruninstall
Source: ..\Notepad2.txt;                    DestDir: {app};                  Flags: ignoreversion
Source: ..\Readme.txt;                      DestDir: {app};                  Flags: ignoreversion
Source: ..\Readme-mod.txt;                  DestDir: {app};                  Flags: ignoreversion


[Icons]
Name: {commondesktop}\{#app_name}; Filename: {app}\Notepad2.exe; Tasks: desktopicon\common; Comment: {#app_name} {#app_version}; WorkingDir: {app}; AppUserModelID: Notepad2; IconFilename: {app}\Notepad2.exe; IconIndex: 0
Name: {userdesktop}\{#app_name};   Filename: {app}\Notepad2.exe; Tasks: desktopicon\user;   Comment: {#app_name} {#app_version}; WorkingDir: {app}; AppUserModelID: Notepad2; IconFilename: {app}\Notepad2.exe; IconIndex: 0
Name: {#quick_launch}\{#app_name}; Filename: {app}\Notepad2.exe; Tasks: quicklaunchicon;    Comment: {#app_name} {#app_version}; WorkingDir: {app};                           IconFilename: {app}\Notepad2.exe; IconIndex: 0


[INI]
Filename: {app}\Notepad2.ini; Section: Notepad2; Key: Notepad2.ini; String: %APPDATA%\Notepad2\Notepad2.ini


[Run]
Filename: {app}\Notepad2.exe; Description: {cm:LaunchProgram,{#app_name}}; WorkingDir: {app}; Flags: nowait postinstall skipifsilent unchecked


[InstallDelete]
Type: files;      Name: {userdesktop}\{#app_name}.lnk;   Check: not IsTaskSelected('desktopicon\user')   and IsUpgrade()
Type: files;      Name: {commondesktop}\{#app_name}.lnk; Check: not IsTaskSelected('desktopicon\common') and IsUpgrade()
Type: files;      Name: {#quick_launch}\{#app_name}.lnk; Check: not IsTaskSelected('quicklaunchicon')    and IsUpgrade(); OnlyBelowVersion: 0,6.01
Type: files;      Name: {app}\Notepad2.ini;              Check: IsUpgrade()


[UninstallDelete]
Type: files;      Name: {app}\Notepad2.ini
Type: dirifempty; Name: {app}


[Code]
// Global variables/constants and general functions
const installer_mutex_name = '{#app_name}' + '_setup_mutex';

function IsModuleLoaded(modulename: AnsiString): Boolean;
external 'IsModuleLoaded2@files:psvince.dll stdcall setuponly';

function IsModuleLoadedU(modulename: AnsiString): Boolean;
external 'IsModuleLoaded2@{app}\psvince.dll stdcall uninstallonly';

#if defined(sse_required) || defined(sse2_required)
function IsProcessorFeaturePresent(Feature: Integer): Boolean;
external 'IsProcessorFeaturePresent@kernel32.dll stdcall';
#endif


////////////////////////////////////////
//  Custom functions and procedures   //
////////////////////////////////////////


// Check if Notepad2 has replaced Windows Notepad
function DefaulNotepadCheck(): Boolean;
var
  sDebugger: String;
begin
  if RegQueryStringValue(HKLM, '{#IFEO}', 'Debugger', sDebugger) then begin
    if sDebugger = (ExpandConstant('"{app}\Notepad2.exe" /z')) then begin
      Log('Custom Code: {#app_name} is set as the default notepad');
      Result := True;
    end
    else begin
      Log('Custom Code: {#app_name} is NOT set as the default notepad');
      Result := False;
    end;
  end;
end;


#if defined(sse_required)
function Is_SSE_Supported(): Boolean;
begin
  // PF_XMMI_INSTRUCTIONS_AVAILABLE
  Result := IsProcessorFeaturePresent(6);
end;

#elif defined(sse2_required)

function Is_SSE2_Supported(): Boolean;
begin
  // PF_XMMI64_INSTRUCTIONS_AVAILABLE
  Result := IsProcessorFeaturePresent(10);
end;

#endif


function IsOldBuildInstalled(): Boolean;
begin
  if RegKeyExists(HKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad2') and
  FileExists(ExpandConstant('{pf}\Notepad2\Uninstall.inf')) then begin
    Log('Custom Code: The old build is installed');
    Result := True;
  end
  else begin
    Log('Custom Code: The old build is NOT installed');
    Result := False;
  end;
end;


function IsOfficialBuildInstalled(): Boolean;
begin
  if RegKeyExists(HKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad2') and
  FileExists(ExpandConstant('{pf}\Notepad2\Notepad2.inf')) then begin
    Log('Custom Code: The official Notepad2 build is installed');
    Result := True;
  end
  else begin
    Log('Custom Code: The official Notepad2 build is NOT installed');
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
    if Exec('rundll32.exe', ExpandConstant('advpack.dll,LaunchINFSectionEx "{pf}\Notepad2\Uninstall.inf",DefaultUninstall,,8,N'), '', SW_HIDE, ewWaitUntilTerminated, iResultCode) then begin
      Result := 2;
      Sleep(200);
      Log('Custom Code: The old build was successfully uninstalled');
    end
    else begin
      Result := 1;
      Log('Custom Code: Something went wrong when uninstalling the old build');
    end;
end;


function UninstallOfficialVersion(): Integer;
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
    if Exec('rundll32.exe', ExpandConstant('advpack.dll,LaunchINFSectionEx "{pf}\Notepad2\Notepad2.inf",DefaultUninstall,,8,N'), '', SW_HIDE, ewWaitUntilTerminated, iResultCode) then begin
      Result := 2;
      Sleep(200);
      Log('Custom Code: The official Notepad2 build was successfully uninstalled');
    end
    else begin
      Result := 1;
      Log('Custom Code: Something went wrong when uninstalling the official Notepad2 build');
    end;
end;


function ShouldSkipPage(PageID: Integer): Boolean;
begin
  // Hide the license page
  if IsUpgrade() and (PageID = wpLicense) then
    Result := True
  else
    Result := False;
end;


procedure AddReg();
begin
  RegWriteStringValue(HKCR, 'Applications\notepad2.exe', 'AppUserModelID', 'Notepad2');
  RegWriteStringValue(HKCR, 'Applications\notepad2.exe\shell\open\command', '', ExpandConstant('"{app}\Notepad2.exe" %1'));
  RegWriteStringValue(HKCR, '*\OpenWithList\notepad2.exe', '', '');
end;


procedure RemoveReg();
begin
  RegDeleteKeyIncludingSubkeys(HKCR, 'Applications\notepad2.exe');
  RegDeleteKeyIncludingSubkeys(HKCR, '*\OpenWithList\notepad2.exe');
end;


procedure CleanUpSettings();
begin
  DeleteFile(ExpandConstant('{userappdata}\Notepad2\Notepad2.ini'));
  RemoveDir(ExpandConstant('{userappdata}\Notepad2'));
end;


procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpSelectTasks then
    WizardForm.NextButton.Caption := SetupMessage(msgButtonInstall)
  else if CurPageID = wpFinished then
    WizardForm.NextButton.Caption := SetupMessage(msgButtonFinish);
end;


procedure CurStepChanged(CurStep: TSetupStep);
begin

  if CurStep = ssInstall then begin
    if IsOldBuildInstalled() then begin
      UninstallOldVersion();
      // This is the case where the old build is installed; the DefaulNotepadCheck() returns true
      // and the set_default task isn't selected
      if not IsTaskSelected('remove_default') then
        RegWriteStringValue(HKLM, '{#IFEO}', 'Debugger', ExpandConstant('"{app}\Notepad2.exe" /z'));
    end;
    if IsOfficialBuildInstalled() then begin
      UninstallOfficialVersion();
      // This is the case where the old build is installed; the DefaulNotepadCheck() returns true
      // and the set_default task isn't selected
      if not IsTaskSelected('remove_default') then
        RegWriteStringValue(HKLM, '{#IFEO}', 'Debugger', ExpandConstant('"{app}\Notepad2.exe" /z'));
    end;
  end;

  if CurStep = ssPostInstall then begin
    if IsTaskSelected('reset_settings') then
      CleanUpSettings();

    if IsTaskSelected('set_default') then
      RegWriteStringValue(HKLM, '{#IFEO}', 'Debugger', ExpandConstant('"{app}\Notepad2.exe" /z'));

    if IsTaskSelected('remove_default') then begin
      RegDeleteValue(HKLM, '{#IFEO}', 'Debugger');
      RegDeleteKeyIfEmpty(HKLM, '{#IFEO}');
    end;

    // Always add Notepad2's AppUserModelID and the rest registry values
    AddReg();
  end;

end;


procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  // When uninstalling, ask the user to delete Notepad2's settings
  if CurUninstallStep = usUninstall then begin
    if SettingsExistCheck() then begin
      if SuppressibleMsgBox(CustomMessage('msg_DeleteSettings'), mbConfirmation, MB_YESNO or MB_DEFBUTTON2, IDNO) = IDYES then begin
        CleanUpSettings();
      end;
    end;

    if DefaulNotepadCheck() then
      RegDeleteValue(HKLM, '{#IFEO}', 'Debugger');
    RegDeleteKeyIfEmpty(HKLM, '{#IFEO}');
    RemoveReg();

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
  iMsgBoxResult: Integer;
begin
  // Create a mutex for the installer and if it's already running then show a message and stop installation
  if CheckForMutexes(installer_mutex_name) and not WizardSilent() then begin
    SuppressibleMsgBox(CustomMessage('msg_SetupIsRunningWarning'), mbError, MB_OK, MB_OK);
    Result := False;
  end
  else begin
    Result := True;
    CreateMutex(installer_mutex_name);

    while IsModuleLoaded('Notepad2.exe') and (iMsgBoxResult <> IDCANCEL) do
      iMsgBoxResult := SuppressibleMsgBox(CustomMessage('msg_AppIsRunning'), mbError, MB_OKCANCEL, IDCANCEL);

    if iMsgBoxResult = IDCANCEL then
      Result := False;

#if defined(sse2_required)
    if not Is_SSE2_Supported() then begin
      SuppressibleMsgBox(CustomMessage('msg_simd_sse2'), mbCriticalError, MB_OK, MB_OK);
      Result := False;
    end;
#elif defined(sse_required)
    if not Is_SSE_Supported() then begin
      SuppressibleMsgBox(CustomMessage('msg_simd_sse'), mbCriticalError, MB_OK, MB_OK);
      Result := False;
    end;
#endif

  end;
end;


function InitializeUninstall(): Boolean;
var
  iMsgBoxResult: Integer;
begin
  if CheckForMutexes(installer_mutex_name) then begin
    SuppressibleMsgBox(CustomMessage('msg_SetupIsRunningWarning'), mbError, MB_OK, MB_OK);
    Result := False;
  end
  else begin
    Result := True;
    CreateMutex(installer_mutex_name);

    // Check if app is running during uninstallation
    while IsModuleLoadedU('Notepad2.exe') and (iMsgBoxResult <> IDCANCEL) do
      iMsgBoxResult := SuppressibleMsgBox(CustomMessage('msg_AppIsRunningUninstall'), mbError, MB_OKCANCEL, IDCANCEL);

    if iMsgBoxResult = IDCANCEL then
      Result := False;

    // Unload psvince.dll in order to be uninstalled
    UnloadDLL(ExpandConstant('{app}\psvince.dll'));
  end;
end;
