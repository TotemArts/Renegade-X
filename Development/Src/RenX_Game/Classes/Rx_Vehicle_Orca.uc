/*********************************************************
*
* File: Rx_Vehicle_Orca.uc
* Author: RenegadeX-Team
* Poject: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/
class Rx_Vehicle_Orca extends Rx_Vehicle_Air
placeable;



var int missleBayToggle;

/** Firing sounds */
var() AudioComponent FiringAmbient;
var() SoundCue FiringStopSound;
var() SoundCue Snd_FiringAmbient_Heroic;

/** Extra Vehicle Sound stuff **/
var name TailRotorTriggerTag; 			// Is the same as "EngineStart"
var name TailRotorStopTag; 				// Is the same as "EngineStop"

var() AudioComponent TailRotorAmbient;	// The looping sound for the tailrotor
var() AudioComponent TailRotorStart;	// The start up sound for the tailrotor
var() AudioComponent TailRotorStop;		// The rev down sound for the tailrotor

var() AudioComponent LandingGearDeploy;			// The Landing gear Deploying Sound
var() AudioComponent LandingGearRetract;		// The Landing retracting Deploying Sound

var name GunCameraTag;

var array<int> JetEffectIndices;
var Rx_SkelControl_JetThruster JetControl;
var name JetScalingParam;

var SkelControlSingleBone TailRotor_Control;
var SkelControlSingleBone TailFlap_Control;
var SkelControlSingleBone TurbineTiltleft_Control;
var SkelControlSingleBone TurbineTiltRight_Control;

var (Rx_Vehicle_Orca) float StrafingFactor, TurningFactor, SprintingFactor;
var (Rx_Vehicle_Orca) float TailRotor_Speed, TailRotor_MaxAngle;

var bool CurrentlyLanding;	// Checks to see if the Orca is in the landing phase

var bool bLockedDirection; 

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if (Mesh != none && TailRotorAmbient != none)
	{
		Mesh.AttachComponentToSocket(TailRotorAmbient, 'TailRotorSocket');
		Mesh.AttachComponentToSocket(TailRotorStart, 'TailRotorSocket');
		Mesh.AttachComponentToSocket(TailRotorStop, 'TailRotorSocket');

		Mesh.AttachComponentToSocket(LandingGearDeploy, 'LandingGearSource');
		Mesh.AttachComponentToSocket(LandingGearRetract, 'LandingGearSource');
	}
	
	if (Mesh != None)
	{
		JetControl = Rx_SkelControl_JetThruster(Mesh.FindSkelControl('OrcaJet'));
		TailRotor_Control = SkelControlSingleBone(Mesh.FindSkelControl('TailRotor_Control'));
		TailFlap_Control = SkelControlSingleBone(Mesh.FindSkelControl('TailFlap_Control'));
		TurbineTiltleft_Control = SkelControlSingleBone(Mesh.FindSkelControl('TurbineTiltleft_Control'));
		TurbineTiltRight_Control = SkelControlSingleBone(Mesh.FindSkelControl('TurbineTiltRight_Control'));
	}
}

