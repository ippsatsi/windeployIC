### windeployIC  ###

;Opciones Diskpart
;array de discos
Global $arDisks
; array de particiones en el disco actual
Global $arParticiones
Global $Diskpart_pid = 0
Global $DiscoActual = "N"
Global $arTiposPartitions[3][3]
$arTiposPartitions[0][0] = "System"
$arTiposPartitions[0][1] = "Sistema"
$arTiposPartitions[0][2] = "S"
$arTiposPartitions[1][0] = "Principal"
$arTiposPartitions[1][1] = "Principal"
$arTiposPartitions[1][2] = "W"
$arTiposPartitions[2][0] = "Recovery"
$arTiposPartitions[2][1] = "Recuperación"
$arTiposPartitions[2][2] = "R"

;~ Global $bolEnProgresoEnPantalla = False
;~ Global $intEnProgresoIndex = 0
;~ Global $intNumDiskpartSleeps = 5
;~ Global $intIdleContador = 0


Func Diskpart_creacion_proceso()
	Local $sSalida
	$Diskpart_pid = Run("DiskPart.exe", "", @SW_HIDE, $STDIN_CHILD + $STDOUT_CHILD)
	While StringRight(StdoutRead($Diskpart_pid, True, False), 10) <> "DISKPART> "

		Sleep(100)
		If Not(ProcessExists($Diskpart_pid)) Then
			MsgBox($MB_SYSTEMMODAL, "", "No se pudo inicializar diakpart ")
			$Diskpart_pid = 0
		EndIf
	Wend
	If $Diskpart_pid <> 0 Then
		$sSalida = StdoutRead($Diskpart_pid)
;~ 		ConsoleWrite($sSalida)
	EndIf
	Return $Diskpart_pid
EndFunc

Func DiskpartCerrarProceso($Diskpart_pid)
	If $Diskpart_pid <> 0 Then
		StdinWrite($Diskpart_pid, "exit" & @CRLF)
		$Diskpart_pid = 0
	EndIf
EndFunc

Func Pausa_finalice_comando($Diskpart_pid)
	While StringRight(StdoutRead($Diskpart_pid, True, False), 10) <> "DISKPART> "
		Sleep(100)
	WEnd
EndFunc

Func LimpiarSalidaDiskpart($Diskpart_pid)
	Local $sSalidaLimpia, $sSalida
	$sSalida = StdoutRead($Diskpart_pid)
	;eliminamos el prompt al final de la salida
	$sSalida = ReemplazarCaracteresEspanol($sSalida)
	$sSalidaLimpia = StringReplace($sSalida,@CRLF & @CRLF & "DISKPART> ", "")
	;$sSalidaLimpia = StringReplace($sSalidaLimpia, @CRLF & @CRLF, "")
	Return $sSalidaLimpia
EndFunc

Func EjecutarComandoDiskpart($Diskpart_pid, $comando)
	If	$Diskpart_pid <> 0 Then
		StdinWrite($Diskpart_pid, $comando & @CRLF)
		Pausa_finalice_comando($Diskpart_pid)
		$sSalida = LimpiarSalidaDiskpart($Diskpart_pid)
		Return $sSalida
	Else
		ConsoleWrite("Error Ejecutando Diskpart")
		Return 1
	EndIf
EndFunc

Func EjecutarCompararComandoDiskpart($Diskpart_pid, $comando, $sSalidaAComparar)
	;cuando la funcion se ejecute correctamente, su salida sera False, sino seran los mensajes de error generados
	Local $sErrores
	If	$Diskpart_pid <> 0 Then
		StdinWrite($Diskpart_pid, $comando & @CRLF)
		Pausa_finalice_comando($Diskpart_pid)
		$sSalida = LimpiarSalidaDiskpart($Diskpart_pid)
		If StringInStr($sSalida, $sSalidaAComparar) Then
			Return False
		EndIf
		$sErrores = "Comando no tuvo la salida esperada" & @CRLF
		$sErrores = $sErrores & "salida incorrecta:" & $sSalida  & @CRLF
		Return $sErrores
	EndIf
	$sErrores = "Proceso Diskpart no disponible" & @CRLF
	Return $sErrores
EndFunc

Func ListarDiscos($Diskpart_pid)
	Local $sSalida
	$sSalida = EjecutarComandoDiskpart($Diskpart_pid, "list disk")
	ExtraerListaDiscos($sSalida)
 	;ConsoleWrite("_________")
	;ConsoleWrite($sSalida)
 	;ConsoleWrite("_________")
EndFunc

Func dpf_ListarParticiones($Diskpart_pid)
	Local $sSalida
	$sSalida = EjecutarComandoDiskpart($Diskpart_pid, "list part")
	If Not dpf_ExtraerListaParticiones($sSalida) Then Return False
	Return True
