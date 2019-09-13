/**
 * RxGame
 *
 * */
class Rx_Pawn extends UTPawn
	implements (RxIfc_ClientSideInstantHitRadius)
	implements (RxIfc_TargetedCustomName)
	implements(RxIfc_TargetedDescription)
	implements(RxIfc_RadarMarker)
	implements (RxIfc_PassiveAbility);

`include(RenX_Game\RenXStats.uci);
	
/** one1: added */
var float CameraSmoothZOffset;

var float CamStartZHeight;
var float CamStartCrouchZHeight;

/** Smoothing scale for lagged camera - higher values = shorter smoothing time. */
var float CameraSmoothingFactor;
/** Saved Camera positions (for lagging camera) */
struct native TimePosition
{
	var vector Position;
	var float Time;
};
var array<TimePosition> OldPositions;
/**  camera lag (in seconds) */
var float CameraLag;
/** Smoothed Camera Offset */
var vector CameraOffset;

var float CamLowAngleStart;
var float CamLowOffsetMax;
var float CamHighAngleStart;
var float CamHighOffsetMax;
var int CurrentCamPitch;
`define PITCH_LOWEST 15000
`define PITCH_HIGHEST 51535

/** one1: Added this here, because Attachment actors do not share common actor on server
 *  side. When this Pawn commences AS, this value will get updated so players will
 *  be able to render beam properly. */
var repnotify vector AirstrikeLocation;

/** one1: Weapons on the back. If you change size of this array, 
 *  change size of CurrentBackWeaponMeshes and BackWeaponSocketNames. */
var	repnotify class<Rx_BackWeaponAttachment> CurrentBackWeapons[5];
var Rx_BackWeaponAttachment CurrentBackWeaponComponents[5];

/** one1: Names of back sockets. */
var name BackWeaponSocketNames[5];

var SkeletalMeshComponent ParachuteMesh;
//var SkeletalMeshComponent CapeMesh; 
// All in range -1 to 1
// X: -1: full stall 1: forward
// Y: -1: Turn Left 0: straight 1:Turn Right
// Z: 1: Start undeployed 0: falling -1: finish undeployed
var vector ParachuteAnimState, TargetParachuteAnimState;
var MorphNodeWeight ParachuteLeftTurnWeight, ParachuteRightTurnWeight, ParachuteCurveWeight, ParachuteClosedWeight;
var float ParachuteManouverAnimSpeed;
var float ParachuteDeployAnimSpeed;
var float ParachuteUnDeployAnimSpeed;

var const float ParachuteDeployVelocity;
var float ParachuteDrag;
var float ParachuteDragRampUpTime;
var repnotify bool ParachuteDeployed;
var float CurrentParachuteCamDistMod;
var float ParachuteCamDistMod;
var materialInstance ParachuteGDIMat;
var materialInstance ParachuteNodMat;
var SoundCue ParachuteDeployCue;

// True if the pawn is currently repairing something.
var bool bRepairing;

//Variables for Health
var int DamageRate;
var bool bTakingDamage;
var int BleedDamageType; 			// HANDEPSILON - 0 for none, 1 for burn, 2 for Tiberium

//Enumerated values for armour types. 
enum ENUM_Armor 
{
	A_Kevlar,
	A_FLAK, 
	A_Lazurus,
	A_NONE
};

var ENUM_Armor Armor_Type;

/** Is the player climbing downward? */
var bool            bClimbDown;

// Variables for Grenades
var bool bThrowingGrenade;      // already throwing grenade yet?

// Variable for vehicle entering (allows 
var bool CanEnterVehicles;

// Anti bunny hop
var float MaxJumpZ;
var float CurrentHopStamina;
var float MinHopStamina;
var float HopCost;
var float HopRegenRate;

// Variables for sprinting
var float		Stamina;
var const float MaxStamina;

var float		SprintSpeed;
var int         StaminaCooldownTime;
var int		    ExhaustionTime;
var bool		bSprinting;
var bool		bSprintingServer;
var bool        bExhausted;
var float       SprintStaminaCost;
var float       StaminaRegenRate;
var int         JumpStaminaCost;
var int         DodgeStaminaCost;  
var bool        WasInFirstPersonBeforeDodge;
var bool        bWasInThirdPersonBeforeIronsight;

var float		WalkingSpeed;
var float		RunningSpeed;
var float       IntendedGroundSpeed;
var repnotify float       SpeedUpgradeMultiplier;
var float		SpeedUpgradeMultiplier_NonReplicated; //Used Explicitly for 
var float 		JumpHeightMultiplier; 
var float			SprintDodgeSpeed;

//Dodging
var string 				DodgeNodeName;
var AnimNodeBlendList 	DodgeNode; //Should be named 'Dive', because we're special  
var SoundCue			Snd_DodgeCue; //Dodge sound cue 
var float				DodgeCoolDownTime; //Time between dodges  

var name 		WeaponAimedToRestAnim;
var name 		WeaponSprintAnim;
var name 		WeaponRestToAimedAnim;

var AnimNodeSequence FullBodyAnimSequence; 

// Stamina & Sprinting fix
// By Triggerhippy
// RxPlayerInput now updates this value based on input, so it's accurate.
var EMoveDir moveDirection;
//-----------------

// Variables for Relaxed Stance
var bool IsRelaxed;
var float RelaxTime;
var bool bAlwaysRelaxed;
// the base name of the relax tree nodes without the numbers attached to them
var string RelaxBaseName;

// the array that holds the relax nodes so they can be cached and children changed easily 
var array<AnimNodeBlendList> RelaxedBlendLists;

// Relaxed Aim Node doesnt have any profiles and is only used when pawn is in
// realxded state.  weaponAimNode has all the aim profiles.
var	AnimNodeAimOffset RelaxedAimNode;
var	AnimNodeAimOffset WeaponAimNode;
var AnimNodeBlendBySpeed RunSpeedAnimNode;

//----------------------------------------------------------------------------
// Armor Related
//----------------------------------------------------------------------------
var int Armor;
/** note.  if MaxArmor isnot set in the defualt properties it will set MaxArmor
 *  to waht is the current Armor in the default properties */
var int ArmorMax;

var name WeaponBackSocket, WeaponC4Socket, WeaponPistolSocket;

var bool bCalculatingBleedDamage;
var bool bIsPtPawn;
var bool bPTInitialized;

/**Shahman: Variables when being being targetted*/
var bool bTargetted;
var bool bStartFirePressedButNoStopFireYet;
var bool bFocused;

/**Variables for anti cheat purposes*/
var vector LastLocation;
var float TempTime; 

struct Bleed
{
	var int Damage; // Amount of damage per tick
	var int Count; // How many ticks remaining
	var Controller EventInstigator; // Who caused the damage (for awarding kills)
	var class<DamageType> Type; // Damage type (must be different from the type that created the bleed)
	// var int NextTick; // When to apply this tick next
};

struct VoiceBlock
{
	var int	 VoiceIndex;
	var name SoundType;
	var bool bCanOverride;
};

var repnotify VoiceBlock ReplicatedVoice;

var array<Bleed> Bleeds;
var float BleedInterval; // How often to apply bleed effects

var ActorComponent BackSocketComponent, C4SocketComponent, PistolSocketComponent;

var bool bSwappedCam;
var bool bDodgeCapable;
var	vector DodgeVelocity;
var	float DodgeDuration;
var	float TimeInDodge;
var	float LastVelZInDodge;
var repnotify bool bDoingDodge;
var repnotify name ReloadAnim;
var repnotify name BoltReloadAnim;
var repnotify bool bBeaconDeployAnimating;

var int ShotgunPelletCount;
var repnotify vector ShotgunPelletHitLocations[12];
var bool bHeadshot;

var Rx_Building_Nod_Defense Obelisk;
var Rx_Building_GDI_Defense Agt;
var bool bCheckedForOb;
var bool bCheckedForAgt;
var bool bWasInIronsightBeforeAction;

var Rx_AuthenticationClient authenticationClient;

// Modifiers for rockets seeking this actor
var float SeekAimAheadModifier;
var float SeekAccelrateModifier;

var AnimNodeSequence LeftHandAnimName; //Animation to use for the left hand
var AnimNodeBlendPerBone LeftHandOverride; //Left Professional Ass-Grabbin' Kontrol!
var SkelControlSingleBone LeftHandIK_SB; //Left Professional Ass-Grabbin' Kontrol!
var SkelControlSingleBone LeftHandIK_SBR; //Left Professional Ass-Grabbin Rotational' Kontrol!
var SkelControlSingleBone RightHandIK_SB; //Right Professional Ass-Grabbin' Kontrol!
var SkelControlSingleBone RightHandIK_SBR; //Right Professional Ass-Grabbin' Rotational Kontrol!

//var bool bBlinkingName;
var byte UISymbol; 
var byte HitEnemyForDemorec;
var byte HitEnemyWithHeadshotForDemoRec;
var float LastRanInto;

/** used for 3rdperson cam interpolation during demoplayback */
var float SavedLocationZ[5];
var int SavedLocationZIter;

/*For commander targeting*/
var bool bIsTarget;
var bool bIsDefensiveTarget; 
var bool bIsAdminTarget;  

//Veterancy
var repnotify byte VRank; 
var float Vet_HealthMod[4]; //Health Increases for this vehicle as it ranks up (*X)
var float Vet_SprintSpeedMod[4]; //Sprint speed increases for this vehicle as it ranks up. (*X)

var float RegenerationRate, HeroicRegenerationRate; 
var float MaxDR; //Maximum resistance. Lower numbers are more resilient (0.0 is 100% resistance, 1.0 is no resistance)


//For determining some VP stuff
var string SpotLocation; //Updated once per SpotUpdateTime
var float SpotUpdateTime; //Time to wait between updates (in seconds)
 var float LegitamateDamage; //Store how much damage we took that was from enemy sources, and not just from jumping off of stuff
 
/*Copied from beacons*/
var float					  Damage_Taken;

/*Track who does damage to me so I can distribute points correctly on disarming*/
struct Attacker
{
	var PlayerReplicationInfo PPRI; 
	var float DamageDone; 
	var float LastDamageTime; 
};

var array<Attacker>	DamagingParties;	//Track who is doing damage to me to evenly distribute points

 //Comm Centre
var byte RadarVisibility; //Set radar visibility. 0: Invisible to all 1: visible to your team 2: visible to enemy team/ Pawn copy to replicate to all
var bool bSpotted; 

//Shadow Bounds Scale (nBab)
var DynamicLightEnvironmentComponent MyLightEnvironment; 

//Pawn Voices
var Rx_AudioComponent VoiceComponent; 
var bool		   bCanHitReact; //Used to determine if we should play a hit reaction sound

var bool		   bPlayAssistSound;
var byte 			LastPicked_KillConfirm, LastPicked_Hit, LastPicked_VKillConfirm, LastPicked_BKill, LastPicked_Assist, DeathSound; //Used in Randomization for voice sounds


//-------------Vaulting Variables
var int ClimbHeight;
var bool bVaulted;
var Rx_Weapon MyGrenade; 
var MaterialInstanceConstant CustomBuffMat; 

var byte CurrentStoredWeaponOverlayByte; //For remembering what weapon overlay we're using

var class<Rx_Weapon> PreviousWeaponClass; //Hold incase weapons need to know where they're coming from

// Vars for Transitioning between vehicle and pawn cam when entering/exiting vehicles
var vector VehiclePawnTransitionStartLoc;
var float BlendPct;
var float BlendSpeed;
var vector lastRxPawnOutCamLoc;

var Rx_PassiveAbility PassiveAbilities[3]; //What passive abilities, if any, does this pawn have? (0 = Jump / 1 = G key / 2 = X Key) 

var bool bTickHandIK; //Controls if we need to be ticking hand IK on this Pawn usually only briefly after reloads
var bool bUpdate3rdPersonEyeHeightBob;

var float DodgeBlendTime; 
var AnimNodeSequence DodgeGroupNode; //Holds a reference to the forward dodge node to signal the 'Dive' group to play
var bool bWasSprintingBeforeDodge; //Were we sprinting before we started dodging?

var vector DodgeCameraOffset; 
var float  DodgeCameraZOffset;

//-----------------------------------------------------------------------------
// Pawn control
//-----------------------------------------------------------------------------

replication
{
	if ( bNetDirty)
		Armor, ArmorMax, CurrentBackWeapons, AirstrikeLocation, SpeedUpgradeMultiplier, Armor_Type, JumpHeightMultiplier, bIsTarget, VRank, RadarVisibility, bSpotted, bFocused, ReplicatedVoice; 
	if ( bNetDirty && (!bNetOwner || bDemoRecording))
		bDoingDodge, ReloadAnim, BoltReloadAnim, ParachuteDeployed, bRepairing, bBeaconDeployAnimating, UISymbol, bSprintingServer; //bBlinkingName
	// Only replicate if our current weapon is a shotgun. Otherwise this is irrelivant.
	if ( bNetDirty && (!bNetOwner || bDemoRecording) && RemoteRole == ROLE_SimulatedProxy && Rx_Weapon_Shotgun(Weapon) != none)
		ShotgunPelletHitLocations;
	if ( bNetDirty && bDemoRecording )
		HitEnemyForDemorec, HitEnemyWithHeadshotForDemoRec;		
}


simulated event PreBeginPlay()
{
	
	// important that this comes before Super so mutators can modify it
	if (ArmorMax == 0)
	{
		ArmorMax = default.Armor;
	}
	
	//Armor = GetShieldStrength();
	super.PreBeginPlay();
	SpawnSound.VolumeMultiplier=0.0;
	TeleportSound.VolumeMultiplier=0.0;
	IntendedGroundSpeed = RunningSpeed;
}

simulated function PostBeginPlay()
{  
	super.PostBeginPlay();
	
	
	//set shadow frustum scale (nBab)
	SetShadowBoundsScale();

	// Start the relax timer when the pawn spawns
	SetTimer( 0.5, false, 'RelaxTimer' );
	SetHandIKEnabled(false);
	ParachuteMesh.SetLightEnvironment(LightEnvironment);
	if(WorldInfo.NetMode == NM_DedicatedServer)
	{
		SetTimer( 1.0, true, 'CheckLoc' );
		
		bAlwaysRelevant = Rx_Game(WorldInfo.Game).bInfantryAlwaysRelevant; 
		
		if(!bAlwaysRelevant) SetTimer(0.1,true,'UpdatePRILocation'); 
		//SetTimer(2.0,true,'TestVisAct');
	}	
		SetTimer(SpotUpdateTime,true,'UpdateSpotLocation');
}

//set shadow frustum scale (nBab)
simulated function SetShadowBoundsScale()
{
	MyLightEnvironment = DynamicLightEnvironmentComponent(Mesh.LightEnvironment);
	MyLightEnvironment.LightingBoundsScale = Rx_MapInfo(WorldInfo.GetMapInfo()).CharacterShadowBoundsScale;
	Mesh.SetLightEnvironment(MyLightEnvironment);
}

function CheckLoc()
{
	if(VSizeSq(location - LastLocation) > 64)
	{
		TempTime = WorldInfo.TimeSeconds;
		
	}
	LastLocation = location;
}

function UpdatePRILocation()
{
	//`log("Update Location"); 
	if(Controller != none && DrivenVehicle == none)
		Rx_PRI(Controller.PlayerReplicationInfo).UpdatePawnLocation(location,rotation,velocity); 
	else
		if(Controller != none && DrivenVehicle !=none)
			Rx_PRI(Controller.PlayerReplicationInfo).UpdatePawnLocation(DrivenVehicle.location,DrivenVehicle.rotation, DrivenVehicle.velocity); 
}

function SetRadarVisibility(byte Visibility)
{
	RadarVisibility = Visibility;
	if(Controller != none)
		Rx_PRI(Controller.PlayerReplicationInfo).PawnRadarVis = Visibility;
}

simulated function SendRadarSpotted()
{
	if(WorldInfo.NetMode != NM_DedicatedServer) 
	{
		ServerSetRadarSpotted(); 
	}
} 

reliable server function ServerSetRadarSpotted()
{
	if(Rx_Controller(Controller) != none )
	{
		Rx_Controller(Controller).SetSpottedRadarVisibility();
	}
	else
	if(Rx_Bot(Controller) != none )
	{
		Rx_Bot(Controller).SetSpottedRadarVisibility();
	}
}

simulated function ClientReStart()
{
	super.ClientReStart();
	if(Rx_Controller(Controller) != None) {
		Rx_Controller(Controller).SetOurCameraMode(Rx_Controller(Controller).camMode);
	}
}

simulated function UpdateSpotLocation()
{
	local string STS; 
	if(Rx_Controller(Controller) == none || Rx_Bot(Controller) == none)
	{
		ClearTimer('UpdateSpotLocation'); //Don't keep updating. 
		return;
	}
	
	STS = GetPawnLocation(self);
	SpotLocation = STS; 
	ServerSendLocationInfo(STS);  
}

reliable server function ServerSendLocationInfo(coerce string STR)
{
	SpotLocation = STR; 
}

simulated function MakeHumanCharInvisibleToBots() {
	if(PlayerController(Controller) != None) {
		SetInvisible(true);
	}	
}

