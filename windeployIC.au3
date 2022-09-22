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

Global $arParticionesSistema[3]

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
				;MsgBox(0, "prueba boton", "Crear imagen Disco Actual:" & $DiscoActual  )
				;obtener num de disco seleccionado
				;$ItemSelected = ControlListView($CrearImagen, "", $lwListDisc,"GetSelected")

				;seleccionar disco
				$Diskpart_pid = Diskpart_creacion_proceso()
				If SeleccionarDisco($Diskpart_pid, $DiscoActual) Then
					;verificamos q tenga particiones
					If Not dpf_ListarParticiones($Diskpart_pid) Then
						MsgBox($MB_SYSTEMMODAL, "Disco vacio", "El disco seleccionado no posee ninguna partición")
						ContinueCase
					EndIf
					_ArrayDisplay($arParticiones, "lista")
				EndIf
				;verificamos q existan las 3 particiones necesarias q usa el Windows
				If UBound($arParticiones) < 3 Then
					MsgBox(0, "Particiones", "El disco solo tiene " & UBound($arParticiones) & " particion(es)"  )
					ContinueCase
				EndIf
				$intPartActual = 0
				;Encontrar particion sistema
				If $arDisks[$DiscoActual][7] = "UEFI" Then
					;si es UEFI, puede q sea la 2 particion la q sea de sistema
					If Not IsPartitionType($intPartActual, $SYSTEM_PART_NUM) Then
						$intPartActual += 1
						If Not IsPartitionType($intPartActual, $SYSTEM_PART_NUM) Then
							ConsoleWrite("El disco no posee partición de sistema")
							ContinueCase
						EndIf
					EndIf
				EndIf
				$arParticionesSistema[0] = $arParticiones[$intPartActual][0]
				ConsoleWrite("arParSis: " & $arParticionesSistema[0] & @CRLF)
				$arSize = StringSplit($arParticiones[$intPartActual][2], " ", $STR_NOCOUNT)
				;Confirmamos q tenga particion de sistema
				If ($arSize[0] > 300 And $arSize[1] = "MB") Or $arSize[1] = "GB" Then
					ConsoleWrite("No tiene particion de sistema" & @CRLF)
					ContinueCase
				EndIf

				_ArrayDisplay($arSize, "size")

				;encontrar particion principal
				$intPartActual += 1
				If $arDisks[$DiscoActual][7] = "UEFI" Then
					$intPartActual += 1
				EndIf
				$arParticionesSistema[1] = $arParticiones[$intPartActual][0]
				If Not StringInStr($arParticiones[$intPartActual][1], $arTiposPartitions[1][0]) And Not StringInStr($arParticiones[$intPartActual][1], $arTiposPartitions[1][1]) Then
					MsgBox($MB_SYSTEMMODAL, "Partición Windows", "El disco no tiene partición con Windows")
					ContinueCase
				EndIf
				ConsoleWrite("arParPrincipal: " & $arParticionesSistema[1] & @CRLF)
				;Confirmamos q tenga particion de sistema
				_ArrayDisplay($arParticiones, "lista")
				;encontrar particion recovery

				;Buscamos la particion del tipo seleccionada
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

Func IsPartitionType($intNumPartition, $intTypePartition)
	If $arParticiones[$intNumPartition][1] <> $arTiposPartitions[$intTypePartition][0] And $arParticiones[$intNumPartition][1] <> $arTiposPartitions[$intTypePartition][1] Then
		Return False
	Else
		Return True
	EndIf
EndFunc

