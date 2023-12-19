#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <ListViewConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

$version = "1.0.5"
#Region ### START Koda GUI section ### Form=crearimagen_v2.kxf
$CrearImagen = GUICreate("Windeploy ImageCreator " & $version, 634, 715, 179, 118)
$grpCrearImagen = GUICtrlCreateGroup("CrearImagen", 8, 186, 617, 249)
$grpImagen = GUICtrlCreateGroup("Imagen", 16, 256, 601, 137)
$lblName1 = GUICtrlCreateLabel("Nombre", 30, 284, 41, 17)
$inNombreImagen = GUICtrlCreateInput("", 120, 281, 401, 21, $GUI_SS_DEFAULT_INPUT)
$lblDescrip = GUICtrlCreateLabel("Descripcion", 31, 318, 60, 17)
$inDescripImagen = GUICtrlCreateInput("", 120, 316, 401, 21, $GUI_SS_DEFAULT_INPUT)
$cboCompresion = GUICtrlCreateCombo("", 120, 356, 81, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "Fast|Max", "Fast")
$lblCompresion = GUICtrlCreateLabel("Compresión", 33, 355, 59, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$lblFile1 = GUICtrlCreateLabel("Archivo destino", 24, 229, 77, 17)
$inFileDestino = GUICtrlCreateInput("", 120, 225, 401, 21)
$btFileDestino = GUICtrlCreateButton("Examinar", 536, 224, 75, 25)
$btCrear = GUICtrlCreateButton("Crear Imagen", 448, 401, 75, 25)
$btAgregar = GUICtrlCreateButton("Agregar Imagen", 532, 401, 83, 25)
$ckboxAddDriver = GUICtrlCreateCheckbox("Solo agregar driver", 32, 405, 120, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$outProceso = GUICtrlCreateEdit("", 16, 451, 601, 201, BitOR($GUI_SS_DEFAULT_EDIT,$ES_READONLY))
GUICtrlSetData(-1, "")
$Cerrar = GUICtrlCreateButton("Cerrar", 543, 670, 75, 25)
$Group1 = GUICtrlCreateGroup("Seleccionar disco", 16, 16, 601, 161)
$lwListDisc = GUICtrlCreateListView("#|Modelo|Sistema|Tamaño|Espacio Libre|Interface|Status", 32, 40, 570, 116, BitOr($LVS_SHOWSELALWAYS, $LVS_SINGLESEL, $LVS_NOSORTHEADER))
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 0, 50)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 1, 150)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 2, 70)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 3, 70)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 4, 70)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 5, 70)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 6, 70)
GUICtrlCreateGroup("", -99, -99, 1, 1)

GUICtrlSendMsg($lwListDisc, $LVM_SETEXTENDEDLISTVIEWSTYLE, $LVS_EX_GRIDLINES, $LVS_EX_GRIDLINES)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Func SondearCancelacionCierre()
	Local $msg
	$msg = GUIGetMsg()
	If $msg <> $GUI_EVENT_MOUSEMOVE Then
		If $msg = $Cerrar Then
			Return True
		Else
			Return False
		EndIf
	EndIf
EndFunc

Func gi_CerrarToCancelar()
   GUICtrlSetData($Cerrar, "Cancelar")
EndFunc

Func gi_CancelarToCerrar()
   GUICtrlSetData($Cerrar, "Cerrar")
EndFunc

Func _IsChecked($idControlID)
        Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