simulated event ReplicatedEvent(name VarName)
{
	local int i;
	
	if ( VarName == 'bDoingDodge' ) 
	{
		if(bDoingDodge) {
			DodgeGroupNode.PlayAnim(false, 1.0, 0.0);
			DodgeNode.SetActiveChild(1,0.2);
		} 
		else 
		{
			DodgeNode.SetActiveChild(0,0.5);
		}
	} 
	else if (VarName == 'bBeaconDeployAnimating')
	{
		if (bBeaconDeployAnimating)
		{
			PlayBeaconDeployAnimation();
			SetHandIKEnabled(false);
		}
		else
		{
			CancelBeaconDeployAnimation();
			SetHandIKEnabled(true);
		}
	}
	else if ( VarName == 'ReloadAnim' ) 
	{
		if(ReloadAnim != '')
		{
			SetHandIKEnabled(false);
			TopHalfAnimSlot.PlayCustomAnim( ReloadAnim, 1.0, 1.0, 1.0, false, true );		
		}
		else 
		{
			TopHalfAnimSlot.StopCustomAnim(1.0);
			SetHandIKEnabled(true);
			ResetHandIKVectorRotator();
			bTickHandIK = true; 
		}		
	} 
	else if ( VarName == 'BoltReloadAnim' ) 
	{
		if(BoltReloadAnim != '')
		{
			SetHandIKEnabled(false);
			TopHalfAnimSlot.PlayCustomAnim( BoltReloadAnim, 1.0, 1.0, 1.0, false, true );		
		}
		else 
		{
			TopHalfAnimSlot.StopCustomAnim(1.0);
			SetHandIKEnabled(true);
			ResetHandIKVectorRotator();
			bTickHandIK = true; 
		}		
	} 
	else if( VarName == 'FlashLocation' )	
	{ 
		if(Rx_Attachment_Shotgun(CurrentWeaponAttachment) == None) 
		{ // Shotgun Effects are instead generated in Rx_Weapon.InstantFire()
			FlashLocationUpdated(Weapon, FlashLocation, TRUE);
		}
	}
	else if ( VarName == 'ShotgunPelletHitLocations' ) 
	{
		for(i = 0; i < 12; i++) 
		{
			FlashLocationUpdated(None, ShotgunPelletHitLocations[i], True);
		}
	}
	else if (Varname == 'ParachuteDeployed')
	{
		if(ParachuteDeployed)
		{
			ActualDeployParachute();
		}
		else
		{
			ActualPackParachute();
		}
	}
	/** one1: Added; this gets replicated to all relevant players. */
	else if (Varname == 'CurrentBackWeapons')
	{
		RefreshBackWeapons();
	}
	else if (VarName == 'AirstrikeLocation') 
	{
		/** one1: Added: On updated AirstrikeLocation, spawn beam on currently attached weapon. */
		if (Rx_Attachment_Airstrike(CurrentWeaponAttachment) != none)
		{
			if (AirstrikeLocation == vect(0, 0, 0))
				Rx_Attachment_Airstrike(CurrentWeaponAttachment).DestroyBeam();
			else
				Rx_Attachment_Airstrike(CurrentWeaponAttachment).SpawnBeam(AirstrikeLocation);
		}
	}
	else if (VarName == 'SpeedUpgradeMultiplier')
	{
		UpdateRunSpeedNode();
	}
	else
	if ( VarName == 'VRank')
	{
		
		if(Rx_Controller(Controller) != none ) Rx_Controller(Controller).ClientUpdateVPMenu(true); //Tell controller to update the menu if VRank changed
		if(Vrank == 3 && Rx_WeaponAttachment_Varying(CurrentWeaponAttachment) != none ) Rx_WeaponAttachment_Varying(CurrentWeaponAttachment).SetHeroic(true); 
		SetGroundSpeed();
		UpdateRunSpeedNode();
	}
	else
		if(VarName == 'bIsTarget')
		{
			if(bIsTarget) SetTargetAlarm(25);
		}
	else
		if(VarName == 'ReplicatedVoice')
		{
			//`log("Replicated Voice"); 
			if(ReplicatedVoice.SoundType != 'NULL')
				PlayVoiceSound(ReplicatedVoice.SoundType, 
			ReplicatedVoice.bCanOverride, ReplicatedVoice.VoiceIndex) ;
		}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

/** one1: Added. */
simulated function RefreshBackWeapons()
{
	if (Role == ROLE_Authority)
	{
		// server side (or SP mode)
		// check for non-visible weapons and put classes into CurrentBackWeapons array
		Rx_InventoryManager(InvManager).GetHiddenWeaponAttachmentClasses(CurrentBackWeapons);

		// if we are dedicated server, we did enough already
		if (WorldInfo.NetMode == NM_DedicatedServer) return;
	}

	RefreshBackWeaponComponents();
}

/** one1: Added. */
simulated function RefreshBackWeaponComponents()
{
	local int i;

	for (i = 0; i < ArrayCount(CurrentBackWeapons); i++)
	{
		if (CurrentBackWeapons[i] == none)
		{
			// if currently something is attached, detach it
			if (CurrentBackWeaponComponents[i] != none)
			{
				Mesh.DetachComponent(CurrentBackWeaponComponents[i]);
				DetachComponent(CurrentBackWeaponComponents[i]);
				CurrentBackWeaponComponents[i] = none;
			}

			continue;
		}

		// if something is attached, detach first
		if (CurrentBackWeaponComponents[i] != none)
		{
			// if already attached, skip
			if (CurrentBackWeaponComponents[i].Class == CurrentBackWeapons[i])
				continue;

			// else detach first
			Mesh.DetachComponent(CurrentBackWeaponComponents[i]);
			DetachComponent(CurrentBackWeaponComponents[i]);
		}

		// attach
		CurrentBackWeaponComponents[i] = new(self) CurrentBackWeapons[i];
		CurrentBackWeaponComponents[i].SetShadowParent(Mesh);
		CurrentBackWeaponComponents[i].SetLightEnvironment(LightEnvironment);
		AttachComponent(CurrentBackWeaponComponents[i]);
		Mesh.AttachComponentToSocket(CurrentBackWeaponComponents[i], BackWeaponSocketNames[i]);
	}
}




/** on1: Overriden to clean backweapons. */
simulated event Destroyed()
{
	local int i;

	for (i = 0; i < ArrayCount(CurrentBackWeapons); i++)
	{
		if (CurrentBackWeaponComponents[i] != none)
		{
			Mesh.DetachComponent(CurrentBackWeaponComponents[i]);
			DetachComponent(CurrentBackWeaponComponents[i]);
			CurrentBackWeaponComponents[i] = none;
		}
	}

	// Clear blend weight references
	ParachuteLeftTurnWeight = none;
	ParachuteRightTurnWeight = none;
	ParachuteCurveWeight = none;
	ParachuteClosedWeight = none;
	
	super.Destroyed();
}

simulated function class<Rx_FamilyInfo> GetRxFamilyInfo()
{
	local class<Rx_FamilyInfo> famInfo;
	famInfo = class<Rx_FamilyInfo>(self.CurrCharClassInfo);
	
	if(famInfo == None) return class'Rx_FamilyInfo_GDI_Soldier' ;
	
	return famInfo;
}


simulated function ResetCharPhysState()
{
	super.ResetCharPhysState();
	ClearTimer('RelaxTimer');
	SetHandIKEnabled(false);
	Relax(true);
}


/**
 * Overloaded UTPawn.StartFeignDeathRecoverAnim() to disable cylinder collision and re-enable mesh collision.
 * 
 * @author     triggerhippy
 * @since      2011-10-12
 * 
 */
simulated event StartFeignDeathRecoveryAnim()
{
	//Execute UTPawns recovery 
	super.StartFeignDeathRecoveryAnim();
	
	//Re-enable mesh collision in addition to cylinder
	//REMOVED: CylinderComponent.SetActorCollision(false, false);
	Mesh.SetActorCollision(true, true);
	Mesh.SetTraceBlocking(true, true);
}

simulated function DelayRegen()
{
	bTakingDamage = false;
	HealthRegen();
}

simulated function HealthRegen()
{
	if (!bTakingDamage)
	{
		SetTimer(0.1, true, 'RegenTimer');
	}
}

function RegenTimer()
{	
	if (Controller != none && Controller.IsA('PlayerController') && !IsInPain() && DamageRate > 0)
	{
		DamageRate = fMax(0,DamageRate-5);
	}
	else
	ClearTimer('RegenTimer');
}

/* Add a bleed to the current player
 * TO CONSIDER:
 *  - Should allow multiple damage types per instigator?
 *  - Should track individual effect times? Players not likely to notice...
 */
function AddBleed(float Damage, int Count, Controller EventInstigator, class<DamageType> Type)
{
	local Bleed newBleed;
	local int i;
	for (i=0;i<Bleeds.Length;i++)
	{
		// Go with the most damaging bleed
		if (EventInstigator == Bleeds[i].EventInstigator && Type == Bleeds[i].Type)
		{
			if (Damage >= Bleeds[i].Damage)
				Bleeds[i].Damage = Damage;
			Bleeds[i].Count = Count;
			return;
		}
	}
	// Instigator does not already have a bleed
	newBleed.Damage = Damage;
	newBleed.Count = Count;
	newBleed.EventInstigator = EventInstigator;
	newBleed.Type = Type;
	Bleeds.AddItem(newBleed);
	if (Bleeds.Length == 1)
	{
		// Don't set timer if already set -- does this matter?
		SetTimer(BleedInterval, true, 'DoBleed');
	}
}

/* Process bleed effects on the current player */
function DoBleed()
{
	local int i;
	for (i=0; i<Bleeds.Length; i++)
	{
		bCalculatingBleedDamage = true;
		self.TakeDamage(Bleeds[i].Damage, Bleeds[i].EventInstigator, vect(0,0,0), vect(0,0,0), Bleeds[i].Type,,self);
		bCalculatingBleedDamage = false;
		Bleeds[i].Count--;
		if (Bleeds[i].Count == 0)
		{
			Bleeds.Remove(i,1);
		}
	}
	if (Bleeds.Length == 0)
	{
		ClearTimer('DoBleed');
	}
}

function bool GiveArmor(int ArmorAmount)
{
	if (Armor < ArmorMax)
	{
		Armor = Min(ArmorMax, Armor + ArmorAmount);
		return true;
	}
	return false;
}

event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local int ActualDamage;
	local int ScoreDamage;
	local int ArmorTemp;
	local int BleedDamage;
	local PlayerController PC;
	local Controller Killer;
	local Controller Killed;
	local class<Rx_DmgType_Special> DmgType;
	local float Scr;
	local string DeathVPString; 
	local int InstigatorIndex;
	local Attacker TempAttacker;
	local Attacker PRII;
	local float TempAssistPoints; 
	local Controller C; 
	local int	SavedHealth, SavedArmour; 
	local Rx_PRI InstigatorPRI; 
	
	//`log("Took Damage"); 
		
	if(EventInstigator != none && !ValidRotation(EventInstigator, DamageCauser)) {
		return;	
	}
	
	if ( (Role < ROLE_Authority) || (Health <= 0) || GetRxFamilyInfo().static.IsImmuneTo(DamageType))
	{
		bHeadshot = false;
		return;
	}	

	if ( DamageType == None )
	{
		if ( EventInstigator == None )
			`warn("No damagetype for damage with no instigator");
		else
			`warn("No damagetype for damage by "$EventInstigator.Pawn$" with weapon "$EventInstigator.Pawn.Weapon);
		DamageType = class'DamageType';
	}
	
	if(Damage < 0) 
	{
		Damage = 0;
	}

	if(Rx_Controller(EventInstigator) != None && GetTeamNum() != EventInstigator.GetTeamNum()) {
		if(Rx_Projectile_Rocket(DamageCauser) != None && Rx_Controller(EventInstigator) != None && GetTeamNum() != EventInstigator.GetTeamNum()) { 
			Rx_Controller(EventInstigator).IncReplicatedHitIndicator();
			
		}
	}
	
	if (Physics == PHYS_None && DrivenVehicle == None)
	{
		SetMovementPhysics();
	}
	if (Physics == PHYS_Walking && DamageType.default.bExtraMomentumZ)
	{
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
	}
	
	momentum = momentum/Mass;

	if ( DrivenVehicle != None )
	{
		DrivenVehicle.AdjustDriverDamage( Damage, EventInstigator, HitLocation, Momentum, DamageType );
	}

	ActualDamage = Damage;
	WorldInfo.Game.ReduceDamage(ActualDamage, self, EventInstigator, HitLocation, Momentum, DamageType, DamageCauser);

	//reduce damage based on armor... Editted for infantry armour.
	if(!bHeadshot) 
	{
		AdjustDamage(ActualDamage, Momentum, EventInstigator, HitLocation, DamageType, HitInfo, DamageCauser );
	}
	

	// Controller is set to None by Actor.TakeDamage
	Killed = Controller;

	// call Actor's version to handle any SeqEvent_TakeDamage for scripting
	Super(Actor).TakeDamage(ActualDamage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	// FIXME:: Need to tweak damage and count (maybe even specify in the DamageType)
	if (ClassIsChildOf(DamageType, class'Rx_DmgType_Special'))
	{
		DmgType = class<Rx_DmgType_Special>(DamageType);
		if (DmgType.default.bCausesBleed)
		{
			BleedDamage = Damage;
			if(bHeadshot) {
				BleedDamage = BleedDamage/5.0;
			}
			// Bleed is a separate damage type so it does not feedback loop
			AddBleed(DmgType.default.BleedDamageFactor*BleedDamage, DmgType.default.BleedCount, EventInstigator, DmgType.default.BleedType);
		}
	}

	//Save health and armor pre-change for later
	SavedHealth = Health; 
	SavedArmour = Armor; 
	
	// When Taking Falling Damage Armor is not Useful
	// Also water (drowning damage) is not useful to armor - halo2pac
	if ( DamageType == class'Rx_DmgType_Fell' || DamageType == class'Rx_DmgType_Drowned' || DmgType != none && DmgType.default.bPiercesArmor)
	{
		Health -= ActualDamage;
	}
	else
	{
		ArmorTemp = Armor - ActualDamage;
		if( ArmorTemp < 0 )
		{
			Armor = 0;
			ArmorTemp *= -1;
			Health -= ArmorTemp;
		}
		else
		{
			Armor = ArmorTemp;
		}
	}

	if (HitLocation == vect(0,0,0))
	{
		HitLocation = Location;
	}

	if ( Health <= 0 )
	{
		PC = PlayerController(Controller);
		// play force feedback for death
		if (PC != None)
		{
			PC.ClientPlayForceFeedbackWaveform(damageType.default.KilledFFWaveform);
		}

		/**
		//---
		//Death Physics Tweak
		//By Triggerhippy

		//Apply momentum to dead pawn
		HandleMomentum( momentum, HitLocation, DamageType, HitInfo );
		
		//Make him go flying
		ForceRagdoll();
		//---
		*/
		// pawn died
		
		
		
		Killer = SetKillInstigator(EventInstigator, DamageType);

		if(EventInstigator != none && EventInstigator == controller && LastHitBy != none)
			Killer = SetKillInstigator(LastHitBy, DamageType); //Suiciding with explosives still gives the kill to whoever hit last. 
		
		TearOffMomentum = momentum;
		
		
		if(bIsTarget || bIsDefensiveTarget) ClientNotifyTargetKilled();
		
		//Clear out those who who haven't attacked us in the last 10 seconds
		foreach DamagingParties(PRII)
		{
			if(WorldInfo.TimeSeconds - PRII.LastDamageTime >= 10.0) 
			{
				Damage_Taken-=PRII.DamageDone; //Rid yourselves of irrelevant excessive damage
				DamagingParties.RemoveItem(PRII);
			}
		continue;
		}
		
		//Divi out assist points to those who didn't get the kill
		foreach DamagingParties(PRII)
		{
		if(PRII.PPRI != none)
			{
			if(PRII.DamageDone >= 50 && EventInstigator != none && PRII.PPRI.Owner != EventInstigator) 
				{
					C=Controller(PRII.PPRI.Owner); 
					//`log(PRII.PPRI.Owner @ EventInstigator @ PRII.DamageDone); 
					TempAssistPoints =fmax(1, GetRxFamilyInfo().default.VPReward[VRank]*(PRII.DamageDone/Damage_Taken)); // at least one point
					TempAssistPoints=fmax(1,TempAssistPoints+BuildAssistVPString(C));
			
					if(Rx_Controller(C) != none ) {
						Rx_Controller(C).DisseminateVPString("[Infantry Kill Assist]&" $ TempAssistPoints $ "&");
						if(Rx_Pawn(C.Pawn) != none) Rx_Pawn(C.Pawn).PlayVoiceSound('Assist', false);
					}
					else
					if(Rx_Bot(C) != none ) {
						Rx_Bot(C).DisseminateVPString("[Infantry Kill Assist]&" $ TempAssistPoints $ "&"); 
						if(Rx_Pawn(C.Pawn) != none) Rx_Pawn(C.Pawn).PlayVoiceSound('Assist', false);
					}
				}
			}
		}
		
		//Give points to vehicle healers 
		if(Killer != none && Rx_Vehicle(Killer.Pawn) != none)
			Rx_Vehicle(Killer.Pawn).HealerKillAssistBonus(class'Rx_VeterancyModifiers'.default.Ev_InfantryRepairKillAssists);		
		
		if(EventInstigator == none)
		{
			//Skip everything and just go to being dead
				PlayVoiceSound('Death', true) ;
				Died(Killer, DamageType, HitLocation);
		}
		
		//Get VP modifiers and build the string to go along with it

		if(Rx_Defence_Controller(Killer) != none) //Just give defences VP, nothing else
		{
			Rx_Defence_Controller(Killer).GiveVeterancy(GetRxFamilyInfo().default.VPReward[VRank]);	
		}
		
		if(EventInstigator != none && RX_PRI(EventInstigator.PlayerReplicationInfo) != none)
		{
			DeathVPString = BuildDeathVPString(Killer, DamageType, bHeadshot);
		
			if(Rx_Controller(EventInstigator) != None && GetTeamNum() != EventInstigator.GetTeamNum()) Rx_Controller(EventInstigator).DisseminateVPString(DeathVPString); 
			else
			if(Rx_Bot(EventInstigator) != None && GetTeamNum() != EventInstigator.GetTeamNum()) Rx_Bot(EventInstigator).DisseminateVPString(DeathVPString); 
		}
		
		if(Killer != none && Rx_Pawn(Killer.Pawn) != none && (DamageType != class'Rx_DmgType_ProxyC4' && DamageType !=class'Rx_DmgType_TimedC4' )) 
		{
			Rx_Pawn(Killer.Pawn).SetTimer(1.5,false,'PlayKillConfirmTimer');
		
		}
		else if(Killer != none && Rx_Vehicle(Killer.Pawn) != none && Rx_Pawn( Rx_Vehicle(Killer.Pawn).Driver) != none && (DamageType != class'Rx_DmgType_ProxyC4' && DamageType !=class'Rx_DmgType_TimedC4' ))
		{
			//`log("Pawn Driver is" @ Rx_Pawn( Rx_Vehicle(Killer.Pawn).Driver) );
			Rx_Pawn( Rx_Vehicle(Killer.Pawn).Driver).SetTimer(1.5,false,'PlayKillConfirmTimer');	
		}			
		
		PlayVoiceSound('Death', true) ;
		Died(Killer, DamageType, HitLocation);
		SetRadarVisibility(0); 
		ClearPassiveAbilities();
	}
	else
	{
		
		NotifyTakeHit(EventInstigator, HitLocation, ActualDamage, DamageType, Momentum, DamageCauser);
		if (DrivenVehicle != None)
		{
			DrivenVehicle.NotifyDriverTakeHit(EventInstigator, HitLocation, actualDamage, DamageType, Momentum);
		}
		if ( EventInstigator != None && EventInstigator != controller )
		{
			
			LastHitBy = EventInstigator;
			if(isTimerActive('ResetLastHit')) ClearTimer('ResetLastHit');
			SetTimer(10.0, false, 'ResetLastHit'); 
		}
	}

	if(InGodMode())
		DamageRate = 0;

	if(class<Rx_DmgType_Burn>(DamageType) != None || class<Rx_DmgType_Electric>(DamageType) != None)
		BleedDamageType=1;
	else if(class<Rx_DmgType_Tiberium>(DamageType) != None)
		BleedDamageType=2;
	else
		BleedDamageType=0;
		
	DamageRate += ActualDamage * 4;
	Clamp(DamageRate,0,100);

	if ( DamageRate > 0)
	{
		bTakingDamage = true;
		SetTimer(0.5, false, 'DelayRegen');
	}

	if (EventInstigator != none)
	{
		if(EventInstigator.GetTeamNum() != GetTeamNum() && bTakingDamage && bCanHitReact && DrivenVehicle == none && Health > 0) 
			PlayVoiceSound('Damage', true) ;
		
		// add score (or sub, if bIsFriendlyFire is on)
		if(!EventInstigator.IsA('SentinelController') && EventInstigator.PlayerReplicationInfo != None)
		{
			ScoreDamage = ActualDamage;
			if(Health < 0)
				ScoreDamage += Health; // so that if he already was nearly dead, we dont get full score
			if(ScoreDamage < 0)
				ScoreDamage = 0;
				
			Scr = ScoreDamage * class<Rx_FamilyInfo>(CurrCharClassInfo).default.DamagePointsMultiplier;							
			
			if (((Killed == None && GetTeamNum() != EventInstigator.GetTeamNum()) || Killed.GetTeamNum() != EventInstigator.GetTeamNum()) && Rx_PRI(EventInstigator.PlayerReplicationInfo) != None)
			{
				InstigatorPRI = Rx_PRI(EventInstigator.PlayerReplicationInfo);
				
				LegitamateDamage+=ActualDamage;
				
				if(InstigatorPRI.bUseLegacyScoreSystem)
						InstigatorPRI.AddScoreToPlayerAndTeam(Scr);
					else
					{
						InstigatorPRI.AddScoreToPlayerAndTeam(Scr);
						InstigatorPRI.AddInfantryDamage(ScoreDamage);
					}
				
				
				
				/*Now track who's doing the damage if it's legit*/
				InstigatorIndex=DamagingParties.Find('PPRI',EventInstigator.PlayerReplicationInfo);
				if(InstigatorIndex == -1)  //New damager
				{
					TempAttacker.PPRI=EventInstigator.PlayerReplicationInfo;
					
					TempAttacker.DamageDone = Min(ActualDamage,SavedHealth+SavedArmour);
					
					TempAttacker.LastDamageTime = WorldInfo.TimeSeconds; 
					
					Damage_Taken+=TempAttacker.DamageDone; //Add this damage to the total damage taken.
					
					DamagingParties.AddItem(TempAttacker) ;
				
				}
				else
				{
					
					if(ActualDamage <= float(SavedHealth+SavedArmour))
					{
						DamagingParties[InstigatorIndex].DamageDone+=ActualDamage;
						Damage_Taken+=ActualDamage; //Add this damage to the total damage taken.
						DamagingParties[InstigatorIndex].LastDamageTime = WorldInfo.TimeSeconds; 
					}
					else
					{
						DamagingParties[InstigatorIndex].DamageDone+=SavedHealth+SavedArmour;
						DamagingParties[InstigatorIndex].LastDamageTime = WorldInfo.TimeSeconds; 					
						Damage_Taken+=SavedHealth; //Add this damage to the total damage taken.
					}
				}
			}
		}
	}

	//Rx_Controller(Controller).InitDamagePPC();
	//ScriptTrace();
	
	PlayHit(actualDamage,Controller, hitLocation, DamageType, Momentum, HitInfo);
	MakeNoise(1.0);
	//loginternal(actualDamage);
	bHeadshot = false;

	if(Rx_Game(WorldInfo.Game).GameplayEventsWriter != none)
	{
		if(EventInstigator != none && Controller != none)
		{
			`RecordDamage(WEAPON_DAMAGE, EventInstigator, DamageType, Controller, Damage_Taken);
		}
		else if(Controller != none)
			`RecordDamage(DAMAGE, Controller, DamageType, Controller, Damage_Taken);

		if(ClassIsChildOf(DamageType, class'Rx_DmgType_Tiberium'))
			 `RecordDamage(DAMAGE_TIBERIUM, Controller, DamageType, Controller, Damage_Taken);
	}
}

function bool ValidRotation(Controller EventInstigator, Actor DamageCauser)
{
	local rotator TempRotator;
	local rotator TempRotator2;
	
	if(WorldInfo.NetMode == NM_DedicatedServer  
		&& Rx_Controller(EventInstigator) != None 
		&& Rx_Pawn(EventInstigator.Pawn) != None
		&& (WorldInfo.TimeSeconds - Rx_Pawn(EventInstigator.Pawn).TempTime) > 10.0 
		&& Rx_Pawn(EventInstigator.Pawn).health > 0)
		{
			TempRotator = rotator(self.location - EventInstigator.Pawn.location);		
			TempRotator2 = EventInstigator.Pawn.rotation;
			while ( abs(TempRotator.Yaw - TempRotator2.yaw) > 32768 ) {
				if ( TempRotator.yaw > TempRotator2.yaw ) {
					TempRotator.yaw = TempRotator.Yaw - 65536;
				} else {
					TempRotator.yaw = TempRotator.Yaw + 65536;
				}
			}
			
			if(Rx_Weapon(DamageCauser) != None 
				&& Rx_Weapon(DamageCauser).bInstantHit
				&& abs(TempRotator.Yaw - EventInstigator.Pawn.rotation.Yaw) > 1000)
			{
				return false;
			}
			else if(Rx_Weapon(DamageCauser) != None 
				&& Rx_Weapon(DamageCauser).UsesClientSideProjectiles(0)
				&& abs(TempRotator.Yaw - EventInstigator.Pawn.rotation.Yaw) > 3000)
			{
				return false;
			}
		}	
	return true;
}

function AdjustDamage(out int InDamage, out vector Momentum, Controller InstigatedBy, vector HitLocation, class<DamageType> DamageType, TraceHitInfo HitInfo, Actor DamageCauser)
{
	local float FinalResistance;
	//Editted for RenX armor system. Armor reduces/increases damage so long as it's up. 	
	
	//`log("Damage Type in AdjustDamage():" @ DamageType );
	//Even if they only have 1 armor left, the damage is reduced. 
	
	FinalResistance = 1.0 ;
	
	if(Armor > 0 && class<Rx_DmgType>(DamageType) != none )
	{
		switch(Armor_Type)
		{
			case A_Kevlar :
			//InDamage*=class<Rx_DmgType>(DamageType).static.KevlarDamageScalingFor();
			FinalResistance -= (1.0 - class<Rx_DmgType>(DamageType).static.KevlarDamageScalingFor());
			break; 
			
			case A_FLAK :
			//InDamage*=class<Rx_DmgType>(DamageType).static.FLAKDamageScalingFor(); 
			FinalResistance -= (1.0 - class<Rx_DmgType>(DamageType).static.FLAKDamageScalingFor());
			break; 
			
			case A_Lazurus : 
			//InDamage*=class<Rx_DmgType>(DamageType).static.LazarusDamageScalingFor();
			FinalResistance -= (1.0 - class<Rx_DmgType>(DamageType).static.LazarusDamageScalingFor());
			break;
			
			case A_NONE : 
			//InDamage*=class<Rx_DmgType>(DamageType).static.NoArmourDamageScalingFor() ; 
			FinalResistance -= (1.0 - class<Rx_DmgType>(DamageType).static.NoArmourDamageScalingFor());
			break;
		
		}
	}
	
	FinalResistance -= (1.0 - fmax(GetResistanceModifier(), MaxDR)) ;
	//Adjusted damage for random buffs/nerfs
	
	InDamage*=fmax(0.01, FinalResistance);  //GetResistanceModifier(); 
	
	////UT3 call////
	super.AdjustDamage(InDamage, Momentum, InstigatedBy, HitLocation, DamageType, HitInfo, DamageCauser);
	
}

function string BuildDeathVPString(Controller Killer, class<DamageType> DamageType, bool Headshot)
{
	local string VPString;
	local int IntHolder; //Hold current number we'll be using 
	local int KillerVRank; 
	local float BaseVP;
	//local class<Rx_Vehicle> Killer_VehicleType; 
	local class<Rx_FamilyInfo> Victim_FamInfo;//Killer_FamInfo
	local string Killer_Location, Victim_Location; 
	local bool  KillerisPawn; //KillerisVehicle KillerInBase, KillerInEnemyBase, VictimInBase, VictimInEnemyBase, 
	local Rx_PRI KillerPRI; 
	local bool	bNeutral; //Only set to false if this is Offensive or Defensive 
	//Remember that -I- am the victim here
	//Begin by finding WHAT we are
	
	//if(Killer == none) return ""; 
	
	if((Rx_Controller(Killer) == none && Rx_Bot(Killer) == none)) return ""; 
	
	Victim_FamInfo=GetRxFamilyInfo();

	KillerPRI = Rx_PRI(Killer.PlayerReplicationInfo) ;
	
	bNeutral = true; 
	
	if(Rx_Vehicle(Killer.Pawn) != none ) //I got shot by a vehicool  
	{
		//KillerisVehicle = true; 
		//Killer_VehicleType = class<Rx_Vehicle>(Killer.Pawn.class); Shouldn't really come into play.
		//Get Veterancy Rank
		KillerVRank = Rx_Vehicle(Killer.Pawn).GetVRank(); 

	}
	else 
	//They're a Pawn, Harry
	if(Rx_Pawn(Killer.Pawn) != none )
	{
		KillerisPawn = true; 
		//Killer_FamInfo = Rx_Pawn(Killer.Pawn).GetRxFamilyInfo();
		//Get Veterancy Rank
		KillerVRank = Rx_Pawn(Killer.Pawn).GetVRank(); 
	}
	
	/*Finding location info*/ 
	
	IntHolder=Killer.GetTeamNum(); 

	Killer_Location = GetPawnLocation(Killer.Pawn); 
	
	IntHolder=GetTeamNum(); 
	
	Victim_Location = GetPawnLocation(self); 
	
	/*End Getting location*/
	
	//VP count starts here. 
	BaseVP = Victim_FamInfo.default.VPReward[VRank]; 
	
	VPString = "[Infantry Kill]&+" $ BaseVP $ "&" ; 
	
	//Are THEY defending a beacon 
	
	if(NearEnemyBeacon()) //If we're near an enemy beacon 
	{
		IntHolder = class'Rx_VeterancyModifiers'.default.Mod_BeaconDefense;	
			
		BaseVP+=IntHolder;
		
		if(KillerPRI != none)
			KillerPRI.AddBeaconKill(); 
		
		VPString = VPString $ "[Beacon Defence]&+" $ IntHolder $ "&";
	} 
		
		//Are WE defending an enemy beacon?
		
	if(NearFriendlyBeacon()) //If we're near a friendly beacon 
	{
		IntHolder = class'Rx_VeterancyModifiers'.default.Mod_BeaconAttack;	
			
		BaseVP+=IntHolder;
		
		VPString = VPString $ "[Beacon Offence]&+" $ IntHolder $ "&";
	} 
	
	if(IHaveABeacon() ) //If we were carrying a beacon 
	{
		IntHolder = class'Rx_VeterancyModifiers'.default.Mod_BeaconHolderKill;	
			
		BaseVP+=IntHolder;
		
		VPString = VPString $ "[Beacon Prevention]&+" $ IntHolder $ "&";
	} 
	
	if(Headshot) //If we got headshot-ed
	{
		IntHolder = class'Rx_VeterancyModifiers'.default.Mod_Headshot;	
			
		BaseVP+=IntHolder;
		
		VPString = VPString $ "[HEADSHOT]&+" $ IntHolder $ "&";
	} 
		
	if(KillerisPawn && IsSniper() ) //If we're a sniper class
	{
		IntHolder = class'Rx_VeterancyModifiers'.default.Mod_SniperKilled;	
			
		BaseVP+=IntHolder;
		
		VPString = VPString $ "[Sniper Killed]&+" $ IntHolder $ "&";
	} 
		
	if(WasSniper(Killer) ) //If we're a sniper class
	{
		IntHolder = class'Rx_VeterancyModifiers'.default.Mod_SniperKill;	
			
		BaseVP+=IntHolder;
		
		VPString = VPString $ "[Sniper Kill]&+" $ IntHolder $ "&";
	} 
		
	if(VRank > KillerVRank ) //Ya' done got fucked, son  [Negative Modifiers] (Leave out the '+') 
	{
		IntHolder = class'Rx_VeterancyModifiers'.default.Mod_Disadvantage*(VRank - KillerVRank);	
			
		BaseVP+=IntHolder;
		
		VPString = VPString $ "[Disadvantage]&+" $ IntHolder $ "&";
	} 
		
	if( PawnInFriendlyBase(Victim_Location, self) ) // Getting wrecked in your own base
	{
		IntHolder = class'Rx_VeterancyModifiers'.default.Mod_AssaultKill;	
			
		BaseVP+=IntHolder;
		
		if(KillerPRI != none)
			KillerPRI.AddOffensiveKill(); 
		
		bNeutral = false; 
		
		VPString = VPString $ "[Offensive Kill]&+" $ IntHolder $ "&";
	} 
		
	/********************/
	/*Negative Modifiers*/
	/********************/
		
	if(KillerVRank > VRank ) //Is this bastard gimping ? [Negative Modifiers] (Leave out the '+') 
	{
		IntHolder = class'Rx_VeterancyModifiers'.default.Mod_UnfairAdvantage*(KillerVRank-VRank);	
			
		BaseVP+=IntHolder;
		
		VPString = VPString $ "[Vet Advantage]&" $ IntHolder $ "&";
	} 
		
	if(DamageType == class'Rx_DmgType_ProxyC4' ) //Kills with mines 
	{
		IntHolder = class'Rx_VeterancyModifiers'.default.Mod_MineKill;	
			
		BaseVP+=IntHolder;
		
		if(KillerPRI != none)
			KillerPRI.AddMineKill(); 
		
		VPString = VPString $ "[Mine Kill]&" $ IntHolder $ "&";
	} 
		
	if( PawnInFriendlyBase(Killer_Location, Killer.Pawn) ) //Is this bastard in his own base ? [Negative Modifiers] (Leave out the '+') 
	{
		IntHolder = class'Rx_VeterancyModifiers'.default.Mod_DefenseKill;	
			
		BaseVP+=IntHolder;
		
		if(KillerPRI != none)
			KillerPRI.AddDefensiveKill(); 
		
		if(IsInfiltrator()){
			KillerPRI.AddInfiltratorKill();
		}
		
		bNeutral = false; 
		
		VPString = VPString $ "[Defensive Kill]&" $ IntHolder $ "&";
	} 
		
	BaseVP=fmax(1.0, BaseVP); //Offer at least 1 VP cuz... why not ? Consolation prize
		
	if(KillerPRI != none)
		KillerPRI.AddTotalKill(); 
	
	if(bNeutral)
		KillerPRI.AddNeutralKill(); 
		
	return "[Infantry Kill]&+" $ BaseVP $ "&" ;
		
	//Uncomment to use full feat strings 
	//return VPString ; /*Complicated for the sake of you entitled, ADHD kids that need flashing lights to pet your ego. BaseVP$"&"$*/
}


//A much lighter variant of the VPString builder, used to calculate assists (Which only add in negative modifiers for in-base and higher VRank)
function int BuildAssistVPString(Controller Killer) 
{
	local int EndAssistModifier;
	local int KillerVRank; 
	local string Killer_Location, Victim_Location; 
	//local bool  KillerisPawn; 
	local Rx_PRI KillerPRI; 
	local bool	 bNeutral; 
	//Remember that -I- am the victim here
	
	//if(Killer == none) return 0; 
	
	if((Rx_Controller(Killer) == none && Rx_Bot(Killer) == none)) return 0;
	
	bNeutral = true;  
	
	KillerPRI = Rx_PRI(Killer.PlayerReplicationInfo) ;
	
	if(Rx_Vehicle(Killer.Pawn) != none ) //I got shot by a vehicool  
	{
		KillerVRank = Rx_Vehicle(Killer.Pawn).GetVRank(); 
	}
	else 
	//They're a Pawn, Harry
	if(Rx_Pawn(Killer.Pawn) != none )
	{
		KillerVRank = Rx_Pawn(Killer.Pawn).GetVRank(); 
	}
	/*Finding location info*/ 
	
	Killer_Location = GetPawnLocation(Killer.Pawn); 
	
	Victim_Location = GetPawnLocation(self); 
	
	/*End Getting location*/
	
	//VP count starts here. 
	
	/********************/
	/*Positive Modifiers*/
	/********************/
	
	if( PawnInFriendlyBase(Victim_Location, self) ) // Getting wrecked in your own base
	{
		EndAssistModifier += class'Rx_VeterancyModifiers'.default.Mod_AssaultKill;	

		if(KillerPRI != none)
			KillerPRI.AddOffensiveAssist(); 
		
		bNeutral = false;  
	} 
		
	/********************/
	/*Negative Modifiers*/
	/********************/
		
	if(KillerVRank > VRank ) //Is this bastard gimping ? [Negative Modifiers] (Leave out the '+') 
	{
		EndAssistModifier += class'Rx_VeterancyModifiers'.default.Mod_UnfairAdvantage*(KillerVRank-VRank);	
	} 
		
	if( PawnInFriendlyBase(Killer_Location, Killer.Pawn) ) //Is this bastard in his own base ? [Negative Modifiers] (Leave out the '+') 
	{
		if(KillerPRI != none)
			KillerPRI.AddDefensiveAssist(); 
		
		bNeutral = false;  
		
		EndAssistModifier += class'Rx_VeterancyModifiers'.default.Mod_DefenseKill;	
	} 
		
	if(KillerPRI != none)
	{
		KillerPRI.AddTotalAssists(); 
		
		if(bNeutral)
			KillerPRI.AddNeutralAssists(); 
		
		KillerPRI.AddScoreToPlayerAndTeam(0); //Add 0 for assists. That way they don't affect Legacy, but also call the update for Score in the new PRI score system.
	}
		
	
	
	
	return EndAssistModifier ;
	
}


function bool NearFriendlyBeacon()
{
local Rx_Weapon_DeployedBeacon CloseBeacon; 

foreach OverlappingActors(class'Rx_Weapon_DeployedBeacon', CloseBeacon, 1500)
	{
			if(CloseBeacon.GetTeamNum() == GetTeamNum()) return true; 
	}
	return false; 
}

function bool NearEnemyBeacon()
{
	local Rx_Weapon_DeployedBeacon CloseBeacon; 

	foreach OverlappingActors(class'Rx_Weapon_DeployedBeacon', CloseBeacon, 1500)
		{
			if(CloseBeacon.GetTeamNum() != GetTeamNum()) return true; 
		}
		return false; 
} 

function bool IsSniper()
{
	local class<Rx_FamilyInfo> Fam; 
	
	Fam=GetRxFamilyInfo();
	
	if(Fam == class'Rx_FamilyInfo_GDI_Deadeye' || Fam == class'Rx_FamilyInfo_GDI_Havoc' || Fam == class'Rx_FamilyInfo_Nod_BlackHandSniper' || Fam == class'Rx_FamilyInfo_Nod_Sakura') return true; 
	else
	return false; 
}

function bool IsInfiltrator()
{
	local class<Rx_FamilyInfo> Fam; 
	
	Fam=GetRxFamilyInfo();
	
	if(Fam == class'Rx_FamilyInfo_GDI_Hotwire' || Fam == class'Rx_FamilyInfo_GDI_Engineer' || Fam == class'Rx_FamilyInfo_Nod_Engineer' || Fam == class'Rx_FamilyInfo_Nod_Technician' || Fam == class'Rx_FamilyInfo_Nod_StealthBlackHand') return true; 
	else
	return false; 
}

function bool IHaveABeacon()
{
	local Rx_InventoryManager MyInventory; 
	local class<Rx_Weapon> MyWeapon; 
	MyInventory = Rx_InventoryManager(InvManager);
	
	foreach MyInventory.Items(MyWeapon)
	{
		if(MyWeapon.isA('Rx_Weapon_Beacon')) return true; 
	}
	return false; 
}

function int GetVRank()
{
	return VRank; 
}

function bool WasSniper (Controller C)
{
	local class<Rx_Weapon> Weaps;

	if(C.Pawn != none && C.Pawn.Weapon != none)
	{
		Weaps = class<Rx_Weapon>(C.Pawn.Weapon.class) ;
		if(Weaps == class'Rx_Weapon_SniperRifle_GDI' || Weaps == class'Rx_Weapon_SniperRifle_Nod')
			return true; 
	}
	
	return false; 
}

simulated function ENUM_Armor GetArmor()
{
	return Armor_Type;
}

function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local Rx_Bot bot;
	local Rx_CapturePoint CP;
	local byte WasTeam;
	//local Rx_ORI ORI; 
	
	WasTeam = GetTeamNum();
	
	if(Rx_Controller(Controller) != None)
	{
		Rx_Controller(Controller).RemoveAllEffects();
	}
	else
	if(Rx_Bot(Controller) != None)
	{
		Rx_Bot(Controller).RemoveAllEffects();
	}
	//Notify ORI that this target was destroyed [Deprecated]
	//if(ORI != none && bIsTarget) ORI.NotifyTargetKilled(self); 

	if(PlayerReplicationInfo != none)
	{
		Rx_PRI(PlayerReplicationInfo).SetIsSpy(false);
		Rx_PRI(PlayerReplicationInfo).SetTargetEliminated(1); 
	}

	//Don't awkwardly continue regenerating health on your dead body.... 
	if(IsTimerActive('regenerateHealthTimer') ) ClearTimer('regenerateHealthTimer');
	
	foreach Worldinfo.AllControllers(class'Rx_Bot', bot) 
	{
		if(Rx_SquadAI(bot.squad).SquadLeader == controller && bot.GetOrders() == 'Follow') 
		{
			UTTeamInfo(bot.Squad.Team).AI.SetBotOrders(bot);   
		}
	}
	
	if (ParachuteDeployed)
	{
		ActualPackParachute();
		HideParachute();
	}
	
	if (super.Died(Killer, damageType, HitLocation))
	{
		foreach TouchingActors(class'Rx_CapturePoint', CP)
			CP.NotifyPawnDied(self, WasTeam);
		return true;
	}
	else
		return false;
}

simulated function float CalcRadiusDmgDistance(vector HurtOrigin)
{
	local float		ColRadius, ColHeight;

	GetBoundingCylinder(ColRadius, ColHeight);

	return FMax(VSize(Location - HurtOrigin) - ColRadius,0.f);
}

function TakeDamageFromDistance (
	float               GivenDistance,
	Controller			InstigatedBy,
	float				BaseDamage,
	float				DamageRadius,
	class<DamageType>	DamageType,
	float				Momentum,
	vector				HurtOrigin,
	bool				bFullDamage,
	Actor               DamageCauser,
	optional float      DamageFalloffExponent=1.f
)
{
	local float		ColRadius, ColHeight;
	local float		DamageScale, ScaledDamage;
	local vector	Dir;

	GetBoundingCylinder(ColRadius, ColHeight);

	Dir	= Location - HurtOrigin;
	Dir	= Normal(Dir);

	if ( bFullDamage )
	{
		DamageScale = 1.f;
	}
	else
	{
		DamageScale = FClamp(1.f - GivenDistance/DamageRadius, 0.f, 1.f);
		DamageScale = DamageScale ** DamageFalloffExponent;
	}

	if (DamageScale > 0.f)
	{
		ScaledDamage = DamageScale * BaseDamage;
		TakeDamage
		(
			ScaledDamage,
			InstigatedBy,
			Location - 0.5f * (ColHeight + ColRadius) * Dir,
			(DamageScale * Momentum * Dir),
			DamageType,,
			DamageCauser
		);
	}
}

simulated function bool ClientHitIsNotRelevantForServer()
{
	return Health <= 0;
}

simulated function TakeRadiusDamage
(
	Controller			InstigatedBy,
	float				BaseDamage,
	float				DamageRadius,
	class<DamageType>	DamageType,
	float				Momentum,
	vector				HurtOrigin,
	bool				bFullDamage,
	Actor               DamageCauser,
	optional float      DamageFalloffExponent=1.f
)
{
	//The hell ACTUALLY shot me? 
	local Weapon ProjectileWeaponOwner; 
	
	if(InstigatedBy != None 
			&& (InstigatedBy.GetTeamNum() == GetTeamNum() && InstigatedBy != Controller) 
			&& Rx_Weapon_DeployedActor(DamageCauser) == None) {
		return;
	}	
	if(Rx_Weapon_DeployedActor(DamageCauser) != None)
	{
		if(InstigatedBy != Controller && DamageCauser.GetTeamNum() == GetTeamNum())
			return; // Beacons/C4 only damages the planter
	}
	
	if(Rx_Projectile(DamageCauser) != none) 
		ProjectileWeaponOwner = Rx_Projectile(DamageCauser).GetWeaponInstigator();
	else if(InstigatedBy != None)
		ProjectileWeaponOwner = InstigatedBy.Pawn.Weapon; // Was likely instant and not a projectile 
	
	//&& Rx_Projectile_Grenade(DamageCauser) == none) {
	//EDIT: Grenades and anything that's going to have a delayed explosion [like really really slow, timer projectiles] should just go straight to TakeRadiusDamage 
	
	if(Rx_Projectile(DamageCauser) != None && !Rx_Projectile(DamageCauser).isAirstrikeProjectile()) { 
		if(WorldInfo.NetMode != NM_DedicatedServer 
					&& InstigatedBy != None && InstigatedBy.Pawn != none && (Rx_Weapon(ProjectileWeaponOwner) != None || Rx_Vehicle_Weapon(ProjectileWeaponOwner) != None)) {	
			if(Health > 0 && self.GetTeamNum() != InstigatedBy.GetTeamNum() && UTPlayerController(InstigatedBy) != None) {
				Rx_Hud(UTPlayerController(InstigatedBy).myHud).ShowHitMarker();
			}

			if (InstigatedBy != None && InstigatedBy.Pawn != none && Rx_Weapon_VoltAutoRifle(ProjectileWeaponOwner) != None)
				Rx_Weapon_VoltAutoRifle(ProjectileWeaponOwner).ServerALRadiusDamageCharged(self,HurtOrigin,bFullDamage,class'Rx_Projectile_VoltBolt'.static.GetChargePercentFromDamage(BaseDamage));
			else if(InstigatedBy != None && InstigatedBy.Pawn != none && Rx_Weapon(ProjectileWeaponOwner) != None) {
				Rx_Weapon(ProjectileWeaponOwner).ServerALRadiusDamage(self,HurtOrigin,bFullDamage);
			} else {
				Rx_Vehicle_Weapon(ProjectileWeaponOwner).ServerALRadiusDamage(self,HurtOrigin,bFullDamage, Rx_Projectile(DamageCauser).FMTag);
			}	
		} else if(ROLE == ROLE_Authority && AIController(InstigatedBy) != None) {
			super.TakeRadiusDamage(InstigatedBy,BaseDamage,DamageRadius,DamageType,Momentum,HurtOrigin,bFullDamage,DamageCauser,DamageFalloffExponent);
		}
	} else {
		//`log("Base Damage is: " @ BaseDamage); 
		super.TakeRadiusDamage(InstigatedBy,BaseDamage,DamageRadius,DamageType,Momentum,HurtOrigin,bFullDamage,DamageCauser,DamageFalloffExponent);
	}
}

simulated function byte GetHealNecessity() //On a scale from 0 to 5, how much does it hurt? 
{
	local float HealthFraction; 
	
	HealthFraction = (float(Health+Armor)/float(HealthMax+ArmorMax))*100.0 ;
	
	
	if(HealthFraction < 33) return 3 ; //Critical
	else
	if(HealthFraction <= 66) return 2 ; // Should probably heal me, bro 
	else
	if(HealthFraction <= 95) return 1; //Not much in the way of necessity on healing
	else
	return 0 ; 
}

function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
	local int HealthAmmount,ArmorAmmount, TotalAmmount;
	local float Score;

	if (Health <= 0 || Amount <= 0 || Healer == None || (Health >= HealthMax && Armor >= ArmorMax))
		return false;

	HealthAmmount = Min(Amount, HealthMax - Health);
	
	Health += HealthAmmount;

	ArmorAmmount = Min(Amount - HealthAmmount, ArmorMax - Armor);
	Armor += ArmorAmmount;
	
	TotalAmmount = HealthAmmount + ArmorAmmount;
	
	DamageRate = (fmax(0,DamageRate-TotalAmmount));
	
	// Give score to the healer (EDIT-Yosh: Only if it was legitimate damage, i.e from an enemy)
	if (TotalAmmount > 0 && LegitamateDamage > 0)
	{
		LegitamateDamage=fMax(0,LegitamateDamage-TotalAmmount); 
		Score = TotalAmmount * class<Rx_FamilyInfo>(CurrCharClassInfo).default.HealPointsMultiplier;
		Rx_PRI(Healer.PlayerReplicationInfo).AddScoreToPlayerAndTeam(Score);
		Rx_PRI(Healer.PlayerReplicationInfo).AddRepairPoints_P(TotalAmmount); //Add to amount of Pawn repair points this 
		
	}

	return true;
}

function bool DoJump( bool bUpdating )
{
	/**if (DeductStamina(JumpStaminaCost))
	{			
		JumpZ = MaxJumpZ * CurrentHopStamina;
		CurrentHopStamina = FMax(CurrentHopStamina - HopCost,MinHopStamina);
	}*/

	local Actor TraceHit; 
	Local Vector StartLoc, EndLoc, VaultStartLoc, VaultEndLoc; 
	
	Local Vector MyPosition, MyRotation; 
	
	Local Vector HitNormal, HitLocation; 
	
	Local Int Magnitude;

	if(IsTimerActive('JumpRecoilTimer'))
		return false; 
	
	VaultStartLoc = Location;
	VaultStartLoc.Z -= 40.0;
	StartLoc = VaultStartLoc;
	
	Magnitude = 40;
	MyPosition = Location;
	MyRotation = Vector(Rotation);
	
	MyRotation.X *= Magnitude;
	MyRotation.Y *= Magnitude;
	
	MyPosition.X += MyRotation.X;
	MyPosition.Y += MyRotation.Y;
	MyPosition.Z -= 40.0;

	VaultEndLoc = MyPosition;
	EndLoc = VaultEndLoc;

	TraceHit = Trace (HitLocation, HitNormal, StartLoc, EndLoc, true ,,, 
	TRACEFLAG_Bullet | TRACEFLAG_PhysicsVolumes | 
	TRACEFLAG_SkipMovers | TRACEFLAG_Blocking); 

	//DrawDebugLine (StartLoc, EndLoc, 255, 250, 100, true); 

	if (TraceHit != none && TraceHit.IsA ('VaultActor') && bVaulted == false && Physics == Phys_Walking) 
	{ 
		GotoState ('Vaulting'); 
	}	
	else
	{	
		//Save our speed from our jump 
		if(bSprinting)
			IntendedGroundSpeed = SprintSpeed; //*GetSpeedModifier();
		else
			IntendedGroundSpeed = RunningSpeed;  //*GetSpeedModifier();
		
		JumpZ = default.JumpZ * JumpHeightMultiplier;
		return super.DoJump(bUpdating);
	}
	return false;
}

event SwapCamBack()
{
	Rx_Controller(GetALocalPlayerController()).ToggleCam();
}

/** no double jump */
function bool CanMultiJump(){return false;}

simulated function SetGroundSpeed(optional float Speed) {
	if (Speed != 0)
		IntendedGroundSpeed = Speed;
	Speed = FMax(IntendedGroundSpeed * CurrentHopStamina, WalkingSpeed);
	GroundSpeed = Speed * GetSpeedModifier(); //(SpeedUpgradeMultiplier+GetRxFamilyInfo().default.Vet_SprintSpeedMod[VRank]);
	ServerSetGroundSpeed(Speed);
}

reliable server function ServerSetGroundSpeed(float Speed) {
	Speed = FMin(Speed, SprintSpeed);
	if(Speed > RunningSpeed) {
		bSprintingServer = true;
	} else {
		bSprintingServer = false;
	}
	Groundspeed = Speed * GetSpeedModifier(); //(SpeedUpgradeMultiplier+GetRxFamilyInfo().default.Vet_SprintSpeedMod[VRank]);
}

simulated function UpdateRunSpeedNode()
{
	if(RunSpeedAnimNode != None)
	{
		RunSpeedAnimNode.Constraints[0] = 0;
		RunSpeedAnimNode.Constraints[1] = WalkingSpeed * GetSpeedModifier() - 5 ;//(SpeedUpgradeMultiplier+GetRxFamilyInfo().default.Vet_SprintSpeedMod[VRank]) - 5;
		RunSpeedAnimNode.Constraints[2] = RunningSpeed * GetSpeedModifier() - 5 ;//(SpeedUpgradeMultiplier+GetRxFamilyInfo().default.Vet_SprintSpeedMod[VRank])  - 5;
		RunSpeedAnimNode.Constraints[3] = SprintSpeed * GetSpeedModifier() - 5 ;// (SpeedUpgradeMultiplier+GetRxFamilyInfo().default.Vet_SprintSpeedMod[VRank])  - 5;
		//`log(RunSpeedAnimNode.Constraints[1]);
	}
}

/**
 * Starts sprinting and if the player is moving forward and has more than zero stamina. 
 * 
 * @since 2011-10-12
 */
function StartSprint()
{
	if (!bSprinting)
	{
		if (Stamina <=0 || (PlayerController(Controller) != None && Rx_PlayerInput(PlayerController(Controller).PlayerInput).aBaseYTemp <= 0) || Rx_weapon(Weapon).GetHolderCanSprint() == false ) 
		{
			//Make entry in log and return
			//`log("Sprinting set to false because player isn't moving forward.");
			return;
		}
	
		/**
		if(GetTeamNum() == TEAM_GDI && GetObelisk() != None && !obelisk.IsDestroyed()) {
			//DrawDebugLine(location,obelisk.SentinelLocation,0,0,255,true);
			if(VSizeSq(location-obelisk.location) <= 640000 || FastTrace(location, obelisk.SentinelLocation,,true)) {
				return;
			}
		} else if(GetTeamNum() == TEAM_Nod && GetAgt() != None && !Agt.IsDestroyed()) {
			if(VSizeSq(location-Agt.location) <= 250000 || FastTrace(location, Agt.SentinelLocation,,true)) {
				return;
			}
		}
		*/
	
		if(Rx_Weapon(Weapon).bIronsightActivated) {
			bWasInIronsightBeforeAction = true;
			Rx_Weapon(Weapon).EndZoom(UTPlayerController(Controller));
		} else {
			bWasInIronsightBeforeAction = false;	
		}
		
		//StopFiring();
		//if(PlayerController(Controller) != None) {
			SetGroundSpeed(SprintSpeed);
		//}
		SetHandIKEnabled(false);

		Relax(true);
		
		if(bSprinting == false && Rx_Controller(Controller) != None && !Rx_Controller(Controller).bBehindView && IsWeaponAllowingSprintAnim()) {
			BeginSprintAnims();
		}
		bSprinting = true;
		
		//Tell weapons we began sprinting 
		if(Rx_weapon(Weapon) != none) 
			Rx_Weapon(Weapon).OnActionStart(); 
	}
}

function Rx_Building_Nod_Defense GetObelisk()
{
	if(!bCheckedForOb) {
		ForEach AllActors(class'Rx_Building_Nod_Defense', Obelisk) {
			break;
		}
		bCheckedForOb = true;
	}
	return Obelisk;
}

function Rx_Building_GDI_Defense GetAgt()
{
	if(!bCheckedForAgt) {
		ForEach AllActors(class'Rx_Building_GDI_Defense', Agt) {
			break;
		}
		bCheckedForAgt = true;
	}
	return Agt;
}

function bool IsWeaponAllowingSprintAnim()
{
	return Rx_Weapon_Reloadable(weapon) == None || (!Rx_Weapon_Reloadable(weapon).CurrentlyReloading && !Rx_Weapon_Reloadable(weapon).CurrentlyBoltReloading);
}

function BeginSprintAnims()
{
	Rx_Weapon(weapon).PlayWeaponAnimation(WeaponAimedToRestAnim, 0.0);
	Rx_Weapon(weapon).PlayArmAnimation(WeaponAimedToRestAnim, 0.0);
	SetTimer(0.5, false, 'PlayRunAnim');
}

function PlayRunAnim() 
{
	if(Rx_Controller(Controller) != None && !Rx_Controller(Controller).bBehindView && IsWeaponAllowingSprintAnim()) {
		Rx_Weapon(weapon).PlayWeaponAnimation(WeaponSprintAnim, 0.0,true);
		Rx_Weapon(weapon).PlayArmAnimation(WeaponSprintAnim, 0.0,,true);	
	}
}

function StopSprinting()
{
	if (bSprinting)
	{
		SetGroundSpeed(RunningSpeed);
		StopSprintSelf();
		if(Rx_Controller(Controller) != None)
			Rx_Controller(Controller).bHoldSprint = false;
	}
}

function StopSprintSelf()
{
	ClearTimer('PlayRunAnim');
	SetHandIKEnabled(true);
	if(bSprinting && Rx_Controller(Controller) != None && IsWeaponAllowingSprintAnim()) { 
		Rx_Weapon(weapon).PlayWeaponAnimation(WeaponRestToAimedAnim, 0.0);
		Rx_Weapon(weapon).PlayArmAnimation(WeaponRestToAimedAnim, 0.0);
	}
	bSprinting = false;
	
	//Notify Weapon 
	Rx_Weapon(weapon).OnActionStop(); 
	/** // Go back into ironsight after sprint
	if(bWasInIronsightBeforeAction && Rx_Controller(Controller) != None) {
		Rx_Weapon(Weapon).StartZoom(UTPlayercontroller(Controller));	
	}
	*/
}

reliable client function ClientStopSprint()
{
	StopSprintSelf();	
}


simulated function Tick(float DeltaTime)
{	
	local vector TempVect;
	
	if(Rx_Controller(Controller) == none)
	{
		TickParachute(DeltaTime);
		super.Tick(DeltaTime); 
		
		if (Stamina < MaxStamina && !bExhausted) //Tick Stamina appropriately
		{
			Stamina += (StaminaRegenRate * DeltaTime);
			if (Stamina > MaxStamina) 
				{
					Stamina = MaxStamina;
				}
		}
		
		return; //Ignore all of this if we're not the pawn we need to be concerned with. 
	}
	
	if((WorldInfo.NetMode != NM_DedicatedServer && (bTickHandIK || Rx_Controller(Controller) != none )) || WorldInfo.IsPlayingDemo()) 
	{
		TickHandIK(DeltaTime); //Calculate all of the hand IK repositioning crap.
		bTickHandIK = false; //Reset, as we don't need to do this constantly
	}
		
	
	if (bSprinting && Worldinfo.Netmode != NM_DedicatedServer && DrivenVehicle == None)
	{
		if(PlayerController(Controller) != None) 
		{
			/**Weapon.StopFire(0);
			Weapon.StopFire(1);
			Weapon.StopFire(2);*/
			
			if (Rx_PlayerInput(PlayerController(Controller).PlayerInput).aBaseYTemp <= 0)
				StopSprinting();
		}
		DeductStamina(SprintStaminaCost * DeltaTime);
	}
	else if (Stamina < MaxStamina && !bExhausted)
	{
		Stamina += (StaminaRegenRate * DeltaTime);
		if (Stamina > MaxStamina) 
		{
			Stamina = MaxStamina;
		}
	}
	
	/** Regen hop stamina
	if (CurrentHopStamina < 1)
	{
		CurrentHopStamina = FMin(CurrentHopStamina + HopRegenRate * DeltaTime ,1);
		if (CurrentHopStamina == 1 && WorldInfo.NetMode != NM_DedicatedServer)
			SetGroundSpeed();
	}
*/
	
	
	if(WorldInfo.IsPlayingDemo())
	{
		/** in demos it proved to reduce playerlag a bit if the location is forced down (This wont lead to players walking in the ground as the physicsengine still puts them on the ground)*/
		TempVect = location;
		TempVect.z -= 20;
		if(Physics == Phys_Walking)
			setlocation(TempVect);

	}
	TickParachute(DeltaTime);
	super.Tick(DeltaTime);
}

simulated function TickHandIK(float DeltaTime)
{
	local vector LeftHandVec;
	local rotator TempRot, NoRot;
	local Rx_WeaponAttachment CurrentRxAttachment;
	local Rx_Weapon PawnWeapon;
	
	NoRot.Pitch = 0;
	NoRot.Yaw = 0;
	NoRot.Roll = 0;
	
	if (Rx_Weapon(Weapon) != None) 
		PawnWeapon = Rx_Weapon(Weapon); 
	if(CurrentWeaponAttachment != none) 
			CurrentRxAttachment = Rx_WeaponAttachment(CurrentWeaponAttachment); 
		
	if(PawnWeapon == none || CurrentRxAttachment == none)
	{
		SetHandIKEnabled(false);
			ResetHandIKVectorRotator();
			return;
	}
	
	if(PawnWeapon.bByPassHandIK == false)
	{		
		if (TopHalfAnimSlot.bIsPlayingCustomAnim == false)
		{
				
			if (LeftHandIK_SB != None)
			{
				CurrentRxAttachment.Mesh.GetSocketWorldLocationAndRotation((CurrentRxAttachment.LeftHandIKSocket),LeftHandVec, TempRot, 1);
		
				if (CurrentRxAttachment.Mesh.GetSocketByName(CurrentRxAttachment.LeftHandIKSocket) != None)
				{
					LeftHandIK_SB.bAddTranslation = false;
					SetHandIKEnabled(true);
			
					if (!IsRelaxed)
						LeftHandIK_SB.BoneTranslation = LeftHandVec + PawnWeapon.LeftHandIK_Offset;
					else
					{
						if (PawnWeapon.bUseHandIKWhenRelax)
						{
							LeftHandIK_SB.bAddTranslation = false;
							SetHandIKEnabled(true);
							LeftHandIK_SB.BoneTranslation = LeftHandVec + PawnWeapon.LeftHandIK_Relaxed_Offset;
						}
						else
						{
							LeftHandIK_SB.bAddTranslation = True;
							SetHandIKEnabled(false);
							LeftHandIK_SB.BoneTranslation = PawnWeapon.LeftHandIK_Relaxed_Offset;
						}
					}
				}
				else
				{
					LeftHandIK_SB.bAddTranslation = True;
					SetHandIKEnabled(false);
			
					if (!IsRelaxed)
						LeftHandIK_SB.BoneTranslation = PawnWeapon.LeftHandIK_Offset;
					else
						LeftHandIK_SB.BoneTranslation = PawnWeapon.LeftHandIK_Relaxed_Offset;
				}
			}
			if (LeftHandIK_SBR != None)
			{
				if (!IsRelaxed)
					LeftHandIK_SBR.BoneRotation = PawnWeapon.LeftHandIK_Rotation;
				else
					LeftHandIK_SBR.BoneRotation = PawnWeapon.LeftHandIK_Relaxed_Rotation;
			}
			if (RightHandIK_SB != None)
			{
				if (!IsRelaxed)
					RightHandIK_SB.BoneTranslation = PawnWeapon.RightHandIK_Offset;
				else
					RightHandIK_SB.BoneTranslation = PawnWeapon.RightHandIK_Relaxed_Offset;
			}
			if (RightHandIK_SBR != None)
			{
				if (IsRelaxed)
					RightHandIK_SBR.BoneRotation = PawnWeapon.RightHandIK_Relaxed_Rotation;
				else
				{
					RightHandIK_SBR.BoneRotation = NoRot;
				}
			}

			if (LeftHandOverride != None)
			{
				if (PawnWeapon.bOverrideLeftHandAnim)
				{
					LeftHandOverride.SetBlendTarget(1.0, 0.25);
					LeftHandAnimName.SetAnim(PawnWeapon.LeftHandAnim);
				}
				else
				{
					LeftHandOverride.SetBlendTarget(0.0, 0.25);
					LeftHandAnimName.SetAnim(PawnWeapon.LeftHandAnim);
				}
			}
		}
		else
		{
			SetHandIKEnabled(false);
			ResetHandIKVectorRotator();
		}
		
		if (bVaulted || (Rx_Weapon_Reloadable(Weapon) != none && Rx_Weapon_Reloadable(Weapon).CurrentlyReloading))
		{
			SetHandIKEnabled(false);
			ResetHandIKVectorRotator();
		}
	}
	else
	{
		SetHandIKEnabled(false);
		ResetHandIKVectorRotator();
	}
}

simulated function ResetHandIKVectorRotator()
{
	local vector NoVec;
	local rotator NoRot;
	
	NoVec.X = 0;
	NoVec.Y = 0;
	NoVec.Z = 0;
	NoRot.Pitch = 0;
	NoRot.Yaw = 0;
	NoRot.Roll = 0;
	
	// SetHandIKEnabled(false);
	// Relax(true);
	LeftHandIK_SB.bAddTranslation = true;
	LeftHandIK_SB.BoneTranslation = NoVec;
	LeftHandIK_SBR.BoneRotation = NoRot;
	RightHandIK_SB.bAddTranslation = true;
	RightHandIK_SB.BoneTranslation = NoVec;
	RightHandIK_SBR.BoneRotation = NoRot;	
}

client reliable function ClientSetStamina(float value)
{
	Stamina = value;
}

/**
 * Returns true if the player has enough stamina to subtract the specified amount, and false if not.
 * 
 *  @param	Amount	The amount of stamina to be deducted
 *  @return         True or false
 *  @since          2011-10-12
 * 
 */
simulated function bool DeductStamina(float Amount)
{
	if (Stamina <= 0)
		return false;
	
	/* Stamina Fix (Jumping and dodging)
	 * By Triggerhippy
	 *
	 * These modifications implement the following changes:
	 * The player can now only dodge or jump if they have the necessary stamina.
	 */

	// We want to drop out here if the player is trying to jump or dodge with insufficient stamina (but not sprint), so this is set to -10 rather than 0.
	if (Stamina - Amount < -10)
	{
		return false;
	}

	Stamina -= Amount;
	if (Stamina <= 0)
	{
		Stamina = 0;
		StopSprinting();
		bExhausted = true;
		setTimer(ExhaustionTime, false, 'CatchBreath');
	}
	else
	{
		bExhausted = true;
		setTimer(StaminaCooldownTime, false, 'CatchBreath');
	}
	return true;
}

simulated function CatchBreath() 
{
	bExhausted = false;
}

/** Walking System */
function StartWalking()
{
	if(Rx_Weapon(Weapon).bIronsightActivated )
		return;	
	ConsoleCommand("Walking");
	SetGroundSpeed(WalkingSpeed);
}

function StopWalking()
{
	if(Rx_Weapon(Weapon).bIronsightActivated || Rx_Weapon(Weapon).GetZoomedState() != ZST_NotZoomed )
		return;
	SetGroundSpeed(RunningSpeed);
}

reliable server function ServerStopWalking()
{
	StopWalking();
}


//-----------------------------------------------------------------------------
// animation related
//-----------------------------------------------------------------------------

simulated function SetOverlay(class<Rx_StatModifierInfo> StatClass, bool bAffectWeapons)//SetOverlay(LinearColor MatColour, float MatOpacity, float MatInflation, bool bAffectWeapons)
{
	//Incase we're hanging onto anything
	ClearOverlay();  
	
	SetOverlayMaterial(StatClass.default.PawnMIC); 
	
	if(bAffectWeapons) 
	{
		CurrentStoredWeaponOverlayByte = StatClass.default.EffectPriority;
	
		if(Rx_GRI(WorldInfo.GRI).WeaponOverlays.Length == 0 && WorldInfo.NetMode != NM_DedicatedServer) Rx_GRI(WorldInfo.GRI).SetupWeaponOverlays(); //Tell GRI to setup weapon overlays if it hasn't already 
		
		SetWeaponOverlayFlag(StatClass.default.EffectPriority);
	}
	
}

simulated function ClearOverlay()
{
	SetOverlayMaterial(none);
	
	if(CurrentStoredWeaponOverlayByte != 255) 
	{
		ClearWeaponOverlayFlag(CurrentStoredWeaponOverlayByte);
		CurrentStoredWeaponOverlayByte = 255; 
	}
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	local string RelaxName;
	local int  RelaxNodeCount;
	local AnimNodeBlendList RelaxNodeTemp;

	RelaxNodeCount = 0;
	
	//super.PostInitAnimTree(SkelComp);

	if (SkelComp == ParachuteMesh)
	{
		
		ParachuteClosedWeight = MorphNodeWeight(ParachuteMesh.FindMorphNode('Parachute_OpeningStart'));		
		ParachuteCurveWeight = MorphNodeWeight(ParachuteMesh.FindMorphNode('Parachute_Curved'));		
		ParachuteLeftTurnWeight = MorphNodeWeight(ParachuteMesh.FindMorphNode('Parachute_LeftTurn'));		
		ParachuteRightTurnWeight = MorphNodeWeight(ParachuteMesh.FindMorphNode('Parachute_RightTurn'));
	}

	if (SkelComp == Mesh)
	{
		RunSpeedAnimNode = AnimNodeBlendBySpeed(Mesh.FindAnimNode('RunSpeedNode'));
		UpdateRunSpeedNode();

		LeftLegControl = SkelControlFootPlacement(Mesh.FindSkelControl(LeftFootControlName));
		RightLegControl = SkelControlFootPlacement(Mesh.FindSkelControl(RightFootControlName));
		FeignDeathBlend = AnimNodeBlend(Mesh.FindAnimNode('FeignDeathBlend'));
		FullBodyAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('FullBodySlot'));
		TopHalfAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('TopHalfSlot'));

		LeftHandAnimName = AnimNodeSequence( mesh.FindAnimNode('LeftHandAnimSeq') );
		LeftHandOverride = AnimNodeBlendPerBone(SkelComp.FindAnimNode('LeftHandOverride'));
		LeftHandIK = SkelControlLimb( mesh.FindSkelControl('LeftHandIK') );		
		RightHandIK = SkelControlLimb( mesh.FindSkelControl('RightHandIK') );
		
		LeftHandIK_SB = SkelControlSingleBone( mesh.FindSkelControl('LeftHandIK_Offset') );
		LeftHandIK_SBR = SkelControlSingleBone( mesh.FindSkelControl('LeftHandIK_Rotation') );
		RightHandIK_SB = SkelControlSingleBone( mesh.FindSkelControl('RightHandIK_Offset') );
		RightHandIK_SBR = SkelControlSingleBone( mesh.FindSkelControl('RightHandIK_Rotation') );

		RootRotControl = SkelControlSingleBone( mesh.FindSkelControl('RootRot') );
		AimNode = AnimNodeAimOffset( mesh.FindAnimNode('AimNode') );
		GunRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('GunRecoilNode') );
		LeftRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('LeftRecoilNode') );
		RightRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('RightRecoilNode') );

		DrivingNode = UTAnimBlendByDriving( mesh.FindAnimNode('DrivingNode') );
		VehicleNode = UTAnimBlendByVehicle( mesh.FindAnimNode('VehicleNode') );
		HoverboardingNode = UTAnimBlendByHoverboarding( mesh.FindAnimNode('Hoverboarding') );

		FlyingDirOffset = AnimNodeAimOffset( mesh.FindAnimNode('FlyingDirOffset') );
		
		//Dodge (Dive) Blend node 
		DodgeNode = AnimNodeBlendList(Mesh.FindAnimNode(name(DodgeNodeName)));
		DodgeNode.SetActiveChild(0,1.0);
		
		DodgeGroupNode = AnimNodeSequence( mesh.FindAnimNode('DodgeAnimNode') );//Only need Fwd.. The rest are linked to it
		//`log(DodgeGroupNode);
	
		// IF the Aimnode doesnt exist in the tree dont set WeaponAimNode equal to it
		if( AimNode != none )
		{
			WeaponAimNode = AimNode;
		}

		// Get Relaxed Aim Node
		RelaxedAimNode = AnimNodeAimOffset( mesh.FindAnimNode('AimRelaxed') );
		if( RelaxedAimNode == none )
		{
			`warn("Relaxed Aim Node Not Found In AnimTree");
		}

		// Find all the relax nodes in the tree and cache them
		do
		{
			RelaxNodeCount++;
			// Set name of next Relax Node
			RelaxName = RelaxBaseName$RelaxNodeCount;
			// Get First RelaxNode
			RelaxNodeTemp = AnimNodeBlendList(Mesh.FindAnimNode(name(RelaxName)));
			//if it doesnt find a node dont add it to the list
			if( RelaxNodeTemp != none )
			{
				RelaxedBlendLists.AddItem(RelaxNodeTemp);		
			}
		} 
		until( RelaxNodeTemp == none );
	}
}

simulated function SetAnimSet( AnimSet NewAnimSet, name ProfileName)
{
	Mesh.AnimSets[0] = NewAnimSet;
	Mesh.UpdateAnimations();
	WeaponAimNode.SetActiveProfileByName(ProfileName);
}


//-----------------------------------------------------------------------------
// camera related
//-----------------------------------------------------------------------------

/**
 * returns base Aim Rotation without any adjustment (no aim error, no autolock, no adhesion.. just clean initial aim rotation!)
 *
 * @return	base Aim rotation.
 */

//-----------------------------------------------------------------------------
// mesh related
//-----------------------------------------------------------------------------

/** we dont need to set any other mats so make sure we dont override old */
simulated function SetCharacterMeshInfo(SkeletalMesh SkelMesh, MaterialInterface HeadMaterial, MaterialInterface BodyMaterial)
{
	//`log("-----SET CHARACTER MESH INFO----");
   Mesh.SetSkeletalMesh(SkelMesh);
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (!VerifyBodyMaterialInstance())
			`logd("VerifyBodyMaterialInstance failed on pawn"@self);
	}
	
	NotifyPassivesMeshChanged(); 
}

simulated function ResetRelaxStance(optional bool RestartTimer)
{
	if (bAlwaysRelaxed)
	{
		Relax(true);
	}
	else if(IsRelaxed)
	{
		Relax(false);
		if (RestartTimer)
		{
			SetTimer( RelaxTime, false, 'RelaxTimer' );
		}
	}
	else
	{
		if( IsTimerActive('RelaxTmer') )
		{
			ClearTimer('RelaxTimer');
			if (RestartTimer)
			{
				SetTimer( RelaxTime, false, 'RelaxTimer' );
			}
		}
	}
}

/*Need to clean weapons up pretty bad*/
simulated function StartFire(byte FireModeNum)
{
	local Rx_Weapon OurWeapon; 
	
	if(bThrowingGrenade) return; 
	
	if(Rx_Weapon(Weapon) != none)
		OurWeapon = Rx_Weapon(Weapon); 
	
	if((OurWeapon.bIronSightCapable
		|| Rx_Weapon_Scoped(Weapon) != None 
		|| Rx_Weapon_PersonalIonCannon(weapon) != None 
		|| Rx_Weapon_Airstrike(weapon) != None
		|| Rx_Weapon_Railgun(weapon) != None) 
		&& FireModeNum == 1) 
	{
		
		if(Rx_Weapon_Reloadable(Weapon) != None && Rx_Weapon_Reloadable(Weapon).CurrentlyReloading)
			return;		 
			
		if(bSprinting)
			StopSprinting();

		if(!OurWeapon.bDisplayCrosshair 
			&& (!OurWeapon.bIronSightCapable || Rx_PlayerInput(PlayerController(Controller).PlayerInput).bClickToGoOutOfADS))
		{
			OurWeapon.EndZoom(UTPlayerController(Instigator.Controller));
		}			
		else if((OurWeapon.bDisplayCrosshair || (OurWeapon.bIronSightCapable && !OurWeapon.bIronsightActivated))
				&& !Rx_Controller(Controller).bZoomed && Rx_Controller(Controller).DesiredFOV == Rx_Controller(Controller).GetFovAngle())
		{
			OurWeapon.StartZoom(UTPlayerController(Instigator.Controller));	
			bStartFirePressedButNoStopFireYet = true;
		}
		return;
	} 	
	if (OurWeapon != none && OurWeapon.GetIsBurstFire())
	{
		OurWeapon.FireButtonPressed(FireModeNum);
	}

	if(bSprinting && Rx_Weapon(Weapon) != None)
	{
		StopSprinting();
	}
	else if (bSprinting) return;
	
	if (!bDodging)
	{
		ResetRelaxStance();
		Super.StartFire(FireModeNum);
	}
}

simulated function StopFire(byte FireModeNum)
{
	local Rx_Weapon OurWeapon; 
	
	if(Rx_Weapon(Weapon) != none)
		OurWeapon = Rx_Weapon(Weapon); 
	
	if(FireModeNum == 1)
		bStartFirePressedButNoStopFireYet = false;
		
	if(Weapon != none)
	{
		if (OurWeapon != none && OurWeapon.GetIsBurstFire())
		{
			OurWeapon.FireButtonReleased(FireModeNum);
		}
	
		if(!Rx_PlayerInput(PlayerController(Controller).PlayerInput).bClickToGoOutOfADS 
				&& (OurWeapon.bIronSightCapable && FireModeNum == 1)) 
		{	
			if((!Rx_Weapon(Weapon).bDisplayCrosshair || (OurWeapon.bIronSightCapable && OurWeapon.bIronsightActivated))
					&& Rx_Controller(Controller).bZoomed && Rx_Controller(Controller).DesiredFOV == Rx_Controller(Controller).GetFovAngle()) 
			{
				OurWeapon.EndZoom(UTPlayerController(Instigator.Controller));
				return;
			}
		}	

		SetTimer( RelaxTime, false, 'RelaxTimer' );
	}
	Super.StopFire(FireModeNum);
}

/**
  * used on remote clients
  */
simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
{
	Relax(false);
	super.WeaponFired(InWeapon,bViaReplication,HitLocation);
}

/**
  * used on remote clients
  */
simulated function WeaponStoppedFiring(Weapon InWeapon, bool bViaReplication)
{
	super.WeaponStoppedFiring(InWeapon,bViaReplication);
	SetTimer( RelaxTime, false, 'RelaxTimer' );	
}


// for AI since for somereason they dont call StopFire
function bool StopFiring()
{
	SetTimer( RelaxTime, false, 'RelaxTimer' );
	return super.StopFiring();
}

simulated function Relax( bool SetRelaxed )
{
	local AnimNodeBlendList RelaxNode;
	if (bAlwaysRelaxed)
	{
		SetRelaxed = true;
	}
	
	if(SetRelaxed && !IsRelaxed && !IsFiring())
	{	
		foreach RelaxedBlendLists(RelaxNode)
		{
			RelaxNode.SetActiveChild(1,0.35);
		}
		AimNode = RelaxedAimNode;
		IsRelaxed = true;
		
		if(LeftHandIK_SBR != none)
			LeftHandIK_SBR.ControlStrength = 1.0;

		if(RightHandIK_SBR != none)
			RightHandIK_SBR.ControlStrength = 1.0;
		
		if (Weapon != none && Rx_Weapon(Weapon).bByPassHandIK == false)
		{
			if (Rx_Weapon(Weapon).bUseHandIKWhenRelax)
				SetHandIKEnabled(true);
			else
				SetHandIKEnabled(false);
		}
		else
		{
			SetHandIKEnabled(false);
		}
	} 
	else if( !SetRelaxed && IsRelaxed )
	{
		foreach RelaxedBlendLists(RelaxNode)
		{
			RelaxNode.SetActiveChild(0,0.15);
		}
		AimNode = WeaponAimNode;
		IsRelaxed = false;
		if(LeftHandIK_SBR != none)
			LeftHandIK_SBR.ControlStrength = 1.0;

		if(RightHandIK_SBR != none)
			RightHandIK_SBR.ControlStrength = 0.0;
		
		if (Weapon != none && Rx_Weapon(Weapon).bByPassHandIK == false)
			SetHandIKEnabled(true);
		else
			SetHandIKEnabled(false);
	}
}

simulated function RelaxTimer()
{
	Relax(true);
}


function UnmarkTarget()
{
	bTargetted = false;
}

function ToggleNightVision()
{
	local Rx_Weapon_Scoped W;
	if( Weapon != none)
	{
		W = Rx_Weapon_Scoped(Weapon);
		if (W != none)
		{
			Rx_Weapon_Scoped(Weapon).ToggleNightVision();
		}
	}
}

/**
 * Return world location to start a weapon fire trace from.
 *
 * @return	World location where to start weapon fire traces from
 */
simulated event Vector GetWeaponStartTraceLocation(optional Weapon CurrentWeapon)
{
	local Vector Loc;
	//local Vector vel;
	if( CurrentWeapon != none && UDKSkeletalMeshComponent(CurrentWeapon.Mesh) != none )
	{
		//vel = velocity / 32; 
		//vel.z = -2;
		UDKSkeletalMeshComponent(CurrentWeapon.Mesh).GetSocketWorldLocationAndRotation( Rx_Weapon(Weapon).FireSocket, Loc );
		//UDKSkeletalMeshComponent(Mesh).GetSocketWorldLocationAndRotation( Rx_Weapon(Weapon).FireSocket, Loc );
		//return Loc + vel;
		//loginternal(Loc);
		return Loc;
	}
	// If the muzzle bone isnt there
	return GetPawnViewLocation();
}

/** TakeHeadShot()
 * @param	Impact - impact information (where the shot hit)
 * @param	HeadShotDamageType - damagetype to use if this is a headshot
 * @param	HeadDamage - amount of damage the weapon causes if this is a headshot
 * @param	AdditionalScale - head sphere scaling for head hit determination
 * @return		true if pawn handled this as a headshot, in which case the weapon doesn't need to cause damage to the pawn.
 * @Param		ProjectileWeapon - If a projectile is calling takeheadshot, then you need a reference to the weapon that fired it(otherwise it references whatever weapon the Instigator is carrying when this is called)
*/
simulated function bool TakeHeadShot(const out ImpactInfo Impact, class<DamageType> HeadShotDamageType, int HeadDamage, float AdditionalScale, controller InstigatingController, bool bRocketDamage, optional Weapon ProjectileWeapon) 
{
	local Weapon WeaponToCall; //Weapon to call back to for dealing damage
	
	//`log("Took Headshot" @ HeadshotDamageType @ HeadDamage @ AdditionalScale @ InstigatingController @ bRocketDamage); 
	if(Role < ROLE_Authority && InstigatingController != None && !InstigatingController.IsLocalPlayerController()) {
		//`log("rETURN fase in take headshot");
		return false;
	}
	
	
	
	
	if(InstigatingController != None && IsLocationOnHead(Impact, AdditionalScale) && (InstigatingController.IsA('PlayerController') || UTBot(InstigatingController) != None) )
	{
		bHeadshot = true; //Confirmed as a head shot 
		
		//This was a projectile, so seek which weapon it truly belonged to
		if(ProjectileWeapon != none) 
			WeaponToCall = ProjectileWeapon;
		else
			WeaponToCall = InstigatingController.Pawn.Weapon;
		
		//`log("Took Headshot" @ HeadshotDamageType); 
		if (WorldInfo.NetMode != NM_DedicatedServer && Rx_Pawn(InstigatingController.Pawn) != None && InstigatingController.Pawn.IsLocallyControlled())
		{	
			if(Health > 0 && self.GetTeamNum() != InstigatingController.GetTeamNum() && UTPlayerController(InstigatingController) != None)
			{
				Rx_Hud(UTPlayerController(InstigatingController).myHud).ShowHitMarker(true);
				Rx_Controller(InstigatingController).AddHSHit()  ; 	
			}	
			
			Rx_Weapon(WeaponToCall).ServerALHeadshotHit(self,Impact.HitLocation,Impact.HitInfo);
		}
		else if (WorldInfo.NetMode != NM_DedicatedServer && (Rx_Vehicle(InstigatingController.Pawn) != None || Rx_VehicleSeatPawn(InstigatingController.Pawn) != None) && InstigatingController.Pawn.IsLocallyControlled())
		{
			if(Health > 0 && self.GetTeamNum() != InstigatingController.GetTeamNum() && UTPlayerController(InstigatingController) != None)
				{
					Rx_Hud(UTPlayerController(InstigatingController).myHud).ShowHitMarker(true);
					Rx_Controller(InstigatingController).AddHSHit()  ; 	
				}
			//`log("Weapon was " @ Rx_Vehicle_Weapon(InstigatingController.Pawn.Weapon) @ InstigatingController.Pawn.Weapon);
			Rx_Vehicle_Weapon(WeaponToCall).ServerALHeadshotHit(self,Impact.HitLocation,Impact.HitInfo);
		}
		else if (WorldInfo.NetMode == NM_DedicatedServer && (AIController(InstigatingController) != None || bRocketDamage))
			TakeDamage(HeadDamage, InstigatingController, Impact.HitLocation, Impact.RayDir, HeadShotDamageType, Impact.HitInfo);
		
		return true;
	}
	
	return false;
}

