#### windeployIC ###
;dism /get-imageinfo /imagefile:
Global $arImagenes
Global $arListMounted


Func DismSuccessDosIdiomas($sSalida)
	If StringInStr($sSalida,"The operation completed successfully") Or StringInStr($sSalida,"La operación se completó correctamente") Then
		Return True
	Else
		Return False
	EndIf
EndFunc

Func ConvertDismBytesToGb($sValor)
	Local $intValor
	$sValor = StringReplace($sValor, ",", "")
	;para la version de Dism en ingles
	$sValor = StringReplace($sValor, ".", "")
	$sValor = StringReplace($sValor, "bytes", "")
	$intValor = Number($sValor)
	$intValor = $intValor/1024
	$intValor = $intValor/1024
	$intValor = $intValor/1024
	Return Round($intValor,1)
EndFunc
;~ (1 = 1) ? "True!" : "False!")

Func DismCapture($UnidadCap, $FilePath, $ImageName, $ImageDescrip,$compresion, $Salida, $bolAppend)
;~ 	Dism /Capture-Image /ImageFile:<path_to_image_file>
;~ 					/CaptureDir:<source_directory>
;~ 					/Name:<image_name>
;~ 					[/Description:<image_description>]
;~ [/ConfigFile:<configuration_file.ini>] {[/Compress:{max|fast|none}] [/Bootable] | [/WIMBoot]} [/CheckIntegrity] [/Verify] [/NoRpFix] [/EA]
	Local $txtCommandLine = 'dism ' & ($bolAppend ? '/Append-Image' : '/Capture-Image') & ' /ImageFile:"' & $FilePath & _
								'" /CaptureDir:' & $UnidadCap & _
								' /Name:"' & $ImageName & _
								'" /Description:"' & $ImageDescrip & _
								($bolAppend ? '"' : '" /Compress:' & $compresion)
	Local $psTarea = Run(@ComSpec & " /c " & $txtCommandLine, "", @SW_HIDE, $STDOUT_CHILD)
	Local $value = 0, $line, $msj_sin_progreso, $mensajes
	Local $percent = 0
	Local $hTimer = TimerInit()
	Local $strProgresoTexto = ""
	Local $intPrcentajeTarea = 60
	Local $floatRatioProgreso = $intPrcentajeTarea/100
	Local $arSalida
	Local $strMensajesAnteriores = GUICtrlRead($Salida) & @CRLF
	While ProcessExists($psTarea)
		$mensajes = $txtCommandLine & @CRLF & StdoutRead($psTarea, True)
		$msj_sin_progreso = StringMid($mensajes, 1, StringInStr($mensajes,"[", 0,1) - 1 ) & @CRLF
		$line = StdoutRead($psTarea, True)
		If StringInStr($line, ".0%") Then
			;separamos a partir del .0%, para hallar el % de progreso
			$line1 = StringSplit($line, ".0%",$STR_ENTIRESPLIT)
			$value = StringRight($line1[$line1[0] - 1], 2) ; agarramos el ultimo % leido
		EndIf
		; Si llega a 00 es porque llego al 100% y finalizo correctamente
		If $value == "00" Then $value = 100
		;aqui esta el codigo que detectara mientras se esta aplicando la imagen
		;si el usuario desea cancelarlo
		Local $n = 0
		;codigo para cancelacion
		;ConsoleWrite("n:" & $n & @CRLF)
		While $n < 15 ;fijamos en 10 el numero de eventos a procesar de la cola
			;ConsoleWrite("while n:" & $n & @CRLF)
			;ConsoleWrite("status Cancelar :" & $statusCancelacion & @CRLF)
			If SondearCancelacionCierre() Then
				;ConsoleWrite("status:" & $n & @CRLF)
				f_KillIfProcessExists("Dism.exe")
;~ 				ActualizandoStatus("Operacion Cancelada")
;~ 				MensajesProgreso($MensajesInstalacion, " ")
;~ 				MensajesProgreso($MensajesInstalacion, "   ---- Operacion Cancelada ----   ")
				GUICtrlSetData($Salida, GUICtrlRead($Salida) & @CRLF & @CRLF & "Y   ---- Operacion Cancelada ----   " & @CRLF)
				Return False
			EndIf
			Sleep(1)
			$n = $n + 1
		WEnd
		;fin del codigo para cancelar la operacion
		Sleep(100)
		If $percent <> $value Then
			;calculamos el tiempo transcurrido y estimado
			$iRatioRestante = (100 - $value)/$value
			$mmTiempoTranscurrido = TimerDiff($hTimer)
			$mmTiempoEstimadoTotal = ($mmTiempoTranscurrido * $iRatioRestante) + $mmTiempoTranscurrido
			$ssTiempoTranscurrido = Floor($mmTiempoTranscurrido/1000)
			$ssTiempoTotal = Floor($mmTiempoEstimadoTotal/1000)
			;$intBarraProgresoGUI += $floatRatioProgreso*($value - $percent)
			;gi_MostrarAvanceBarraProgresoGUI($InstProgreso, $intBarraProgresoGUI)
			$strProgresoTexto = f_ProgresoTexto($value, 3)
			;f_MensajesProgreso_MostrarProgresoTexto($MensajesInstalacion, $strProgresoTexto)
			GUICtrlSetData($Salida, $strMensajesAnteriores & $msj_sin_progreso & $strProgresoTexto)
