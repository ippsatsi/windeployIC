#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#Region ### START Koda GUI section ### Form=crearimagen.kxf
$CrearImagen = GUICreate("Windeploy ImageCreator", 634, 612, 179, 118)
$grpCrearImagen = GUICtrlCreateGroup("CrearImagen", 8, 16, 617, 249)
$grpImagen = GUICtrlCreateGroup("Imagen", 16, 84, 601, 137)
$lblName1 = GUICtrlCreateLabel("Nombre", 30, 112, 41, 17)
$inNombreImagen = GUICtrlCreateInput("", 112, 109, 409, 21, $ES_READONLY)
$lblDescrip = GUICtrlCreateLabel("Descripcion", 31, 146, 60, 17)
$inDescripImagen = GUICtrlCreateInput("", 112, 144, 409, 21, $ES_READONLY)
$cboCompresion = GUICtrlCreateCombo("", 113, 184, 81, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "Fast|Max", "Fast")
$lblCompresion = GUICtrlCreateLabel("Compresión", 33, 183, 59, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$lblFile1 = GUICtrlCreateLabel("Archivo destino", 24, 45, 77, 17)
$inFileDestino = GUICtrlCreateInput("", 112, 43, 409, 21)
$btFileDestino = GUICtrlCreateButton("Examinar", 536, 42, 75, 25)
$btCrear = GUICtrlCreateButton("Crear Imagen", 448, 232, 75, 25)
$btAgregar = GUICtrlCreateButton("Agregar Imagen", 532, 232, 83, 25)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$outProceso = GUICtrlCreateEdit("", 16, 280, 601, 273, BitOR($GUI_SS_DEFAULT_EDIT,$ES_AUTOHSCROLL,$ES_AUTOVSCROLL,$ES_READONLY), $WS_EX_STATICEDGE)
GUICtrlSetData(-1, "")
$Cerrar = GUICtrlCreateButton("Cerrar", 543, 568, 75, 25)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###


