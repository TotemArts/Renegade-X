class Rx_Building_Obelisk extends Rx_Building_Nod_Defense
   placeable
   implements (RxIfc_TargetedDescription);

simulated function String GetHumanReadableName()
{
	return "Obelisk of Light";
}

simulated function string GetTargetedDescription(PlayerController PlayerPerspective)
{
	if (GetHealth() > 0 && Rx_Building_Team_Internals(BuildingInternals).bNoPower)
		return "Laser Offline";
	return "";
}

defaultproperties
{
    MineLimit=3
    TeamID                 = TEAM_NOD
    BuildingInternalsClass = Rx_Building_Obelisk_Internals
    Begin Object Name=Static_Exterior
        StaticMesh=StaticMesh'RX_BU_Oblisk.Mesh.SM_Obelisk_New'
    End Object

    Begin Object Name=Static_Interior
        StaticMesh=StaticMesh'RX_BU_Oblisk.Mesh.SM_Obelisk_Interior'
    End Object

    Begin Object Name=Static_Interior_Complex
        StaticMesh=StaticMesh'RX_BU_Oblisk.Mesh.SM_Obelisk_Interior_Complex'
    End Object 

    Begin Object Name=PT_Screens
        StaticMesh=StaticMesh'RX_BU_Oblisk.Mesh.SM_Obelisk_Screens'
    End Object

    /***************************************************/
    /*             Point Light Components              */
    /***************************************************/
    Begin Object Name=PointLightComponent1
        Translation = (X=39.106998,Y=97.719994,Z=55.000000)
        Radius = 300.000000
    End Object
    PointLightComponents.Add(PointLightComponent1)
    Components.Add(PointLightComponent1)

    Begin Object Name=PointLightComponent2
        Translation = (X=-148.485199,Y=0.000000,Z=55.000000)
        Radius = 300.000000
    End Object
    PointLightComponents.Add(PointLightComponent2)
    Components.Add(PointLightComponent2)

    Begin Object Name=PointLightComponent3
        Translation = (X=39.106998,Y=-97.719994,Z=55.000000)
        Radius = 300.000000
    End Object
    PointLightComponents.Add(PointLightComponent3)
    Components.Add(PointLightComponent3)


    /***************************************************/
    /*              Spot Light Components              */
    /***************************************************/
    Begin Object Name=SpotLightComponent1
        Translation = (X=-8.0,Y=204.0,Z=-77.0)
        Rotation    = (Pitch=0,Yaw=-16384,Roll=0)
        LightColor  = (B=0,G=0,R=255,A=0)
    End Object
    Components.Add(SpotLightComponent1)
    SpotLightComponents.Add(SpotLightComponent1)

    Begin Object Name=SpotLightComponent2
        Translation = (X=-8.0,Y=-204.0,Z=-77.0)
        Rotation    = (Pitch=0,Yaw=16384,Roll=0)
        LightColor  = (B=0,G=0,R=255,A=0)
    End Object
    Components.Add(SpotLightComponent2)
    SpotLightComponents.Add(SpotLightComponent2)

    Begin Object Name=SpotLightComponent3
        Translation = (X=169.0,Y=4.0,Z=-85.0)
        Rotation    = (Pitch=1638,Yaw=32768,Roll=0)
        LightColor  = (B=0,G=0,R=255,A=0)
    End Object
    Components.Add(SpotLightComponent3)
    SpotLightComponents.Add(SpotLightComponent3)
}
