/**
 * RxGame
 *
 * */
class Rx_Pawn extends UTPawn
	implements (RxIfc_ClientSideInstantHitRadius)
	implements (RxIfc_TargetedCustomName);


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

/** Is the player climbing downward? */
var bool            bClimbDown;

// Variables for Grenades
var bool bThrowingGrenade;      // already throwing grenade yet?

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

var name 		DodgeForwardAnim;
var name 		DodgeBackwardAnim;
var name 		DodgeLeftAnim; 
var name 		DodgeRightAnim;  

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

//----------------------------------------------------------------------------
// Armor Related
//----------------------------------------------------------------------------
var int Armor;
/** note.  if MaxArmor isnot set in the defualt properties it will set MaxArmor
 *  to waht is the current Armor in the default properties */
var int ArmorMax;

var name WeaponBackSocket, WeaponC4Socket, WeaponPistolSocket;

var int PlayAreaLeaveDamageWaitCounter;
var int	PlayAreaLeaveDamageWait;
var bool bCalculatingBleedDamage;
var bool bIsPtPawn;
var bool bPTInitialized;

/**Shahman: Variables when being being targetted*/
var bool bTargetted;
var bool bStartFirePressedButNoStopFireYet;

struct Bleed
{
	var int Damage; // Amount of damage per tick
	var int Count; // How many ticks remaining
	var Controller EventInstigator; // Who caused the damage (for awarding kills)
	var class<DamageType> Type; // Damage type (must be different from the type that created the bleed)
	// var int NextTick; // When to apply this tick next
};

var array<Bleed> Bleeds;
var float BleedInterval; // How often to apply bleed effects

var ActorComponent BackSocketComponent, C4SocketComponent, PistolSocketComponent;

var bool bSwappedCam;
var bool bDodgeCapable;
var	vector DodgeVelocity;
var	float DodgeDuration;
var	float TimeInDodge;
var	float LastVelZInDodge;
var repnotify name DodgeAnim;
var repnotify name ReloadAnim;
var repnotify name BoltReloadAnim;
var repnotify bool bBeaconDeployAnimating;

var int ShotgunPelletCount;
var repnotify vector ShotgunPelletHitLocations[12];
var bool bHeadshot;
var int InPlayAreaVolumes;
var Soundcue PlayerWarnSound;

var Rx_Building_Obelisk Obelisk;
var Rx_Building_AdvancedGuardTower Agt;
var bool bCheckedForOb;
var bool bCheckedForAgt;
var bool bWasInIronsightBeforeAction;

var Rx_AuthenticationClient authenticationClient;

// Modifiers for rockets seeking this actor
var float SeekAimAheadModifier;
var float SeekAccelrateModifier;

var SkelControlSingleBone LeftHandIK_SB; //Left Professional Ass-Grabbin' Kontrol!
var SkelControlSingleBone RightHandIK_SB; //Right Professional Ass-Grabbin' Kontrol!

var bool bBlinkingName;
var byte HitEnemyForDemorec;
var byte HitEnemyWithHeadshotForDemoRec;


//-----------------------------------------------------------------------------
// Pawn control
//-----------------------------------------------------------------------------

replication
{
	if ( bNetDirty)
		Armor, ArmorMax, CurrentBackWeapons, AirstrikeLocation; 
	if ( bNetDirty && !bNetOwner)
		DodgeAnim, ReloadAnim, BoltReloadAnim, ParachuteDeployed, bRepairing, bBeaconDeployAnimating, bBlinkingName, bSprintingServer;
	// Only replicate if our current weapon is a shotgun. Otherwise this is irrelivant.
	if ( bNetDirty && !bNetOwner && RemoteRole == ROLE_SimulatedProxy && Rx_Weapon_Shotgun(Weapon) != none)
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
	// Start the relax timer when the pawn spawns
	SetTimer( 0.5, false, 'RelaxTimer' );
	SetHandIKEnabled(false);
	ParachuteMesh.SetLightEnvironment(LightEnvironment);
}

simulated function ClientReStart()
{
	super.ClientReStart();
	if(Rx_Controller(Controller) != None) {
		Rx_Controller(Controller).SetOurCameraMode(Rx_Controller(Controller).camMode);
	}
}

simulated function MakeHumanCharInvisibleToBots() {
	if(PlayerController(Controller) != None) {
		SetInvisible(true);
	}	
}

