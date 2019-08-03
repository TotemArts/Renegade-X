class Rx_Building_MedicalCentre extends Rx_Building_Techbuilding
placeable;

simulated function String GetHumanReadableName()
{
	return "Medical Center";
}

defaultproperties
{
	
	BuildingInternalsClass  = Rx_Building_MedicalCentre_Internals

    Begin Object Name=Static_Exterior
        StaticMesh = StaticMesh'RX_BU_MedicalCentre.Mesh.SM_Placeholder'
    End Object

    Begin Object Name=Static_Interior
        StaticMesh = StaticMesh'RX_BU_MedicalCentre.Mesh.SM_Placeholder'
    End Object

    Begin Object Name=PT_Screens
        StaticMesh = StaticMesh'RX_BU_MedicalCentre.Mesh.SM_Placeholder'
    End Object

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