simulated function bool IsLocationOnHead(const out ImpactInfo Impact, float AdditionalScale)
{
	local vector HeadLocation;
	local float Distance;

	if (HeadBone == '')
	{
		return False;
	}

	Mesh.ForceSkelUpdate();
	HeadLocation = Mesh.GetBoneLocation(HeadBone) + vect(0,0,1) * HeadHeight;

	// Find distance from head location to bullet vector
	Distance = PointDistToLine(HeadLocation, Impact.RayDir, Impact.HitLocation);

	return ( Distance < (HeadRadius * HeadScale * AdditionalScale) );
}

// Redefine function without 'exec', so nobody can use it via console -- still needed for kismet
exec simulated function FeignDeath() { ServerFeignDeath(); }

state FeigningDeath
{
	simulated function FeignDeath() { ServerFeignDeath(); }
}

reliable server function ServerFeignDeath()
{
   if (WorldInfo.NetMode != NM_DedicatedServer && WorldInfo.NetMode != NM_ListenServer)
   {
      super.ServerFeignDeath();
   }
}

simulated function SwitchWeapon(byte NewGroup)
{
	//if(NewGroup > 9 && !bThrowingGrenade) return; 
	
    if( NewGroup > 9 && Rx_InventoryManager(InvManager) != None ) // Over 9 means we're casting an ability
    {
		Rx_InventoryManager(InvManager).PreviousInventoryGroup = Rx_Weapon(Weapon).InventoryGroup;
		Super.SwitchWeapon(NewGroup);
    }
	else
	{ 
		Super.SwitchWeapon(NewGroup);
	}
}