simulated event ReplicatedEvent(name VarName)
{
	local int i;
	if ( VarName == 'DodgeAnim' ) 
	{
		if(DodgeAnim != '') {
			SetHandIKEnabled(false);
			FullBodyAnimSlot.PlayCustomAnimByDuration( DodgeAnim, DodgeDuration + 0.4, 0.4, 0.4);
		} 
		else 
		{
			SetHandIKEnabled(true);
		}
	} 
	else if (VarName == 'bBeaconDeployAnimating')
	{
		if (bBeaconDeployAnimating)
		{
			PlayBeaconDeployAnimation();
		}
		else
		{
			CancelBeaconDeployAnimation();
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
		SetTimer(0.1, false, 'RegenTimer');
	}
}

function RegenTimer()
{
	if (Controller != none && Controller.IsA('PlayerController') && !IsInPain() && DamageRate > 0)
	{
		DamageRate -= 5;
	}

	if (bTakingDamage || Health <= 0 || DamageRate <= 0)
	{
		DamageRate = 0;
		ClearTimer('DelayRegen');
		ClearTimer('HealthRegen');
	}
	else
	{
		HealthRegen();
	}
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

event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local int ActualDamage;
	local int ScoreDamage;
	local int ArmorTemp;
	local int BleedDamage;
	local PlayerController PC;
	local Controller Killer;
	local class<Rx_DmgType_Special> DmgType;
	local float Scr;

	
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

	//reduce damage based on armor
	if(!bHeadshot) 
	{
		AdjustDamage(ActualDamage, Momentum, EventInstigator, HitLocation, DamageType, HitInfo, DamageCauser );
	}

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

	// When Taking Falling Damage Armor is not Useful
	// Also water (drowning damage) is not useful to armor - halo2pac
	if ( DamageType == class'DmgType_Fell' || DamageType == class'UTDmgType_Drowned' || DmgType != none && DmgType.default.bPiercesArmor)
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
		TearOffMomentum = momentum;
		Died(Killer, DamageType, HitLocation);
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
		}
	}

	if(InGodMode())
		DamageRate = 0;

	DamageRate += ActualDamage * 2;

	if ( DamageRate > 0)
	{
		bTakingDamage = true;
		SetTimer(1.0, false, 'DelayRegen');
	}

	if (EventInstigator != none)
	{
		// add score (or sub, if bIsFriendlyFire is on)
		if(!EventInstigator.IsA('SentinelController') && EventInstigator.PlayerReplicationInfo != None)
		{
			ScoreDamage = ActualDamage;
			if(Health < 0)
				ScoreDamage += Health; // so that if he already was nearly dead, we dont get full score
			if(ScoreDamage < 0)
				ScoreDamage = 0;
				
			Scr = ScoreDamage * class<Rx_FamilyInfo>(CurrCharClassInfo).default.DamagePointsMultiplier;							
			
			if (GetTeamNum() != EventInstigator.GetTeamNum() && Rx_PRI(EventInstigator.PlayerReplicationInfo) != None)
			{
				Rx_PRI(EventInstigator.PlayerReplicationInfo).AddScoreToPlayerAndTeam(Scr);
			}
		}
	}

	//Rx_Controller(Controller).InitDamagePPC();
	//ScriptTrace();
	PlayHit(actualDamage,Controller, hitLocation, DamageType, Momentum, HitInfo);
	MakeNoise(1.0);
	//loginternal(actualDamage);
	bHeadshot = false;
}

function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local Rx_Bot bot;
	local Rx_CapturePoint CP;
	local byte WasTeam;
	
	WasTeam = GetTeamNum();
	if(Rx_Controller(Controller) != None)
		Rx_Controller(Controller).LastKiller = Killer;
	Rx_PRI(PlayerReplicationInfo).SetIsSpy(false);
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
	if(InstigatedBy != None 
			&& InstigatedBy.GetTeamNum() == GetTeamNum() 
			&& Rx_Weapon_DeployedActor(DamageCauser) == None) {
		return;
	}	
	if(Rx_Weapon_DeployedActor(DamageCauser) != None)
	{
		if(InstigatedBy != Controller && DamageCauser.GetTeamNum() == GetTeamNum())
			return; // Beacons/C4 only damages the planter
	}
	if(Rx_Projectile(DamageCauser) != None && !Rx_Projectile(DamageCauser).isAirstrikeProjectile()) {
		if(WorldInfo.NetMode != NM_DedicatedServer 
					&& InstigatedBy != None && (Rx_Weapon(InstigatedBy.Pawn.Weapon) != None || Rx_Vehicle_Weapon(InstigatedBy.Pawn.Weapon) != None)) {	
			if(Health > 0 && self.GetTeamNum() != InstigatedBy.GetTeamNum() && UTPlayerController(InstigatedBy) != None) {
				Rx_Hud(UTPlayerController(InstigatedBy).myHud).ShowHitMarker();
			}

			if (Rx_Weapon_VoltAutoRifle(InstigatedBy.Pawn.Weapon) != None)
				Rx_Weapon_VoltAutoRifle(InstigatedBy.Pawn.Weapon).ServerALRadiusDamageCharged(self,HurtOrigin,bFullDamage,class'Rx_Projectile_VoltBolt'.static.GetChargePercentFromDamage(BaseDamage));
			else if(Rx_Weapon(InstigatedBy.Pawn.Weapon) != None) {
				Rx_Weapon(InstigatedBy.Pawn.Weapon).ServerALRadiusDamage(self,HurtOrigin,bFullDamage);
			} else {
				Rx_Vehicle_Weapon(InstigatedBy.Pawn.Weapon).ServerALRadiusDamage(self,HurtOrigin,bFullDamage);
			}	
		} else if(ROLE == ROLE_Authority && AIController(InstigatedBy) != None) {
			super.TakeRadiusDamage(InstigatedBy,BaseDamage,DamageRadius,DamageType,Momentum,HurtOrigin,bFullDamage,DamageCauser,DamageFalloffExponent);
		}
	} else {
		super.TakeRadiusDamage(InstigatedBy,BaseDamage,DamageRadius,DamageType,Momentum,HurtOrigin,bFullDamage,DamageCauser,DamageFalloffExponent);
	}
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

	// Give score to the healer
	if (TotalAmmount > 0)
	{
		Score = TotalAmmount * class<Rx_FamilyInfo>(CurrCharClassInfo).default.HealPointsMultiplier;
		Rx_PRI(Healer.PlayerReplicationInfo).AddScoreToPlayerAndTeam(Score);
	}

	return true;
}

