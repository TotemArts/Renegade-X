class Rx_Building_HandOfNod extends Rx_Building_Nod_InfantryFactory
   placeable;

simulated function String GetHumanReadableName()
{
	return "Hand of Nod";
}

DefaultProperties
{
    TeamID                 = TEAM_NOD
    BuildingInternalsClass = Rx_Building_HandOfNod_Internals
   
    Begin Object Name=Static_Exterior
        StaticMesh = StaticMesh'RX_BU_Hand.Mesh.HoN_Exterior'
    End Object

    Begin Object Name=Static_Interior
        StaticMesh = StaticMesh'RX_BU_Hand.Mesh.HoN_Interior'
    End Object

    Begin Object Name=PT_Screens
        StaticMesh = StaticMesh'RX_BU_Hand.Mesh.SM_HoN_Screens'
    End Object    
	
	Begin Object Name=Static_Interior_Complex
        StaticMesh = StaticMesh'RX_BU_Hand.Mesh.HoN_InteriorDetails'
    End Object

    /***************************************************/
    /*             Point Light Components              */
    /***************************************************/
    Begin Object Name=PointLightComponent1
        Translation = (X=0.000000,Y=-161.802002,Z=310.000000)
        Radius = 500.000000
    End Object
    PointLightComponents.Add(PointLightComponent1)
    Components.Add(PointLightComponent1)

    Begin Object Name=PointLightComponent2
        Translation = (X=0.000000,Y=-795.000000,Z=310.000000)
        Radius = 500.000000
    End Object
    PointLightComponents.Add(PointLightComponent2)
    Components.Add(PointLightComponent2)

    Begin Object Name=PointLightComponent3
        Translation = (X=0.000000,Y=305.000000,Z=310.000000)
        Radius = 500.000000
    End Object
    PointLightComponents.Add(PointLightComponent3)
    Components.Add(PointLightComponent3)

    Begin Object Name=PointLightComponent4
        Translation = (X=-240.000000,Y=-146.000000,Z=20.000000)
        Radius = 500.000000
    End Object
    PointLightComponents.Add(PointLightComponent4)
    Components.Add(PointLightComponent4)

    Begin Object Name=PointLightComponent5
        Translation = (X=240.000000,Y=-146.000000,Z=20.000000)
        Radius = 500.000000
    End Object
    PointLightComponents.Add(PointLightComponent5)
    Components.Add(PointLightComponent5)

    Begin Object Name=PointLightComponent6
        Translation = (X=240.000000,Y=-695.000000,Z=20.000000)
        Radius = 500.000000
    End Object
    PointLightComponents.Add(PointLightComponent6)
    Components.Add(PointLightComponent6)

    Begin Object Name=PointLightComponent7
        Translation = (X=-240.000000,Y=-695.000000,Z=20.000000)
        Radius = 500.000000
    End Object
    PointLightComponents.Add(PointLightComponent7)
    Components.Add(PointLightComponent7)

    Begin Object Name=PointLightComponent8
        Translation = (X=0.000000,Y=-985.000000,Z=20.000000)
        Radius = 500.000000
    End Object
    PointLightComponents.Add(PointLightComponent8)
    Components.Add(PointLightComponent8)

    /***************************************************/
    /*              Spot Light Components              */
    /***************************************************/
    Begin Object Name=SpotLightComponent1
        Translation = (X=-283.0,Y=306.0,Z=142.0)
        Rotation    = (Pitch=-2392,Yaw=0,Roll=0)
        LightColor  = (B=0,G=0,R=255,A=0)
    End Object
    Components.Add(SpotLightComponent1)
    SpotLightComponents.Add(SpotLightComponent1)

    Begin Object Name=SpotLightComponent2
        Translation = (X=283.0,Y=306.0,Z=142.0)
        Rotation    = (Pitch=-2392,Yaw=-32768,Roll=0)
        LightColor  = (B=0,G=0,R=255,A=0)
    End Object
    Components.Add(SpotLightComponent2)
    SpotLightComponents.Add(SpotLightComponent2)

    Begin Object Name=SpotLightComponent3
        Translation = (X=-345.0,Y=-136.0,Z=-60.0)
        Rotation    = (Pitch=-1948,Yaw=0,Roll=0)
        LightColor  = (B=0,G=0,R=255,A=0)
    End Object
    Components.Add(SpotLightComponent3)
    SpotLightComponents.Add(SpotLightComponent3)

    Begin Object Name=SpotLightComponent4
        Translation = (X=345.0,Y=-136.0,Z=-60.0)
        Rotation    = (Pitch=-1948,Yaw=-32768,Roll=0)
        LightColor  = (B=0,G=0,R=255,A=0)
    End Object
    Components.Add(SpotLightComponent4)
    SpotLightComponents.Add(SpotLightComponent4)

    Begin Object Name=SpotLightComponent5
        Translation = (X=0.0000,Y=-47.0,Z=-53.0)
        Rotation    = (Pitch=1638,Yaw=-16384,Roll=0)
        LightColor  = (B=0,G=0,R=255,A=0)
    End Object
    Components.Add(SpotLightComponent5)
    SpotLightComponents.Add(SpotLightComponent5)
}
