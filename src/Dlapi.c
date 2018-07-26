/******************************************************************************
*
*
* Notepad2
*
* Dlapi.c
*   Directory Listing APIs used in Notepad2
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
#if !defined(_WIN32_WINNT)
#define _WIN32_WINNT 0x501
#endif
#include <windows.h>
#include <commctrl.h>
#include <shlobj.h>
#include <shlwapi.h>
#include <string.h>
#include "dlapi.h"



//==== DirList ================================================================

//==== DLDATA Structure =======================================================

typedef struct tagDLDATA // dl
{

  HWND hwnd;                 // HWND of ListView Control
  UINT cbidl;                // Size of pidl
  LPITEMIDLIST  pidl;        // Directory Id
  LPSHELLFOLDER lpsf;        // IShellFolder Interface to pidl
  WCHAR szPath[MAX_PATH];     // Pathname to Directory Id
  int iDefIconFolder;        // Default Folder Icon
  int iDefIconFile;          // Default File Icon
  BOOL bNoFadeHidden;        // Flag passed from GetDispInfo()
  HANDLE hExitThread;        // Flag is set when Icon Thread should terminate
  HANDLE hTerminatedThread;  // Flag is set when Icon Thread has terminated

} DLDATA, *LPDLDATA;


//==== Property Name ==========================================================
static const WCHAR *pDirListProp = L"DirListData";



//=============================================================================
//
//  DirList_Init()
//
//  Initializes the DLDATA structure and sets up the listview control
//
BOOL DirList_Init(HWND hwnd,LPCWSTR pszHeader)
{

  HIMAGELIST hil;
  SHFILEINFO shfi;
  LV_COLUMN  lvc;

  // Allocate DirListData Property
  LPDLDATA lpdl = (LPDLDATA)GlobalAlloc(GPTR,sizeof(DLDATA));
  SetProp(hwnd,pDirListProp,(HANDLE)lpdl);

  // Setup dl
  lpdl->hwnd = hwnd;
  lpdl->cbidl = 0;
  lpdl->pidl = NULL;
  lpdl->lpsf = NULL;
  lstrcpy(lpdl->szPath,L"");

  // Add Imagelists
  hil = (HIMAGELIST)SHGetFileInfo(L"C:\\",0,&shfi,sizeof(SHFILEINFO),
                    SHGFI_SMALLICON | SHGFI_SYSICONINDEX);

  ListView_SetImageList(hwnd,hil,LVSIL_SMALL);

  hil = (HIMAGELIST)SHGetFileInfo(L"C:\\",0,&shfi,sizeof(SHFILEINFO),
                    SHGFI_LARGEICON | SHGFI_SYSICONINDEX);

  ListView_SetImageList(hwnd,hil,LVSIL_NORMAL);

  // Initialize default icons - done in DirList_Fill()
  //SHGetFileInfo(L"Icon",FILE_ATTRIBUTE_DIRECTORY,&shfi,sizeof(SHFILEINFO),
  //  SHGFI_USEFILEATTRIBUTES | SHGFI_SMALLICON | SHGFI_SYSICONINDEX);
  //lpdl->iDefIconFolder = shfi.iIcon;

  //SHGetFileInfo(L"Icon",FILE_ATTRIBUTE_NORMAL,&shfi,sizeof(SHFILEINFO),
  //  SHGFI_USEFILEATTRIBUTES | SHGFI_SMALLICON | SHGFI_SYSICONINDEX);
  //lpdl->iDefIconFile = shfi.iIcon;

  lpdl->iDefIconFolder = 0;
  lpdl->iDefIconFile = 0;

  // Icon thread control
  lpdl->hExitThread = CreateEvent(NULL,TRUE,FALSE,NULL);
  lpdl->hTerminatedThread = CreateEvent(NULL,TRUE,TRUE,NULL);

  lvc;
  pszHeader;

  return TRUE;

}


//=============================================================================
//
//  DirList_Destroy()
//
//  Free memory used by dl structure
//
BOOL DirList_Destroy(HWND hwnd)
{

  LPDLDATA lpdl = (LPDLDATA)GetProp(hwnd,pDirListProp);

  // Release multithreading objects
  DirList_TerminateIconThread(hwnd);
  CloseHandle(lpdl->hExitThread);
  CloseHandle(lpdl->hTerminatedThread);

  if (lpdl->pidl)
    CoTaskMemFree(lpdl->pidl);

  if (lpdl->lpsf)
    lpdl->lpsf->lpVtbl->Release(lpdl->lpsf);

  // Free DirListData Property
  RemoveProp(hwnd,pDirListProp);
  GlobalFree(lpdl);

  return FALSE;

}


//=============================================================================
//
//  DirList_StartIconThread()
//
//  Start thread to extract file icons in the background
//
BOOL DirList_StartIconThread(HWND hwnd)
{

  DWORD dwtid;
  LPDLDATA lpdl = (LPVOID)GetProp(hwnd,pDirListProp);

  DirList_TerminateIconThread(hwnd);

  ResetEvent(lpdl->hExitThread);
  //ResetEvent(lpdl->hTerminatedThread);

  CreateThread(NULL,0,DirList_IconThread,(LPVOID)lpdl,0,&dwtid);

  return TRUE;

}


//=============================================================================
//
//  DirList_TerminateIconThread()
//
//  Terminate Icon Thread and reset multithreading control structures
//
BOOL DirList_TerminateIconThread(HWND hwnd)
{

  LPDLDATA lpdl = (LPVOID)GetProp(hwnd,pDirListProp);

  SetEvent(lpdl->hExitThread);

  //WaitForSingleObject(lpdl->hTerminatedThread,INFINITE);
  while (WaitForSingleObject(lpdl->hTerminatedThread,0) != WAIT_OBJECT_0)
  {
    MSG msg;
    if (PeekMessage(&msg,NULL,0,0,PM_REMOVE)) {
      TranslateMessage(&msg);
      DispatchMessage(&msg);
    }
  }

  ResetEvent(lpdl->hExitThread);
  SetEvent(lpdl->hTerminatedThread);

  return TRUE;

}


//=============================================================================
//
//  DirList_Fill()
//
//  Snapshots a directory and displays the items in the listview control
//
int DirList_Fill(HWND hwnd,LPCWSTR lpszDir,DWORD grfFlags,LPCWSTR lpszFileSpec,
                 BOOL bExcludeFilter,BOOL bNoFadeHidden,
                 int iSortFlags,BOOL fSortRev)
{

  WCHAR wszDir[MAX_PATH];

  LPSHELLFOLDER lpsfDesktop = NULL;
  LPSHELLFOLDER lpsf = NULL;

  LPITEMIDLIST  pidl = NULL;
  LPITEMIDLIST  pidlEntry = NULL;

  LPENUMIDLIST  lpe = NULL;

  LV_ITEM       lvi;
  LPLV_ITEMDATA lplvid;

  ULONG chParsed = 0;
  ULONG dwAttributes = 0;

  DL_FILTER dlf;
  SHFILEINFO shfi;

  LPDLDATA lpdl = (LPVOID)GetProp(hwnd,pDirListProp);

  // Initialize default icons
  SHGetFileInfo(L"Icon",FILE_ATTRIBUTE_DIRECTORY,&shfi,sizeof(SHFILEINFO),
    SHGFI_USEFILEATTRIBUTES | SHGFI_SMALLICON | SHGFI_SYSICONINDEX);
  lpdl->iDefIconFolder = shfi.iIcon;

  SHGetFileInfo(L"Icon",FILE_ATTRIBUTE_NORMAL,&shfi,sizeof(SHFILEINFO),
    SHGFI_USEFILEATTRIBUTES | SHGFI_SMALLICON | SHGFI_SYSICONINDEX);
  lpdl->iDefIconFile = shfi.iIcon;

  // First of all terminate running icon thread
  DirList_TerminateIconThread(hwnd);

  // A Directory is strongly required
  if (!lpszDir || !*lpszDir)
    return(-1);

  lstrcpy(lpdl->szPath,lpszDir);

  // Init ListView
  SendMessage(hwnd,WM_SETREDRAW,0,0);
  ListView_DeleteAllItems(hwnd);

  // Init Filter
  DirList_CreateFilter(&dlf,lpszFileSpec,bExcludeFilter);

  // Init lvi
  lvi.mask = LVIF_TEXT | LVIF_IMAGE | LVIF_PARAM;
  lvi.iItem = 0;
  lvi.iSubItem = 0;
  lvi.pszText = LPSTR_TEXTCALLBACK;
  lvi.cchTextMax = MAX_PATH;
  lvi.iImage = I_IMAGECALLBACK;

  // Convert Directory to a UNICODE string
  /*MultiByteToWideChar(CP_ACP,
                      MB_PRECOMPOSED,
                      lpszDir,
                      -1,
                      wszDir,
                      MAX_PATH);*/
  lstrcpy(wszDir,lpszDir);


  // Get Desktop Folder
  if (NOERROR == SHGetDesktopFolder(&lpsfDesktop))
  {

    // Convert wszDir into a pidl
    if (NOERROR == lpsfDesktop->lpVtbl->ParseDisplayName(
                                          lpsfDesktop,
                                          hwnd,
                                          NULL,
                                          wszDir,
                                          &chParsed,
                                          &pidl,
                                          &dwAttributes))

    {

      // Bind pidl to IShellFolder
      if (NOERROR == lpsfDesktop->lpVtbl->BindToObject(
                                            lpsfDesktop,
                                            pidl,
                                            NULL,
                                            &IID_IShellFolder,
                                            (void**)&lpsf))

      {

        // Create an Enumeration object for lpsf
        if (NOERROR == lpsf->lpVtbl->EnumObjects(
                                        lpsf,
                                        hwnd,
                                        grfFlags,
                                        &lpe))

        {

          // Enumerate the contents of lpsf
          while (NOERROR == lpe->lpVtbl->Next(
                                            lpe,
                                            1,
                                            &pidlEntry,
                                            NULL))

          {

            // Add found item to the List
            // Check if it's part of the Filesystem
            dwAttributes = SFGAO_FILESYSTEM | SFGAO_FOLDER;

            lpsf->lpVtbl->GetAttributesOf(
                            lpsf,
                            1,
                            (ITEMIDLIST const **)&pidlEntry,
                            &dwAttributes);

            if (dwAttributes & SFGAO_FILESYSTEM)
            {

              // Check if item matches specified filter
              if (DirList_MatchFilter(lpsf,pidlEntry,&dlf))
              {

                lplvid = CoTaskMemAlloc(sizeof(LV_ITEMDATA));

                lplvid->pidl = pidlEntry;
                lplvid->lpsf = lpsf;

                lpsf->lpVtbl->AddRef(lpsf);

                lvi.lParam = (LPARAM)lplvid;

                // Setup default Icon - Folder or File
                lvi.iImage = (dwAttributes & SFGAO_FOLDER) ?
                  lpdl->iDefIconFolder : lpdl->iDefIconFile;

                ListView_InsertItem(hwnd,&lvi);

                lvi.iItem++;

              }

            }

          } // IEnumIDList::Next()

          lpe->lpVtbl->Release(lpe);

        } // IShellFolder::EnumObjects()

      } // IShellFolder::BindToObject()

    } // IShellFolder::ParseDisplayName()

    lpsfDesktop->lpVtbl->Release(lpsfDesktop);

  } // SHGetDesktopFolder()

  if (lpdl->pidl)
    CoTaskMemFree(lpdl->pidl);

  if (lpdl->lpsf && lpdl->lpsf->lpVtbl)
    lpdl->lpsf->lpVtbl->Release(lpdl->lpsf);

  // Set lpdl
  lpdl->cbidl = IL_GetSize(pidl);
  lpdl->pidl = pidl;
  lpdl->lpsf = lpsf;
  lpdl->bNoFadeHidden = bNoFadeHidden;

  // Set column width to fit window
  ListView_SetColumnWidth(hwnd,0,LVSCW_AUTOSIZE_USEHEADER);

  // Sort before display is updated
  DirList_Sort(hwnd,iSortFlags,fSortRev);

  // Redraw Listview
  SendMessage(hwnd,WM_SETREDRAW,1,0);

  // Return number of items in the control
  return (ListView_GetItemCount(hwnd));

}