simulated function ThrowGrenade()
{
	if(!bThrowingGrenade) 
		return; 
	else
	if(Rx_Weapon_RechargeableGrenade(Weapon) != none ) 
		Weapon.StartFire(0); 
}

simulated function FinishGrenadeThrow()
{
	
	Rx_InventoryManager(InvManager).SwitchToPreviousWeapon() ;	
}


function SetMoveDirection(EMoveDir dir) 
{
	moveDirection = dir;
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{ 
	if (!bDodging && bDodgeCapable && !IsTimerActive('DodgeCoolDownTimer') && Physics == Phys_Walking) {
		StopFiring();
		if (DeductStamina(DodgeStaminaCost))
		{
			
			if(bSprinting) {
				StopSprinting();
				bWasSprintingBeforeDodge = true; /*Client may overrite this on the server by calling (stopsprinting). For servers this is passed in the actual server call */
			}
			if(Rx_Weapon(Weapon).bIronsightActivated) {
				bWasInIronsightBeforeAction = true;
				Rx_Weapon(Weapon).EndZoom(UTPlayercontroller(Controller));
			} else {
				bWasInIronsightBeforeAction = false;
			}
			DoDodge(DoubleClickMove);
			
			if(WorldInfo.NetMode == NM_Client)
			{
				ServerDoDodge(DoubleClickMove, bWasSprintingBeforeDodge); 
			}
			
			return true;
		}
	}
	return false;
}

function DoDodge(eDoubleClickDir DoubleClickMove)
{
	local vector X,Y,Z;
	
	bDoingDodge = true;
	bDodging = true;
	
	WasInFirstPersonBeforeDodge = false;
	
		if(Rx_Controller(Controller) != None && !Rx_Controller(Controller).bBehindView) 
		{
			Rx_Controller(Controller).SetBehindView(true);
			WasInFirstPersonBeforeDodge = true;
		}
		
		//PlaySound(Snd_DodgeCue, false, true,,, true);
	
	if(Rx_weapon(Weapon) != none)
	{
		Rx_Weapon(Weapon).OnActionStart(); 
	}		
			
	
	SetHandIKEnabled(false);
	
	// finds global axes of pawn
	GetAxes(Rotation, X, Y, Z);

	// temporarily raise speeds
	AirSpeed = bWasSprintingBeforeDodge ? SprintDodgeSpeed : DodgeSpeed;
	GroundSpeed = bWasSprintingBeforeDodge ? SprintDodgeSpeed : DodgeSpeed;
	Velocity.Z = -default.GroundSpeed;

	`log("bWasSprinting:" @ bWasSprintingBeforeDodge @ AirSpeed @ GroundSpeed @ DoubleClickMove); 
	
	switch ( DoubleClickMove )
	{
		// dodge left
		case DClick_Left:
			DodgeVelocity = bWasSprintingBeforeDodge ? -SprintDodgeSpeed*Normal(Y) : -DodgeSpeed*Normal(Y);
			break;
		// dodge right
		case DClick_Right:
			DodgeVelocity = bWasSprintingBeforeDodge ? SprintDodgeSpeed*Normal(Y) : DodgeSpeed*Normal(Y);
			break;
		// dodge forward
		case DCLICK_Forward:
			DodgeVelocity = bWasSprintingBeforeDodge ? SprintDodgeSpeed*Normal(X) : DodgeSpeed*Normal(X);
			break;
		// dodge backward
		case DCLICK_Back:
			DodgeVelocity = bWasSprintingBeforeDodge ? -SprintDodgeSpeed*Normal(X) : -DodgeSpeed*Normal(X);
			break;
		// in case there is an error
		default:
		//	`log('DoDodge Error');
			break;
	}

	Velocity.X = DodgeVelocity.X;
	Velocity.Y = DodgeVelocity.Y;
	
//	LastVelZInDodge = 0.f;

//	SetPhysics(Phys_Flying); // gives the right physics
	bDodgeCapable = false; // prevent dodging mid dodge
	if(PlayerController(Controller) != None) {
		PlayerController(Controller).IgnoreMoveInput(true); //prevent the player from controlling pawn direction
	}
	TimeInDodge = 0.0f;
	SetTimer(DodgeDuration,false,'UnDodge'); //time until the dodge is done
	
	//calcDodgeAnim(DoubleClickMove);
	//SetCamOffset(DodgeCameraOffset);
	SetTimer(DodgeCoolDownTime, false, 'DodgeCoolDownTimer');
	playDodgeAnimation();	
}

reliable server function ServerDoDodge(eDoubleClickDir DoubleClickMove, bool bWithSprint)
{ 
	//Was trying sprint dodge? (Override if cleint already made us stop sprinting)
	bWasSprintingBeforeDodge = bWithSprint; 
	Dodge(DoubleClickMove);
}

reliable server function ServerUnDodge()
{
	UnDodge();
}

simulated function DodgeCoolDownTimer()
{
	//Do nothing
}; 

/**
 * The following function makes the Pawn follow the slope of stairs if he dodges down them
 */
