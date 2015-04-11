class Rx_Building_Barracks extends Rx_Building
   placeable;

simulated function String GetHumanReadableName()
{
	return "Barracks";
}

DefaultProperties
{
	TeamID                  = TEAM_GDI
	BuildingInternalsClass  = Rx_Building_Barracks_Internals

	Begin Object Name=Static_Exterior
		StaticMesh=StaticMesh'RX_BU_Barracks.Mesh.SM_Barracks_Exterior'
	End Object

	Begin Object Name=Static_Interior
		StaticMesh=StaticMesh'RX_BU_Barracks.Mesh.SM_Barracks_Interior'
	End Object

	Begin Object Name=Static_Interior_Complex
		StaticMesh=StaticMesh'RX_BU_Barracks.Mesh.SM_Barracks_Interior_Complex'
	End Object

	Begin Object Name=PT_Screens
		StaticMesh=StaticMesh'RX_BU_Barracks.Mesh.SM_Barracks_Screens'
	End Object


	/***************************************************/
	/*             Point Light Components              */
	/***************************************************/
	Begin Object Name=PointLightComponent1
		Translation = (X=-218.000000,Y=290.000000,Z=58.000000)
		Radius = 350.000000
	End Object
	PointLightComponents.Add(PointLightComponent1)
	Components.Add(PointLightComponent1)

	Begin Object Name=PointLightComponent2
		Translation = (X=218.000000,Y=290.000000,Z=58.000000)
		Radius = 350.000000
	End Object
	PointLightComponents.Add(PointLightComponent2)
	Components.Add(PointLightComponent2)

	Begin Object Name=PointLightComponent3
		Translation = (X=-218.000000,Y=-55.000000,Z=58.000000)
		Radius = 350.000000
	End Object
	PointLightComponents.Add(PointLightComponent3)
	Components.Add(PointLightComponent3)

	Begin Object Name=PointLightComponent4
		Translation = (X=218.000000,Y=-55.000000,Z=58.000000)
		Radius = 350.000000
	End Object
	PointLightComponents.Add(PointLightComponent4)
	Components.Add(PointLightComponent4)

	Begin Object Name=PointLightComponent5
		Translation = (X=-218.000000,Y=-400.000000,Z=58.000000)
		Radius = 350.000000
	End Object
	PointLightComponents.Add(PointLightComponent5)
	Components.Add(PointLightComponent5)

	Begin Object Name=PointLightComponent6
		Translation = (X=218.000000,Y=-400.000000,Z=58.000000)
		Radius = 350.000000
	End Object
	PointLightComponents.Add(PointLightComponent6)
	Components.Add(PointLightComponent6)

	Begin Object Name=PointLightComponent7
		Translation = (X=-218.000000,Y=-770.000000,Z=58.000000)
		Radius = 350.000000
	End Object
	PointLightComponents.Add(PointLightComponent7)
	Components.Add(PointLightComponent7)

	Begin Object Name=PointLightComponent8
		Translation = (X=218.000000,Y=-770.000000,Z=58.000000)
		Radius = 350.000000
	End Object
	PointLightComponents.Add(PointLightComponent8)
	Components.Add(PointLightComponent8)


	/***************************************************/
	/*              Spot Light Components              */
	/***************************************************/
	Begin Object Name=SpotLightComponent1
		Translation = (X=-434.0,Y=290.0,Z=-43.0)
		Rotation    = (Pitch=0,Yaw=0,Roll=0)
		LightColor  = (B=110,G=214,R=255,A=0)
	End Object
	Components.Add(SpotLightComponent1)
	SpotLightComponents.Add(SpotLightComponent1)

	Begin Object Name=SpotLightComponent2
		Translation = (X=-434.0,Y=-400,Z=-43.0)
		Rotation    = (Pitch=0,Yaw=0,Roll=0)
		LightColor  = (B=110,G=214,R=255,A=0)
	End Object
	Components.Add(SpotLightComponent2)
	SpotLightComponents.Add(SpotLightComponent2)

	Begin Object Name=SpotLightComponent3
		Translation = (X=434.0,Y=290.0,Z=-43.0)
		Rotation    = (Pitch=0,Yaw=-32768,Roll=0)
		LightColor  = (B=110,G=214,R=255,A=0)
	End Object
	Components.Add(SpotLightComponent3)
	SpotLightComponents.Add(SpotLightComponent3)

	Begin Object Name=SpotLightComponent4
		Translation = (X=434.0,Y=-400.0,Z=-43.0)
		Rotation    = (Pitch=0,Yaw=-32768,Roll=0)
		LightColor  = (B=110,G=214,R=255,A=0)
	End Object
	Components.Add(SpotLightComponent4)
	SpotLightComponents.Add(SpotLightComponent4)

	Begin Object Name=SpotLightComponent5
		Translation = (X=0.0000,Y=-635.0,Z=-60.0)
		Rotation    = (Pitch=1638,Yaw=-16384,Roll=0)
		LightColor  = (B=110,G=214,R=255,A=0)
	End Object
	Components.Add(SpotLightComponent5)
	SpotLightComponents.Add(SpotLightComponent5)

}