//=============================================================================
//
//  DirList_IconThread()
//
//  Thread to extract file icons in the background
//
DWORD WINAPI DirList_IconThread(LPVOID lpParam)
{

  HWND hwnd;

  LPDLDATA lpdl;
  LV_ITEM lvi;
  LPLV_ITEMDATA lplvid;

  IShellIcon* lpshi;

  int iItem = 0;
  int iMaxItem;

  lpdl = (LPDLDATA)lpParam;
  ResetEvent(lpdl->hTerminatedThread);

  // Exit immediately if DirList_Fill() hasn't been called
  if (!lpdl->lpsf) {
    SetEvent(lpdl->hTerminatedThread);
    ExitThread(0);
    return(0);
  }

  hwnd = lpdl->hwnd;
  iMaxItem = ListView_GetItemCount(hwnd);

  CoInitialize(NULL);

  // Get IShellIcon
  lpdl->lpsf->lpVtbl->QueryInterface(lpdl->lpsf,&IID_IShellIcon,(void **)&lpshi);

  while (iItem < iMaxItem && WaitForSingleObject(lpdl->hExitThread,0) != WAIT_OBJECT_0) {

    lvi.iItem = iItem;
    lvi.mask  = LVIF_PARAM;
    if (ListView_GetItem(hwnd,&lvi)) {

      SHFILEINFO shfi;
      LPITEMIDLIST pidl;
      DWORD dwAttributes = SFGAO_LINK | SFGAO_SHARE;

      lplvid = (LPLV_ITEMDATA)lvi.lParam;

      lvi.mask = LVIF_IMAGE;

      if (!lpshi || NOERROR != lpshi->lpVtbl->GetIconOf(lpshi,lplvid->pidl,GIL_FORSHELL,&lvi.iImage))
      {
        pidl = IL_Create(lpdl->pidl,lpdl->cbidl,lplvid->pidl,0);
        SHGetFileInfo((LPCWSTR)pidl,0,&shfi,sizeof(SHFILEINFO),SHGFI_PIDL | SHGFI_SYSICONINDEX | SHGFI_SMALLICON);
        CoTaskMemFree(pidl);
        lvi.iImage = shfi.iIcon;
      }

      // It proved necessary to reset the state bits...
      lvi.stateMask = 0;
      lvi.state = 0;

      // Link and Share Overlay
      lplvid->lpsf->lpVtbl->GetAttributesOf(
                              lplvid->lpsf,
                              1,
                              (ITEMIDLIST const **)&lplvid->pidl,
                              &dwAttributes);

      if (dwAttributes & SFGAO_LINK)
      {
        lvi.mask |= LVIF_STATE;
        lvi.stateMask |= LVIS_OVERLAYMASK;
        lvi.state |= INDEXTOOVERLAYMASK(2);
      }

      if (dwAttributes & SFGAO_SHARE)
      {
        lvi.mask |= LVIF_STATE;
        lvi.stateMask |= LVIS_OVERLAYMASK;
        lvi.state |= INDEXTOOVERLAYMASK(1);
      }

      // Fade hidden/system files
      if (!lpdl->bNoFadeHidden)
      {
        WIN32_FIND_DATA fd;
        if (NOERROR == SHGetDataFromIDList(lplvid->lpsf,lplvid->pidl,
                        SHGDFIL_FINDDATA,&fd,sizeof(WIN32_FIND_DATA)))
        {
          if ((fd.dwFileAttributes & FILE_ATTRIBUTE_HIDDEN) ||
              (fd.dwFileAttributes & FILE_ATTRIBUTE_SYSTEM))
          {
            lvi.mask |= LVIF_STATE;
            lvi.stateMask |= LVIS_CUT;
            lvi.state |= LVIS_CUT;
          }
        }
      }
      lvi.iSubItem = 0;
      ListView_SetItem(hwnd,&lvi);
    }
    iItem++;
  }

  if (lpshi)
    lpshi->lpVtbl->Release(lpshi);

  CoUninitialize();

  SetEvent(lpdl->hTerminatedThread);
  ExitThread(0);
  return(0);

}


