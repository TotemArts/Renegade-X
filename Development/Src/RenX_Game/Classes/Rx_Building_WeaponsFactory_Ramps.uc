class Rx_Building_WeaponsFactory_Ramps extends Rx_Building_WeaponsFactory
   placeable;

defaultproperties
{
	MineLimit=8
    Begin Object Class=StaticMeshComponent Name=Static_Ramps
        StaticMesh = StaticMesh'RX_BU_WeaponsFactory.Mesh.SM_WeaponsFactory_Ramps'
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