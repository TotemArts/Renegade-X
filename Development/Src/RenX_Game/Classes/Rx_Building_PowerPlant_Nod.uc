class Rx_Building_PowerPlant_Nod extends Rx_Building_Nod_PowerFactory
	placeable;
      

simulated function String GetHumanReadableName()
{
	return "Power Plant";
}

DefaultProperties
{
	MineLimit=6
	TeamID                  = TEAM_NOD
	BuildingInternalsClass  = Rx_Building_PowerPlant_Nod_Internals

	Begin Object Name=Static_Exterior
		StaticMesh = StaticMesh'RX_BU_PowerPlant.Mesh.SM_PP_Exterior_Nod'
	End Object

	Begin Object Name=Static_Interior
		StaticMesh = StaticMesh'RX_BU_PowerPlant.Mesh.SM_PP_Interior_Simple_Nod'
	End Object

	Begin Object Name=PT_Screens
		StaticMesh = StaticMesh'RX_BU_PowerPlant.Mesh.SM_PP_Screens_Nod'
	End Object

	/***************************************************/
	/*              Spot Light Components              */
	/***************************************************/
	Begin Object Name=SpotLightComponent1
		LightColor  = (B=0,G=0,R=255,A=0)
	End Object
	Components.Add(SpotLightComponent1)
	SpotLightComponents.Add(SpotLightComponent1)

	Begin Object Name=SpotLightComponent2
		LightColor  = (B=0,G=0,R=255,A=0)
	End Object
	Components.Add(SpotLightComponent2)
	SpotLightComponents.Add(SpotLightComponent2)

	Begin Object Name=SpotLightComponent3
		LightColor  = (B=0,G=0,R=255,A=0)
	End Object
	Components.Add(SpotLightComponent3)
	SpotLightComponents.Add(SpotLightComponent3)

	Begin Object Name=SpotLightComponent4
		LightColor  = (B=0,G=0,R=255,A=0)
	End Object
	Components.Add(SpotLightComponent4)
	SpotLightComponents.Add(SpotLightComponent4)

	Begin Object Name=SpotLightComponent5
		LightColor  = (B=0,G=0,R=255,A=0)
	End Object
	Components.Add(SpotLightComponent5)
	SpotLightComponents.Add(SpotLightComponent5)
}