//=============================================================================
//
//  DirList_GetDispInfo()
//
//  Must be called in response to a WM_NOTIFY/LVN_GETDISPINFO message from
//  the listview control
//
BOOL DirList_GetDispInfo(HWND hwnd,LPARAM lParam,BOOL bNoFadeHidden)
{

  LV_DISPINFO *lpdi = (LPVOID)lParam;

  LPLV_ITEMDATA lplvid = (LPLV_ITEMDATA)lpdi->item.lParam;

  // SubItem 0 is handled only
  if (lpdi->item.iSubItem != 0)
    return FALSE;

  // Text
  if (lpdi->item.mask & LVIF_TEXT)
    IL_GetDisplayName(lplvid->lpsf,lplvid->pidl,SHGDN_INFOLDER,
                      lpdi->item.pszText,lpdi->item.cchTextMax);

  // Set values
  lpdi->item.mask |= LVIF_DI_SETITEM;

  return TRUE;

}


//=============================================================================
//
//  DirList_DeleteItem()
//
//  Must be called in response to a WM_NOTIFY/LVN_DELETEITEM message
//  from the control
//
BOOL DirList_DeleteItem(HWND hwnd,LPARAM lParam)
{

  LV_ITEM lvi;

  NM_LISTVIEW *lpnmlv = (LPVOID)lParam;

  lvi.iItem = lpnmlv->iItem;
  lvi.iSubItem = 0;
  lvi.mask = LVIF_PARAM;

  if (ListView_GetItem(hwnd,&lvi))
  {

    // Free mem
    LPLV_ITEMDATA lplvid = (LPLV_ITEMDATA)lvi.lParam;
    CoTaskMemFree(lplvid->pidl);
    lplvid->lpsf->lpVtbl->Release(lplvid->lpsf);

    CoTaskMemFree(lplvid);

    return TRUE;

  }

  else
    return FALSE;

}


