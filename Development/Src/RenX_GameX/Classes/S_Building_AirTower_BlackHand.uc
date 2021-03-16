class S_Building_AirTower_BlackHand extends Rx_Building
   placeable;

var() S_Building_Airstrip_BlackHand LinkedAirstrip;

simulated function String GetHumanReadableName()
{
    return "Airstrip";
}

function GetAttackPoints()
{
    local NavigationPoint N;
    local Vector Dummy1,Dummy2;
    local Rx_Building Strip;

    Strip = S_Building_AirTower_Internals_BlackHand(BuildingInternals).AirstripInternals.BuildingVisuals;

    foreach WorldInfo.AllNavigationPoints(class'NavigationPoint',N)
    {
        if(N.Trace(Dummy1,Dummy2,N.Location,Location,,,,TRACEFLAG_Bullet) != Self && N.Trace(Dummy1,Dummy2,N.Location,Strip.Location,,,,TRACEFLAG_Bullet) != Strip)
            Continue;

        ViableAttackPoints.AddItem(N);

    }

    if(ViableAttackPoints.length <= 0)
        `log(GetHumanReadableName()@" : Failed to find viable attack points! Bots may find issues in pathfinding to this building!");
}


DefaultProperties
{
    //MineLimit=3
   	TeamID = TEAM_GDI
	BuildingInternalsClass  = S_Building_AirTower_Internals_BlackHand
    GDIColor    = "#3260FF"

	Begin Object Name=Static_Exterior
        StaticMesh = StaticMesh'S_BU_AirStrip.Mesh.AirTower_Exterior'
    End Object

    Begin Object Name=Static_Interior
        StaticMesh = StaticMesh'S_BU_AirStrip.Mesh.AirTower_Interior'
    End Object

    Begin Object Name=PT_Screens
        StaticMesh = StaticMesh'S_BU_AirStrip.Mesh.SM_AirTower_Screens'
    End Object

   Begin Object Class=StaticMeshComponent Name=SandBags
        CastShadow                      = True
        AlwaysLoadOnClient              = True
        AlwaysLoadOnServer              = False
        CollideActors                   = True
        BlockActors                     = True
        BlockRigidBody                  = True
        BlockZeroExtent                 = True
        BlockNonZeroExtent              = True
        bCastDynamicShadow              = True
        bAcceptsLights                  = True
        bAcceptsDecalsDuringGameplay    = True
        bAcceptsDecals                  = True
        bAllowApproximateOcclusion      = True
        bUsePrecomputedShadows          = True
        bForceDirectLightMap            = True
        bAcceptsDynamicLights           = False
        LightingChannels                = (bInitialized=True,Static=True)
        StaticMesh                      = StaticMesh'RX_BU_AirStrip.Mesh.AirtTower_Sandbags'
        Translation                     = (Z=-150)
    End Object
    StaticMeshPieces.Add(SandBags)
    Components.Add(SandBags)
    
    /***************************************************/
    /*             Point Light Components              */
    /***************************************************/
    Begin Object Name=PointLightComponent1
        Translation = (X=328.316742,Y=-191.119507,Z=19.0)
    End Object
    PointLightComponents.Add(PointLightComponent1)
    Components.Add(PointLightComponent1)

    Begin Object Name=PointLightComponent2
        Translation = (X=327.890259,Y=190.693604,Z=19.0)
    End Object
    PointLightComponents.Add(PointLightComponent2)
    Components.Add(PointLightComponent2)

    Begin Object Name=PointLightComponent3
        Translation = (X=0.000000,Y=0.000000,Z=50.000000)
    End Object
    PointLightComponents.Add(PointLightComponent3)
    Components.Add(PointLightComponent3)

    /***************************************************/
    /*              Spot Light Components              */
    /***************************************************/
    Begin Object Name=SpotLightComponent1
        Translation = (X=477.568085,Y=0.909855,Z=-63.726059)
        Rotation    = (Pitch=0,Yaw=32768,Roll=0)
        LightColor  = (B=255,G=0,R=0,A=0)
    End Object
    SpotLightComponents.Add(SpotLightComponent1)
    Components.Add(SpotLightComponent1)

    Begin Object Name=SpotLightComponent2
        Translation = (X=67.538994,Y=-349.838287,Z=-63.726059)
        Rotation    = (Pitch=0,Yaw=4413,Roll=0)
        LightColor  = (B=255,G=0,R=0,A=0)
    End Object
    SpotLightComponents.Add(SpotLightComponent2)
    Components.Add(SpotLightComponent2)

    Begin Object Name=SpotLightComponent3
        Translation = (X=107.227089,Y=186.403488,Z=-63.726059)
        Rotation    = (Pitch=0,Yaw=10923,Roll=0)
        LightColor  = (B=255,G=0,R=0,A=0)
    End Object
    SpotLightComponents.Add(SpotLightComponent3)
    Components.Add(SpotLightComponent3)
}