/******************************************************************************
*
*
* Notepad2
*
* Dialogs.h
*   Definitions for Notepad2 dialog boxes
*
* See Readme.txt for more information about this source code.
* Please send me your comments to this work.
*
* See License.txt for details about distribution and modification.
*
*                                              (c) Florian Balmer 1996-2011
*                                                  florian.balmer@gmail.com
*                                               http://www.flos-freeware.ch
*
*
******************************************************************************/


#define MBINFO         0
#define MBWARN         1
#define MBYESNO        2
#define MBYESNOWARN    3
#define MBYESNOCANCEL  4
#define MBOKCANCEL     8

int  MsgBox(int,UINT,...);
void DisplayCmdLineHelp();
BOOL GetDirectory(HWND,int,LPWSTR,LPCWSTR,BOOL);
INT_PTR CALLBACK AboutDlgProc(HWND,UINT,WPARAM,LPARAM);
void RunDlg(HWND,LPCWSTR);
BOOL OpenWithDlg(HWND,LPCWSTR);
BOOL FavoritesDlg(HWND,LPWSTR);
BOOL AddToFavDlg(HWND,LPCWSTR,LPCWSTR);
BOOL FileMRUDlg(HWND,LPWSTR);
BOOL ChangeNotifyDlg(HWND);
BOOL ColumnWrapDlg(HWND,UINT,int *);
BOOL WordWrapSettingsDlg(HWND,UINT,int *);
BOOL LongLineSettingsDlg(HWND,UINT,int *);
BOOL TabSettingsDlg(HWND,UINT,int *);
BOOL SelectDefEncodingDlg(HWND,int *);
BOOL SelectEncodingDlg(HWND,int *);
BOOL RecodeDlg(HWND,int *);
BOOL SelectDefLineEndingDlg(HWND,int *);
INT_PTR InfoBox(int,LPCWSTR,int,...);


// End of Dialogs.h
