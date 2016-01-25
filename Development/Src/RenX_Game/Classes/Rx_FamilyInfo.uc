/*********************************************************
*
* File: Rx_FamilyInfo.uc
* Author: RenegadeX-Team
* Project: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/
class Rx_FamilyInfo extends UTFamilyInfo
	abstract; //UTFamilyInfo_Liandri_Male;

var localized string    CharacterName;

/** one1: Made this obsolete. */
//var array<class>        StartWeapons;

//Enumerated values for armour types. 
enum ENUM_Armor 
{
	A_Kevlar,
	A_FLAK, 
	A_Lazarus
};


var const float         DamagePointsMultiplier;
var const float 		SpeedMultiplier;
var const float			JumpMultiplier;
var const float         HealPointsMultiplier;
var const float         PointsForKill;
var const int           MaxHealth;
var const int           MaxArmor;
var ENUM_Armor 			Armor_Type;
var const bool			bFemale; //halo2pac

// Offset the 3rd person camera height for tall or short characters.
var const float         CameraHeightModifier;

// Array of damage types we're immune to
var array<class>        ImmuneTo;

/** one1: Inventory manager class for this familyinfo. */
var class<Rx_InventoryManager> InvManagerClass;

/** one1: Removed and modified to return only first weapon. This is used only
 *  for displaying weapon on character in menu. */
function static class<Rx_Weapon> GetPrimaryStartWeaponClass()
{
	return default.InvManagerClass.default.PrimaryWeapons[0];
}

function static MaterialInterface GetFirstPersonArmsMaterial(int TeamNum)
{
	return None;
}

function static float GetCameraHeightModifier()
{
	return default.CameraHeightModifier;
}

// See if we're immune to a specific damage type
function static bool IsImmuneTo(class<DamageType> damageType)
{
	local int i;

	for (i = 0; i < default.ImmuneTo.Length; i++)
	{
		if (default.ImmuneTo[i] == damageType)
			return true;
	}
	return false;

}