EndFunc

Func dpf_ExtraerListaParticiones($sSalida)
	Local $arFilas, $i, $sDato, $arSize
	$arFilas = $sSalida
	If	Not QuitarCabeceraTabla($arFilas) Then Return False
	Dim $arParticiones[UBound($arFilas)][6]
;~ 	_ArrayDisplay($arFilas)
	For $i = 0 to UBound($arFilas) - 1
		;# de Particion
		$sDato = StringMid($arFilas[$i], 12,2)
		$arParticiones[$i][0] = StringStripWS($sDato, 8)
		;Tipo Particion
		$sDato = StringMid($arFilas[$i], 17,15)
		$arParticiones[$i][1] = StringStripWS($sDato, 8)
		; Tamaño de particion
		$sDato = StringMid($arFilas[$i], 35,8)
		$arSize = StringSplit(StringStripWS($sDato,7)," ",2)
		$arParticiones[$i][2] = _ConvertirGBbinToGBdecimal($arSize[0], $arSize[1])
		$arParticiones[$i][3] = $arSize[1] ;Unidad
		;Desplazamiento
		$sDato = StringMid($arFilas[$i], 45,7)
		$arSize = StringSplit(StringStripWS($sDato,7)," ",2)
		$arParticiones[$i][4] = _ConvertirGBbinToGBdecimal($arSize[0], $arSize[1])
		$arParticiones[$i][5] = $arSize[1] ;Unidad
	 Next
	 ;_ArrayDisplay($arParticiones, "Lista Filas")
	Return True

EndFunc


Func QuitarCabeceraTabla(ByRef $sSalida)
	;dividimos en lineas o filas
	$sSalida = StringSplit($sSalida, @LF, $STR_NOCOUNT)
	;eliminamos las 3 primeras filas, q son parte de la cabecera de la tabla
	If UBound($sSalida) > 0 Then
		_ArrayDelete($sSalida, 0)
		_ArrayDelete($sSalida, 0)
		_ArrayDelete($sSalida, 0)
		Return True
	Else
		Return False
	EndIf
EndFunc

Func ExtraerListaDiscos($sSalida)
	Local $arFilas, $i, $arSize

	$arFilas = $sSalida
	QuitarCabeceraTabla($arFilas)
	;_ArrayDisplay( $arFilas, "Lista Filas")
	Dim $arDisks[UBound($arFilas)][17]

	For $i = 0 to UBound($arFilas) - 1
		;# de disco
		$sDato = StringMid($arFilas[$i], 9,1)
		$arDisks[$i][0] = $sDato
		;Status  - si esta en linea
		$sDato = StringMid($arFilas[$i], 14,9)
		$arDisks[$i][1] = $sDato
		; Tamaño de disco
		$sDato = StringMid($arFilas[$i], 28,8)
		$arSize = StringSplit(StringStripWS($sDato,7)," ",2)
		;_ArrayDisplay( $arSize, "Lista Filas")
		$arDisks[$i][2] = _ConvertirGBbinToGBdecimal($arSize[0], $arSize[1])
		$arDisks[$i][3] = $arSize[1] ;Unidad
		;Espacio disponible
		$sDato = StringMid($arFilas[$i], 38,7)
		$arSize = StringSplit(StringStripWS($sDato,7)," ",2)
		$arDisks[$i][4] = _ConvertirGBbinToGBdecimal($arSize[0], $arSize[1])
		$arDisks[$i][5] = $arSize[1] ;Unidad
		; Si es dinamico
		$sDato = StringMid($arFilas[$i], 48,1)
		$arDisks[$i][6] = $sDato
		; Si es mbr o uefi o vacio
		$sDato = StringMid($arFilas[$i], 53,1)
		$arDisks[$i][7] = $sDato
	Next
;~ 	_ArrayDisplay( $arDisks, "Lista Filas")
	Return $arFilas
EndFunc

Func SeleccionarDisco($Diskpart_pid, $intNumDisco)
	Local $sSalida, $OK

	$sSalida = EjecutarComandoDiskpart($Diskpart_pid, "sel disk " & $intNumDisco)
	If StringInStr($sSalida, "El disco " & $intNumDisco & " es ahora el disco seleccionado") > 0 Then
 		;ConsoleWrite($sSalida & "??????")
		Return True
	Else
		Return False
	EndIf
EndFunc

Func dpf_SeleccionarParticion($Diskpart_pid, $intNumParticion)
	Local $sSalida, $OK

	$sSalida = EjecutarComandoDiskpart($Diskpart_pid, "sel part " & $intNumParticion)
