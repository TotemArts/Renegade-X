/*********************************************************
*
* File: Rx_Vehicle.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/
class Rx_Vehicle extends UTVehicle
	//implements(Rx_IPurchasable) DEPRACATED ITEM
	implements(RxIfc_ClientSideInstantHitRadius)
	implements(RxIfc_SeekableTarget)
	implements(RxIfc_EMPable)
	implements(RxIfc_TargetedDescription)
	implements(RxIfc_Airlift)
	implements(RxIfC_RadarMarker);

`define TakeEMPDamage TakeDamage(EMPDamage,EMPInstigator,vect(0,0,0),vect(0,0,0),EMPDmgType,,self)

var GameSkelCtrl_Recoil    Recoil;
var bool bLightArmor; //Used for an armour modifier
var const bool bIsAircraft;
var name RecoilTriggerTag; // call same as FireTriggerTags in Vehicle Weapon!
var bool bUsesBullets;
var Pawn PawnThatTrysToDrive;
var byte TeamBought; // to save the Teamnum before going neutral for vehiclecounter calculations
var repnotify bool fpCamera;
var name fpCameraTag;
var name tpCameraTag;
var int ZoomedFOV;
var PlayerReplicationInfo buyerPri;
var PlayerReplicationInfo BoundPRI;
var float TimeLastOccupied;
var bool bDriverLocked;
var bool bReservedToBuyer;
var float startTime;
var byte LastTeamToUse;
var bool bBindable;
var float ReservationLength;
var float oldMaxEngineTorque, oldThrottleSpeed;
var interpCurveFloat oldTorqueVSpeedCurve;

// UTVehicle only replicates driver and 1st passenger PRI. We need more of them.
var PlayerReplicationInfo Passenger2PRI;
var PlayerReplicationInfo Passenger3PRI;
var PlayerReplicationInfo Passenger4PRI;
var PlayerReplicationInfo Passenger5PRI;

var bool bOkAgainstBuildings; // Hint for AI

var protected float SavedDmg;
var const float     HealPointsScale;        /** how many points per healed HP */
var const float     DamagePointsScale;      /** how many points per damaged HP */
var const float     PointsForDestruction;
var repnotify bool  bReverseSteeringInverted;

var repnotify bool bEMPd;
var Controller EMPInstigator;
var int EMPTimeLeft;
//var ParticleSystem EMPParticleTemplate;
var ParticleSystemComponent EMPParticleComponent;
var bool bEMPParticleAttached;

var int EMPTime;
var int EMPDamage;
var class<DamageType> EMPDmgType;
var AudioComponent EMPSound;

var name BrakeLightParameterName;	// material parameter that should be modified to turn the brake lights on and off
var name ReverseLightParameterName;	// material parameter that should be modified to turn the reverse lights on and off
var name HeadLightParameterName;	// material parameter that should be modified to turn the headlights on and off
var bool bBrakeLightOn;				// Internal variable.  Maintains brake light state to avoid extraMatInst calls.
var bool bReverseLightOn;			// Internal variable.  Maintains reverse light state to avoid extra MatInst calls.
var bool bHeadlightsOn;				// Internal variable.  Maintains headlight state to avoid extra MatInst calls.

var SoundCue SuspensionShiftSound;	/** Sound played whenever Suspension moves suddenly */
var bool bIsReducingFrontalCollisionGrip;

// Modifiers for rockets seeking this actor
var float SeekAimAheadModifier;
var float SeekAccelrateModifier;
var float ReducedThrottleForTurning;
var float SpeedAtWhichToApplyReducedTurningThrottle;
var SkeletalMesh SkeletalMeshForPT;

/** Wheel Dirt Fix Variables*/
var array<ParticleSystemComponent> WheelPSCs;
var ParticleSystem DefaultWheelPSCTemplate;
var ParticleSystem WheelParticleEffect, OldWheelParticleEffect;
var UTPhysicalMaterialProperty OldPhysicalProperty;

var bool bSprinting;
var repnotify bool bSprintingServer;

/**Shahman: Variables when being detected*/
var bool bSpotted;
var bool bTargetted;
var bool bFocused; 

/** Minimum speed multiplier for sprinting. */
var(Vehicle) repnotify float MinSprintSpeedMultiplier;

/** Maximum speed multiplier for sprinting. */
var(Vehicle) float MaxSprintSpeedMultiplier;

/** time interval for reaching maximum sprint speed. */
var(Vehicle) float SprintTimeInterval;

/** increment amount for addding/subtracting sprint speed modifier. */
var(Vehicle) float SprintSpeedIncrement;

var() SoundCue SprintBoostSound, SprintStopSound;

var bool bSecondaryFireTogglesFirstPerson;
var bool bCanResetSlip;

var Rx_Speaker Speaker;
//var bool bBlinkingName;

var byte UISymbol; 
/** reference to the texture to use for the Hud */
var() Texture VehicleIconTexture;
var() Texture MinimapIconTexture;

var float RegenerationRate, HeroicRegenerationRate;

/*For commander targeting*/
var bool bIsTarget;
var bool bIsDefensiveTarget; 
var bool bIsAdminTarget;  

//Veterancy
var repnotify byte VRank; 
var byte TempVRank; //Hold onto the last VRank piloting if the driver leaves [avoids exploting getting out of a vehicle just before it explodes to deny bonuses]
var int VPReward[4]; 
var float Vet_HealthMod[4]; //Health Increases for this vehicle as it ranks up (*X)
var float Vet_SprintSpeedMod[4]; //Sprint speed increases for this vehicle as it ranks up. (*X)
var float Vet_SprintTTFD[4] ; //SprintTrackTorqueFactorDivident change so we can still turn with faster sprint speeds. (+X)
var bool bHasPlayerEntered;

var bool bHijackBonus; /*When true, the vehicle grants a bonus when stolen. Resets after a minute and a half to prevent team-hampering*/
var const int VPCost[3]; 
var bool bAlwaysRegenerate; //Should this unit ALWAYS regenerate? 
var bool bCanBePromoted ; 
var float LegitamateDamage;
var bool bTakingDamage; 
var float MaxDR; //Maximum resistance. Lower numbers are more resilient (0.0 is 100% resistance, 1.0 is no resistance)
/*Copied from beacons*/
var float					  Damage_Taken;

//For determining some VP stuff
var string SpotLocation; //Updated once per SpotUpdateTime
var float SpotUpdateTime; //Time to wait between updates (in seconds)

/*Track who does damage to me so I can distribute points correctly on death*/
struct Attacker
{
	var PlayerReplicationInfo PPRI; 
	var float DamageDone; 
	var float LastDamageTime; 
};

var array<Attacker>	DamagingParties;	//Track who is doing damage to me to evenly distribute points

struct Repairer
{
	var PlayerReplicationInfo 	PPRI;
	var float					LastRepairTime;
};
var array<Repairer> CurrentHealers; //Track all healers from the last ten seconds  

var float DeathImpulseStrength; 

//Comm Centre
var byte RadarVisibility, LastRadarVisibility; //Set radar visibility. 0: Invisible to all 1: visible to your team 2: visible to enemy team 
//Shadow Bounds Scale (nBab)
var DynamicLightEnvironmentComponent MyLightEnvironment;

var array<float> BarrelLength; //Estimated length of the vehicle's barrels. Used to adjust where projectiles are spawned when clipping through geometry

//Heroic Effects 
var ParticleSystem		Heroic_MuzzleFlash;

var	repnotify bool				bPickedUp;

/** Rx_IPurchasable */
var const bool bHighTier;
var const int BasePurchaseCost;
var const localized string PT_Title;
var const localized string PT_Description;
var const Texture2D PT_Icon;

var protected repnotify LinearColor VehicleOverlayColour; 
//For HUD stuff, should only be used by mods/mutators.
var string CustomVehicleName;

//Death impulse 
var rotator DestroyedRotatorAddend; 
var float 	DestroyedImpulseOffset; //location + this is where the death impulse is applied (along the Y-axis)
var bool	bStayUprightOnDeath;

var float TestFric; 

// Vars for Transitioning between vehicle and pawn cam when entering/exiting vehicles
var vector VehiclePawnTransitionStartLoc;
var float BlendPct;
var vector CalcViewLocation;

//Voice override for Pawns (Unused by most vehicles, so should be none)
var class<Rx_Pawn_VoiceClass> VehicleVoiceClass;

replication
{
	if (bNetDirty && Role == ROLE_Authority )
		SavedDmg, bReverseSteeringInverted, bSprintingServer, MinSprintSpeedMultiplier, bSpotted, bFocused, buyerPri, BoundPRI, bDriverLocked, bReservedToBuyer, bEMPd, UISymbol, VRank, RadarVisibility, bPickedUp, VehicleOverlayColour, fpCamera; //bBlinkingName

	if (bNetDirty && Role == ROLE_Authority && Seats.Length >= 3)
		Passenger2PRI;

	if (bNetDirty && Role == ROLE_Authority && Seats.Length >= 4)
		Passenger3PRI;

	if (bNetDirty && Role == ROLE_Authority && Seats.Length >= 5)
		Passenger4PRI;
}
/**DEPRACATED FUNCTIONS
static function int ClassToIndex() {
	local int Index;
	ScriptTrace();
	
	Index = `RxGameObject.PurchaseSystem.GDIVehicleClasses.find(default.Class);
	if (Index >= 0)
		return Index;

	return `RxGameObject.PurchaseSystem.NodVehicleClasses.find(default.Class);
	
}

// Purchasing
static function Purchase(Rx_PRI Context) {
	local int RealCost;
	local Rx_Controller ContextController;

	ScriptTrace();
	
	if (Available(Context) == PURCHASE_AVAILABLE) {
		// The class is purchasable
		RealCost = Cost(Context);
		if (FFloor(Context.GetCredits()) >= Cost(Context)) {
			ContextController = Rx_Controller(Context.Owner);
			
			// We have enough credits; purchase the vehicle
			if (`RxGameObject.PurchaseSystem.VehicleManager.QueueVehicle(default.Class, Context, ClassToIndex())) {
				Context.RemoveCredits(RealCost);
			
				if (Context.AirdropCounter > 0) {
					Context.AirdropCounter++;
					if (`WorldInfoObject.NetMode == NM_Standalone)
						Context.LastAirdropTime = `WorldInfoObject.TimeSeconds;
				}

				//return true;
			} 
			else {
				ContextController.clientmessage("You have reached the queue limit, vehicle not added to the queue!", 'Vehicle');				
				//return false;
			}
		}
	} 
}
*/
static function int Cost(Rx_PRI Context) {
	local float Multiplier;
	
	Multiplier = 1.0;
	
	if (`RxGameObject.PurchaseSystem.AreTeamPowerPlantsDestroyed(Context.GetTeamNum())) 
		Multiplier = 1.5;
	
	if (`RxGameObject.PurchaseSystem.AreTeamFactoriesDestroyed(Context.GetTeamNum()))
		Multiplier *= 2;

	return default.BasePurchaseCost * Multiplier;
}