;~ 			FormProgreso_lblProgreso("Aplicando imagen, Total Est: " & f_CambiarAMinutos($ssTiempoTotal) ,"Transcurrido: " & f_CambiarAMinutos($ssTiempoTranscurrido)& "  " & $value & "%")
			$percent = $value
		EndIf
		;If $value = 100 Then ExitLoop
	WEnd
	$mensajes = StdoutRead($psTarea, True)
	$arSalida = StringSplit($mensajes, @LF)
	ConsoleWrite("----Salida DismCapture: " & $mensajes & @CRLF)
	GUICtrlSetData($Salida, $strMensajesAnteriores & $msj_sin_progreso & $strProgresoTexto & @CRLF &$arSalida[Ubound($arSalida)-2])
EndFunc

Func DismApply( $FilePathWim, $UnidadToApply, $ImageIndex, $Salida)
;~ 	DISM.exe /Apply-Image
;~ 			/ImageFile:<path_to_image_file>
;~ 			[/SWMFile:<pattern>]
;~ 			/ApplyDir:<target_directory> {/Index:< image_index> | /Name:<image_name>}
;~ 			[/CheckIntegrity] [/Verify] [/NoRpFix] [/ConfirmTrustedFile] [/WIMBoot (deprecated)] [/Compact] [/EA]

	Local $txtCommandLine = 'dism /Apply-Image /ImageFile:"' & $FilePathWim & _
								'" /ApplyDir:' & $UnidadToApply & _
								' /Index:"' & $ImageIndex & '"'
;~ 								'" /ScratchDir:" '
	Local $psTarea = Run(@ComSpec & " /c " & $txtCommandLine, "", @SW_HIDE, $STDOUT_CHILD)
	While ProcessExists($psTarea)
		Local $mensajes = $txtCommandLine & @CRLF & StdoutRead($psTarea, True)
		GUICtrlSetData($Salida, $mensajes)
	WEnd
EndFunc

Func DismMount( $RutaMontaje, $FileIma, $ImageIndex, $Salida)
;~ 	Dism /Mount-Image /ImageFile:<path_to_image_file>
;~ 	{/Index:<image_index> | /Name:<image_name>}
;~ 	/MountDir:<path_to_mount_directory>
;~ 	[/ReadOnly] [/Optimize] [/CheckIntegrity]
	Local $txtCommandLine = 'dism /Mount-Image /ImageFile:"' & $FileIma & _
								'" /MountDir:"' & $RutaMontaje & _
								'" /Index:"' & $ImageIndex & '"'

	Local $psTarea = Run(@ComSpec & " /c " & $txtCommandLine, "", @SW_HIDE, $STDOUT_CHILD)
	While ProcessExists($psTarea)
		Local $mensajes = $txtCommandLine & @CRLF & StdoutRead($psTarea, True)
		GUICtrlSetData($Salida, $mensajes)
	WEnd
	getListMounted($lvMnt1)
EndFunc

;~ Dism /Get-MountedImageInfo
;~ Deployment Image Servicing and Management tool
;~ Version: 10.0.22621.1

;~ Mounted images:

;~ Mount Dir : C:\Users\W10\Downloads\montar
;~ Image File : C:\Users\W10\Downloads\prueba_disn.wim
;~ Image Index : 1
;~ Mounted Read/Write : Yes
;~ Status : Ok

;~ The operation completed successfully.

