class Rx_Building_TeamSilo_Nod extends Rx_Building_Nod_MoneyFactory
	placeable;

simulated function String GetHumanReadableName()
{
	return "Nod Silo";
}

defaultproperties
{
   TeamID = TEAM_NOD
   BuildingInternalsClass = Rx_Building_TeamSilo_Nod_Internals
	
	Begin Object Name=Static_Exterior
		StaticMesh = StaticMesh'RX_BU_TeamSilo.Meshes.SM_Silo_Nod'
		LightingChannels=(bInitialized=True,Static=True)
	End Object
	
	Begin Object Name=Static_Interior
        StaticMesh = StaticMesh'RX_BU_TeamSilo.Meshes.SM_Silo_Exterior_Nod'
		LightingChannels=(bInitialized=True,Static=True)
    End Object
	
    Begin Object Name=Static_Interior_Complex
        StaticMesh = StaticMesh'RX_BU_Silo.Meshes.SM_Silo_Details'
    End Object

	/***************************************************/
	/*             Point Light Components              */
	/***************************************************/

	PointLightComponents.Remove(PointLightComponent1)
	Components.Remove(PointLightComponent1)

	PointLightComponents.Remove(PointLightComponent2)
	Components.Remove(PointLightComponent2)

	PointLightComponents.Remove(PointLightComponent3)
	Components.Remove(PointLightComponent3)

	PointLightComponents.Remove(PointLightComponent4)
	Components.Remove(PointLightComponent4)

	PointLightComponents.Remove(PointLightComponent5)
	Components.Remove(PointLightComponent5)

	PointLightComponents.Remove(PointLightComponent6)
	Components.Remove(PointLightComponent6)

	PointLightComponents.Remove(PointLightComponent7)
	Components.Remove(PointLightComponent7)

	PointLightComponents.Remove(PointLightComponent8)
	Components.Remove(PointLightComponent8)

	PointLightComponents.Remove(PointLightComponent9)
	Components.Remove(PointLightComponent9)

	PointLightComponents.Remove(PointLightComponent10)
	Components.Remove(PointLightComponent10)

	PointLightComponents.Remove(PointLightComponent11)
	Components.Remove(PointLightComponent11)

	PointLightComponents.Remove(PointLightComponent12)
	Components.Remove(PointLightComponent12)

	PointLightComponents.Remove(PointLightComponent13)
	Components.Remove(PointLightComponent13)

	PointLightComponents.Remove(PointLightComponent14)
	Components.Remove(PointLightComponent14)


	/***************************************************/
	/*              Spot Light Components              */
	/***************************************************/
	
	Begin Object Name=SpotLightComponent1
		Brightness                  = 0.000000	
	End Object
	Components.Add(SpotLightComponent1)
	SpotLightComponents.Add(SpotLightComponent1)

	Begin Object Name=SpotLightComponent2
		Brightness                  = 0.000000
	End Object
	Components.Add(SpotLightComponent2)
	SpotLightComponents.Add(SpotLightComponent2)

	Begin Object Name=SpotLightComponent3
		Brightness                  = 0.000000
	End Object
	Components.Add(SpotLightComponent3)
	SpotLightComponents.Add(SpotLightComponent3)

	Begin Object Name=SpotLightComponent4
		Brightness                  = 0.000000
	End Object
	Components.Add(SpotLightComponent4)
	SpotLightComponents.Add(SpotLightComponent4)

	Begin Object Name=SpotLightComponent5
		Brightness                  = 0.000000
	End Object
	Components.Add(SpotLightComponent5)
	SpotLightComponents.Add(SpotLightComponent5)
}

