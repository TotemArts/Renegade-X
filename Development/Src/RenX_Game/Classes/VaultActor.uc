class VaultActor extends Actor implements (Rx_ObjectTooltipInterface)
	placeable;

/** Base cylinder component for collision */
// var() editconst const CylinderComponent	CylinderComponent;
var() CylinderComponent       CollisionCylinder;

var() int Height;
var() int PushDistance;
var() bool bEnabled;
var() string tooltip;
var() string keybindToLookUp;

var() StaticMeshComponent VaultMesh;

// Vault type
var() enum EType
{
        Tall,
        Medium,
        Small
}Type;

simulated function string GetTooltip(Rx_Controller PC)
{
	local vector cameraLoc;
	local rotator cameraRot;

	if (PC.Pawn != None)
			{
				PC.GetPlayerViewPoint(cameraLoc, cameraRot);

				if ( bEnabled )
					{
						// Replace {placeholder} substring with keybind:
						return Repl(tooltip, "{GBA_ThisKeyBind}", Caps(UDKPlayerInput(PC.PlayerInput).GetUDKBindNameFromCommand(keybindToLookUp)), true);
					}
			}
	return "";
}


simulated function bool IsTouchingOnly()
{
	return true;
}

simulated function bool IsBasicOnly()
{
	return false;
}

defaultproperties
{
    Begin Object Class=StaticMeshComponent Name=Vault_Mesh
		CastShadow                      = True
		AlwaysLoadOnClient              = True
		AlwaysLoadOnServer              = false
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
		//HiddenGame=true
		LightingChannels                = (bInitialized=True,Static=True)
		StaticMesh = StaticMesh'RX_Deco_Containers.Meshes.SM_Crate_Wooden'
	End Object
	Components.Add( Vault_Mesh )
	VaultMesh=Vault_Mesh

	CollisionComponent=Vault_Mesh
	bCollideActors=True
	bBlockActors=True

	Height = 450
	PushDistance = 100
	Type = Tall
	
	
	Begin Object Class=CylinderComponent Name=CollisionCmp
		CollisionRadius     = 75.0f
		CollisionHeight     = 50.0f
		bAlwaysRenderIfSelected=true
		BlockNonZeroExtent  = True
		BlockZeroExtent     = false
		bDrawNonColliding   = True
		bDrawBoundingBox    = False
		BlockActors         = False
		CollideActors       = True
	End Object
	//CollisionComponent = CollisionCmp
	CollisionCylinder  = CollisionCmp
	Components.Add(CollisionCmp)

	CollisionType       = COLLIDE_TouchAllButWeapons

	bEnabled = True;
	tooltip = "Press <font color='#ff0000' size='20'>[ {GBA_ThisKeyBind} ]</font> to climb/vault";
	keybindToLookUp = "GBA_Jump" ;

}