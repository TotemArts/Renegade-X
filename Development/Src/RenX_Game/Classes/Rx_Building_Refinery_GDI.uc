class Rx_Building_Refinery_GDI extends Rx_Building_GDI_MoneyFactory
	placeable;

simulated function String GetHumanReadableName()
{
	return "Refinery";
}

DefaultProperties
{
	MineLimit=6
	TeamID                  = TEAM_GDI
	BuildingInternalsClass  = Rx_Building_Refinery_GDI_Internals

	Begin Object Name=Static_Exterior
		StaticMesh = StaticMesh'RX_BU_Refinery.Mesh.SM_Ref_Exterior_GDI'
	End Object

	Begin Object Name=Static_Interior
		StaticMesh = StaticMesh'RX_BU_Refinery.Mesh.SM_Ref_Interior_GDI'
	End Object
	
	Begin Object Name=PT_Screens
		StaticMesh = StaticMesh'RX_BU_Refinery.Mesh.SM_Refinery_Screens_GDI'
	End Object

	/***************************************************/
	/*              Spot Light Components              */
	/***************************************************/
	Begin Object Name=SpotLightComponent1
		LightColor  = (B=110,G=214,R=255,A=0)
	End Object
	Components.Add(SpotLightComponent1)
	SpotLightComponents.Add(SpotLightComponent1)

	Begin Object Name=SpotLightComponent2
		LightColor  = (B=110,G=214,R=255,A=0)
	End Object
	Components.Add(SpotLightComponent2)
	SpotLightComponents.Add(SpotLightComponent2)

	Begin Object Name=SpotLightComponent3
		LightColor  = (B=110,G=214,R=255,A=0)
	End Object
	Components.Add(SpotLightComponent3)
	SpotLightComponents.Add(SpotLightComponent3)

	Begin Object Name=SpotLightComponent4
		LightColor  = (B=110,G=214,R=255,A=0)
	End Object
	Components.Add(SpotLightComponent4)
	SpotLightComponents.Add(SpotLightComponent4)

	Begin Object Name=SpotLightComponent5
		LightColor  = (B=242,G=250,R=255,A=0)
	End Object

}