event Tick(float DeltaTime)
{
	local float JetParticleScale;
	local int i, JetIndex;
	
	super.tick(DeltaTime);

	if ( LastRenderTime > WorldInfo.TimeSeconds - 0.2 )
	{
		if ( JetControl != None )
		{
			JetParticleScale = FClamp(1.0-JetControl.ControlStrength, 0.2 , 1.0);
			for ( i=0; i<JetEffectIndices.Length; i++ )
			{
				JetIndex = JetEffectIndices[i];
				if ( JetIndex < VehicleEffects.Length && (VehicleEffects[JetIndex].EffectRef != None) )
				{
					VehicleEffects[JetIndex].EffectRef.SetFloatParameter(JetScalingParam, JetParticleScale);
				}
			}
			
		}
	
		// Establishes the rotation of the Tail Rotor
		if ( bDriving )
		{
			if ( Steering > 0.0f )
			{
				if ( StrafingFactor >= 1.0f ) // Clamps Steering Factor to 1.0
				{
					StrafingFactor = 1.0f;
				}
				else
				{
					StrafingFactor += TailRotor_Speed;
				}
			}
			if ( Steering < 0.0f )
			{
				if ( StrafingFactor <= -1.0f ) // Clamps Steering Factor to -1.0
				{
					StrafingFactor = -1.0f;
				}
				else
				{
					StrafingFactor -= TailRotor_Speed;
				}
			}
			
			if ( Steering == 0.0f )
			{
				StrafingFactor = StrafingFactor;
				if ( StrafingFactor > 0.0f ) // Subtracts until StrafingFactor is 0
				{
					StrafingFactor -= TailRotor_Speed;
				}
				if ( StrafingFactor < 0.0f ) // Adds until StrafingFactor is 0
				{
					StrafingFactor += TailRotor_Speed;
				}
				if ( StrafingFactor < TailRotor_Speed && StrafingFactor > -TailRotor_Speed ) // Set to 0 if close enough
				{
					StrafingFactor = 0.0f;
				}
			}

			if ( AngularVelocity.Z > 0.15f )
			{
				if ( TurningFactor >= 1.0f ) // Clamps Steering Factor to 1.0
				{
					TurningFactor = 1.0f;
				}
				else
				{
					TurningFactor += ((TailRotor_Speed*1.0f) * Abs(AngularVelocity.Z));
				}
			}
			if ( AngularVelocity.Z < -0.15f )
			{
				if ( TurningFactor <= -1.0f ) // Clamps Steering Factor to -1.0
				{
					TurningFactor = -1.0f;
				}
				else
				{
					TurningFactor -= ((TailRotor_Speed*1.0f) * Abs(AngularVelocity.Z));
				}
			}
			
			if ( Abs(AngularVelocity.Z) < 0.15f )
			{
				TurningFactor = TurningFactor;
				if ( TurningFactor > 0.0f ) // Subtracts until TurningFactor is 0
				{
					TurningFactor -= ((TailRotor_Speed*1.0f)*0.5f);
				}
				if ( TurningFactor < 0.0f ) // Adds until TurningFactor is 0
				{
					TurningFactor += ((TailRotor_Speed*1.0f)*0.5f);
				}
				if ( Abs(TurningFactor) < 0.07f ) // Set to 0 if close enough
				{
					TurningFactor = 0.0f;
				}
			}
			
			if (bSprinting)
			{
				if ( SprintingFactor >= 1.0f ) // Clamps Sprinting Factor to 1.0
				{
					SprintingFactor = 1.0f;
				}
				else
				{
					SprintingFactor += 0.02f;
				}
			}
			else
			{
				if ( SprintingFactor <= 0.0f ) // Clamps Sprinting Factor to 0.0
				{
					SprintingFactor = 0.0f;
				}
				else
				{
					SprintingFactor -= 0.02f;
				}
			}
			
			
			// Define Tail Rotor roll Rotation
			TailRotor_Control.BoneRotation.Roll = ((-(TailRotor_MaxAngle-(SprintingFactor * (TailRotor_MaxAngle * 0.75f))) * 182.0)* FClamp((((TurningFactor * 2.0f) + (StrafingFactor * 2.0f))*0.5), -1.0f, 1.0f));
			
			// Define Tail Flap Yaw Rotation
			TailFlap_Control.BoneRotation.Yaw = ((-(50.0f-(SprintingFactor * (50.0f * 0.75f))) * 182.0)* TurningFactor);
			
			// Define Left Turbine Strafing
			TurbineTiltleft_Control.BoneRotation.Roll = ((-(40.0f-(SprintingFactor * (40.0f * 0.75f))) * 182.0)* Abs(FClamp((((TurningFactor * 2.0f) + (StrafingFactor * 2.0f))*0.25), -1.0f, 1.0f)));
			
			// Define Right Turbine Strafing
			TurbineTiltRight_Control.BoneRotation.Roll = ((-(40.0f-(SprintingFactor * (40.0f * 0.75f))) * 182.0)* -Abs(FClamp((((TurningFactor * 2.0f) + (StrafingFactor * 2.0f))*0.25), -1.0f, 1.0f)));
		}
		else
		{
			// Define Tail Rotor roll Rotation
			TailRotor_Control.BoneRotation.Roll = 0.0f;
			
			// Define Tail Flap Yaw Rotation
			TailFlap_Control.BoneRotation.Yaw = 0.0f;
			
			// Define Left Turbine Strafing
			TurbineTiltleft_Control.BoneRotation.Roll = 0.0f;
			
			// Define Right Turbine Strafing
			TurbineTiltRight_Control.BoneRotation.Roll = 0.0f;
		}


	}
}




