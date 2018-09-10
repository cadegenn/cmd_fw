#Build Switches
# /DVERSION=[Version]

# Switches:
# /INI [IniFile] Use settings from INI file
# /S Silent

# Exit codes:
# 0: OK
# 1: Cancel
# 2: Not administrator
# -1: Error

#
# Includes
#
!include FileFunc.nsh
!include LogicLib.nsh
!include x64.nsh
!insertmacro GetParameters
!insertmacro GetOptions

#
# defines
#
!define PRODUCT_CODENAME "cmd_fw"
!define GUID "${PRODUCT_CODENAME}"
!define PRODUCT_FULLNAME "Tiny %COMSPEC% Framework"
!define PRODUCT_NAME "CMD Fw"
!define PRODUCT_SHORTNAME "CMDFw"
!define PRODUCT_DESCRIPTION "A small ComSpec FrameWork"
!define PRODUCT_VERSION "${VERSION}"
!define PRODUCT_PUBLISHER "Charles-Antoine Degennes"
!define PRODUCT_WEB_SITE "https://github.com/cadegenn/${PRODUCT_CODENAME}"
!define PRODUCT_COPYRIGHT "GPL v3+"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${GUID}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define DEFAULT_INSTALL_DIR "$COMMONFILES64\${PRODUCT_CODENAME}\"

#
# General Attributes
#
Unicode true
CrcCheck off # CRC check generates random errors
Icon "..\images\${PRODUCT_CODENAME}.ico"
InstallDir "${DEFAULT_INSTALL_DIR}"
Name "${PRODUCT_NAME}"
OutFile "${PRODUCT_SHORTNAME}-${VERSION}.exe"
RequestExecutionLevel admin

VIAddVersionKey "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey "Comments" "${PRODUCT_DESCRIPTION}"
VIAddVersionKey "CompanyName" "${PRODUCT_PUBLISHER}"
VIAddVersionKey "LegalCopyright" "${PRODUCT_COPYRIGHT}"
VIAddVersionKey "FileDescription" "Installer"
VIAddVersionKey "FileVersion" "${VERSION}"
VIProductVersion "${VERSION}"
;VIProductVersion "1.0.0.0"

#
# Pages
#
Page license
Page directory
Page instfiles
UninstPage uninstConfirm
UninstPage instfiles

LicenseData "..\LICENSE"

#
# Functions
#
Function Usage
  push $0
  StrCpy $0 "Switches:$\r$\n"
  StrCpy $0 "$0/S - Install ${PRODUCT_SHORTNAME} silently with no user prompt.$\r$\n"
  StrCpy $0 "$0/D=c:\path\to\install\folder - Specify an alternate installation folder. Default install dir is '${DEFAULT_INSTALL_DIR}'.$\r$\n"
  MessageBox MB_OK $0
  pop $0
FunctionEnd

Function .onInit
  ${GetParameters} $R0
  ClearErrors
  ${GetOptions} $R0 "/?"    $R1
  ${IfNot} ${Errors}
    call Usage
    Abort
  ${EndIf}
  # use HKLM\Software and C:\Program Files, even on 64-bit computer
  # where Windows would normally redirect ourself to
  # HKLM\Software\wow6432Nodes and C:\Program Files (x86)
  ${If} ${RunningX64}
	DetailPrint "Running on a 64-bit Windows... setting RegView accordingly"
	SetRegView 64
  ${Else}
	DetailPrint "Running on a 32-bit Windows..."
  ${EndIf}
FunctionEnd

; this code do not work quite well
; some files are missing on next install
; Function UninstallPrevious
    ; ; Check for uninstaller.
    ; ReadRegStr $R0 HKLM ${PRODUCT_UNINST_KEY} "QuietUninstallString"
    ; ${If} $R0 == ""        
        ; Goto Done
    ; ${EndIf}
    ; DetailPrint "Removing previous installation."
    ; ; Run the uninstaller silently.
    ; ExecWait '$R0'
    ; Done:
; FunctionEnd

#
# Sections
#
; ; The "" makes the section hidden.
; Section "" SecUninstallPrevious
    ; Call UninstallPrevious
; SectionEnd

Section "Install"
	SetOutPath "$INSTDIR"
	
	; pack everything
	File /r "..\bin"
	File /r "..\cmd"
	File /r "..\lib"
	File "..\*.cmd"
	File "..\*.md"
	File "..\images\${PRODUCT_CODENAME}.ico"
	File "..\LICENSE"
	
	; write registry values
	; CMD_fw custom entries
	WriteRegStr HKLM "Software\${PRODUCT_CODENAME}" "InstallDir" $INSTDIR
	WriteRegStr HKLM "Software\${PRODUCT_CODENAME}" "version" ${VERSION}
	; add/remove programs
	DetailPrint "Registering uninstallation options in add/remove programs"
	WriteRegStr HKLM ${PRODUCT_UNINST_KEY} "DisplayName" "${PRODUCT_FULLNAME}"
	WriteRegStr HKLM ${PRODUCT_UNINST_KEY} "UninstallString" '"$INSTDIR\uninst.exe"'
	WriteRegStr HKLM ${PRODUCT_UNINST_KEY} "QuietUninstallString" '"$INSTDIR\uninst.exe" /S'
	WriteRegStr HKLM ${PRODUCT_UNINST_KEY} "InstallLocation" "$INSTDIR"
	WriteRegStr HKLM ${PRODUCT_UNINST_KEY} "DisplayIcon" "$INSTDIR\${PRODUCT_CODENAME}.ico"
	WriteRegStr HKLM ${PRODUCT_UNINST_KEY} "Publisher" "${PRODUCT_PUBLISHER}"
	WriteRegStr HKLM ${PRODUCT_UNINST_KEY} "URLInfoAbout" "${PRODUCT_WEB_SITE}"
	WriteRegStr HKLM ${PRODUCT_UNINST_KEY} "DisplayVersion" "${PRODUCT_VERSION}"
	WriteRegStr HKLM ${PRODUCT_UNINST_KEY} "NoModify" 1
	WriteRegStr HKLM ${PRODUCT_UNINST_KEY} "NoRepair" 1
	; from @url http://nsis.sourceforge.net/Add_uninstall_information_to_Add/Remove_Programs
	${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
	IntFmt $0 "0x%08X" $0
	WriteRegDWORD HKLM ${PRODUCT_UNINST_KEY} "EstimatedSize" "$0"

	; ; ; install NuGet ComSpec repository to ease further modules installation
	; ; DetailPrint "Installing NuGet package provider"
	; ; #!system 'ComSpec.exe -ExecutionPolicy bypass -Command "Install-PackageProvider -Name NuGet -Force"'
	; ; nsExec::ExecToLog 'ComSpec.exe -ExecutionPolicy bypass -Command "Install-PackageProvider -Name NuGet -Force"'
	; ; DetailPrint "Installing PsIni module"
	; ; nsExec::ExecToLog 'ComSpec.exe -ExecutionPolicy bypass -Command "Install-Module -Name PsIni -Confirm:$$false -Force"'
	; DetailPrint "Running post-install ComSpec script"
	; nsExec::ExecToLog '"$INSTDIR\post-install.cmd"'
	
	WriteUninstaller $INSTDIR\uninst.exe
SectionEnd

Section "Uninstall"
	Delete "$INSTDIR\uninst.exe"
	RMDIR /r "$INSTDIR"
	DeleteRegKey HKLM ${PRODUCT_UNINST_KEY}
	DeleteRegKey HKLM "Software\${PRODUCT_CODENAME}"
SectionEnd