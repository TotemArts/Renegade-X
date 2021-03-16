class S_Building_HandOfNod_BlackHand_Ramps extends S_Building_HandOfNod_BlackHand
   placeable;

DefaultProperties
{
 	 //MineLimit=10
     Begin Object Class=StaticMeshComponent Name=Static_Ramps
        StaticMesh = StaticMesh'S_BU_Hand.Mesh.SM_HoN_Ramps'
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