function ToggleCam()
{
	if(fpCamera)
	{
		fpCamera = false;
		Seats[0].CameraTag = tpCameraTag;
		OldPositions.Length=0;
		//Mesh.SetHidden(false);
		//Driver.Mesh.SetHidden(false);
		UTPlayercontroller(Controller).setFOV(85);
	}
	else
	{
		fpCamera = true;
		Seats[0].CameraTag = GunCameraTag;
		//Mesh.SetHidden(true);
		//Driver.Mesh.SetHidden(true);
		UTPlayercontroller(Controller).setFOV(50);
	}
}

simulated function VehicleEvent(name EventTag)
{
	super.VehicleEvent(EventTag);

	if (TailRotorTriggerTag == EventTag)
	{
		TailRotorStart.Play();
		SetTimer(1.22, false, 'PlayTailRotorSound');
		SetTimer(1.0, false, 'BeginLandingGearRetract');
	}
		
	if (TailRotorStopTag == EventTag)
	{
		TailRotorAmbient.Stop();
		TailRotorStop.Play();
	}
}

function PlayTailRotorSound()
{
	TailRotorAmbient.Play();
}

function GotoIdleEvent()
{
	VehicleEvent('Idle');
}



simulated function VehicleWeaponFireEffects(vector HitLocation, int SeatIndex)
{  

	if (SeatFiringMode(0,,true) == 1)
	{
		VehicleEvent('GunFire');

		if (!FiringAmbient.bWasPlaying)
		{
			FiringAmbient.Play();
		}
	}
	else if (SeatFiringMode(0,,true) == 0)
	{
		if (GetBarrelIndex(SeatIndex) == 2)
		{
			VehicleEvent('FireLeft');
		}
		else if (GetBarrelIndex(SeatIndex) == 1)
		{
			VehicleEvent('FireRight');
		}

	}

}
    
simulated function VehicleWeaponFired( bool bViaReplication, vector HitLocation, int SeatIndex )
{
	if(SeatIndex == 0) {
		super.VehicleWeaponFired(bViaReplication,HitLocation,SeatIndex);
	}
	
	// toggle missle bays
	missleBayToggle = missleBayToggle == 1 ? 2 : 1;
	
}

simulated function VehicleWeaponStoppedFiring( bool bViaReplication, int SeatIndex )
{
	if(SeatIndex == 0) {
		super.VehicleWeaponStoppedFiring(bViaReplication,SeatIndex);
	}
    
    // Trigger any vehicle Firing Effects
	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		if (Role == ROLE_Authority || bViaReplication || WorldInfo.NetMode == NM_Client)
		{
			VehicleEvent('STOP_GunFire');
		}
	}

	if(SeatFiringMode(0,, true) == 1)
    {
    	PlaySound(FiringStopSound, TRUE, FALSE, FALSE, Location, FALSE);
    }
	FiringAmbient.Stop();
}


//================================================
// COPIED from RxVehicle_MammothTank
// Attribute of a multi weapon vehicle, this code correctly identifies 
// the propper firing socket
//================================================
simulated function vector GetEffectLocation(int SeatIndex)
{
	local vector SocketLocation;
	local name FireTriggerTag;

	if ( Seats[SeatIndex].GunSocket.Length <= 0 )
		return Location;
	
	FireTriggerTag = Seats[SeatIndex].GunSocket[GetBarrelIndex(SeatIndex)];

	Mesh.GetSocketWorldLocationAndRotation(FireTriggerTag, SocketLocation);

	return SocketLocation;
}


// Modified from the mammoth source to use missleBayToggle
// which switches between the 2 available missle bays
simulated function int GetBarrelIndex(int SeatIndex)
{
	local int OldBarrelIndex;
    
	OldBarrelIndex = super.GetBarrelIndex(SeatIndex);
	if (Weapon == none)
		return OldBarrelIndex;

	return (Weapon.CurrentFireMode == 1 ? 0 : missleBayToggle);
}


simulated function SetDriving(bool bNewDriving)
{
	if (bAutoLand && !bNewDriving && !bEMPd && !bChassisTouchingGround && Health > 0)
	{
		if (Role == ROLE_Authority)
		{
			GotoState('AutoLanding');
		}
	}
	else
	{
		Super.SetDriving(bNewDriving);
		// BeginLandingGearRetract();
	}
}