;~ 	La partición 2 es ahora la partición seleccionada.
	If StringInStr($sSalida, "La partición " & $intNumParticion & " es ahora la partición seleccionada") > 0 Then
;~ 		ConsoleWrite($sSalida & "??????")
		Return True
	Else
		Return False
	EndIf
EndFunc

Func ExtraerValorParametro($ParamValor)
	Local $arParametro
	$arParametro = StringSplit(StringStripWS($ParamValor,7), ":",2)
	;una vez extraido, le limpiamos los espacios
	Return StringStripWS($arParametro[1],3)
EndFunc

Func ExtraerDetalleDisco($sSalida, $idArrarDisks)
	; lo dividimos en lineas
	;ConsoleWrite($sSalida)
	$sSalida = StringSplit($sSalida, @LF, $STR_NOCOUNT)
	$arDisks[$idArrarDisks][8] = $sSalida[1] ; Modelo
	$arDisks[$idArrarDisks][9] = ExtraerValorParametro($sSalida[2]) ;Id de disco
	If $arDisks[$idArrarDisks][9] = "00000000" Then
		$arDisks[$idArrarDisks][7] = "vacio"
	ElseIf $arDisks[$idArrarDisks][7] = "*" Then
		$arDisks[$idArrarDisks][7] = "UEFI"
	Else
		$arDisks[$idArrarDisks][7] = "MBR"
	EndIf

	$arDisks[$idArrarDisks][10] = ExtraerValorParametro($sSalida[3]) ;Tipo de conexion
EndFunc

Func RellenarCtrlList($idListDiscos)
	GUICtrlSendMsg($idListDiscos, $LVM_DELETEALLITEMS, 0, 0)	; Limpiamos el ctrl Lista
	If $Diskpart_pid <> 0 Then
		For $idLista = 0 To UBound($arDisks) - 1
			GUICtrlCreateListViewItem($arDisks[$idLista][0] & "|" & $arDisks[$idLista][8] & "|" & _
				$arDisks[$idLista][7] & "|" & $arDisks[$idLista][2] & "|" & $arDisks[$idLista][4] & "|" & _
				$arDisks[$idLista][10] & "|" & $arDisks[$idLista][1], $idListDiscos)
		Next
	Else
		GUICtrlCreateListViewItem("x|Error en|comando|diskpart|x|x" , $idListDiscos)
	EndIf
EndFunc

Func ObtenerInfoDisco($Diskpart_pid, $idListDiscos)
	Local $intNumDisco, $sSalida

	For $idArray = 0 To UBound($arDisks) - 1
		; Seleccionamos disco
		$intNumDisco = $arDisks[$idArray][0]
		If StringIsDigit($intNumDisco) = 1 Then
			If SeleccionarDisco($Diskpart_pid, $intNumDisco) Then
				$sSalida = EjecutarComandoDiskpart($Diskpart_pid, "detail disk")
				ExtraerDetalleDisco($sSalida, $idArray)
;~ 				ConsoleWrite($sSalida)
			Else
				ConsoleWrite("Error en la seleccion de disco")
				$Diskpart_pid = 0
				Return
			EndIf
		Else
			ConsoleWrite("Error en el numero de disco" & $intNumDisco)
			$Diskpart_pid = 0
			Return
		EndIf
	Next
	RellenarCtrlList($idListDiscos)
	;_ArrayDisplay( $arDisks, "Lista Filas")
EndFunc

Func TareaComandosDiskpart($arrayComando)
	Local $intPrcentajeTarea = 20
	Local $sSalida, $OK,  $arComando, $sSalidaComandos = '', $comando, $salida_correcta, $otro_comando, $nombreTarea
	If $DiscoActual = "N" Then
		ActualizandoStatus("Error de seleccion - No ha seleccionado un disco")
		Return
	EndIf
	f_KillIfProcessExists("Diskpart.exe")
	$Diskpart_pid = Diskpart_creacion_proceso()
	If SeleccionarDisco($Diskpart_pid, $DiscoActual) Then
		FormProgreso_EnableCancelar()
		Local $floatRatioProgreso = $intPrcentajeTarea/UBound($arrayComando)
		For $i = 0 To UBound($arrayComando) - 1
			$comando = $arrayComando[$i][0]
			$salida_correcta = $arrayComando[$i][1]
			$nombreTarea = "    " & $arrayComando[$i][2]
			$otro_comando = $arrayComando[$i][3]
			If $otro_comando Then
				Execute($otro_comando)
			Else
				MensajesProgreso($MensajesInstalacion, $nombreTarea)
				$sSalida = EjecutarCompararComandoDiskpart($Diskpart_pid, $comando, $salida_correcta)
				$sSalidaComandos = "tarea " & $i & ":" & $nombreTarea & " - " & $sSalida & @CRLF
				If $sSalida Then Return $sSalidaComandos
			EndIf
			$intBarraProgresoGUI += $floatRatioProgreso
			gi_MostrarAvanceBarraProgresoGUI($InstProgreso, $intBarraProgresoGUI)
			;Hablitamos sondeo del batan cancelar entre cada tarea
			;hacemos un barrido de los eventos q se van encolando
			;se encolan muchos eventos, ya q al mover el mouse se van generando eventos
			$n = 0
			While $n < 15 ;fijamos en 10 el numero de eventos a procesar de la cola
				If FormProgreso_SondearCancelacionCierre() Then
					DiskpartCerrarProceso($Diskpart_pid)
					FormProgreso_DisableCancelar()
					ActualizandoStatus("Operacion Cancelada")
					Return "  ----- Operacion Cancelada ----- "
				EndIf
				Sleep(1)
				$n = $n + 1
			WEnd
		Next
		FormProgreso_DisableCancelar()
		DiskpartCerrarProceso($Diskpart_pid)
		Return False
	EndIf
	DiskpartCerrarProceso($Diskpart_pid)
