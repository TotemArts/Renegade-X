class Rx_Building_WeaponsFactory extends Rx_Building_GDI_VehicleFactory
   placeable;

simulated function String GetHumanReadableName()
{
	return "Weapons Factory";
}

defaultproperties
{
	BuildingInternalsClass  = Rx_Building_WeaponsFactory_Internals

    Begin Object Name=Static_Exterior
        StaticMesh = StaticMesh'RX_BU_WeaponsFactory.Mesh.WeaponsFactory_Exterior'
    End Object

    Begin Object Name=Static_Interior
        StaticMesh = StaticMesh'RX_BU_WeaponsFactory.Mesh.WeaponsFactory_Interior'
    End Object

    Begin Object Name=PT_Screens
        StaticMesh = StaticMesh'RX_BU_WeaponsFactory.Mesh.SM_BU_WF_Screens'
    End Object

	/***************************************************/
	/*             Point Light Components              */
	/***************************************************/
	Begin Object Name=PointLightComponent1
		Translation = (X=-150.0,Y=-310.0,Z=45.0)
		Radius = 500.0
	End Object
	PointLightComponents.Add(PointLightComponent1)
	Components.Add(PointLightComponent1)

	Begin Object Name=PointLightComponent2
		Translation = (X=-772.0,Y=-342.0,Z=20.0)
		Radius = 400.0
	End Object
	PointLightComponents.Add(PointLightComponent2)
	Components.Add(PointLightComponent2)

	Begin Object Name=PointLightComponent3
		Translation = (X=432.0,Y=-348.0,Z=30.0)
		Radius = 500.0
	End Object
	PointLightComponents.Add(PointLightComponent3)
	Components.Add(PointLightComponent3)

	Begin Object Name=PointLightComponent4
		Translation = (X=-500.0,Y=75.0,Z=150.0)
		Radius = 500.0
		Brightness = 4.0
		LightColor = (B=0,G=0,R=255,A=0)
	End Object
	PointLightComponents.Add(PointLightComponent4)
	Components.Add(PointLightComponent4)

	Begin Object Name=PointLightComponent5
		Translation = (X=-500.0,Y=650.0,Z=150.0)
		Radius = 500.0
		Brightness = 4.0
		LightColor = (B=0,G=0,R=255,A=0)
	End Object
	PointLightComponents.Add(PointLightComponent5)
	Components.Add(PointLightComponent5)

	Begin Object Name=PointLightComponent6
		Translation = (X=-35.0,Y=100.0,Z=150.0)
		Radius = 500.0
		Brightness = 4.0
		LightColor = (B=0,G=0,R=255,A=0)
	End Object
	PointLightComponents.Add(PointLightComponent6)
	Components.Add(PointLightComponent6)

	Begin Object Name=PointLightComponent7
		Translation = (X=-35.0,Y=650.0,Z=150.0)
		Radius = 500.0
		Brightness = 4.0
		LightColor = (B=0,G=0,R=255,A=0)
	End Object
	PointLightComponents.Add(PointLightComponent7)
	Components.Add(PointLightComponent7)

	/***************************************************/
	/*              Spot Light Components              */
	/***************************************************/
	Begin Object Name=SpotLightComponent1
		Translation = (X=486.0,Y=-630.0,Z=-65.0)
		Rotation    = (Pitch=0,Yaw=16384,Roll=0)
		LightColor  = (B=110,G=214,R=255,A=0)
	End Object
	Components.Add(SpotLightComponent1)
	SpotLightComponents.Add(SpotLightComponent1)

	Begin Object Name=SpotLightComponent2
		Translation = (X=486.0,Y=-62.0,Z=-65.0)
		Rotation    = (Pitch=0,Yaw=-16384,Roll=0)
		LightColor  = (B=110,G=214,R=255,A=0)
	End Object
	Components.Add(SpotLightComponent2)
	SpotLightComponents.Add(SpotLightComponent2)

	Begin Object Name=SpotLightComponent3
		Translation = (X=-892.0,Y=-345.0,Z=-65.0)
		Rotation    = (Pitch=0,Yaw=0,Roll=0)
		LightColor  = (B=110,G=214,R=255,A=0)
	End Object
	Components.Add(SpotLightComponent3)
	SpotLightComponents.Add(SpotLightComponent3)

	Begin Object Name=SpotLightComponent4
		Translation = (X=-155.0,Y=-566.0,Z=-81.0)
		Rotation    = (Pitch=0,Yaw=16384,Roll=0)
		LightColor  = (B=110,G=214,R=255,A=0)
	End Object
	Components.Add(SpotLightComponent4)
	SpotLightComponents.Add(SpotLightComponent4)
}