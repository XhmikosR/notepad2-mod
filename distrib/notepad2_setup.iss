;* Notepad2-mod - Installer script
;*
;* Copyright (C) 2010-2017 XhmikosR
;*
;* This file is part of Notepad2-mod.
;*
;* See License.txt for details.

; Requirements:
; Inno Setup: http://www.jrsoftware.org/isdl.php


#define VS2017

; Preprocessor related stuff
#if VER < EncodeVer(5,5,9)
  #error Update your Inno Setup version (5.5.9 or newer)
#endif

#if !defined(VS2017)
  #error You need to define the compiler used; VS2017
#endif

#if defined(VS2017)
  #define compiler "VS2017"
#endif

#define bindir "..\bin\" + compiler

#ifnexist bindir + "\Release_x86\Notepad2.exe"
  #error Compile Notepad2 x86 first
#endif

#ifnexist bindir + "\Release_x64\Notepad2.exe"
  #error Compile Notepad2 x64 first
#endif

#define VerMajor
#define VerMinor
#define VerBuild
#define VerRevision

#expr ParseVersion(bindir + "\Release_x86\Notepad2.exe", VerMajor, VerMinor, VerBuild, VerRevision)
#define app_version   str(VerMajor) + "." + str(VerMinor) + "." + str(VerBuild) + "." + str(VerRevision)
#define app_name      "Notepad2-mod"
#define app_copyright "Copyright � 2004-2017, Florian Balmer et al."
#define quick_launch  "{userappdata}\Microsoft\Internet Explorer\Quick Launch"