EndFunc

Func dpf_AsignarLetraToPartition($intPartitionTypeNumber)
	;Asignamos Letra a la particion segun su tipo
	f_KillIfProcessExists("Diskpart.exe")
	$Diskpart_pid = Diskpart_creacion_proceso()
	If SeleccionarDisco($Diskpart_pid, $DiscoActual) Then
		Local $intNumParticion = dpf_BuscarParticion($Diskpart_pid, $intPartitionTypeNumber)
		If $intNumParticion <> "N" Then
			If Not dpf_SeleccionarParticion($Diskpart_pid, $intNumParticion) Then
				MensajesProgreso($MensajesInstalacion, "No se pudo seleccionar la particion " & $intNumParticion & " del tipo " & $arTiposPartitions[$intPartitionTypeNumber][0])
				Return False
			EndIf
			MensajesProgreso($MensajesInstalacion, "Se selecciono la particion " & $arTiposPartitions[$intPartitionTypeNumber][1])
			$sSalida = EjecutarCompararComandoDiskpart($Diskpart_pid, "assign letter=" & $arTiposPartitions[$intPartitionTypeNumber][2], "DiskPart asignó correctamente una letra de unidad o punto de montaje")
			If $sSalida Then
				MensajesProgreso($MensajesInstalacion, "No se pudo asignar la letra " & $arTiposPartitions[$intPartitionTypeNumber][2] & " a la partición" )
				MensajesProgreso($MensajesInstalacion, "La tarea produjo esta salida:" & @CRLF & $sSalida)
				Return False
			EndIf
			MensajesProgreso($MensajesInstalacion, "Se asigno la letra " & $arTiposPartitions[$intPartitionTypeNumber][2])
			Return True
		EndIf
	EndIf
	Return False
EndFunc

Func dpf_BuscarParticion($Diskpart_pid, $intIndexTipoPartition)
	;Buscamos y obtenemos el numero de la particion segun su tipo
	Local $intNumPartRecovery = "N"
	If Not dpf_ListarParticiones($Diskpart_pid) Then
		dpf_MensajeExtraccionWinRE("El disco seleeccionado no posee ninguna partición")
		Return False
	EndIf
	;Buscamos la particion del tipo seleccionada
	For $i = 0 To UBound($arParticiones) - 1
		If StringInStr($arParticiones[$i][1], $arTiposPartitions[$intIndexTipoPartition][0]) Or StringInStr($arParticiones[$i][1], $arTiposPartitions[$intIndexTipoPartition][1]) Then
			$intNumPartRecovery = $arParticiones[$i][0]
			ExitLoop
		EndIf
	Next
	If $intNumPartRecovery = "N" Then
		dpf_MensajeExtraccionWinRE("No se encontro particion del tipo " & $arTiposPartitions[$intIndexTipoPartition][0])
	EndIf
	Return $intNumPartRecovery
EndFunc

Func dpf_ObtenerParticiones()
   	f_KillIfProcessExists("Diskpart.exe")
	$Diskpart_pid = Diskpart_creacion_proceso()
	If SeleccionarDisco($Diskpart_pid, $DiscoActual) Then
	   MsgBox($MB_SYSTEMMODAL, "Disco vacio", "zz")
	   If Not dpf_ListarParticiones($Diskpart_pid) Then
		  MsgBox($MB_SYSTEMMODAL, "Disco vacio", "El disco seleccionado no tiene particiones")
		  Return False
	   EndIf

	EndIf
	Return False
 EndFunc