static function EAvailability Available(Rx_PRI Context) 
{
	
	if (default.bHighTier && `RxGameObject.PurchaseSystem.AreTeamFactoriesDestroyed(Context.GetTeamNum())) 
	{
			return PURCHASE_HIDDEN;
	}
	
	return PURCHASE_AVAILABLE;
}

/**DEPRACATED - Remove at will-
 
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

// Metadata
static function int StatType() {
	return 3;
}

static function int DamageOutOfSix() {
	return 0;
}

static function int RangeOutOfSix() {
	return 0;
}

static function int RateOfFireOutOfSix() {
	return 0;
}

static function int MagazineCapacityOutOfSize() {
	return 0;
}
*/ 

static function Rx_Building_VehicleFactory GetVehicleFactory(byte TeamNum) {
	if (TeamNum == TEAM_GDI)
		return `RxGameObject.PurchaseSystem.WeaponsFactory[0];
	
	return `RxGameObject.PurchaseSystem.Airstrip[0];
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bEMPd')
	{
		if (bEMPd)
		{
			StartEMPEffects();
			// Fallback timer in case StopEffects doesn't work the first time it is called due to a bug that may/may not still exist.
			SetTimer(EMPTime+2,false,'FallbackStopEMPEffects');
		}
		else
		{
			StopEMPEffects();
			UpdateThrottleAndTorqueVars();
		}
			
	}
	else if(VarName == 'bSprintingServer')
	{
		if(!bSprintingServer && IsTimerActive('DecreaseSprintSpeed'))
		{
			ClearTimer('DecreaseSprintSpeed');
			UpdateThrottleAndTorqueVars();
		}
				
		if(UDKVehicleSimChopper(SimObj) != None)
		{
			UDKVehicleSimChopper(SimObj).MaxStrafeForce = bSprintingServer ? UDKVehicleSimChopper(SimObj).Default.MaxStrafeForce * Rx_Vehicle_Air(self).MaxStrafeForce : UDKVehicleSimChopper(SimObj).Default.MaxStrafeForce;
			UDKVehicleSimChopper(SimObj).MaxRiseForce = bSprintingServer ? UDKVehicleSimChopper(SimObj).Default.MaxRiseForce * Rx_Vehicle_Air(self).MaxRiseForce : UDKVehicleSimChopper(SimObj).Default.MaxRiseForce;
			UDKVehicleSimChopper(SimObj).MaxYawRate = bSprintingServer ? UDKVehicleSimChopper(SimObj).Default.MaxYawRate * Rx_Vehicle_Air(self).MaxYawRate : UDKVehicleSimChopper(SimObj).Default.MaxYawRate;
			UDKVehicleSimChopper(SimObj).RollTorqueStrafeFactor = bSprintingServer ? UDKVehicleSimChopper(SimObj).Default.RollTorqueStrafeFactor * Rx_Vehicle_Air(self).RollTorqueStrafeFactor : UDKVehicleSimChopper(SimObj).Default.RollTorqueStrafeFactor;
			UDKVehicleSimChopper(SimObj).PitchTorqueFactor = bSprintingServer ? UDKVehicleSimChopper(SimObj).Default.PitchTorqueFactor * Rx_Vehicle_Air(self).PitchTorqueFactor : UDKVehicleSimChopper(SimObj).Default.PitchTorqueFactor;	
		} 
		 			
	}
	else if(VarName == 'MinSprintSpeedMultiplier')
	{
		UpdateThrottleAndTorqueVars();
	}
	else if(VarName == 'bIsTarget')
	{
		if(bIsTarget)
			SetTargetAlarm(25);
	}
	else if(VarName == 'VRank')
	{
		
		if(Vrank == 3)
		{
			SetHeroicMuzzleFlash(true);
		}
		else		
		{
			SetHeroicMuzzleFlash(false);	
		}

	}
	else if(VarName == 'bPickedUp')
	{
		if(bPickedUp) SetPhysics(PHYS_NONE); 
		else
		SetPhysics(PHYS_RigidBody);
	}
	else if(VarName == 'VehicleOverlayColour')
	{
		SetOverlay(VehicleOverlayColour);
	} else if(VarName == 'fpCamera')
	{
		if(!fpCamera)
		{
			fpCamera = false;
			Seats[0].CameraTag = tpCameraTag;
			OldPositions.Length=0;
		}
		else
		{
			fpCamera = true;
			Seats[0].CameraTag = fpCameraTag;
		}
	}
	else
		super.ReplicatedEvent(VarName);

}


simulated function SetRadarVisibility(byte Visibility)
{
	RadarVisibility = Visibility; 
	
	if(Rx_PRI(PlayerReplicationInfo) != none) 
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
	else
	if(Rx_Vehicle_HarvesterController(Controller) != none )
	{
	Rx_Vehicle_HarvesterController(Controller).SetSpottedRadarVisibility();
	}
}

simulated function PlayerReplicationInfo GetSeatPRI(int SeatNum)
{
	if ( Role == ROLE_Authority )
	{
		return Seats[SeatNum].SeatPawn.PlayerReplicationInfo;
	}
	else
	{
		switch(seatNum)
		{
		case 0:
			return PlayerReplicationInfo;
		case 1:
			return PassengerPRI;
		case 2:
			return Passenger2PRI;
		case 3:
			return Passenger3PRI;
		case 4:
			return Passenger4PRI;
		}
	}
}

function SetSeatStoragePawn(int SeatIndex, Pawn PawnToSit)
{
	//local Rx_Vehicle_Attacheable Tur;
	
	super.SetSeatStoragePawn(seatindex,pawntosit);
	
	switch(SeatIndex)
	{
	case 2:
		 Passenger2PRI = (PawnToSit == None) ? None : Seats[SeatIndex].SeatPawn.PlayerReplicationInfo;
		
	case 3:
		Passenger3PRI = (PawnToSit == None) ? None : Seats[SeatIndex].SeatPawn.PlayerReplicationInfo;
	case 4:
		Passenger4PRI = (PawnToSit == None) ? None : Seats[SeatIndex].SeatPawn.PlayerReplicationInfo;
	}
		
}

function startUpDriving()
{
	SetTimer(1.0,false,'moveVehicleAwayFromSpawnpoint');
	SetTimer(ReservationLength,false,'openVehToAllPlayersAfterBuy');
	startTime = WorldInfo.TimeSeconds;
}

function startUpDrivingWithDelay()
{
	SetTimer(2.5,false,'moveVehicleAwayFromSpawnpointAir');
	SetTimer(ReservationLength,false,'openVehToAllPlayersAfterBuy');
	startTime = WorldInfo.TimeSeconds;
}

function ToggleCam()
{
	if(fpCamera)
	{
		fpCamera = false;
		Seats[0].CameraTag = tpCameraTag;
		OldPositions.Length=0;
		//Mesh.SetHidden(false);
		UTPlayercontroller(Controller).setFOV(DefaultFOV);
	}
	else
	{
		fpCamera = true;
		Seats[0].CameraTag = fpCameraTag;
		//Mesh.SetHidden(true);
		UTPlayercontroller(Controller).setFOV(ZoomedFOV);
	}
	ServerChangeFpCamera(fpCamera);
}

reliable server function ServerChangeFpCamera(bool newFpCamera)
{
	fpCamera = newFpCamera;
}

simulated event PostBeginPlay()
{
	local int i;
	
	super.PostBeginPlay();
	Team  = 255;
	
	//set shadow frustum scale (nBab)
	SetShadowBoundsScale();
	
	if(ROLE == ROLE_Authority && Rx_Vehicle_Harvester(self) == none && Rx_Defence(self) == none) 
	{
		bAlwaysRelevant = Rx_Game(WorldInfo.Game).bVehiclesAlwaysRelevant; 
		
		if(!bAlwaysRelevant) 
			SetTimer(0.1,true,'UpdatePRILocation'); 
	}
	
	if (Mesh != None && (ROLE == ROLE_SimulatedProxy || WorldInfo.NetMode == NM_StandAlone) && Rx_Vehicle_Air(self) == None)
	{
		SetTimer(0.5, true, 'CheckWheelEmitters');
		for( i=0; i< Wheels.Length; i++ )
		{
			WheelPSCs[i] = new () class'ParticleSystemComponent';
			if( WheelPSCs[i] != none )
			{
				WheelPSCs[i].SetTemplate(DefaultWheelPSCTemplate);
				Mesh.AttachComponentToSocket(WheelPSCs[i], name("WheelEffectSocket"$i));
			}
			OldWheelParticleEffect = DefaultWheelPSCTemplate;
		}
	}
	//if(ROLE == ROLE_Authority && Controller != none) RadarVisibility = Rx_Controller(Controller).GetRadarVisibility();

	MaterialInstanceConstant(Mesh.GetMaterial(0)).SetScalarParameterValue('Camo_Offset_Seed', FRand());
	MaterialInstanceConstant(Mesh.GetMaterial(0)).SetScalarParameterValue('Camo_Scale_Seed', (FRand() % 0.4) + 0.8);

	SetTimer(SpotUpdateTime,true,'UpdateSpotLocation');
}

//set shadow frustum scale (nBab)
simulated function SetShadowBoundsScale()
{
	MyLightEnvironment = DynamicLightEnvironmentComponent(Mesh.LightEnvironment);
	MyLightEnvironment.LightingBoundsScale = Rx_MapInfo(WorldInfo.GetMapInfo()).GroundVehicleShadowBoundsScale;
	Mesh.SetLightEnvironment(MyLightEnvironment);
}

// Turn lights on/off and also control tail, break, and reverse lights
function Tick( FLOAT DeltaSeconds )
{
	local bool bSetBrakeLightOn, bSetReverseLightOn;	

	// client side effects follow - return if server or not rendered
	if (LastRenderTime < WorldInfo.TimeSeconds - 0.2)
		return;

	// Update brake light and reverse light
	// Both lights default to off.

	// check if scorpion is braking
	if( ( (OutputBrake > 0.0) || bOutputHandbrake) && (VSizeSq(Velocity) > 4.0) )
	{
		bSetBrakeLightOn = true;
		if ( !bBrakeLightOn )
		{	
			// turn on brake light
			bBrakeLightOn = TRUE;
			if(DamageMaterialInstance[0] != None)
			{
				DamageMaterialInstance[0].SetScalarParameterValue(BrakeLightParameterName, 2.0 );
			}
		}
	}

	// check if vehicle is in reverse
	if ( Throttle < 0.0 )
	{
		bSetReverseLightOn = true;
		if ( !bReverseLightOn )
		{
			// turn on reverse light
			bReverseLightOn = true;
			if(DamageMaterialInstance[0] != None)
			{
				DamageMaterialInstance[0].SetScalarParameterValue(ReverseLightParameterName, 1.0 );
			}
		}
	}
	
	if( Rx_Vehicle_Treaded(self) != None && Steering != 0 && Throttle > 0 && VSizeSq(Velocity) > Square(SpeedAtWhichToApplyReducedTurningThrottle))
	{
		Throttle = ReducedThrottleForTurning;
	}

	if ( bBrakeLightOn && !bSetBrakeLightOn )
	{
		// turn off brake light
		bBrakeLightOn = false;
		if(DamageMaterialInstance[0] != None)
		{
			DamageMaterialInstance[0].SetScalarParameterValue(BrakeLightParameterName, 1.0 );
		}
	}
	if ( bReverseLightOn && !bSetReverseLightOn )
	{
		// turn off reverse light & goto normal tail lights
		bReverseLightOn = false;
		if(DamageMaterialInstance[0] != None)
		{
			DamageMaterialInstance[0].SetScalarParameterValue(ReverseLightParameterName, 0.0 );
		}
	}

	// update headlights & breaklights (Basically switch lights off when the vehicle is empty)
	if ( bHeadlightsOn )
	{
		if ( PlayerReplicationInfo == None )
		{
			// turn off headlights
			bHeadlightsOn = false;
			if(DamageMaterialInstance[0] != None)
			{
				DamageMaterialInstance[0].SetScalarParameterValue(HeadLightParameterName, 0.0 );
				DamageMaterialInstance[0].SetScalarParameterValue(BrakeLightParameterName, 0.0 );
			}
		}
	}
	else if ( PlayerReplicationInfo != None )
	{
		// turn on headlights
		bHeadlightsOn = true;
		if(DamageMaterialInstance[0] != None)
		{
			DamageMaterialInstance[0].SetScalarParameterValue(HeadLightParameterName, 1.0 );
			DamageMaterialInstance[0].SetScalarParameterValue(BrakeLightParameterName, 1.0 );
		}
	}

	
}

function StartSprint()
{
	if(!bSprinting && !bEMPd)
	{
		if(!IsTimerActive('IncreaseSprintSpeed'))
		{
	    
			//if(MinSprintSpeedMultiplier*Vet_SprintSpeedMod[VRank] == Default.MinSprintSpeedMultiplier*Vet_SprintSpeedMod[VRank])
				if(MinSprintSpeedMultiplier*GetSpeedModifier() == Default.MinSprintSpeedMultiplier*GetSpeedModifier())
				IncreaseSprintSpeed();
			else
				SetTimer(SprintTimeInterval, true, 'IncreaseSprintSpeed');
		}
		if(IsTimerActive('DecreaseSprintSpeed'))
		{
			ClearTimer('DecreaseSprintSpeed');
		}
		
		VehicleEvent('SprintStart');
		if(SprintBoostSound != none) PlaySound(SprintBoostSound, TRUE, FALSE, FALSE, Location, FALSE);
		bSprinting = true;
	}
}

function StopSprinting()
{
	
	if(bSprinting)
	{
		bSprinting = false;
		if(!IsTimerActive('DecreaseSprintSpeed'))
		{
			SetTimer(0.25, true, 'DecreaseSprintSpeed');
		}
		if(IsTimerActive('IncreaseSprintSpeed'))
		{
			ClearTimer('IncreaseSprintSpeed');
		}

		VehicleEvent('SprintStop');
		if(SprintStopSound != none) PlaySound(SprintStopSound, TRUE, FALSE, FALSE, Location, FALSE);
		
	}
}

reliable server function ServerSetGroundSpeed(float Speed)
{
	if(bEMPd) Speed = 0; 
	
	if(Speed > default.GroundSpeed)
	{
		bSprintingServer = true;
	} 
	else
	{
		bSprintingServer = false;
	}
	GroundSpeed = Speed;	
}
reliable server function ServerSetAirSpeed(float Speed)
{
	if(bEMPd) Speed = 0; 
	
	if(Speed > default.AirSpeed)
	{
		bSprintingServer = true;
	} 
	else
	{
		bSprintingServer = false;
	}
	AirSpeed = Speed;	
}
reliable server function ServerSetWaterSpeed(float Speed)
{
	if(bEMPd) Speed = 0; 
	
	if(Speed > default.WaterSpeed)
	{
		bSprintingServer = true;
	} 
	else
	{
		bSprintingServer = false;
	}
	WaterSpeed = Speed;	
}
reliable server function ServerSetMaxSpeed(float Speed)
{
	if(bEMPd) Speed = 0; 
	
	if(Speed > default.MaxSpeed)
	{
		bSprintingServer = true;
	} 
	else
	{
		bSprintingServer = false;
	}
	MaxSpeed = Speed;	
}

reliable server function IncreaseSprintSpeed()
{
	local float SprintSpeed_Air;
	local float SprintSpeed_Ground;
	local float SprintSpeed_Water;
	local float VGround_SprintSpeedMax;
	
	if(bEMPd) return; 
	
	VGround_SprintSpeedMax = default.MaxSprintSpeedMultiplier*GetSpeedModifier() ;//*Vet_SprintSpeedMod[VRank] ;
	//`log(VGround_SprintSpeedMax);
	MinSprintSpeedMultiplier += SprintSpeedIncrement*GetSpeedModifier();//Vet_SprintSpeedMod[VRank];
	//`log(SprintSpeedIncrement*Vet_SprintSpeedMod[VRank]);
	
	if(MinSprintSpeedMultiplier >= VGround_SprintSpeedMax)
	{
		MinSprintSpeedMultiplier = VGround_SprintSpeedMax;
		if(IsTimerActive('IncreaseSprintSpeed'))
		{
			ClearTimer('IncreaseSprintSpeed');
		}
	}

	SprintSpeed_Air = Default.AirSpeed * MinSprintSpeedMultiplier * GetSpeedModifier() * GetScriptedSpeedModifier();//Vet_SprintSpeedMod[VRank];
	SprintSpeed_Ground = Default.GroundSpeed * MinSprintSpeedMultiplier * GetSpeedModifier() * GetScriptedSpeedModifier();//Vet_SprintSpeedMod[VRank];
	SprintSpeed_Water = Default.WaterSpeed * MinSprintSpeedMultiplier * GetSpeedModifier() * GetScriptedSpeedModifier();//Vet_SprintSpeedMod[VRank];

	if(PlayerController(Controller) != None)
	{
		ServerSetAirSpeed(SprintSpeed_Air);
		ServerSetGroundSpeed(SprintSpeed_Ground);
		ServerSetWaterSpeed(SprintSpeed_Water);
	}

	AirSpeed = SprintSpeed_Air;
	GroundSpeed = SprintSpeed_Ground;
	WaterSpeed = SprintSpeed_Water;

	if(UDKVehicleSimCar(SimObj) != None)
		UDKVehicleSimCar(SimObj).ThrottleSpeed = UDKVehicleSimCar(SimObj).Default.ThrottleSpeed * MinSprintSpeedMultiplier * GetScriptedSpeedModifier();
}
reliable server function DecreaseSprintSpeed()
{
	
	//`log("Tried to decrease");
	MinSprintSpeedMultiplier -= SprintSpeedIncrement;
	if(MinSprintSpeedMultiplier <= Default.MinSprintSpeedMultiplier)
	{
		MinSprintSpeedMultiplier = Default.MinSprintSpeedMultiplier;
		if(IsTimerActive('DecreaseSprintSpeed'))
		{
			ClearTimer('DecreaseSprintSpeed');
		}
	}

	if(PlayerController(Controller) != None)
	{
		ServerSetAirSpeed(AirSpeed);
		ServerSetGroundSpeed(GroundSpeed);
		ServerSetWaterSpeed(WaterSpeed);
	}

	AirSpeed = Default.AirSpeed * GetScriptedSpeedModifier();
	GroundSpeed = Default.GroundSpeed * GetScriptedSpeedModifier();
	WaterSpeed = Default.WaterSpeed * GetScriptedSpeedModifier();

	if(UDKVehicleSimCar(SimObj) != None)
		UDKVehicleSimCar(SimObj).ThrottleSpeed = UDKVehicleSimCar(SimObj).Default.ThrottleSpeed * GetScriptedSpeedModifier();
}

reliable server function HardSprintStop()
{
	
	//`log("Tried to decrease");
	MinSprintSpeedMultiplier -= default.MinSprintSpeedMultiplier  * GetScriptedSpeedModifier();
	if(IsTimerActive('DecreaseSprintSpeed'))
	{
		ClearTimer('DecreaseSprintSpeed');
	}
	
	AirSpeed = Default.AirSpeed * GetScriptedSpeedModifier();
	GroundSpeed = Default.GroundSpeed * GetScriptedSpeedModifier();
	WaterSpeed = Default.WaterSpeed * GetScriptedSpeedModifier();

	if(PlayerController(Controller) != None)
	{
		ServerSetAirSpeed(AirSpeed);
		ServerSetGroundSpeed(GroundSpeed);
		ServerSetWaterSpeed(WaterSpeed);
	}

	if(UDKVehicleSimCar(SimObj) != None)
		UDKVehicleSimCar(SimObj).ThrottleSpeed = UDKVehicleSimCar(SimObj).Default.ThrottleSpeed  * GetScriptedSpeedModifier();
}

function UnmarkTarget()
{
	bTargetted = false;
}

simulated function vector GetCameraStart(int SeatIndex)
{
	local vector CamStart;

	if (fpCamera && SeatIndex == 0 && Seats[SeatIndex].CameraTag != '')
	{
		if (Mesh.GetSocketWorldLocationAndRotation(Seats[SeatIndex].CameraTag, CamStart) )
		{
			return CamStart;
		}
	}
	return Super.GetCameraStart(SeatIndex);
}


simulated function DrivingStatusChanged()
{
	// turn parking friction on or off
	bUpdateWheelShapes = true;

	// possibly use different physical material while being driven (to allow properties like friction to change).
	
	if ( bDriving )
	{
		if(Role == ROLE_Authority && Rx_Vehicle_Treaded(self) != None)
		{
			SetTimer(0.05,true,'FrontalCollisionGripReductionTimer');
		}
		if ( DrivingPhysicalMaterial != None )
		{
			DrivingPhysicalMaterial.friction=0.7;
			DrivingPhysicalMaterial.bEnableAnisotropicFriction=true;
			DrivingPhysicalMaterial.AnisoFrictionDir=vect(1.0,1.0,1.0); 			
			Mesh.SetPhysMaterialOverride(DrivingPhysicalMaterial);
		}
	}
	else if ( DefaultPhysicalMaterial != None )
	{
		DefaultPhysicalMaterial.friction=0.7;
		DefaultPhysicalMaterial.bEnableAnisotropicFriction=false;
		DefaultPhysicalMaterial.AnisoFrictionDir=vect(0.0,0.0,0.0); 			
		Mesh.SetPhysMaterialOverride(DefaultPhysicalMaterial);
	}

	if ( bDriving && !bIsDisabled )
	{
		VehiclePlayEnterSound();
	}
	else if ( Health > 0 )
	{
		VehiclePlayExitSound();
	}

	bBlocksNavigation = !bDriving;

	if (!bDriving)
	{
		StopFiringWeapon();

		SetMovementEffect(0, false);
		SetTexturesToBeResident(false);
		
		if(Role == ROLE_Authority)
		{
			ClearTimer('FrontalCollisionGripReductionTimer');
		}		
	}

	VehicleEvent(bDriving ? 'EngineStart' : 'EngineStop');
}

/**
simulated function DrivingStatusChanged() 
{

	super.DrivingStatusChanged();
	if(bDriving)
	{
		if(Role == ROLE_Authority && Rx_Vehicle_Treaded(self) != None)
		{
			SetTimer(0.05,true,'FrontalCollisionGripReductionTimer');
		}
		if ( DrivingPhysicalMaterial != None )
		{
			DrivingPhysicalMaterial.friction=0.7;
			DrivingPhysicalMaterial.bEnableAnisotropicFriction=true;
			DrivingPhysicalMaterial.AnisoFrictionDir=vect(1.0,1.0,1.0); 
			Mesh.SetPhysMaterialOverride(DrivingPhysicalMaterial);
		}		
	}
	else 
	{
		if(Role == ROLE_Authority)
		{
			ClearTimer('FrontalCollisionGripReductionTimer');
		}
	}
}
*/

function FrontalCollisionGripReductionTimer()
{
	local int i;
	
	if(Rx_Vehicle_Harvester(self) == None && Rx_Vehicle_Treaded(self) != None)
	{
		

		if(bFrontalCollision && !bIsReducingFrontalCollisionGrip)
		{
			for(i=0; i<Wheels.length; i++)
			{
				if(UDKVehicleWheel(Wheels[i]) != None)
				{
					Wheels[i].LongSlipFactor = 0.1;
				}
			}
			bIsReducingFrontalCollisionGrip = true;
			bCanResetSlip = false;
			SetTimer(1.0, false, 'canResetSlipTimer');
		}
		
		if(Throttle == 0.0)
			bCanResetSlip = true; 
		if(!bFrontalCollision && bCanResetSlip && bIsReducingFrontalCollisionGrip) 
		{
			for(i=0; i<Wheels.length; i++)
			{
				if(UDKVehicleWheel(Wheels[i]) != None)
				{
					Wheels[i].LongSlipFactor = Wheels[i].default.LongSlipFactor;
				}
			}
			bIsReducingFrontalCollisionGrip = false;
		}
	}
}

function canResetSlipTimer()
{
	bCanResetSlip = true;
} 

/** added recoil */
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	if (SkelComp == Mesh && Mesh != none)
		Recoil = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil') );
}

/**
 * Team is changed when vehicle is possessed
 */
event SetTeamNum(byte toTeam)
{
	local byte from;
	if ( toTeam != Team )
	{
		from = Team;
		Team = toTeam;
		NotifyCaptuePointsOfTeamChange(from, toTeam);
		TeamChanged();
	}
}

simulated function TeamChanged()
{
	if (Rx_GRI(WorldInfo.GRI) != none)
		Rx_GRI(WorldInfo.GRI).VehChangedTeam(self);
}

function NotifyCaptuePointsOfTeamChange(byte from, byte to)
{
	local Rx_CapturePoint CP;

	foreach TouchingActors(class'Rx_CapturePoint', CP)
		CP.NotifyVehicleTeamChange(self,from,to);
}

/**
 * An interface for causing various events on the vehicle.
 * also recoil is called here
 */
simulated function VehicleEvent(name EventTag)
{
	super.VehicleEvent(EventTag);

	if (RecoilTriggerTag == EventTag && Recoil != none)
		Recoil.bPlayRecoil = true;
}

exec function ReloadWeapon()
{
	if( Weapon != none && Rx_Vehicle_Weapon_Reloadable(Weapon) != none )
	{
		Rx_Vehicle_Weapon_Reloadable(Weapon).ReloadWeapon();
	}
}

simulated function EntryAnnouncement(Controller C)
{
	// dont call super to remove the Hijacked sounds
}

function bool TryToDrive(Pawn P)
{
	local vector X,Y,Z;
	local bool bFreedSeat;
	local bool bEnteredVehicle;

	local Pawn DriverTemp;
	local Rx_SoftLevelBoundaryVolume volume;
	local Rx_Controller PC;

	// Bots should only be drivers, not passengers
	if(Rx_VehRolloutController(Controller) == None && Driver != None && UTBot(P.Controller) != None) 
		return false; 

	PC = Rx_Controller(P.PlayerReplicationInfo.Owner);
	
	if(PC != None && PlayAreaVolumeOfPawn(self) == None && PlayAreaVolumeOfPawn(P) != None)
	{	
		PC.clientmessage("Try entering the vehicle from another side! As the vehicle is outside the map boundaries it can´t be entered from your current location!");
		return false; // Pawn has to step out of the PlayArea aswell so that he triggers the PlayArea UnTouch() event
	}	

	// disallow entering scripted bot's vehicle
	if(Rx_Bot_Scripted(Controller) != None)
	{
		PC.clientmessage("This vehicle is being controlled by an NPC!");
		return false;
	}

	if(buyerPri != none)
	{ 
		// Known Bug: If a player buys a vehicle then switches team, he'll be able to get in the vehicle he bought on his old team before exclusive access expires.
		if (bReservedToBuyer && P.PlayerReplicationInfo != buyerPri)
		{
			if(P.PlayerReplicationInfo.Owner != None && PC != None) 
			{
				PC.ReceiveVehicleMessageWithInt(class'Rx_Message_Vehicle',VM_NoEntry_BuyerReserved,buyerPri,,Class,Int(ReservationLength - `TimeSince(startTime))+1);
			}
			return false;
		}
		else if (P.GetTeamNum() != buyerPri.GetTeamNum())
		{
			if(P.PlayerReplicationInfo.Owner != None && PC != None) 
			{
				PC.ReceiveVehicleMessageWithInt(class'Rx_Message_Vehicle',VM_NoEntry_TeamReserved,buyerPri,,Class,Int(ReservationLength - `TimeSince(startTime))+1);
			}
			return false;
		}
	}

	// If a human tries to enter kick out the Rollout AI driver
	if(Driver != none && Rx_VehRolloutController(Controller) != none) {
		bAllowedExit = true;
		driverTemp = Driver;
		DriverLeave(true);
		driverTemp.Controller.Destroy();
		driverTemp.Destroy();
	}

	PawnThatTrysToDrive = P;    

	// Super call to UTVehicle:

	// don't allow while playing spawn effect
	if (bPlayingSpawnEffect)
	{
		return false;
	}

	// Does the vehicle need to be uprighted?
	if ( bIsInverted && bMustBeUpright && !bVehicleOnGround && VSizeSq(Velocity) <= 25.0f )
	{
		if ( bCanFlip )
		{
			bIsUprighting = true;
			UprightStartTime = WorldInfo.TimeSeconds;
			GetAxes(Rotation,X,Y,Z);
			bFlipRight = ((P.Location - Location) dot Y) > 0;
		}
		return false;
	}

	if ( !CanEnterVehicle(P) || (Vehicle(P) != None) )
	{
		return false;
	}

	// Check vehicle Locking....
	// Must be a non-disabled same team (or no team game) vehicle
	if (!bIsDisabled && (Team == UTVEHICLE_UNSET_TEAM || !bTeamLocked || !WorldInfo.Game.bTeamGame || WorldInfo.GRI.OnSameTeam(self,P)))
	{
		if (bEnteringUnlocks)
		{
			bTeamLocked = false;
			if (ParentFactory != None)
			{
				ParentFactory.VehicleTaken();
			}
		}

		if (!AnySeatAvailable())
		{
			if (WorldInfo.GRI.OnSameTeam(self, P))
			{
				// kick out the first bot in the vehicle to make way for this driver
				bFreedSeat = KickOutBot();
			}

			if (!bFreedSeat)
			{
				// we were unable to kick a bot out
				return false;
			}
		}

		// Look to see if the driver seat is open
		if (Driver == None && ( !bDriverLocked || P.PlayerReplicationInfo == BoundPRI || P.GetTeamNum() != BoundPRI.GetTeamNum() ) )
			bEnteredVehicle = DriverEnter(P);
		else
			bEnteredVehicle = PassengerEnter(P, GetFirstAvailableSeat());

		if( bEnteredVehicle )
		{
			SetTexturesToBeResident( TRUE );
			foreach TouchingActors(class'Rx_SoftLevelBoundaryVolume', volume)
			{
				if (PC.IsInPlayArea)
				{
					PC.PlayAreaLeaveDamageWaitCounter = 0;
					PC.PlayAreaLeaveDamageWait = volume.DamageWait;
					PC.SetTimer(volume.fWaitToWarn, false, 'PlayAreaTimerTick');
					PC.IsInPlayArea = false;
				}
				break;
			}
		}

		return bEnteredVehicle;
	}

	VehicleLocked( P );
	return false;
}