function Dodging(float DeltaTime)
{
	local vector TraceStart;
	local vector TraceEnd1, TraceEnd2, TraceEnd3;
	//local float  DebugSpeedDiff;	
	local float  AirSpeedTemp;	
	local float  GroundSpeedTemp;	

	`log("DOOOOOOOOOOODGE!!!!!");
	if( !bDodging ) {
		return;	
	}
	
	
	TimeInDodge += DeltaTime;
	
	//all traces start slightly offset from center of pawn
	TraceStart = Location + 20*Normal(DodgeVelocity);

	//trace location for detecting objects just below pawn
	TraceEnd1 = TraceStart;
	TraceEnd1.Z -= 75;

	//trace location for detecting objects below pawn that are close
	TraceEnd2 = TraceStart;
	TraceEnd2.Z -= 120;

	//trace locations for detecting when pawn will fall off a ledge
	TraceEnd3 = TraceStart;
	TraceEnd3.Z -= 121;		

	if( FastTrace(TraceEnd1, TraceStart) && !FastTrace(TraceEnd2, TraceStart) ) //nothing is directly underneath the pawn and something is sort of uderneath the pawn
	{
		Velocity.Z = -default.DodgeSpeed; //push pawn down
	}
	
	if( FastTrace(TraceEnd3, TraceStart) ) //pawn is about to fall off a ledge
	{
		UnDodge();
	}
	else
	{
		//DebugSpeedDiff = AirSpeed;
		AirSpeedTemp = DodgeSpeed - FInterpEaseIn(0.0f, 0.8f, TimeInDodge, 1.5f) * DodgeSpeed;
		if(AirSpeedTemp > 0) {
			AirSpeed = AirspeedTemp;
		} else {
			AirSpeed = 0.f;
		}
		
		GroundSpeedTemp = DodgeSpeed - FInterpEaseIn(0.0f, 0.8f, TimeInDodge, 1.5f) * DodgeSpeed;
		if(GroundSpeedTemp > 0) {
			GroundSpeed = GroundSpeedTemp;
		} else {
			GroundSpeed = 0.f;
		}
		
		if(LastVelZInDodge != 0.f && LastVelZInDodge != Velocity.Z) {
			Airspeed += abs(LastVelZInDodge - Velocity.Z);
		} 
		
		LastVelZInDodge = Velocity.Z;
		
		//loginternal(AirSpeed);
		//loginternal("AirSpeed Diff: "@DebugSpeedDiff - AirSpeed);
	}
}

function UnDodge()
{	

	SetPhysics(Phys_Falling); //use falling instead of walking in case we are mid-air after the dodge
	bDodgeCapable = true;
	bDodging = false;
	
	if(Rx_weapon(Weapon) != none){
		Rx_Weapon(Weapon).OnActionStop(); 
	}	
	
	if(Controller != None && PlayerController(Controller) != None) {
		PlayerController(Controller).IgnoreMoveInput(false);
	}
	
	if(bWasSprintingBeforeDodge && WorldInfo.NetMode != NM_DedicatedServer){
		GroundSpeed = default.GroundSpeed * GetSpeedModifier() ;//(SpeedUpgradeMultiplier+GetRxFamilyInfo().default.Vet_SprintSpeedMod[VRank]) ;
		StartSprint();
	}
	else
	{
		GroundSpeed = default.GroundSpeed * GetSpeedModifier() ;//(SpeedUpgradeMultiplier+GetRxFamilyInfo().default.Vet_SprintSpeedMod[VRank]) ;
	}
	
	AirSpeed = default.AirSpeed*GetSpeedModifier();//SpeedUpgradeMultiplier * (SpeedUpgradeMultiplier+GetRxFamilyInfo().default.Vet_SprintSpeedMod[VRank]) ;
	
	DodgeNode.SetActiveChild(0,0.5);
	//SetCamOffset(default.CamOffset); 
	
	//DodgeAnim = '';
	if(WasInFirstPersonBeforeDodge) {
		if(Controller != None && PlayerController(Controller) != None && WorldInfo.NetMode != NM_DedicatedServer) {
			Rx_Controller(Controller).SetBehindView(false);
		}
	}
	
	if(bWasInIronsightBeforeAction && Rx_Weapon(Weapon) != None) {
		Rx_Weapon(Weapon).StartZoom(UTPlayercontroller(Controller));
	}
	
	bWasSprintingBeforeDodge = false;
	SetTimer( 0.2, false, 'ReEnableHandIKAfterDodge' );
	
	/**if(ROLE < Role_Authority)
		ServerUnDodge();*/ 
	bDoingDodge = false;
}

function ReEnableHandIKAfterDodge() {
	SetHandIKEnabled(true);	
}

function playDodgeAnimation()
{
	ReloadAnim = ''; // to notify remote clients (with repnotify) that they should stop reloadanimation if they play it
	BoltReloadAnim = '';
	DodgeGroupNode.PlayAnim(false, 1.0, 0.0);
	DodgeNode.SetActiveChild(1,0.2);
	//FullBodyAnimSlot.PlayCustomAnimByDuration( DodgeAnim, DodgeDuration + 0.2, 0.2, 0.2);
}

simulated function FaceRotation(rotator NewRotation, float DeltaTime)
{
	if(!bDodging) {
		super.FaceRotation(NewRotation, DeltaTime); 
	}
}

final simulated function SetOfflineChar(byte CharNum)
{
	local int i;
	
	if(Controller != None) {
		Controller.Possess(self,false);	
	}
	
	for (i = 0; i < Mesh.SkeletalMesh.Materials.length; i++) {
		Mesh.SetMaterial( i, None );
	}
	
}

simulated function resetZoom()
{
	if(Rx_Weapon(Weapon) == None || Rx_Controller(Controller) == None)
		return;
	if(Rx_Weapon(Weapon).bIronsightActivated || (!Rx_Weapon(Weapon).bIronSightCapable && Controller != None && Rx_Controller(Controller).bZoomed))
	{		
		if(Rx_Weapon(Weapon).bIronSightCapable && bWasInThirdPersonBeforeIronsight)
		{
			Rx_Weapon(Weapon).bIronsightActivated = false;
			if(Controller != None && Rx_Controller(Controller).bZoomed) {
				Rx_Controller(Controller).SetOurCameraMode(ThirdPerson);
			}
		}
		Rx_Weapon(Weapon).EndZoom(UTPlayercontroller(Controller));
	}
}

/** one1: Modified; custom inventory manager spawning */
simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info) {

	local int i;
	local class<UTFamilyInfo> prev;
	local array<class<Rx_Weapon> > prevItems;
	local class<Rx_Weapon> weapClass;

	prev = CurrCharClassInfo;

	resetZoom();

	super.SetCharacterClassFromInfo(Info);
	
	if(Mesh.SkeletalMesh != None) {
		for (i = 0; i < Mesh.SkeletalMesh.Materials.length; i++) {
			Mesh.SetMaterial( i, None );
		} 
	}

	/** one1: Set inventory manager according to family info class. */
	if (Role == ROLE_Authority)
	{
		//Reseed Taunts 
		ReseedVoiceOvers(); 
		
		
		if (prev == Info)
			return; // no changes, skip

		if (InvManager != none)
		{
			prevItems = Rx_InventoryManager(InvManager).GetWeaponsOfClassification(CLASS_ITEM);
			InvManager.Destroy();
		}

		InventoryManagerClass = class<Rx_FamilyInfo>(Info).default.InvManagerClass;

		InvManager = Spawn(InventoryManagerClass, self);
		InvManager.SetupFor(self);
		foreach prevItems(weapClass)
		{
			Rx_InventoryManager(InvManager).AddWeaponOfClass(weapClass, CLASS_ITEM);
		}
		
	}		
}

simulated event StartDriving(Vehicle V)
{
	local Actor StealthedActor;
	local Controller cntrl;
	
	resetZoom();

	if(lastRxPawnOutCamLoc != vect(0,0,0))
	{
	    if(Rx_Vehicle(V) != None)
	    {    
	        Rx_Vehicle(V).VehiclePawnTransitionStartLoc = lastRxPawnOutCamLoc;
			Rx_Vehicle(V).BlendPct = 0.0f;
	    }
	    else if(Rx_VehicleSeatPawn(V) != None)
	    {
	        Rx_Vehicle(Rx_VehicleSeatPawn(V).MyVehicle).VehiclePawnTransitionStartLoc = lastRxPawnOutCamLoc;
			Rx_Vehicle(Rx_VehicleSeatPawn(V).MyVehicle).BlendPct = 0.0f;
	    }	

	    lastRxPawnOutCamLoc = vect(0,0,0);
	}
	
	super.StartDriving(V);
	
	if(Rx_Weapon_Charged(Weapon) != none) 
		Rx_Weapon_Charged(Weapon).StopFire(0); 
	
	ClearTimer('UpdatePRILocation'); 
	
	if(Controller != None)
	{
		cntrl = Controller;
		
		if(Rx_Controller(Controller) != none && Rx_Controller(Controller).Vet_Menu != none ) 
		{
			Rx_Controller(Controller).DestroyOldVetMenu(); //Kill Vet menu on start driving
		}
	} 
	else 
	{
		cntrl = V.Controller;
	}
	if(cntrl != None && WorldInfo.NetMode != NM_DedicatedServer && cntrl.IsLocalPlayerController()) {
		foreach DynamicActors(class'Actor', StealthedActor, class'RxIfc_Stealth') {
			if(cntrl.GetTeamNum() != StealthedActor.GetTeamNum()) {
				RxIfc_Stealth(StealthedActor).ChangeStealthVisibilityParam(false);    
			}
		} 
	}	
}

simulated event StopDriving(Vehicle V)
{
    local Actor StealthedActor;
    local Controller cntrl;
    

	if(DamageRate > 0)
		DelayRegen();				//HANDEPSILON - Immediately try to fade out the remaining vignette
	
	OldPositions.Length = 0;
    if(Rx_Vehicle(V) != None)
    {    
    	VehiclePawnTransitionStartLoc = Rx_Vehicle(V).CalcViewLocation;
    }
    else if(Rx_VehicleSeatPawn(V) != None)
    {
    	VehiclePawnTransitionStartLoc = Rx_Vehicle(Rx_VehicleSeatPawn(V).MyVehicle).CalcViewLocation;
    }

	BlendPct = 0.0f;

	if(V.health == 0)
		BlendSpeed = 0.6f;
	else
		BlendSpeed = 0.4f;	

	super.StopDriving(V);

	if(Rx_Weapon_RepairGun(Weapon) != None) 
	{
		if(Rx_Weapon_RepairGun(Weapon).BeamEmitter[0] != None) 
		{
			Rx_Weapon_RepairGun(Weapon).BeamEmitter[0].SetHidden(true);	
			Rx_Weapon_RepairGun(Weapon).BeamEmitter[0].DeactivateSystem();	
		}
		if(Rx_Weapon_RepairGun(Weapon).BeamEmitter[1] != None)
		{
			Rx_Weapon_RepairGun(Weapon).BeamEmitter[1].SetHidden(true);	
			Rx_Weapon_RepairGun(Weapon).BeamEmitter[1].DeactivateSystem();
		}
	}
	super.StopDriving(V);

	if(Controller != None)
	{
		cntrl = Controller;
		
		if(Rx_Controller(Controller) != none && Rx_Controller(Controller).Vet_Menu != none ) 
		{
			Rx_Controller(Controller).DestroyOldVetMenu(); //Kill Vet menu on stop driving 
		}
	} 
	else
	{
		cntrl = V.Controller;
	}	
    if(cntrl != None && WorldInfo.NetMode != NM_DedicatedServer && cntrl.IsLocalPlayerController()) {
	    foreach DynamicActors(class'Actor', StealthedActor, class'RxIfc_Stealth') {
			if(cntrl.GetTeamNum() != StealthedActor.GetTeamNum()) {
				RxIfc_Stealth(StealthedActor).ChangeStealthVisibilityParam(true);    
			}
		} 
    }	
    
	//`log("Log stopped driving"); 
	if(ROLE == ROLE_Authority && Rx_Controller(Controller) != none) 
	{
		if(Rx_Weapon(Weapon) != none) 
			Rx_Weapon(Weapon).bIronsightActivated=false; //Get rid of of ironsights when they leave.
		
		SetRadarVisibility(Rx_Controller(Controller).GetRadarVisibility()); 
		CheckVRank(); 
		Rx_Controller(Controller).UpdateModifiedStats();
		Rx_PRI(Controller.PlayerReplicationInfo).RemoveVehicleClass(); 
		SetTimer(0.05, true, 'UpdatePRILocation'); 
	}
	else
	if(ROLE == ROLE_Authority && Rx_Bot(Controller) != none) 
	{
		SetRadarVisibility(Rx_Bot(Controller).GetRadarVisibility());
		CheckVRank(); 
		Rx_Bot(Controller).UpdateModifiedStats();
		Rx_PRI(Controller.PlayerReplicationInfo).RemoveVehicleClass(); 
		SetTimer(0.1, true, 'UpdatePRILocation'); 
	}
	
    if(Rx_Bot(Controller) != None && Physics == PHYS_Falling)
    	SetTimer(FRand()+0.5f,false,'TryParachute');	
}

simulated function string GetCharacterClassName()
{
	local class<Rx_FamilyInfo> fam;
	fam = class<Rx_FamilyInfo>( GetFamilyInfo());
	return fam.default.CharacterName;
}

simulated function string GetTargetedName(PlayerController PlayerPerspective)
{
	return GetCharacterClassName();
}

simulated function ProcessViewRotation( float DeltaTime, out rotator out_ViewRotation, out Rotator out_DeltaRot )
{
	if(Weapon != None)
	{
		Rx_Weapon(Weapon).ProcessViewRotation(DeltaTime, out_ViewRotation, out_DeltaRot);
	}
	
	out_ViewRotation += out_DeltaRot;
	out_DeltaRot = rot(0,0,0);
	
	if(PlayerController(Controller) != None)
	{
		out_ViewRotation = PlayerController(Controller).LimitViewRotation(out_ViewRotation, ViewPitchMin, ViewPitchMax);
	}
}

function bool IsInPain()
{
	local Rx_Volume_Tiberium V;

	if(super.IsInPain())
		return true;
		
	ForEach TouchingActors(class'Rx_Volume_Tiberium',V)
			return true;
	return false;
}

/**
 * Responsible for playing any death effects, animations, etc.
 *
 * @param 	DamageType - type of damage responsible for this pawn's death
 *
 * @param	HitLoc - location of the final shot
 */
simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local vector ApplyImpulse, ShotDir;
	local TraceHitInfo HitInfo;
	local PlayerController PC;
	local bool bPlayersRagdoll, bUseHipSpring;
	local class<UTDamageType> UTDamageType;
	local RB_BodyInstance HipBodyInst;
	local int HipBoneIndex;
	local matrix HipMatrix;
	local class<UDKEmitCameraEffect> CameraEffect;
	local name HeadShotSocketName;
	local SkeletalMeshSocket SMS;

	bCanTeleport = false;
	bReplicateMovement = false;
	bTearOff = true;
	bPlayedDeath = true;
	bForcedFeignDeath = false;
	bPlayingFeignDeathRecovery = false;

	HitDamageType = DamageType; // these are replicated to other clients
	TakeHitLocation = HitLoc;

	if(bDodging)
	{
		UnDodge();
	}

	if ( WorldInfo.NetMode == NM_DedicatedServer )
	{
 		UTDamageType = class<UTDamageType>(DamageType);
		// tell clients whether to gib
		bTearOffGibs = (UTDamageType != None && ShouldGib(UTDamageType));
		bGibbed = bGibbed || bTearOffGibs;
		GotoState('Dying');
		return;
	}

	/** one1: added: hide 1st person arms in MP game */
	if(ArmsMesh[0] != none)
	{
		ArmsMesh[0].SetHidden(true);
	}
	if(ArmsMesh[1] != none)
	{
		ArmsMesh[1].SetHidden(true);
	}

	// Is this the local player's ragdoll?
	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		if( PC.ViewTarget == self )
		{
			if ( Rx_Hud(PC.MyHud) != none )
				Rx_Hud(PC.MyHud).DisplayHit(HitLoc, 100, DamageType);

			bPlayersRagdoll = true;
			break;
		}
	}
	if ( (WorldInfo.TimeSeconds - LastRenderTime > 3) && !bPlayersRagdoll )
	{
		if (WorldInfo.NetMode == NM_ListenServer || WorldInfo.IsRecordingDemo())
		{
			if (WorldInfo.Game.NumPlayers + WorldInfo.Game.NumSpectators < 2 && !WorldInfo.IsRecordingDemo())
			{
				Destroy();
				return;
			}
			bHideOnListenServer = true;

			// check if should gib (for clients)
			UTDamageType = class<UTDamageType>(DamageType);
			if (UTDamageType != None && ShouldGib(UTDamageType))
			{
				bTearOffGibs = true;
				bGibbed = true;
			}
			TurnOffPawn();
			return;
		}
		else
		{
			// if we were not just controlling this pawn,
			// and it has not been rendered in 3 seconds, just destroy it.
			Destroy();
			return;
		}
	}

	UTDamageType = class<UTDamageType>(DamageType);

	if (UTDamageType != None && !class'UTGame'.static.UseLowGore(WorldInfo) && ShouldGib(UTDamageType))
	{
			SpawnGibs(UTDamageType, HitLoc);
	}
	else
	{
		CheckHitInfo( HitInfo, Mesh, Normal(TearOffMomentum), TakeHitLocation );

		// check to see if we should do a CustomDamage Effect
		if( UTDamageType != None )
		{
			if( UTDamageType.default.bUseDamageBasedDeathEffects )
			{
				UTDamageType.static.DoCustomDamageEffects(self, UTDamageType, HitInfo, TakeHitLocation);
			}

			if( UTPlayerController(PC) != none )
			{
				CameraEffect = UTDamageType.static.GetDeathCameraEffectVictim(self);
				if (CameraEffect != None)
				{
					UTPlayerController(PC).ClientSpawnCameraEffect(CameraEffect);
				}
			}
		}

		bBlendOutTakeHitPhysics = false;

		// Turn off hand IK when dead.
		SetHandIKEnabled(false);

		// if we had some other rigid body thing going on, cancel it
		if (Physics == PHYS_RigidBody)
		{
			//@note: Falling instead of None so Velocity/Acceleration don't get cleared
			SetPhysics(PHYS_Falling);
		}

		PreRagdollCollisionComponent = CollisionComponent;
		CollisionComponent = Mesh;

		Mesh.MinDistFactorForKinematicUpdate = 0.f;

		// If we had stopped updating kinematic bodies on this character due to distance from camera, force an update of bones now.
		if( Mesh.bNotUpdatingKinematicDueToDistance )
		{
			Mesh.ForceSkelUpdate();
			Mesh.UpdateRBBonesFromSpaceBases(TRUE, TRUE);
		}

		Mesh.PhysicsWeight = 1.0;

		if(UTDamageType != none && UTDamageType.default.DeathAnim != '' && (FRand() > 0.5) )
		{
			// Don't want to use stop player and use hip-spring if in the air (eg PHYS_Falling)
			if(Physics == PHYS_Walking && UTDamageType.default.bAnimateHipsForDeathAnim)
			{
			    Mesh.PhysicsWeight = 0.0;
				SetPhysics(PHYS_None);
				bUseHipSpring=true;
			}
			else
			{
                SetPhysics(PHYS_RigidBody);
				// We only want to turn on 'ragdoll' collision when we are not using a hip spring, otherwise we could push stuff around.
				SetPawnRBChannels(TRUE);
			}

			Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);

			// Turn off angular motors on skeleton.
			Mesh.bUpdateJointsFromAnimation = True;
			Mesh.PhysicsAssetInstance.SetNamedMotorsAngularPositionDrive(false, false, NoDriveBodies, Mesh, true);
			Mesh.PhysicsAssetInstance.SetAngularDriveScale(1.0f, 1.0f, 0.0f);

			// If desired, turn on hip spring to keep physics character upright
			if(bUseHipSpring)
			{
				HipBodyInst = Mesh.PhysicsAssetInstance.FindBodyInstance('b_Spine_1', Mesh.PhysicsAsset);
				HipBoneIndex = Mesh.MatchRefBone('b_Spine_1');
				HipMatrix = Mesh.GetBoneMatrix(HipBoneIndex);
				HipBodyInst.SetBoneSpringParams(DeathHipLinSpring, DeathHipLinDamp, DeathHipAngSpring, DeathHipAngDamp);
				HipBodyInst.bMakeSpringToBaseCollisionComponent = FALSE;
				HipBodyInst.EnableBoneSpring(True, True, HipMatrix);
				HipBodyInst.bDisableOnOverextension = TRUE;
				HipBodyInst.OverextensionThreshold = 100.f;
			}

			FullBodyAnimSlot.PlayCustomAnim( UTDamageType.default.DeathAnim, UTDamageType.default.DeathAnimRate, 0.05, -1.0, false, false);

			SetTimer(0.1, true, 'DoingDeathAnim');
			StartDeathAnimTime = WorldInfo.TimeSeconds;
			TimeLastTookDeathAnimDamage = WorldInfo.TimeSeconds;
			DeathAnimDamageType = UTDamageType;
		}
		else
		{
			SetPhysics(PHYS_RigidBody);
			Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);
			SetPawnRBChannels(TRUE);

			/** one1: added */
			Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume, FALSE);
			Mesh.SetRBCollidesWithChannel(RBCC_Pawn, FALSE);
			Mesh.SetRBCollidesWithChannel(RBCC_Vehicle, FALSE);

			if( TearOffMomentum != vect(0,0,0) )
			{
				ShotDir = normal(TearOffMomentum);
				ApplyImpulse = ShotDir * DamageType.default.KDamageImpulse;

				// If not moving downwards - give extra upward kick
				if ( Velocity.Z > -10 )
				{
					ApplyImpulse += Vect(0,0,1)*DamageType.default.KDeathUpKick;
				}
				Mesh.AddImpulse(ApplyImpulse, TakeHitLocation, HitInfo.BoneName, true);
			}
		}
		GotoState('Dying');

		if (WorldInfo.NetMode != NM_DedicatedServer && UTDamageType != None && UTDamageType.default.bSeversHead && !bDeleteMe)
		{
			SpawnHeadGib(UTDamageType, HitLoc);

			if ( !class'UTGame'.static.UseLowGore(WorldInfo) )
			{
				HeadShotSocketName = GetFamilyInfo().default.HeadShotGoreSocketName;
				SMS = Mesh.GetSocketByName( HeadShotSocketName );
				if( SMS != none )
				{
					HeadshotNeckAttachment = new(self) class'StaticMeshComponent';
					HeadshotNeckAttachment.SetActorCollision( FALSE, FALSE );
					HeadshotNeckAttachment.SetBlockRigidBody( FALSE );

					Mesh.AttachComponentToSocket( HeadshotNeckAttachment, HeadShotSocketName );
					HeadshotNeckAttachment.SetStaticMesh( GetFamilyInfo().default.HeadShotNeckGoreAttachment );
					HeadshotNeckAttachment.SetLightEnvironment( LightEnvironment );
				}
			}
		}
	}

	LeftLegControl.SetSkelControlActive(false);
	RightLegControl.SetSkelControlActive(false);
}

simulated function DoingDeathAnim()
{
	local RB_BodyInstance HipBodyInst;
	local matrix DummyMatrix;
	local AnimNodeSequence SlotSeqNode;
	local float TimeSinceDeathAnimStart, MotorScale;
	local bool bStopAnim;

	if(DeathAnimDamageType.default.MotorDecayTime != 0.0)
	{
		TimeSinceDeathAnimStart = WorldInfo.TimeSeconds - StartDeathAnimTime;
		MotorScale = 1.0 - (TimeSinceDeathAnimStart/DeathAnimDamageType.default.MotorDecayTime);

		// If motors are scaled to zero, stop death anim
		if(MotorScale <= 0.0)
		{
			bStopAnim = TRUE;
		}
		// If non-zero, scale motor strengths
		else
		{
			Mesh.PhysicsAssetInstance.SetAngularDriveScale(MotorScale, MotorScale, 0.0f);
		}
	}

	// If we want to stop animation after a certain
	if( DeathAnimDamageType != None &&
		DeathAnimDamageType.default.StopAnimAfterDamageInterval != 0.0 &&
		(WorldInfo.TimeSeconds - TimeLastTookDeathAnimDamage) > DeathAnimDamageType.default.StopAnimAfterDamageInterval )
	{
		bStopAnim = TRUE;
	}


	// If done playing custom death anim - turn off bone motors.
	SlotSeqNode = AnimNodeSequence(FullBodyAnimSlot.Children[1].Anim);

	if(!SlotSeqNode.bPlaying || bStopAnim)
	{
        Mesh.PhysicsWeight = 1.0;
		SetPhysics(PHYS_RigidBody);
		Mesh.PhysicsAssetInstance.SetAllMotorsAngularPositionDrive(false, false);
		HipBodyInst = Mesh.PhysicsAssetInstance.FindBodyInstance('b_Spine_1', Mesh.PhysicsAsset);
		HipBodyInst.EnableBoneSpring(FALSE, FALSE, DummyMatrix);

		// Ensure we have ragdoll collision on at this point
		SetPawnRBChannels(TRUE);

		ClearTimer('DoingDeathAnim');
		//ThrowWeaponOnDeath();
	}
}

function float GetAimAheadModifier() {
	return SeekAimAheadModifier;
}

function float GetAccelrateModifier() {
	return SeekAccelrateModifier;
}

exec function ToggleThirdPersonEyeheightBob() { 
	bUpdate3rdPersonEyeHeightBob = !bUpdate3rdPersonEyeHeightBob; 
}

/* UpdateEyeHeight()
* Update player eye position, based on smoothing view while moving up and down stairs, and adding view bobs for landing and taking steps.
* Called every tick only if bUpdateEyeHeight==true.
*/
event UpdateEyeHeight( float DeltaTime )
{
	local float smooth, MaxEyeHeight, OldEyeHeight, Speed2D, OldBobTime;
	local Actor HitActor;
	local vector HitLocation,HitNormal, X, Y, Z;
	local int m,n;	

	if ( bTearOff )
	{
		// no eyeheight updates if dead
		EyeHeight = Default.BaseEyeheight;
		bUpdateEyeHeight = false;
		return;
	}

	if ( abs(Location.Z - OldZ) > 15 )
	{
		// if position difference too great, don't do smooth land recovery
		bJustLanded = false;
		bLandRecovery = false;
	}

	if ( !bJustLanded )
	{
		// normal walking around
		// smooth eye position changes while going up/down stairs
		smooth = FMin(0.9, 10.0 * DeltaTime/CustomTimeDilation);
		LandBob *= (1 - smooth);
		if( Physics == PHYS_Walking || Physics==PHYS_Spider || Controller.IsInState('PlayerSwimming') )
		{
			OldEyeHeight = EyeHeight;
			EyeHeight = FMax((EyeHeight - Location.Z + OldZ) * (1 - smooth) + BaseEyeHeight * smooth,
								-0.5 * CylinderComponent.CollisionHeight);
		}
		else
		{
			EyeHeight = EyeHeight * ( 1 - smooth) + BaseEyeHeight * smooth;
		}

		if (Physics == PHYS_Walking)
			CameraSmoothZOffset = FMax((CameraSmoothZOffset - Location.Z + OldZ) * (1 - smooth),
								 -0.5 * CylinderComponent.CollisionHeight);
		else
			CameraSmoothZOffset = 0;

		if (Mesh != none && CurrCharClassInfo != none)
		{
			Mesh.SetTranslation(vect(0,0,1) * CurrCharClassInfo.Default.BaseTranslationOffset + vect(0,0,1) * CameraSmoothZOffset);

			if (bIsCrouched)
				Mesh.SetTranslation(Mesh.Translation + vect(0,0,1) *(CylinderComponent.Default.CollisionHeight - CrouchHeight));
		}

	}
	else if ( bLandRecovery )
	{
		// return eyeheight back up to full height
		if(IsFirstPerson())
		    smooth = FMin(0.9, 9.0 * DeltaTime);
		else 
            smooth = FMin(0.9, 6.0 * DeltaTime);
		OldEyeHeight = EyeHeight;
		LandBob *= (1 - smooth);
		// linear interpolation at end
		if ( Eyeheight > 0.9 * BaseEyeHeight )
		{
			Eyeheight = Eyeheight + 0.15*BaseEyeheight*Smooth;  // 0.15 = (1-0.75)*0.6
		}
		else
			EyeHeight = EyeHeight * (1 - 0.6*smooth) + BaseEyeHeight*0.6*smooth;
		if ( Eyeheight >= BaseEyeheight)
		{
			bJustLanded = false;
			bLandRecovery = false;
			Eyeheight = BaseEyeheight;
		}
	}
	else
	{
		
		// drop eyeheight a bit on landing
		if(IsFirstPerson())
		    smooth = FMin(0.65, 8.0 * DeltaTime);
		else 
		    smooth = FMin(0.65, 4.0 * DeltaTime);
		OldEyeHeight = EyeHeight;
		EyeHeight = EyeHeight * (1 - 1.5*smooth);
		LandBob += 0.08 * (OldEyeHeight - Eyeheight);
		if(IsFirstPerson())
		{
			if ( (Eyeheight < 0.25 * BaseEyeheight + 1) || (LandBob > 2.4)  )
			{
				bLandRecovery = true;
				Eyeheight = 0.25 * BaseEyeheight + 1;
			}
		}	
		else if(bUpdate3rdPersonEyeHeightBob)
		{
			if ( (Eyeheight < 0.75 * BaseEyeheight + 1) || (LandBob > 2.4)  )
			{
				bLandRecovery = true;
				Eyeheight = 0.75 * BaseEyeheight + 1;
			}
		}	
	}

	// don't bob if disabled, or just landed
	if( bJustLanded || !bUpdateEyeheight )
	{
		BobTime = 0;
		WalkBob = Vect(0,0,0);
	}
	else
	{
		// add some weapon bob based on jumping
		if ( Velocity.Z > 0 )
		{
		  JumpBob = FMax(-1.5, JumpBob - 0.03 * DeltaTime * FMin(Velocity.Z,300));
		}
		else
		{
		  JumpBob *= (1 -  FMin(1.0, 8.0 * DeltaTime));
		}

		// Add walk bob to movement
		OldBobTime = BobTime;
		Bob = FClamp(Bob, -0.05, 0.05);

		if (Physics == PHYS_Walking )
		{
		  GetAxes(Rotation,X,Y,Z);
		  Speed2D = VSize(Velocity);
		  if ( Speed2D < 10 )
			  BobTime += 0.2 * DeltaTime;
		  else
			  BobTime += DeltaTime * (0.3 + 0.7 * Speed2D/GroundSpeed);
		  WalkBob = Y * Bob * Speed2D * sin(8 * BobTime);
		  AppliedBob = AppliedBob * (1 - FMin(1, 16 * deltatime));
		  WalkBob.Z = AppliedBob;
		  if ( Speed2D > 10 )
			  WalkBob.Z = WalkBob.Z + 0.75 * Bob * Speed2D * sin(16 * BobTime);
		}
		else if ( Physics == PHYS_Swimming )
		{
		  GetAxes(Rotation,X,Y,Z);
		  BobTime += DeltaTime;
		  Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
		  WalkBob = Y * Bob *  0.5 * Speed2D * sin(4.0 * BobTime);
		  WalkBob.Z = Bob * 1.5 * Speed2D * sin(8.0 * BobTime);
		}
		else
		{
		  BobTime = 0;
		  WalkBob = WalkBob * (1 - FMin(1, 8 * deltatime));
		}

		if ( (Physics == PHYS_Walking) && (VSizeSq(Velocity) > 100) && IsFirstPerson() )
		{
			m = int(0.5 * Pi + 9.0 * OldBobTime/Pi);
			n = int(0.5 * Pi + 9.0 * BobTime/Pi);

			if ( (m != n) && !bIsWalking && !bIsCrouched )
			{
			  ActuallyPlayFootStepSound(0);
			}
		}
		if ( !bWeaponBob )
		{
			WalkBob *= 0.1;
		}
	}
	if ( (CylinderComponent.CollisionHeight - Eyeheight < 12) && IsFirstPerson() )
	{
	  // desired eye position is above collision box
	  // check to make sure that viewpoint doesn't penetrate another actor
		// min clip distance 12
		if (bCollideWorld)
		{
			HitActor = trace(HitLocation,HitNormal, Location + WalkBob + (MaxStepHeight + CylinderComponent.CollisionHeight) * vect(0,0,1),
						  Location + WalkBob, true, vect(12,12,12),, TRACEFLAG_Blocking);
			MaxEyeHeight = (HitActor == None) ? CylinderComponent.CollisionHeight + MaxStepHeight : HitLocation.Z - Location.Z;
			Eyeheight = FMin(Eyeheight, MaxEyeHeight);
		}
	}
}


