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

#include <funciones.au3>
#include <diskpart_funciones.au3>

#include <windeployic_gui_v2.au3>
#include <funciones_gui.au3>

;Opciones GUI
Opt("GUIResizeMode", $GUI_DOCKTOP  + $GUI_DOCKSIZE)

GUICtrlSetState($CrearImagen, @SW_SHOW)
RefrescarDiscos($lwListDisc)

While 1
	$nMsg = GUIGetMsg()
;~ 	Si no hay eventos o solo se esta moviendo el mouse, no entrara al Switch
	If $nMsg = $GUI_EVENT_NONE Or $nMsg = $GUI_EVENT_MOUSEMOVE Then ContinueLoop;
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Cerrar
			Exit
		Case $btFileDestino
			$RutaFile = SelectFileDialog("save", $inFileDestino, "Seleccione el archivo WIM", "wim")
		Case $btCrear
			If 	GUICtrlRead($inFileDestino) <> "" And _
				GUICtrlRead($inNombreImagen) <> "" And _
				GUICtrlRead($inDescripImagen) <> "" Then
				MsgBox(0, "prueba boton", "Crear imagen Disco Actual:" & $DiscoActual  )
				;obtener num de disco seleccionado
				;$ItemSelected = ControlListView($CrearImagen, "", $lwListDisc,"GetSelected")
				;encontrar particion principal
				;	seleccionar disco
				;	obtener particiones
				;encontrar particion recovery
				;sino encontramos algunas de las 2 particiones lanzar error y cancelar proceso
				; asignar letras a las 2 particiones
				; crear imagen de principal
				; si no hay imagen de recovery, crear imagen de recovery
;~ 				DismCapture(GUICtrlRead($inCapUnidadSrc), _
;~ 					GUICtrlRead($inFileDestino), _
;~ 					GUICtrlRead($inNombreImagen), _
;~ 					GUICtrlRead($inDescripImagen), _
;~ 					GUICtrlRead($cboCompresion), $outProceso, False)
			EndIf

	EndSwitch
	CambiarEstado()
WEnd