//=============================================================================
//
//  DirList_CompareProc()
//
//  Compares two list items
//
int CALLBACK DirList_CompareProcFw(LPARAM lp1,LPARAM lp2,LPARAM lFlags)
{

  HRESULT hr;
  int result;

  LPLV_ITEMDATA lplvid1 = (LPLV_ITEMDATA)lp1;
  LPLV_ITEMDATA lplvid2 = (LPLV_ITEMDATA)lp2;

  hr = (lplvid1->lpsf->lpVtbl->CompareIDs(
                                 lplvid1->lpsf,
                                 lFlags,
                                 lplvid1->pidl,
                                 lplvid2->pidl));

  result = (short)(SCODE_CODE(GetScode(hr)));

  if (result != 0 || lFlags == 0)
    return(result);

  hr = (lplvid1->lpsf->lpVtbl->CompareIDs(
                                 lplvid1->lpsf,
                                 0,
                                 lplvid1->pidl,
                                 lplvid2->pidl));

  result = (short)(SCODE_CODE(GetScode(hr)));

  return(result);

}

int CALLBACK DirList_CompareProcRw(LPARAM lp1,LPARAM lp2,LPARAM lFlags)
{

  HRESULT hr;
  int result;

  LPLV_ITEMDATA lplvid1 = (LPLV_ITEMDATA)lp1;
  LPLV_ITEMDATA lplvid2 = (LPLV_ITEMDATA)lp2;

  hr = (lplvid1->lpsf->lpVtbl->CompareIDs(
                                 lplvid1->lpsf,
                                 lFlags,
                                 lplvid1->pidl,
                                 lplvid2->pidl));

  result = -(short)(SCODE_CODE(GetScode(hr)));

  if (result != 0)
    return(result);

  hr = (lplvid1->lpsf->lpVtbl->CompareIDs(
                                 lplvid1->lpsf,
                                 0,
                                 lplvid1->pidl,
                                 lplvid2->pidl));

  result = -(short)(SCODE_CODE(GetScode(hr)));

  return(result);

}


//=============================================================================
//
//  DirList_Sort()
//
//  Sorts the listview control by the specified order
//
BOOL DirList_Sort(HWND hwnd,int lFlags,BOOL fRev)
{

  if (fRev)
    return ListView_SortItems(hwnd,DirList_CompareProcRw,lFlags);

  else
    return ListView_SortItems(hwnd,DirList_CompareProcFw,lFlags);

}


//=============================================================================
//
//  DirList_GetItem()
//
//  Copies the data of the specified item in the listview control to a buffer
//
int DirList_GetItem(HWND hwnd,int iItem,LPDLITEM lpdli)
{

  LV_ITEM lvi;
  LPLV_ITEMDATA lplvid;

  ULONG dwAttributes = SFGAO_FILESYSTEM;


  if (iItem == -1)
  {

    if (ListView_GetSelectedCount(hwnd))

      iItem = ListView_GetNextItem(hwnd,-1,LVNI_ALL | LVNI_SELECTED);

    else

      return(-1);

  }

  lvi.mask = LVIF_PARAM;
  lvi.iItem = iItem;
  lvi.iSubItem = 0;

  if (!ListView_GetItem(hwnd,&lvi))
  {

    if (lpdli->mask & DLI_TYPE)

      lpdli->ntype = DLE_NONE;

    return(-1);

  }

  lplvid = (LPLV_ITEMDATA)lvi.lParam;

  // Filename
  if (lpdli->mask & DLI_FILENAME)

    IL_GetDisplayName(lplvid->lpsf,lplvid->pidl,SHGDN_FORPARSING,
                      lpdli->szFileName,MAX_PATH);

  // Displayname
  if (lpdli->mask & DLI_DISPNAME)

    IL_GetDisplayName(lplvid->lpsf,lplvid->pidl,SHGDN_INFOLDER,
                      lpdli->szDisplayName,MAX_PATH);

  // Type (File / Directory)
  if (lpdli->mask & DLI_TYPE)
  {

    WIN32_FIND_DATA fd;

    if (NOERROR == SHGetDataFromIDList(lplvid->lpsf,
                                       lplvid->pidl,
                                       SHGDFIL_FINDDATA,
                                       &fd,
                                       sizeof(WIN32_FIND_DATA)))

    lpdli->ntype = (fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) ?
                    DLE_DIR : DLE_FILE;

    /*lplvid->lpsf->lpVtbl->GetAttributesOf(
                            lplvid->lpsf,
                            1,
                            &lplvid->pidl,
                            &dwAttributes);

    lpdli->ntype = (dwAttributes & SFGAO_FOLDER) ? DLE_DIR : DLE_FILE;*/

  }

  return iItem;

}


//=============================================================================
//
//  DirList_GetItemEx()
//
//  Retrieves extended infomration on a dirlist item
//
int DirList_GetItemEx(HWND hwnd,int iItem,LPWIN32_FIND_DATA pfd)
{

  LV_ITEM lvi;
  LPLV_ITEMDATA lplvid;


  if (iItem == -1)
  {

    if (ListView_GetSelectedCount(hwnd))

      iItem = ListView_GetNextItem(hwnd,-1,LVNI_ALL | LVNI_SELECTED);

    else

      return(-1);

  }

  lvi.mask = LVIF_PARAM;
  lvi.iItem = iItem;
  lvi.iSubItem = 0;

  if (!ListView_GetItem(hwnd,&lvi))
    return(-1);

  lplvid = (LPLV_ITEMDATA)lvi.lParam;

  if (NOERROR == SHGetDataFromIDList(lplvid->lpsf,
                                     lplvid->pidl,
                                     SHGDFIL_FINDDATA,
                                     pfd,
                                     sizeof(WIN32_FIND_DATA)))
    return iItem;

  else
    return(-1);

}