simulated function UpdateEyeHeightDemo( float DeltaTime )
{
	local int i;
	local float median;

	OldZ = Location.Z;
	
	if(SavedLocationZIter++ > 3)
		SavedLocationZIter = 0;
	SavedLocationZ[SavedLocationZIter] = Location.Z;
	
	for(i = 0; i < 5; i++)
	{
		median += SavedLocationZ[i];	
	}
	EyeHeight = BaseEyeHeight + (median/5 - Location.Z);
	
	CameraSmoothZOffset = median/5 - Location.Z;
	if(weapon == none && Weapon(InvManager.InventoryChain) != None)
		weapon = Weapon(InvManager.InventoryChain);
}

/* Debug commands for setting up the dynamic camera offset
exec function CamLowAngle(int i) { CamLowAngleStart = i; }
exec function CamLowOffset(int i) { CamLowOffsetMax = i; }
exec function CamHighAngle(int i) { CamHighAngleStart = i; }
exec function CamHighOffset(int i) { CamHighOffsetMax = i; }
exec function CamPrint() {
	`log("Current Pitch: "$CurrentCamPitch);
}*/

simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	super.CalcCamera(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);

	if(!bFixedView && IsFirstPerson())
	{
		if(VehiclePawnTransitionStartLoc != vect(0,0,0) && BlendPct < 1.0f)
		{
			if(WorldInfo.NetMode != NM_DedicatedServer) 
			{
				SetHidden(true);
			    if (Weapon != None)
			    {
			        Weapon.SetHidden(true);
			    }
			}
			if(fDeltaTime != 1.0f)
			{
				BlendPct += fDeltaTime/BlendSpeed;
				out_CamLoc = VLerp(VehiclePawnTransitionStartLoc,  out_CamLoc, BlendPct);
			}	
		} else 
		{
			if(VehiclePawnTransitionStartLoc != vect(0,0,0) && WorldInfo.NetMode != NM_DedicatedServer) 
			{
				SetHidden(false);
			    if (Weapon != None && (Rx_Weapon(Weapon).GetZoomedState() == ZST_NotZoomed || Rx_Weapon(Weapon).bIronsightActivated))
			    {
			        Weapon.SetHidden(false);
			    }				
			}
			VehiclePawnTransitionStartLoc = vect(0,0,0);
		}
		lastRxPawnOutCamLoc = out_CamLoc;		
	}
	return true;
}	

