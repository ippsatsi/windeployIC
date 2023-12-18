;####      windeployic #####
Func SelectFileDialog($tipo, $inControl,$mensaje,$filtro)
	$wim_filtro = "archivos wim (*.wim)"
	$all_files = "Todos (*.*)"
	$inf_files = "archivos .inf (*.inf)"
	If $filtro = "wim" Then
		$filtro = $wim_filtro
	ElseIf $filtro = "inf" Then
		$filtro = $inf_files
	Else
		$filtro = $all_files
	EndIf

	If $tipo = "save" Then
		$RutaArchivo = FileSaveDialog($mensaje, @WindowsDir & "\", $filtro,  $FD_PROMPTOVERWRITE)
	ElseIf $tipo = "folder" Then
;~ 		$RutaArchivo = FileSelectFolder($mensaje, @WindowsDir & "\")
;~ 		$RutaArchivo = FileSelectFolder($mensaje, "C:")
		$RutaArchivo = FileSelectFolder("Choose your folder", "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}")
	ElseIf $tipo = "driver" Then
		$RutaArchivo = FileOpenDialog($mensaje, @WindowsDir & "\", $filtro, $FD_FILEMUSTEXIST)
	Else
		$RutaArchivo =  FileOpenDialog($mensaje, @WindowsDir & "\", $filtro, $FD_MULTISELECT)
	EndIf
;~ 	$RutaArchivo =  FileOpenDialog($mensaje, @WindowsDir & "\", $filtro, BitOR($FD_FILEMUSTEXIST, $FD_MULTISELECT))
	If $RutaArchivo <> "" And $filtro <> "driver" Then
		GUICtrlSetData($inControl, $RutaArchivo)
	EndIf
	Return $RutaArchivo
EndFunc