function bool AnySeatAvailable()
{
	if(!super.AnySeatAvailable())
	{
		if (WorldInfo.GRI.OnSameTeam(self, PawnThatTrysToDrive))
		{
			// kick out the first bot in the vehicle to make way for this driver
			return KickOutBot();
		}
		return false;
	}
	return true;
}

function bool ChangeSeat(Controller ControllerToMove, int RequestedSeat)
{
	if (Controller == ControllerToMove && bAllowedExit == false)
		return false;

	if (RequestedSeat == 0 && bDriverLocked && ControllerToMove.PlayerReplicationInfo != BoundPRI)
	{
		if ( PlayerController(ControllerToMove) != None )
		{
			PlayerController(ControllerToMove).ClientPlaySound(VehicleLockedSound);
			PlayerController(ControllerToMove).ReceiveLocalizedMessage(class'Rx_Message_Vehicle',VM_NoEntry_DriverLocked,BoundPRI);
		}
		return false;
	}
	return super.ChangeSeat(ControllerToMove, RequestedSeat);
}

/**
function InitializeSeats()
{
	local int i;

	for(i=0;i<Seats.Length;i++) {
		if(i > 0) {
			Seats[i].GunClass = Seats[0].GunClass; // just to avoid a Nullpointer in super.InitializeSeats(). 
												   // Is resetted to None again after super has been called.
		}
	}
	
	super.InitializeSeats();
	
	for(i=0;i<Seats.Length;i++) {
		if(i > 0) {
			Seats[i].GunClass = None; 
			Seats[i].Gun = None; 
		}
	}    
}*/

function InitializeSeats()
{
	local int i;
	if (Seats.Length==0)
	{
		`log("WARNING: Vehicle ("$self$") **MUST** have at least one seat defined");
		destroy();
		return;
	}

	for(i=0;i<Seats.Length;i++)
	{
		// Seat 0 = Driver Seat.  It doesn't get a WeaponPawn

		if (i>0)
		{
	   		Seats[i].SeatPawn = Spawn(class'Rx_VehicleSeatPawn');
	   		Seats[i].SeatPawn.SetBase(self);
	   		if(Seats[i].GunClass != None)
			{
				Seats[i].Gun = UTVehicleWeapon(Seats[i].SeatPawn.InvManager.CreateInventory(Seats[i].GunClass));
				Seats[i].Gun.SetBase(self);
			}
			Seats[i].SeatPawn.EyeHeight = Seats[i].SeatPawn.BaseEyeheight;
			if(Seats[i].GunClass != None)
				UTWeaponPawn(Seats[i].SeatPawn).MyVehicleWeapon = UTVehicleWeapon(Seats[i].Gun);
			UTWeaponPawn(Seats[i].SeatPawn).MyVehicle = self;
	   		UTWeaponPawn(Seats[i].SeatPawn).MySeatIndex = i;

	   		if ( Seats[i].ViewPitchMin != 0.0f )
	   		{
				UTWeaponPawn(Seats[i].SeatPawn).ViewPitchMin = Seats[i].ViewPitchMin;
			}
			else
	   		{
				UTWeaponPawn(Seats[i].SeatPawn).ViewPitchMin = ViewPitchMin;
			}


	   		if ( Seats[i].ViewPitchMax != 0.0f )
	   		{
				UTWeaponPawn(Seats[i].SeatPawn).ViewPitchMax = Seats[i].ViewPitchMax;
			}
			else
	   		{
				UTWeaponPawn(Seats[i].SeatPawn).ViewPitchMax = ViewPitchMax;
			}
		}
		else
		{
			Seats[i].SeatPawn = self;
			if(Seats[i].GunClass != None)
			{
				Seats[i].Gun = UTVehicleWeapon(InvManager.CreateInventory(Seats[i].GunClass));
				Seats[i].Gun.SetBase(self);
			}
		}

		Seats[i].SeatPawn.DriverDamageMult = Seats[i].DriverDamageMult;
		Seats[i].SeatPawn.bDriverIsVisible = Seats[i].bSeatVisible;

		if (Seats[i].Gun!=none)
		{
			UTVehicleWeapon(Seats[i].Gun).SeatIndex = i;
			UTVehicleWeapon(Seats[i].Gun).MyVehicle = self;
		}

		// Cache the names used to access various variables
   	}
}


function bool PassengerEnter(Pawn P, int SeatIndex)
{
	// Restrict someone not on the same team
	if ( WorldInfo.Game.bTeamGame && GetTeamNum() != 255 && !WorldInfo.GRI.OnSameTeam(P,self) )
	{
		return false;
	}

	if (SeatIndex <= 0 || SeatIndex >= Seats.Length)
	{
		`warn("Attempted to add a passenger to unavailable passenger seat" @ SeatIndex);
		return false;
	}

	if ( !Seats[SeatIndex].SeatPawn.DriverEnter(p) )
	{
		return false;
	}

	HandleEnteringFlag(UTPlayerReplicationInfo(Seats[SeatIndex].SeatPawn.PlayerReplicationInfo));

	SetSeatStoragePawn(SeatIndex,P);

	bHasBeenDriven = true;
	if (GetTeamNum() == 255)
		SetTeamNum(P.GetTeamNum());
	return true;
}

simulated function StopVehicleSounds()
{
	super.StopVehicleSounds();
	//if (EMPSound != None)
		EMPSound.Stop();
}

simulated function StartEMPEffects()
{
	//if (EMPSound != None)
		EMPSound.Play();

	// If for whatever reason an existing component is still present, make sure it is removed.
	/*if (EMPParticleComponent != None)
	{
		EMPParticleComponent.DeactivateSystem();
		DetachComponent(EMPParticleComponent);
		EMPParticleComponent = None;
	}

	if (EMPParticleTemplate != None)
	{
		EMPParticleComponent = new(self) class'ParticleSystemComponent';
		EMPParticleComponent.SetTemplate(EMPParticleTemplate);
		AttachComponent(EMPParticleComponent);
	}*/
	//if (EMPParticleComponent != None)
		EMPParticleComponent.ActivateSystem();
}

simulated function StopEMPEffects()
{
	//if (EMPSound != None)
		EMPSound.Stop();
	//if (EMPParticleComponent != None)
	//{
		EMPParticleComponent.DeactivateSystem();
		//DetachComponent(EMPParticleComponent);
		//EMPParticleComponent = None;
	//}
}

simulated function FallbackStopEMPEffects()
{
	//if (!bEMPd && EMPParticleComponent != None)
	if (!bEMPd && EMPParticleComponent.bIsActive)
	{
		`log("EMP STOP EFFECTS FALLBACK UTILIZED!");
		EMPParticleComponent.DeactivateSystem();
		//DetachComponent(EMPParticleComponent);
		//EMPParticleComponent = None;
	}
}

simulated function bool IsEffectedByEMP()
{
	return  GetResistanceModifier() > 0.7;  //If damage resistance is more than 30% grant EMP immunity ;//true;
}

function EnteredEMPField(Rx_EMPField EMPCausingActor);

function LeftEMPField(Rx_EMPField EMPCausingActor);

simulated function bool EMPHit(Controller InstigatedByController, Actor EMPCausingActor, optional int TimeModifier = 0.0)
{
	if ((InstigatedByController != none && InstigatedByController.GetTeamNum() == GetTeamNum()) || bEMPd)
		return false;

	//`logd("Vehicle EMPd");

	bEMPd = true;
	
	//This is done through replication in a client server environment
	if(WorldInfo.NetMode == NM_StandAlone) StartEMPEffects();
	
	if(bSprinting) StopSprinting(); 
	
	
	
	//`logd(`showvar(simobj));
	if(UDKVehicleSimCar(simobj) != none)
	{
		//oldTorqueVSpeedCurve = UDKVehicleSimCar(simobj).TorqueVSpeedCurve;
		//UDKVehicleSimCar(simobj).TorqueVSpeedCurve = (Points=((InVal=0.0,OutVal=0.0),(InVal=0.0,OutVal=0.0),(InVal=0.0,OutVal=0.0)));
		oldThrottleSpeed = UDKVehicleSimCar(simobj).ThrottleSpeed;
		UDKVehicleSimCar(simobj).ThrottleSpeed = 0;
	}

	if(SVehicleSimTank(simobj) != none)
	{
		oldMaxEngineTorque = SVehicleSimTank(simobj).MaxEngineTorque;
		SVehicleSimTank(simobj).MaxEngineTorque = 0;
	}

	//`logd(`showvar(controller));

	if(Rx_Controller(controller) != none)
		Rx_Controller(controller).OnEMPHit(InstigatedByController, EMPCausingActor, TimeModifier);
	else if(Rx_Bot(controller) != none)
		Rx_Bot(controller).OnEMPHit(InstigatedByController, EMPCausingActor, TimeModifier);
	else if(Rx_Vehicle_HarvesterController(controller) != none)
		Rx_Vehicle_HarvesterController(controller).OnEMPHit(InstigatedByController, EMPCausingActor, TimeModifier);
	
	if(WorldInfo.NetMode == NM_Client) 
		return true; //Cut here for clients
	
	//Knock Aircraft out of the sky
	if(bIsAircraft)
		SetDriving(false);
	
	EMPTimeLeft = (EMPTime + TimeModifier)*GetResistanceModifier();
	EMPInstigator = InstigatedByController;
	
	`TakeEMPDamage;
	
	SetTimer(1.0, true, 'EMPBleed');
	
	if(Rx_Controller(EMPInstigator) != none && EMPInstigator.GetTeamNum() != LastTeamToUse ) {
		Rx_Controller(EMPInstigator).DisseminateVPString("[Vehicle EMP'd]&" $ class'Rx_VeterancyModifiers'.default.Ev_VehicleEMP $ "&"); 
	}
	
	if(Rx_PRI(EMPInstigator.PlayerReplicationInfo) != none && EMPInstigator.GetTeamNum() != LastTeamToUse){
		Rx_PRI(EMPInstigator.PlayerReplicationInfo).AddEMPHit();
		Rx_PRI(EMPInstigator.PlayerReplicationInfo).AddScoreToPlayerAndTeam(0); //EMPs worth 0 actual.. as you get points for the damage already
	}
	
	return true;
}

simulated function  EMPBleed()
{
	`logd("EMPBleed start");
	if (--EMPTimeLeft <= 0)
	{
		ClearTimer('EMPBleed');
		bEMPd = false;
		if(UDKVehicleSimCar(simobj) != none)
		{
			UDKVehicleSimCar(simobj).ThrottleSpeed = oldThrottleSpeed;
			//UDKVehicleSimCar(simobj).TorqueVSpeedCurve = oldTorqueVSpeedCurve;
		}
		if(SVehicleSimTank(simobj) != none)
			SVehicleSimTank(simobj).MaxEngineTorque = oldMaxEngineTorque;
		
			
		if(Role == ROLE_Authority) UpdateThrottleAndTorqueVars();
		
		StopEMPEffects();

		`logd("EMPBleed no time left!");

		if(Rx_Controller(controller) != none)
			Rx_Controller(controller).OnEMPBleed(true);
		else if(Rx_Bot(controller) != none)
			Rx_Bot(controller).OnEMPBleed(true);
		else if(Rx_Vehicle_HarvesterController(controller) != none)
			Rx_Vehicle_HarvesterController(controller).OnEMPBleed(true);
		
		if(bIsAircraft && Driver != none) 
				SetDriving(true); 
	}
	else
	{
		// If EMP was initated by a teammate, make sure the damage isn't blocked by friendlyfire protection. Need proper way to do this :o
		if(role == ROLE_Authority)
		{
			if (EMPInstigator != none && EMPInstigator.GetTeamNum() == GetTeamNum())
				TakeDamage(EMPDamage,None,vect(0,0,0),vect(0,0,0),EMPDmgType,,self);
			else
				`TakeEMPDamage;
			
			//Re-enable driving if we're being driven
			if(Driver != none && !bIsAircraft) 
				SetDriving(true); 
		}

		if(Rx_Controller(controller) != none)
			Rx_Controller(controller).OnEMPBleed();
		else if(Rx_Bot(controller) != none)
			Rx_Bot(controller).OnEMPBleed();
		else if(Rx_Vehicle_HarvesterController(controller) != none)
			Rx_Vehicle_HarvesterController(controller).OnEMPBleed();
	}

	//`logd("Rx_Vehicle EMPBleed"@`showvar(EMPTimeLeft)@`showvar(acceleration)@`showvar(velocity));
}

simulated function ClearEMP()
{
	if(!bEMPd)
		return; 
	EMPTimeLeft = 0; 
	EMPBleed();
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	local int i;
	local Rx_Pawn UTP;
	local byte WasTeam;
	local string DeathVPString; 
	local Attacker PRII;
	local Repairer RPRII;  
	local float TempAssistPoints; 
	local Controller C; 
	
	WasTeam = GetTeamNum();
		
	if(Killer != none)
	{
		DeathVPString = BuildDeathVPString(Killer, DamageType);
		
		//Clear out those who who haven't attacked us in the last 10 seconds
		foreach DamagingParties(PRII)
			{
				if(WorldInfo.TimeSeconds - PRII.LastDamageTime >= 15.0) 
				{
					Damage_Taken-=PRII.DamageDone; //Rid yourselves of irrelevant excessive damage
					DamagingParties.RemoveItem(PRII);
				}
			continue;
			}
		
		//Divi out assist points to those who didn't get the kill and are still in this array 
			foreach DamagingParties(PRII)
			{
			if(PRII.PPRI != none)
				{
				if(PRII.DamageDone >= 100 && PRII.PPRI.Owner != Killer) 
					{
						C=Controller(PRII.PPRI.Owner); 
						//`log(PRII.PPRI.Owner @ EventInstigator @ PRII.DamageDone); 
						
						//Why's Unreal so keen on turning everything into integers... I swear 
						TempAssistPoints = fmin(default.VPReward[VRank], fmax(1,default.VPReward[VRank]*( (1.0*PRII.DamageDone)/(HealthMax*1.0))))  ;//Damage_Taken)); // at least 2 points
						TempAssistPoints=fmax(1.0,TempAssistPoints+BuildAssistVPString(C));
						if(Rx_Controller(C) != none ) 
							Rx_Controller(C).DisseminateVPString("[Vehicle Kill Assist]&" $ TempAssistPoints $ "&"); 
						else
						if(Rx_Bot(C) != none ) 
							Rx_Bot(C).DisseminateVPString("[Vehicle Kill Assist]&" $ TempAssistPoints $ "&"); 
					}
				}
			}
			
		//Divi out assist points to those who were repairing
			
		if(Rx_Vehicle(Killer.Pawn) != none)
		{
			foreach Rx_Vehicle(Killer.Pawn).CurrentHealers(RPRII)
			{
			if(RPRII.PPRI != none)
				{
				if((WorldInfo.TimeSeconds - RPRII.LastRepairTime) <= 5.0) 
					{
						C=Controller(RPRII.PPRI.Owner); 
						//`log(RPRII.PPRI.Owner @ EventInstigator @ RPRII.DamageDone); 
						TempAssistPoints=class'Rx_VeterancyModifiers'.default.Ev_VehicleRepairAssist;
						if(Rx_Controller(C) != none ) Rx_Controller(C).DisseminateVPString("[Vehicle Kill Repair Assist]&" $ TempAssistPoints $ "&"); 
						else
						if(Rx_Bot(C) != none ) Rx_Bot(C).DisseminateVPString("[Vehicle Kill Repair Assist]&" $ TempAssistPoints $ "&"); 
					}
				}
			}
		}
		
		//Play kill taunt for killer if they're on foot
		if(Rx_Pawn(Killer.Pawn) !=none && (DamageType != class'Rx_DmgType_ProxyC4' && DamageType !=class'Rx_DmgType_TimedC4' )) Rx_Pawn(Killer.Pawn).SetTimer(1.5,false,'PlayVehicleKillConfirmTimer');
		else
		if(Rx_Vehicle(Killer.Pawn) != none && Rx_Pawn( Rx_Vehicle(Killer.Pawn).Driver) != none && (DamageType != class'Rx_DmgType_ProxyC4' && DamageType !=class'Rx_DmgType_TimedC4' ))
		{
			Rx_Pawn( Rx_Vehicle(Killer.Pawn).Driver).SetTimer(1.5,false,'PlayVehicleKillConfirmTimer'); 	
		}			
		
		if(Rx_Controller(Killer) != None && GetTeamNum() != Killer.GetTeamNum()) Rx_Controller(Killer).DisseminateVPString(DeathVPString); 
		else
		if(Rx_Bot(Killer) != None && GetTeamNum() != Killer.GetTeamNum()) Rx_Bot(Killer).DisseminateVPString(DeathVPString); 
		else
		if(Rx_Defence_Controller(Killer) != none) //Just give defences VP, nothing else
		{
			Rx_Defence_Controller(Killer).GiveVeterancy(default.VPReward[VRank]);	
		}
	}
	for (i=0;i<Seats.Length;i++)
	{
		if (Seats[i].StoragePawn != None || Seats[i].StoragePawn != None)
		{
			UTP = Rx_Pawn(Seats[i].StoragePawn);
			if(UTP != none && Seats[i].SeatPawn != none)
			{
				if (Rx_Controller(Seats[i].SeatPawn.Controller) != None && Killer != none)
					Rx_Controller(Seats[i].SeatPawn.Controller).ReceiveVehicleDeathMessage(Killer.PlayerReplicationInfo, damageType);
					
					if(Rx_Defence(Self) != none) Rx_PRI(Seats[i].SeatPawn.Controller.PlayerReplicationInfo).SetTargetEliminated(31) ;
					else
					if(Rx_Vehicle_Air(Self) != none) Rx_PRI(Seats[i].SeatPawn.Controller.PlayerReplicationInfo).SetTargetEliminated(41) ;
					else
					Rx_PRI(Seats[i].SeatPawn.Controller.PlayerReplicationInfo).SetTargetEliminated(11) ;
				
				if((class<Rx_DmgType_Nuke>(DamageType) != None || class<Rx_DmgType_IonCannon>(DamageType) != None) && Rx_Game(WorldInfo.Game) != None && Rx_Game(WorldInfo.Game).bPedestalDetonated)
				{
					bStopDeathCamera = true;
				}
				else if(Rx_Bot_Scripted(Seats[i].SeatPawn.Controller) == None || (Rx_Bot_Scripted(Seats[i].SeatPawn.Controller).mySpawner != None && Rx_Bot_Scripted(Seats[i].SeatPawn.Controller).mySpawner.bDriverSurvives))
					Seats[i].SeatPawn.DriverLeave(true);
			}
		}
	}
	
	
	
	if( TeamBought != 255 && !ClassIsChildOf(self.Class, class'Rx_Vehicle_Harvester') )
	{
		Rx_TeamInfo(UTTeamGame(WorldInfo.Game).Teams[TeamBought]).DecreaseVehicleCount();
	}

	if (super.Died(Killer, DamageType, HitLocation))
	{
		NotifyCaptuePointsOfDied(WasTeam);
		return true;
	}
	else
		return false;
}