simulated function bool CalcThirdPersonCam( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	local vector DesiredCamStart, CamStart, CamEnd, HitLocation, HitNormal, CamDirX, CamDirY, CamDirZ, CurrentCamOffset, AngleOffset;
	local float DesiredCameraZOffset;

	if(WorldInfo.IsPlayingDemo() && fDeltaTime > 0)
	{
		UpdateEyeHeightDemo(fDeltaTime); 
	}
		
	ModifyRotForDebugFreeCam(out_CamRot);

	DesiredCamStart = Location;
	// Always start from the bottom of collision so change in collision size doesn't affect the camera.
	DesiredCamStart.Z -= GetCollisionHeight();
	CurrentCamOffset = CamOffset;
	
	// SmoothCam for going up and down stairs.
	DesiredCamStart.Z += CameraSmoothZOffset;
	if(bUpdate3rdPersonEyeHeightBob)
	    DesiredCamStart.Z += Eyeheight - BaseEyeheight;
	
	if ( bWinnerCam )
	{
		// use "hero" cam
		SetHeroCam(out_CamRot);
		CurrentCamOffset = vect(0,0,0);
		CurrentCamOffset.X = GetCollisionRadius();
	}
	else
	{
		DesiredCameraZOffset = (bIsCrouched) ? CamStartCrouchZHeight : CamStartZHeight;
		
		if (GetRxFamilyInfo() != none)
			DesiredCameraZOffset += GetRxFamilyInfo().default.CameraHeightModifier;
		
		if(bDodging)
			DesiredCameraZOffset += DodgeCameraZOffset; 

		CameraZOffset = Lerp(CameraZOffset,DesiredCameraZOffset,FClamp(fDeltaTime * 10.0f,0,1)) ;//(CameraZOffset >= CamStartCrouchZHeight && CameraZOffset <= CamStartZHeight) ? Lerp(CameraZOffset,DesiredCameraZOffset,FClamp(fDeltaTime * 10.0f,0,1)) : DesiredCameraZOffset;
		if ( Health <= 0 )
		{
			CurrentCamOffset = vect(0,0,0);
			CurrentCamOffset.X = GetCollisionRadius();
		}
	}
	DesiredCamStart.Z += CameraZOffset;	

	CurrentCamPitch = out_CamRot.Pitch;
	AngleOffset = vect(0,0,0);
	if (out_CamRot.Pitch <= `PITCH_LOWEST)
	{
		if (out_CamRot.Pitch > CamLowAngleStart)
			AngleOffset.Z = ((out_CamRot.Pitch - CamLowAngleStart) / (`PITCH_LOWEST - CamLowAngleStart)) * CamLowOffsetMax;
	}
	else
	{
		if ( out_CamRot.Pitch < CamHighAngleStart )
			AngleOffset.Z = Abs((out_CamRot.Pitch - CamHighAngleStart) / (`PITCH_HIGHEST - CamHighAngleStart)) * CamHighOffsetMax;
	}
	DesiredCamStart += AngleOffset >> out_CamRot;
	
	// Smooth cam start from prev locations.
	CamStart = GetSmoothedCamStart(DesiredCamStart);

	GetAxes(out_CamRot, CamDirX, CamDirY, CamDirZ);
	CamDirX *= CurrentCameraScale;

	if ( (Health <= 0) || bFeigningDeath )
	{
		// adjust camera position to make sure it's not clipping into world
		// @todo fixmesteve.  Note that you can still get clipping if FindSpot fails (happens rarely)
		FindSpot(GetCollisionExtent(),CamStart);
	}
	if (CurrentCameraScale < CameraScale)
	{
		CurrentCameraScale = FMin(CameraScale, CurrentCameraScale + 5 * FMax(CameraScale - CurrentCameraScale, 0.3)*fDeltaTime);
	}
	else if (CurrentCameraScale > CameraScale)
	{
		CurrentCameraScale = FMax(CameraScale, CurrentCameraScale - 5 * FMax(CameraScale - CurrentCameraScale, 0.3)*fDeltaTime);
	}
	if (CamDirX.Z > GetCollisionHeight())
	{
		CamDirX *= square(cos(out_CamRot.Pitch * 0.0000958738)); // 0.0000958738 = 2*PI/65536
	}
	
	if (ParachuteDeployed && CurrentParachuteCamDistMod < ParachuteCamDistMod)
	{
		CurrentParachuteCamDistMod = Lerp(CurrentParachuteCamDistMod,ParachuteCamDistMod,FClamp(fDeltaTime*3,0,1));
		CurrentCamOffset.X += CurrentParachuteCamDistMod;
	}
	else if (!ParachuteDeployed && CurrentParachuteCamDistMod > 0)
	{
		CurrentParachuteCamDistMod = Lerp(CurrentParachuteCamDistMod,0,FClamp(fDeltaTime,0,1));
		CurrentCamOffset.X += CurrentParachuteCamDistMod;
	}
	else
	{
		CurrentCamOffset.X += CurrentParachuteCamDistMod;
	}
	
	out_CamLoc = CamStart - CamDirX* CurrentCamOffset.X+ CurrentCamOffset.Y*CamDirY + CurrentCamOffset.Z*CamDirZ;

	CamStart.z -= 30;
	CamEnd = out_CamLoc;
	CamEnd.z -= 30;

	if(VehiclePawnTransitionStartLoc == vect(0,0,0))
	{
		if (!FastTrace(CamEnd,CamStart))
		{
			CamStart.z += 30;
			if (Trace(HitLocation, HitNormal, out_CamLoc, DesiredCamStart, false, vect(12,12,12)) != None) {
				out_CamLoc = HitLocation;
				if(VSizeSq(location-out_CamLoc) < 3025.0)
				{
					if(WorldInfo.NetMode != NM_DedicatedServer)
						SetHidden(true); // when cam gets near to prevent the cam showing the inside of the character	
				}
				else if(WorldInfo.NetMode != NM_DedicatedServer)
					SetHidden(false);

				return false;
			} else if(WorldInfo.NetMode != NM_DedicatedServer)
				SetHidden(false);
		} else if(WorldInfo.NetMode != NM_DedicatedServer)
			SetHidden(false);
	}

	if(VehiclePawnTransitionStartLoc != vect(0,0,0) && BlendPct < 1.0f)
	{
		if(fDeltaTime != 1.0f)
		{
			BlendPct += fDeltaTime/BlendSpeed;
			out_CamLoc = VLerp(VehiclePawnTransitionStartLoc,  out_CamLoc, BlendPct);
		}	
	} else 
	{
		VehiclePawnTransitionStartLoc = vect(0,0,0);
	}
	lastRxPawnOutCamLoc = out_CamLoc;
	return true;
}

simulated function SetCamOffset(vector Offset){
	CamOffset = Offset;
}

simulated function vector GetSmoothedCamStart(vector DesiredStart)
{
	local int i, len, obsolete;
	local vector CamStart;
	local TimePosition NewPos, PrevPos;
	local float DeltaTime;

	// If we've already updated the cameraoffset, just return it
	len = OldPositions.Length;

	if (len > 0 && OldPositions[len-1].Time == WorldInfo.TimeSeconds)
	{
		return CameraOffset + DesiredStart;
	}

	CamStart = DesiredStart;
	if (CameraLag == 0 || (!IsHumanControlled() && !WorldInfo.IsPlayingDemo()))
	{
		return CamStart;
	}

	// cache our current location
	NewPos.Time = WorldInfo.TimeSeconds;
	NewPos.Position = CamStart;
	OldPositions[len] = NewPos;

	// if no old locations saved, return offset
	if ( len == 0 )
	{
		CameraOffset = CamStart - Location;
		return CamStart;
	}
	DeltaTime = (len > 2) ? (WorldInfo.TimeSeconds - OldPositions[len-2].Time) : 0.0;

	// If we're too far from out previous position, and it's not because of velocity (therefor we have been moved), reset the camera
	if (len > 2 && VSizeSq(DesiredStart - Oldpositions[len-2].Position) * DeltaTime > VSizeSq(Velocity)+1)
	{
		OldPositions.remove(0,OldPositions.Length);
//		return CamStart;
	}

	len = OldPositions.Length;
	obsolete = 0;
	for ( i=0; i<len; i++ )
	{
		if ( OldPositions[i].Time < WorldInfo.TimeSeconds - CameraLag )
		{
			PrevPos = OldPositions[i];
			obsolete++;
		}
		else
		{
			if ( Obsolete > 0 )
			{
				// linear interpolation to maintain same distance in past
				if ( (i == 0) || (OldPositions[i].Time - PrevPos.Time > 0.2) )
				{
					CamStart = OldPositions[i].Position;
				}
				else
				{
					CamStart = PrevPos.Position + (OldPositions[i].Position - PrevPos.Position)*(WorldInfo.TimeSeconds - CameraLag - PrevPos.Time)/(OldPositions[i].Time - PrevPos.Time);
				}
				if ( Obsolete > 1)
					OldPositions.Remove(0, obsolete-1);
			}
			else
			{
				CamStart = OldPositions[i].Position;
			}
			// need to smooth camera to vehicle distance, since vehicle update rate not synched with frame rate
			if ( DeltaTime > 0 )
			{
				DeltaTime *= CameraSmoothingFactor;
				CameraOffset = (CamStart - Location)*DeltaTime + CameraOffset*(1-DeltaTime);
			}
			else
			{
				CameraOffset = CamStart - Location;
			}
			CamStart = CameraOffset + DesiredStart;
			return CamStart;
		}
	}
	if(len > 0)
		CamStart = OldPositions[len-1].Position;
	return CamStart;
}

// Footsteps are actually played in here, so they're the same for 1st and 3rd person.
simulated event PlayFootStepSound(int FootDown)
{
	local PlayerController PC;
	local SoundCue FootSound;
	
	FootSound = SoundGroupClass.static.GetFootstepSound(FootDown, GetMaterialBelowFeet());
	
	if(SoundGroupClass==class'Rx_PawnSoundGroup_Heavy') 
	{
		FootSound.VolumeMultiplier=1.25; //1.5; 
	} 
	
	
	
	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		if ( (PC.ViewTarget != None) && (VSizeSq(PC.ViewTarget.Location - Location) < MaxFootstepDistSq) )
		{
			if (FootSound != None)
			{
				PlaySound(FootSound, false, true,,, true);
			}
			return;
		}
	}
	

}

// Debug function for testing the DeployedActor building radius trace stuff
/*exec function TraceToBuildings()
{
	local Rx_Building B, tracedB;
	local vector HitLoc, HitNorm, BuildingLocation, FlatLocation;
	local bool bBuildingHit;
	local int i;
	local float BuildingDmgRadius;

	BuildingDmgRadius = class'Rx_Weapon_DeployedBeacon'.default.BuildingDmgRadius;
	FlatLocation = Location;

	foreach OverlappingActors(class'Rx_Building', B, BuildingDmgRadius, Location, false)
	{
		bBuildingHit = false;

		`log("Attempting hit on "$B);

		if (VSizeSq(B.Location-Location) <= Square(BuildingDmgRadius))
		{
			i = -1;
			bBuildingHit=true;
			`log("-1 Distance check hit with distance "$VSize(B.Location-Location));
		}
		else if (B.BuildingInternals.Trace2dTargets.Length > 0)
		{
			`log("Attempting trace2d targets");
			for (i=0; i<B.BuildingInternals.Trace2dTargets.Length; ++i)
			{
				`log("Checking target "$i);
				BuildingLocation = B.BuildingInternals.Trace2dTargets[i];
				FlatLocation.Z = BuildingLocation.Z;
				if (VSizeSq(BuildingLocation-FlatLocation) <= Square(BuildingDmgRadius))
				{
					`log(i$" Distance check hit with distance "$VSize(BuildingLocation-FlatLocation));
					bBuildingHit=true;
				}
				else
				{
					foreach TraceActors(class'Rx_Building', tracedB, HitLoc, HitNorm, BuildingLocation, FlatLocation)
					{  
						if (tracedB == B && VSizeSq(HitLoc-FlatLocation) <= Square(BuildingDmgRadius))
						{
							`log(i$" Trace check hit with distance "$VSize(HitLoc-FlatLocation));
							bBuildingHit = true;
						}
						break;
					}
				}
				if (bBuildingHit)
					break;
			}
		}
		else
		{
			// Fallback method in the event the building does not have any Trace2d targets.
			BuildingLocation = B.Location;
			foreach TraceActors(class'Rx_Building', tracedB, HitLoc, HitNorm, BuildingLocation, Location)
			{  
				if (tracedB == B && VSizeSq(HitLoc-Location) <= Square(BuildingDmgRadius))
				{
					`log("-1 Trace check hit with distance "$VSize(HitLoc-Location));
					bBuildingHit = true;
				}
				break;
			}
		}
		
	}
}*/

// We don't want this doing anything anymore.
simulated function ActuallyPlayFootstepSound(int FootDown);

simulated function PlayBeaconDeployAnimation()
{
	ForceCrouch();
	bBeaconDeployAnimating = true;
	ReloadAnim = ''; // to notify remote clients (with repnotify) that they should stop reloadanimation if they play it
	BoltReloadAnim = '';
	FullBodyAnimSlot.PlayCustomAnimByDuration('H_M_Beacon_Deploy', 4, 0.4, 0.4);
	if (Role < ROLE_Authority)
	{
		ServerPlayBeaconDeployAnimation();
	}

}

reliable server function ServerPlayBeaconDeployAnimation()
{
	bBeaconDeployAnimating = true;
}

simulated function CancelBeaconDeployAnimation()
{
	UnCrouch();
	bBeaconDeployAnimating = false;
	FullBodyAnimSlot.StopCustomAnim(0.4);
	if (Role < ROLE_Authority)
	{
		ServerCancelBeaconDeployAnimation();
	}
}

reliable server function ServerCancelBeaconDeployAnimation()
{
	bBeaconDeployAnimating = false;
}

simulated function SetIsRepairing(bool repairing)
{
	bRepairing = repairing;
	if (Role < ROLE_Authority)
	{
		ServerSetIsRepairing(repairing);
	}
}

reliable server function ServerSetIsRepairing(bool repairing)
{
	SetIsRepairing(repairing);
}

function bool CanParachute()
{
	if (GetRxFamilyInfo().default.bHasParachute && self.Velocity.Z < ParachuteDeployVelocity && Physics == PHYS_Falling && !ParachuteDeployed)
		return true;
	else return false;
}

simulated function TryParachute()
{
	if (CanParachute())
	{
		ActualDeployParachute();
		if (Role < Role_Authority)
		{
			ServerActualDeployParachute();
		}
	}
}

simulated function ActualDeployParachute()
{
	ParachuteMesh.SetScale(1);
	ParachuteMesh.SetHidden(false);
	UpdateParachuteMat();
	ParachuteAnimState.Z = 1;
	TargetParachuteAnimState.Z = 0;
	ParachuteDragRampUpTime = 0;
	CreateAudioComponent(ParachuteDeployCue,true,true,true,,true);
	ParachuteDeployed = true;
}

simulated function UpdateParachuteMat()
{
	if (WorldInfo.NetMode == NM_DedicatedServer)
		return;
	if (GetTeamNum() == TEAM_NOD)
		ParachuteMesh.SetMaterial(0,ParachuteNodMat);
	else
		ParachuteMesh.SetMaterial(0,ParachuteGDIMat);
}

reliable server function ServerActualDeployParachute()
{
	ActualDeployParachute();
}

simulated function ActualPackParachute()
{
	ParachuteDeployed = false;
	TargetParachuteAnimState.Z = -1;
}

function float CalcParachuteDrag(float DeltaTime)
{
	local float Force;
	local float Accel;

	Force = Square(Velocity.Z * 0.4) * ParachuteDrag;
	Force *= FClamp(ParachuteDragRampUpTime / Default.ParachuteDragRampUpTime,0,1);
	Accel = Force / Mass;
	return Accel * DeltaTime;
}

simulated function TickParachute(float DeltaTime)
{
	if (ParachuteDeployed)
	{
		ParachuteDragRampUpTime += DeltaTime;
		velocity.Z += CalcParachuteDrag(DeltaTime);
	}

	if(ParachuteDeployed && Physics != PHYS_Falling)  
	{
		ActualPackParachute();
	}
	UpdateParachuteAnim(DeltaTime);
}

simulated function HideParachute()
{
	ParachuteMesh.SetScale(0);
	ParachuteMesh.SetHidden(true);
}

simulated function UpdateParachuteAnim(float DeltaTime)
{
	local float CurveWeight, LeftWeight, RightWeight, ClosedWeight;
	if (ParachuteMesh != none && !ParachuteMesh.HiddenGame)
	{	
		CurveWeight = 0;
		LeftWeight = 0;
		RightWeight = 0;
		ClosedWeight = 0;

		if (!ParachuteDeployed && ParachuteAnimState.Z <= -1)
		{
			HideParachute();
		}
		else
		{	
			if (ParachuteAnimState.Z > TargetParachuteAnimState.Z)
			{
				ParachuteAnimState.Z -= DeltaTime * ParachuteDeployAnimSpeed;
				FClamp(ParachuteAnimState.Z,TargetParachuteAnimState.Z,1);
			}

			Normal2D(TargetParachuteAnimState);
			// Smooth Anim state.
			ParachuteAnimState.X = Lerp(ParachuteAnimState.X,TargetParachuteAnimState.X,FClamp( DeltaTime * ParachuteManouverAnimSpeed,0,1));
			ParachuteAnimState.Y = Lerp(ParachuteAnimState.Y,TargetParachuteAnimState.Y,FClamp( DeltaTime * ParachuteManouverAnimSpeed,0,1));
			if (TargetParachuteAnimState.Z <= 0)
				ParachuteAnimState.Z = Lerp(ParachuteAnimState.Z,TargetParachuteAnimState.Z,FClamp( DeltaTime * ParachuteDeployAnimSpeed,0,1));
			else
				ParachuteAnimState.Z = Lerp(ParachuteAnimState.Z,TargetParachuteAnimState.Z,FClamp( DeltaTime * ParachuteUnDeployAnimSpeed,0,1));

			// Base curve weight;
			CurveWeight += 0.7f;
		
			// Blend left and right for manouvering.
			LeftWeight += FClamp(-ParachuteAnimState.Y,0,1);
			RightWeight += FClamp(ParachuteAnimState.Y,0,1);
			LeftWeight += FClamp(((-ParachuteAnimState.X*0.5)+0.5),0,1);
			RightWeight += FClamp(((-ParachuteAnimState.X*0.5)+0.5),0,1);

			// Deploying
			if (ParachuteAnimState.Z > 0)
			{
				ClosedWeight += FClamp(ParachuteAnimState.Z,0,1);
				ParachuteMesh.SetScale(1 - ClosedWeight);
			}
			// Undeploying
			else if (ParachuteAnimState.Z < 0)
			{
				ClosedWeight += -ParachuteAnimState.Z * 0.8;
				CurveWeight *= ParachuteAnimState.Z + 1;
				LeftWeight += -ParachuteAnimState.Z * (1-LeftWeight);
				RightWeight += -ParachuteAnimState.Z * (1-RightWeight);
			}

			// Update blend weights
			ParachuteClosedWeight.SetNodeWeight(FClamp( ClosedWeight,0,1));
			ParachuteCurveWeight.SetNodeWeight(FClamp( CurveWeight,0,1));
			ParachuteRightTurnWeight.SetNodeWeight(FClamp( RightWeight,0,1));
			ParachuteLeftTurnWeight.SetNodeWeight(FClamp( LeftWeight,0,1));
		}
	}
}


event Landed(vector HitNormal, actor FloorActor)
{
	local Controller KeepLastHit; //don't reset last hit on landing 
	
	if(LastHitBy != none) 
		KeepLastHit=LastHitBy;  
	
	bVaulted = false;
	super.Landed(HitNormal,FloorActor);

	NotifyPassivesLanded();
	
	//SetTimer(0.15, false, 'JumpRecoilTimer'); 
	
	if(Health <= 0)
		ActualPackParachute();

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if(Weapon != none && Rx_Weapon(Weapon).bIronsightActivated) 
			SetGroundSpeed(Rx_Weapon(Weapon).ZoomGroundSpeed);
		else
			SetGroundSpeed();
	}

	if(bIsPtPawn) {
		SetPhysics(PHYS_None);
		bPTInitialized=true;
	}
	LastHitBy = KeepLastHit; 
}

simulated function JumpRecoilTimer(); //If this Timer's active, you still can't jump 


simulated function SetHandIKEnabled(bool bEnabled)
{
	if (!bIsPtPawn)
	{
		super.SetHandIKEnabled(bEnabled);
	}
}

simulated function FlashCountUpdated(Weapon InWeapon, Byte InFlashCount, bool bViaReplication)
{
	if(bViaReplication && Rx_Weapon(weapon) != None && Rx_Weapon(weapon).UsesClientSideProjectiles(0) && IsPlayerPawn() && IsLocallyControlled()) {
		return;
	}
	super.FlashCountUpdated(InWeapon,InFlashCount,bViaReplication);
}

simulated function FlashLocationUpdated(Weapon InWeapon, Vector InFlashLocation, bool bViaReplication)
{
	if(bViaReplication && Rx_Weapon(weapon) != None && Rx_Weapon(weapon).UsesClientSideProjectiles(0) && IsPlayerPawn() && IsLocallyControlled()) {
		return;
	}	
	super.FlashLocationUpdated(InWeapon,InFlashLocation,bViaReplication);
}

simulated function FiringModeUpdated(Weapon InWeapon, byte InFiringMode, bool bViaReplication)
{
	if(bViaReplication && Rx_Weapon(weapon) != None && Rx_Weapon(weapon).UsesClientSideProjectiles(0) && IsPlayerPawn() && IsLocallyControlled()) {
		return;
	}	
	super.FiringModeUpdated(InWeapon,InFiringMode,bViaReplication);
}

function SetbHeadshot(bool NewValue) 
{
	bHeadshot = NewValue;
}

simulated function bool isSpy()
{
	if(Rx_PRI(PlayerReplicationInfo) == None)
		return false;
	return Rx_PRI(PlayerReplicationInfo).isSpy();
}

simulated function WeaponChanged(UTWeapon NewWeapon)
{
    local UDKSkeletalMeshComponent UTSkel;

	
    // Make sure the new weapon respects behindview
    if (NewWeapon.Mesh != None)
    {
        NewWeapon.Mesh.SetHidden(!IsFirstPerson());
		
		if(!IsFirstPerson()) 
			Rx_Weapon(NewWeapon).CycleVisibility(); //Call to be sure animations will be ready and played correctly when switching from 3rd to 1st person the first time.
		
        UTSkel = UDKSkeletalMeshComponent(NewWeapon.Mesh);
        if (UTSkel != none)
        {
            ArmsMesh[0].SetFOV(UTSkel.FOV);
            ArmsMesh[1].SetFOV(UTSkel.FOV);
            ArmsMesh[0].SetScale(UTSkel.Scale);
            ArmsMesh[1].SetScale(UTSkel.Scale);
            Rx_Weapon(NewWeapon).PlayWeaponEquipWithOptionalAnim(false);
        }
    }
}

exec function swapvis(bool Vis)
{
	Rx_weapon(Weapon).ChangeVisibility(Vis);
}

simulated function UTPlayerReplicationInfo GetRxPlayerReplicationInfo()
{
	return Rx_PRI(GetUTPlayerReplicationInfo());
}


event EncroachedBy( actor Other )
{
	if ( Pawn(Other) != None && Vehicle(Other) == None && Rx_Pawn(Other) == None)
		gibbedBy(Other);
}

/**function setBlinkingName()
{
	bBlinkingName = true;
	SetTimer(3.5,false,'DisableBlinkingName');
}
*/
function setUISymbol(byte sym)
{
	UISymbol = sym;
	SetTimer(3.5,false,'DisableUISymbol');
}

/**function DisableBlinkingName()
{
	bBlinkingName = false;	
}*/

function DisableUISymbol()
{
	UISymbol = 0; 
}

function KillRecipient(Pawn Recipient)
{
	KilledBy(None);
}

simulated function bool CanThrowWeapon()
{
	return ( (Rx_Weapon_Beacon(Weapon) != None) && Weapon.CanThrow() );
}

simulated function OnRemoveCredits(Rx_SeqAct_RemoveCredits InAction)
{
	local Rx_PRI RXPRI;

	RXPRI = Rx_PRI(PlayerReplicationInfo);

	if(RXPRI != None)
	{
		RXPRI.RemoveCredits(InAction.Credits);
	}
}

simulated function OnAddCredits(Rx_SeqAct_AddCredits InAction)
{
	local Rx_PRI RXPRI;

	RXPRI = Rx_PRI(PlayerReplicationInfo);

	if(RXPRI != None)
	{
		RXPRI.AddCredits(InAction.Credits);
	}
}

function setArmorType(byte AType)
{
	Armor_Type=ENUM_Armor(Atype); 
}

//Add
simulated function TakeFallingDamage()
{
	local float EffectiveSpeed;
	local float AdjustedMaxFallSpeed; 
	
	AdjustedMaxFallSpeed = MaxFallSpeed*GetRxFamilyInfo().default.FallspeedModifier; 
	
	if (Velocity.Z < -0.5 * AdjustedMaxFallSpeed)
	{
		if ( Role == ROLE_Authority )
		{
			MakeNoise(1.0);
			if (Velocity.Z < -1 * AdjustedMaxFallSpeed)
			{
				EffectiveSpeed = Velocity.Z;
				if (TouchingWaterVolume())
				{
					/*Leaving it at 100 still left enough momentum to slap people into the ground if they sorta glitched/jittered at the water's edge*/
					EffectiveSpeed += 800 ;//100; 
				}
				if (EffectiveSpeed < -1 * AdjustedMaxFallSpeed)
				{ 
					TakeDamage(-100 * (EffectiveSpeed + AdjustedMaxFallSpeed)/AdjustedMaxFallSpeed, None, Location, vect(0,0,0), class'Rx_DmgType_Fell');
				}
				}
		}
	}
	else if (Velocity.Z < -1.4 * JumpZ)
		MakeNoise(0.5);
	else if ( Velocity.Z < -0.8 * JumpZ )
		MakeNoise(0.2);
}

function TakeDrowningDamage()
{
	TakeDamage(10, None, Location + GetCollisionHeight() * vect(0,0,0.5)+ 0.7 * GetCollisionRadius() * vector(Controller.Rotation), vect(0,0,0), class'Rx_DmgType_Drowned');
}

simulated function ClientSetAsTarget(int Spot_Mode, coerce string TeamString, int Num)
{
	//`log("Set as target PAWN CLIENT"); 
	if(Health <= 0 || self.IsInState('Dead') ) return;
	ServerSetAsTarget(Spot_Mode, TeamString, Num);
}

reliable server function ServerSetAsTarget(int Spot_Mode, coerce string TeamString, int Num)
{
local Rx_Controller RXPC;
local Rx_ORI ORI;
RXPC=Rx_Controller(Controller);
ORI=RXPC.myORI; 

//`log("------ServerSetAsTarget PAWN------"); 
ORI.Update_Markers (
TeamString, //String of what team we're updating these for. The object keeps track of GDI/Nod targets, but only displays the targets that correspond with the 
Spot_Mode, //Type of call getting passed down. 0:Attack 1: Defend 2: Repair 3: Waypoint
0, //Whether to update Commander/CoCommander or Support Targets [assume 1 commander for now]
false, // If we're looking to update a waypoint. If this is true, and CT is equal to 1, we'll update the defensive waypoint.
false, //If this is a building being targeted
self	//Actor we'll be marking
);
}
simulated function SetAsTarget(byte TType)
{

if(Rx_PRI(PlayerReplicationInfo) != none) Rx_PRI(PlayerReplicationInfo).SetAsTarget(TType);
	
}


simulated function SetTargetAlarm (int Time)
{
	SetTimer(Time,false,'TargetAlarm');
}

simulated function TargetAlarm()
{
	local Rx_ORI ORI;
	local Rx_Controller PC;
	
	PC = Rx_Controller(GetALocalPlayerController()) ;
	ORI=Rx_GRI(WorldInfo.GRI).ObjectiveManager; 
	
	ORI.NotifyTargetDecayed(self); //Decay
	
	PC.HudVisuals.NotifyTargetDecayed(self); //Decay
	
}

reliable client function ClientNotifyTarget(int TeamNum, int Target_Type, int TargetNum) //Just notify that you are indeed a target
{
	local Rx_Controller PC;
	
	PC = Rx_Controller(Controller) ;
	PC.HudVisuals.UpdateTargets(self, TeamNum, Target_Type, TargetNum);
}

reliable client function ClientNotifyTargetKilled() 
{
	
local Rx_ORI ORI;
	local Rx_Controller PC;
	
	PC = Rx_Controller(GetALocalPlayerController()) ;
	ORI=Rx_GRI(WorldInfo.GRI).ObjectiveManager; 
	
	ORI.NotifyTargetKilled(self); //Decay
	
	PC.HudVisuals.NotifyTargetKilled(self); //Decay	
}

/**exec simulated function CapeMe()
{
	local name HeadShotSocketName;
	//local SkeletalMeshSocket SMS; 
	HeadShotSocketName = GetFamilyInfo().default.HeadShotGoreSocketName;
	//SMS = Mesh.GetSocketByName( HeadShotSocketName );
	
	Mesh.AttachComponentToSocket(CapeMesh, HeadShotSocketName);
}*/

exec simulated function AttachVoiceBox()
{	
	local name HeadShotSocketName;
	HeadShotSocketName = GetFamilyInfo().default.HeadShotGoreSocketName;
	//`log("Attach Voice");
	Mesh.AttachComponentToSocket(VoiceComponent, HeadShotSocketName);
}


function PromoteUnit(byte rank) //Promotion depends mostly on the unit. All units gain health however
{	
	local class<Rx_FamilyInfo> FamInfo; 
	local float ArmourPCT; 

	if(rank < 0) 
		rank = 0;
	else if(rank > 3)
		rank = 3; 

	ArmourPCT=float(Armor)/float(ArmorMax); 

	VRank=rank; 
	FamInfo=GetRxFamilyInfo();
	ArmorMax=(FamInfo.default.MaxArmor+FamInfo.default.Vet_HealthMod[rank]); 
	Armor=ArmorMax*ArmourPCT; ;

	//Armor=FamInfo.default.MaxArmor+FamInfo.default.Vet_HealthMod[rank]; 



	if(rank >= 2) 
	{
		SetTimer(0.5f, true, 'regenerateHealthTimer'); //Start Regenerating if Elite/Heroic
		if(rank==3) 
			RegenerationRate = HeroicRegenerationRate; 
		else
			RegenerationRate=default.RegenerationRate;	
	}
	else
		if(IsTimerActive('regenerateHealthTimer')) 
			ClearTimer('regenerateHealthTimer') ;

	UpdateRunSpeedNode();
	//Rx_Weapon(Weapon).PromoteWeapon(rank); Just use the inventory manager 

	Rx_InventoryManager(InvManager).PromoteAllWeapons(rank); 

}

/*Check if the Pawn is in base. This is expensive... don't ever spam this*/
function string GetPawnLocation (Pawn P)
{
	local string LocationInfo;
	local Rx_GRI WGRI; 
	local RxIfc_SpotMarker SpotMarker;
	local Actor TempActor;
	local float NearestSpotDist;
	local RxIfc_SpotMarker NearestSpotMarker;
	local float DistToSpot;	
	
	if(P == none)
	{
		return "";
	}
	
	if (WorldInfo.NetMode != NM_Client)
		if(Rx_Pawn(P) != none)
			return Rx_Pawn(P).SpotLocation; //Don't waste server resources on this. Just pull the given location 
		else if(Rx_vehicle(P) != none)
			return Rx_vehicle(P).SpotLocation; //Don't waste server resources on this. Just pull the given location 
	
	WGRI = Rx_GRI(WorldInfo.GRI);
	
	if(WGRI == none) 
		return "";
		
	foreach WGRI.SpottingArray(TempActor) {
		SpotMarker = RxIfc_SpotMarker(TempActor);
		DistToSpot = VSizeSq(TempActor.location - P.location);
		if(NearestSpotDist == 0.0 || DistToSpot < NearestSpotDist) {
			NearestSpotDist = DistToSpot;	
			NearestSpotMarker = SpotMarker;
		}
	}
	
	LocationInfo = NearestSpotMarker.GetSpotName();	
	return LocationInfo; 
}

simulated function bool PawnInFriendlyBase(coerce string LocationInfo, Pawn P)
{
	local int TEAMI;
	local Volume V; 
	local Rx_Mutator Rx_Mut;
	
	Rx_Mut = Rx_Game(WorldInfo.Game).GetBaseRXMutator();
	
	if (Rx_Mut != None)
	{
		if(Rx_Mut.OverridesPawnInFriendlyBase())
			return Rx_Mut.PawnInFriendlyBase(LocationInfo, P);
	}  	   
	
	if(P==none) return false;
	TEAMI=P.GetTeamNum(); 
	//`log(P @ LocationInfo @ TEAMI);
		switch(TEAMI)
	{
	case 0:
	foreach P.TouchingActors(class'Volume', V)
	{
		if(Rx_Volume_TeamBase_GDI(V) != none) return true; 
		else
		continue; 
	}
	
	//if(Caps(LocationInfo)=="GDI REFINERY" || Caps(LocationInfo)=="GDI POWERPLANT" || Caps(LocationInfo)=="WEAPONS FACTORY" || Caps(LocationInfo) == "BARRACKS" || CAPS(LocationInfo) == "ADV. GUARD TOWER") return true;
	break;
	
	case 1: 
	//if(Caps(LocationInfo)=="NOD REFINERY" || Caps(LocationInfo)=="NOD POWERPLANT" || Caps(LocationInfo)=="AIRSTRIP" || Caps(LocationInfo) == "HAND OF NOD" || Caps(LocationInfo) == "OBELISK OF LIGHT") return true;
	foreach P.TouchingActors(class'Volume', V)
	{
		if(Rx_Volume_TeamBase_Nod(V) != none) return true; 
		else
		continue; 
	}
	
	break;
	
	default:
	return false;
	break;
	}
	return false; 	
	
}

simulated function bool PawnInEnemyBase(coerce string LocationInfo, Pawn P)
{
	local int TEAMI;
	local Volume V; 
	
	if(P==none) return false;
	TEAMI=P.GetTeamNum();
	
		switch(TEAMI)
	{
	case 0: 
	//if(Caps(LocationInfo)=="NOD REFINERY" || Caps(LocationInfo)=="NOD POWERPLANT" || Caps(LocationInfo)=="AIRSTRIP" || Caps(LocationInfo) == "HAND OF NOD" || Caps(LocationInfo) == "OBELISK OF LIGHT") return true;
	foreach P.TouchingActors(class'Volume', V)
	{
		if(Rx_Volume_TeamBase_Nod(V) != none) return true; 
		else
		continue; 
	}
	break;
	
	case 1: 
	foreach P.TouchingActors(class'Volume', V)
	{
		if(Rx_Volume_TeamBase_GDI(V) != none) return true; 
		else
		continue; 
	}
	//if(Caps(LocationInfo)=="GDI REFINERY" || Caps(LocationInfo)=="GDI POWERPLANT" || Caps(LocationInfo)=="WEAPONS FACTORY" || Caps(LocationInfo) == "BARRACKS" || CAPS(LocationInfo) == "ADV. GUARD TOWER")	
	break;
	default: 
	return false; 
	break;
	}
	
	return false; 	
	
}

function regenerateHealth(int HealAmount)
{
	
	if(bTakingDamage) return; 
    
	if(Health  < HealthMax) {    
		Health += HealAmount;
		if(Health > HealthMax)
		{
			Health=HealthMax; //If we went over, knock it back to the max	
			DamageRate=0;
		}
		
		LegitamateDamage=fMax(0,LegitamateDamage-HealAmount);
		DamageRate = fMax(0,DamageRate-(HealAmount*10));
		return;
    }
	
	if(Armor  < ArmorMax) {    
		Armor += HealAmount;
		if(Armor > ArmorMax) 
		{
			Armor=ArmorMax; //If we went over, knock it back to the max	
			DamageRate=0;
		}
		LegitamateDamage=fMax(0,LegitamateDamage-(HealAmount*10));
		DamageRate = fMax(0,DamageRate-HealAmount);
		return;
    }
}

function regenerateHealthTimer()
{
	
	if(bTakingDamage) return; 
	
    //if(Health  < HealthMax/2) {
    
	if(Health  < HealthMax) {    
		Health += RegenerationRate;
		if(Health > HealthMax)
		{
			Health=HealthMax; //If we went over, knock it back to the max	
			DamageRate=0;
		}
		
		LegitamateDamage=fMax(0,LegitamateDamage-RegenerationRate);
		DamageRate = fMax(0,DamageRate-(RegenerationRate*10));
		return;
    }
	
	if(Armor  < ArmorMax) {    
		Armor += RegenerationRate;
		if(Armor > ArmorMax) 
		{
			Armor=ArmorMax; //If we went over, knock it back to the max	
			DamageRate=0;
		}
		LegitamateDamage=fMax(0,LegitamateDamage-(RegenerationRate*10));
		DamageRate = fMax(0,DamageRate-RegenerationRate);
		return;
    }
}

function setMaxHealth(int NewMaxHealth)
{
		if(self.HealthMax <NewMaxHealth)
			self.HealthMax = NewMaxHealth;
		//self.Health = self.HealthMax;
		if (self.HealthMax>NewMaxHealth)
			self.HealthMax = NewMaxHealth;
		if (self.Health > self.HealthMax)
			self.Health = self.HealthMax;
	
}

function CheckVRank()
{
	local byte CheckRank; 
	CheckRank=Rx_PRI(PlayerReplicationInfo).Vrank;
	
	if( VRank != CheckRank ) PromoteUnit(CheckRank); 
}

function Suicide() //edit so suicides can no longer be used to totally negate a player's bonuses
{
	//KilledBy(LastHitBy.Pawn);
	
	if(LastHitBy != none) 
	{
		TakeDamage(Armor+Health+99, LastHitBy, location, vect(0,0,0), class'DmgType_Suicided'); 
	}
	else
	KilledBy(self);
}

function ResetLastHit()
{
	LastHitBy=none; 
}

simulated function SetSpotted(float SpottedTime)
{		
	if(ROLE < ROLE_Authority) ServerSetSpotted(SpottedTime); 
	else
	{
		bSpotted = true;
		SetTimer(SpottedTime,false,'ResetSpotted');
	}

}

reliable server function ServerSetSpotted(float SpottedTime)
{
	//if(GetTimerRate('ResetSpotted') - GetTimerCount('ResetSpotted') >= SpottedTime) return; //Already spotted for longer by something else	
	bSpotted = true;
	SetTimer(SpottedTime,false,'ResetSpotted');
}

function ResetSpotted()
{
	bSpotted = false;
}

simulated function SetFocused()
{
if(ROLE < ROLE_Authority) ServerSetFocused();
else
	{
	bFocused = true;
	SetTimer(10.0,false,'ResetFocused'); 
	}

}

reliable server function ServerSetFocused() //Draw a focus-fire symbol for enemy targets on this unit
{
	bFocused = true;
	SetTimer(10.0,false,'ResetFocused'); 
}

function ResetFocused()
{
	bFocused = false; 
}


simulated function bool IsHealer()
{
	local class<Rx_FamilyInfo> Fam; 
	
	Fam = GetRxFamilyInfo();
	
	return (Fam == class'Rx_FamilyInfo_GDI_Hotwire' || Fam == class'Rx_FamilyInfo_GDI_Engineer' || Fam == class'Rx_FamilyInfo_Nod_Technician' || Fam == class'Rx_FamilyInfo_Nod_Engineer');
}

simulated function class<Rx_Pawn_VoiceClass> GetVoiceClass()
{
	if(Rx_vehicle(DrivenVehicle) != none && Rx_Vehicle(DrivenVehicle).VehicleVoiceClass != none )
		return Rx_Vehicle(DrivenVehicle).VehicleVoiceClass; 
	else
		return GetRxFamilyInfo().default.PawnVoiceClass;
}

simulated function PlayVoiceSound(name VoiceOverType, bool bOverrideSound, optional byte VoiceLineNum = 0) //Voice sounds all start on the server
{
	local SoundNodeWave SoundToPlay;
	local float SoundDuration;
	//local PlayerController PC;
	local class<Rx_FamilyInfo> FamInfo; 
	
	if(Role == Role_Authority && VoiceOverType != 'Taunt') 
	{		
		if(isTimerActive('ClearReplicatedVoice')) 
			ClearTimer('ClearReplicatedVoice');
		
		if(IsInState('Stealthed'))
			return; 
		
		VoiceLineNum = PickRandomVoiceIndex(VoiceOverType); //If we're the server or a standalone, choose the line to say
	}
	
	if(WorldInfo.NetMode == NM_DedicatedServer) //Just replicate to clients
	{
		//`log("Played Sound on server" @ VoiceLineNum @ VoiceOverType); 
		ReplicatedVoice.VoiceIndex = VoiceLineNum;
		ReplicatedVoice.SoundType = VoiceOverType;
		ReplicatedVoice.bCanOverride = bOverrideSound;
		SetTimer(0.5,false,'ClearReplicatedVoice');
		if(bCanHitReact && VoiceOverType == 'Damage') 
		{
			bCanHitReact=false;
			SetTimer(4.0,false,'ResetHitReaction');
		}
		
		if(bPlayAssistSound && VoiceOverType == 'Assist')
		{
			bPlayAssistSound=false;
			SetTimer(20.0,false,'ResetAssistVoice');
		}
	
		bNetDirty = true; 
		return;
	}
	
	if( (VoiceComponent.isPlaying() && !bOverrideSound ) || (VoiceOverType=='Damage' && !bCanHitReact) || (self.IsInState('Dead') && VoiceOverType != 'Death'))  
	{
		return;
	}
	
	VoiceComponent.Stop(); 
	
	//if(IsTimerActive('ClearVoiceComponent')) ClearTimer('ClearVoiceComponent');
	
	FamInfo = GetRxFamilyInfo();
	//`log(VoiceLineNum @ VoiceOverType);  
	
	switch (VoiceOverType)
	{
		case 'Taunt' :
		SoundToPlay = GetVoiceClass().static.GetTauntSound(VoiceLineNum);
		
		break;
		
		case 'Death' :
			SoundToPlay = FamInfo.default.PawnVoiceClass.static.GetDeathSound(VoiceLineNum);
			break;
		
		case 'Damage' :
		SoundToPlay = FamInfo.default.PawnVoiceClass.static.GetTakeDamageSound(VoiceLineNum);
		if(WorldInfo.NetMode != NM_Client)
		{
			bCanHitReact=false ;
			SetTimer(4.0,false,'ResetHitReaction');
		}
		break;
		
		case 'Kill' :
		SoundToPlay = FamInfo.default.PawnVoiceClass.static.GetKillConfirmSound(VoiceLineNum);
		break;
		
		case 'DestroyVehicle' :
		SoundToPlay = FamInfo.default.PawnVoiceClass.static.GetDestroyVehicleSound(VoiceLineNum);
		break;
		
		case 'Assist' :
		SoundToPlay = FamInfo.default.PawnVoiceClass.static.GetAssistSound(VoiceLineNum);
		break;
		
		case 'DestroyBuilding' :
		SoundToPlay = FamInfo.default.PawnVoiceClass.static.GetBuildingDestroyedSound(VoiceLineNum);
		break;
	}
	
	if(SoundToPlay == none) return;
	//SoundToPlay = SoundNodeWave'RX_CharSnd_Generic.gdi_male.S_Soldier_GDI_AreaSecured_02';
	if(SoundToPlay.Duration > 2.5) 
		SoundDuration=SoundToPlay.Duration; 
	else
		SoundDuration=2.5; 
	
	if((WorldInfo.Netmode == NM_Client || WorldInfo.NetMode == NM_Standalone) && Rx_Controller(Controller) !=none) //Your own voice may need to be slightly lower
	{
		if(DrivenVehicle == none) VoiceComponent.VolumeMultiplier= FamInfo.default.PawnVoiceClass.default.PersonalVolumeModifier; 
		else
		VoiceComponent.VolumeMultiplier= FamInfo.default.PawnVoiceClass.default.PersonalVolumeModifier+0.30; 
	}

		
	VoiceComponent.SetWaveParameter('Voice', SoundToPlay);
	VoiceComponent.SoundCue.Duration=SoundDuration;
	VoiceComponent.Play(); 
	
	
	
}

simulated function ClearVoiceComponent()
{
	VoiceComponent.SetWaveParameter('Voice', none);
	VoiceComponent.SoundCue.Duration=0.0;	
}


function PlayDyingSound(); //Can do our own 

simulated function ResetHitReaction()
{
	bCanHitReact = true;
}

function PlayKillConfirmTimer()
{
	PlayVoiceSound('Kill', false);
}

function PlayVehicleKillConfirmTimer()
{
	PlayVoiceSound('DestroyVehicle', false);
}

function PlayBuildingKillTimer()
{
	PlayVoiceSound('DestroyBuilding', false);
}

function int PickRandomVoiceIndex(name VoiceType) //Pick a voice index, but try to prevent playing the same sound twice in a row
{
	local int Output, PosNeg, Integer;
	//local byte LastInteger; //Uncomment for debugging only

	//Integer to use

	if(VoiceType == 'Kill')  Integer=(GetRxFamilyInfo().default.PawnVoiceClass.default.KillConfirmSounds.Length);
	else
	if(VoiceType == 'Damage') Integer=(GetRxFamilyInfo().default.PawnVoiceClass.default.TakeDamageSounds.Length);
	else
	if(VoiceType == 'DestroyVehicle') Integer=(GetRxFamilyInfo().default.PawnVoiceClass.default.DestroyVehicleSounds.Length);
	else
	if(VoiceType == 'Taunt') Integer=(GetRxFamilyInfo().default.PawnVoiceClass.default.TauntSounds.Length);
	else
	if(VoiceType == 'Assist') Integer=(GetRxFamilyInfo().default.PawnVoiceClass.default.AssistSounds.Length);
	else
	if(VoiceType == 'DestroyBuilding') Integer=(GetRxFamilyInfo().default.PawnVoiceClass.default.BuildingDestroyedSounds.Length);
	else
	//Death sounds are more rare and don't need to be super randomized
	if(VoiceType == 'Death') 
	{
	return DeathSound ; //rand(GetRxFamilyInfo().default.PawnVoiceClass.default.DeathSounds.Length);	
	}

	if(Integer == 2)
	{
		switch(VoiceType)
		{
			case 'Kill':
				LastPicked_KillConfirm= LastPicked_KillConfirm == 0 ? 1 : 0 ;
				return LastPicked_KillConfirm;  
				break;
				
			case 'Damage':
				LastPicked_Hit= LastPicked_Hit == 0 ? 1 : 0 ;
				return LastPicked_Hit;  
			break;
			
			case 'DestroyVehicle':
				LastPicked_VKillConfirm = LastPicked_VKillConfirm == 0 ? 1 : 0 ;
				return LastPicked_VKillConfirm;  
				//`log("Integer/Output/Last" @ Integer @ OutPut @ LastInteger); 
			break;		
			case 'DestroyBuilding':
				LastPicked_BKill = LastPicked_BKill == 0 ? 1 : 0 ;
				return LastPicked_BKill;  
				//`log("Integer/Output/Last" @ Integer @ OutPut @ LastInteger); 
			break;
			
			case 'Assist':
				LastPicked_Assist = LastPicked_Assist == 0 ? 1 : 0 ;
				return LastPicked_Assist;  
				//`log("Integer/Output/Last" @ Integer @ OutPut @ LastInteger); 
			break;
			
			default:
			break;
		}
		
		
	}
	else
	if(Integer==1) return 0; 

	PosNeg=rand(100);

	Output=rand(Integer);



	switch(VoiceType)
	{
		case 'Kill':
			Output = PosNeg <= 20 ? LastPicked_KillConfirm+1+rand(2) : LastPicked_KillConfirm-1-rand(2);
			
			if(Output > Integer-1) Output = 0; 
			else
			if(Output < 0) OutPut = Integer-1;
			//LastInteger=LastPicked_KillConfirm;
			LastPicked_KillConfirm=Output;
			//`log("Integer/Output/Last" @ Integer @ OutPut @ LastInteger); 
			break;
		case 'Damage':
			Output = PosNeg <= 20 ? LastPicked_Hit+1+rand(2) : LastPicked_Hit-1-rand(2);
			
			if(Output > Integer-1) Output = 0; 
			else
			if(Output < 0) OutPut = Integer-1; 
		
			//LastInteger=LastPicked_Hit;
			LastPicked_Hit=Output;
			//`log("Integer/Output/Last" @ Integer @ OutPut @ LastInteger); 
		break;
		
		case 'DestroyVehicle':
			
			Output = PosNeg <= 20 ? LastPicked_VKillConfirm+1+rand(2) : LastPicked_VKillConfirm-1-rand(2);
			
			if(Output > Integer-1) Output = 0; 
			else
			if(Output < 0) OutPut = Integer-1;
			
			//LastInteger=LastPicked_VKillConfirm;
			LastPicked_VKillConfirm = Output; 
			//`log("Integer/Output/Last" @ Integer @ OutPut @ LastInteger); 
		break;
		
		case 'DestroyBuilding':
			
			Output = PosNeg <= 20 ? LastPicked_BKill+1+rand(2) : LastPicked_BKill-1-rand(2);
			
			if(Output > Integer-1) Output = 0; 
			else
			if(Output < 0) OutPut = Integer-1;
			
			LastPicked_BKill = Output; 
		break;
		
		case 'Assist':
			
			OutPut = LastPicked_Assist+1; 
			
			if(Output > Integer-1) Output = 0; 
			else
			if(Output < 0) OutPut = Integer-1;

			LastPicked_Assist = Output; 
		break;
		
		
		default:
		break;
	}

		
	//`log("Integer/Output/Last" @ Integer @ OutPut @ LastInteger); 

	return Output; 
}

simulated function PlayTaunt(byte Option = 0)
{
	if(Role < Role_Authority) 
		ServerPlayTaunt(Option); 
	else if(!VoiceComponent.isPlaying())
		{
			PlayVoiceSound('Taunt',false, Option);
		}
	 
}

unreliable server function ServerPlayTaunt(byte Option = 0)
{
	
	PlayVoiceSound('Taunt',false, Option); 
	
}

function ResetAssistVoice()
{
	bPlayAssistSound = true;
}

function ReseedVoiceOvers()
{
	if(GetRxFamilyInfo() == none ) return; 
	LastPicked_KillConfirm=rand(GetRxFamilyInfo().default.PawnVoiceClass.default.KillConfirmSounds.Length);
	LastPicked_Hit=rand(GetRxFamilyInfo().default.PawnVoiceClass.default.TakeDamageSounds.Length);
	LastPicked_VKillConfirm=rand(GetRxFamilyInfo().default.PawnVoiceClass.default.DestroyVehicleSounds.Length);
	LastPicked_BKill=rand(GetRxFamilyInfo().default.PawnVoiceClass.default.BuildingDestroyedSounds.Length);
	LastPicked_Assist=rand(GetRxFamilyInfo().default.PawnVoiceClass.default.AssistSounds.Length);
	DeathSound=rand(GetRxFamilyInfo().default.PawnVoiceClass.default.DeathSounds.Length);;
	
}

function ClearReplicatedVoice()
{
	ReplicatedVoice.SoundType='NULL'; 
}

simulated function WeaponAttachmentChanged()
{
	super.WeaponAttachmentChanged();
	if(Vrank == 3 && Rx_WeaponAttachment_Varying(CurrentWeaponAttachment) != none ) Rx_WeaponAttachment_Varying(CurrentWeaponAttachment).SetHeroic(true); 
}


//------------ TheAgent's Vaulting system ------------//
// *********** Vault STATE********************************************
// Contains stop functions and special case vaults.
// handles animations and movement

/*
Exec function DoVault () 
{ 
	local Actor TraceHit; 
	Local Vector StartLoc, EndLoc, VaultStartLoc, VaultEndLoc; 
	
	Local Vector MyPosition, MyRotation; 
	
	Local Vector HitNormal, HitLocation; 
	
	Local Int Magnitude;

	// Trace from socket locations 
	If (bVaulted == false && Physics == Phys_Walking)
	{
		VaultStartLoc = Location;
		VaultStartLoc.Z -= 40.0;
		StartLoc = VaultStartLoc;
	
		Magnitude = 40;
		MyPosition = Location;
		MyRotation = Vector(Rotation);
	
		MyRotation.X *= Magnitude;
		MyRotation.Y *= Magnitude;
	
		MyPosition.X += MyRotation.X;
		MyPosition.Y += MyRotation.Y;
		MyPosition.Z -= 40.0;

		VaultEndLoc = MyPosition;
		EndLoc = VaultEndLoc;

		TraceHit = Trace (HitLocation, HitNormal, StartLoc, EndLoc, true ,,, 
		TRACEFLAG_Bullet | TRACEFLAG_PhysicsVolumes | 
		TRACEFLAG_SkipMovers | TRACEFLAG_Blocking); 

		//DrawDebugLine (StartLoc, EndLoc, 255, 250, 100, true); 

		If (TraceHit.IsA ('VaultActor')) 
		{ 
			GotoState ('Vaulting'); 
		}
	}
} 
*/


state Vaulting
{

	function Check()
	{
		local VaultActor VA;
		local Actor TraceHit;
		local Vector StartLoc, EndLoc, VaultStartLoc, VaultEndLoc;

		local Vector HitNormal, HitLocation;

		Local Vector MyPosition, MyRotation; 
		Local Int Magnitude;
		

		if (Controller != None && PlayerController(Controller) != None)
		{
			PlayerController(Controller).IgnoreMoveInput(true);
			PlayerController(Controller).IgnoreLookInput(true);
			StopFiring();
			CameraLag = 3.0;
			
			WasInFirstPersonBeforeDodge = false;
			if(Rx_Controller(Controller) != None && !Rx_Controller(Controller).bBehindView && WorldInfo.NetMode != NM_DedicatedServer) 
			{
				Rx_Controller(Controller).SetBehindView(true);
				WasInFirstPersonBeforeDodge = true;
			}
			SetHandIKEnabled(false);
		}

		foreach VisibleCollidingActors (class'VaultActor', VA,90,Location)
		{

			VaultStartLoc = Location;
			VaultStartLoc.Z -= 40.0;
			StartLoc = VaultStartLoc;
	
			Magnitude = 40;
			MyPosition = Location;
			MyRotation = Vector(Rotation);
	
			MyRotation.X *= Magnitude;
			MyRotation.Y *= Magnitude;
	
			MyPosition.X += MyRotation.X;
			MyPosition.Y += MyRotation.Y;
			MyPosition.Z -= 40.0;
	
			VaultEndLoc = MyPosition;
			EndLoc = VaultEndLoc;

			TraceHit = Trace(HitLocation, HitNormal, StartLoc, EndLoc, true,,,
			TRACEFLAG_Bullet | TRACEFLAG_PhysicsVolumes |
			TRACEFLAG_SkipMovers | TRACEFLAG_Blocking);


			if(TraceHit.IsA('VaultActor'))
			{

				if(VA.Type == Tall)
				{
					bVaulted = true;
					DoJump(true);
					SetHandIKEnabled(false);
					Velocity.Z = VA.Height;
					FullBodyAnimSlot.PlayCustomAnim('H_M_Vault_Tall', 1.0, 0.2, 0.2, FALSE, TRUE);
					SetTimer(0.55, false, 'VaultPushForward');
				}
            
				else if(VA.Type == Medium )
				{
					bVaulted = true;
					DoJump(True);
					SetHandIKEnabled(false);
					Velocity.Z = VA.Height;
					FullBodyAnimSlot.PlayCustomAnim('H_M_Vault_Medium', 1.0, 0.2, 0.2, FALSE, TRUE);
					SetTimer(0.35, false, 'VaultPushForward');
				}

				else if(VA.Type == Small)
				{
					bVaulted = true;
					DoJump(True);
					SetHandIKEnabled(false);
					Velocity.Z = VA.Height;
					FullBodyAnimSlot.PlayCustomAnim('H_M_Vault_Small', 1.0, 0.2, 0.2, FALSE, TRUE);
					SetTimer(0.1, false, 'VaultPushForward');
				}
				
				SetHandIKEnabled(false);

			}
			else
			{
				PushState('PlayerWalking');
				SetHandIKEnabled(true);
			}

		}

	}
	
	function SetbVaultedFalse()
	{
		bVaulted=false;
	}

	function VaultPushForward()
	{
		local VaultActor VA;
		Local Vector MyRotation; 
		Local Int ForwardPush;
	
		foreach VisibleCollidingActors (class'VaultActor', VA, 90, Location)
		{
			ForwardPush = VA.PushDistance;
			MyRotation = Vector(Rotation);
			MyRotation.X *= ForwardPush;
			MyRotation.Y *= ForwardPush;
			Velocity.X += MyRotation.X;
			Velocity.Y += MyRotation.Y;
			PushState('PlayerWalking');
		}
		
		if (Controller != None && PlayerController(Controller) != None)
		{
			PlayerController(Controller).IgnoreMoveInput(false);
			PlayerController(Controller).IgnoreLookInput(false);
			CameraLag = 0.05;
			
			if(WasInFirstPersonBeforeDodge) 
			{
				SetTimer( 0.5, false, 'WasInFirstPersonBeforeVault' );
			}
			SetTimer( 0.2, false, 'ReEnableHandIKAfterDodge' );
		}
		SetTimer( 0.4, false, 'SetbVaultedFalse' );
		//bVaulted = false;
	}
	
	function WasInFirstPersonBeforeVault()
	{
		if(Controller != None && PlayerController(Controller) != None && WorldInfo.NetMode != NM_DedicatedServer) 
		{
			Rx_Controller(Controller).SetBehindView(false);
		}
	}

  Begin:
  
  Check();

}

function TestVisAct()
{
	local Actor CA; 
	
	foreach VisibleCollidingActors(class'Actor', CA, 300, location, false)
			{
				//`log("-----Actor------: " @ CA); 
				if(CA == Self || RxIfc_Airlift(CA) == none) 
				{
				//`log("Skipping :" @ CA);
				continue; 	
				}
				
				//`log("-----Actor Found------: " @ CA); 
				
			}
}

/****Do not stack supply crate healing*****/
function SetLastSupportHealTime()
{
	if(Rx_Controller(Controller) != none) 
		Rx_Controller(Controller).SetLastSupportHealTime();  
	else
	if(Rx_Bot(Controller) != none) 
		Rx_Bot(Controller).SetLastSupportHealTime(); 
}

function bool bCanAcceptSupportHealing()
{
	local int iWorldSeconds; 
	
	iWorldSeconds = int(WorldInfo.TimeSeconds);
	
	if(Rx_Controller(Controller) != none) 
	{
		//`log(Rx_Controller(Controller).LastSupportHealTime @ iWorldSeconds); 
		return Rx_Controller(Controller).LastSupportHealTime < iWorldSeconds ;	
	} 
	else
	if(Rx_Bot(Controller) != none) 
		return Rx_Bot(Controller).LastSupportHealTime < iWorldSeconds; 
	else
	return false; 
}

/**Stat Modifier Calls**/ 
simulated function float GetSpeedModifier()
{
	return (SpeedUpgradeMultiplier+GetRxFamilyInfo().default.Vet_SprintSpeedMod[VRank])+GetInventoryWeight();
}

simulated function float GetResistanceModifier()
{
	if(Rx_Controller(Controller) != none) 
		return Rx_Controller(Controller).Misc_DamageResistanceMod;  
	else
	if(Rx_Bot(Controller) != none) 
		return Rx_Bot(Controller).Misc_DamageResistanceMod; 
	else
	return 1.0; 
}

/**
function UpdateStats()
{
	ArmourPCT=float(Armor)/float(ArmorMax); 
	FamInfo=GetRxFamilyInfo();
	ArmorMax=(FamInfo.default.MaxArmor+FamInfo.default.Vet_HealthMod[rank])*GetResistanceodifier(); 
	Armor=ArmorMax*ArmourPCT; ;	
}
*/

function SetSpeedUpgradeMod(float UpgradeNum)  //Used to modify from outside sources 
{
	SpeedUpgradeMultiplier = GetRxFamilyInfo().default.SpeedMultiplier + UpgradeNum;
}

simulated function string GetTargetedDescription(PlayerController PlayerPerspective)
{
	//Above all else 
	if(Rx_PRI(PlayerReplicationInfo) != none && Rx_PRI(PlayerReplicationInfo).bGetIsCommander()) 
		return "[COMMANDER]";
	else
	return ""; 
}

simulated function SetAlwaysRelevant(bool Relevant)
{
	bAlwaysRelevant = Relevant; 
}

/******************
*RxIfc_RadarMarker*
*******************/

//0:Infantry 1: Vehicle 2:Miscellaneous  
simulated function int GetRadarIconType()
{
	return 0; //Infantry
} 

simulated function bool ForceVisible()
{
	return PlayerReplicationInfo == none || Rx_PRI(PlayerReplicationInfo).isSpotted();  
}

simulated function vector GetRadarActorLocation() 
{
	return DrivenVehicle == none ? location : DrivenVehicle.location; 
} 
simulated function rotator GetRadarActorRotation()
{
	return DrivenVehicle == none ? rotation : DrivenVehicle.rotation;  
}

simulated function byte GetRadarVisibility()
{
	return RadarVisibility; 
} 

simulated function Texture GetMinimapIconTexture()
{
	return none; 
}
/* Ion Storm should disable minimap & overview map and activate a noise overlay on them
simulated function DisableMinimap()
{
	SetRadarVisibility(0);
}
*/

/******************
*END RadarMarker***
*******************/

/*Modifying Relevancy Temporarily*/

function SetTemporaryRelevance(float Amount)
{
	if(Rx_Game(WorldInfo.Game).bInfantryAlwaysRelevant)
		return;
	
	SetRelevant(true);
	SetTimer(Amount,false,'ResetAlwaysRelevantTimer'); 
}

function SetRelevant(bool Rel)
{
	bAlwaysRelevant = Rel ; 
}

function ResetAlwaysRelevantTimer()
{
	bAlwaysRelevant = Rx_Game(WorldInfo.Game).bInfantryAlwaysRelevant;
}

simulated function NotifyTeamChanged() {
	Super.NotifyTeamChanged();
	if (Rx_Controller(Controller) != None && `RxGameObject != None) {
		Rx_Controller(Controller).UpdateDiscordPresence(`RxGameObject.MaxPlayers);
	}
}