Func getListMounted($ctrlListView)
	GUICtrlSendMsg($ctrlListView, $LVM_DELETEALLITEMS, 0, 0)	; Delete all Items
	Local $txtCommandLine = "Dism /Get-MountedImageInfo"
	Local $psTarea = Run(@ComSpec & " /c " & $txtCommandLine, "", @SW_HIDE, $STDOUT_CHILD)

	ProcessWaitClose($psTarea)
	Local $sSalida = StdoutRead($psTarea)
	$sSalida = ReemplazarCaracteresEspanol($sSalida)
	;para q reconozca en ingles y español
	StringReplace($sSalida, "Index :", "Imagen:")
	Local $intNumIndex = @extended
	StringReplace($sSalida, "Índice:", "Imagen:")
	$intNumIndex = @extended + $intNumIndex
	If DismSuccessDosIdiomas($sSalida) And $intNumIndex > 0 Then
		Dim $arListMounted[$intNumIndex][5]
		$sSalida = StringReplace($sSalida,@CRLF & @CRLF , "|")
		Local $arSalida = StringSplit($sSalida, "|", $STR_NOCOUNT)
		;Eliminamos las 2 primeras lineas q son
		;Deployment Image Servicing and Management tool Version: 10.0.19041.572
		;Details for image : D:\install.wim
		_ArrayDelete($arSalida, 0)
		_ArrayDelete($arSalida, 0)
		;y la ultima q es:
		;The operation completed successfully.
		_ArrayDelete($arSalida, UBound($arSalida)-1)
		For $i = 0 To UBound($arSalida) - 1
			Local $arImagen = ExtraerDatosImagen($arSalida[$i])