DefaultProperties
{
	CameraHeightModifier = 0

	FamilyID="GDI"
	Faction="GDI" 

	CharacterMesh=SkeletalMesh'RX_CH_Animations.Mesh.SK_CH_PhysModel'

	ArmMeshPackageName="RX_CH_Arms"
	ArmMesh="RX_CH_Arms.Mesh.SK_Arms_GDI_Default"
	ArmSkinPackageName="RX_CH_Arms"
	
	// PhysAsset=PhysicsAsset'RX_CH_Animations.Mesh.SK_Character_HitReaction_Physics'
	PhysAsset=PhysicsAsset'RX_CH_Animations.Mesh.SK_CH_Physics'					// PhysicsAsset'RX_CH_Animations.Mesh.SK_Character_Ragdoll_Physics'
	AnimSets(0)=AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_Unarmed'
	AnimSets(1)=AnimSet'RX_CH_Animations.Anims.AS_Character_Male_AimOffset'
	
	SoundGroupClass=class'RenX_Game.Rx_PawnSoundGroup' 
	VoiceClass=class'RenX_Game.Rx_Voice_GDI_Male' 
	
	LeftFootBone=b_L_Ankle
	RightFootBone=b_R_Ankle
	TakeHitPhysicsFixedBones[0]=b_L_Ankle
	TakeHitPhysicsFixedBones[1]=b_R_Ankle

	RedArmMaterial=none
	BlueArmMaterial=none

	CharacterTeamHeadMaterials[0]=none
	CharacterTeamBodyMaterials[0]=none
	CharacterTeamHeadMaterials[1]=none
	CharacterTeamBodyMaterials[1]=none

	BaseMICParent=MaterialInstanceConstant'RenX_AssetBase.Characters.MI_CH_All'
	BioDeathMICParent=MaterialInstanceConstant'RenX_AssetBase.Characters.MI_CH_All_BioDeath'
	
	HeadShotEffect=ParticleSystem'RX_CH_Gibs.Effects.P_BloodExplode'

	HeadShotGoreSocketName="HeadShotGoreSocket"
	HeadShotNeckGoreAttachment=StaticMesh'RX_CH_Gore.S_CH_Head_Chunk3'	// StaticMesh'RX_CH_Gore.S_CH_Headshot_Gore'
	
	NeckStumpName="RX_CH_Gore.S_CH_Head_Chunk3"		// "RX_CH_Gore.S_CH_Headshot_Gore" 	// "SK_CH_IronG_Male_NeckStump01"
	
	BloodSplatterDecalMaterial=MaterialInstanceTimeVarying'T_FX.DecalMaterials.MITV_FX_OilDecal_Small01'

	GibExplosionTemplate=ParticleSystem'RX_CH_Gibs.Effects.P_BloodExplode'

	DeathMeshBreakableJoints=("b_L_Arm","b_R_Arm","b_L_UpperLeg","b_R_UpperLeg")

	HeadGib=(BoneName=b_Head,GibClass=class'Rx_Gib_HumanHead',bHighDetailOnly=false)

	Gibs[0]=(BoneName=b_L_ForeArm,GibClass=class'Rx_Gib_HumanArm',bHighDetailOnly=false)
 	Gibs[1]=(BoneName=b_R_ForeArm,GibClass=class'Rx_Gib_HumanArm',bHighDetailOnly=true)
 	Gibs[2]=(BoneName=b_L_LowerLeg,GibClass=class'Rx_Gib_HumanChunk',bHighDetailOnly=false)
 	Gibs[3]=(BoneName=b_R_LowerLeg,GibClass=class'Rx_Gib_HumanChunk',bHighDetailOnly=true)
 	Gibs[4]=(BoneName=b_Spine_1,GibClass=class'Rx_Gib_HumanTorso',bHighDetailOnly=false)
 	Gibs[5]=(BoneName=b_Spine_2,GibClass=class'Rx_Gib_HumanChunk',bHighDetailOnly=false)
 	Gibs[6]=(BoneName=b_Spine_3,GibClass=class'Rx_Gib_HumanBone',bHighDetailOnly=false)
 	Gibs[7]=(BoneName=b_L_UpperLeg,GibClass=class'Rx_Gib_HumanChunk',bHighDetailOnly=true)
 	Gibs[8]=(BoneName=b_R_UpperLeg,GibClass=class'Rx_Gib_HumanChunk',bHighDetailOnly=true)
	
	// default death mesh here
	DeathMeshSkelMesh=SkeletalMesh'RX_CH_Skeletons.Mesh.SK_CH_Skeleton_Human_Male'
	DeathMeshPhysAsset=PhysicsAsset'RX_CH_Skeletons.Mesh.SK_CH_Skeleton_Human_Male_Physics'
	SkeletonBurnOutMaterials=(MaterialInstanceTimeVarying'RX_CH_Skeletons.Materials.MITV_CH_Skeletons_Human_01_BO')
	
	DeathMeshNumMaterialsToSetResident=1
	
	BloodEmitterClass=class'Rx_Emit_HeadShotBloodSpray' // class'UTGame.UTEmit_BloodSpray'
	BloodEffects[0]=(Template=ParticleSystem'RX_CH_Gibs.Effects.P_BloodExplode',MinDistance=750.0)
	BloodEffects[1]=(Template=ParticleSystem'RX_CH_Gibs.Effects.P_BloodExplode',MinDistance=350.0)
	BloodEffects[2]=(Template=ParticleSystem'RX_CH_Gibs.Effects.P_BloodExplode',MinDistance=0.0)

	DefaultMeshScale=1.075
	DrivingDrawScale=0.8
	BaseTranslationOffset=14.0

	MaxHealth = 100
	MaxArmor  = 100
	Armor_Type = A_Kevlar
	SpeedMultiplier=1.0
	JumpMultiplier=1.0
	DamagePointsMultiplier=0.05 /*Stock, 1 point/credit per 20 damage. That puts a Rifle soldier at giving away 10 points total without a death bonus*/ 
	
	bFemale = false; //halo2pac

	/** one1: Default inventory manager class. */
	InvManagerClass=class'Rx_InventoryManager'
}
