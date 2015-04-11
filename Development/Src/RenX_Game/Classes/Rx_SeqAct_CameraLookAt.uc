/**
 * KisMet LootAt
 * \Development\Src\Engine\Classes\CameraLookAt.uc 
*/
class Rx_SeqAct_CameraLookAt extends SequenceAction;
 
var Vector PawnPos;
var Vector CamPos;
var Vector UpVector;
var Vector RotatedVector;
 
function  Activated()
{
 RotatedVector=Vector(Rotator(Normal(PawnPos - CamPos)));   
}

 
defaultproperties
{
 bCallHandler=false
 
 ObjColor=(R=255,G=0,B=255,A=255)
 ObjName="CameraLookAt"
        ObjCategory="Camera"
 
 VariableLinks.Empty
 VariableLinks(0)=(ExpectedType=class'SeqVar_Vector',LinkDesc="PawnPos",PropertyName=PawnPos)
 VariableLinks(1)=(ExpectedType=class'SeqVar_Vector',LinkDesc="CamPos",PropertyName=CamPos)
 VariableLinks(2)=(ExpectedType=class'SeqVar_Vector',LinkDesc="UpVector",PropertyName=UpVector)
 VariableLinks(3)=(ExpectedType=class'SeqVar_Vector',LinkDesc="RotatedVector",bWriteable=TRUE,PropertyName=RotatedVector)
 
}