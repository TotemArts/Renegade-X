class Rx_CapturableMCT extends Rx_Building_Techbuilding
   placeable;

simulated function String GetHumanReadableName()
{
	return "MCT";
}

defaultproperties
{
	
	BuildingInternalsClass  = Rx_CapturableMCT_Internals

    Begin Object Class=StaticMeshComponent Name=SiloScreens
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
		bAcceptsDynamicLights           = False
		LightingChannels                = (bInitialized=True,Static=True)
        StaticMesh                      = StaticMesh'RX_BU_Silo.Meshes.SM_Silo_MCT'
		Translation						= (Z=-150)
    End Object
	StaticMeshPieces.Add(SiloScreens)
	Components.Add(SiloScreens)
}