/** state to automatically land when player jumps out while high above land */
state AutoLanding
{
	simulated function SetDriving(bool bNewDriving)
	{
		if ( bNewDriving )
		{
			GotoState('Auto');
			Global.SetDriving(bNewDriving);
		}
	}

	function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
	{
		if (Global.Died(Killer, DamageType, HitLocation))
		{
			SetDriving(false);
			return true;
		}
		else
		{
			return false;
		}
	}

	function Tick(float DeltaTime)
	{
		local actor HitActor;
		local vector HitNormal, HitLocation;

		if (bChassisTouchingGround)
		{
			GotoState('Auto');
			SetDriving(false);
			VehicleEvent('Landed');
		}
		else
		{
			if ( SprintingFactor > 0.0f )
				SprintingFactor -= 0.02f;
			else if ( SprintingFactor < 0.0f )
				SprintingFactor += 0.02f;
			else
				SprintingFactor = 0.0f;
				
			if ( StrafingFactor > 0.0f )
				StrafingFactor -= TailRotor_Speed;
			else if ( StrafingFactor < 0.0f )
				StrafingFactor += TailRotor_Speed;
			else
				SprintingFactor = 0.0f;
					
			if ( TurningFactor > 0.0f )
				TurningFactor -= ((TailRotor_Speed*1.0f)*0.5f);
			else if ( TurningFactor < 0.0f )
				TurningFactor += ((TailRotor_Speed*1.0f)*0.5f);
			else
				SprintingFactor = 0.0f;
			
			TailRotor_Control.BoneRotation.Roll = ((-(TailRotor_MaxAngle-(SprintingFactor * (TailRotor_MaxAngle * 0.75f))) * 182.0)* FClamp((((TurningFactor * 2.0f) + (StrafingFactor * 2.0f))*0.5), -1.0f, 1.0f));
			TailFlap_Control.BoneRotation.Yaw = ((-(50.0f-(SprintingFactor * (50.0f * 0.75f))) * 182.0)* TurningFactor);
			TurbineTiltleft_Control.BoneRotation.Roll = ((-(40.0f-(SprintingFactor * (40.0f * 0.75f))) * 182.0)* Abs(FClamp((((TurningFactor * 2.0f) + (StrafingFactor * 2.0f))*0.25), -1.0f, 1.0f)));
			TurbineTiltRight_Control.BoneRotation.Roll = ((-(40.0f-(SprintingFactor * (40.0f * 0.75f))) * 182.0)* -Abs(FClamp((((TurningFactor * 2.0f) + (StrafingFactor * 2.0f))*0.25), -1.0f, 1.0f)));
			
			HitActor = Trace(HitLocation, HitNormal, Location - vect(0,0,2500), Location, false);
			if ( Velocity.Z < -1200 )
			OutputRise = 1.0;
			else if ( HitActor == None )
			OutputRise = -1.0;
			else if ( VSize(HitLocation - Location) < -2*Velocity.Z )
			{
				if ( Velocity.Z > -100 )
				OutputRise = 0;
				else
				{
					OutputRise = 1.0;
					BeginLandingGearDeploy();
				}
			}
			else if ( Velocity.Z > -500 )
			OutputRise = -0.4;
			else
			OutputRise = -0.1;
		}
	}
}


simulated function BeginLandingGearDeploy()
{
	if (CurrentlyLanding == false)
	{
		VehicleEvent('DeployLandingGear');
		LandingGearDeploy.Play();
		CurrentlyLanding=true;
	}
}

simulated function BeginLandingGearRetract()
{
	
	VehicleEvent('RetractLandingGear');
	LandingGearRetract.Play();
	CurrentlyLanding=false;
}

simulated function SetHeroicMuzzleFlash(bool SetTrue)
 {
	
	if(SetTrue) FiringAmbient.SoundCue=Snd_FiringAmbient_Heroic;
	else
	FiringAmbient.SoundCue=FiringAmbient.default.SoundCue; 
	super.SetHeroicMuzzleFlash(SetTrue);
 }