function NotifyCaptuePointsOfDied(byte WasTeam)
{
	local Rx_CapturePoint CP;
	foreach TouchingActors(class'Rx_CapturePoint', CP)
		CP.NotifyVehicleDied(self, WasTeam);
}

function bool RecommendLongRangedAttack()
{
	/** To keep bots from ramming eachother go long ranged combat if the enemy is within weaponrange */
	if(Controller.Enemy != None 
		&& VSizeSq(Controller.Enemy.location - location) < Square(Weapon.MaxRange())) {
		// && Weapon.IsAimCorrect()) {
		return true;
	} 
	return false;
}

/** is evaluated before RecommendLongRangedAttack */
function bool RecommendCharge(UTBot B, Pawn Enemy)
{
	local float dist;
	local Vehicle veh;
	
	if(Enemy != None && B.GetOrders() == 'Attack' && Rx_BuildingObjective(B.Squad.SquadObjective) != None) {
		if(B.GetTeamNum() == TEAM_GDI) {
			if(Rx_Game(WorldInfo.Game).GetObelisk() != None && FastTrace(Enemy.location, Rx_Bot(B).GetObelisk().location)) {	
				return false;
			}
		} else if(B.GetTeamNum() == TEAM_NOD) {
			if(Rx_Game(WorldInfo.Game).GetAGT() != None && FastTrace(Enemy.location, Rx_Bot(B).GetAGT().location)) {	
				return false;
			}
		}
	}
	
	dist = VSizeSq(location - Enemy.location);
	
	if ( Vehicle(Enemy) == None && dist < Square(weapon.MaxRange())) {
		/** check to see if the Enemy is blocked by a vehicle. If so then dont recommend charge */
		ForEach CollidingActors(class'Vehicle', veh, 500, Enemy.location)
		{
			if(veh != self && class'Rx_Utils'.static.OrientationOfLocAndRotToB(Enemy.location,rotator(location - Enemy.location),veh) > 0.4) {     
				/**
				DrawDebugLine(location,Enemy.location,0,0,255,true);
				DrawDebugSphere(Enemy.location,500,10,0,0,255,true);
				DebugFreezeGame(veh);    
				*/        
				return false;
			}
		}
	}    
	
	if ( Vehicle(Enemy) == None ) {
		/** when close and can turn in place or in front or in back then charge*/ 
		if(dist < Square(500 + FRand()*200) 
			&& (bTurnInPlace || (class'Rx_Utils'.static.OrientationToB(self, Enemy) > 0.7 || class'Rx_Utils'.static.OrientationToB(self, Enemy) < -0.7))) {
			return true;    
		}
	} 
	
	if(Rx_Vehicle_APC_GDI(self) != None || Rx_Vehicle_APC_Nod(self) != None
			|| Rx_Vehicle_Buggy(self) != None || Rx_Vehicle_Humvee(self) != None) {
		if ( Vehicle(Enemy) == None ) {
			return true;
		}
	} else if(Rx_Vehicle_FlameTank(self) != None) {
		if ( Vehicle(Enemy) == None ) {
			return VsizeSq(location - Enemy.location) < Square(800 + FRand()*300);
		}
	} else if(Rx_Vehicle_StealthTank(self) != None) {
		if ( Vehicle(Enemy) == None ) {
			return VsizeSq(location - Enemy.location) < Square(1000 + FRand()*400);
		}
	}
	
	return false; // overridden in some vehicleclasses
}
/** Recommend high priority charge at enemy */
function bool CriticalChargeAttack(UTBot B)
{
	return super.CriticalChargeAttack(B);
}

function bool TooCloseToAttack(Actor Other)
{
	local float dist;
	
	if(Pawn(Other) != None && RecommendCharge(UTBot(Controller),Pawn(Other))) {
		return false;
	}
	if(super.TooCloseToAttack(Other)) {
		return true;    
	}
	if ( Vehicle(Other) == None ) {
		return false;
	}
	dist = VSizeSq(Location - Other.Location);
	return (dist < Square(300.0 + 200*FRand()));
}

function bool ValidEnemyForVehicle(Pawn NewEnemy)
{
	return true;
}

simulated function bool CanEnterVehicle(Pawn P)
{
	local int i;
	local bool bSeatAvailable, bIsHuman;
	local PlayerReplicationInfo SeatPRI;

	if (Rx_Pawn(P) != None && !Rx_Pawn(P).CanEnterVehicles)
		return false;

	// Vehicle is locked after purchase
	if(buyerPri != none)
	{
		if (bReservedToBuyer && P.PlayerReplicationInfo != buyerPri)
			return false;
		else if (P.GetTeamNum() != buyerPri.GetTeamNum())
			return false;
	}

	if ( P.bIsCrouched || (P.DrivenVehicle != None) || (P.Controller == None) || !P.Controller.bIsPlayer
	     || Health <= 0 || bDeleteMe )
	{
		return false;
	}

	// check for available seat, and no enemies in vehicle
	// allow humans to enter if full but with bots (TryToDrive() will kick one out if possible)
	bIsHuman = P.IsHumanControlled();
	bSeatAvailable = false;
	for (i=0;i<Seats.Length;i++)
	{
		if (i == 0 && bDriverLocked && BoundPRI != P.PlayerReplicationInfo && BoundPRI.GetTeamNum() == P.GetTeamNum())
			continue;
		SeatPRI = GetSeatPRI(i);
		if (SeatPRI == None)
		{
			bSeatAvailable = true;
		}
		else if (!WorldInfo.GRI.OnSameTeam(P, SeatPRI))
		{
			return false;
		}
		else if (bIsHuman && SeatPRI.bBot)
		{
			bSeatAvailable = true;
		}
	}

	return bSeatAvailable;
}

simulated function bool InUseableRange(UDKPlayerController PC, float Dist)
{
	return true;
}

simulated function bool IsVehicleStolen()
{
	if(Rx_PRI(PlayerReplicationInfo) == None)
		return false;
	return Rx_PRI(PlayerReplicationInfo).IsVehicleStolen();
}

simulated function bool IsVehicleFromCrate()
{
	if(Rx_PRI(PlayerReplicationInfo) == None)
		return false;
	return Rx_PRI(PlayerReplicationInfo).IsVehicleFromCrate();
}

function VehicleStolen()
{
	local Rx_Controller PC;
	local Rx_Controller Veh_Owner;
	
	if(bHijackBonus)
	{
	Rx_PRI(Seats[0].SeatPawn.PlayerReplicationInfo).AddVP(+10); 
	Rx_PRI(Seats[0].SeatPawn.PlayerReplicationInfo).SetVehicleIsStolen (true);

	if(Rx_Controller(Seats[0].SeatPawn.Controller) != none)
		Rx_Controller(Seats[0].SeatPawn.Controller).DisseminateVPString("[VEHICLE STOLEN]&+" $ class'Rx_VeterancyModifiers'.default.Ev_VehicleSteal $"&");
	else if(Rx_Bot(Seats[0].SeatPawn.Controller) != none)
		Rx_Bot(Seats[0].SeatPawn.Controller).DisseminateVPString("[VEHICLE STOLEN]&+" $ class'Rx_VeterancyModifiers'.default.Ev_VehicleSteal $"&");


	bHijackBonus = false; 
	SetTimer(90,false,'ResetHijackTimer'); 
	}
	
	if (BoundPRI == None) {
		`LogRx("GAME" `s "Stolen;" `s self.Class `s "by" `s `PlayerLog(Seats[0].SeatPawn.PlayerReplicationInfo) );
		foreach WorldInfo.AllControllers(class'Rx_Controller', PC) {
			if (PC.GetTeamNum() == LastTeamToUse)
				PC.ReceiveLocalizedMessage(class'Rx_Message_Vehicle',VM_EnemyStolen_Unbound,,,Class);
			else
				PC.ReceiveLocalizedMessage(class'Rx_Message_Vehicle',VM_EnemyStolen_Enemy,,Seats[0].SeatPawn.PlayerReplicationInfo,Class);
		}
	}
	else {
		`LogRx("GAME" `s "Stolen;" `s self.Class `s "bound to" `s `PlayerLog(BoundPRI) `s "by" `s `PlayerLog(Seats[0].SeatPawn.PlayerReplicationInfo) );
		foreach WorldInfo.AllControllers(class'Rx_Controller', PC) {
			if (PC.GetTeamNum() == BoundPRI.GetTeamNum()) {
				PC.ReceiveLocalizedMessage(class'Rx_Message_Vehicle',VM_EnemyStolen_Team,BoundPRI,,Class);
				
				if (PC.PlayerReplicationInfo == BoundPRI)
					Veh_Owner = PC;
			}
			else
				PC.ReceiveLocalizedMessage(class'Rx_Message_Vehicle',VM_EnemyStolen_Enemy,,Seats[0].SeatPawn.PlayerReplicationInfo,Class);
		}
		Veh_Owner != none ? UnBind(Veh_Owner) : UnBind();
	}
	
	if( TeamBought != 255 && !ClassIsChildOf(self.Class, class'Rx_Vehicle_Harvester') )
	{
		Rx_TeamInfo(UTTeamGame(WorldInfo.Game).Teams[TeamBought]).DecreaseVehicleCount();
		TeamBought = 255; // so the originaly owning team doesent get a vehiclecount decrease again once this veh gets destroyed
	}
	
}



function bool DriverEnter(Pawn P)
{
	local Rx_Controller C;
	local bool bWasBuyer;

	if (!super.DriverEnter(P))
		return false;

	if(bSprintingServer || bSprinting) StopSprinting(); 
	
	if (bEMPd)
		SetDriving(false);
	if(Rx_VehRolloutController(Controller) == none)
	{
		if (buyerPri != None)
		{
			if (Controller.PlayerReplicationInfo == buyerPri)
				bWasBuyer = true;
			buyerPri = none;
			bReservedToBuyer = false;
		}
	}
	if (GetTeamNum() != LastTeamToUse)
	{
		if (LastTeamToUse != 255)
			VehicleStolen();
		LastTeamToUse = GetTeamNum();
	}
	if(Rx_Bot(Controller) != None)
		Rx_Bot(Controller).EnteredVehicle();        
	if (BoundPRI != None)
	{
		if (Seats[0].SeatPawn.PlayerReplicationInfo != BoundPRI)
		{
			foreach WorldInfo.AllControllers(class'Rx_Controller', C)
			{
				if (C.PlayerReplicationInfo == BoundPRI)
				{
					C.ReceiveLocalizedMessage(class'Rx_Message_Vehicle',VM_TeammateEntered,,Seats[0].SeatPawn.PlayerReplicationInfo,Class);
					break;
				}
			}
		}
	}
	else if (Rx_Controller(Controller) != None && bBindable)
		Rx_Controller(Controller).NotifyBindAllowed(self, bWasBuyer);
	
	if(ROLE == ROLE_Authority && Rx_Controller(Controller) != none)
	{
		SetRadarVisibility(Rx_Controller(Controller).GetRadarVisibility()); 
		PromoteUnit(Rx_PRI(Controller.PlayerReplicationInfo).VRank); 
		TempVRank = Rx_PRI(Controller.PlayerReplicationInfo).VRank;
		//Set appropriate overlays
		Rx_Controller(Controller).UpdateModifiedStats(); 
		Rx_PRI(Controller.PlayerReplicationInfo).UpdateVehicleClass(self.class); 
		if(IsTimerActive('ResetTempVRank')) ClearTimer('ResetTempVRank'); 
		if(WorldInfo.NetMode != NM_StandAlone && Rx_Vehicle_Weapon(Weapon) != none) Rx_Vehicle_Weapon(Weapon).ClientGetAmmo(); 
	//`log("I am a" @ Rx_Vehicle_Weapon(Weapon)); 
	
	}		
	else
	if(ROLE == ROLE_Authority && Rx_Bot(Controller) != none) 
	{
		if(Rx_Bot_Scripted(Controller) == None)
		{
			SetRadarVisibility(Rx_Bot(Controller).GetRadarVisibility());  	
			PromoteUnit(Rx_PRI(Controller.PlayerReplicationInfo).VRank); 
			//Update overlays/stats
			Rx_Bot(Controller).UpdateModifiedStats();
			Rx_PRI(Controller.PlayerReplicationInfo).UpdateVehicleClass(self.class); 
			TempVRank =Rx_PRI(Controller.PlayerReplicationInfo).VRank;
		}
		else
		{
			SetRadarVisibility(Rx_Bot(Controller).GetRadarVisibility());  	
			PromoteUnit(Rx_Bot_Scripted(Controller).VRank); 
			//Update overlays/stats
			Rx_Bot(Controller).UpdateModifiedStats();
			TempVRank =Rx_Bot_Scripted(Controller).VRank;

		}

		if(IsTimerActive('ResetTempVRank')) 
			ClearTimer('ResetTempVRank'); 
	}
	else 
	if(ROLE == ROLE_Authority && Rx_Vehicle_HarvesterController(Controller) != none) 
	{
		SetRadarVisibility(Rx_Vehicle_HarvesterController(Controller).GetRadarVisibility());  	
	}

	if (!bHasPlayerEntered && ROLE == ROLE_Authority && Rx_Controller(Controller) != none) // Set ammo to max if just bought, so they don't need to reload because of vet clip size increase.
	{
		bHasPlayerEntered = true;
		if (Rx_Vehicle_Weapon_Reloadable(Weapon) != None)
		{
			Rx_Vehicle_Weapon_Reloadable(Weapon).CurrentAmmoInClip = Rx_Vehicle_Weapon_Reloadable(Weapon).GetMaxAmmoInClip();
		}
		else if (Rx_Vehicle_MultiWeapon(Weapon) != None)
		{
			Rx_Vehicle_MultiWeapon(Weapon).CurrentAmmoInClip[0] = Rx_Vehicle_MultiWeapon(Weapon).GetMaxAmmoInClip();
			Rx_Vehicle_MultiWeapon(Weapon).CurrentAmmoInClip[1] = Rx_Vehicle_MultiWeapon(Weapon).GetMaxAltAmmoInClip();
		}
	}
	
	return true;
}

event bool DriverLeave(bool bForceLeave)
{	
    if (!super.DriverLeave(bForceLeave))
		return false;
	
    // set team to neutral if buyer lockdown is over (buyerePri is set to none then)
	if(buyerPri == none) {
		SetNeutralIfNoOccupants();
	}
	
	StopSprinting();
	SetTimer(5.0, false, 'ResetTempVRank');
	ClearOverlay();	 	

    return true;
}

function ResetTempVRank()
{
	TempVRank = 0; 
}

function PassengerLeave(int SeatIndex)
{
	super.PassengerLeave(SeatIndex);
	SetNeutralIfNoOccupants();
}

function bool SetNeutralIfNoOccupants()
{
	local int i;
	for (i=0; i<Seats.Length; ++i)
	{
		if (Seats[i].SeatPawn.Controller != None)
			return false;
	}
	SetTeamNum(255);
	TimeLastOccupied = WorldInfo.TimeSeconds;
	return true;
}

function bool ToggleDriverLock()
{
	local int Seat;

	if (bDriverLocked)
	{
		bDriverLocked = false;
	}
	else
	{
		bDriverLocked = true;
		if (Seats[0].SeatPawn.Controller != None && Seats[0].SeatPawn.PlayerReplicationInfo != BoundPRI)
		{
			if (PlayerController(Seats[0].SeatPawn.Controller) != None)
				PlayerController(Seats[0].SeatPawn.Controller).ReceiveLocalizedMessage(class'Rx_Message_Vehicle',VM_OwnerLocked,BoundPRI);
			Seat = GetFirstAvailableSeat();
			if (Seat == -1)
				DriverLeave(true);
			else
				ChangeSeat(Seats[0].SeatPawn.Controller, Seat);
		}
	}
	return bDriverLocked;
}

function bool Bind(Rx_Controller binder)
{
	if (!bBindable || BoundPRI != None)
		return false;

	BoundPRI = binder.PlayerReplicationInfo;
	binder.BoundVehicle = self;
	return true;
}

function bool UnBind(optional Rx_Controller unbinder)
{
	if (BoundPRI != None)
	{
		if (unbinder != None && BoundPRI == unbinder.PlayerReplicationInfo)
		{
			unbinder.BoundVehicle = None;
		}
		else
		{
			foreach WorldInfo.AllControllers(class'Rx_Controller', unbinder)
			{
				if (BoundPRI == unbinder.PlayerReplicationInfo)
				{
					unbinder.BoundVehicle = None;
					break;
				}
			}
		}
		BoundPRI = None;
		bDriverLocked = false;
		if (Rx_Controller(Seats[0].SeatPawn.Controller) != None )
		{
			Rx_Controller(Seats[0].SeatPawn.Controller).ReceiveLocalizedMessage(class'Rx_Message_Vehicle',VM_CanBind_PrevUnbound);
		}
		return true;
	}
	return false;
}

function ResetHijackTimer()
{
	bHijackBonus = true; 
}

function bool hasLightArmor()
{
	return bLightArmor;
}

function bool hasAirCraftArmor()
{
	return bIsAircraft;
}

function bool TeamLink(int TeamNum)
{
	return (LinkHealMult > 0 && (Team == TeamNum || Team == 255) && Health > 0);
}

