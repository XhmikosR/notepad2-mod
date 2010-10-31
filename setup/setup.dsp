# Microsoft Developer Studio Project File - Name="SetupStub" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# NOSKIPWIN64
# USEKIT 4

# TARGTYPE "Win32 (x86) Application" 0x0101

!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "setup.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "setup.mak" CFG="SetupStub - Win32 Full"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "SetupStub - Win32 Full" (based on "Win32 (x86) Application")
!MESSAGE "SetupStub - Win32 Lite" (based on "Win32 (x86) Application")
!MESSAGE "SetupStub - Win64 Full" (based on "Win32 (x86) Application")
!MESSAGE "SetupStub - Win64 Lite" (based on "Win32 (x86) Application")
!MESSAGE 

CPP=cl.exe
RSC=rc.exe
LINK32=link.exe

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Target_Dir ""

!IF "$(CFG)" == "SetupStub - Win32 Full"

# PROP Output_Dir "bin.x86-32"
# PROP Intermediate_Dir "obj.x86-32.full"
# ADD CPP /nologo /MD /W3 /Wp64 /GS- /GF /GL /EHsc /O1 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_UNICODE" /D "UNICODE" /D "_WIN32_WINNT=0x0500" /c
# ADD RSC /l 0x409 /d "NDEBUG" /d "_M_IX86"
# ADD LINK32 kernel32.lib user32.lib shell32.lib comctl32.lib advpack.lib cabinet.lib /nologo /SUBSYSTEM:WINDOWS,5.0 /OSVERSION:5.0 /MACHINE:IX86 /RELEASE /OPT:REF /OPT:ICF /OPT:NOWIN98 /LTCG /MERGE:.rdata=.text /IGNORE:4078 /STUB:dosstub.bin /OUT:bin.x86-32\setupfull.exe

!ELSEIF "$(CFG)" == "SetupStub - Win32 Lite"

# PROP Output_Dir "bin.x86-32"
# PROP Intermediate_Dir "obj.x86-32.lite"
# ADD CPP /nologo /MD /W3 /Wp64 /GS- /GF /GL /EHsc /O1 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_UNICODE" /D "UNICODE" /D "_WIN32_WINNT=0x0500" /D "SETUP_LITE" /c
# ADD RSC /l 0x409 /d "NDEBUG" /d "_M_IX86" /d "SETUP_LITE"
# ADD LINK32 kernel32.lib user32.lib shell32.lib comctl32.lib advpack.lib cabinet.lib /nologo /SUBSYSTEM:WINDOWS,5.0 /OSVERSION:5.0 /MACHINE:IX86 /RELEASE /OPT:REF /OPT:ICF /OPT:NOWIN98 /LTCG /MERGE:.rdata=.text /IGNORE:4078 /STUB:dosstub.bin /OUT:bin.x86-32\setuplite.exe

!ELSEIF "$(CFG)" == "SetupStub - Win64 Full"

# PROP Output_Dir "bin.x86-64"
# PROP Intermediate_Dir "obj.x86-64.full"
# ADD CPP /nologo /MD /W3 /Wp64 /GS- /GF /GL /EHsc /O1 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_UNICODE" /D "UNICODE" /D "_WIN32_WINNT=0x0502" /c
# ADD RSC /l 0x409 /d "NDEBUG" /d "_M_AMD64"
# ADD LINK32 kernel32.lib user32.lib shell32.lib comctl32.lib advpack.lib cabinet.lib /nologo /SUBSYSTEM:WINDOWS,5.2 /OSVERSION:5.2 /MACHINE:AMD64 /RELEASE /OPT:REF /OPT:ICF /OPT:NOWIN98 /LTCG /MERGE:.rdata=.text /IGNORE:4078 /STUB:dosstub.bin /OUT:bin.x86-64\setupfull.exe

!ELSEIF "$(CFG)" == "SetupStub - Win64 Lite"

# PROP Output_Dir "bin.x86-64"
# PROP Intermediate_Dir "obj.x86-64.lite"
# ADD CPP /nologo /MD /W3 /Wp64 /GS- /GF /GL /EHsc /O1 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_UNICODE" /D "UNICODE" /D "_WIN32_WINNT=0x0502" /D "SETUP_LITE" /c
# ADD RSC /l 0x409 /d "NDEBUG" /d "_M_AMD64" /d "SETUP_LITE"
# ADD LINK32 kernel32.lib user32.lib shell32.lib comctl32.lib advpack.lib cabinet.lib /nologo /SUBSYSTEM:WINDOWS,5.2 /OSVERSION:5.2 /MACHINE:AMD64 /RELEASE /OPT:REF /OPT:ICF /OPT:NOWIN98 /LTCG /MERGE:.rdata=.text /IGNORE:4078 /STUB:dosstub.bin /OUT:bin.x86-64\setuplite.exe

!ENDIF

# Begin Target
# Name "SetupStub - Win32 Full"
# Name "SetupStub - Win32 Lite"
# Name "SetupStub - Win64 Full"
# Name "SetupStub - Win64 Lite"

# Begin Group "Source Files"
# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File
SOURCE=.\setup.c
# End Source File
# Begin Source File
SOURCE=.\dosetup.c
# End Source File
# Begin Source File
SOURCE=.\cabinet.c
# End Source File
# End Group

# Begin Group "Header Files"
# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File
SOURCE=.\resource.h
# End Source File
# Begin Source File
SOURCE=.\version.h
# End Source File
# End Group

# Begin Group "Resource Files"
# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# Begin Source File
SOURCE=.\setup.rc
# End Source File
# End Group

# Begin Group "Libraries"
# PROP Default_Filter ""
# Begin Source File
SOURCE=.\libs\Wow64.c
# End Source File
# End Group

# End Target
# End Project