//=============================================================================
//
//  DirList_PropertyDlg()
//
//  Shows standard Win95 Property Dlg for selected Item
//
BOOL DirList_PropertyDlg(HWND hwnd,int iItem)
{

  LV_ITEM lvi;
  LPLV_ITEMDATA lplvid;
  LPCONTEXTMENU lpcm;
  CMINVOKECOMMANDINFO cmi;
  BOOL bSuccess = TRUE;

  static const char *lpVerb = "properties";

  if (iItem == -1)
  {
    if (ListView_GetSelectedCount(hwnd))
      iItem = ListView_GetNextItem(hwnd,-1,LVNI_ALL | LVNI_SELECTED);

    else
      return FALSE;
  }

  lvi.mask = LVIF_PARAM;
  lvi.iItem = iItem;
  lvi.iSubItem = 0;

  if (!ListView_GetItem(hwnd,&lvi))
    return FALSE;

  lplvid = (LPLV_ITEMDATA)lvi.lParam;

  if (NOERROR == lplvid->lpsf->lpVtbl->GetUIObjectOf(
                                         lplvid->lpsf,
                                         GetParent(hwnd),  // Owner
                                         1,                // Number of objects
                                         (ITEMIDLIST const **)&lplvid->pidl,    // pidl
                                         &IID_IContextMenu,
                                         NULL,
                                         (void **)&lpcm))
  {

    cmi.cbSize = sizeof(CMINVOKECOMMANDINFO);
    cmi.fMask = 0;
    cmi.hwnd = GetParent(hwnd);
    cmi.lpVerb = lpVerb;
    cmi.lpParameters = NULL;
    cmi.lpDirectory = NULL;
    cmi.nShow = SW_SHOWNORMAL;
    cmi.dwHotKey = 0;
    cmi.hIcon = NULL;

    if (NOERROR != lpcm->lpVtbl->InvokeCommand(lpcm,&cmi))
      bSuccess = FALSE;

    lpcm->lpVtbl->Release(lpcm);

  }

  else
    bSuccess = FALSE;

  return(bSuccess);

}



//=============================================================================
//
//  DirList_GetLongPathName()
//
//  Get long pathname for currently displayed directory
//
BOOL DirList_GetLongPathName(HWND hwnd,LPWSTR lpszLongPath)
{
  WCHAR tch[MAX_PATH];
  LPDLDATA lpdl = (LPVOID)GetProp(hwnd,pDirListProp);
  if (SHGetPathFromIDList(lpdl->pidl,tch))
  {
    lstrcpy(lpszLongPath,tch);
    return(TRUE);
  }
  else
    return(FALSE);
}



//=============================================================================
//
//  DirList_SelectItem()
//
//  Select specified item in the list
//
BOOL DirList_SelectItem(HWND hwnd,LPCWSTR lpszDisplayName,LPCWSTR lpszFullPath)
{

  #define LVIS_FLAGS LVIS_SELECTED|LVIS_FOCUSED

  WCHAR szShortPath[MAX_PATH];
  SHFILEINFO  shfi;

  LV_FINDINFO lvfi;
  DLITEM dli;

  int i = -1;

  if (!lpszFullPath || !lstrlen(lpszFullPath))
    return(FALSE);
  else
    GetShortPathName(lpszFullPath,szShortPath,MAX_PATH);

  if (!lpszDisplayName || !lstrlen(lpszDisplayName))
    SHGetFileInfo(lpszFullPath,0,&shfi,sizeof(SHFILEINFO),SHGFI_DISPLAYNAME);
  else
    lstrcpyn(shfi.szDisplayName,lpszDisplayName,MAX_PATH);

  lvfi.flags = LVFI_STRING;
  lvfi.psz   = shfi.szDisplayName;

  dli.mask = DLI_ALL;

  while ((i = ListView_FindItem(hwnd,i,&lvfi)) != -1)
  {

    DirList_GetItem(hwnd,i,&dli);
    GetShortPathName(dli.szFileName,dli.szFileName,MAX_PATH);

    if (!lstrcmpi(dli.szFileName,szShortPath))
    {
      ListView_SetItemState(hwnd,i,LVIS_FLAGS,LVIS_FLAGS);
      ListView_EnsureVisible(hwnd,i,FALSE);

      return(TRUE);
    }

  }

  return(FALSE);

}



//=============================================================================
//
//  DirList_CreateFilter()
//
//  Create a valid DL_FILTER structure
//
void DirList_CreateFilter(PDL_FILTER pdlf,LPCWSTR lpszFileSpec,
                          BOOL bExcludeFilter)
{

  WCHAR *p;

  ZeroMemory(pdlf,sizeof(DL_FILTER));
  lstrcpyn(pdlf->tFilterBuf,lpszFileSpec,(DL_FILTER_BUFSIZE-1));
  pdlf->bExcludeFilter = bExcludeFilter;

  if (!lstrcmp(lpszFileSpec,L"*.*") || !lstrlen(lpszFileSpec))
    return;

  pdlf->nCount = 1;
  pdlf->pFilter[0] = &pdlf->tFilterBuf[0];    // Zeile zum Ausprobieren

  while (p = StrChr(pdlf->pFilter[pdlf->nCount-1],L';'))
  {
    *p = L'\0';                              // Replace L';' by L'\0'
    pdlf->pFilter[pdlf->nCount] = (p + 1);  // Next position after L';'
    pdlf->nCount++;                         // Increase number of filters
  }

}



