class S_Building_AirTower_BlackHand_Ramps extends S_Building_AirTower_BlackHand
   placeable;
   
simulated function String GetHumanReadableName()
{
	return "Airstrip";
}

defaultproperties
{
	MineLimit=6
	BuildingInternalsClass  = S_Building_AirTower_Internals_BlackHand_Ramps

    Begin Object Class=StaticMeshComponent Name=Static_Ramps
        StaticMesh = StaticMesh'S_BU_AirStrip.Mesh.SM_AirTower_Ramp'
		CastShadow                      = True
		AlwaysLoadOnClient              = True
		AlwaysLoadOnServer              = True
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
		bAcceptsDynamicLights           = True
		LightingChannels                = (bInitialized=True,Static=True)
		Translation						= (Z=-150)
    End Object
	StaticMeshPieces.Add( Static_Ramps )
	Components.Add( Static_Ramps )
}