/*

//==============================================\\
// ALTERNATE HALO BANSHEE STYLE FLIGHT CONTROLS \\
//==============================================\\

simulated function SetInputs(float InForward, float InStrafe, float InUp)
{
    local bool bReverseThrottle;
    local UTConsolePlayerController ConsolePC;
    local rotator SteerRot, VehicleRot;
    local vector SteerDir, VehicleDir; // , AngVel
    local float VehicleHeading, SteerHeading, DeltaTargetHeading, Deflection;

    Throttle = InForward;
	Steering = InStrafe;
	Rise = InUp;

	ConsolePC = UTConsolePlayerController(Controller);

    if (InForward > 0)
    {
		Throttle = 1;
    }

    if (InForward < 0)
    {
		Throttle = -1;
    }


    ConsolePC = UTConsolePlayerController(Controller);
    if (ConsolePC != None)
    {
        Steering = FClamp(Steering * ConsoleSteerScale, -1.0, 1.0);

        UpdateLookSteerStatus();

        // tank, wheeled / heavy vehicles will use this

        // If we desire 'look steering' on this vehicle, do it here.
//        if (bUsingLookSteer && IsHumanControlled())
//        {
            // If there is a deflection, look at the angle that its point in.
            Deflection = Sqrt(Throttle*Throttle + Steering*Steering);

            if(bStickDeflectionThrottle)
            {
                // The region we consider 'reverse' is anything below DeflectionReverseThresh, or anything withing the triangle below the center position.
                bReverseThrottle = ((Throttle < DeflectionReverseThresh) || (Throttle < 0.0 && Abs(Steering) < -Throttle));
                
				Deflection = Sqrt(Throttle*Throttle + Steering*Steering);
				Throttle = Deflection;

                if (bReverseThrottle)
                {
                    Throttle *= -1;
                }
            }
			

            VehicleRot.Yaw = Rotation.Yaw;
            VehicleDir = vector(VehicleRot);

            SteerRot.Yaw = DriverViewYaw;
            SteerRot.Pitch = DriverViewPitch;
            SteerDir = vector(SteerRot);

            VehicleHeading = GetHeadingAngle(VehicleDir);
            SteerHeading = GetHeadingAngle(SteerDir);
            DeltaTargetHeading = FindDeltaAngle(SteerHeading, VehicleHeading);
			

            if (DeltaTargetHeading > LookSteerDeadZone)
            {
                Steering = FMin((DeltaTargetHeading - LookSteerDeadZone) * LookSteerSensitivity, 1.0);
                // Rise = FMin((DeltaTargetHeading - LookSteerDeadZone) * LookSteerSensitivity, 1.0);
            }
            else if (DeltaTargetHeading < -LookSteerDeadZone)
            {
                Steering = FMax((DeltaTargetHeading + LookSteerDeadZone) * LookSteerSensitivity, -1.0);
                // Rise = FMax((DeltaTargetHeading + LookSteerDeadZone) * LookSteerSensitivity, -1.0);
            }
            else
            {
                Steering = 0.0;
            }
			
			
        // Reverse steering when reversing
            if (Throttle < 0.0 && ForwardVel < 0.0)
            {
                Steering = -1.0 * Steering;
            }
//		}
        // `log( "Throttle: " $ Throttle $ " Steering: " $ Steering );
    }
}

*/

/*
reliable server function ServerChangeSeat(int RequestedSeat)
{
	if ( RequestedSeat == 1 && Driver != None)
		return;
	super.ServerChangeSeat(RequestedSeat);
}
*/