simulated function ChangeCharacterClass()
{
	local UTPlayerReplicationInfo PRI;

	// set mesh to the one in the PRI, or default for this team if not found
	PRI = GetUTPlayerReplicationInfo();

	if (PRI != None)
	{
		SetCharacterClassFromInfo(GetFamilyInfo());

		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			// refresh weapon attachment
			if (CurrentWeaponAttachmentClass != None)
			{
				// recreate weapon attachment in case the socket on the new mesh is in a different place
				if (CurrentWeaponAttachment != None)
				{
					CurrentWeaponAttachment.DetachFrom(Mesh);
					CurrentWeaponAttachment.Destroy();
					CurrentWeaponAttachment = None;
				}
				WeaponAttachmentChanged();
			}
			// refresh overlay
			if (OverlayMaterialInstance != None)
			{
				SetOverlayMaterial(OverlayMaterialInstance);
			}
		}
	}

	if (!bReceivedValidTeam)
	{
		SetTeamColor();
		bReceivedValidTeam = (GetTeam() != None);
	}

	if (Rx_Controller(Controller) != None && `RxGameObject != None) {
		Rx_Controller(Controller).UpdateDiscordPresence(`RxGameObject.MaxPlayers);
	}
}

function float GetInventoryWeight(){
	if(Rx_InventoryManager(InvManager) == none)
		return 0.0; 
	else
		return Rx_InventoryManager(InvManager).GetInventoryWeight();
	
}

function GivePassiveAbility(byte AbilityNum, class<Rx_PassiveAbility> PassiveAbility)
{
	if(PassiveAbility == none)
	{
		return; 
	}
	
	PassiveAbilities[AbilityNum] = Spawn(PassiveAbility, self);
	
	//`log("AbilityNum: " @ AbilityNum); 
	PassiveAbilities[AbilityNum].Init(self, AbilityNum); 
	//Handle client replication with the ability itself 
	/**if(WorldInfo.NetMode == NM_DedicatedServer)
		ClientGivePassiveAbility(AbilityNum, PassivesID);*/
}

//Called on the client. Passes an actual instance of an ability class 
simulated function ReplicatePassiveAbility (byte AbilityNum, Rx_PassiveAbility PassiveAbility){
	//`log("Set Passive ability: " @ AbilityNum @ PassiveAbility);
	PassiveAbilities[AbilityNum] = PassiveAbility;
} 

simulated function ClearPassiveAbilities()
{
	local int i; 
	
	for(i=0;i<3;i++){
			if(PassiveAbilities[i] != none)
					PassiveAbilities[i].RemoveUser(); 
			PassiveAbilities[i] = none; 
		}
}

/*Passive Abilities Interface*/

simulated function bool ActivateJumpAbility(bool bToggle) {
	
	if(bToggle) //Toggle it on
	{
		if(PassiveAbilities[0] != none) 
		{
			PassiveAbilities[0].ActivateAbility();
			return true; 			
		}
		
		return false; 
	}
	else //Toggle it off 
	{
		if(PassiveAbilities[0] != none) 
		{
			PassiveAbilities[0].DeactivateAbility(false); //Only abilities themselves will force deactivate 
			return true; 	
		}
		
		return false; 
	}
	
	return false; //I don't know how you'd get here... but just in case
}

simulated function bool ActivateAbility0(bool Toggle); 

simulated function bool ActivateAbility1(bool Toggle); 

simulated function NotifyPassivesDodged(int DodgeDir){
	local int i; 
	
	for(i=0;i<3;i++){
		if(PassiveAbilities[i] != none)
			PassiveAbilities[i].NotifyDodged(0); 
	}
}

simulated function NotifyPassivesCrouched(bool Toggle){
	local int i; 
	
	for(i=0;i<3;i++){
		if(PassiveAbilities[i] != none)
			PassiveAbilities[i].NotifyCrouched(Toggle); 
	}
}

simulated function NotifyPassivesSprint(bool Toggle){
	local int i; 
	
	for(i=0;i<3;i++){
		if(PassiveAbilities[i] != none)
			PassiveAbilities[i].NotifySprint(Toggle); 
	}
}

simulated function NotifyPassivesLanded(){
	local int i; 
	
	for(i=0;i<3;i++){
		if(PassiveAbilities[i] != none)
			PassiveAbilities[i].NotifyLanded(); 
	}
}

simulated function NotifyPassivesMeshChanged()
{
	local int i; 
	
	for(i=0;i<3;i++){
		if(PassiveAbilities[i] != none)
			PassiveAbilities[i].NotifyMeshChanged(); 
	}
}

/*END Passive ability interface*/

DefaultProperties
{
	//nBab
	/*Begin Object Name=MyLightEnvironment
		bSynthesizeSHLight=TRUE
		bIsCharacterLightEnvironment=TRUE
		bUseBooleanEnvironmentShadowing=FALSE
		InvisibleUpdateTime=1
		MinTimeBetweenFullUpdates=.2
		//setting shadow frustum scale (nBab)
		LightingBoundsScale=0.2
	End Object
	Components.Add(MyLightEnvironment)
	LightEnvironment=MyLightEnvironment*/

	Begin Object Class=SkeletalMeshComponent Name=ParachuteMeshComponent
		SkeletalMesh = SkeletalMesh'RX_CH_Parachute.Mesh.SK_RamAir'
		AnimTreeTemplate = AnimTree'RX_CH_Parachute.Mesh.SK_RamAir_AnimTree'
		MorphSets.Add(MorphTargetSet'RX_CH_Parachute.Mesh.SK_RamAir_MorphTargetSet')
		HiddenGame = TRUE
		HiddenEditor = TRUE
		BlockRigidBody=false
		bUsePrecomputedShadows=FALSE
		Translation = (X= 0, Y= 0, Z =30)
		AlwaysCheckCollision = false
	End Object

	ParachuteGDIMat = MaterialInstanceConstant'RX_CH_Parachute.Materials.MI_Parachute_GDI'
	ParachuteNodMat = MaterialInstanceConstant'RX_CH_Parachute.Materials.MI_Parachute_Nod'
	ParachuteDeployCue = SoundCue'RX_CH_Parachute.Sounds.A_Parachute_Open'

	ParachuteAnimState = (X = 0, Y = 0, Z = 1)
	TargetParachuteAnimState = (X = 0, Y = 0, Z = 0)
	ParachuteManouverAnimSpeed = 4
	ParachuteDeployAnimSpeed = 2
	ParachuteUnDeployAnimSpeed = 2
	
	ParachuteMesh = ParachuteMeshComponent
	Components.Add(ParachuteMeshComponent)
	ParachuteDeployVelocity = -750.0
	ParachuteDrag = 4.0
	ParachuteDragRampUpTime = 1.75;
	ParachuteDeployed = FALSE
	ParachuteCamDistMod = 400.0
	//ParachuteCamDistMod = 200.0
	CurrentParachuteCamDistMod = 0

	RadarVisibility = 1 
	
	//CAPE//
	/**
	Begin Object Class=SkeletalMeshComponent Name=CapeMeshComponent
		SkeletalMesh = SkeletalMesh'RX_CH_Capes.Mesh.SK_Cape'
		bEnableClothSimulation 	 	= false
		bClothAwakeOnStartup   	 	= false
	End Object
	CapeMesh=CapeMeshComponent
	Components.Add(CapeMeshComponent)
	*/
	
	CanEnterVehicles = true;

	CurrentHopStamina = 1.0
	MinHopStamina = 0.40
	HopCost = 0.30
	HopRegenRate = 0.30
	MaxJumpZ = 325.0
	bAlwaysRelevant = false
	
	CurrentCameraScale=1.0
	CameraScale=1.0
	CameraScaleMin=1.0
	CameraScaleMax=40.0
//	CamOffset=(X=105.0,Y=5.0,Z=15.0)	// To be used if Camera Lag is 0
	CamOffset=(X=105.0,Y=5.0,Z=-28.0)  // Normal 3rd person Cam (X=70.0,Y=10.0,Z=-20.0) (X=90.0,Y=10.0,Z=-12.5) (X=100.0,Y=10.0,Z=-10) (X=90.0,Y=10.0,Z=-7.5) (X=80.0,Y=10.0,Z=-12)  (X=65.0,Y=5.0,Z=-16)   
//	CamOffset=(X=90.0,Y=40.0,Z=-35.0)	// over the shoulder
//	CamOffset=(X=-12.0,Y=4.0,Z=-37.0)	// First person view using 3rd person camera
	CamStartZHeight = 93.0
	CamStartCrouchZHeight = 75.0
	CameraSmoothingFactor = 3
	CameraLag = 0.05

	DodgeCameraOffset = (X=130.0,Y=5.0,Z=-60.0)
	
	CamLowAngleStart=6000
	CamLowOffsetMax=30
	CamHighAngleStart=61000
	CamHighOffsetMax=30

	BaseTranslationOffset=0.0 // 6.0
	
	/**Begin Object Name=OverlayMeshComponent0
		Scale=1.0
		bAcceptsDynamicDecals=FALSE
		CastShadow=false
		bOwnerNoSee=true
		bUpdateSkelWhenNotRendered=false 
		bOverrideAttachmentOwnerVisibility=true
		TickGroup=TG_PostAsyncWork
		bAllowAmbientOcclusion=false
	End Object
	OverlayMesh=OverlayMeshComponent0
	*/
	Begin Object Name=WPawnSkeletalMeshComponent
		AnimTreeTemplate=AnimTree'RX_CH_Animations.Anims.AT_Character_Modular'
		AnimSets(0)=AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_Unarmed'
		Scale=1.0
		bUpdateSkelWhenNotRendered=false
		//bCastHiddenShadow = true
		BlockZeroExtent=True				// Uncomment to enable accurate hitboxes (1/3)
		CollideActors=true;					// Uncomment to enable accurate hitboxes (2/3)
	End Object
	Mesh=WPawnSkeletalMeshComponent
	Components.Add(WPawnSkeletalMeshComponent)

	Begin Object Name=CollisionCylinder
		CollisionRadius=16
		CollisionHeight=50 //60		
		BlockZeroExtent=False				// Uncomment to enable accurate hitboxes (3/3)
	End Object
	CrouchHeight=35
	CrouchRadius=16.0
	
	Begin Object Name=FirstPersonArms
		// PhysicsAsset=None
		FOV=55
		Animations=MeshSequenceA
		DepthPriorityGroup=SDPG_Foreground
		bUpdateSkelWhenNotRendered=true
		CastShadow=true
		bAllowAmbientOcclusion=true
		bCastDynamicShadow=true
		bSelfShadowOnly=true
	End Object
	ArmsMesh[0]=FirstPersonArms

	Begin Object Name=FirstPersonArms2
		// PhysicsAsset=None
		FOV=55
		Scale3D=(Y=-1.0)
		Animations=MeshSequenceB
		DepthPriorityGroup=SDPG_Foreground
		bUpdateSkelWhenNotRendered=true
		CastShadow=true
		bSelfShadowOnly=true
		bAllowAmbientOcclusion=true
	End Object
	ArmsMesh[1]=FirstPersonArms2
	
	// default bone names
	WeaponSocket=WeaponPoint
	WeaponSocket2=DualWeaponPoint
	HeadBone=b_head
	TorsoBoneName=b_Spine_2
	PawnEffectSockets[0]=L_JB
	PawnEffectSockets[1]=R_JB	
	
	HeadRadius=+8.0
	HeadHeight=5.0
	HeadScale=+1.0
	HeadOffset=32		// I dont think this is doing anything
	
	ViewPitchMin=-14000 // -16384
	ViewPitchMax=15000 // 16383
	MaxYawAim=7000

	WalkingPct=+0.25
	CrouchedPct=+0.3
	BaseEyeHeight=41 	// 36.0
	EyeHeight=41 		// 36.0
	GroundSpeed=310
	AirSpeed=100
	WaterSpeed=150.0
	SwimmingZOffset=0.0
	SwimmingZOffsetSpeed=100.0
	OutofWaterZ=0
	AccelRate=1400
	MaxLeanRoll=2500
	JumpZ=325.0
	VehicleCheckRadius=120
	
	CustomGravityScaling=0.85

	
	// CrouchMeshZOffset=100.0		// Does not work
	// CrouchTranslationOffset=100	// Does not work
	WalkableFloorZ=0.65				// 0.7 = 45 Degree

	Buoyancy=1.0
	UnderWaterTime=10.0
	
	DamageParameterName=none
	
	// I dont think this works (Copied from UT3's UTPawn class)
	// BioRifleDeathBurnTime is used for the disolving death effect on the character
	Begin Object Class=ParticleSystemComponent Name=GooDeath
		Template=ParticleSystem'RX_WP_ChemicalThrower.Effects.FX_ChemDamage'
		bAutoActivate=false
	End Object
	BioBurnAway=GooDeath
	BioBurnAwayTime=3.5f
	BioEffectName=BioRifleDeathBurnTime
	
	Begin Object Class=Rx_AudioComponent Name=InitVoice
		bUseOwnerLocation = true
		bStopWhenOwnerDestroyed = true
		SoundCue = SoundCue'RX_CharSnd_Generic.gdi_male.Pawn_Voice'
		//InstanceParameters(0).name='Voice'
		//InstanceParameters(0).WaveParam=SoundNodeWave'RX_CharSnd_Generic.gdi_male.S_Soldier_GDI_AreaSecured_02'
	End Object
	
	VoiceComponent=InitVoice
	Components.Add(InitVoice); 
	
	DeathHipLinSpring=10000.0
	DeathHipLinDamp=500.0
	DeathHipAngSpring=10000.0
	DeathHipAngDamp=500.0
	
	bCanDoubleJump=false
	MaxMultiJump=0
	MultiJumpRemaining=0
	bCanStrafe=true
	bStopOnDoubleLanding=false
	bEnableFootPlacement=false

	// moving here for now until we can fix up the code to have it pass in the armor object
	ShieldBeltMaterialInstance=none
	ShieldBeltTeamMaterialInstances(0)=none
	ShieldBeltTeamMaterialInstances(1)=none
	ShieldBeltTeamMaterialInstances(2)=none
	ShieldBeltTeamMaterialInstances(3)=none

	ArmorHitSound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Kevlar'
	// SpawnSound=none
	// TeleportSound=none

	
	
	SoundGroupClass=class'RenX_Game.Rx_PawnSoundGroup'

	TransInEffects(0)=none
	TransInEffects(1)=none 

	MaxFallSpeed=800  // 750
	FallSpeedThreshold=150 	// 125
	
	// Armor Related
	Armor = 100

	BleedInterval = 0.5f

	/** one1: Set to none, inventory manager is spawned when character is chosen. */
	InventoryManagerClass = none

//	WeaponBackSocket = Weapon_Back
//	WeaponC4Socket = Weapon_C4 
//	WeaponPistolSocket = Weapon_Pistol
	/
	WalkingSpeed=90
	RunningSpeed=310	// 290
	SprintSpeed=420.0	// 440.0 
	LadderSpeed=85
	SpeedUpgradeMultiplier=1 
	JumpHeightMultiplier=1
	
	ExhaustionTime=3.0f			// Seconds
	StaminaCooldownTime=2.0f	// Seconds
	SprintStaminaCost=5.0f;		// Per second
//	SprintStaminaCost=0.0f;		// Per second
	JumpStaminaCost=0.0f;		// Per use
	DodgeStaminaCost=20.0f		// Per use	
//	DodgeStaminaCost=0.0f;		// Per use	
	StaminaRegenRate=10.0f;		// Per second
	Stamina=100.0f
	MaxStamina = 100.0f
	
	//Dodge......BAAAAAALL!!!!!
	DodgeNodeName		= "Dive1"
	DodgeBlendTime = 0.5f
	DodgeSpeed=420 //420
	SprintDodgeSpeed=550
	DodgeSpeedZ=300.0
	DodgeDuration=1.0	// 1.0
	bDodgeCapable=false //true //true;  Not this patch yet... till we figure something out. Yosh
	Snd_DodgeCue = SoundCue'RX_CharacterSounds.Male.SC_Male_Dodge_Grunt'
	
	WeaponAimedToRestAnim = WeaponAimedToRest
	WeaponSprintAnim = WeaponSprint
	WeaponRestToAimedAnim = WeaponRestToAim
	
	IsRelaxed = false
	RelaxTime = 5.0f
	RelaxBaseName = "Relax"
	
	bReplicateHealthToAll=true
	bCanPickupInventory=true	
	
	// Seeking modifiers. Higher values mean seeking rockets can track this vehicle better
	SeekAimAheadModifier = 0.0
	SeekAccelrateModifier = 0.0

	/** one1: Added. Add more sockets, but adjust array sizes too! */
	BackWeaponSocketNames[0] = Weapon_Back
	BackWeaponSocketNames[1] = Weapon_Secondary
	BackWeaponSocketNames[2] = Weapon_Pistol
	BackWeaponSocketNames[3] = Weapon_C4
	BackWeaponSocketNames[4] = Weapon_Item
	
	RegenerationRate = 1
	HeroicRegenerationRate = 3 
	MaxDR = 0.1 //Maximumum of 90% damage resistance
	
	SpotLocation = "NULL"
	SpotUpdateTime = 1.0 //Seconds
	UISymbol = 0
	
	bCanHitReact = true
	bPlayAssistSound = true
	
	//--------------Vaulting Options
	ClimbHeight = 0
	bVaulted = false
	
	CurrentStoredWeaponOverlayByte = 255
	
	PassiveAbilities(0) = none 
	PassiveAbilities(1) = none 
	PassiveAbilities(2) = none 
	
	DodgeCameraZOffset = -40
	DodgeCoolDownTime = 1.5
	
	//bSmoothNetUpdates = 

	//MaxSmoothNetUpdateDist;

	//NoSmoothNetUpdateDist;

	//SmoothNetUpdateTime;
}