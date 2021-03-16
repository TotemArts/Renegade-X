class S_Building_Refinery_BlackHand extends Rx_Building_Refinery_GDI
	placeable;

simulated function String GetHumanReadableName()
{
	return "Refinery";
}

DefaultProperties
{
	TeamID = TEAM_GDI
    BuildingInternalsClass = S_Building_Refinery_BlackHand_Internals
	GDIColor    = "#3260FF"

	Begin Object Name=Static_Exterior
		StaticMesh = StaticMesh'S_BU_Refinery.Mesh.SM_Ref_Exterior_Nod'
	End Object

	Begin Object Name=Static_Interior
		StaticMesh = StaticMesh'S_BU_Refinery.Mesh.SM_Ref_Interior_Nod'
	End Object
	
	Begin Object Name=PT_Screens
		StaticMesh = StaticMesh'S_BU_Refinery.Mesh.SM_Refinery_Screens_Nod'
	End Object

	Begin Object Name=SpotLightComponent1
		LightColor  = (B=255,G=0,R=0,A=0)
	End Object

	Begin Object Name=SpotLightComponent2
		LightColor  = (B=255,G=0,R=0,A=0)
	End Object

	Begin Object Name=SpotLightComponent3
		LightColor  = (B=255,G=0,R=0,A=0)
	End Object

	Begin Object Name=SpotLightComponent4
		LightColor  = (B=255,G=0,R=0,A=0)
	End Object

	Begin Object Name=SpotLightComponent5
		LightColor  = (B=242,G=250,R=255,A=0)
	End Object
}