//=============================================================================
//
//  DirList_MatchFilter()
//
//  Check if a specified item matches a given filter
//
BOOL DirList_MatchFilter(LPSHELLFOLDER lpsf,LPCITEMIDLIST pidl,PDL_FILTER pdlf)
{

  int i;
  WIN32_FIND_DATA fd;
  BOOL bMatchSpec;

  // Immediately return true if lpszFileSpec is *.* or NULL
  if (pdlf->nCount == 0 && !pdlf->bExcludeFilter)
    return TRUE;

  SHGetDataFromIDList(lpsf,pidl,SHGDFIL_FINDDATA,&fd,sizeof(WIN32_FIND_DATA));

  // All the directories are added
  if (fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
    return(TRUE);

  // Check if exclude *.* after directories have been added
  if (pdlf->nCount == 0 && pdlf->bExcludeFilter)
    return FALSE;

  for (i = 0; i < pdlf->nCount; i++)
  {
    if (*pdlf->pFilter[i]) // Filters like L"\0" are ignored
    {
      bMatchSpec = PathMatchSpec(fd.cFileName,pdlf->pFilter[i]);
      if (bMatchSpec)
      {
        if (!pdlf->bExcludeFilter)
          return(TRUE);
        else
          return(FALSE);
      }
    }
  }

  // No matching
  return(pdlf->bExcludeFilter)?TRUE:FALSE;

}



//==== DriveBox ===============================================================

//=============================================================================
//
//  Internal Itemdata Structure
//
typedef struct tagDC_ITEMDATA
{

  LPITEMIDLIST  pidl;
  LPSHELLFOLDER lpsf;

} DC_ITEMDATA, *LPDC_ITEMDATA;


//=============================================================================
//
//  DriveBox_Init()
//
//  Initializes the drive box
//
BOOL DriveBox_Init(HWND hwnd)
{

  HIMAGELIST hil;
  SHFILEINFO shfi;

  hil = (HIMAGELIST)SHGetFileInfo(L"C:\\",0,&shfi,sizeof(SHFILEINFO),
                                  SHGFI_SMALLICON | SHGFI_SYSICONINDEX);
  SendMessage(hwnd,CBEM_SETIMAGELIST,0,(LPARAM)hil);
  SendMessage(hwnd,CBEM_SETEXTENDEDSTYLE,CBES_EX_NOSIZELIMIT,CBES_EX_NOSIZELIMIT);

  return TRUE;

}


//=============================================================================
//
//  DriveBox_Fill
//

int DriveBox_Fill(HWND hwnd)
{

  LPSHELLFOLDER lpsfDesktop;
  LPSHELLFOLDER lpsf; // Workspace == CSIDL_DRIVES

  LPITEMIDLIST  pidl;
  LPITEMIDLIST  pidlEntry;

  LPENUMIDLIST  lpe;

  COMBOBOXEXITEM  cbei;
  LPDC_ITEMDATA   lpdcid;

  ULONG dwAttributes = 0;

  DWORD grfFlags = SHCONTF_FOLDERS;


  // Init ComboBox
  SendMessage(hwnd,WM_SETREDRAW,0,0);
  SendMessage(hwnd,CB_RESETCONTENT,0,0);

  ZeroMemory(&cbei,sizeof(COMBOBOXEXITEM));
  cbei.mask = CBEIF_TEXT | CBEIF_IMAGE | CBEIF_SELECTEDIMAGE | CBEIF_LPARAM;
  cbei.pszText = LPSTR_TEXTCALLBACK;
  cbei.cchTextMax = MAX_PATH;
  cbei.iImage = I_IMAGECALLBACK;
  cbei.iSelectedImage = I_IMAGECALLBACK;


  // Get pidl to [My Computer]
  if (NOERROR == SHGetSpecialFolderLocation(hwnd,
                                            CSIDL_DRIVES,
                                            &pidl))
  {

    // Get Desktop Folder
    if (NOERROR == SHGetDesktopFolder(&lpsfDesktop))
    {

      // Bind pidl to IShellFolder
      if (NOERROR == lpsfDesktop->lpVtbl->BindToObject(
                                            lpsfDesktop,
                                            pidl,
                                            NULL,
                                            &IID_IShellFolder,
                                            (void **)&lpsf))

      {

        // Create an Enumeration object for lpsf
        if (NOERROR == lpsf->lpVtbl->EnumObjects(
                                        lpsf,
                                        hwnd,
                                        grfFlags,
                                        &lpe))

        {

          // Enumerate the contents of [My Computer]
          while (NOERROR == lpe->lpVtbl->Next(
                                            lpe,
                                            1,
                                            &pidlEntry,
                                            NULL))

          {

            // Add item to the List if it is part of the
            // Filesystem
            dwAttributes = SFGAO_FILESYSTEM;

            lpsf->lpVtbl->GetAttributesOf(
                            lpsf,
                            1,
                            (ITEMIDLIST const **)&pidlEntry,
                            &dwAttributes);

            if (dwAttributes & SFGAO_FILESYSTEM)
            {

              // Windows XP: check if pidlEntry is a drive
              SHDESCRIPTIONID di;
              HRESULT hr;
              hr = SHGetDataFromIDList(lpsf,pidlEntry,SHGDFIL_DESCRIPTIONID,
                                        &di,sizeof(SHDESCRIPTIONID));
              if (hr != NOERROR || (di.dwDescriptionId >= SHDID_COMPUTER_DRIVE35 &&
                                    di.dwDescriptionId <= SHDID_COMPUTER_OTHER))
              {

                lpdcid = CoTaskMemAlloc(sizeof(DC_ITEMDATA));

                //lpdcid->pidl = IL_Copy(pidlEntry);
                lpdcid->pidl = pidlEntry;
                lpdcid->lpsf = lpsf;

                lpsf->lpVtbl->AddRef(lpsf);

                // Insert sorted ...
                {
                  COMBOBOXEXITEM cbei2;
                  LPDC_ITEMDATA lpdcid2;
                  HRESULT hr;
                  cbei2.mask = CBEIF_LPARAM;
                  cbei2.iItem = 0;

                  while ((SendMessage(hwnd,CBEM_GETITEM,0,(LPARAM)&cbei2)))
                  {
                    lpdcid2 = (LPDC_ITEMDATA)cbei2.lParam;
                    hr = (lpdcid->lpsf->lpVtbl->CompareIDs(
                                lpdcid->lpsf,
                                0,
                                lpdcid->pidl,
                                lpdcid2->pidl));

                    if ((short)(SCODE_CODE(GetScode(hr))) < 0)
                      break;
                    else
                      cbei2.iItem++;
                  }

                  cbei.iItem = cbei2.iItem;
                  cbei.lParam = (LPARAM)lpdcid;
                  SendMessage(hwnd,CBEM_INSERTITEM,0,(LPARAM)&cbei);

                }

              }

            }

          } // IEnumIDList::Next()

          lpe->lpVtbl->Release(lpe);

        } // IShellFolder::EnumObjects()

        lpsf->lpVtbl->Release(lpsf);

      } // IShellFolder::BindToObject()

      CoTaskMemFree(pidl);

    } // SHGetSpecialFolderLocation()

    lpsfDesktop->lpVtbl->Release(lpsfDesktop);

  } // SHGetDesktopFolder()


  SendMessage(hwnd,WM_SETREDRAW,1,0);
  // Return number of items added to combo box
  return ((int)SendMessage(hwnd,CB_GETCOUNT,0,0));

}


//=============================================================================
//
//  DriveBox_GetSelDrive
//
BOOL DriveBox_GetSelDrive(HWND hwnd,LPWSTR lpszDrive,int nDrive,BOOL fNoSlash)
{

  COMBOBOXEXITEM cbei;
  LPDC_ITEMDATA lpdcid;
  int i = (int)SendMessage(hwnd,CB_GETCURSEL,0,0);

  // CB_ERR means no Selection
  if (i == CB_ERR)
    return FALSE;

  // Get DC_ITEMDATA* of selected Item
  cbei.mask = CBEIF_LPARAM;
  cbei.iItem = i;
  SendMessage(hwnd,CBEM_GETITEM,0,(LPARAM)&cbei);
  lpdcid = (LPDC_ITEMDATA)cbei.lParam;

  // Get File System Path for Drive
  IL_GetDisplayName(lpdcid->lpsf,lpdcid->pidl,SHGDN_FORPARSING,lpszDrive,nDrive);

  // Remove Backslash if required (makes Drive relative!!!)
  if (fNoSlash)
    PathRemoveBackslash(lpszDrive);

  return TRUE;

}


//=============================================================================
//
//  DriveBox_SelectDrive
//
BOOL DriveBox_SelectDrive(HWND hwnd,LPCWSTR lpszPath)
{

  COMBOBOXEXITEM cbei;
  LPDC_ITEMDATA lpdcid;
  WCHAR szRoot[64];

  int i;
  int cbItems = (int)SendMessage(hwnd,CB_GETCOUNT,0,0);

  // No Drives in Combo Box
  if (!cbItems)
    return FALSE;

  cbei.mask = CBEIF_LPARAM;

  for (i = 0; i < cbItems; i++)
  {
    // Get DC_ITEMDATA* of Item i
    cbei.iItem = i;
    SendMessage(hwnd,CBEM_GETITEM,0,(LPARAM)&cbei);
    lpdcid = (LPDC_ITEMDATA)cbei.lParam;

    // Get File System Path for Drive
    IL_GetDisplayName(lpdcid->lpsf,lpdcid->pidl,SHGDN_FORPARSING,szRoot,64);

    // Compare Root Directory with Path
    if (PathIsSameRoot(lpszPath,szRoot))
    {
      // Select matching Drive
      SendMessage(hwnd,CB_SETCURSEL,i,0);
      return TRUE;
    }
  }

  // Don't select anything
  SendMessage(hwnd,CB_SETCURSEL,(WPARAM)-1,0);
  return FALSE;

}


//=============================================================================
//
//  DriveBox_PropertyDlg()
//
//  Shows standard Win95 Property Dlg for selected Drive
//
BOOL DriveBox_PropertyDlg(HWND hwnd)
{

  COMBOBOXEXITEM cbei;
  LPDC_ITEMDATA lpdcid;
  int iItem;
  LPCONTEXTMENU lpcm;
  CMINVOKECOMMANDINFO cmi;
  BOOL bSuccess = TRUE;

  static const char *lpVerb = "properties";

  iItem = (int)SendMessage(hwnd,CB_GETCURSEL,0,0);

  if (iItem == CB_ERR)
    return FALSE;

  cbei.mask = CBEIF_LPARAM;
  cbei.iItem = iItem;
  SendMessage(hwnd,CBEM_GETITEM,0,(LPARAM)&cbei);
  lpdcid = (LPDC_ITEMDATA)cbei.lParam;

  if (NOERROR == lpdcid->lpsf->lpVtbl->GetUIObjectOf(
                                         lpdcid->lpsf,
                                         GetParent(hwnd),  // Owner
                                         1,                // Number of objects
                                         (ITEMIDLIST const **)&lpdcid->pidl,    // pidl
                                         &IID_IContextMenu,
                                         NULL,
                                         (void **)&lpcm))
  {

    cmi.cbSize = sizeof(CMINVOKECOMMANDINFO);
    cmi.fMask = 0;
    cmi.hwnd = GetParent(hwnd);
    cmi.lpVerb = lpVerb;
    cmi.lpParameters = NULL;
    cmi.lpDirectory = NULL;
    cmi.nShow = SW_SHOWNORMAL;
    cmi.dwHotKey = 0;
    cmi.hIcon = NULL;

    if (NOERROR != lpcm->lpVtbl->InvokeCommand(lpcm,&cmi))
      bSuccess = FALSE;

    lpcm->lpVtbl->Release(lpcm);

  }

  else
    bSuccess = FALSE;

  return(bSuccess);

}


//=============================================================================
//
//  DriveBox_DeleteItem
//
LRESULT DriveBox_DeleteItem(HWND hwnd,LPARAM lParam)
{

  NMCOMBOBOXEX *lpnmcbe;
  COMBOBOXEXITEM cbei;
  LPDC_ITEMDATA lpdcid;

  lpnmcbe = (LPVOID)lParam;
  cbei.iItem = lpnmcbe->ceItem.iItem;

  cbei.mask = CBEIF_LPARAM;
  SendMessage(hwnd,CBEM_GETITEM,0,(LPARAM)&cbei);
  lpdcid = (LPDC_ITEMDATA)cbei.lParam;

  // Free pidl
  CoTaskMemFree(lpdcid->pidl);
  // Release lpsf
  lpdcid->lpsf->lpVtbl->Release(lpdcid->lpsf);

  // Free lpdcid itself
  CoTaskMemFree(lpdcid);

  return TRUE;

}


//=============================================================================
//
//  DriveBox_GetDispInfo
//
LRESULT DriveBox_GetDispInfo(HWND hwnd,LPARAM lParam)
{

  NMCOMBOBOXEX *lpnmcbe;
  LPDC_ITEMDATA lpdcid;
  SHFILEINFO shfi;
  WCHAR szTemp[256];

  lpnmcbe = (LPVOID)lParam;
  lpdcid = (LPDC_ITEMDATA)lpnmcbe->ceItem.lParam;

  if (!lpdcid)
    return FALSE;

  // Get Display Name
  if (lpnmcbe->ceItem.mask & CBEIF_TEXT)
    IL_GetDisplayName(lpdcid->lpsf,lpdcid->pidl,SHGDN_NORMAL,lpnmcbe->ceItem.pszText,lpnmcbe->ceItem.cchTextMax);

  // Get Icon Index
  if (lpnmcbe->ceItem.mask & (CBEIF_IMAGE | CBEIF_SELECTEDIMAGE))
  {
    IL_GetDisplayName(lpdcid->lpsf,lpdcid->pidl,SHGDN_FORPARSING,szTemp,256);
    SHGetFileInfo(szTemp,0,&shfi,sizeof(SHFILEINFO),SHGFI_SYSICONINDEX | SHGFI_SMALLICON);
    lpnmcbe->ceItem.iImage = shfi.iIcon;
    lpnmcbe->ceItem.iSelectedImage = shfi.iIcon;
  }

  // Set values
  lpnmcbe->ceItem.mask |= CBEIF_DI_SETITEM;

  return TRUE;

}



//==== ItemID =================================================================

//=============================================================================
//
//  IL_Create()
//
// Creates an ITEMIDLIST by concatenating pidl1 and pidl2
// cb1 and cb2 indicate the sizes of the pidls, where cb1
// can be zero and pidl1 can be NULL
//
// If cb2 is zero, the size of pidl2 is retrieved using
// IL_GetSize(pidl2)
//
LPITEMIDLIST IL_Create(LPCITEMIDLIST pidl1,UINT cb1,
                       LPCITEMIDLIST pidl2,UINT cb2)
{

  LPITEMIDLIST pidl;

  if (!pidl2)
    return NULL;

  if (!cb2)
    cb2 = IL_GetSize(pidl2) + 2; // Space for terminating Bytes

  if (!cb1)
    cb1 = IL_GetSize(pidl1);

  // Allocate Memory
  pidl = CoTaskMemAlloc(cb1 + cb2);

  // Init new ITEMIDLIST
  if (pidl1)
    CopyMemory(pidl,pidl1,cb1);

  // pidl2 can't be NULL here
  CopyMemory((LPBYTE)pidl + cb1,pidl2,cb2);

  return pidl;

}


//=============================================================================
//
// IL_GetSize()
//
// Retrieves the number of bytes in a pidl
// Does not add space for zero terminators !!
//
UINT IL_GetSize(LPCITEMIDLIST pidl)
{

  LPITEMIDLIST pidlTmp;
  UINT cb = 0;

  if (!pidl)
    return 0;

  for (pidlTmp = (LPITEMIDLIST)pidl;
       pidlTmp->mkid.cb;
       pidlTmp = _IL_Next(pidlTmp))

    cb += pidlTmp->mkid.cb;


  return cb;

}


//=============================================================================
//
// IL_GetDisplayName()
//
// Gets the Display Name of a pidl. lpsf is the parent IShellFolder Interface
// dwFlags specify a SHGDN_xx value
//
BOOL IL_GetDisplayName(LPSHELLFOLDER lpsf,
                       LPCITEMIDLIST pidl,
                       DWORD dwFlags,
                       LPWSTR lpszDisplayName,
                       int nDisplayName)
{

  STRRET str;

  if (NOERROR == lpsf->lpVtbl->GetDisplayNameOf(lpsf,
                                                pidl,
                                                dwFlags,
                                                &str))
  {

    // Shlwapi.dll provides new function:
    return StrRetToBuf(&str,pidl,lpszDisplayName,nDisplayName);
    // ...but I suppose my version is faster ;-)
    /*switch (str.uType)
    {

      case STRRET_WSTR:
        WideCharToMultiByte(CP_ACP,
                            0,
                            str.pOleStr,
                            -1,
                            lpszDisplayName,
                            nDisplayName,
                            NULL,
                            NULL);
        CoTaskMemFree(str.pOleStr);
        break;

      case STRRET_OFFSET:
        lstrcpyn(lpszDisplayName,
                 ((WCHAR *)(pidl)) + str.uOffset,
                 nDisplayName);
        break;

      case STRRET_CSTR:
        lstrcpyn(lpszDisplayName,str.cStr,nDisplayName);
        break;

    }

    return TRUE;*/
  }

  return FALSE;
}



///   End of Dlapi.c   ///