defaultproperties
{
	MaxDesireability = 0.8
    
	missleBayToggle = 0;
	ExitRadius=150.0

    // Helicopter Phyics
	Begin Object Class=UDKVehicleSimChopper Name=SimObject
		MaxThrustForce=700.0
		MaxReverseForce=500.0
		LongDamping=0.5
		MaxStrafeForce=400.0
		LatDamping=0.5
		MaxRiseForce=300.0
		UpDamping=0.6
		TurnTorqueFactor=9000.0
		TurnTorqueMax=10000.0
		TurnDamping=1.0
		MaxYawRate=1.25
		PitchTorqueFactor=2000.0
		PitchTorqueMax=300.0
		PitchDamping=0.5
		RollTorqueTurnFactor=8500.0
		RollTorqueStrafeFactor=750.0
		RollTorqueMax=3000.0
		RollDamping=1.0
		MaxRandForce=30.0
		RandForceInterval=0.5
		StopThreshold=10
		bAllowZThrust False
		bFullThrustOnDirectionChange False
		bShouldCutThrustMaxOnImpact=true
		bStabilizeStops=false
	End Object
	SimObj=SimObject
	Components.Add(SimObject)

	Health=400
	bLightArmor=false
	bisAirCraft=true
	bFollowLookDir=false

	COMOffset=(X=50,Z=-50.0)

	BaseEyeheight=0
	Eyeheight=0
	bRotateCameraUnderVehicle=false
	CameraLag=0.2
	LookForwardDist=290.0
	bLimitCameraZLookingUp=true

	AirSpeed=700.0
	MaxSpeed=1000.0
	GroundSpeed=1100.0

	MinSprintSpeedMultiplier=1.0
	MaxSprintSpeedMultiplier=1.14
	SprintTimeInterval=1.0
	SprintSpeedIncrement=1.0

	/************************/
	/*Veterancy Multipliers*/
	/***********************/
	
	Snd_FiringAmbient_Heroic = SoundCue'RX_VH_Orca.Sounds.SC_Orca_Gun_Looping_Heroic'
	
	//VP Given on death (by VRank)
	VPReward(0) = 8 
	VPReward(1) = 10 
	VPReward(2) = 12 
	VPReward(3) = 16 
	
	VPCost(0) = 30
	VPCost(1) = 70
	VPCost(2) = 150
	
	Vet_HealthMod(0)=1 //400
	Vet_HealthMod(1)=1.125 //450
	Vet_HealthMod(2)=1.25 //500
	Vet_HealthMod(3)=1.5 //650 
	
	Vet_SprintSpeedMod(0)=1.0
	Vet_SprintSpeedMod(1)=1.05
	Vet_SprintSpeedMod(2)=1.10
	Vet_SprintSpeedMod(3)=1.15
	
	/**********************/
	
	bStayUpright=true
	StayUprightRollResistAngle=5.0
	StayUprightPitchResistAngle=5.0
	StayUprightStiffness=1200
	StayUprightDamping=20

	SpawnRadius=180.0
	RespawnTime=5.0

	PushForce=50000.0
	HUDExtent=140.0

	HornIndex=1
	
	CustomGravityScaling=1.0	// 0.35
	
	SeekAimAheadModifier = 180
	SeekAccelrateModifier = 16

	GunCameraTag=CamViewGun

//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\

	Begin Object Name=CollisionCylinder
        //CollisionHeight=+200.0
		CollisionRadius=+300.0
		Translation=(X=-40.0,Y=0.0,Z=40.0)
	End Object

	Begin Object name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'RX_VH_Orca.Mesh.SK_VH_Orca'
		AnimTreeTemplate=AnimTree'RX_VH_Orca.Anims.AT_VH_Orca'
		AnimSets.Add(AnimSet'RX_VH_Orca.Anims.AS_VH_Orca')
		PhysicsAsset=PhysicsAsset'RX_VH_Orca.Mesh.SK_VH_Orca_Physics'
		MorphSets[0]=MorphTargetSet'RX_VH_Orca.Mesh.MT_VH_Orca'
	End Object

	DrawScale=1.0
	
	SkeletalMeshForPT=SkeletalMesh'RX_VH_Orca.Mesh.SK_PTVH_Orca'

	VehicleIconTexture=Texture2D'RX_VH_Orca.UI.T_VehicleIcon_Orca'
	MinimapIconTexture=Texture2D'RX_VH_Orca.UI.T_MinimapIcon_Orca'


//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\

	Seats(0)={( GunClass=class'Rx_Vehicle_Orca_Weapon',
                GunSocket=("GunSocket","Missile_Left","Missile_Right"),
                TurretControls=(TurretPitch,TurretRotate,MissilePitch,MissileRotate),
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=25),
                CameraOffset=-450, //-700,
                SeatIconPos=(X=0.5,Y=0.33),
                bSeatVisible=true,
                SeatBone=b_DriverLocation,
                SeatSocket=DriverSocket,
                SeatOffset=(X=0,Y=0,Z=0),
                SeatRotation=(Pitch=0,Yaw=0),
                MuzzleFlashLightClass=class'RenX_Game.Rx_Light_Tank_MuzzleFlash'
		)}
				
	Seats(1)={( // GunClass=class'Rx_Vehicle_Orca_Passenger_Weapon',
				// TurretVarPrefix="Passenger",
                // GunSocket=("Missile_Left","Missile_Right"),
                CameraTag=CamView3P,
                CameraBaseOffset=(Z=-50),
                CameraOffset=-600,
                bSeatVisible=false,
                SeatBone=b_DriverLocation,
                SeatSocket=PassengerSocket,
                SeatOffset=(X=59,Y=0,Z=-18),
                SeatRotation=(Pitch=0,Yaw=0),
				// MuzzleFlashLightClass=class'RenX_Game.Rx_Light_Tank_MuzzleFlash'
				// WeaponEffects=((SocketName=HellFireMissile_Left),(SocketName=HellFireMissile_Right))
		)}
            
	DrivingAnim=H_M_Seat_Orca



