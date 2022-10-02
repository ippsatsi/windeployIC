#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile_x64=windeployIC.exe
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=Creador de imagenes para windeploy
#AutoIt3Wrapper_Res_Fileversion=1.0.0.2
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_ProductName=windeploy_ic
#AutoIt3Wrapper_Res_ProductVersion=1.0.5
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

#include <windeployic_gui.au3>
#include <funciones_gui.au3>
#include <dism_funciones.au3>

;Opciones GUI
Opt("GUIResizeMode", $GUI_DOCKTOP  + $GUI_DOCKSIZE)

GUICtrlSetState($CrearImagen, @SW_SHOW)
RefrescarDiscos($lwListDisc)

Global $arParticionesSistema[3][2], $estadoCancelar = False

While 1
	$nMsg = GUIGetMsg()
;~ 	Si no hay eventos o solo se esta moviendo el mouse, no entrara al Switch
	If $nMsg = $GUI_EVENT_NONE Or $nMsg = $GUI_EVENT_MOUSEMOVE Then ContinueLoop;
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit

		Case $Cerrar
			If GUICtrlRead($Cerrar) = "Cancelar" Then
				$estadoCancelar = True
			Else
				Exit
			EndIf

		Case $btFileDestino
			$RutaFile = SelectFileDialog("save", $inFileDestino, "Seleccione el archivo WIM", "wim")
		Case $btCrear
			If 	GUICtrlRead($inFileDestino) <> "" And _
				GUICtrlRead($inNombreImagen) <> "" And _
				GUICtrlRead($inDescripImagen) <> "" Then

				;limpiamos el control de los mensajes
				GUICtrlSetData($outProceso, "")
				DetectarParticiones(False)
			EndIf
		Case $btAgregar
			If 	GUICtrlRead($inFileDestino) <> "" And _
				GUICtrlRead($inNombreImagen) <> "" And _
				GUICtrlRead($inDescripImagen) <> "" Then

				If Not FileExists(GUICtrlRead($inFileDestino)) Then
					MsgBox(0, "Archivo Destino", "El archivo destino no existe, si va agregar imagenes, el archivo destino debe existir"  )
					ContinueCase
				EndIf

				;limpiamos el control de los mensajes
				GUICtrlSetData($outProceso, "")
				DetectarParticiones(True)
			EndIf
	EndSwitch
	;obtener num de disco seleccionado
	;con la funcion cambiarEstado() obtenemos el disco seleccionado y lo
	;guardamos en $DiscoActual
	CambiarEstado()
WEnd

Func IsPartitionType($intNumPartition, $intTypePartition)
	If $arParticiones[$intNumPartition][1] <> $arTiposPartitions[$intTypePartition][0] And $arParticiones[$intNumPartition][1] <> $arTiposPartitions[$intTypePartition][1] Then
		Return False
	Else
		Return True
	EndIf
EndFunc

