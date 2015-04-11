/** one1: Added. */
class Rx_BackWeaponAttachment extends SkeletalMeshComponent;

var int SocketIndex;

/** one1: Override to calculate whether to display this weapon as primary or secondary. */
static function int GetSocketIndex(Rx_InventoryManager mngr) { return default.SocketIndex; }

/** one1: Override to calculate whether to display this weapon as primary or secondary on default Inv Manager. */
static function int GetDefaultSocketIndex(class<Rx_InventoryManager> mngr) { return default.SocketIndex; }

DefaultProperties
{
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
