;Include gui files
#include <GuiConstantsEx.au3>
#include <MsgBoxConstants.au3>

;Create the gui
$hMainGUI = GUICreate("DisplayChanger", 250, 180)

;Create refresh rate buttons
$24hzButton = GUICtrlCreateButton("24hz", 10, 10, 50, 30)
$60hzButton = GUICtrlCreateButton("60hz", 70, 10, 50, 30)
$120hzButton = GUICtrlCreateButton("120hz", 130, 10, 50, 30)
$144hzButton = GUICtrlCreateButton("144hz", 190, 10, 50, 30)

;Create resolution buttons
$720pButton = GUICtrlCreateButton("720p", 10, 50, 50, 30)
$1080pButton = GUICtrlCreateButton("1080p", 70, 50, 50, 30)

;Create color space buttons
$YCBCRButton = GUICtrlCreateButton("YCbCr", 10, 90, 50, 30)
$RGBButton = GUICtrlCreateButton("RGB", 70, 90, 50, 30)

;Create 3D buttons
$3DOnButton = GUICtrlCreateButton("3D On", 10, 130, 50, 30)
$3DOffButton = GUICtrlCreateButton("3D Off", 70, 130, 50, 30)

;Show the GUI
GUISetState(@SW_SHOW, $hMainGUI)


;Main GUI Control Loop
While 1
	$hMsg = GUIGetMsg()
	Switch $hMsg
		Case $GUI_EVENT_CLOSE
			Exit

		Case $24hzButton
			ChangeScreenRes("", "", "", 24)

		Case $60hzButton
			ChangeScreenRes("", "", "", 60)

		Case $120hzButton
			ChangeScreenRes("", "", "", 120)

		Case $144hzButton
			ChangeScreenRes("", "", "", 144)

		Case $720pButton
			ChangeScreenRes(1280, 720, "", "")

		Case $1080pButton
			ChangeScreenRes(1920, 1080, "", "")

		Case $YCBCRButton
			ChangeColorSpace("y")

		Case $RGBButton
			ChangeColorSpace("r")

		Case $3DOnButton
			ShellExecute("C:\Program Files (x86)\NVIDIA Corporation\3D Vision\nvstlink.exe", "/enable")

		Case $3DOffButton
			ShellExecute("C:\Program Files (x86)\NVIDIA Corporation\3D Vision\nvstlink.exe", "/disable")

	EndSwitch

WEnd

Func ChangeScreenRes($i_Width = @DesktopWidth, $i_Height = @DesktopHeight, $i_BitsPP = @DesktopDepth, $i_RefreshRate = @DesktopRefresh)
	Local Const $DM_PELSWIDTH = 0x00080000
	Local Const $DM_PELSHEIGHT = 0x00100000
	Local Const $DM_BITSPERPEL = 0x00040000
	Local Const $DM_DISPLAYFREQUENCY = 0x00400000
	Local Const $CDS_TEST = 0x00000002
	Local Const $CDS_UPDATEREGISTRY = 0x00000001
	Local Const $DISP_CHANGE_RESTART = 1
	Local Const $DISP_CHANGE_SUCCESSFUL = 0
	Local Const $HWND_BROADCAST = 0xffff
	Local Const $WM_DISPLAYCHANGE = 0x007E
	If $i_Width = "" Or $i_Width = -1 Then $i_Width = @DesktopWidth ; default to current setting
	If $i_Height = "" Or $i_Height = -1 Then $i_Height = @DesktopHeight ; default to current setting
	If $i_BitsPP = "" Or $i_BitsPP = -1 Then $i_BitsPP = @DesktopDepth ; default to current setting
	If $i_RefreshRate = "" Or $i_RefreshRate = -1 Then $i_RefreshRate = @DesktopRefresh ; default to current setting
	Local $DEVMODE = DllStructCreate("byte[32];int[10];byte[32];int[6]")
	Local $B = DllCall("user32.dll", "int", "EnumDisplaySettings", "ptr", 0, "long", 0, "ptr", DllStructGetPtr($DEVMODE))
	If @error Then
		$B = 0
		SetError(1)
		Return $B
	Else
		$B = $B[0]
	EndIf
	If $B <> 0 Then
		DllStructSetData($DEVMODE, 2, BitOR($DM_PELSWIDTH, $DM_PELSHEIGHT, $DM_BITSPERPEL, $DM_DISPLAYFREQUENCY), 5)
		DllStructSetData($DEVMODE, 4, $i_Width, 2)
		DllStructSetData($DEVMODE, 4, $i_Height, 3)
		DllStructSetData($DEVMODE, 4, $i_BitsPP, 1)
		DllStructSetData($DEVMODE, 4, $i_RefreshRate, 5)
		$B = DllCall("user32.dll", "int", "ChangeDisplaySettings", "ptr", DllStructGetPtr($DEVMODE), "int", $CDS_TEST)
		If @error Then
			$B = -1
		Else
			$B = $B[0]
		EndIf
		Select
			Case $B = $DISP_CHANGE_RESTART
				$DEVMODE = ""
				Return 2
			Case $B = $DISP_CHANGE_SUCCESSFUL
				DllCall("user32.dll", "int", "ChangeDisplaySettings", "ptr", DllStructGetPtr($DEVMODE), "int", $CDS_UPDATEREGISTRY)
				DllCall("user32.dll", "int", "SendMessage", "hwnd", $HWND_BROADCAST, "int", $WM_DISPLAYCHANGE, _
						"int", $i_BitsPP, "int", $i_Height * 2 ^ 16 + $i_Width)
				$DEVMODE = ""
				Return 1
			Case Else
				$DEVMODE = ""
				SetError(1)
				Return $B
		EndSelect
	EndIf
EndFunc   ;==>ChangeScreenRes



Func ChangeColorSpace($cColorSpaceChar)
	AutoItSetOption("MouseCoordMode", 0)
	Run('C:\Program Files\NVIDIA Corporation\Control Panel Client\nvcplui.exe')
	WinWaitActive("NVIDIA Control Panel", "")
	Sleep(2500)
	MouseClick("left", 122, 217, 1)
	MouseClick("left", 453, 724, 1)
	; MouseClick("left", 455, 819, 1)
	Send($cColorSpaceChar & "{enter}")
	Sleep(250)
	Send("!a")
	;Sleep 3000
	WinClose("NVIDIA Control Panel", "")
EndFunc   ;==>ChangeColorSpace