simulated event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local float CurDmg,Scr;
	local int TempDmg;
	local int ScoreDamage;
	local int InstigatorIndex;
	local Attacker TempAttacker;
	
	if(Health <= 0)
		return;

	//`log("took damage from" @ Damage @ EventInstigator@ DamageType); 

	if((WorldInfo.Netmode == NM_DedicatedServer || WorldInfo.Netmode == NM_StandAlone) && AIController(EventInstigator) == None)
	{
		if(Rx_Projectile_Rocket(DamageCauser) != None && Rx_Controller(EventInstigator) != None && GetTeamNum() != EventInstigator.GetTeamNum())
		{ 
			Rx_Controller(EventInstigator).IncReplicatedHitIndicator();
		}
	}

	if (Role == ROLE_Authority)
	{
		if ( (UTPawn(Driver) != None) && UTPawn(Driver).bIsInvulnerable )
			Damage = 0;
	}

	bForceNetUpdate = TRUE; // force quick net update

	if ( DamageType != None )
	{
	//	if(Rx_Controller(EventInstigator) != None) Rx_Controller(EventInstigator).AddHit();
		
		CurDmg = Float(Damage) * DamageType.static.VehicleDamageScalingFor(self) * fmax(GetResistanceModifier(), MaxDR);
		
		Damage *= DamageType.static.VehicleDamageScalingFor(self)*fmax(GetResistanceModifier(), MaxDR);
		
		if(Damage > 0) setTakingDamage();
		
		momentum *= DamageType.default.VehicleMomentumScaling * MomentumMult;
		
	    if(Damage < CurDmg)
	    {
	    	SavedDmg += CurDmg - Float(Damage);	
	    }
	    
	    if (SavedDmg >= 1)
	    {
	    	Damage += SavedDmg; 
	    	TempDmg = SavedDmg;
	    	SavedDmg -= Float(TempDmg);		   
	    }
	    
	    if( Driver != none || Rx_Defence(self) != none )
	    {
		    if (EventInstigator != none 
		    	&& !EventInstigator.IsA('Rx_SentinelController') 
		    	&& Rx_Pri(EventInstigator.PlayerReplicationInfo) != None
		    	&& GetTeamNum() != EventInstigator.GetTeamNum())
		    {
				
				ScoreDamage = Damage;
				/**if(Health < 0)
					ScoreDamage += Health; // so that if he already was nearly dead, we dont get full score
				**/
					
					if(ScoreDamage > float(Health)) ScoreDamage = float(Health); //Don't give ridiculously high points for high damage
					
					if(ScoreDamage < 0)
					ScoreDamage = 0;
				
				//`log(ScoreDamage);
				
				Scr = ScoreDamage * DamagePointsScale;						
				//`log(Scr);
				LegitamateDamage+=Damage; //This was real damage
				Rx_PRI(EventInstigator.PlayerReplicationInfo).AddScoreToPlayerAndTeam(Scr);	   
				
				/*Now track who's doing the damage if it's legit*/
				InstigatorIndex=DamagingParties.Find('PPRI',EventInstigator.PlayerReplicationInfo);
			
				if(InstigatorIndex == -1)  //New damager
				{
					TempAttacker.PPRI=EventInstigator.PlayerReplicationInfo;
					
					TempAttacker.DamageDone = Min(Damage,Health);
					
					Rx_PRI(TempAttacker.PPRI).AddVehicleDamagePoints(Min(Damage,Health));
					
					TempAttacker.LastDamageTime = WorldInfo.TimeSeconds; 
					
					Damage_Taken+=TempAttacker.DamageDone; //Add this damage to the total damage taken.
					
					DamagingParties.AddItem(TempAttacker) ;
					
					
				
				}
				else
				{
					if(Damage <= float(Health))
					{
						DamagingParties[InstigatorIndex].LastDamageTime = WorldInfo.TimeSeconds; 
						DamagingParties[InstigatorIndex].DamageDone+=Damage;
						Rx_PRI(DamagingParties[InstigatorIndex].PPRI).AddVehicleDamagePoints(Damage);
						Damage_Taken+=Damage; //Add this damage to the total damage taken.
					}
					else
					{
						DamagingParties[InstigatorIndex].LastDamageTime = WorldInfo.TimeSeconds;	
						DamagingParties[InstigatorIndex].DamageDone+=Health;
						Rx_PRI(DamagingParties[InstigatorIndex].PPRI).AddVehicleDamagePoints(Health);
						Damage_Taken+=Health; //Add this damage to the total damage taken.
					}
				}
				
		    }
	    }	    		
	}	
	
	super(Pawn).TakeDamage(Damage,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	
	if (Role == ROLE_Authority)
	{
		CheckDamageSmoke();
	}	
}

function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
	local int RealAmount;
	local float Scr;
	local int InstigatorIndex;
	local Repairer TempHealer; 

	if (Health <= 0 || Amount <= 0 || Healer == None)
		return false;

	Amount*=(1.0/GetResistanceModifier()); 
	
	RealAmount = Min(Amount, HealthMax - Health);

	if (DamageType == class'Rx_DmgType_RepairFacility')
	{
		return Super.HealDamage(RealAmount, Healer, DamageType);
	}

	if (RealAmount > 0 && LegitamateDamage > 0 && (Driver != none || Rx_Defence(self) !=none ))
	{
		if (Health >= HealthMax && SavedDmg > 0.0f)
		{
			
			SavedDmg = FMax(0.0f, SavedDmg - Amount);
			Scr = SavedDmg * HealPointsScale;
			Rx_PRI(Healer.PlayerReplicationInfo).AddScoreToPlayerAndTeam(Scr);
		}
		LegitamateDamage=fMax(0,LegitamateDamage-RealAmount); 
		Scr = RealAmount * HealPointsScale;
		Rx_PRI(Healer.PlayerReplicationInfo).AddScoreToPlayerAndTeam(Scr);
		Rx_PRI(Healer.PlayerReplicationInfo).AddRepairPoints_V(Amount); //Add to amount of Vehicle repair points this
		/*Now track who's doing the healing if it's legit*/
				InstigatorIndex=CurrentHealers.Find('PPRI',Healer.PlayerReplicationInfo);
			
				if(InstigatorIndex == -1)  //New damager
				{
				TempHealer.PPRI=Healer.PlayerReplicationInfo;
				
				TempHealer.LastRepairTime = WorldInfo.TimeSeconds;
				
				CurrentHealers.AddItem(TempHealer) ;
				
				}
				else
				{
					CurrentHealers[InstigatorIndex].LastRepairTime = WorldInfo.TimeSeconds;
				}
		
		
	}

   	return Super.HealDamage(RealAmount, Healer, DamageType);
}

/**
 *  AI code
 */
function bool Occupied()
{
	return Controller != None;
}

function bool OpenPositionFor(Pawn P)
{
	if(Rx_Bot(P.Controller) != None) 
	{
		return Controller == None;    
	}
	else
	{
		return super.OpenPositionFor(P);
	}
}

function moveVehicleAwayFromSpawnpoint()
{
	local vector tv;
	local UTPawn rolloutDriver;
	local Rx_VehRolloutController rolloutAI;	

	if(driver != none)
		return;
	
	tv = Location;
	tv.z += 60;
	tv.x += 50;

	rolloutDriver = Spawn(class'UTPawn',,,tv,,,true);

	rolloutAI = Spawn(class'Rx_VehRolloutController',,,tv,,,true);
	rolloutAI.bIsPlayer = false;
	rolloutAI.PlayerReplicationInfo = none;
	rolloutAI.SetTeam(Team);

	rolloutAI.Possess(rolloutDriver,true);
	DriverEnter(rolloutDriver);
	rolloutAI.GotoState('RolloutMove');
}

function moveVehicleAwayFromSpawnpointAir()
{
	local vector tv;
	local UTPawn rolloutDriver;
	local Rx_VehRolloutController rolloutAI;	

	if(driver != none)
		return;
	
	tv = Location;
	tv.z += 60;
	tv.x += 50;

	rolloutDriver = Spawn(class'UTPawn',,,tv,,,true);

	rolloutAI = Spawn(class'Rx_VehRolloutControllerAir',,,tv,,,true);
	rolloutAI.bIsPlayer = false;
	rolloutAI.PlayerReplicationInfo = none;
	rolloutAI.SetTeam(Team);

	rolloutAI.Possess(rolloutDriver,true);
	DriverEnter(rolloutDriver);
	rolloutAI.GotoState('RolloutMove');
}

function openVehToAllPlayersAfterBuy() 
{
	if (buyerPri != None)
	{
		if(Rx_Bot(buyerPri.Owner) != None)
		{
			Rx_Bot(buyerPri.Owner).SetBaughtVehicle(-1);	
		}	
		SetTeamNum(255);
		buyerPri = none;
		bReservedToBuyer = false;
	}
}

simulated event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent,
								   const out CollisionImpactData Collision, int ContactIndex ) {
	local float HisOrientationToMe;
	local float MyOrientationToHim;
	
	if(OtherComponent == None || VSizeSq(Velocity - OtherComponent.Owner.Velocity) > 62500) {
		super.RigidBodyCollision(HitComponent,OtherComponent,Collision,ContactIndex);
	}
	
	//if(shouldUmkurven(OtherVeh))w
	//  einen NavPoint aus Pawn.Anchor.PathList auswählen
	
	//loginternal(VSize(Velocity - OtherComponent.Owner.Velocity)); 
	//loginternal(self@"RigidBodyCollision");
	if(bStationary == false && Rx_Vehicle_Harvester(HitComponent.owner) == None && UTVehicle(HitComponent.owner) != None 
			&& OtherComponent != None 
			&& UTVehicle(OtherComponent.owner) != None 
			&& (Rx_Bot(Controller) != None || (Rx_VehRolloutController(Controller) != None && AIController(UTVehicle(OtherComponent.owner).Controller) != None)) )
	{
		HisOrientationToMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(Location,Rotation,OtherComponent.owner.location);
		MyOrientationToHim = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(OtherComponent.owner.location,OtherComponent.owner.rotation,location);
		if(HisOrientationToMe > 0.2)
		{ // meaning hes in front of me
			if(HisOrientationToMe > MyOrientationToHim)
			{ // meaning hes more in front of me then im in front of him -> so i wait
				if(UTBot(Controller) != None)
				{
					UTBot(Controller).MoveTarget = None;
					Rx_Bot(Controller).setShouldWait(UTVehicle(Controller.Pawn));
				} 
				else
				{
					Rx_VehRolloutController(Controller).setShouldWait(UTVehicle(Controller.Pawn));
				}
				UTVehicle(Controller.Pawn).bStationary = true;	
			}	
		}
	}
}

function bool NeedsHealing() 
{
	if(Health <= 0)
	{
		return false;
	}
	return HealthMax > Health;
}

function HandleEnteringFlag(UTPlayerReplicationInfo EnteringPRI);

function bool IsReversedSteeringInverted()
{
	return bReverseSteeringInverted;
}

function SetReversedSteeringInverted(bool NewVal)
{
	bReverseSteeringInverted=NewVal;
	ServerSetReversedSteeringInverted(NewVal);
}

reliable server function ServerSetReversedSteeringInverted(bool NewVal)
{
	bReverseSteeringInverted=NewVal;
}

simulated function SwitchWeapon(byte NewGroup)
{
	if(UTPlayerController(Controller) == None || (!Rx_PlayerInput(UTPlayerController(Controller).PlayerInput).bRadio1Pressed 
			&& !Rx_PlayerInput(UTPlayerController(Controller).PlayerInput).bRadio0Pressed))
	{	
		super.SwitchWeapon(NewGroup);
	}
}

simulated event SuspensionHeavyShift(float Delta)
{
	if(Delta>0)
	{
		PlaySound(SuspensionShiftSound);
	}
}

simulated function ProcessViewRotation( float DeltaTime, out rotator out_ViewRotation, out Rotator out_DeltaRot )
{
	super.ProcessViewRotation(DeltaTime,out_ViewRotation,out_DeltaRot);
	if(Weapon != None) {
		Rx_Vehicle_Weapon(Weapon).ProcessViewRotation(DeltaTime, out_ViewRotation, out_DeltaRot);
	}
	out_ViewRotation += out_DeltaRot;
}

simulated function VehicleCalcCamera(float DeltaTime, int SeatIndex, out vector out_CamLoc, out rotator out_CamRot, out vector CamStart, optional bool bPivotOnly)
{
	
	if (fpCamera && SeatIndex == 0)
	{
		out_CamLoc = GetCameraStart(SeatIndex);
		out_CamRot = Seats[SeatIndex].SeatPawn.GetViewRotation();
		CamStart = out_CamLoc;
		CalcViewLocation = out_CamLoc;

	    CalcPlayerVehicleCamTransition(out_CamLoc, DeltaTime);	
		return;
	}

	super.VehicleCalcCamera(DeltaTime,SeatIndex,out_CamLoc,out_CamRot,CamStart,bPivotOnly);

	CalcPlayerVehicleCamTransition(out_CamLoc, DeltaTime);

}

simulated function CalcPlayerVehicleCamTransition(out vector out_CamLoc, float DeltaTime)
{
	if(WorldInfo.NetMode != NM_DedicatedServer)
	{
		if(VehiclePawnTransitionStartLoc != vect(0,0,0) && BlendPct < 1.0f)
		{
			BlendPct += DeltaTime/0.5f;
			out_CamLoc = VLerp(VehiclePawnTransitionStartLoc,  out_CamLoc, BlendPct);
		} else 
		{
			VehiclePawnTransitionStartLoc = vect(0,0,0);
		}
		CalcViewLocation = out_CamLoc;
	}
}

/**RxIfc_SeekableTarget******/

function float GetAimAheadModifier()
{
	return SeekAimAheadModifier;
}

function float GetAccelrateModifier()
{
	return SeekAccelrateModifier;
}

simulated function vector GetAdjustedLocation()
{
	return location; 
}

/********************/

simulated function StartFire(byte FireModeNum)
{
 	//local vector FireStartLoc;
 	local Rx_Vehicle veh;
 	
 	if(FireModeNum == 1 && bSecondaryFireTogglesFirstPerson)
 	{
 		if(WorldInfo.NetMode != NM_DedicatedServer && Rx_Controller(controller) != None)
 		{
 			Rx_Controller(controller).ToggleCam();
 		}
 		return;
 	}
/////////////////////////EDITTED to include support for Multi-weapons and their Secondary reload variables that didn't originally exist. 8AUG2015
 	if(Rx_Vehicle_Weapon(weapon) != None) //Separated for Multi_weapons. If we make more of any kind of weapon, add it here as well.
	{
		//Reloadable weapons (Most of them)
		 /**	if(Rx_Vehicle_Weapon_Reloadable(weapon) != none && (Rx_Vehicle_Weapon_Reloadable(weapon).CurrentlyReloading && !Rx_Vehicle_Weapon_Reloadable(weapon).bReloadAfterEveryShot)
			) 
			
			return; 
			
			//if(Rx_Vehicle_Multiweapon(weapon) != none && !Rx_Vehicle_Multiweapon(weapon).bReadytoFire()) return;
			
			switch(FireModeNum)
			{
				case 0: /Primary Weapon trying to fire
				if(Rx_Vehicle_Multiweapon(weapon) != none && !Rx_Vehicle_Multiweapon(weapon).bReadytoFire()) return;
				break;
				
				case 1:
				if(Rx_Vehicle_Multiweapon(weapon) != none && Rx_Vehicle_Multiweapon(weapon).SecondaryReloading) return;
				break;
			}	*/		
		
 	}		
 	/**if(Rx_Vehicle_Weapon_Reloadable(weapon) != None && Rx_Vehicle_Weapon_Reloadable(weapon).bCheckIfBarrelInsideWorldGeomBeforeFiring)
 	{
	 	FireStartLoc = GetPhysicalFireStartLoc(UTVehicleWeapon(weapon));
	 	if(!FastTrace(FireStartLoc,location))
		{
			UTVehicleWeapon(weapon).ClearPendingFire(UTVehicleWeapon(weapon).CurrentFireMode);
			return;
		}
	} 
	*/
 	if(Rx_Vehicle_Weapon_Reloadable(weapon) != None && Rx_Vehicle_Weapon_Reloadable(weapon).bCheckIfFireStartLocInsideOtherVehicle)
 	{	 	
 	    foreach CollidingActors(class'Rx_Vehicle', veh, 3, location, true)
   		{
			if(veh == self)
				continue;	
			UTVehicleWeapon(weapon).ClearPendingFire(UTVehicleWeapon(weapon).CurrentFireMode);
			return;
		}
	} 	

	super.StartFire(FireModeNum);
}

simulated function float CalcRadiusDmgDistance(vector HurtOrigin)
{
	local vector HitLocation;
	local TraceHitInfo HitInfo;

	HitLocation = Location;
	CheckHitInfo( HitInfo, Mesh, Location - HurtOrigin, HitLocation );
	return VSize(HitLocation - HurtOrigin);
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
	local vector HitLocation, Dir;
	local float DamageScale;
	local TraceHitInfo HitInfo;

	// calculate actual hit position on mesh, rather than approximating with cylinder
	HitLocation = Location;
	Dir = Location - HurtOrigin;

	CheckHitInfo( HitInfo, Mesh, Dir, HitLocation );

	if ( bFullDamage )
	{
		DamageScale = 1.f;
	}
	else if ( GivenDistance > DamageRadius )
		return;
	else
	{
		DamageScale = FMax(0,1 - GivenDistance/DamageRadius);
		DamageScale = DamageScale ** DamageFalloffExponent;
	}

	RadialImpulseScaling = DamageScale;

	TakeDamage
	(
		BaseDamage * DamageScale,
		InstigatedBy,
		HitLocation,
		(DamageScale * Momentum * Normal(dir)),
		DamageType,
		HitInfo,
		DamageCauser
	);
	RadialImpulseScaling = 1.0;
	/* This ends up calling TakeRadiusDamage, and thus uses server-side distance and will be different. Plus we don't do any damage to drivers anyway right?
	if (Health > 0)
	{
		DriverRadiusDamage(BaseDamage, DamageRadius, InstigatedBy, DamageType, Momentum, HurtOrigin, DamageCauser);
	}*/
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
	local Weapon ProjectileWeaponOwner; 
	
	if(InstigatedBy != None && InstigatedBy.GetTeamNum() == GetTeamNum())
	{
		return;
	}
	
	if(Rx_Projectile(DamageCauser) != None && !Rx_Projectile(DamageCauser).isAirstrikeProjectile())
	{
		//Get what actually shot us 
		if(Rx_Projectile(DamageCauser) != none) 
			ProjectileWeaponOwner = Rx_Projectile(DamageCauser).GetWeaponInstigator();
		else
			ProjectileWeaponOwner = InstigatedBy.Pawn.Weapon; //Likely not a projectile then, so just look for the weapon calling this 
		
		if(WorldInfo.NetMode != NM_DedicatedServer && InstigatedBy != None 
				&& InstigatedBy.Pawn != None
				&& (Rx_Weapon(ProjectileWeaponOwner) != None || Rx_Vehicle_Weapon(ProjectileWeaponOwner) != None)) 
		{	
			if(Health > 0 && self.GetTeamNum() != InstigatedBy.GetTeamNum() && UTPlayerController(InstigatedBy) != None)
			{
				Rx_Hud(UTPlayerController(InstigatedBy).myHud).ShowHitMarker();
			}

			if (Rx_Weapon_VoltAutoRifle(ProjectileWeaponOwner) != None)
			{
				Rx_Weapon_VoltAutoRifle(ProjectileWeaponOwner).ServerALRadiusDamageCharged(self,HurtOrigin,bFullDamage,class'Rx_Projectile_VoltBolt'.static.GetChargePercentFromDamage(BaseDamage));
			}
			else if(Rx_Weapon(ProjectileWeaponOwner) != None)
			{
				Rx_Weapon(ProjectileWeaponOwner).ServerALRadiusDamage(self,HurtOrigin,bFullDamage);
			} 
			else
			{
				Rx_Vehicle_Weapon(ProjectileWeaponOwner).ServerALRadiusDamage(self,HurtOrigin,bFullDamage, Rx_Projectile(DamageCauser).FMTag);
			}	
		}
		else if(ROLE == ROLE_Authority && AIController(InstigatedBy) != None)
		{
			super.TakeRadiusDamage(InstigatedBy,BaseDamage,DamageRadius,DamageType,Momentum,HurtOrigin,bFullDamage,DamageCauser,DamageFalloffExponent);
		}
	}
	else
	{
		super.TakeRadiusDamage(InstigatedBy,BaseDamage,DamageRadius,DamageType,Momentum,HurtOrigin,bFullDamage,DamageCauser,DamageFalloffExponent);
	}
}

simulated function int GetSeatIndexBasedOnWeapon(Weapon InWeapon)
{
	local int i;
	for (i=0; i<Seats.Length; ++i)
		if (InWeapon.Class == Seats[i].GunClass)
			return i;
	return 0;
}

simulated function class<Rx_Vehicle_Weapon> GetWeaponClassOfSeat(int SeatIndex)
{
	return class<Rx_Vehicle_Weapon>(Seats[SeatIndex].GunClass);
}

simulated function VehicleWeaponImpactEffects(vector HitLocation, int SeatIndex)
{
	super.VehicleWeaponImpactEffects(HitLocation, SeatIndex);

	PlayBeamParticleEffect(HitLocation, SeatIndex);
}

simulated function PlayBeamParticleEffect(vector HitLocation, int SeatIndex)
{
	local ParticleSystemComponent E;
	local ParticleSystem PS;
	local class<Rx_Vehicle_Weapon> RxVW;  

	RxVW = GetWeaponClassOfSeat(SeatIndex);
	
	if(VRank < 3 || RxVW.default.BeamTemplates_Heroic[0] == none) PS = RxVW.default.BeamTemplates[SeatFiringMode(SeatIndex,,true)];
	else
	PS = GetWeaponClassOfSeat(SeatIndex).default.BeamTemplates_Heroic[SeatFiringMode(SeatIndex,,true)];
	
	
	
	if (PS != None)
	{
		E = WorldInfo.MyEmitterPool.SpawnEmitter(PS, GetEffectLocation(SeatIndex));
		E.SetVectorParameter('BeamEnd', HitLocation);
	}
}

