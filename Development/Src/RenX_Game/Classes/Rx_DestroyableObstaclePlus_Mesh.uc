class Rx_DestroyableObstaclePlus_Mesh extends Rx_DestroyableObstaclePlus
placeable;

DefaultProperties

{
HP=1000

MaxHP=1000

Begin Object Name=ObstacleMesh
      StaticMesh=StaticMesh'RX_Deco_Rock.Mesh.SM_BasaltMain01'
	    CastShadow                      = True
		bSelfShadowOnly 				= True
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
   End Object

}