;~ 			como hay : q se repite 2 veces, lo reemplzamos por palotes los : q son parte de la ruta y los reatauramos al fina
			$arListMounted[$i][0] = ExtraerValorParametro($arImagen[3]);~ Mounted Read/Write : Yes
			$arListMounted[$i][1] = StringReplace(ExtraerValorParametro(StringReplace($arImagen[0], ":\", "|")), "|", ":\");~ Mount Dir : C:\Users\W10\Downloads\montar
			$arListMounted[$i][2] = StringReplace(ExtraerValorParametro(StringReplace($arImagen[1], ":\", "|")), "|", ":\");~ Image File : C:\Users\W10\Downloads\prueba_disn.wim
			$arListMounted[$i][3] = ExtraerValorParametro($arImagen[2]);~ Image Index : 1
			$arListMounted[$i][4] = ExtraerValorParametro($arImagen[4]);~ Status : Ok
		Next
		RellenarCtrlListView($ctrlListView, $arListMounted)
;~ _ArrayDisplay($arImagenes, "2D display")
	Else
;~ 		ActualizandoStatus("Ocurrio un error al examinar el archivo WIM")
	EndIf
EndFunc

Func DismUnmount($RutaMontaje, $bolGuardarCambios, $Salida)
	;~ 	Dism /Unmount-Image /MountDir:C:\test\offline /commit
	Local $strSave
	If $bolGuardarCambios = $GUI_CHECKED Then
		$strSave = "/commit"
		OptimizeImage($RutaMontaje, $Salida)
	Else
		$strSave = "/discard"
	EndIf

	Local $txtCommandLine = 'dism /Unmount-Image /MountDir:"' & $RutaMontaje & _
								'" ' & $strSave

	Local $psTarea = Run(@ComSpec & " /c " & $txtCommandLine, "", @SW_HIDE, $STDOUT_CHILD)
	While ProcessExists($psTarea)
		Local $mensajes = $txtCommandLine & @CRLF & StdoutRead($psTarea, True)
		GUICtrlSetData($Salida, $mensajes)
	WEnd

EndFunc

Func OptimizeImage($RutaMontaje, $Salida)
	;~ 		optimizamos winre
	;~ dism /image:"W:\WinPE_amd64\mount_winre" /Cleanup-Image /StartComponentCleanup /scratchdir:c:\scratchdir
	Local $txtCommandLine = 'dism /image:"' & $RutaMontaje & _
								'" /Cleanup-Image /StartComponentCleanup '

	Local $psTarea = Run(@ComSpec & " /c " & $txtCommandLine, "", @SW_HIDE, $STDOUT_CHILD)
	While ProcessExists($psTarea)
		Local $mensajes = $txtCommandLine & @CRLF & StdoutRead($psTarea, True)
		GUICtrlSetData($Salida, $mensajes)
	WEnd
EndFunc

Func DismAddDriver($RutaDriver, $strRutaMontajeSel, $Salida)
;~ 	Dism /Add-Driver /Image:"W:\WinPE_amd64\mount" /Driver:"W:\WinPE_amd64\VMD\iastorVD.inf" /scratchdir:c:\scratchdir
	Local $txtCommandLine = 'Dism /Add-Driver /Image:"' & $strRutaMontajeSel & _
								'" /Driver:"' & $RutaDriver & '"'

	Local $psTarea = Run(@ComSpec & " /c " & $txtCommandLine, "", @SW_HIDE, $STDOUT_CHILD)
	While ProcessExists($psTarea)
		Local $mensajes = $txtCommandLine & @CRLF & StdoutRead($psTarea, True)
		GUICtrlSetData($Salida, $mensajes)
	WEnd
EndFunc

Func VerifyDrivers($RutaMontaje, $Salida)
	;~ Verify that the drivers are part of the image:
	;~ Dism /Get-Drivers /Image:"W:\WinPE_amd64\mount"
	Local $txtCommandLine = 'Dism /Get-Drivers /Image:"' & $RutaMontaje & '"'
	Local $psTarea = Run(@ComSpec & " /c " & $txtCommandLine, "", @SW_HIDE, $STDOUT_CHILD)
	While ProcessExists($psTarea)
		Local $mensajes = $txtCommandLine & @CRLF & StdoutRead($psTarea, True)
		GUICtrlSetData($Salida, $mensajes)
	WEnd
EndFunc

Func DismExport($RutaFileSrc, $RutaFileDst,  $ImageIndex, $compresion, $Salida)
;~ 	Dism /Export-Image /SourceImageFile:<path_to_image_file>
;~ 	{/SourceIndex:<image_index> | /SourceName:<image_name>}
;~ 	/DestinationImageFile:<path_to_image_file>
;~ 	[/DestinationName:<Name>] [/Compress:{fast|max|none|recovery}] [/Bootable] [/WIMBoot] [/CheckIntegrity]

	Local $txtCommandLine = 'Dism /Export-Image /SourceImageFile:"' & $RutaFileSrc & _
							'" /SourceIndex:' & $ImageIndex & _
							' /DestinationImageFile:"' & $RutaFileDst & _
							'" /Compress:' & $compresion
	Local $psTarea = Run(@ComSpec & " /c " & $txtCommandLine, "", @SW_HIDE, $STDOUT_CHILD)
	While ProcessExists($psTarea)
		Local $mensajes = $txtCommandLine & @CRLF & StdoutRead($psTarea, True)
		GUICtrlSetData($Salida, $mensajes)
	WEnd
EndFunc


Func CargaListaImagenes($sRutaFileWim)
	If $sRutaFileWim = "" Then Return False
	Local $txtCommandLine = "dism /get-imageinfo /imagefile:" & $sRutaFileWim
	Local $psTarea = Run(@ComSpec & " /c " & $txtCommandLine, "", @SW_HIDE, $STDOUT_CHILD)
	ProcessWaitClose($psTarea)
	Local $sSalida = StdoutRead($psTarea)
	$sSalida = ReemplazarCaracteresEspanol($sSalida)
	;para q reconozca en ingles y español
	StringReplace($sSalida, "Index :", "Imagen:")
	Local $intNumIndex = @extended
	StringReplace($sSalida, "Índice:", "Imagen:")
	$intNumIndex = @extended + $intNumIndex
;~ 	MsgBox($MB_SYSTEMMODAL,"pruba", $sSalida)
	If DismSuccessDosIdiomas($sSalida) And $intNumIndex > 0 Then
		Dim $arImagenes[$intNumIndex][4]
		$sSalida = StringReplace($sSalida,@CRLF & @CRLF , "|")
		Local $arSalida = StringSplit($sSalida, "|", $STR_NOCOUNT)
		;Eliminamos las 2 primeras lineas q son
		;Deployment Image Servicing and Management tool Version: 10.0.19041.572
		;Details for image : D:\install.wim
		_ArrayDelete($arSalida, 0)
		_ArrayDelete($arSalida, 0)
		;y la ultima q es:
		;The operation completed successfully.
		_ArrayDelete($arSalida, UBound($arSalida)-1)
		For $i = 0 To UBound($arSalida) - 1
			Local $arImagen = ExtraerDatosImagen($arSalida[$i])
			$arImagenes[$i][0] = ExtraerValorParametro($arImagen[0])
			$arImagenes[$i][1] = ExtraerValorParametro($arImagen[1])
			$arImagenes[$i][2] = ExtraerValorParametro($arImagen[2])
			$arImagenes[$i][3] = ConvertDismBytesToGb(ExtraerValorParametro($arImagen[3])) & " Gb"
		Next
		Return True
	Else
		Dim $arImagenes[$intNumIndex][4]
		Return False
	EndIf
EndFunc

Func ExtraerDatosImagen($sDatosImagen)
	Local $arImagen = StringSplit($sDatosImagen, @LF, $STR_NOCOUNT)
	Return $arImagen
EndFunc

Func RellenarCtrlListView($ctrlLista, $arTabla)
	Local $sTextoCelda,$sTextoFila
	Local $intNumCol = UBound($arTabla, 2)
	Dim $arFila[$intNumCol]
	GUICtrlSendMsg($ctrlLista, $LVM_DELETEALLITEMS, 0, 0)	; Limpiamos el ctrl Lista
	For $Item = 0 To UBound($arTabla) - 1
		For $i = 0 To $intNumCol - 1
			$arFila[$i] = $arTabla[$Item][$i]
		Next
		$sTextoFila = _ArrayToString($arFila,"|")
		GUICtrlCreateListViewItem($sTextoFila, $ctrlLista)
	Next
EndFunc
