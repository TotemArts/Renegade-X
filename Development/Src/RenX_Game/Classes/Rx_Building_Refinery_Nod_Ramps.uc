class Rx_Building_Refinery_Nod_Ramps extends Rx_Building_Refinery_Nod
	placeable;

DefaultProperties
{
	MineLimit=8
	Begin Object Class=StaticMeshComponent Name=Static_Ramps
		StaticMesh = StaticMesh'RX_BU_Refinery.Mesh.SM_Ref_Ramps_Nod'
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
