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
	implements (RxIfc_ClientSideInstantHitRadius)
	implements (RxIfc_SeekableTarget)
	implements (RxIfc_EMPable)
	implements (RxIfc_TargetedDescription);

`define TakeEMPDamage TakeDamage(EMPDamage,EMPInstigator,vect(0,0,0),vect(0,0,0),EMPDmgType,,self)

var GameSkelCtrl_Recoil    Recoil;
var bool bLightArmor;
var bool bIsAircraft;
var name RecoilTriggerTag; // call same as FireTriggerTags in Vehicle Weapon!
var bool bUsesBullets;
var Pawn PawnThatTrysToDrive;
var byte TeamBought; // to save the Teamnum before going neutral for vehiclecounter calculations
var bool fpCamera;
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

/** Minimum speed multiplier for sprinting. */
var(Vehicle) repnotify float MinSprintSpeedMultiplier;

/** Maximum speed multiplier for sprinting. */
var(Vehicle) float MaxSprintSpeedMultiplier;

/** time interval for reaching maximum sprint speed. */
var(Vehicle) float SprintTimeInterval;

/** increment amount for addding/subtracting sprint speed modifier. */
var(Vehicle) float SprintSpeedIncrement;

var bool bSecondaryFireTogglesFirstPerson;
var bool bCanResetSlip;

var Rx_Speaker Speaker;
var bool bBlinkingName;


/** reference to the texture to use for the Hud */
var() Texture VehicleIconTexture;
var() Texture MinimapIconTexture;

replication
{
	if (bNetDirty && Role == ROLE_Authority )
		SavedDmg, bReverseSteeringInverted, bSprintingServer, MinSprintSpeedMultiplier, bSpotted, buyerPri, BoundPRI, bDriverLocked, bReservedToBuyer, bEMPd, bBlinkingName;

	if (bNetDirty && Role == ROLE_Authority && Seats.Length >= 3)
		Passenger2PRI;

	if (bNetDirty && Role == ROLE_Authority && Seats.Length >= 4)
		Passenger3PRI;

	if (bNetDirty && Role == ROLE_Authority && Seats.Length >= 5)
		Passenger4PRI;
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
			StopEMPEffects();
	}
	else if(VarName == 'bSprintingServer')
	{
		if(!bSprintingServer && IsTimerActive('DecreaseSprintSpeed'))
		{
			ClearTimer('DecreaseSprintSpeed');
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
		if(UDKVehicleSimCar(SimObj) != None)
		{
			UDKVehicleSimCar(SimObj).ThrottleSpeed = UDKVehicleSimCar(SimObj).Default.ThrottleSpeed * MinSprintSpeedMultiplier;
		}
		else if(SVehicleSimTank(SimObj) != None)
		{
			SVehicleSimTank(SimObj).MaxEngineTorque = SVehicleSimTank(SimObj).Default.MaxEngineTorque * MinSprintSpeedMultiplier;
    		SVehicleSimTank(SimObj).InsideTrackTorqueFactor =  SVehicleSimTank(SimObj).Default.InsideTrackTorqueFactor * (MinSprintSpeedMultiplier / Rx_Vehicle_Treaded(self).SprintTrackTorqueFactorDivident);
    	} 	
	}
	else
		super.ReplicatedEvent(VarName);

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
}

simulated event PostBeginPlay()
{
	local int i;
	
	super.PostBeginPlay();
	Team  = 255;
	
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
	
	if( Rx_Vehicle_Treaded(self) != None && Steering != 0 && Throttle > 0 && VSize(Velocity) > SpeedAtWhichToApplyReducedTurningThrottle) 
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
	if(!bSprinting)
	{
		if(!IsTimerActive('IncreaseSprintSpeed'))
		{
	    
			if(MinSprintSpeedMultiplier == Default.MinSprintSpeedMultiplier)
				IncreaseSprintSpeed();
			else
				SetTimer(SprintTimeInterval, true, 'IncreaseSprintSpeed');
		}
		if(IsTimerActive('DecreaseSprintSpeed'))
		{
			ClearTimer('DecreaseSprintSpeed');
		}

		bSprinting = true;
	}
}
function StopSprinting()
{
	if(bSprinting)
	{
		if(!IsTimerActive('DecreaseSprintSpeed'))
		{
			SetTimer(0.25, true, 'DecreaseSprintSpeed');
		}
		if(IsTimerActive('IncreaseSprintSpeed'))
		{
			ClearTimer('IncreaseSprintSpeed');
		}

		bSprinting = false;
	}
}

reliable server function ServerSetGroundSpeed(float Speed)
{
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

	MinSprintSpeedMultiplier += SprintSpeedIncrement;
	if(MinSprintSpeedMultiplier >= MaxSprintSpeedMultiplier)
	{
		MinSprintSpeedMultiplier = MaxSprintSpeedMultiplier;
		if(IsTimerActive('IncreaseSprintSpeed'))
		{
			ClearTimer('IncreaseSprintSpeed');
		}
	}

	SprintSpeed_Air = Default.AirSpeed * MinSprintSpeedMultiplier;
	SprintSpeed_Ground = Default.GroundSpeed * MinSprintSpeedMultiplier;
	SprintSpeed_Water = Default.WaterSpeed * MinSprintSpeedMultiplier;

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
		UDKVehicleSimCar(SimObj).ThrottleSpeed = UDKVehicleSimCar(SimObj).Default.ThrottleSpeed * MinSprintSpeedMultiplier;
}
reliable server function DecreaseSprintSpeed()
{
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

	AirSpeed = Default.AirSpeed;
	GroundSpeed = Default.GroundSpeed;
	WaterSpeed = Default.WaterSpeed;

	if(UDKVehicleSimCar(SimObj) != None)
		UDKVehicleSimCar(SimObj).ThrottleSpeed = UDKVehicleSimCar(SimObj).Default.ThrottleSpeed;
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
			SetTimer(1.0, false, 'reduce');
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

function reduce()
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
	// do nothing to remove the Hijacked sounds
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
	if ( bIsInverted && bMustBeUpright && !bVehicleOnGround && VSize(Velocity) <= 5.0f )
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
	return true;
}

function EnteredEMPField(Rx_EMPField EMPCausingActor);

function LeftEMPField(Rx_EMPField EMPCausingActor);

function bool EMPHit(Controller InstigatedByController, Actor EMPCausingActor)
{
	if (InstigatedByController.GetTeamNum() == GetTeamNum() || bEMPd)
		return false;

	bEMPd = true;
	if (bDriving)
		SetDriving(false);
	EMPTimeLeft = EMPTime;
	EMPInstigator = InstigatedByController;
	`TakeEMPDamage;
	StartEMPEffects();
	SetTimer(1.0, true, 'EMPBleed');
	return true;
}

