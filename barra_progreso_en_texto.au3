Global $arProgressIndicator[] = ["|","/","-","\"]
Global $gi_AlmacenTextoMensajes = ""

Func MensajesProgreso($xBoxProgreso, $mensaje, $xlblEstado = 0)
	;$xBoxProgreso, es el id del control
	; $gi_AlmacenTextoMensajes es donde se acumula la salida de los comandos
	$gi_AlmacenTextoMensajes &= " " & $mensaje & @CRLF
	GUICtrlSetData($xBoxProgreso,$gi_AlmacenTextoMensajes)
	_GUICtrlEdit_Scroll($xBoxProgreso, $SB_SCROLLCARET)
	Return $mensaje
EndFunc

Func MensajesProgresoSinCRLF($xBoxProgreso, $mensaje, $xlblEstado = 0)
	;$xBoxProgreso, es el id del control
	; $gi_AlmacenTextoMensajes es donde se acumula la salida de los comandos
	$gi_AlmacenTextoMensajes &= $mensaje
	GUICtrlSetData($xBoxProgreso, $gi_AlmacenTextoMensajes)
	Return $mensaje
EndFunc

Func f_MensajesProgreso_MostrarProgresoTexto($xBoxProgreso, $mensaje)
	;$xBoxProgreso, es el id del control
	; $gi_AlmacenTextoMensajes es donde se acumula la salida de los comandos
	; Aca a diferencia de las funciones anteriores, mantenemos sin actualizar el $gi_AlmacenTextoMensajes, y solo actualizamos el
	; el $mensaje con la nueva data
	GUICtrlSetData($xBoxProgreso, $gi_AlmacenTextoMensajes & $mensaje)
	Return $mensaje
EndFunc

Func f_ProgresoTexto($intValor, $intMOD)
	; $intMOD determina cuan larga sera la barra de progreso
	If $intValor > 100 Or $intValor < 0 Then Return "Error en lectura progreso"
	$strProgresoTexto = "["
	For $i = 0 To $intValor
		If Mod($i,$intMOD) = 0 Then $strProgresoTexto &= "="
	Next
	For $i = ($intValor + 1) To 100
		If Mod($i,$intMOD) = 0 Then $strProgresoTexto &= "x" ; usamos X por mientras, despues lo reemplazamos por doble espacio en blanco
	Next
	$strProgresoTexto &= "]"
	; ================
	;colocamos el porcentaje en el centro del texto
	If $intValor > 9 Then
		$lenValor = 2
	Else
		$lenValor = 1
	EndIf
	; si usamos espacios en blanco desde un principio, los calculos no seran exactos
	$lenProgresoString = Floor(StringLen($strProgresoTexto)/2)
	$posReemplazo = $lenProgresoString - $lenValor
	;ConsoleWrite("++" & $lenProgresoString & ";;" & $posReemplazo & @CRLF)
	$strProgresoTexto = StringReplace($strProgresoTexto, $posReemplazo , $intValor & "%") ; desplazamos 3 posiciones por los espacios antes del "["
	; se usa doble espacio en blanco, para compensar q autoit hace q estos ocupen menos espacio en pantalla
	$strProgresoTexto = StringReplace($strProgresoTexto, "x" , "  ")
	;=======================
	Return "   " & $strProgresoTexto
EndFunc

Func LimpiarVentanaProgreso()
	$gi_AlmacenTextoMensajes = ""
	;$intBarraProgresoGUI = 0
	GUICtrlSetData($MensajesInstalacion, $gi_AlmacenTextoMensajes)
EndFunc

Func f_UltNElemArray_to_Texto($arSalida, $intIndice, $intN)
	Local $strTexto = ""
	If UBound($arSalida) < $intN Then Return "Error en array"
	For $i = ($intIndice - $intN) To $intIndice
		$strTexto &= $arSalida[$i] & @CRLF
	Next
	Return $strTexto
EndFunc

Func f_ExtraeResumenComando($mensaje_salida, $intPrimeros, $intUltimos)
	; $intPrimeros = indica cuantas filas del inicio vamos a usar
	; $intUltimos = indica cuantas filas del final vamos a usar
	Local $strResumenFinal = ""

	Local $arMensaje = StringSplit($mensaje_salida, @LF)
	Local $ultIndice = UBound($arMensaje) - 1
	For $i = 1 To $intPrimeros
		$strResumenFinal &= $arMensaje[$i] & @CRLF
	Next
	For $i = ($ultIndice - $intUltimos) To $ultIndice
		$strResumenFinal &= $arMensaje[$i] & @CRLF
	Next
	Return $strResumenFinal
EndFunc


Func f_MostrarProgresoTexto($Salida, $psTarea, $func_detect_cancelacion, $program_a_cancelar)
	; $Salida: Id del control donde se mostrara
	; $psTarea: handler del proceso q genera la salida
;~ 	$func_detect_cancelacion: nombre de la funcion q detecta la cancelacion
;~ 	$program_a_cancelar: nombre del proceso q se matara cuando se cancele el programa
	Local $strProgresoTexto = ""
	Local $value = 0
	Local $percent = 0
	Local $fDiff = 0
	Local $indexProgrIndic = 0
	Local $hTimer = TimerInit()
	While ProcessExists($psTarea)

		$fDiff = TimerDiff($hTimer)
		If $fDiff > 300 Then
			$hTimer = TimerInit()
			$indexProgrIndic += 1
			if UBound($arProgressIndicator) == $indexProgrIndic Then
				$indexProgrIndic = 0
			EndIf
		EndIf
		$line = StdoutRead($psTarea, True)
		If StringInStr($line, ".0%") Then
			;separamos a partir del .0%, para hallar el % de progreso
			$line1 = StringSplit($line, ".0%",$STR_ENTIRESPLIT)
			$value = StringRight($line1[$line1[0] - 1], 2) ; agarramos el ultimo % leido
		EndIf
		; Si llega a 00 es porque llego al 100% y finalizo correctamente
		If $value == "00" Then $value = 100

;~ 		=================================
		;aqui esta el codigo que detectara mientras se esta aplicando la imagen
		;si el usuario desea cancelarlo
		Local $n = 0
		;codigo para cancelacion
		While $n < 15 ;fijamos en 10 el numero de eventos a procesar de la cola
			;ConsoleWrite("while n:" & $n & @CRLF)
			If $func_detect_cancelacion() Then
				f_KillIfProcessExists($program_a_cancelar)
				MensajesProgreso($Salida,@CRLF & "Y   ---- Operacion Cancelada ----   " & @CRLF)
				Return False
			EndIf
			Sleep(1)
			$n = $n + 1
		WEnd
		;fin del codigo para cancelar la operacion
		Sleep(100)

;~ 		=================================

		If $percent <> $value Then
			$strProgresoTexto = f_ProgresoTexto($value, 3)
			f_MensajesProgreso_MostrarProgresoTexto($Salida, $arProgressIndicator[$indexProgrIndic] & @CRLF & $strProgresoTexto)
			$percent = $value
		EndIf

	WEnd
	Local $sSalida = StdoutRead($psTarea, True)
	$sSalida = ReemplazarCaracteresEspanol($sSalida)

	MensajesProgreso($Salida,@CRLF & $strProgresoTexto)
	MensajesProgreso($Salida, " ")
;==========================
	MensajesProgreso($Salida, "Proceso finalizado")
	MensajesProgreso($Salida, @CRLF & "===========Salida del comando===============" & @CRLF & f_ExtraeResumenComando($sSalida, 4, 3))
EndFunc