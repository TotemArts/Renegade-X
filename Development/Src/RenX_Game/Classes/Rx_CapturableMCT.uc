class Rx_CapturableMCT extends Rx_Building_Techbuilding implements (Rx_ObjectTooltipInterface)
   placeable;

var() StaticMeshComponent Mesh;
var() string ReadableName;
var() string ToolTip;

simulated function String GetHumanReadableName()
{
	return ReadableName;
}

simulated function string GetBuildingName()
{
	return ReadableName;
}

simulated function bool IsTouchingOnly()
{
	return false;
}

simulated function bool IsBasicOnly()
{
	return true;
}

simulated function string GetTooltip(Rx_Controller PC)
{
	if (class'Rx_Utils'.static.OrientationToB(self, PC.Pawn) > 0.1)
	return ToolTip;
}

simulated function bool GetShouldShowHealth(){return true;}

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
	
	Mesh = SiloScreens
	ReadableName = "MCT"
	ToolTip="Use the <font color='#ff0000' size='20'>Repair Gun</font> to capture."

	IconTexture = Texture2D'RenxHUD.T_Tech_Silo'
}