function EMPBleed()
{
	if (--EMPTimeLeft <= 0)
	{
		ClearTimer('EMPBleed');
		bEMPd = false;
		if (Driver != None)
			SetDriving(true);
		StopEMPEffects();
	}
	else
	{
		// If EMP was initated by a teammate, make sure the damage isn't blocked by friendlyfire protection. Need proper way to do this :o
		if (EMPInstigator.GetTeamNum() == GetTeamNum())
			TakeDamage(EMPDamage,None,vect(0,0,0),vect(0,0,0),EMPDmgType,,self);
		else
			`TakeEMPDamage;
	}
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	local int i;
	local Rx_Pawn UTP;
	local byte WasTeam;

	WasTeam = GetTeamNum();
	
	for (i=0;i<Seats.Length;i++)
	{
		if (Seats[i].StoragePawn != None || Seats[i].StoragePawn != None)
		{
			UTP = Rx_Pawn(Seats[i].StoragePawn);
			if(UTP != none && Seats[i].SeatPawn != none)
			{
				if (Rx_Controller(Seats[i].SeatPawn.Controller) != None)
					Rx_Controller(Seats[i].SeatPawn.Controller).ReceiveVehicleDeathMessage(Killer.PlayerReplicationInfo, damageType);
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
		&& VSize(Controller.Enemy.location - location) < Weapon.MaxRange()) {
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
	
	dist = VSize(location - Enemy.location);
	
	if ( Vehicle(Enemy) == None && dist < weapon.MaxRange()) {
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
		if(dist < (500 + FRand()*200) 
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
			return Vsize(location - Enemy.location) < 800 + FRand()*300;
		}
	} else if(Rx_Vehicle_StealthTank(self) != None) {
		if ( Vehicle(Enemy) == None ) {
			return Vsize(location - Enemy.location) < 1000 + FRand()*400;
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
	dist = VSize(Location - Other.Location);
	return (dist < (300.0 + 200*FRand()));
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

function VehicleStolen()
{
	local Rx_Controller PC;
	if (BoundPRI == None)
		`LogRx("GAME" `s "Stolen;" `s self.Class `s "by" `s `PlayerLog(Seats[0].SeatPawn.PlayerReplicationInfo) );
	else
	{
		`LogRx("GAME" `s "Stolen;" `s self.Class `s "bound to" `s `PlayerLog(BoundPRI) `s "by" `s `PlayerLog(Seats[0].SeatPawn.PlayerReplicationInfo) );
		foreach WorldInfo.AllControllers(class'Rx_Controller', PC)
		{
			if (PC.PlayerReplicationInfo == BoundPRI)
			{
				PC.ReceiveLocalizedMessage(class'Rx_Message_Vehicle',VM_EnemyStolen,,,Class);
				UnBind(PC);
				return;
			}
		}
		UnBind();
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
	if (LastTeamToUse != 255 && GetTeamNum() != LastTeamToUse)
	{
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

    return true;
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
	
	if(Health <= 0)
		return;
	
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
		CurDmg = Float(Damage) * DamageType.static.VehicleDamageScalingFor(self);
		
		Damage *= DamageType.static.VehicleDamageScalingFor(self);
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
				Rx_PRI(EventInstigator.PlayerReplicationInfo).AddScoreToPlayerAndTeam(Scr);	    	    
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

	if (Health <= 0 || Amount <= 0 || Healer == None)
		return false;

	RealAmount = Min(Amount, HealthMax - Health);

	if (RealAmount > 0 && (Driver != none || Rx_Defence(self) !=none ))
	{
		if (Health >= HealthMax && SavedDmg > 0.0f)
		{
			SavedDmg = FMax(0.0f, SavedDmg - Amount);
			Scr = SavedDmg * HealPointsScale;
			Rx_PRI(Healer.PlayerReplicationInfo).AddScoreToPlayerAndTeam(Scr);
		}
		Scr = RealAmount * HealPointsScale;
		Rx_PRI(Healer.PlayerReplicationInfo).AddScoreToPlayerAndTeam(Scr);
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
	
	if(OtherComponent == None || VSize(Velocity - OtherComponent.Owner.Velocity) > 250) {
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
	if(UTPlayerController(Controller) == None || (!Rx_PlayerInput(UTPlayerController(Controller).PlayerInput).bAltPressed 
			&& !Rx_PlayerInput(UTPlayerController(Controller).PlayerInput).bCntrlPressed))
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
		return;
	}
	super.VehicleCalcCamera(DeltaTime,SeatIndex,out_CamLoc,out_CamRot,CamStart,bPivotOnly);
}

function float GetAimAheadModifier()
{
	return SeekAimAheadModifier;
}

function float GetAccelrateModifier()
{
	return SeekAccelrateModifier;
}

simulated function StartFire(byte FireModeNum)
{
 	local vector FireStartLoc;
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
			if(Rx_Vehicle_Weapon_Reloadable(weapon) != none &&
			Rx_Vehicle_Weapon_Reloadable(weapon).CurrentlyReloadingClientside) 
			
			return; 
			
			switch(FireModeNum)
			{
				case 0: //Primary Weapon trying to fire
				if(Rx_Vehicle_Multiweapon(weapon) != none && Rx_Vehicle_Multiweapon(weapon).CurrentlyReloadingClientside) return;
				break;
				
				case 1:
				if(Rx_Vehicle_Multiweapon(weapon) != none && Rx_Vehicle_Multiweapon(weapon).CurrentlyReloadingSecondaryClientside) return;
				break;
			}			
		
 	}		
 	if(Rx_Vehicle_Weapon_Reloadable(weapon) != None && Rx_Vehicle_Weapon_Reloadable(weapon).bCheckIfBarrelInsideWorldGeomBeforeFiring)
 	{
	 	FireStartLoc = GetPhysicalFireStartLoc(UTVehicleWeapon(weapon));
	 	if(!FastTrace(FireStartLoc,location))
		{
			UTVehicleWeapon(weapon).ClearPendingFire(UTVehicleWeapon(weapon).CurrentFireMode);
			return;
		}
	} 
	
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
	if(InstigatedBy != None && InstigatedBy.GetTeamNum() == GetTeamNum())
	{
		return;
	}
	if(Rx_Projectile(DamageCauser) != None && !Rx_Projectile(DamageCauser).isAirstrikeProjectile())
	{
		if(WorldInfo.NetMode != NM_DedicatedServer && InstigatedBy != None 
				&& InstigatedBy.Pawn != None
				&& (Rx_Weapon(InstigatedBy.Pawn.Weapon) != None || Rx_Vehicle_Weapon(InstigatedBy.Pawn.Weapon) != None)) 
		{	
			if(Health > 0 && self.GetTeamNum() != InstigatedBy.GetTeamNum() && UTPlayerController(InstigatedBy) != None)
			{
				Rx_Hud(UTPlayerController(InstigatedBy).myHud).ShowHitMarker();
			}

			if (Rx_Weapon_VoltAutoRifle(InstigatedBy.Pawn.Weapon) != None)
			{
				Rx_Weapon_VoltAutoRifle(InstigatedBy.Pawn.Weapon).ServerALRadiusDamageCharged(self,HurtOrigin,bFullDamage,class'Rx_Projectile_VoltBolt'.static.GetChargePercentFromDamage(BaseDamage));
			}
			else if(Rx_Weapon(InstigatedBy.Pawn.Weapon) != None)
			{
				Rx_Weapon(InstigatedBy.Pawn.Weapon).ServerALRadiusDamage(self,HurtOrigin,bFullDamage);
			} 
			else
			{
				Rx_Vehicle_Weapon(InstigatedBy.Pawn.Weapon).ServerALRadiusDamage(self,HurtOrigin,bFullDamage);
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

	PS = GetWeaponClassOfSeat(SeatIndex).default.BeamTemplates[SeatFiringMode(SeatIndex,,true)];
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

	if ( (HitActor == None) && (VSize(Location - HitLocation) > 10000) )
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

		if (!bViaReplication && GetSeatIndexForController(GetALocalPlayerController()) == SeatIndex)
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
	
	if(VSize(Velocity) > 120 && !IsInState('Stealthed') && !IsInState('BeenShot'))
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

simulated function rotator GetWeaponAim(UTVehicleWeapon VWeapon)
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

function ToggleTurretRotation()
{
}

function PancakeOther(Pawn Other)
{
	if(GetTeamNum() != 255 && GetTeamNum() != Other.GetTeamNum())
		Other.TakeDamage(10000, GetCollisionDamageInstigator(), Other.Location, Velocity * Other.Mass, CrushedDamageType);
}

simulated function string GetTargetedDescription(PlayerController PlayerPerspective)
{
	if (BoundPRI != None) 		
	{
		if (PlayerPerspective.PlayerReplicationInfo == BoundPRI)
		{
			if (bDriverLocked)
				return "Your Vehicle [Locked]";
			else
				return "Your Vehicle";
		}
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

reliable server function SetSpotted()
{
	bSpotted = true;
	SetTimer(10.0,false,'ResetSpotted');
}

function ResetSpotted()
{
	bSpotted = false;
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

function setBlinkingName()
{
	bBlinkingName = true;
	SetTimer(3.5,false,'DisableBlinkingName');
}

function DisableBlinkingName()
{
	bBlinkingName = false;	
}

simulated state DyingVehicle
{

	simulated function DoVehicleExplosion(bool bDoingSecondaryExplosion)
	{
		super.DoVehicleExplosion(bDoingSecondaryExplosion);
		Mesh.SetHidden(true);
		SetCollision(false,false); 
	}
}


DefaultProperties
{
	bRotateCameraUnderVehicle = true
    
	MinSprintSpeedMultiplier=1.0
	MaxSprintSpeedMultiplier=1.2
	SprintTimeInterval=1.0
	SprintSpeedIncrement=1.0
   
   
   Begin Object name=SVehicleMesh
		ScriptRigidBodyCollisionThreshold=100.0
    End Object	
   
   /**
    Begin Object name=SVehicleMesh
		RBChannel=RBCC_Vehicle
		RBCollideWithChannels=(Default=TRUE,BlockingVolume=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,Vehicle=TRUE)
		BlockActors=true
		BlockZeroExtent=true
		BlockRigidBody=true
		BlockNonzeroExtent=true
		CollideActors=true
		bForceDiscardRootMotion=true
		bUseSingleBodyPhysics=1
		bNotifyRigidBodyCollision=true
		ScriptRigidBodyCollisionThreshold=100.0
    End Object	
	
	
	Physics=PHYS_RigidBody
	bEdShouldSnap=true
	bStatic=false
	bCollideActors=true
	bCollideWorld=true
	bProjTarget=true
	bBlockActors=true
	bWorldGeometry=false
	bCanBeBaseForPawns=true
	bAlwaysRelevant=false
	RemoteRole=ROLE_SimulatedProxy
	bNetInitialRotation=true
	bBlocksTeleport=TRUE
	*/
	
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
	
	bCanStrafe=true
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

	ExplosionDamage=0
	ExplosionRadius=1

	RanOverDamageType=class'Rx_DmgType_RanOver'
	CrushedDamageType=class'Rx_DmgType_Pancake'

	EMPTime=6
	EMPDamage=1
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
}