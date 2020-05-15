class Rx_Volume_CaptureArea extends Volume
	placeable;

var Rx_CapturePoint CapturePoint;

simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	if(CapturePoint != None)
		CapturePoint.Touch(Other,OtherComp,HitLocation,HitNormal);
}

simulated event UnTouch( Actor Other )
{
	if(CapturePoint != None)	
		CapturePoint.UnTouch(Other);
}
DefaultProperties
{
	bStatic	= false
	bNoDelete = true
	BrushColor=(R=125,G=0,B=255,A=255)

}