simulated function ClientsideVehicleWeaponImpactEffects(vector HitLocation, int SeatIndex)
{
	local vector NewHitLoc, HitNormal, LightLoc;
	local Actor HitActor;
	local TraceHitInfo HitInfo;
	local MaterialImpactEffect ImpactEffect;
	local MaterialInterface MI;
	local MaterialInstanceTimeVarying MITV_Decal;
	local int DecalMaterialsLength;
	local Vehicle V;
	local Pawn EffectInstigator;
	local UTPlayerController PC;

	HitNormal = Normal(Location - HitLocation);
	HitActor = FindWeaponHitNormal(NewHitLoc, HitNormal, (HitLocation - (HitNormal * 32)), HitLocation + (HitNormal * 32),HitInfo);

	if ( (HitActor == None) && (VSizeSq(Location - HitLocation) > 1000000000) )
	{
		return;
	}

	if (Pawn(HitActor) != None)
	{
		CheckHitInfo(HitInfo, Pawn(HitActor).Mesh, -HitNormal, NewHitLoc);
	}
	// figure out the impact effect to use
	ImpactEffect = class<UTVehicleWeapon>(Seats[SeatIndex].GunClass).static.GetImpactEffect(HitActor, HitInfo.PhysMaterial, SeatFiringMode(SeatIndex,, true));
	if (ImpactEffect.Sound != None)
	{
		// if hit a vehicle controlled by the local player, always play it full volume
		V = Vehicle(HitActor);
		if (V != None && V.IsLocallyControlled() && V.IsHumanControlled())
		{
			PlayerController(V.Controller).ClientPlaySound(ImpactEffect.Sound);
		}
		else
		{
			if ( (class<UTVehicleWeapon>(Seats[SeatIndex].GunClass).default.BulletWhip != None) && (WorldInfo.GRI != None) )
			{
				ForEach LocalPlayerControllers(class'UTPlayerController', PC)
				{
					if (!WorldInfo.GRI.OnSameTeam(self, PC))
					{
						PC.CheckBulletWhip(class<UTVehicleWeapon>(Seats[SeatIndex].GunClass).default.BulletWhip, Location, Normal(HitLocation - Location), HitLocation);
					}
				}
			}
			if (Speaker == None)
				Speaker = Spawn(class'Rx_Speaker', self);
			Speaker.PlaySoundAt(ImpactEffect.Sound, HitLocation);
		}
	}

	EffectInstigator = Seats[SeatIndex].SeatPawn;
	if (EffectInstigator == None)
	{
		EffectInstigator = self;
	}
	if (EffectInstigator.EffectIsRelevant(HitLocation, false, MaxImpactEffectDistance))
	{
		// Pawns handle their own hit effects
		if (HitActor != None && (Pawn(HitActor) == None || Vehicle(HitActor) != None))
		{
			// this code is mostly duplicated in:  UTGib, UTProjectile, UTVehicle, UTWeaponAttachment be aware when updating
			if ( !WorldInfo.bDropDetail && (Pawn(HitActor) == None) )
			{
				// if we have a decal to spawn on impact
				DecalMaterialsLength = ImpactEffect.DecalMaterials.length;
				if( DecalMaterialsLength > 0 )
				{
					MI = ImpactEffect.DecalMaterials[Rand(DecalMaterialsLength)];
					if( MI != None )
					{
						if( MaterialInstanceTimeVarying(MI) != none )
						{
							MITV_Decal = new(self) class'MaterialInstanceTimeVarying';
							MITV_Decal.SetParent( MI );

							WorldInfo.MyDecalManager.SpawnDecal( MITV_Decal, HitLocation, rotator(-HitNormal), ImpactEffect.DecalWidth,
								ImpactEffect.DecalHeight, 10.0, false,, HitInfo.HitComponent, true, false, HitInfo.BoneName, HitInfo.Item, HitInfo.LevelIndex );
							//here we need to see if we are an MITV and then set the burn out times to occur
							MITV_Decal.SetScalarStartTime( ImpactEffect.DecalDissolveParamName, ImpactEffect.DurationOfDecal );
						}
						else
						{
							WorldInfo.MyDecalManager.SpawnDecal( MI, HitLocation, rotator(-HitNormal), ImpactEffect.DecalWidth,
								ImpactEffect.DecalHeight, 10.0, false,, HitInfo.HitComponent, true, false, HitInfo.BoneName, HitInfo.Item, HitInfo.LevelIndex );
						}
					}
				}
			}

			if (ImpactEffect.ParticleTemplate != None)
			{
				SpawnImpactEmitter(HitLocation, HitNormal, ImpactEffect, SeatIndex );
				if ( (Seats[SeatIndex].ImpactFlashLightClass != None) && (WorldInfo.GetDetailMode() != DM_Low) && !class'Engine'.static.IsSplitScreen()
					&& (!WorldInfo.bDropDetail || (Seats[SeatIndex].SeatPawn != None && PlayerController(Seats[SeatIndex].SeatPawn.Controller) != None && Seats[SeatIndex].SeatPawn.IsLocallyControlled())) )
				{
					LightLoc = HitLocation + ((0.5 * Seats[SeatIndex].ImpactFlashLightClass.default.TimeShift[0].Radius * vect(1,0,0)) >> rotator(HitNormal));
					UDKEmitterPool(WorldInfo.MyEmitterPool).SpawnExplosionLight(Seats[SeatIndex].ImpactFlashLightClass, LightLoc);
				}
			}
		}
	}

	PlayBeamParticleEffect(HitLocation, SeatIndex);
}

event RanInto(Actor Other)
{
	if (Rx_Pawn(Other) != None && Rx_Pawn(Other).GetTeamNum() == GetTeamNum())
		Rx_Pawn(Other).LastRanInto = WorldInfo.TimeSeconds;
	else
		super.RanInto(Other);
}

simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
{
	VehicleWeaponFired(bViaReplication, HitLocation, GetSeatIndexBasedOnWeapon(InWeapon));
}

simulated function VehicleWeaponFired( bool bViaReplication, vector HitLocation, int SeatIndex )
{
	// Trigger any vehicle Firing Effects
	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		// Instant Fire plays the fire effects on the client immediately, so don't play them again when the server tells the client that it has fired (as they've already been played).
		if (bViaReplication && Seats[SeatIndex].SeatPawn != None && Seats[SeatIndex].SeatPawn.Controller == GetALocalPlayerController())
			return;

		VehicleWeaponFireEffects(HitLocation, SeatIndex);

		if (!bViaReplication && Seats[SeatIndex].SeatPawn != None && GetSeatIndexForController(GetALocalPlayerController()) == SeatIndex)
			ClientsideVehicleWeaponImpactEffects(HitLocation, SeatIndex);
		else
			VehicleWeaponImpactEffects(HitLocation, SeatIndex);

		if (SeatIndex == 0)
		{
			Seats[SeatIndex].Gun = UTVehicleWeapon(Weapon);
		}
		if (Seats[SeatIndex].Gun != None)
		{
			UTVehicleWeapon(Seats[SeatIndex].Gun).ShakeView();
		}
		if ( EffectIsRelevant(Location,false,MaxFireEffectDistance) )
		{
			CauseMuzzleFlashLight(SeatIndex);
		}
	}
}

simulated function CheckWheelEmitters()
{
	local vector loc, norm, end;
	local TraceHitInfo hitInfo;
	local Actor traceHit;
	local UTPhysicalMaterialProperty PhysicalProperty;
	local int i;
	
	if(VSizeSq(Velocity) > 14400 && !IsInState('Stealthed') && !IsInState('BeenShot'))
    {
		
		end = Location;
		end.Z = Location.Z -128;
		traceHit = trace(loc, norm, end, Location, false,, hitInfo);
	
		if (traceHit == none)
		{
			return;
		}
		if( HitInfo.HitComponent != none && Landscape(HitInfo.HitComponent.Owner) != none 
				&& Landscape(HitInfo.HitComponent.Owner).LandscapeMaterial != None
				&& Landscape(HitInfo.HitComponent.Owner).LandscapeMaterial.GetPhysicalMaterial() != None)
			PhysicalProperty = UTPhysicalMaterialProperty(Landscape(HitInfo.HitComponent.Owner).LandscapeMaterial.GetPhysicalMaterial().GetPhysicalMaterialProperty(class'UTPhysicalMaterialProperty'));
	//		`log( HitInfo.Material $ ' ' $ HitInfo.PhysMaterial $ ' ' $ Landscape(HitInfo.HitComponent.Owner).LandscapeMaterial.GetPhysicalMaterial() );
		else if(HitInfo.PhysMaterial != None)
			PhysicalProperty = UTPhysicalMaterialProperty(HitInfo.PhysMaterial.GetPhysicalMaterialProperty(class'UTPhysicalMaterialProperty'));

	}
	else
	{
		PhysicalProperty = OldPhysicalProperty;
	}
	
     // check the material type and change wheel particles
	if( PhysicalProperty != none )
	{
		OldPhysicalProperty = PhysicalProperty;
		for(i = 0; i < WheelParticleEffects.Length; i++ )
		{
			 if( PhysicalProperty.MaterialType == WheelParticleEffects[i].MaterialType )
			{
				 WheelParticleEffect = WheelParticleEffects[i].ParticleTemplate;
				 break;   
			}
		}
	}
	else
		WheelParticleEffect = DefaultWheelPSCTemplate; // prolly means it should be an empty emitter, mb a tiny amount of shed dust to taste
		
	if( WheelParticleEffect != none && WheelParticleEffect != OldWheelParticleEffect )
	{
		for( i=0; i<WheelPSCs.Length; i++ )
		{
			WheelPSCs[i].SetTemplate(WheelParticleEffect);
		}
		OldWheelParticleEffect = WheelParticleEffect;
	}
	
	for( i=0; i<WheelPSCs.Length; i++ )
	{
		if(IsInState('Stealthed') || IsInState('BeenShot'))
			WheelPSCs[i].SetFloatParameter('Wheelslip', 1.0);
		else
			WheelPSCs[i].SetFloatParameter('Wheelslip', 1.0 + 9.0*FClamp(VSizeSq(Velocity)/MaxSpeed, 0.0, 1.0)); // input range is 1-10
	}
}

simulated function rotator GetWeaponAimWithOptionalPredefinedAimPoint(UTVehicleWeapon VWeapon, vector AimPoint)
{
	local vector SocketLocation, CameraLocation, RealAimPoint, DesiredAimPoint, HitLocation, HitRotation, DirA, DirB;
	local rotator CameraRotation, SocketRotation, ControllerAim, AdjustedAim;
	local float DiffAngle, MaxAdjust;
	local Controller C;
	local PlayerController PC;
	local Quat Q;

	if ( VWeapon != none )
	{
		C = Seats[VWeapon.SeatIndex].SeatPawn.Controller;

		PC = PlayerController(C);
		if(AimPoint != vect(0,0,0))
			DesiredAimPoint = AimPoint;
		else 
		{	
			if (PC != None)
			{
				PC.GetPlayerViewPoint(CameraLocation, CameraRotation);
				DesiredAimPoint = CameraLocation + Vector(CameraRotation) * VWeapon.GetTraceRange();
				if (Trace(HitLocation, HitRotation, DesiredAimPoint, CameraLocation, true, vect(0,0,0),,TRACEFLAG_Bullet) != None)
				{
					DesiredAimPoint = HitLocation;
				}
			}
			else if (C != None)
			{
				DesiredAimPoint = C.GetFocalPoint();
			}
		}

		if ( Seats[VWeapon.SeatIndex].GunSocket.Length>0 )
		{
			GetBarrelLocationAndRotation(VWeapon.SeatIndex, SocketLocation, SocketRotation);
			if(VWeapon.bIgnoreSocketPitchRotation || ((DesiredAimPoint.Z - Location.Z)<0 && VWeapon.bIgnoreDownwardPitch))
			{
				SocketRotation.Pitch = Rotator(DesiredAimPoint - Location).Pitch;
			}
		}
		else
		{
			SocketLocation = Location;
			SocketRotation = Rotator(DesiredAimPoint - Location);
		}

		RealAimPoint = SocketLocation + Vector(SocketRotation) * VWeapon.GetTraceRange();
		DirA = normal(DesiredAimPoint - SocketLocation);
		DirB = normal(RealAimPoint - SocketLocation);
		DiffAngle = ( DirA dot DirB );
		MaxAdjust = VWeapon.GetMaxFinalAimAdjustment();
		if ( DiffAngle >= MaxAdjust )
		{
			// bit of a hack here to make bot aiming and single player autoaim work
			ControllerAim = (C != None) ? C.Rotation : Rotation;
			AdjustedAim = VWeapon.GetAdjustedAim(SocketLocation);
			if (AdjustedAim == VWeapon.Instigator.GetBaseAimRotation() || AdjustedAim == ControllerAim)
			{
				// no adjustment				
				return rotator(DesiredAimPoint - SocketLocation);
			}
			else
			{
				// FIXME: AdjustedAim.Pitch = Instigator.LimitPitch(AdjustedAim.Pitch);
				return AdjustedAim;
			}
		}
		else
		{
			Q = QuatFromAxisAndAngle(Normal(DirB cross DirA), ACos(MaxAdjust));
			return Rotator( QuatRotateVector(Q,DirB));
		}
	}
	else
	{
		return Rotation;
	}
}
simulated function rotator GetWeaponAim(UTVehicleWeapon VWeapon)
{
	return GetWeaponAimWithOptionalPredefinedAimPoint(VWeapon, vect(0,0,0));
}

function vector GetWeaponAimLocation(vector AimLoc)
{
	local vector HitNormal, HitLocation, StartTrace, EndTrace;
	local rotator AdjustedAim;
	local Actor TraceActor;
	
	AdjustedAim = GetWeaponAimWithOptionalPredefinedAimPoint(UTVehicleWeapon(weapon), AimLoc);	
	StartTrace = GetPhysicalFireStartLoc(UTVehicleWeapon(weapon));
	EndTrace = StartTrace + Vector(AdjustedAim) * 2000;

	TraceActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true, vect(0,0,0),, TRACEFLAG_Bullet);
	if(TraceActor != None)
	{
		return HitLocation;
	} else
	{
		return EndTrace;
	}
}

function ToggleTurretRotation()
{
}

function PancakeOther(Pawn Other)
{
	if(Rx_Pawn(Other) == None)
		return;

	if(GetTeamNum() != 255 && GetTeamNum() != Other.GetTeamNum())
	{
		Other.TakeDamage(10000, GetCollisionDamageInstigator(), Other.Location, Velocity * Other.Mass, CrushedDamageType);
	}
}

simulated function string GetTargetedDescription(PlayerController PlayerPerspective)
{
	//Above all else 
	if(Rx_PRI(PlayerReplicationInfo) != none && Rx_PRI(PlayerReplicationInfo).bGetIsCommander()) return "[COMMANDER]";
	
	if (BoundPRI != None) 		
	{
		if (PlayerPerspective.PlayerReplicationInfo == BoundPRI)
		{
			if (bDriverLocked)
				return "Your Vehicle [Locked]";
			else
				return "Your Vehicle";
		}
		else if (BoundPRI.GetTeamNum() == PlayerPerspective.GetTeamNum())
			return BoundPRI.PlayerName$"'s Vehicle";

		else if (bDriverLocked && BoundPRI.GetTeamNum() == PlayerPerspective.GetTeamNum())
			return "Locked by"@BoundPRI.PlayerName;
	}
	else if (buyerPri != None)
	{
		if (PlayerPerspective.PlayerReplicationInfo == buyerPri)
		{
			if (bReservedToBuyer)
				return "Your Purchased Vehicle";
		}
		else if (bReservedToBuyer && buyerPri.GetTeamNum() == PlayerPerspective.GetTeamNum())
		{
			return "Reserved for"@buyerPRI.PlayerName;
		}
	}
	return "";
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
	if(GetTimerRate('ResetSpotted') - GetTimerCount('ResetSpotted') >= SpottedTime) return; //Already spotted for longer by something else	
	
	bSpotted = true;
	SetTimer(SpottedTime,false,'ResetSpotted');
}

function ResetSpotted()
{
	bSpotted = false;
}

simulated function SetFocused()
{
//Hold
}

reliable server function ServerSetFocused() //Draw a focus-fire symbol for enemy targets on this unit
{
	//`log("SERVER SetFocused on " @ self);
	bFocused = true;
	SetTimer(10.0,false,'ResetFocused'); 
}



function ResetFocused()
{
	bFocused = false; 
}

event CheckReset()
{
	//don´t reset
	ResetTime = WorldInfo.TimeSeconds + 10000000.0;
}

simulated function UTGib SpawnGibVehicle(vector SpawnLocation, rotator SpawnRotation, StaticMesh TheMesh, vector HitLocation, bool bSpinGib, vector ImpulseDirection, ParticleSystem PS_OnBreak, ParticleSystem PS_Trail)
{
	local UTGib gib;	
	gib = super.SpawnGibVehicle(SpawnLocation,SpawnRotation,TheMesh,HitLocation,bSpinGib,ImpulseDirection,PS_OnBreak,PS_Trail);
	if(gib != None)
		gib.LifeSpan = 4.0 + (2.0 * FRand());
	return gib;
}

simulated event Destroyed()
{
	local Rx_Controller C;
	if (bEMPd)
		StopEMPEffects();   // don't know if cleaning up particle system component is necessary here, but doing just in case.
	if (Speaker != None)
	{
		Speaker.Destroy();
		Speaker = None;
	}
	//if(ROLE == ROLE_Authority) ClientNotifyTargetKilled();
	
	super.Destroyed();
	Recoil = None;
	buyerPri = None;
	Passenger2PRI = None;
	Passenger3PRI = None;
	Passenger4PRI = None;
	Passenger5PRI = None;
	if (BoundPRI != None)
	{
		foreach WorldInfo.AllControllers(class'Rx_Controller', C)
		{
			if (C.PlayerReplicationInfo == BoundPRI)
			{
				C.ReceiveLocalizedMessage(class'Rx_Message_Vehicle',VM_Destroyed,,,Class);
				break;
			}
		}
	}
	UnBind();
}

/**function setBlinkingName()
{
	bBlinkingName = true;
	SetTimer(3.5,false,'DisableBlinkingName');
}*/

function SetUISymbol(byte sym)
{
	UISymbol = sym; 
	SetTimer(3.5,false,'DisableUISymbol');
}


function DisableUISymbol()
{
	UISymbol = 0; 
}

simulated function byte GetHealNecessity() //On a scale from 0 to 3, how much does it hurt? 
{
	local float HealthFraction; 
	
	HealthFraction = (float(Health)/float(HealthMax))*100.0 ;

	
	if(HealthFraction <= 33) return 3 ; //Critical
	else
	if(HealthFraction <= 66) return 2 ; // Should probably heal me, bro 
	else
	if(HealthFraction <= 95) return 1; //Not much in the way of necessity on healing
	else
	return 0 ; 
}

simulated function BlowupVehicle()
{
	local int i;

	if(bDriving)
	{
		VehicleEvent('EngineStop');
	}

	bCanBeBaseForPawns = false;
	LinkHealMult = 0.0;
	GotoState('DyingVehicle');
	AddVelocity(TearOffMomentum, TakeHitLocation, HitDamageType);
	bDeadVehicle = true;
	
	if(!bStayUprightOnDeath){
		
		bStayUpright = false;
		if ( StayUprightConstraintInstance != None )
		{
			StayUprightConstraintInstance.TermConstraint();
		}
	}
	

	// Iterate over wheels, turning off those we want
	for(i=0; i<Wheels.length; i++)
	{
		if(UDKVehicleWheel(Wheels[i]) != None && UDKVehicleWheel(Wheels[i]).bDisableWheelOnDeath)
		{
			SetWheelCollision(i, FALSE);
		}
	}

	CustomGravityScaling = 1.0;
	if ( UDKVehicleSimHover(SimObj) != None )
	{
		UDKVehicleSimHover(SimObj).bDisableWheelsWhenOff = true;
	}
}