Func DetectarParticiones($Append)

	;extraemos la ruta al folder donde ubicamos el archivo WIM
	$RutaFileDestino = GUICtrlRead($inFileDestino)
	$intUltimoBackslash = StringInStr($RutaFileDestino, "\",0,-1)
	$strLocationFolderDestino = StringMid($RutaFileDestino, 1, $intUltimoBackslash)
	GUICtrlSetData($outProceso, "Iniciando procedimientos, espere ...." & @CRLF)
	;seleccionar disco
	$Diskpart_pid = Diskpart_creacion_proceso()
	If SeleccionarDisco($Diskpart_pid, $DiscoActual) Then
		;verificamos q tenga particiones
		If Not dpf_ListarParticiones($Diskpart_pid) Then
			MsgBox($MB_SYSTEMMODAL, "Disco vacio", "El disco seleccionado no posee ninguna partición")
			Return False
		EndIf
		;_ArrayDisplay($arParticiones, "lista")
	EndIf
	;verificamos q existan las 3 particiones necesarias q usa el Windows
	ConsoleWrite("particiones necesarias: " & UBound($arParticiones) & @CRLF)
	If UBound($arParticiones) < 3 Then
		MsgBox(0, "Particiones", "El disco solo tiene " & UBound($arParticiones) & " particion(es)"  )
		Return False
	EndIf
	$intPartActual = 0

	;Encontrar particion sistema
	If $arDisks[$DiscoActual][7] = "UEFI" Then
		;si es UEFI, puede q sea la 2 particion la q sea de sistema
		If Not IsPartitionType($intPartActual, $SYSTEM_PART_NUM) Then
			$intPartActual += 1
			If Not IsPartitionType($intPartActual, $SYSTEM_PART_NUM) Then
				ConsoleWrite("El disco no posee partición de sistema")
				Return False
			EndIf
		EndIf
	EndIf

	$arParticionesSistema[0][0] = $arParticiones[$intPartActual][0]
	ConsoleWrite("arParSis: " & $arParticionesSistema[0][0] & @CRLF)
	$arSize = StringSplit($arParticiones[$intPartActual][2], " ", $STR_NOCOUNT)
	;Confirmamos q tenga particion de sistema
	If ($arSize[0] > 300 And $arSize[1] = "MB") Or $arSize[1] = "GB" Then
		ConsoleWrite("No tiene particion de sistema" & @CRLF)
		Return False
	EndIf
	;_ArrayDisplay($arSize, "size")

	;encontrar particion principal
	$intPartActual += 1
	If $arDisks[$DiscoActual][7] = "UEFI" Then
		$intPartActual += 1
	EndIf
	$arParticionesSistema[1][0] = $arParticiones[$intPartActual][0]
	If Not IsPartitionType($intPartActual, $PRINCIPAL_PART_NUM) Then
		MsgBox($MB_SYSTEMMODAL, "Partición Windows", "El disco no tiene partición con Windows")
	EndIf
	ConsoleWrite("arParPrincipal: " & $arParticionesSistema[1][0] & @CRLF)

	;encontrar particion recovery
	$arParticionesSistema[2][0] = 99 ; 99 es la bandera cuando no encontramos Recovery
	For $i = 0 to UBound($arParticiones)- 1
		If IsPartitionType($i, $RECOVERY_PART_NUM) Then
			$arParticionesSistema[2][0] = $arParticiones[$i][0]
		EndIf
	Next
	ConsoleWrite("Particion Recovery: " & $arParticionesSistema[2][0] & @CRLF)
	If $arParticionesSistema[2][0] = 99 Then
		MsgBox($MB_SYSTEMMODAL, "Partición Recovery", "El disco no tiene partición Recovery")
		Return False
	EndIf

	; asignar letras a las 2 particiones
	$Letra = dpf_AsignarLetra($Diskpart_pid, $arParticionesSistema[1][0])
	If $Letra = "." Then
		MsgBox($MB_SYSTEMMODAL, "Asignacion de Letras", "No se pudo asignar una letra a la particon principal")
		Return False
	EndIf
	$arParticionesSistema[1][1] = $Letra
	$Letra = dpf_AsignarLetra($Diskpart_pid, $arParticionesSistema[2][0])
	If $Letra = "." Then
		MsgBox($MB_SYSTEMMODAL, "Asignacion de Letras", "No se pudo asignar una letra a la particon Recovery")
		Return False
	EndIf
	$arParticionesSistema[2][1] = $Letra
;~ 	_ArrayDisplay($arParticionesSistema, "ParticionesBasica")
	; verificamos directorios
	If FileExists($arParticionesSistema[1][1] & ":\Windows") Then
		ConsoleWrite("Carpeta Windows Existe" & @CRLF)
	Else
		MsgBox($MB_SYSTEMMODAL, "Carpetas Sistema", "No se encontro la carpeta " & $arParticionesSistema[1][1] & ":\Windows")
		Return False
	EndIf
	If FileExists($arParticionesSistema[2][1] & ":\Recovery") Then
		ConsoleWrite("Carpeta Recovery Existe" & @CRLF)
	Else
		MsgBox($MB_SYSTEMMODAL, "Carpetas Sistema", "No se encontro la carpeta " & $arParticionesSistema[2][1] & ":\Recovery")
		Return False
	EndIf

	gi_CerrarToCancelar()
	; crear imagen de principal
	DismCapture($arParticionesSistema[1][1] & ":", _
			$RutaFileDestino, _
			GUICtrlRead($inNombreImagen), _
			GUICtrlRead($inDescripImagen), _
			GUICtrlRead($cboCompresion), $outProceso, $Append)
	; si no hay imagen de recovery, crear imagen de recovery
	If Not FileExists($strLocationFolderDestino & "Recovery.wim") Then
		DismCapture($arParticionesSistema[2][1] & ":", _
			$strLocationFolderDestino & "Recovery.wim", _
			"Recovery Image", _
			"Recovery Image File", _
			GUICtrlRead($cboCompresion), $outProceso, False)
	Else
		ConsoleWrite("Ya existe " & $strLocationFolderDestino & "Recovery.wim, no se creará imagen Recovery" & @CRLF)
		GUICtrlSetData($outProceso, GUICtrlRead($outProceso) & @CRLF & @CRLF & "Ya existe " & $strLocationFolderDestino & "Recovery.wim, no se creará imagen Recovery" & @CRLF)
	EndIf
	gi_CancelarToCerrar()
	Return True
EndFunc

