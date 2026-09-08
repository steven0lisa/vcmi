; NSIS installer for the VCMI ready-to-play package (Windows x64).
;
; Build from the repo root after injecting bundled data into the staged zip:
;   makensis -DINPUT_DIR=/path/to/staged-package \
;            -DVERSION=1.8.0 packaging/ready-to-play/windows-installer.nsi
;
; INPUT_DIR must contain the full payload: VCMI_launcher.exe, VCMI_client.exe,
; DLLs, config/, Mods/ and (ready-to-play) Data/, Maps/, Mp3/.

Unicode True
!include "MUI2.nsh"

!define APPNAME "VCMI - Open Heroes 3 (Ready to Play)"
!define COMPANY "VCMI team"
!define UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\VCMI-ReadyToPlay"

!ifndef INPUT_DIR
  !error "Pass -DINPUT_DIR=<staged package dir>"
!endif
!ifndef VERSION
  !define VERSION "0.0.0"
!endif

Name "${APPNAME} ${VERSION}"
OutFile "VCMI-ReadyToPlay-Windows-x64.exe"
InstallDir "$PROGRAMFILES64\VCMI"
InstallDirRegKey HKLM "${UNINST_KEY}" "InstallLocation"
RequestExecutionLevel admin
SetCompressor /SOLID lzma

!define MUI_ABORTWARNING
!define MUI_FINISHPAGE_RUN "$INSTDIR\VCMI_client.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Launch VCMI"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "SimpChinese"

Section "Install"
  SetOutPath "$INSTDIR"
  File /r "${INPUT_DIR}\*.*"

  ; Start menu shortcuts (client = play, launcher = mods/settings)
  CreateDirectory "$SMPROGRAMS\VCMI"
  CreateShortCut "$SMPROGRAMS\VCMI\VCMI.lnk" "$INSTDIR\VCMI_client.exe"
  CreateShortCut "$SMPROGRAMS\VCMI\VCMI Launcher (mods).lnk" "$INSTDIR\VCMI_launcher.exe"
  CreateShortCut "$DESKTOP\VCMI.lnk" "$INSTDIR\VCMI_client.exe"

  ; Uninstaller + Add/Remove Programs entry
  WriteUninstaller "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "${UNINST_KEY}" "DisplayName" "${APPNAME}"
  WriteRegStr HKLM "${UNINST_KEY}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKLM "${UNINST_KEY}" "Publisher" "${COMPANY}"
  WriteRegStr HKLM "${UNINST_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "${UNINST_KEY}" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegDWORD HKLM "${UNINST_KEY}" "NoModify" 1
  WriteRegDWORD HKLM "${UNINST_KEY}" "NoRepair" 1
SectionEnd

Section "Uninstall"
  RMDir /r "$INSTDIR"
  RMDir /r "$SMPROGRAMS\VCMI"
  Delete "$DESKTOP\VCMI.lnk"
  DeleteRegKey HKLM "${UNINST_KEY}"
SectionEnd