//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


	BurnOutMaterial[0]=MaterialInstanceConstant'RX_VH_Orca.Materials.MI_VH_Orca_BO'
	BurnOutMaterial[1]=MaterialInstanceConstant'RX_VH_Orca.Materials.MI_VH_Orca_BO'

	DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_Orca.Materials.PhysMat_Orca_Driving'
	DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_Orca.Materials.PhysMat_Orca'

	RecoilTriggerTag = "GunFire"
	TailRotorTriggerTag = "EngineStart"
	TailRotorStopTag = "EngineStop"
	VehicleEffects(0)=(EffectStartTag="GunFire",EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_MuzzleFlash_Gun',EffectSocket="GunSocket")
	VehicleEffects(1)=(EffectStartTag="FireLeft",EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_MuzzleFlash_Missiles',EffectSocket="Missile_Left")
	VehicleEffects(2)=(EffectStartTag="FireRight",EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_MuzzleFlash_Missiles',EffectSocket="Missile_Right")
	
	VehicleEffects(3)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_TurbineJet',EffectSocket=TurbineJetSocket_R)
	VehicleEffects(4)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_TurbineJet',EffectSocket=TurbineJetSocket_L)
    
	VehicleEffects(5)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_EngineFire',EffectSocket=DamageFire_01)
	VehicleEffects(6)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_EngineFire',EffectSocket=DamageFire_02)
	VehicleEffects(7)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke',EffectSocket=DamageSmoke_01)
	VehicleEffects(8)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke',EffectSocket=DamageSmoke_02)

	VehicleEffects(9)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_Exhaust',EffectSocket=Exhaust_L)
	VehicleEffects(10)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_Exhaust',EffectSocket=Exhaust_R)

	VehicleEffects(11)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_GroundEffect',EffectSocket=GroundEffectSocket_R)
	VehicleEffects(12)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_GroundEffect',EffectSocket=GroundEffectSocket_L)
	
	VehicleEffects(13)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_WingTip',EffectSocket=WingTipA)
	VehicleEffects(14)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_WingTip',EffectSocket=WingTipB)
	VehicleEffects(15)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_WingTip',EffectSocket=WingTipC)
	VehicleEffects(16)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_WingTip',EffectSocket=WingTipD)
	
	VehicleEffects(17)=(EffectStartTag=SprintStart,EffectEndTag=SprintStop,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_Engine_Boost',EffectSocket=TurbineJetSocket_L)
	VehicleEffects(18)=(EffectStartTag=SprintStart,EffectEndTag=SprintStop,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_Engine_Boost',EffectSocket=TurbineJetSocket_R)
	
	VehicleEffects(19)=(EffectStartTag=EngineStop,EffectEndTag=none,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_TurbineJet_End',EffectSocket=TurbineJetSocket_R)
	VehicleEffects(20)=(EffectStartTag=EngineStop,EffectEndTag=none,EffectTemplate=ParticleSystem'RX_VH_Orca.Effects.P_TurbineJet_End',EffectSocket=TurbineJetSocket_L)
	
	VehicleAnims(0)=(AnimTag=Idle,AnimSeqs=(Idle_Flying),AnimRate=1.0,bAnimLoopLastSeq=true,AnimPlayerName=AnimPlayer)
	VehicleAnims(1)=(AnimTag=DeployLandingGear,AnimSeqs=(Landing),AnimRate=1.0,bAnimLoopLastSeq=false,AnimPlayerName=AnimPlayer)
	VehicleAnims(2)=(AnimTag=EngineStop,AnimSeqs=(Idle_Empty),AnimRate=1.0,bAnimLoopLastSeq=false,AnimPlayerName=AnimPlayer)
	VehicleAnims(3)=(AnimTag=RetractLandingGear,AnimSeqs=(TakeOff),AnimRate=0.5,bAnimLoopLastSeq=false,AnimPlayerName=AnimPlayer)
	VehicleAnims(4)=(AnimTag=Landed,AnimSeqs=(Idle_Empty),AnimRate=1.0,bAnimLoopLastSeq=false,AnimPlayerName=AnimPlayer)
	
	JetScalingParam=JetParticleScale
	JetEffectIndices=(3,4)
	TailRotor_Speed = 0.035
	TailRotor_MaxAngle = 65.0

	BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle_Air')
	BigExplosionSocket=VH_Death
	SecondaryExplosion=ParticleSystem'RX_VH_Orca.Effects.P_Explosion_Vehicle'
	
	DamageMorphTargets(0)=(InfluenceBone=b_Gun_Yaw,MorphNodeName=MorphNodeW_F,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage2))
	DamageMorphTargets(1)=(InfluenceBone=b_TailRotor_Base,MorphNodeName=MorphNodeW_B,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage1))
	DamageMorphTargets(2)=(InfluenceBone=b_Turbine_Propeller_L,MorphNodeName=MorphNodeW_L,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage3))
	DamageMorphTargets(3)=(InfluenceBone=b_Turbine_Propeller_R,MorphNodeName=MorphNodeW_R,LinkedMorphNodeName=none,Health=100,DamagePropNames=(Damage4))

	DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=4.0)
	DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=4.0)
	DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=8.0)
	DamageParamScaleLevels(3)=(DamageParamName=Damage4,Scale=1.5)