function bool DoJump( bool bUpdating )
{
	if (DeductStamina(JumpStaminaCost))
	{			
		JumpZ = MaxJumpZ * CurrentHopStamina;
		CurrentHopStamina = FMax(CurrentHopStamina - HopCost,MinHopStamina);
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
	GroundSpeed = Speed;
	ServerSetGroundSpeed(Speed);
}

reliable server function ServerSetGroundSpeed(float Speed) {
	Speed = FMin(Speed, SprintSpeed);
	if(Speed > RunningSpeed) {
		bSprintingServer = true;
	} else {
		bSprintingServer = false;
	}
	Groundspeed = Speed;
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
		if (Stamina <=0 || (PlayerController(Controller) != None && Rx_PlayerInput(PlayerController(Controller).PlayerInput).aBaseYTemp <= 0))
		{
			//Make entry in log and return
			//`log("Sprinting set to false because player isn't moving forward.");
			return;
		}
	
		/**
		if(GetTeamNum() == TEAM_GDI && GetObelisk() != None && !obelisk.IsDestroyed()) {
			//DrawDebugLine(location,obelisk.SentinelLocation,0,0,255,true);
			if(VSize(location-obelisk.location) <= 800 || FastTrace(location, obelisk.SentinelLocation,,true)) {
				return;
			}
		} else if(GetTeamNum() == TEAM_Nod && GetAgt() != None && !Agt.IsDestroyed()) {
			if(VSize(location-Agt.location) <= 500 || FastTrace(location, Agt.SentinelLocation,,true)) {
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
	}
}

function Rx_Building_Obelisk GetObelisk()
{
	if(!bCheckedForOb) {
		ForEach AllActors(class'Rx_Building_Obelisk', Obelisk) {
			break;
		}
		bCheckedForOb = true;
	}
	return Obelisk;
}

function Rx_Building_AdvancedGuardTower GetAgt()
{
	if(!bCheckedForAgt) {
		ForEach AllActors(class'Rx_Building_AdvancedGuardTower', Agt) {
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
	if (LeftHandIK_SB != None && Rx_Weapon(Weapon) != None)
	{
		LeftHandIK_SB.BoneTranslation = Rx_Weapon(Weapon).LeftHandIK_Offset;
	}
	if (RightHandIK_SB != None && Rx_Weapon(Weapon) != None)
	{
		RightHandIK_SB.BoneTranslation = Rx_Weapon(Weapon).RightHandIK_Offset;
	}

	if (bSprinting && Worldinfo.Netmode != NM_DedicatedServer && DrivenVehicle == None)
	{
		if(PlayerController(Controller) != None) 
		{
			Weapon.StopFire(0);
			Weapon.StopFire(1);
			Weapon.StopFire(2);
			
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
	
	// Regen hop stamina
	if (CurrentHopStamina < 1)
	{
		CurrentHopStamina = FMin(CurrentHopStamina + HopRegenRate * DeltaTime ,1);
		if (CurrentHopStamina == 1 && WorldInfo.NetMode != NM_DedicatedServer)
			SetGroundSpeed();
	}

	//Dodging(DeltaTime);

	TickParachute(DeltaTime);

	super.Tick(DeltaTime);
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
	if(Rx_Weapon(Weapon).bIronsightActivated)
		return;	
	ConsoleCommand("Walking");
	SetGroundSpeed(WalkingSpeed);
}

function StopWalking()
{
	if(Rx_Weapon(Weapon).bIronsightActivated)
		return;
	SetGroundSpeed(RunningSpeed);
}


//-----------------------------------------------------------------------------
// animation related
//-----------------------------------------------------------------------------


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
		LeftLegControl = SkelControlFootPlacement(Mesh.FindSkelControl(LeftFootControlName));
		RightLegControl = SkelControlFootPlacement(Mesh.FindSkelControl(RightFootControlName));
		FeignDeathBlend = AnimNodeBlend(Mesh.FindAnimNode('FeignDeathBlend'));
		FullBodyAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('FullBodySlot'));
		TopHalfAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('TopHalfSlot'));

		LeftHandIK = SkelControlLimb( mesh.FindSkelControl('LeftHandIK') );
		LeftHandIK_SB = SkelControlSingleBone( mesh.FindSkelControl('LeftHandIK_Offset') );

		RightHandIK = SkelControlLimb( mesh.FindSkelControl('RightHandIK') );
		RightHandIK_SB = SkelControlSingleBone( mesh.FindSkelControl('RightHandIK_Offset') );

		RootRotControl = SkelControlSingleBone( mesh.FindSkelControl('RootRot') );
		AimNode = AnimNodeAimOffset( mesh.FindAnimNode('AimNode') );
		GunRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('GunRecoilNode') );
		LeftRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('LeftRecoilNode') );
		RightRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('RightRecoilNode') );

		DrivingNode = UTAnimBlendByDriving( mesh.FindAnimNode('DrivingNode') );
		VehicleNode = UTAnimBlendByVehicle( mesh.FindAnimNode('VehicleNode') );
		HoverboardingNode = UTAnimBlendByHoverboarding( mesh.FindAnimNode('Hoverboarding') );

		FlyingDirOffset = AnimNodeAimOffset( mesh.FindAnimNode('FlyingDirOffset') );
	
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
   Mesh.SetSkeletalMesh(SkelMesh);
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (!VerifyBodyMaterialInstance())
			`logd("VerifyBodyMaterialInstance failed on pawn"@self);
	}
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


simulated function StartFire(byte FireModeNum)
{
	if((Rx_Weapon(Weapon).bIronSightCapable
		|| Rx_Weapon_SniperRifle(Weapon) != None 
		|| Rx_Weapon_PersonalIonCannon(weapon) != None 
		|| Rx_Weapon_RamjetRifle(weapon) != None
		|| Rx_Weapon_Railgun(weapon) != None)
			&& FireModeNum == 1) 
	{
		if(Rx_Weapon_Reloadable(Weapon) != None && Rx_Weapon_Reloadable(Weapon).CurrentlyReloading)
			return;
		if(bSprinting)
			return;	
		if(!Rx_Weapon(Weapon).bDisplayCrosshair 
			&& (!Rx_Weapon(Weapon).bIronSightCapable || Rx_PlayerInput(PlayerController(Controller).PlayerInput).bClickToGoOutOfADS))
		{
			Rx_Weapon(Weapon).EndZoom(UTPlayerController(Instigator.Controller));
		}			
		else if((Rx_Weapon(Weapon).bDisplayCrosshair || (Rx_Weapon(Weapon).bIronSightCapable && !Rx_Weapon(Weapon).bIronsightActivated))
				&& !Rx_Controller(Controller).bZoomed && Rx_Controller(Controller).DesiredFOV == Rx_Controller(Controller).GetFovAngle())
		{
			Rx_Weapon(Weapon).StartZoom(UTPlayerController(Instigator.Controller));	
			bStartFirePressedButNoStopFireYet = true;
		}
		return;
	} 	
	if (Rx_Weapon_LaserRifle(Weapon) != none )
	{
		Rx_Weapon_LaserRifle(Weapon).FireButtonPressed(FireModeNum);
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
	if(FireModeNum == 1)
		bStartFirePressedButNoStopFireYet = false;
		
	if (Rx_Weapon_LaserRifle(Weapon) != none )
	{
		Rx_Weapon_LaserRifle(Weapon).FireButtonReleased(FireModeNum);
	}
	
	if(!Rx_PlayerInput(PlayerController(Controller).PlayerInput).bClickToGoOutOfADS 
			&& (Rx_Weapon(Weapon).bIronSightCapable && FireModeNum == 1)) 
	{	
		if((!Rx_Weapon(Weapon).bDisplayCrosshair || (Rx_Weapon(Weapon).bIronSightCapable && Rx_Weapon(Weapon).bIronsightActivated))
				&& Rx_Controller(Controller).bZoomed && Rx_Controller(Controller).DesiredFOV == Rx_Controller(Controller).GetFovAngle()) 
		{
			Rx_Weapon(Weapon).EndZoom(UTPlayerController(Instigator.Controller));
			/**
			if(Rx_Weapon_SniperRifle(Weapon).CurrentlyBoltReloading)
			{
				//Rx_Pawn(Owner).SetHandIKEnabled(true);
				Rx_Weapon_SniperRifle(Weapon).PlayWeaponBoltReloadAnim();
			}
			*/
			return;
		}
	}	

	SetTimer( RelaxTime, false, 'RelaxTimer' );
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
		SetHandIKEnabled(false);
	} 
	else if( !SetRelaxed && IsRelaxed )
	{
		foreach RelaxedBlendLists(RelaxNode)
		{
			RelaxNode.SetActiveChild(0,0.15);
		}
		AimNode = WeaponAimNode;
		IsRelaxed = false;
		SetHandIKEnabled(true);
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
*/
simulated function bool TakeHeadShot(const out ImpactInfo Impact, class<DamageType> HeadShotDamageType, int HeadDamage, float AdditionalScale, controller InstigatingController, bool bRocketDamage)
{
	if(Role < ROLE_Authority && InstigatingController != None && !InstigatingController.IsLocalPlayerController()) {
		return false;
	}
	if(InstigatingController != None && IsLocationOnHead(Impact, AdditionalScale) && (InstigatingController.IsA('PlayerController') || UTBot(InstigatingController) != None) )
	{
		bHeadshot = true;
		if(WorldInfo.NetMode != NM_DedicatedServer && Rx_Pawn(InstigatingController.Pawn) != None && InstigatingController.Pawn.IsLocallyControlled()) {
			if(Health > 0 && self.GetTeamNum() != InstigatingController.GetTeamNum() && UTPlayerController(InstigatingController) != None) {
				Rx_Hud(UTPlayerController(InstigatingController).myHud).ShowHitMarker();
			}	
			Rx_Weapon(InstigatingController.Pawn.Weapon).ServerALHeadshotHit(self,Impact.HitLocation,Impact.HitInfo);
		} else if(WorldInfo.NetMode != NM_DedicatedServer && Rx_Vehicle(InstigatingController.Pawn) != None && InstigatingController.Pawn.IsLocallyControlled()) {
			if(Health > 0 && self.GetTeamNum() != InstigatingController.GetTeamNum() && UTPlayerController(InstigatingController) != None) {
				Rx_Hud(UTPlayerController(InstigatingController).myHud).ShowHitMarker();
			}			
			Rx_Vehicle_Weapon(InstigatingController.Pawn.Weapon).ServerALHeadshotHit(self,Impact.HitLocation,Impact.HitInfo);
		} else if(WorldInfo.NetMode == NM_DedicatedServer && (AIController(InstigatingController) != None || bRocketDamage)) {
			TakeDamage(HeadDamage, InstigatingController, Impact.HitLocation, Impact.RayDir, HeadShotDamageType, Impact.HitInfo);
		}
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
    if( bThrowingGrenade && Rx_InventoryManager(InvManager) != None )
    {
		Rx_InventoryManager(InvManager).PreviousInventoryGroup = Rx_Weapon(Weapon).InventoryGroup;
		Super.SwitchWeapon(4);
    }
	else
	{
		Super.SwitchWeapon(NewGroup);
	}
}

function SetMoveDirection(EMoveDir dir) 
{
	moveDirection = dir;
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	if (!bDodging && bDodgeCapable && Physics == Phys_Walking) {
		StopFiring();
		if (DeductStamina(DodgeStaminaCost))
		{
			bDodging = true;
			if(bSprinting) {
				StopSprinting();
			}
			if(Rx_Weapon(Weapon).bIronsightActivated) {
				bWasInIronsightBeforeAction = true;
				Rx_Weapon(Weapon).EndZoom(UTPlayercontroller(Controller));
			} else {
				bWasInIronsightBeforeAction = false;
			}
			DoDodge(DoubleClickMove);
			return true;
		}
	}
	return false;
}

function DoDodge(eDoubleClickDir DoubleClickMove)
{
	local vector X,Y,Z;
	
	WasInFirstPersonBeforeDodge = false;
	if(Rx_Controller(Controller) != None && !Rx_Controller(Controller).bBehindView && WorldInfo.NetMode != NM_DedicatedServer) {
		Rx_Controller(Controller).SetBehindView(true);
		WasInFirstPersonBeforeDodge = true;
	}
	SetHandIKEnabled(false);
	
	// finds global axes of pawn
	GetAxes(Rotation, X, Y, Z);

	// temporarily raise speeds
	AirSpeed = DodgeSpeed;
	GroundSpeed = DodgeSpeed;
	Velocity.Z = -default.GroundSpeed;

	switch ( DoubleClickMove )
	{
		// dodge left
		case DClick_Left:
			DodgeVelocity = -DodgeSpeed*Normal(Y);
			break;
		// dodge right
		case DClick_Right:
			DodgeVelocity = DodgeSpeed*Normal(Y);
			break;
		// dodge forward
		case DCLICK_Forward:
			DodgeVelocity = DodgeSpeed*Normal(X);
			break;
		// dodge backward
		case DCLICK_Back:
			DodgeVelocity = -DodgeSpeed*Normal(X);
			break;
		// in case there is an error
		default:
			`log('DoDodge Error');
			break;
	}

	Velocity = DodgeVelocity;
	LastVelZInDodge = 0.f;

	SetPhysics(Phys_Flying); // gives the right physics
	bDodgeCapable = false; // prevent dodging mid dodge
	if(PlayerController(Controller) != None) {
		PlayerController(Controller).IgnoreMoveInput(true); //prevent the player from controlling pawn direction
	}
	TimeInDodge = 0.0f;
	SetTimer(DodgeDuration,false,'UnDodge'); //time until the dodge is done
	calcDodgeAnim(DoubleClickMove);
	playDodgeAnimation();	

}

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
	if(Controller != None && PlayerController(Controller) != None) {
		PlayerController(Controller).IgnoreMoveInput(false);
	}
	GroundSpeed = default.GroundSpeed;
	AirSpeed = default.AirSpeed;
	DodgeAnim = '';
	if(WasInFirstPersonBeforeDodge) {
		if(Controller != None && PlayerController(Controller) != None && WorldInfo.NetMode != NM_DedicatedServer) {
			Rx_Controller(Controller).SetBehindView(false);
		}
	}
	
	if(bWasInIronsightBeforeAction && Rx_Weapon(Weapon) != None) {
		Rx_Weapon(Weapon).StartZoom(UTPlayercontroller(Controller));
	}
		
	SetTimer( 0.2, false, 'ReEnableHandIKAfterDodge' );
}

function ReEnableHandIKAfterDodge() {
	SetHandIKEnabled(true);	
}

function playDodgeAnimation()
{
	ReloadAnim = ''; // to notify remote clients (with repnotify) that they should stop reloadanimation if they play it
	BoltReloadAnim = '';
	FullBodyAnimSlot.PlayCustomAnimByDuration( DodgeAnim, DodgeDuration + 0.2, 0.2, 0.2);
}

function calcDodgeAnim(eDoubleClickDir DoubleClickMove) 
{
	if (DoubleClickMove == DCLICK_Forward) {
		DodgeAnim = DodgeForwardAnim;
	}
	else if (DoubleClickMove == DCLICK_Back) {
		DodgeAnim = DodgeBackwardAnim;
	}
	else if (DoubleClickMove == DCLICK_Left) {
		DodgeAnim = DodgeLeftAnim;
	}
	else if (DoubleClickMove == DCLICK_Right) {
		DodgeAnim = DodgeRightAnim;
	}
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

/** one1: Modified; custom inventory manager spawning */
simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info) {

	local int i;
	local class<UTFamilyInfo> prev;
	local array<class<Rx_Weapon> > prevItems;
	local class<Rx_Weapon> weapClass;

	prev = CurrCharClassInfo;
	
	super.SetCharacterClassFromInfo(Info);
	
	if(Mesh.SkeletalMesh != None) {
		for (i = 0; i < Mesh.SkeletalMesh.Materials.length; i++) {
			Mesh.SetMaterial( i, None );
		} 
	}

	/** one1: Set inventory manager according to family info class. */
	if (Role == ROLE_Authority)
	{
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
	local Rx_Vehicle_StealthTank ST;
	local Controller cntrl;
	
	super.StartDriving(V);
	if(Controller != None)
	{
		cntrl = Controller;
	} 
	else 
	{
		cntrl = V.Controller;
	}
	if(cntrl != None && WorldInfo.NetMode != NM_DedicatedServer && cntrl.IsLocalPlayerController()) {
		foreach DynamicActors(class'Rx_Vehicle_StealthTank', ST) {
			if(cntrl.GetTeamNum() != ST.GetTeamNum()) {
				ST.ChangeStealthVisibilityParam(false);    
			}
		} 
	}	
}

simulated event StopDriving(Vehicle V)
{
    local Rx_Vehicle_StealthTank ST;
    local Controller cntrl;
    
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
	} 
	else
	{
		cntrl = V.Controller;
	}	
    if(cntrl != None && WorldInfo.NetMode != NM_DedicatedServer && cntrl.IsLocalPlayerController()) {
	    foreach DynamicActors(class'Rx_Vehicle_StealthTank', ST) {
	        if(cntrl.GetTeamNum() != ST.GetTeamNum()) {
	            ST.ChangeStealthVisibilityParam(true);    
	        }
	    }
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

function PlayAreaTimerTick()
{
	local Rx_Hud RxHUD;

	if(InPlayAreaVolumes > 0)
		return;
	//BAD BOY! Time to warn the disobedient player...
	if (Controller != None || DrivenVehicle != None)
	{
		if(DrivenVehicle !=None)
		{
			PlayerController(DrivenVehicle.Controller).ClientPlaySound(PlayerWarnSound);
			RxHUD = Rx_Hud(PlayerController(DrivenVehicle.Controller).myHUD);	
		}
		else
		{
			PlayerController(Controller).ClientPlaySound(PlayerWarnSound);
			RxHUD = Rx_Hud(PlayerController(Controller).myHUD);
		}
		if (RxHUD != None)
		{
			//show the first visual warning, with how long they have to get back.
			RxHUD.PlayAreaAnnouncement("RETURN TO BATTLEFIELD",PlayAreaLeaveDamageWait);
		}
		
		//tick once.
		SetTimer(1.0f, false, 'PlayVolumeViolationDamageCountDown');
	}
}

function PlayVolumeViolationDamageCountDown()
{
	local PlayerController PC;
	local Rx_Hud RxHUD;
	
	//check and see if player and vehicle returned to volume.
	if (InPlayAreaVolumes >= 1 || health <= 0)
	{
		PlayAreaLeaveDamageWaitCounter = 0; //reset
		return;
	}

	PlayAreaLeaveDamageWaitCounter++;
	
	if(DrivenVehicle !=None)
		PC = PlayerController(DrivenVehicle.Controller);
	else
		PC = PlayerController(Controller);
	
	RxHUD = Rx_Hud(PC.myHUD);
	
	if (PlayAreaLeaveDamageWaitCounter == PlayAreaLeaveDamageWait)
	{
		//Time ran out...PUNISH the player!
		PlayAreaLeaveDamageWaitCounter = 0; //reset
		
		if (WorldInfo.NetMode != NM_DedicatedServer && RxHUD != None)
			RxHUD.ClearPlayAreaAnnouncement();
		else
			ClearPlayAreaAnnouncementClient();
			
		if (DrivenVehicle != None)
			Rx_Vehicle(DrivenVehicle).DriverLeave(true);
		
		//kill player.
		TakeDamage(1000,None,vect(0,0,0),vect(0,0,0),class'DmgType_Fell');

		PlayAreaLeaveDamageWaitCounter = 0; //reset
	}
	else
	{
		//keep warning.
		if (WorldInfo.NetMode != NM_DedicatedServer && RxHUD != None)
			RxHUD.PlayAreaAnnouncement("RETURN TO BATTLEFIELD",(PlayAreaLeaveDamageWait - PlayAreaLeaveDamageWaitCounter));
		else
			PlayAreaAnnouncementClient("RETURN TO BATTLEFIELD",(PlayAreaLeaveDamageWait - PlayAreaLeaveDamageWaitCounter));
		
		SetTimer(1.0f, false, 'PlayVolumeViolationDamageCountDown');
	}
}

reliable client function PlayAreaAnnouncementClient(string announcement, int count)
{
	if(Rx_Hud(PlayerController(Controller).myHUD) != None)
		Rx_Hud(PlayerController(Controller).myHUD).PlayAreaAnnouncement(announcement,count);	
}

reliable client function ClearPlayAreaAnnouncementClient()
{
	if(Rx_Hud(PlayerController(Controller).myHUD) != None)
		Rx_Hud(PlayerController(Controller).myHUD).ClearPlayAreaAnnouncement();
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
		smooth = FMin(0.9, 9.0 * DeltaTime);
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
		smooth = FMin(0.65, 8.0 * DeltaTime);
		OldEyeHeight = EyeHeight;
		EyeHeight = EyeHeight * (1 - 1.5*smooth);
		LandBob += 0.08 * (OldEyeHeight - Eyeheight);
		if ( (Eyeheight < 0.25 * BaseEyeheight + 1) || (LandBob > 2.4)  )
		{
			bLandRecovery = true;
			Eyeheight = 0.25 * BaseEyeheight + 1;
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
/* Debug commands for setting up the dynamic camera offset
exec function CamLowAngle(int i) { CamLowAngleStart = i; }
exec function CamLowOffset(int i) { CamLowOffsetMax = i; }
exec function CamHighAngle(int i) { CamHighAngleStart = i; }
exec function CamHighOffset(int i) { CamHighOffsetMax = i; }
exec function CamPrint() {
	`log("Current Pitch: "$CurrentCamPitch);
}*/

simulated function bool CalcThirdPersonCam( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	local vector DesiredCamStart, CamStart, CamEnd, HitLocation, HitNormal, CamDirX, CamDirY, CamDirZ, CurrentCamOffset, AngleOffset;
	local float DesiredCameraZOffset;

	ModifyRotForDebugFreeCam(out_CamRot);

	DesiredCamStart = Location;
	// Always start from the bottom of collision so change in collision size doesn't affect the camera.
	DesiredCamStart.Z -= GetCollisionHeight();
	CurrentCamOffset = CamOffset;
	
	// SmoothCam for going up and down stairs.
	DesiredCamStart.Z += CameraSmoothZOffset;

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

		CameraZOffset = (CameraZOffset >= CamStartCrouchZHeight && CameraZOffset <= CamStartZHeight) ? Lerp(CameraZOffset,DesiredCameraZOffset,FClamp(fDeltaTime * 10.0f,0,1)) : DesiredCameraZOffset;
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
	if (!FastTrace(CamEnd,CamStart))
	{
		CamStart.z += 30;
		if (Trace(HitLocation, HitNormal, out_CamLoc, CamStart, false, vect(12,12,12)) != None) {
			out_CamLoc = HitLocation;
			return false;
		}
	}
	return true;
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
	if (CameraLag == 0 || !IsHumanControlled())
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
	if (len > 2 && VSize(DesiredStart - Oldpositions[len-2].Position) * DeltaTime > VSize(Velocity)+1)
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

		if (VSize(B.Location-Location) <= BuildingDmgRadius)
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
				if (VSize(BuildingLocation-FlatLocation) <= BuildingDmgRadius)
				{
					`log(i$" Distance check hit with distance "$VSize(BuildingLocation-FlatLocation));
					bBuildingHit=true;
				}
				else
				{
					foreach TraceActors(class'Rx_Building', tracedB, HitLoc, HitNorm, BuildingLocation, FlatLocation)
					{  
						if (tracedB == B && VSize(HitLoc-FlatLocation) <= BuildingDmgRadius)
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
				if (tracedB == B && VSize(HitLoc-Location) <= BuildingDmgRadius)
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
	if (self.Velocity.Z < ParachuteDeployVelocity && Physics == PHYS_Falling && !ParachuteDeployed)
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
	super.Landed(HitNormal,FloorActor);

	if(Health <= 0)
		ActualPackParachute();

	if (WorldInfo.NetMode != NM_DedicatedServer)
		SetGroundSpeed();

	if(bIsPtPawn) {
		SetPhysics(PHYS_None);
		bPTInitialized=true;
	}
}

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

event EncroachedBy( actor Other )
{
	if ( Pawn(Other) != None && Vehicle(Other) == None && Rx_Pawn(Other) == None)
		gibbedBy(Other);
}

function setBlinkingName()
{
	bBlinkingName = true;
	SetTimer(3.5,false,'DisableBlinkingName');
}

function DisableBlinkingName()
{
	bBlinkingName = false;	
}

function KillRecipient(Pawn Recipient)
{
	KilledBy(None);
}

simulated function bool CanThrowWeapon()
{
	return false;
}

simulated function OnRemoveCredits(Rx_SeqAct_RemoveCredits InAction)
{
	if (InAction.Credits > 0)
	{
		RemoveCreditsAction(InAction.Credits);
	}
}

reliable server function RemoveCreditsAction(int Credits) 
{
	Rx_PRI(PlayerReplicationInfo).RemoveCredits(Credits);
}

DefaultProperties
{
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

	CurrentHopStamina = 1.0
	MinHopStamina = 0.40
	HopCost = 0.30
	HopRegenRate = 0.30
	MaxJumpZ = 325.0
	bAlwaysRelevant = true
	
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

	CamLowAngleStart=6000
	CamLowOffsetMax=30
	CamHighAngleStart=61000
	CamHighOffsetMax=30

	BaseTranslationOffset=0.0 // 6.0
	Begin Object Name=OverlayMeshComponent0
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

	Begin Object Name=WPawnSkeletalMeshComponent
		AnimTreeTemplate=AnimTree'RX_CH_Animations.Anims.AT_Character_Modular'
		AnimSets(0)=AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_Unarmed'
		Scale=1.0
		bUpdateSkelWhenNotRendered=false
		//bCastHiddenShadow = true
//		BlockZeroExtent=True				// Uncomment to enable accurate hitboxes (1/3)
//		CollideActors=true;					// Uncomment to enable accurate hitboxes (2/3)
	End Object
	Mesh=WPawnSkeletalMeshComponent
	Components.Add(WPawnSkeletalMeshComponent)

	Begin Object Name=CollisionCylinder
		CollisionRadius=16
		CollisionHeight=50		
//		BlockZeroExtent=False				// Uncomment to enable accurate hitboxes (3/3)
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
	DodgeSpeed=650	// 550.0
	DodgeSpeedZ=300.0
	DodgeDuration=0.75	// 1.0
	bDodgeCapable=false;
	AccelRate=800
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
	
	WalkingSpeed=90
	RunningSpeed=310	// 290
	SprintSpeed=420.0	// 440.0 
	LadderSpeed=85

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
	
	DodgeForwardAnim 	= H_M_Dive_Fwd
	DodgeBackwardAnim 	= H_M_Dive_Bwd
	DodgeLeftAnim 		= H_M_Dive_Left
	DodgeRightAnim 		= H_M_Dive_Right
	
	WeaponAimedToRestAnim = WeaponAimedToRest
	WeaponSprintAnim = WeaponSprint
	WeaponRestToAimedAnim = WeaponRestToAim
	
	IsRelaxed = false
	RelaxTime = 5.0f
	RelaxBaseName = "Relax"
	
	bReplicateHealthToAll=true
	bCanPickupInventory=true	
	
	PlayerWarnSound			= SoundCue'RX_Dialogue.Generic.S_BackToObjective_Cue'
	InPlayAreaVolumes = 1
	
	// Seeking modifiers. Higher values mean seeking rockets can track this vehicle better
	SeekAimAheadModifier = 0.0
	SeekAccelrateModifier = 0.0

	/** one1: Added. Add more sockets, but adjust array sizes too! */
	BackWeaponSocketNames[0] = Weapon_Back
	BackWeaponSocketNames[1] = Weapon_Secondary
	BackWeaponSocketNames[2] = Weapon_Pistol
	BackWeaponSocketNames[3] = Weapon_C4
	BackWeaponSocketNames[4] = Weapon_Item
}