[Setup]
AppId={#app_name}
AppName={#app_name}
AppVersion={#app_version}
AppVerName={#app_name} {#app_version}
AppPublisher=XhmikosR
AppPublisherURL=https://github.com/XhmikosR/notepad2-mod
AppSupportURL=https://github.com/XhmikosR/notepad2-mod
AppUpdatesURL=https://github.com/XhmikosR/notepad2-mod
AppContact=https://github.com/XhmikosR/notepad2-mod
AppCopyright={#app_copyright}
VersionInfoVersion={#app_version}
UninstallDisplayIcon={app}\Notepad2.exe
#if defined(VS2017)
UninstallDisplayName={#app_name} {#app_version}
#else
UninstallDisplayName={#app_name} {#app_version} ({#compiler})
#endif
DefaultDirName={pf}\Notepad2
LicenseFile=license.txt
OutputDir=.
#if defined(VS2017)
OutputBaseFilename={#app_name}.{#app_version}
#else
OutputBaseFilename={#app_name}.{#app_version}_{#compiler}
#endif
SetupIconFile=Setup.ico
WizardImageFile=compiler:WizModernImage-IS.bmp
WizardSmallImageFile=WizardSmallImageFile.bmp
Compression=lzma2/max
InternalCompressLevel=max
SolidCompression=yes
EnableDirDoesntExistWarning=no
AllowNoIcons=yes
ShowTasksTreeLines=yes
DisableDirPage=yes
DisableProgramGroupPage=yes
DisableReadyPage=yes
DisableWelcomePage=yes
AllowCancelDuringInstall=no
MinVersion=5.1sp3
ArchitecturesAllowed=x86 x64
ArchitecturesInstallIn64BitMode=x64
#ifexist "..\signinfo.txt"
SignTool=MySignTool
#endif
CloseApplications=true
SetupMutex='{#app_name}' + '_setup_mutex'


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
en.tsk_StartMenuIcon         =Create a Start Menu shortcut


[Tasks]
Name: desktopicon;        Description: {cm:CreateDesktopIcon};     GroupDescription: {cm:AdditionalIcons}; Flags: unchecked
Name: desktopicon\user;   Description: {cm:tsk_CurrentUser};       GroupDescription: {cm:AdditionalIcons}; Flags: unchecked exclusive
Name: desktopicon\common; Description: {cm:tsk_AllUsers};          GroupDescription: {cm:AdditionalIcons}; Flags: unchecked exclusive
Name: startup_icon;       Description: {cm:tsk_StartMenuIcon};     GroupDescription: {cm:AdditionalIcons}
Name: quicklaunchicon;    Description: {cm:CreateQuickLaunchIcon}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked;             OnlyBelowVersion: 6.01
Name: reset_settings;     Description: {cm:tsk_ResetSettings};     GroupDescription: {cm:tsk_Other};       Flags: checkedonce unchecked; Check: SettingsExistCheck()
Name: set_default;        Description: {cm:tsk_SetDefault};        GroupDescription: {cm:tsk_Other};                                     Check: not DefaulNotepadCheck()
Name: remove_default;     Description: {cm:tsk_RemoveDefault};     GroupDescription: {cm:tsk_Other};       Flags: checkedonce unchecked; Check: DefaulNotepadCheck()


[Files]
Source: {#bindir}\Release_x64\Notepad2.exe; DestDir: {app};                  Flags: ignoreversion;                         Check: Is64BitInstallMode()
Source: {#bindir}\Release_x86\Notepad2.exe; DestDir: {app};                  Flags: ignoreversion;                         Check: not Is64BitInstallMode()
Source: ..\License.txt;                     DestDir: {app};                  Flags: ignoreversion
Source: ..\Notepad2.txt;                    DestDir: {app};                  Flags: ignoreversion
Source: ..\Readme-mod.txt;                  DestDir: {app};                  Flags: ignoreversion
Source: Notepad2.ini;                       DestDir: {userappdata}\Notepad2; Flags: onlyifdoesntexist uninsneveruninstall


[Icons]
Name: {commondesktop}\{#app_name}; Filename: {app}\Notepad2.exe; Tasks: desktopicon\common; Comment: {#app_name} {#app_version}; WorkingDir: {app}; AppUserModelID: Notepad2; IconFilename: {app}\Notepad2.exe; IconIndex: 0
Name: {userdesktop}\{#app_name};   Filename: {app}\Notepad2.exe; Tasks: desktopicon\user;   Comment: {#app_name} {#app_version}; WorkingDir: {app}; AppUserModelID: Notepad2; IconFilename: {app}\Notepad2.exe; IconIndex: 0
Name: {userstartmenu}\{#app_name}; Filename: {app}\Notepad2.exe; Tasks: startup_icon;       Comment: {#app_name} {#app_version}; WorkingDir: {app}; AppUserModelID: Notepad2; IconFilename: {app}\Notepad2.exe; IconIndex: 0
Name: {#quick_launch}\{#app_name}; Filename: {app}\Notepad2.exe; Tasks: quicklaunchicon;    Comment: {#app_name} {#app_version}; WorkingDir: {app};                           IconFilename: {app}\Notepad2.exe; IconIndex: 0


[INI]
Filename: {app}\Notepad2.ini; Section: Notepad2; Key: Notepad2.ini; String: %APPDATA%\Notepad2\Notepad2.ini


[Run]
Filename: {app}\Notepad2.exe; Description: {cm:LaunchProgram,{#app_name}}; WorkingDir: {app}; Flags: nowait postinstall skipifsilent unchecked


[InstallDelete]
Type: files;      Name: {userdesktop}\{#app_name}.lnk;   Check: not IsTaskSelected('desktopicon\user')   and IsUpgrade()
Type: files;      Name: {commondesktop}\{#app_name}.lnk; Check: not IsTaskSelected('desktopicon\common') and IsUpgrade()
Type: files;      Name: {userstartmenu}\{#app_name}.lnk; Check: not IsTaskSelected('startup_icon')       and IsUpgrade()
Type: files;      Name: {#quick_launch}\{#app_name}.lnk; Check: not IsTaskSelected('quicklaunchicon')    and IsUpgrade(); OnlyBelowVersion: 6.01
Type: files;      Name: {app}\Notepad2.ini
Type: files;      Name: {app}\Readme.txt


[UninstallDelete]
Type: files;      Name: {app}\Notepad2.ini
Type: dirifempty; Name: {app}


[Code]
const IFEO = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe';

#if defined(sse_required) || defined(sse2_required)
function IsProcessorFeaturePresent(Feature: Integer): Boolean;
external 'IsProcessorFeaturePresent@kernel32.dll stdcall';
#endif


// Check if Notepad2 has replaced Windows Notepad
function DefaulNotepadCheck(): Boolean;
var
  sDebugger: String;
begin
  if RegQueryStringValue(HKLM, IFEO, 'Debugger', sDebugger) and
  (sDebugger = (ExpandConstant('"{app}\Notepad2.exe" /z'))) then begin
    Log('Custom Code: {#app_name} is set as the default notepad');
    Result := True;
  end
  else begin
    Log('Custom Code: {#app_name} is NOT set as the default notepad');
    Result := False;
  end;
end;


#if defined(sse_required)
function IsSSESupported(): Boolean;
begin
  // PF_XMMI_INSTRUCTIONS_AVAILABLE
  Result := IsProcessorFeaturePresent(6);
end;

#elif defined(sse2_required)

function IsSSE2Supported(): Boolean;
begin
  // PF_XMMI64_INSTRUCTIONS_AVAILABLE
  Result := IsProcessorFeaturePresent(10);
end;

#endif


function IsOldBuildInstalled(sInfFile: String): Boolean;
begin
  if RegKeyExists(HKLM, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad2') and
  FileExists(ExpandConstant('{pf}\Notepad2\' + sInfFile)) then
    Result := True
  else
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
    Log('Custom Code: Settings are present');
    Result := True;
  end
  else begin
    Log('Custom Code: Settings are NOT present');
    Result := False;
  end;
end;


function UninstallOldVersion(sInfFile: String): Integer;
var
  iResultCode: Integer;
begin
  // Return Values:
  // 0 - no idea
  // 1 - error executing the command
  // 2 - successfully executed the command

  // default return value
  Result := 0;
  // TODO: use RegQueryStringValue
  if not Exec('rundll32.exe', ExpandConstant('advpack.dll,LaunchINFSectionEx ' + '"{pf}\Notepad2\' + sInfFile +'",DefaultUninstall,,8,N'), '', SW_HIDE, ewWaitUntilTerminated, iResultCode) then begin
    Result := 1;
  end
  else begin
    Result := 2;
    Sleep(200);
  end;
end;


function ShouldSkipPage(PageID: Integer): Boolean;
begin
  // Hide the license page if IsUpgrade()
  if IsUpgrade() and (PageID = wpLicense) then
    Result := True;
end;


procedure AddReg();
begin
  RegWriteStringValue(HKCR, 'Applications\notepad2.exe', 'AppUserModelID', 'Notepad2');
  RegWriteStringValue(HKCR, 'Applications\notepad2.exe\shell\open\command', '', ExpandConstant('"{app}\Notepad2.exe" %1'));
  RegWriteStringValue(HKCR, '*\OpenWithList\notepad2.exe', '', '');
end;


procedure CleanUpSettings();
begin
  DeleteFile(ExpandConstant('{userappdata}\Notepad2\Notepad2.ini'));
  RemoveDir(ExpandConstant('{userappdata}\Notepad2'));
end;


procedure RemoveReg();
begin
  RegDeleteKeyIncludingSubkeys(HKCR, 'Applications\notepad2.exe');
  RegDeleteKeyIncludingSubkeys(HKCR, '*\OpenWithList\notepad2.exe');
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
    if IsTaskSelected('reset_settings') then
      CleanUpSettings();

    if IsOldBuildInstalled('Uninstall.inf') or IsOldBuildInstalled('Notepad2.inf') then begin
      if IsOldBuildInstalled('Uninstall.inf') then begin
        Log('Custom Code: The old build is installed, will try to uninstall it');
        if UninstallOldVersion('Uninstall.inf') = 2 then
          Log('Custom Code: The old build was successfully uninstalled')
        else
          Log('Custom Code: Something went wrong when uninstalling the old build');
      end;

      if IsOldBuildInstalled('Notepad2.inf') then begin
        Log('Custom Code: The official Notepad2 build is installed, will try to uninstall it');
        if UninstallOldVersion('Notepad2.inf') = 2 then
          Log('Custom Code: The official Notepad2 build was successfully uninstalled')
        else
          Log('Custom Code: Something went wrong when uninstalling the official Notepad2 build');
      end;

      // This is the case where the old build is installed; the DefaulNotepadCheck() returns true
      // and the set_default task isn't selected
      if not IsTaskSelected('remove_default') then
        RegWriteStringValue(HKLM, IFEO, 'Debugger', ExpandConstant('"{app}\Notepad2.exe" /z'));

    end;
  end;

  if CurStep = ssPostInstall then begin
    if IsTaskSelected('set_default') then
      RegWriteStringValue(HKLM, IFEO, 'Debugger', ExpandConstant('"{app}\Notepad2.exe" /z'));
    if IsTaskSelected('remove_default') then begin
      RegDeleteValue(HKLM, IFEO, 'Debugger');
      RegDeleteKeyIfEmpty(HKLM, IFEO);
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
      if SuppressibleMsgBox(CustomMessage('msg_DeleteSettings'), mbConfirmation, MB_YESNO or MB_DEFBUTTON2, IDNO) = IDYES then
        CleanUpSettings();
    end;

    if DefaulNotepadCheck() then
      RegDeleteValue(HKLM, IFEO, 'Debugger');
    RegDeleteKeyIfEmpty(HKLM, IFEO);
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
begin
    Result := True;

#if defined(sse2_required)
    if not IsSSE2Supported() then begin
      SuppressibleMsgBox(CustomMessage('msg_simd_sse2'), mbCriticalError, MB_OK, MB_OK);
      Result := False;
    end;
#elif defined(sse_required)
    if not IsSSESupported() then begin
      SuppressibleMsgBox(CustomMessage('msg_simd_sse'), mbCriticalError, MB_OK, MB_OK);
      Result := False;
    end;
#endif

end;
