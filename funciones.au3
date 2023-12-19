#include <GuiEdit.au3>
#include <ScrollBarsConstants.au3>

Global $rutaWinre = "R:\Recovery\WindowsRE"
;20 puntos para preparacion de disco
;60 puntos para aplicacion de imagenes
;20 puntos para activacion de particiones

Func _CirculoResultado ($x, $y, $color)

	Local $Verde = 0x00ff00
	Local $Rojo = 0xff0000
	Local $circ_color = $Rojo
	If $color = "verde" Then
		$circ_color = $Verde
	EndIf
	Local $a=GuiCtrlCreateGraphic($x, $y, 10,10)
	GUICtrlSetGraphic(-1,$GUI_GR_COLOR, $circ_color,$circ_color)
	GUICtrlSetGraphic(-1,$GUI_GR_ELLIPSE,1,1,8,8)
	GuiCtrlSetState($a, $GUI_SHOW)
	Return $a
EndFunc


Func ReemplazarCaracteresEspanol($sSalida)
	;corregir carateres extraños
	$sSalida = StringReplace($sSalida, "S¡", "Si")
	$sSalida = StringReplace($sSalida, "¡", "í")
	$sSalida = StringReplace($sSalida, "£", "ú")
	$sSalida = StringReplace($sSalida, "¢", "ó")
	$sSalida = StringReplace($sSalida, "¤", "ñ")
	$sSalida = StringReplace($sSalida, "Ö", "Í")
	Return $sSalida
EndFunc

Func _ConvertirGBbinToGBdecimal($intSize, $Unidad)
	If StringInStr($Unidad, "GB") Then
		Return  String(Round(Number($intSize) * 1.075)) & " GB"   ;1024  * 1024 * 1024
	Else
		Return $intSize & " " & $Unidad
	EndIf
EndFunc

Func RefrescarDiscos($idListDiscos)
;~ 	GUICtrlSetState($btRefresh, $GUI_DISABLE)
;~ 	GUICtrlSetState($btInstalar, $GUI_DISABLE)
;~ 	ActualizandoStatus("Examinando Discos...")
	$Diskpart_pid = Diskpart_creacion_proceso()
	ListarDiscos($Diskpart_pid)
	ObtenerInfoDisco($Diskpart_pid, $idListDiscos)
	;GUICtrlSetState($btRefresh, $GUI_ENABLE)
	DiskpartCerrarProceso($Diskpart_pid)
;~ 	ActualizandoStatus("Listo")
	$Diskpart_pid = 0
;~ 	GUICtrlSetState($ctrlSelModoDisco, $GUI_DISABLE)
;~ 	GUICtrlSetState($btExtractWinRE, $GUI_DISABLE)
EndFunc

Func CambiarEstado()
	Local $ItemSelected
	$ItemSelected = ControlListView($CrearImagen, "", $lwListDisc,"GetSelected")
	If $ItemSelected = "" Then

		GUICtrlSetState($btCrear, $GUI_DISABLE)
		GUICtrlSetState($btAgregar, $GUI_DISABLE)
		GUICtrlSetState($ckboxAddDriver, $GUI_DISABLE)
		$DiscoActual = "N"
	Else


		GUICtrlSetState($btCrear, $GUI_ENABLE)
;~ 		Validamos el ckboxAddDriver para habilitar el boton solo cuando no este con check
		If Not _IsChecked($ckboxAddDriver) Then
			GUICtrlSetState($btAgregar, $GUI_ENABLE)
		Else
			GUICtrlSetState($btAgregar, $GUI_DISABLE)
		EndIf
		GUICtrlSetState($ckboxAddDriver, $GUI_ENABLE)
		$DiscoActual = $ItemSelected
	EndIf
 EndFunc


Func f_ProgresoTexto1($intValor, $intMOD)
	If $intValor > 100 Or $intValor < 0 Then Return "Error en lectura progreso"
	$strProgresoTexto = "   ["
	For $i = 0 To $intValor
		If Mod($i,$intMOD) = 0 Then $strProgresoTexto &= "="
	Next
	For $i = ($intValor + 1) To 100
		If Mod($i,$intMOD) = 0 Then $strProgresoTexto &= "  "
	Next
	$strProgresoTexto &= "]"
	;colocamos el porcentaje en el centro del texto
;~ 	$lenValor = Floor(StringLen($intValor)/2)
	If $intValor > 9 Then
		$lenValor = 2
	Else
		$lenValor = 1
	EndIf

	$lenProgresoString = Floor(StringLen($strProgresoTexto)/2)
	$posReemplazo = ($lenProgresoString - $lenValor) + 3
	;ConsoleWrite("++" & $lenProgresoString & ";;" & $posReemplazo & @CRLF)
	$strProgresoTexto = StringReplace($strProgresoTexto, $posReemplazo , $intValor & "%") ; desplazamos 3 posiciones por los espacios antes del "["
	Return $strProgresoTexto
EndFunc


Func f_KillIfProcessExists($process_name)
	While ProcessExists($process_name)
		ProcessClose($process_name)
	WEnd
EndFunc

Func f_ReemplazarParametro($comando, $parametro)
	if $parametro <> '' Then
		Return StringReplace($comando,"??param??", $parametro)
	Else
		Return $comando
	EndIf
EndFunc


Func f_CambiarAMinutos($segundos)
	Local $strUnidadTiempo
	If $segundos > 60 Then
		Return Int($segundos/60) & " min " & Mod($segundos,60) & " seg"
	Else
		Return $segundos & " seg"
	EndIf
EndFunc

Func f_UltNElemArray_to_Texto1($arSalida, $intIndice, $intN)
	Local $strTexto = ""
	If UBound($arSalida) < $intN Then Return "Error en array"
	For $i = ($intIndice - $intN) To $intIndice
		$strTexto &= $arSalida[$i] & @CRLF
	Next
	Return $strTexto
EndFunc