//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\

	Begin Object Class=AudioComponent Name=ScorpionEngineSound
		SoundCue=SoundCue'RX_VH_Orca.Sounds.SC_Orca_Idle'
	End Object
	EngineSound=ScorpionEngineSound
	Components.Add(ScorpionEngineSound);

	EnterVehicleSound=SoundCue'RX_VH_Orca.Sounds.SC_Orca_Start'
	ExitVehicleSound=SoundCue'RX_VH_Orca.Sounds.SC_Orca_Stop'
	
	Begin Object Class=AudioComponent name=FiringmbientSoundComponent
		bShouldRemainActiveIfDropped=true
		bStopWhenOwnerDestroyed=true
		SoundCue=SoundCue'RX_VH_Orca.Sounds.SC_Orca_Gun_Looping'
	End Object
	FiringAmbient=FiringmbientSoundComponent
	Components.Add(FiringmbientSoundComponent)
    
	FiringStopSound=SoundCue'RX_VH_Humvee.Sounds.SC_Humvee_Fire_Stop'
	
	SprintBoostSound=SoundCue'RX_VH_Orca.Sounds.SC_Orca_Boost'
	SprintStopSound=SoundCue'RX_VH_Orca.Sounds.SC_Orca_BoostEnd'

    // Scrape sound.
	Begin Object Class=AudioComponent Name=BaseScrapeSound
		SoundCue=SoundCue'A_Gameplay.A_Gameplay_Onslaught_MetalScrape01Cue'
	End Object
	ScrapeSound=BaseScrapeSound
	Components.Add(BaseScrapeSound);

    // Initialize sound parameters.
	EngineStartOffsetSecs=3.34
	EngineStopOffsetSecs=0.0
	
	
	Begin Object Class=AudioComponent name=TailRotorAmbientSoundComponent
		bShouldRemainActiveIfDropped=true
		bStopWhenOwnerDestroyed=true
		SoundCue=SoundCue'RX_VH_Orca.Sounds.SC_TailRotor_Idle'
	End Object
	TailRotorAmbient=TailRotorAmbientSoundComponent
	Components.Add(TailRotorAmbientSoundComponent)
	
	Begin Object Class=AudioComponent name=TailRotorStartSoundComponent
		bShouldRemainActiveIfDropped=true
		bStopWhenOwnerDestroyed=true
		SoundCue=SoundCue'RX_VH_Orca.Sounds.SC_TailRotor_Start'
	End Object
	TailRotorStart=TailRotorStartSoundComponent
	Components.Add(TailRotorStartSoundComponent)
	
	Begin Object Class=AudioComponent name=TailRotorStopSoundComponent
		bShouldRemainActiveIfDropped=true
		bStopWhenOwnerDestroyed=true
		SoundCue=SoundCue'RX_VH_Orca.Sounds.SC_TailRotor_Stop'
	End Object
	TailRotorStop=TailRotorStopSoundComponent
	Components.Add(TailRotorStopSoundComponent)	
	
	Begin Object Class=AudioComponent name=LandingGearDeploySoundComponent
		bShouldRemainActiveIfDropped=true
		bStopWhenOwnerDestroyed=true
		SoundCue=SoundCue'RX_VH_Orca.Sounds.SC_LandingGear_Deploy'
	End Object
	LandingGearDeploy=LandingGearDeploySoundComponent
	Components.Add(LandingGearDeploySoundComponent)
	
	Begin Object Class=AudioComponent name=LandingGearRetractSoundComponent
		bShouldRemainActiveIfDropped=true
		bStopWhenOwnerDestroyed=true
		SoundCue=SoundCue'RX_VH_Orca.Sounds.SC_LandingGear_Retract'
	End Object
	LandingGearRetract=LandingGearRetractSoundComponent
	Components.Add(LandingGearRetractSoundComponent)	
		
}