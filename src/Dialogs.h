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

/**
 * App message used to center MessageBox to the window of the program.
 * https://stackoverflow.com/questions/6299797/c-how-to-center-messagebox
 */
#define APPM_CENTER_MESSAGE_BOX		(WM_APP + 1)

int  MsgBox(int,UINT,...);
void DisplayCmdLineHelp(HWND hwnd);
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