/**function DisableBlinkingName()
{
	bBlinkingName = false;	
}*/

simulated state DyingVehicle
{
	
	
	simulated function DoVehicleExplosion(bool bDoingSecondaryExplosion)
	{
		local rotator PerpendicularVelocity; 
		
		super.DoVehicleExplosion(bDoingSecondaryExplosion);
			//Mesh.SetRBRotation(PerpendicularVelocity*500);
			
			//Mesh.AddTorque(9000*vector(PerpendicularVelocity));
			//Let aircraft crash 
			if(Rx_Vehicle_Air(self) != none || Rx_Vehicle_Air_Jet(self) != none){
				
				PerpendicularVelocity.Pitch = Mesh.rotation.pitch+DestroyedRotatorAddend.pitch;
				PerpendicularVelocity.Roll=Mesh.rotation.Roll+DestroyedRotatorAddend.Roll;
				PerpendicularVelocity.Yaw=Mesh.rotation.Yaw+DestroyedRotatorAddend.Yaw;
				
				Mesh.AddForce(DeathImpulseStrength*vector(PerpendicularVelocity), location + vector(rotation) * (DestroyedImpulseOffset*-1.0)); 
				bStayUpright = bStayUprightOnDeath;
				
				if(!bDoingSecondaryExplosion)
					return;
				else{
					Mesh.SetHidden(true);
					SetCollision(false,false); 
				}
				
			}
			else {
				Mesh.SetHidden(true);
				SetCollision(false,false); 
			}
			
	}
}

simulated function ClientSetAsTarget(int Spot_Mode, coerce string TeamString, int Num)
{
	if(Health <= 0 || self.IsInState('Dead') ) return;
	ServerSetAsTarget(Spot_Mode, TeamString, Num);
}

