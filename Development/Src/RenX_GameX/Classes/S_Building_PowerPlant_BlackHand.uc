class S_Building_PowerPlant_BlackHand extends Rx_Building_PowerPlant_GDI
	placeable;

simulated function String GetHumanReadableName()
{
	return "Power Plant";
}

DefaultProperties
{
    BuildingInternalsClass = S_Building_PowerPlant_BlackHand_Internals
	GDIColor    = "#3260FF"

	Begin Object Name=Static_Exterior
		StaticMesh = StaticMesh'S_BU_PowerPlant.Materials.SM_PP_Exterior_Nod'
	End Object

	Begin Object Name=Static_Interior
		StaticMesh = StaticMesh'S_BU_PowerPlant.Materials.SM_PP_Interior_Simple_Nod'
	End Object

	Begin Object Name=PT_Screens
		StaticMesh = StaticMesh'S_BU_PowerPlant.Materials.SM_PP_Screens_Nod'
	End Object

	Begin Object Name=SpotLightComponent1
		LightColor  = (B=255,G=0,R=0,A=0)
	End Object
	Components.Add(SpotLightComponent1)
	SpotLightComponents.Add(SpotLightComponent1)

	Begin Object Name=SpotLightComponent2
		LightColor  = (B=255,G=0,R=0,A=0)
	End Object
	Components.Add(SpotLightComponent2)
	SpotLightComponents.Add(SpotLightComponent2)

	Begin Object Name=SpotLightComponent3
		LightColor  = (B=255,G=0,R=0,A=0)
	End Object
	Components.Add(SpotLightComponent3)
	SpotLightComponents.Add(SpotLightComponent3)

	Begin Object Name=SpotLightComponent4
		LightColor  = (B=255,G=0,R=0,A=0)
	End Object
	Components.Add(SpotLightComponent4)
	SpotLightComponents.Add(SpotLightComponent4)

	Begin Object Name=SpotLightComponent5
		LightColor  = (B=255,G=0,R=0,A=0)
	End Object
}
