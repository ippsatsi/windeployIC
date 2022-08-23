#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile_x64=windeployIC.exe
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_HiDpi=Y
#AutoIt3Wrapper_Run_AU3Check=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ProgressConstants.au3>
#include <String.au3>
#include <EditConstants.au3>
#include <Array.au3>
#include <ColorConstants.au3>
#include <ListViewConstants.au3>
#include <AutoItConstants.au3>

#include <windeployic_gui.au3>
#include <funciones_gui.au3>

;Opciones GUI
Opt("GUIResizeMode", $GUI_DOCKTOP  + $GUI_DOCKSIZE)

GUICtrlSetState($CrearImagen, @SW_SHOW)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Cerrar
			Exit
		Case $btFileDestino
			$RutaFile = SelectFileDialog("save", $inFileDestino, "Seleccione el archivo WIM", "wim")

	EndSwitch
WEnd