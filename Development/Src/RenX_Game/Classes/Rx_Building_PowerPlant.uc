class Rx_Building_PowerPlant extends Rx_Building
   abstract;

simulated function String GetHumanReadableName()
{
	return "Power Plant";
}

defaultproperties
{
	TeamID                     = TEAM_GDI
	myBuildingType=BT_Power

	Begin Object Name=Static_Interior_Complex
		StaticMesh=StaticMesh'RX_BU_PowerPlant.Mesh.SM_PP_Interior_Complex'
	End Object


	/***************************************************/
	/*             Point Light Components              */
	/***************************************************/
	Begin Object Name=PointLightComponent1
		Translation = (X=-210.0,Y=-540.0,Z=30.0)
		Radius = 350.0
	End Object
	PointLightComponents.Add(PointLightComponent1)
	Components.Add(PointLightComponent1)

	Begin Object Name=PointLightComponent2
		Translation = (X=220.0,Y=-310.0,Z=30.0)
		Radius = 500.0
	End Object
	PointLightComponents.Add(PointLightComponent2)
	Components.Add(PointLightComponent2)

	Begin Object Name=PointLightComponent3
		Translation = (X=220.0,Y=310.0,Z=30.0)
		Radius = 500.0
	End Object
	PointLightComponents.Add(PointLightComponent3)
	Components.Add(PointLightComponent3)

	Begin Object Name=PointLightComponent4
		Translation = (X=285.0,Y=0.0,Z=30.0)
		Radius = 500.0
	End Object
	PointLightComponents.Add(PointLightComponent4)
	Components.Add(PointLightComponent4)
	
	Begin Object Name=PointLightComponent5
		Translation = (X=120.0.0,Y=0.0,Z=150.0)
		Radius = 350.0
		Brightness = 10.000000
		LightColor = (B=0,G=0,R=255,A=0)
	End Object
	PointLightComponents.Add(PointLightComponent5)
	Components.Add(PointLightComponent5)

	/***************************************************/
	/*              Spot Light Components              */
	/***************************************************/
	Begin Object Name=SpotLightComponent1
		Translation = (X=521.0,Y=326.0,Z=-64.0)
		Rotation    = (Pitch=0,Yaw=-32768,Roll=0)
	End Object

	Begin Object Name=SpotLightComponent2
		Translation = (X=521.0,Y=-326.0,Z=-64.0)
		Rotation    = (Pitch=0,Yaw=-32768,Roll=0)
	End Object

	Begin Object Name=SpotLightComponent3
		Translation = (X=-21.0,Y=342.0,Z=-64.0)
		Rotation    = (Pitch=0,Yaw=0,Roll=0)
	End Object

	Begin Object Name=SpotLightComponent4
		Translation = (X=-156.0,Y=-660.0,Z=-64.0)
		Rotation    = (Pitch=0,Yaw=16384,Roll=0)
	End Object

	Begin Object Name=SpotLightComponent5
		Translation = (X=571.0,Y=0.0000,Z=-67.0)
		Rotation    = (Pitch=1638,Yaw=-32768,Roll=0)
		LightColor  = (B=110,G=214,R=255,A=0)
	End Object

	IconTexture=Texture2D'RenxHud.T_BuildingIcon_Power_Normal'


}