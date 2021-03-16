/** one1: Added. */
class Rx_BackWeaponAttachment extends SkeletalMeshComponent;

var int SocketIndex;
var Name TeamColourParameterName;

/** one1: Override to calculate whether to display this weapon as primary or secondary. */
static function int GetSocketIndex(Rx_InventoryManager mngr) { return default.SocketIndex; }

/** one1: Override to calculate whether to display this weapon as primary or secondary on default Inv Manager. */
static function int GetDefaultSocketIndex(class<Rx_InventoryManager> mngr) { return default.SocketIndex; }

simulated function UpdateMaterials(byte NewTeamNum)
{
	local MaterialInterface M;
	local MaterialInstanceConstant MIC;
	local int i;

	if (NewTeamNum == 0 || NewTeamNum == 1)
		ForEach SkeletalMesh.Materials(M, i)
		{
			MIC = CreateAndSetMaterialInstanceConstant(i);
			MIC.SetScalarParameterValue(TeamColourParameterName, NewTeamNum);
		}
}

DefaultProperties
{
	TeamColourParameterName=TeamNumber

	bOwnerNoSee=false
	bOnlyOwnerSee=false
	CollideActors=false
	AlwaysLoadOnClient=true
	AlwaysLoadOnServer=true
	MaxDrawDistance=4000
	bForceRefPose=1
	bUpdateSkelWhenNotRendered=false
	bIgnoreControllersWhenNotRendered=true
	bOverrideAttachmentOwnerVisibility=true
	bAcceptsDynamicDecals=FALSE
	CastShadow=true
	bCastDynamicShadow=true
	bAllowAmbientOcclusion=true
	bPerBoneMotionBlur=true
}