reliable server function ServerSetAsTarget(int Spot_Mode, coerce string TeamString, int Num)
{
local Rx_ORI ORI;

ORI=Rx_GRI(WorldInfo.GRI).ObjectiveManager;

//`log("---PC is: " @ ORI @ "---------") ; 

ORI.Update_Markers (
TeamString, //String of what team we're updating these for. The object keeps track of GDI/Nod targets, but only displays the targets that correspond with the 
Spot_Mode, //Type of call getting passed down. 0:Attack 1: Defend 2: Repair 3: Waypoint
0, //Whether to update Commander/CoCommander or Support Targets [assume 1 commander for now]
false, // If we're looking to update a waypoint. If this is true, and CT is equal to 1, we'll update the defensive waypoint.
false, //If this is a building being targeted
self	//Actor we'll be marking
);


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

reliable client function ClientNotifyTarget(int TeamNum, int Target_Type, int TargetNum)
{
	local Rx_Controller PC;
	
	PC = Rx_Controller(GetALocalPlayerController()) ;
	//`log(PC);
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

function PromoteUnit(byte rank) //Promotion depends mostly on the unit. All units gain health however [was simulated]
{	
	local float HealthPCT; 

	if(rank < 0) rank = 0;
	else
	if(rank > 3) rank = 3; 

	HealthPCT=float(Health)/float(HealthMax); 

	HealthMax=default.Health*Vet_HealthMod[rank]; 
	Health=HealthMax*HealthPCT; 

	//Health=default.Health*Vet_HealthMod[rank]; 
	VRank=rank; 

	if(rank >= 2)
	{
		SetTimer(0.5f, true, 'regenerateHealth'); //Start Regenerating if Elite / Heroic
		if(rank == 3)
			RegenerationRate = HeroicRegenerationRate; 
		else
			RegenerationRate = default.RegenerationRate; 
	}
	else		
	{
		if(IsTimerActive('regenerateHealth') && !bAlwaysRegenerate) ClearTimer('regenerateHealth') ;
		if(WorldInfo.NetMode == NM_Standalone) SetHeroicMuzzleFlash(false);	
	}

	if(WorldInfo.NetMode == NM_Standalone && rank == 3)
		SetHeroicMuzzleFlash(true);

	if(Rx_vehicle_Weapon(Weapon) != none)
		Rx_Vehicle_Weapon(Weapon).PromoteWeapon(rank);
}

function regenerateHealth()
{
	if(bTakingDamage) return; 

    if(Health  < HealthMax) {    
		Health += RegenerationRate;
		if(Health > HealthMax) Health=HealthMax; 

		ApplyMorphHeal(RegenerationRate);
    }
}

function setTakingDamage()
{
	bTakingDamage = true; 
	SetTimer(3.0,false,'ResetTakingDamageTimer');
}

function ResetTakingDamageTimer()
{
	bTakingDamage = false; 
}


function string BuildDeathVPString(Controller Killer, class<DamageType> DamageType)
{
	local string VPString;
	local int IntHolder; //Hold current number we'll be using 
	local int KillerVRank; 
	local float BaseVP;
	//local class<Rx_Vehicle> Killer_VehicleType; 
	//local class<Rx_FamilyInfo>  Victim_FamInfo; Killer_FamInfo,
	local string Killer_Location, Victim_Location; 
	//local bool  KillerisVehicle, KillerisPawn; KillerInBase, KillerInEnemyBase, VictimInBase, VictimInEnemyBase, 
	local Rx_PRI KillerPRI; 
	local bool	bNeutral; 
	
	//if(Killer == none || LastTeamToUse == Killer.GetTeamNum() ) return ""; //Meh, you get nothing
	
	if((Killer == none && Rx_Controller(Killer) == none && Rx_Bot(Killer) == none) || LastTeamToUse == Killer.GetTeamNum() ) return ""; //Only RX controllers and bots have a concept of VP

	
	//Remember that -I- am the victim here
	//Begin by finding WHAT we are
	if(Rx_Vehicle(Killer.Pawn) != none ) //I got shot by another vehicool  
	{
		//KillerisVehicle = true; 
		//Killer_VehicleType = class<Rx_Vehicle>(Killer.Pawn.class); //Shouldn't really come into play.
		//Get Veterancy Rank
		KillerVRank = Rx_Vehicle(Killer.Pawn).GetVRank(); 

	}
	else 
	//You're a Pawn, Harry
	if(Rx_Pawn(Killer.Pawn) != none )
	{
		//KillerisPawn = true; 
		//Killer_FamInfo = Rx_Pawn(Killer.Pawn).GetRxFamilyInfo();
		//Get Veterancy Rank
		KillerVRank = Rx_Pawn(Killer.Pawn).GetVRank(); 
	}
	
	/*Finding location info*/ 
	

	KillerPRI = Rx_PRI(Killer.PlayerReplicationInfo);
	
	IntHolder=Killer.GetTeamNum(); 
	
	Killer_Location = GetPawnLocation(Killer.Pawn); 
	
	IntHolder=GetTeamNum(); 
	
	Victim_Location = GetPawnLocation(self); 
	
	/*End Getting location*/
	
	//VP count starts here. 
	BaseVP = default.VPReward[VRank]; 
	
	bNeutral = true; 
	
	VPString = "[Vehicle Kill]&+" $ BaseVP $ "&" ; 
	
	/**************************************************/
	/*Look for neutral Modifiers (Pawns and Vehicles)*/
	/**************************************************/
	//Are THEY defending a beacon 
	if(NearEnemyBeacon()) //If we're near an enemy beacon 
	{
	
		IntHolder = class'Rx_VeterancyModifiers'.default.Mod_BeaconDefense;	
			
		BaseVP+=IntHolder;
		
		VPString = VPString $ "[Beacon Defence]&+" $ IntHolder $ "&";
		
		if(KillerPRI != none)
		{
			KillerPRI.AddBeaconKill(); 
			KillerPRI.AddBeaconKill(); //So nice, we do it twice for vehicles
		}
		
	} 
		
		//Are WE defending an enemy beacon?
		
	if(NearFriendlyBeacon()) //If we're near a friendly beacon 
	{
	
		IntHolder = class'Rx_VeterancyModifiers'.default.Mod_BeaconAttack;	
			
		BaseVP+=IntHolder;
		
		VPString = VPString $ "[Beacon Offence]&+" $ IntHolder $ "&";
	
	} 
		//Are we a substantially higher VRank than them ? 
	if(TempVRank > KillerVRank ) //Ya' done got fucked, son  [Negative Modifiers] (Leave out the '+') 
	{
	
		IntHolder = class'Rx_VeterancyModifiers'.default.Mod_Disadvantage*(VRank - KillerVRank);	
			
		BaseVP+=IntHolder;
		
		VPString = VPString $ "[Disadvantage]&+" $ IntHolder $ "&";
	
	}
		
	if( PawnInFriendlyBase(Victim_Location, self) ) // Getting wrecked in your own base
	{
	
		IntHolder = class'Rx_VeterancyModifiers'.default.Mod_AssaultKill;	
			
		BaseVP+=IntHolder;
		
		VPString = VPString $ "[Offensive Kill]&" $ IntHolder $ "&";
		
		if(KillerPRI != none)
			KillerPRI.AddOffensiveVehKill(); 
		
		bNeutral = false; 
	} 
		//Is this a Ground-to-Air exchange
	if(Rx_Vehicle_Air(self) != none  &&  Rx_Vehicle_Air(Killer.Pawn) == none) //Killing an air vehicle with a ground vehicle 
	{
		IntHolder = class'Rx_VeterancyModifiers'.default.Mod_Ground2Air;	
			
		BaseVP+=IntHolder;
		
		VPString = VPString $ "[Ground to Air]&" $ IntHolder $ "&";
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
		
	if( PawnInFriendlyBase(Killer_Location, Killer.Pawn) ) //Is this bastard in his own base ? [Negative Modifiers] (Leave out the '+') 
	{
		IntHolder = class'Rx_VeterancyModifiers'.default.Mod_DefenseKill;	
			
		BaseVP+=IntHolder;
		
		VPString = VPString $ "[Defensive Kill]&" $ IntHolder $ "&";
		
		if(KillerPRI != none)
			KillerPRI.AddDefensiveVehKill();
		
		bNeutral = false; 
	} 
		
	//EDIT Just show NET amount. Comment this out to show full feat list 
		
	BaseVP=fmax(1.0, BaseVP); //Offer at least 1 VP cuz... why not ? Consolation prize
		
	if(KillerPRI != none)
		KillerPRI.AddVehicleKill();
	
	if(bNeutral)
		KillerPRI.AddNeutralVehKill();
		
	return "[Vehicle Kill]&+" $ BaseVP $ "&" ;
		
	//Uncomment to show full feat list
	//return VPString ; /*Complicated for the sake of you entitled, ADHD kids that need flashing lights to pet your ego. BaseVP$"&"$ */
}

//A much lighter variant of the VPString builder, used to calculate assists (Which only add in negative modifiers for in-base and higher VRank)
function int BuildAssistVPString(Controller Killer) 
{
	local int EndAssistModifier;
	local int KillerVRank; 
	local string Killer_Location, Victim_Location; 
	local Rx_PRI KillerPRI;
	local bool	 bNeutral; 
	
	//Remember that -I- am the victim here
	
	if(Rx_Controller(Killer) == none && Rx_Bot(Killer) == none) return 0; //Only RX controllers and bots have a concept of VP
	
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
	
	bNeutral = true; 
	
	KillerPRI=Rx_PRI(Killer.PlayerReplicationInfo);
	
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
			KillerPRI.AddOffensiveVehAssist(); 
		
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
		EndAssistModifier += class'Rx_VeterancyModifiers'.default.Mod_DefenseKill;	
			
		if(KillerPRI != none)
			KillerPRI.AddDefensiveVehAssist(); 
		
		bNeutral = false; 
	} 
		
	if(KillerPRI != none)
	{
		KillerPRI.AddVehicleAssist(); 
		
		if(bNeutral)
			KillerPRI.AddNeutralVehAssist();
		
		KillerPRI.AddScoreToPlayerAndTeam(0); /*Add 0 for assists. That way they don't affect Legacy, but also call the update for Score in the new PRI score system.*/
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

function int GetVRank()
{
	return VRank; 
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
	
	WGRI = Rx_GRI(WorldInfo.GRI);
	
	if(P == none || WGRI == none) return "";
		
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

function bool PawnInFriendlyBase(coerce string LocationInfo, Pawn P)
{
	local int TEAMI;
	local Volume V; 
	
	if(P==none) return false;
	
	if(Rx_Vehicle(P) != none) TeamI=Rx_Vehicle(P).LastTeamToUse; //If it's a vehicle then go off of the last team that used it.
	else
	TEAMI=P.GetTeamNum();

		switch(TEAMI)
	{
	case 0:
	foreach TouchingActors(class'Volume', V)
	{
		if(Rx_Volume_TeamBase_GDI(V) != none) return true; 
		else
		continue; 
	}
	
	//if(Caps(LocationInfo)=="GDI REFINERY" || Caps(LocationInfo)=="GDI POWERPLANT" || Caps(LocationInfo)=="WEAPONS FACTORY" || Caps(LocationInfo) == "BARRACKS" || CAPS(LocationInfo) == "ADV. GUARD TOWER") return true;
	break;
	
	case 1: 
	//if(Caps(LocationInfo)=="NOD REFINERY" || Caps(LocationInfo)=="NOD POWERPLANT" || Caps(LocationInfo)=="AIRSTRIP" || Caps(LocationInfo) == "HAND OF NOD" || Caps(LocationInfo) == "OBELISK OF LIGHT") return true;
	foreach TouchingActors(class'Volume', V)
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

function bool PawnInEnemyBase(coerce string LocationInfo, Pawn P)
{
	local int TEAMI;
	local Volume V; 
	
	if(P==none) return false;
	
	if(Rx_Vehicle(P) != none) TeamI=Rx_Vehicle(P).LastTeamToUse; //If it's a vehicle then go off of the last team that used it.
	else
	TEAMI=P.GetTeamNum();
	
		switch(TEAMI)
	{
	case 0: 
	//if(Caps(LocationInfo)=="NOD REFINERY" || Caps(LocationInfo)=="NOD POWERPLANT" || Caps(LocationInfo)=="AIRSTRIP" || Caps(LocationInfo) == "HAND OF NOD" || Caps(LocationInfo) == "OBELISK OF LIGHT") return true;
	foreach TouchingActors(class'Volume', V)
	{
		if(Rx_Volume_TeamBase_Nod(V) != none) return true; 
		else
		continue; 
	}
	break;
	
	case 1: 
	foreach TouchingActors(class'Volume', V)
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

//Used to verify the client isn't sending up a VP buy request for something different. 
function static bool VerifyVPPrice(byte Iterator,int Cost)
{ 
	local int VP0,VP1,VP2; //Hold our default VP values 
	
	VP0 = default.VPCost[0]; 
	VP1 = default.VPCost[1]; 
	VP2 = default.VPCost[2]; 
	
	switch(Iterator)
	{
	case 0: 
	if(Cost != VP0) return false ;  //client vehicle out of sync, update it.
	break; 
	
	case 1: 
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

function HealerKillAssistBonus (int Amount) //For infantry... may just make it for everyone honestly
{
	local Repairer RPRII;
	local Controller C; 
		foreach CurrentHealers(RPRII)
		{
		if(RPRII.PPRI != none)
			{
			if((WorldInfo.TimeSeconds - RPRII.LastRepairTime) <= 5.0) 
				{
				C=Controller(RPRII.PPRI.Owner); 
				//`log(RPRII.PPRI.Owner @ EventInstigator @ RPRII.DamageDone); 
				if(Rx_Controller(C) != none ) Rx_Controller(C).DisseminateVPString("[Infantry Kill Repair Assist]&" $ Amount $ "&"); 
				else
				if(Rx_Bot(C) != none ) Rx_Bot(C).DisseminateVPString("[Infantry Kill Repair Assist]&" $ Amount $ "&"); 
				}
			}
		}
}

simulated function vector GetAdjustedEffectLocation(int SeatIndex) //Use this when sticking barrels through terrain
{
	local vector SocketLocation;
	local rotator SocketRotation;

	if ( Seats[SeatIndex].GunSocket.Length == 0 )
		return Location;
	
	
	GetBarrelLocationAndRotation(SeatIndex,SocketLocation, SocketRotation);
	SocketLocation = SocketLocation+vector(SocketRotation) * (-1.0*BarrelLength[SeatIndex]); 
	//`log("AdjustingLocation" @ SocketLocation) ;
	return SocketLocation;
}

simulated function Vector GetAdjustedPhysicalFireStartLoc(UTWeapon ForWeapon)
{
	local UTVehicleWeapon VWeap;

	VWeap = UTVehicleWeapon(ForWeapon);
	if ( VWeap != none )
	{
		return GetAdjustedEffectLocation(VWeap.SeatIndex);
	}
	else
		return location;
}

 simulated function SetVehicleEffectParms(name TriggerName, ParticleSystemComponent PSC)
 {
	
		 super.SetVehicleEffectParms(TriggerName, PSC);
 }
 
 simulated function SetHeroicMuzzleFlash(bool SetTrue)
 {
	 local int i; 
	 
	 if(Heroic_MuzzleFlash == none) return; 
	 
	 for(i=0;i<VehicleEffects.Length;i++)
	 {
		 if(VehicleEffects[i].EffectStartTag=='MainGun' && VehicleEffects[i].EffectRef != none) 
		 {
			 if(SetTrue) VehicleEffects[i].EffectRef.SetTemplate(Heroic_MuzzleFlash);
			 else
			VehicleEffects[i].EffectRef.SetTemplate(default.VehicleEffects[i].EffectTemplate);
			return;
		 }
	 }
 }

 reliable client function ClientUpdatePhysics( EPhysics newPhysics )
 {
	 //`log("Update Physics client" @ newPhysics) ; 
	SetPhysics(newPhysics) ;
 }

//RxIfc_Airlift
simulated function bool bReadyToLift() 
{
	//`log( self @ "Ready for Pickup" @ PlayerReplicationInfo == None @ LastTeamToUse > 1 @ !bPickedUp ) ; 
	return (PlayerReplicationInfo == None && LastTeamToUse == 255 &&  !bPickedUp) ;
} 

simulated function OnAttachToVehicle()
{
	if(Rx_SupportVehicle(Base) != none) LastTeamToUse = Rx_SupportVehicle(Base).TeamIndex;
}

simulated function DetachFromVehicle()
{
	SetPhysics(PHYS_RigidBody); 
	Mesh.WakeRigidBody();
}
//End RxIfc_Airlift

/****Do not stack supply crate healing*****/
function SetLastSupportHealTime()
{
	if(Rx_Controller(Controller) != none) Rx_Controller(Controller).SetLastSupportHealTime();  
	else
	if(Rx_Bot(Controller) != none) Rx_Bot(Controller).SetLastSupportHealTime(); 
}

function bool bCanAcceptSupportHealing()
{
	if(Rx_Controller(Controller) != none) return Rx_Controller(Controller).LastSupportHealTime < WorldInfo.TimeSeconds ; 
	else
	if(Rx_Bot(Controller) != none) return Rx_Bot(Controller).LastSupportHealTime < WorldInfo.TimeSeconds; 
	else
	return false; 
}


/**Stat Modifier Calls**/ 
simulated function float GetSpeedModifier()
{
	
	if(bEMPd) return 0.0; 
	
	if(Rx_Controller(Controller) != none) 
		return Vet_SprintSpeedMod[VRank]+(Rx_Controller(Controller).Misc_SpeedModifier); 
	
	else if(Rx_Bot(Controller) != none) 
	{
		return Vet_SprintSpeedMod[VRank]+(Rx_Bot(Controller).Misc_SpeedModifier); 
	}
	
	else if(Rx_Vehicle_HarvesterController(Controller) != none) 
		return Vet_SprintSpeedMod[VRank]+(Rx_Vehicle_HarvesterController(Controller).Misc_SpeedModifier); 
	
	else if(Rx_Defence_Controller(Controller) != none) 
		return Vet_SprintSpeedMod[VRank]+(Rx_Defence_Controller(Controller).Misc_SpeedModifier); 
	
	else
		return Vet_SprintSpeedMod[VRank]; 
}

simulated function float GetScriptedSpeedModifier()
{
	if(Rx_Bot_Scripted(Controller) != None && Rx_Bot_Scripted(Controller).MySpawner != None)
		return Rx_Bot_Scripted(Controller).MySpawner.SpeedModifier;

	else
		return 1.f;
}

//Resistance is about the only thing defences and Harvesters need to worry about 
function float GetResistanceModifier()
{
	if(Rx_Controller(Controller) != none) return Rx_Controller(Controller).Misc_DamageResistanceMod; 
	else
	if(Rx_Bot(Controller) != none) return Rx_Bot(Controller).Misc_DamageResistanceMod; 
	else
	if(Rx_Vehicle_HarvesterController(Controller) != none) return Rx_Vehicle_HarvesterController(Controller).Misc_DamageResistanceMod;
	else
	if(Rx_Defence_Controller(Controller) != none) return Rx_Defence_Controller(Controller).Misc_DamageResistanceMod; 
	else
	return 1.0; 
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


/** Jacked the Link gun code, as vehicles already have most of the code for overlays in that*/
simulated function SetOverlay(LinearColor MatColour)
{
	local MaterialInstanceConstant MIC;
	local int i;
	
	/*Server doesn't need to concern itself with visuals, and just replicates the colour */
	if(WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer) 
	{
		VehicleOverlayColour = MatColour; 
		return; 
	}
	
	/*Run client/standalone visual code*/
	
	for (i = 0; i < Mesh.Materials.Length || i < Mesh.SkeletalMesh.Materials.Length; i++)
	{
		if (i < Mesh.Materials.Length)
		{
			MIC = MaterialInstanceConstant(Mesh.Materials[i]);
		}
		if (MIC == None)
		{
			if (i >= Mesh.Materials.Length || Mesh.Materials[i] == None)
			{
				Mesh.SetMaterial(i, Mesh.SkeletalMesh.Materials[i]);
			}
			MIC = Mesh.CreateAndSetMaterialInstanceConstant(i);
		}
		if (MIC != None)
		{
			MIC.SetVectorParameterValue('Veh_OverlayColor', MatColour);
			MIC.SetScalarParameterValue('Veh_Overlay_Distort_Amount', 0.500000); //Stop being so damn weird
		}
	}
}

/** Just stole the link gun code to avoid reinventing the wheel entirely*/
simulated function ClearOverlay()
{
	local MaterialInstanceConstant mic;
	local LinearColor Black;
	local int i;

	/*Server doesn't need to concern itself with visuals, and just replicates the colour */
	if(WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer) 
	{
		VehicleOverlayColour = Black; 
		return; 
	}
	
	for (i = 0; i < Mesh.Materials.Length; i++)
	{
		MIC = MaterialInstanceConstant(Mesh.Materials[i]);
		if (MIC != None)
		{
			MIC.SetVectorParameterValue('Veh_OverlayColor',Black);
			MIC.SetScalarParameterValue('Veh_Overlay_Distort_Amount', 0.500000); //Stop being so damn weird

		}
	}
}

simulated function float GetTurnTrackSpeedModifier()
{
	if(bEMPd) return 0.0; 
	if(Rx_Controller(Controller) != none) return Vet_SprintTTFD[VRank]+(Rx_Controller(Controller).Misc_SpeedModifier); 
	else
	if(Rx_Bot(Controller) != none) return Vet_SprintTTFD[VRank]+(Rx_Bot(Controller).Misc_SpeedModifier); 
	else
	return Vet_SprintTTFD[VRank]; 
}

simulated function UpdateThrottleAndTorqueVars()
{
	if(UDKVehicleSimCar(SimObj) != None)
		{
			UDKVehicleSimCar(SimObj).ThrottleSpeed = UDKVehicleSimCar(SimObj).Default.ThrottleSpeed * MinSprintSpeedMultiplier*GetSpeedModifier() * GetScriptedSpeedModifier(); //*Vet_SprintSpeedMod[VRank];
			if(Rx_Bot_Scripted(Controller) != None)
			{
				MaxSpeed = Default.MaxSpeed * GetScriptedSpeedModifier();
				ServerSetMaxSpeed(MaxSpeed);
			}
		}
		else if(SVehicleSimTank(SimObj) != None)
		{
			if(bSprinting)
			{
				SVehicleSimTank(SimObj).MaxEngineTorque = SVehicleSimTank(SimObj).Default.MaxEngineTorque * MinSprintSpeedMultiplier*GetSpeedModifier() * GetScriptedSpeedModifier(); //*Vet_SprintSpeedMod[VRank];
				SVehicleSimTank(SimObj).InsideTrackTorqueFactor =  SVehicleSimTank(SimObj).Default.InsideTrackTorqueFactor * ((MinSprintSpeedMultiplier*GetSpeedModifier()) / (Rx_Vehicle_Treaded(self).SprintTrackTorqueFactorDivident+GetTurnTrackSpeedModifier()))  * GetScriptedSpeedModifier();
			}
			else
			{
				SVehicleSimTank(SimObj).MaxEngineTorque = SVehicleSimTank(SimObj).Default.MaxEngineTorque  * GetScriptedSpeedModifier(); //*Vet_SprintSpeedMod[VRank];
				SVehicleSimTank(SimObj).InsideTrackTorqueFactor =  SVehicleSimTank(SimObj).Default.InsideTrackTorqueFactor  * GetScriptedSpeedModifier();
			}
			
		} 	
}

function bool TryExitPos(Pawn ExitingDriver, vector ExitPos, bool bMustFindGround)
{
	local bool ret;
	
	ret = super.TryExitPos(ExitingDriver, ExitPos, bMustFindGround);	
	if(ret)
	{
		if(PlayAreaVolumeOfPawn(ExitingDriver) == None && PlayAreaVolumeOfPawn(self) != None)
		{	
			return false; // dont allow this Exitlocation as its out of the PlayArea
		}	
	}	
	return ret;
}

function Rx_PlayAreaVolume PlayAreaVolumeOfPawn(Pawn P)
{
	local Rx_PlayAreaVolume V;

	foreach P.TouchingActors( class'Rx_PlayAreaVolume', V )
		return V;

	return None;
}

simulated function SetInputs(float InForward, float InStrafe, float InUp)
{
	if(bEMPd) 
	{
		InForward	=	0.0; 
		InStrafe	=	0.0;
		InUp		=	0.0;
	}		
	
	super.SetInputs(InForward,InStrafe,InUp);
}

simulated function float GetThrottle()
{
	if(UDKVehicleSimCar(simobj) != none)
	{
		return	UDKVehicleSimCar(simobj).ThrottleSpeed;
	}

	if(SVehicleSimTank(simobj) != none)
	{
		return SVehicleSimTank(simobj).MaxEngineTorque;
	}
}

simulated function float GetInwardTurnTrack()
{
	if(UDKVehicleSimCar(simobj) != none)
	{
		return	0.0; 
	}
	else
	if(SVehicleSimTank(simobj) != none)
	{
		return SVehicleSimTank(simobj).InsideTrackTorqueFactor;
	}
	else
	return 0.0; 
}

/******************
*RxIfc_RadarMarker*
*******************/

//0:Infantry 1: Vehicle 2:Miscellaneous  
simulated function int GetRadarIconType()
{
	return 1; //Vehicle
} 

simulated function bool ForceVisible()
{
	return (PlayerReplicationInfo == none && GetTeamNum() == 255) || (Rx_PRI(PlayerReplicationInfo) !=none && Rx_PRI(PlayerReplicationInfo).isSpotted());  
}

simulated function vector GetRadarActorLocation() 
{
	return location; 
} 
simulated function rotator GetRadarActorRotation()
{
	return rotation; 
}

simulated function byte GetRadarVisibility()
{
	return RadarVisibility; 
} 
simulated function Texture GetMinimapIconTexture()
{
	return MinimapIconTexture; 
}

/******************
*END RadarMarker***
*******************/

function UpdatePRILocation()
{
	if(Rx_PRI(PlayerReplicationInfo) != none)
		Rx_PRI(PlayerReplicationInfo).UpdatePawnLocation(location,rotation, velocity); 
}


/*Modifying Relevancy Temporarily*/

function SetTemporaryRelevance(float Amount)
{
	if(Rx_Game(WorldInfo.Game).bVehiclesAlwaysRelevant)
		return;
	
	SetRelevant(true);
	SetTimer(Amount,false,'ResetAlwaysRelevantTimer'); 
}

function SetRelevant(bool Rel)
{
	bAlwaysRelevant = Rel; 
}

function ResetAlwaysRelevantTimer()
{
	bAlwaysRelevant = Rx_Game(WorldInfo.Game).bVehiclesAlwaysRelevant; 
}

simulated function String GetHumanReadableName()
{
	if(CustomVehicleName != "")
		return CustomVehicleName;
	else
		return Super.GetHumanReadableName();
}

function DriverLeft()
{
	if(Rx_Controller(Driver.Controller) != None)
		Rx_Controller(Driver.Controller).ClientSetLocationAndKeepRotation( Driver.Location );
	super.DriverLeft();
}

function bool FindAutoExit(Pawn ExitingDriver)
{
	local vector X, Y, Z;
	local float PlaceDist;

	GetAxes(ExitRotation(), X,Y,Z);
	Y *= -1;

	if ( ExitRadius == 0 )
	{
		ExitRadius = CylinderComponent.CollisionRadius + 2*ExitingDriver.GetCollisionRadius();
	}
	PlaceDist = ExitRadius + ExitingDriver.GetCollisionRadius();

	if ( Controller != None )
	{
		if ( UTBot(ExitingDriver.Controller) != None )
		{
			// bot picks which side he'd prefer to get out on (since bots are bad at running around vehicles)
			return super.FindAutoExit(ExitingDriver);
		}
		else
		{
			// use the controller's rotation as a hint
			if ( (Y dot vector(Controller.Rotation)) < 0 )
			{
				Y *= -1;
			}
		}
	}

	if ( VSizeSq(Velocity) > Square(MinCrushSpeed) )
	{
		//avoid running driver over by placing in direction away from velocity
		if ( (Velocity Dot X) < 0 )
			X *= -1;
		// check if going sideways fast enough
		if ( (Velocity Dot Y) > MinCrushSpeed )
			Y *= -1;
	}

	if ( TryExitPos(ExitingDriver, GetTargetLocation() + (ExitOffset >> Rotation) - (PlaceDist * Y), bFindGroundExit) )
		return true;
	if ( TryExitPos(ExitingDriver, GetTargetLocation() + (ExitOffset >> Rotation) + (PlaceDist * Y), bFindGroundExit) )
		return true;

	if ( TryExitPos(ExitingDriver, GetTargetLocation() + (ExitOffset >> Rotation) - (PlaceDist * X), false) )
		return true;
	if ( TryExitPos(ExitingDriver, GetTargetLocation() + (ExitOffset >> Rotation) + (PlaceDist * X), false) )
		return true;
	if ( !bFindGroundExit )
		return false;
	if ( TryExitPos(ExitingDriver, GetTargetLocation() + (ExitOffset >> Rotation) + (PlaceDist * Y), false) )
		return true;
	if ( TryExitPos(ExitingDriver, GetTargetLocation() + (ExitOffset >> Rotation) - (PlaceDist * Y), false) )
		return true;
	if ( TryExitPos(ExitingDriver, GetTargetLocation() + (ExitOffset >> Rotation) + (PlaceDist * Z), false) )
		return true;

	return false;
}


simulated function bool CanBeBaseForPawn(Pawn APawn)
{
	return super.CanBeBaseForPawn(APawn) && Rx_Vehicle_Walker(APawn) == None;
}

simulated function byte GetTeamNum()
{
	if(Rx_Bot_Scripted(Controller) != None)
		return Controller.GetTeamNum();
	else if(Rx_Pawn_Scripted(Driver) != None)
		return Driver.GetTeamNum();
	else if(Rx_Pawn_Scripted(Seats[0].StoragePawn) != None)
		return Seats[0].StoragePawn.GetTeamNum();

	return Super.GetTeamNum();
}

DefaultProperties
{
	//nBab
    /*Begin Object Name=MyLightEnvironment
        bSynthesizeSHLight=true
        bUseBooleanEnvironmentShadowing=FALSE
        //setting shadow frustum scale (nBab)
        LightingBoundsScale=0.12
    End Object
    LightEnvironment=MyLightEnvironment
    Components.Add(MyLightEnvironment)*/

	bRotateCameraUnderVehicle = true
    
	MinSprintSpeedMultiplier=1.0
	MaxSprintSpeedMultiplier=1.2
	SprintTimeInterval=1.0
	SprintSpeedIncrement=1.0
   
   	RadarVisibility = 1
   
	Begin Object name=SVehicleMesh
		ScriptRigidBodyCollisionThreshold=100.0
	End Object
	
	fpCameraTag = CamView1P
	tpCameraTag = CamView3P
	fpCamera = false
	LinkHealMult = 1
	Begin Object Name=CollisionCylinder
	CollisionHeight=50.0
	CollisionRadius=140.0
	Translation=(X=0.0,Y=0.0,Z=0.0)
	End Object
	CylinderComponent=CollisionCylinder

	//EMPParticleTemplate=ParticleSystem'Pickups.Deployables.Effects.P_Deployables_EMP_Mine_VehicleDisabled'
	Begin Object Class=ParticleSystemComponent Name=EMPParticleComp
		bAutoActivate=false
		Template=ParticleSystem'Pickups.Deployables.Effects.P_Deployables_EMP_Mine_VehicleDisabled'
	End Object
	Components.Add(EMPParticleComp)
	EMPParticleComponent=EMPParticleComp

	Begin Object Class=AudioComponent Name=EMPSoundComp
        SoundCue=SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_EMPLoop'
    End Object
    EMPSound=EMPSoundComp
    Components.Add(EMPSoundComp);
	
	bCanStrafe=false
	AIPurpose = AIP_Any
	
	bHomingTarget=false
	bOverrideAVRiLLocks=false
	bReverseSteeringInverted = true
	
	TeamBought=255
	LastTeamToUse=255
	bTeamLocked=false
	bEnteringUnlocks=true
	bEjectPassengersWhenFlipped=true
	bUsesBullets = false
	bOkAgainstBuildings=true
	bBindable=true
	TimeLastOccupied=-1
	ReservationLength=30

	DamageSmokeThreshold=0.25
	FireDamageThreshold=0.20
	FireDamagePerSec=0.0

	CollisionDamageMult=0.0
	WaterDamage=200.0
	UpsideDownDamagePerSec=200.0
	OccupiedUpsideDownDamagePerSec=200.0

	RespawnTime=10.0
	SpawnInTime=1.0
	SpawnRadius=200.0
	BurnOutTime=0.0
	DeadVehicleLifeSpan=1.0
	BurnTimeParameterName=BurnTime

	SpawnInSound = None
	SpawnOutSound = None
    SuspensionShiftSound= SoundCue'RX_SoundEffects.Vehicle.SC_VehicleCompress'

	ExplosionSound=SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_Explode'
	CollisionSound=SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_Collision'
	
	SprintBoostSound = None
	SprintStopSound = None

	ExplosionDamage=0
	ExplosionRadius=1

	RanOverDamageType=class'Rx_DmgType_RanOver'
	CrushedDamageType=class'Rx_DmgType_Pancake'

	EMPTime=6.0 //9.0//11
	EMPDamage=2 //1
	EMPDmgType=class'Rx_DmgType_EMPGrenade'

	CameraLag=0.3
	ViewPitchMin=-15000
	MinCameraDistSq=1.0
	DefaultFOV=75
	ZoomedFOV=50
	bNoZSmoothing=False
	CameraSmoothingFactor=2.0

	HealPointsScale   = 0.05f // means 0.05 points per healed healthpoint
	DamagePointsScale = 0.1f
	PointsForDestruction = 10.0f

	bStayUpright=true
	StayUprightRollResistAngle=40.0		// 20.0
	StayUprightPitchResistAngle=50.5	// 25.0
	StayUprightStiffness=2000			// 2000
	StayUprightDamping=2000				// 2000
	
	BrakeLightParameterName=BreakLights
	ReverseLightParameterName=ReverseLights
	HeadLightParameterName=Headlights
	
	DrivingAnim=H_M_Seat_Apache

	VehicleIconTexture=Texture2D'RenxHud.T_VehicleIcon_MissingCameo'

	// Seeking modifiers. Higher values mean seeking rockets can track this vehicle better
	SeekAimAheadModifier = 0.0
	SeekAccelrateModifier = 0.0
	
	ReducedThrottleForTurning = 0.7
	SpeedAtWhichToApplyReducedTurningThrottle = 340
	SkeletalMeshForPT=SkeletalMesh'RX_VH_MediumTank.Mesh.SK_VH_MediumTank'
	
	WheelParticleEffects.Empty
	WheelParticleEffects[0]=(MaterialType=Generic,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Generic')
    WheelParticleEffects[1]=(MaterialType=Dirt,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Dirt')
	WheelParticleEffects[2]=(MaterialType=Grass,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Dirt')
    WheelParticleEffects[3]=(MaterialType=Water,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Water')
    WheelParticleEffects[4]=(MaterialType=Snow,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Snow')
	WheelParticleEffects[5]=(MaterialType=Concrete,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Generic')
	WheelParticleEffects[6]=(MaterialType=Metal,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Generic')
	WheelParticleEffects[7]=(MaterialType=Stone,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Stone')
	WheelParticleEffects[8]=(MaterialType=WhiteSand,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_WhiteSand')
	WheelParticleEffects[9]=(MaterialType=YellowSand,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_YellowSand')
	DefaultWheelPSCTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Dirt'
	
	/*Veterancy */
	VRank=0

	SpotLocation = "NULL"
	SpotUpdateTime = 1.0 //Seconds
	
	//VP Given on death (by VRank)
	VPReward(0) = 5 
	VPReward(1) = 7 
	VPReward(2) = 9 
	VPReward(3) = 12

	VPCost(0) = 10
	VPCost(1) = 20
	VPCost(2) = 30
	
	Vet_HealthMod(0)=1
	Vet_HealthMod(1)=1
	Vet_HealthMod(2)=1
	Vet_HealthMod(3)=1
	
	Vet_SprintSpeedMod(0)=1.0
	Vet_SprintSpeedMod(1)=1.0
	Vet_SprintSpeedMod(2)=1.0
	Vet_SprintSpeedMod(3)=1.0
	
	// +X as opposed to *X
	Vet_SprintTTFD(0)=0
	Vet_SprintTTFD(1)=0
	Vet_SprintTTFD(2)=0
	Vet_SprintTTFD(3)=0
	
	/**************************/
	
	RegenerationRate = 1
	HeroicRegenerationRate = 3 
	bHijackBonus = true
	bAlwaysRegenerate = false 
	bCanBePromoted = true  
	UISymbol = 0
	MaxDR = 0.1 //Maximumum of 90% damage resistance
	bHasPlayerEntered = false
	
	BarrelLength(0)=200
	BarrelLength(1)=200
	BarrelLength(2)=200
	BarrelLength(3)=200
	BarrelLength(4)=200
	BarrelLength(5)=200
	
	bPickedUp=false //When replicated, tells the client that the vehicle is being lifted
	
	bAlwaysRelevant = false

	CustomVehicleName = "" //The HUD will use this if it does not == "". This should only be used by mods/mutators.
	
	DeathImpulseStrength = 16000
	
	TestFric = 0.7 
}