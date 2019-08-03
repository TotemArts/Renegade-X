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
	implements(Rx_IPurchasable)
	abstract;

var localized string    CharacterName;

/** one1: Made this obsolete. */
//var array<class>        StartWeapons;

//Enumerated values for armour types. 
enum ENUM_Armor 
{
	A_Kevlar,
	A_FLAK, 
	A_Lazarus,
	A_NONE
};

enum CharacterRole
{
	ROLE_Offense,
	ROLE_Defense
};

var array<class<Rx_PickUp> > PowerUpClasses;

var const float         DamagePointsMultiplier;
var const float 		SpeedMultiplier;
var const float			JumpMultiplier;
var const float         HealPointsMultiplier;
var const float         PointsForKill;
var const int           MaxHealth;
var const int           MaxArmor;
var ENUM_Armor 			Armor_Type;
var CharacterRole		Role;
var const bool			bFemale; //halo2pac
var const float			VPReward[4]; 
var const int			VPCost[3]; 
var bool				bIsStealth;
var const string		PTString;

// Offset the 3rd person camera height for tall or short characters.
var const float         CameraHeightModifier;

// Array of damage types we're immune to
var array<class>        ImmuneTo;

/** one1: Inventory manager class for this familyinfo. */
var class<Rx_InventoryManager> InvManagerClass;

/*The voice used by an actual Pawn, as oppose to the controller*/
var const class<Rx_Pawn_VoiceClass> PawnVoiceClass;

/*Veterancy*/
var float Vet_HealthMod[4]; //Health Increases for this unit as it ranks up (*X)
var float Vet_SprintSpeedMod[4]; //Sprint speed increases for this unit as it ranks up. (*X)

/** Rx_IPurchasable */
var const bool bHighTier;
var const int BasePurchaseCost;
var const localized string PT_Title;
var const localized string PT_Description;
var const int PT_Damage;
var const int PT_Range;
var const int PT_RateOfFire;
var const int PT_MagazineCapacity;
var const Texture2D PT_Icon;

//Passive abilities of this class 
var class<Rx_PassiveAbility> PassiveAbilities[3] ; //Hold passive abilities 
var bool bHasParachute; //Generally yes

// Purchasing
static function Purchase(Rx_PRI Context) {
	local int RealCost;
	if (Available(Context) == PURCHASE_AVAILABLE) {
		// The class is purchasable
		RealCost = Cost(Context);
		if (FFloor(Context.GetCredits()) >= Cost(Context)) {
			// We have enough credits; purchase the class
			Context.RemoveCredits(RealCost);
			Context.SetChar(default.Class, Controller(Context.Owner).Pawn, RealCost == 0);
			
			// Log purchase
			`LogRxPubObject("GAME" `s "Purchase;" `s "character" `s Context.CharClassInfo.name `s "by" `s `PlayerLog(Context));
			
			// Reset Spy status
			Context.SetIsSpy(false);
		}
	}
}

static function int Cost(Rx_PRI Context) {
	return `RxGameObject.PurchaseSystem.GetClassPrice(Context.Team.TeamIndex, default.Class);
}

static function EAvailability Available(Rx_PRI Context) 
{
	if (default.bHighTier) 
	{
		if(`RxGameObject.PurchaseSystem.AreHighTierPayClassesDisabled(Context.Team.TeamIndex))
			return PURCHASE_HIDDEN;

	}
	
	return PURCHASE_AVAILABLE;
}

// Block Data
static function string Title() {
	return default.PT_Title;
}

static function string Description() {
	return default.PT_Description;
}

static function Texture Icon() {
	return default.PT_Icon;
}

static function string StrCost() {
	return string(default.BasePurchaseCost);
}


// Metadata
static function int StatType() {
	return 2;
}

static function int DamageOutOfSix() {
	return default.PT_Damage;
}

static function int RangeOutOfSix() {
	return default.PT_Range;
}

static function int RateOfFireOutOfSix() {
	return default.PT_RateOfFire;
}

static function int MagazineCapacityOutOfSize() {
	return default.PT_MagazineCapacity;
}

static function bool IsStealthUnit()
{
	return default.bIsStealth;
}

static function string BotPTString()
{
	return default.PTString;
}

/** END Rx_IPurchasable */

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



//Used to verify the client isn't sending up a VP buy request for something different. 
function static  bool VerifyVPPrice(byte Iterator,int Cost)
{
	local int VP0,VP1,VP2; //Hold our default VP values 
	
	VP0 = default.VPCost[0]; 
	VP1 = default.VPCost[1]; 
	VP2 = default.VPCost[2]; 
	
	switch(Iterator)
	{
	case 0: 
	if(Cost != VP0) return false ;  //client out of sync, update it.
	break; 
	
	case 1: 
	`log( Cost @ "Cost does not equal = " @ VP0 @ VP1-VP0); 
	if(Cost != VP1 && Cost != (VP1-VP0) ) return false ; 
	break; 
	
	case 2: 
	if(Cost != VP2 && Cost != (VP2-VP0) && Cost != VP2-VP1 ) return false ; 
	break; 
	
	default: 
	return false; 
	}
	
	return true; 
	
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
	PawnVoiceClass=class'Rx_Pawn_VoiceClass_GDI_Soldier'
	
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
	Role = ROLE_Offense
	SpeedMultiplier=1.0
	JumpMultiplier=1.0
	DamagePointsMultiplier=0.05 /*Stock, 1 point/credit per 20 damage. That puts a Rifle soldier at giving away 10 points total without a death bonus*/
	
	bHasParachute = true //True for basically every class
	
	/*Passive Abilities (3 max)*/
	PassiveAbilities(0) = none //Ability linked to 'Jump' 
	PassiveAbilities(1) = none //Ability linked to 'X' by default  	
	PassiveAbilities(2) = none //Ability linked to 'G' by default 	
	
	
	//PT Info block 
	BasePurchaseCost = 0
	bHighTier = false
	
	bFemale = false; //halo2pac

	/** one1: Default inventory manager class. */
	InvManagerClass=class'Rx_InventoryManager'
	
	/***********/
	/*Veterancy*/
	/***********/
	//Works for free infantry
	VPCost(0) = 10
	VPCost(1) = 20
	VPCost(2) = 40
	
	VPReward(0)=2
	VPReward(1)=3
	VPReward(2)=4
	VPReward(3)=6
	
	//+X
	Vet_HealthMod(0)=0
	Vet_HealthMod(1)=25
	Vet_HealthMod(2)=60
	Vet_HealthMod(3)=75
	
	//+X
	Vet_SprintSpeedMod(0)=0
	Vet_SprintSpeedMod(1)=0
	Vet_SprintSpeedMod(2)=0
	Vet_SprintSpeedMod(3)=0
	
	/******************/
	
	}
