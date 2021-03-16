class S_Building_Helipad_BlackHand extends Rx_Building_Helipad_GDI;

simulated function String GetHumanReadableName()
{
	return "Helipad";
}

simulated function PostBeginPlay()
{
	Super(Rx_Building).PostBeginPlay();
}

defaultproperties
{

	BuildingInternalsClass  = S_Building_Helipad_BlackHand_Internals


    Begin Object Name=Static_Exterior
        StaticMesh = StaticMesh'S_BU_Helipad.Mesh.SM_Helipad_Base_BH'
    End Object

    Begin Object Name=PT_Screens
        StaticMesh = StaticMesh'S_BU_Helipad.Mesh.SM_Screens_BH'
    End Object
    
	/***************************************************/
	/*             Point Light Components              */
	/***************************************************/


	Begin Object Name=PointLightComponent2
		Translation = (X=-108.240295,Y=453.241943,Z=64.774841)
		LightColor  = (B=255,G=20,R=0,A=0)
		Radius = 200
		FalloffExponent = 4.0
		Brightness = 3.0
		LightmassSettings=(LightSourceRadius=16.0)
	End Object
	PointLightComponents.Add(PointLightComponent2)
	Components.Add(PointLightComponent2)

	Begin Object Name=PointLightComponent3
		Translation = (X=113.294479,Y=452.710571,Z=52.398956)
		LightColor  = (B=255,G=20,R=0,A=0)
		Radius = 200
		FalloffExponent = 4.0
		Brightness = 3.0
		LightmassSettings=(LightSourceRadius=16.0)
	End Object
	PointLightComponents.Add(PointLightComponent3)
	Components.Add(PointLightComponent3)
	

}