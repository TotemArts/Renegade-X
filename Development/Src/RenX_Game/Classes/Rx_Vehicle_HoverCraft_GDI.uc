/*********************************************************
*
* File: Rx_Vehicle_HoverCraft_GDI.uc
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
class Rx_Vehicle_HoverCraft_GDI extends Rx_Vehicle
	placeable;
	

	
	
	
	
	


enum EDeployState
{
	EDS_Undeployed,
	EDS_Deploying,
	EDS_AbortDeploying,
	EDS_Deployed,
	EDS_UnDeploying,
};

/** If true, this SPMA is deployed */
var	repnotify 	EDeployState	DeployedState;


/** How long does it take to deploy */
var float	DeployTime;

/** How long does it take to undeploy */
var float	UnDeployTime;

var float	LastDeployStartTime;

/** Helper to allow quick access to playing deploy animations */
var AnimNodeSequence	AnimPlay;

/** Animations */

var name GetInAnim[2];
var name GetOutAnim[2];
var name IdleAnim[2];
var name DeployAnim[2];

/** Sounds */

var SoundCue DeploySound;
var SoundCue UndeploySound;

var AudioComponent DeploySoundComp;

var SoundCue DeployedEnterSound;
var SoundCue DeployedExitSound;

var(Deploy) float MaxDeploySpeed;
var(Deploy) bool bRequireAllWheelsOnGround;
var(Deploy) bool bAllowAbortDeploy;

/** Check on timer to see if we can deploy/draw tool tip */
var bool bDrawCanDeployTooltip;

/** Time stamp for last deploy check */
var float TimeSinceLastDeployCheck;

/** Coordinates for the tooltip textures */
var UIRoot.TextureCoordinates ToolTipIconCoords;


var float DeployIconOffset;

/** Set if no acceptable artillery target found */
var bool bNotGoodArtilleryPosition;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

replication
{
	if( bNetDirty && (Role==ROLE_Authority) )
		DeployedState;
}

/**
 * Play an animation with an optional total time
 */
simulated function PlayAnim(name AnimName, optional float AnimDuration = 0.0f)
{
	local float AnimRate;
	if (AnimPlay != none && AnimName != '')
	{
		AnimRate = 1.0f;
		AnimPlay.SetAnim(AnimName);
		if(AnimPlay.AnimSeq != none)
		{
			if (AnimDuration > 0.0f)
			{
				AnimRate = AnimPlay.AnimSeq.SequenceLength / AnimDuration;
			}
			AnimPlay.PlayAnim(false, AnimRate, 0.0);
		}
	}
}

simulated function StopAnim()
{
	if (AnimPlay != none)
	{
		AnimPlay.StopAnim();
	}
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	AnimPlay = AnimNodeSequence( Mesh.Animations.FindAnimNode('AnimPlayer') );
	PlayAnim( IdleAnim[0] );
}

/**
 * Play the ambients when an action anim finishes
 */
simulated function OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	if ( DeployedState == EDS_Undeployed )
	{
		if (Driver != none)
		{
			PlayAnim(IdleAnim[1]);
		}
		else
		{
			PlayAnim(IdleAnim[0]);
		}
	}
}

function bool ShouldDeployToAttack()
{
	return true;
}

function bool CanDeployedAttack(Actor Other)
{
	return CanAttack(Other);
}

simulated function DisplayHud(UTHud Hud, Canvas Canvas, vector2D HudPOS, optional int SeatIndex)
{
	local PlayerController PC;
	local int i;
	super.DisplayHud(HUD, Canvas, HudPOS, SeatIndex);
	if (bDrawCanDeployTooltip)
	{
		for (i=0; i<Seats.length; i++)
		{
			if (Seats[i].SeatPawn != None)
			{
				PC = PlayerController(Seats[i].SeatPawn.Controller);
				if (PC != none)
				{
					if (bHasWeaponBar)
					{
						Hud.DrawToolTip(Canvas, PC, "GBA_Jump", Canvas.ClipX * 0.5, Canvas.ClipY * 0.82, ToolTipIconCoords.U, ToolTipIconCoords.V, ToolTipIconCoords.UL, ToolTipIconCoords.VL, Canvas.ClipY / 768);
					}
					else
					{
						Hud.DrawToolTip(Canvas, PC, "GBA_Jump", Canvas.ClipX * 0.5, Canvas.ClipY * DeployIconOffset, ToolTipIconCoords.U, ToolTipIconCoords.V, ToolTipIconCoords.UL, ToolTipIconCoords.VL, Canvas.ClipY / 768);
					}
				}
			}
		}
	}
}

/**
 * Play Enter Animations
 */
simulated function AttachDriver( Pawn P )
{
	Super.AttachDriver(P);

	if ( DeployedState == EDS_Undeployed )
	{
		PlayAnim( GetInAnim[0] );
	}
	else
	{
		PlayAnim( GetInAnim[1] );
	}
}

/**
 * Play Exit Animation
 */
simulated function DetachDriver( Pawn P )
{
	Super.DetachDriver(P);

	if ( DeployedState == EDS_Undeployed )
	{
		PlayAnim( GetOutAnim[0] );
	}
	else
	{
		PlayAnim( GetOutAnim[1] );
	}
}

// Accessor to change the deployed state.  It ensures all the needed function calls are made
function ChangeDeployState(EDeployState NewState)
{
	DeployedState = NewState;
	DeployedStateChanged();
}


simulated function DeployedStateChanged()
{
	local int i;
	local float TimeIntoDeploy, NewRate;

	switch (DeployedState)
	{
		case EDS_Deploying:
			LastDeployStartTime = WorldInfo.TimeSeconds;
			VehicleEvent('StartDeploy');
			VehiclePlayExitSound();
			SetVehicleDeployed();
			PlayAnim(DeployAnim[0], DeployTime);
			if ( DeploySound != none )
			{
				if(DeploySoundComp == None)
				{
					DeploySoundComp = CreateAudioComponent(DeploySound, TRUE, TRUE, TRUE, Location, TRUE);
				}
				else
				{
					DeploySoundComp.SoundCue = DeploySound;
					DeploySoundComp.Play();
				}
			}
			break;

		case EDS_AbortDeploying:
			TimeIntoDeploy = WorldInfo.TimeSeconds - LastDeployStartTime;
			NewRate = -1.0 * (AnimPlay.CurrentTime/TimeIntoDeploy);
			AnimPlay.PlayAnim(FALSE, NewRate, AnimPlay.CurrentTime);
			if(DeploySoundComp != None)
			{
				DeploySoundComp.Stop();
			}

			if(DeploySoundComp == None)
			{
				DeploySoundComp = CreateAudioComponent(UndeploySound, TRUE, TRUE, TRUE, Location, TRUE);
			}
			else
			{
				DeploySoundComp.SoundCue = UndeploySound;
				DeploySoundComp.Play();
			}

			break;

		case EDS_Deployed:
			VehicleEvent('Deployed');
			AnimPlay.SetAnim(DeployAnim[0]);
			AnimPlay.StopAnim();
			AnimPlay.SetPosition(AnimPlay.AnimSeq.SequenceLength, false);
			for (i = 0; i < Seats.length; i++)
			{

			}
			if(DeploySoundComp != None)
			{
				DeploySoundComp.Stop();
			}
			break;

		case EDS_UnDeploying:
			LastDeployStartTime = WorldInfo.TimeSeconds;
			VehicleEvent('StartUnDeploy');
			PlayAnim(DeployAnim[1], UnDeployTime);
			SetVehicleUndeploying();
			if ( UndeploySound != none )
			{
				if(DeploySoundComp == None)
				{
					DeploySoundComp = CreateAudioComponent(UndeploySound, TRUE, TRUE, TRUE, Location, TRUE);
				}
				else
				{
					DeploySoundComp.SoundCue = UndeploySound;
					DeploySoundComp.Play();
				}
			}
			break;

		case EDS_Undeployed:
			VehicleEvent('UnDeployed');
			AnimPlay.SetAnim(DeployAnim[1]);
			AnimPlay.StopAnim();
			SetVehicleUnDeployed();
			VehiclePlayEnterSound();
			AnimPlay.SetPosition(AnimPlay.AnimSeq.SequenceLength, false);
			for (i = 0; i < Seats.length; i++)
			{

			}
			if(DeploySoundComp != None)
			{
				DeploySoundComp.Stop();
			}
			break;

	}
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'DeployedState' )
	{
		DeployedStateChanged();
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated function bool DeployActivated()
{
	return (DeployedState == EDS_Deployed) || (DeployedState == EDS_Deploying);
}	

simulated function bool IsDeployed()
{
	return (DeployedState == EDS_Deployed);
}

simulated function bool ShouldClamp()
{
	return !IsDeployed();
}

/**
 * Jump Deploys / Undeploys
 */
function bool DoJump(bool bUpdating)
{
	if (Role == ROLE_Authority)
	{
		ServerToggleDeploy();
	}
	return true;
}

/**
 * @Returns true if this vehicle can deploy
 */
event bool CanDeploy(optional bool bShowMessage = true)
{
	local int i;

	// Check current speed
	if (VSize(Velocity) > MaxDeploySpeed)
	{

		return false;
	}
	else if (IsFiring())
	{
		return false;
	}
	else
	{
		// Make sure all 4 wheels are on the ground if required
		if (bRequireAllWheelsOnGround)
		{
			for (i=0;i<Wheels.Length;i++)
			{
				if ( !Wheels[i].bWheelOnGround )
				{
					return false;
				}
			}
		}
		return true;
	}
}

reliable server function ServerToggleDeploy()
{
	if ( CanDeploy() )	// Are we stopped (or close enough)
	{
		GotoState('Deploying');
	}
}

simulated function SetVehicleDeployed()
{
	VehicleEvent('EngineStop');

	SetPhysics(PHYS_None);
	SetBase(None); // Ensure we are not hooked on something (eg another vehicle)
	bStationary = true;
	bBlocksNavigation = true;
}

simulated function SetVehicleUndeployed()
{
	VehicleEvent('EngineStart');

	SetPhysics(PHYS_RigidBody);
	bStationary = false;
	bBlocksNavigation = !bDriving;
}

simulated function SetVehicleUndeploying();

state Deploying
{
	reliable server function ServerToggleDeploy()
	{
		if(bAllowAbortDeploy && !IsTimerActive('BackToUndeployed'))
		{
			ClearTimer('VehicleIsDeployed');
			ChangeDeployState(EDS_AbortDeploying);
			SetTimer(WorldInfo.TimeSeconds - LastDeployStartTime, FALSE, 'BackToUndeployed');
		}
	}

	simulated function BackToUndeployed()
	{
		ChangeDeployState(EDS_UnDeployed);
		GotoState('');
	}

	simulated function BeginState(name PreviousStateName)
	{
		SetTimer(DeployTime,False,'VehicleIsDeployed');

		if (Role == ROLE_Authority)
		{
			SetVehicleDeployed();
		}

		ChangeDeployState(EDS_Deploying);
	}

	simulated function VehicleIsDeployed()
	{
		GotoState('Deployed');
	}
}

state Deployed
{
	reliable server function ServerToggleDeploy()
	{
		if (!IsFiring())
		{
			GotoState('UnDeploying');
		}
	}

	simulated function DrivingStatusChanged()
	{
		Global.DrivingStatusChanged();

		// force bBlocksNavigation when deployed, even if being driven
		bBlocksNavigation = true;
	}

	/** traces down to the ground from the wheels and undeploys the vehicle if wheels are too far off the ground */
	function CheckStability()
	{
		local int i, Count;
		local vector WheelLoc, XAxis, YAxis, ZAxis;

		GetAxes(Rotation, XAxis, YAxis, ZAxis);

		for (i = 0; i < Wheels.Length; i++)
		{
			WheelLoc = Mesh.GetPosition() + (Wheels[i].WheelPosition >> Rotation);
			if (FastTrace(WheelLoc - (ZAxis * (Wheels[i].WheelRadius + Wheels[i].SuspensionTravel)), WheelLoc, vect(1,1,1)))
			{
				Count++;
			}
		}
		if ( Count > 1 )
		{
			SetPhysics(PHYS_RigidBody);
			GotoState('UnDeploying');
			return;
		}
	}

	function BeginState(name PreviousStateName)
	{
		ChangeDeployState(EDS_Deployed);
		if (bRequireAllWheelsOnGround && Role == ROLE_Authority)
		{
			SetTimer(1.0, true, 'CheckStability');
		}
	}

	function EndState(name NextStateName)
	{
		ClearTimer('CheckStability');
	}
}

simulated state UnDeploying
{
	reliable server function ServerToggleDeploy();

	simulated function BeginState(name PreviousStateName)
	{
		SetTimer(UnDeployTime,False,'VehicleUnDeployIsFinished');
		ChangeDeployState(EDS_UnDeploying);
	}

	simulated function VehicleUnDeployIsFinished()
	{
		if (ROLE==ROLE_Authority && WorldInfo.NetMode != NM_ListenServer)
		{
			SetVehicleUndeployed();
		}

		ChangeDeployState(EDS_UnDeployed);
		GotoState('');
	}
}

simulated function VehiclePlayEnterSound()
{
	local SoundCue EnterCue;

    if (bDriving)
    {
    	if (DeployedState == EDS_Deployed || DeployedState == EDS_Undeployed)
    	{
    		EnterCue = IsDeployed() ? DeployedEnterSound : EnterVehicleSound;

    		if (EnterCue != None)
    		{
    			PlaySound(EnterCue);
    		}
    		StartEngineSoundTimed();
    	}
	}
}

simulated function VehiclePlayExitSound()
{
	local SoundCue ExitCue;

	StopEngineSound();

	if (DeployedState == EDS_Deploying || DeployedState == EDS_Undeployed)
	{
		ExitCue = IsDeployed() ? DeployedExitSound : ExitVehicleSound;

		if (ExitCue != None)
		{
			PlaySound(ExitCue);
		}

		StopEngineSoundTimed();
	}
}

simulated function StartEngineSound()
{
	if (EngineSound != None && DeployedState == EDS_Undeployed)
	{
		EngineSound.Play();
	}
	ClearTimer('StartEngineSound');
	ClearTimer('StopEngineSound');
}

function bool ShouldUndeploy(UTBot B) 
{
	return (IsDeployed() && (Pawn(B.Focus) == None || (Pawn(B.Focus).Health <= 0) || WorldInfo.GRI.OnSameTeam(B,B.Focus) || !B.Pawn.CanAttack(B.Focus)));
}

function bool GoodDefensivePosition()
{
	return !bNotGoodArtilleryPosition;
}
	
	
	
	
	
	
	
	
	
	
	
	
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



// special for mammoth
simulated event GetBarrelLocationAndRotation(int SeatIndex, out vector SocketLocation, optional out rotator SocketRotation)
{
    if (Seats[SeatIndex].GunSocket.Length > 0)
    {
        Mesh.GetSocketWorldLocationAndRotation(Seats[SeatIndex].GunSocket[GetBarrelIndex(SeatIndex)], SocketLocation, SocketRotation);
    }
    else
    {
        SocketLocation = Location;
        SocketRotation = Rotation;
    }
}

simulated function int GetBarrelIndex(int SeatIndex)
{
   local int OldBarrelIndex;
   OldBarrelIndex = super.GetBarrelIndex(SeatIndex);
   if (Weapon == none)
      return OldBarrelIndex;

   return (Weapon.CurrentFireMode == 0 ? OldBarrelIndex % 2 : (OldBarrelIndex % 2) + 2);
}



DefaultProperties
{


//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\


	DeployTime=2.1
	UnDeployTime=2.0
	MaxDeploySpeed=100.000000
	bRequireAllWheelsOnGround=False
	DeployIconOffset=0.950000
	
	IdleAnim(0)="HoverCraft_Idle_InActive"
	IdleAnim(1)="HoverCraft_Idle_InActive"
	DeployAnim(0)="HoverCraft_Opening"
	DeployAnim(1)="HoverCraft_Closing"


	Health=1200
	bLightArmor=false
	MaxDesireability=0.2
	MomentumMult=0.7
	bSeparateTurretFocus=true
	bTakeWaterDamageWhileDriving=false
	bHasHandbrake=false
	bTurnInPlace=true
	bCanStrafe=true
	bCanFlip=true
	bFollowLookDir=true
	GroundSpeed=600
	AirSpeed=2000
	MaxSpeed=800
	HornIndex=1
	COMOffset=(x=0.0,y=0.0,z=0.0)

	UprightLiftStrength=30.0
	UprightTorqueStrength=30.0
	CustomGravityScaling=0.8
	WaterDamage=0.0
	
	bStayUpright=true
	StayUprightRollResistAngle=5.0
	StayUprightPitchResistAngle=5.0
	StayUprightStiffness=450
	StayUprightDamping=20

	Begin Object Class=UDKVehicleSimHover Name=SimObject
		WheelSuspensionStiffness=150.0
		WheelSuspensionDamping=4.0
		WheelSuspensionBias=0.0
		MaxThrustForce=3000.0
		MaxReverseForce=2000.0
		LongDamping=10.0
		MaxStrafeForce=1000.0
		DirectionChangeForce=4000.0
		StopThreshold=20
		LatDamping=15.0
		MaxRiseForce=0.0
		UpDamping=0.0
		TurnTorqueFactor=80000.0
		TurnTorqueMax=120000.0
		TurnDamping=100
		MaxYawRate=100000.0
		PitchTorqueFactor=-8000.0
		PitchTorqueMax=18000.0
		PitchDamping=30.0
		RollTorqueTurnFactor=-16000.0
		RollTorqueStrafeFactor=8000.0
		RollTorqueMax=50000.0
		RollDamping=30.0
		MaxRandForce=10000.0
		RandForceInterval=0.4
		bAllowZThrust=false
	End Object
	SimObj=SimObject
	Components.Add(SimObject)


//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\


	Begin Object name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'RX_VH_HoverCraft.Mesh.SK_VH_HoverCraft'
		AnimTreeTemplate=AnimTree'RX_VH_HoverCraft.Anims.AT_VH_HoverCraft'
		PhysicsAsset=PhysicsAsset'RX_VH_HoverCraft.Mesh.SK_VH_HoverCraft_Physics'
		AnimSets(0)=AnimSet'RX_VH_HoverCraft.Anims.AS_VH_HoverCraft'
	End Object

	DrawScale=1.0

	VehicleIconTexture=Texture2D'RX_VH_HoverCraft.UI.T_VehicleIcon_HoverCraft'
	MinimapIconTexture=Texture2D'RX_VH_HoverCraft.UI.T_MinimapIcon_HoverCraft'

//========================================================\\
//*********** Vehicle Seats & Weapon Properties **********\\
//========================================================\\


	Seats(0)={(GunClass=class'Rx_Vehicle_Hovercraft_GDI_Weapon',
				GunSocket=("FireCannonL","FireCannonR","FireL","FireR"),
				TurretVarPrefix="",
				CameraTag=CamView3P,
				CameraBaseOffset=(X=-75,Z=0),
				CameraOffset=-1500,
				SeatIconPos=(X=0.5,Y=0.33),
				MuzzleFlashLightClass=class'RenX_Game.Rx_Light_Tank_MuzzleFlash'
				)}


//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


	BurnOutMaterial[0]=MaterialInstanceConstant'RX_VH_Humvee.Materials.MI_VH_Humvee_BO'
	BurnOutMaterial[1]=MaterialInstanceConstant'RX_VH_Humvee.Materials.MI_VH_Humvee_BO'

	DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_HoverCraft.Materials.PhysMat_HoverCraft_Driving'
	DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_HoverCraft.Materials.PhysMat_HoverCraft'

	VehicleEffects(0)=(EffectStartTag="FireR",EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_MuzzleFlash_Missiles',EffectSocket="FireR")
	VehicleEffects(1)=(EffectStartTag="FireL",EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_MuzzleFlash_Missiles',EffectSocket="FireL")
	
	VehicleEffects(2)=(EffectStartTag="FireCannonR",EffectTemplate=ParticleSystem'RX_VH_MediumTank.Effects.MuzzleFlash',EffectSocket="FireCannonR")
	VehicleEffects(3)=(EffectStartTag="FireCannonL",EffectTemplate=ParticleSystem'RX_VH_MediumTank.Effects.MuzzleFlash',EffectSocket="FireCannonL")
	
	VehicleEffects(4)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageSmoke01)
	VehicleEffects(5)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire',EffectSocket=DamageSmoke02)
	VehicleEffects(6)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_HoverCraft.Effects.P_WaterTrail',EffectSocket=Splash_R_1)
	VehicleEffects(7)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_HoverCraft.Effects.P_WaterTrail',EffectSocket=Splash_R_3)
	VehicleEffects(8)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_HoverCraft.Effects.P_WaterTrail',EffectSocket=Splash_L_1)
	VehicleEffects(9)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_HoverCraft.Effects.P_WaterTrail',EffectSocket=Splash_L_3)
	VehicleEffects(10)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_HoverCraft.Effects.P_FanDistortion',EffectSocket=Fan_Left)
	VehicleEffects(11)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_HoverCraft.Effects.P_FanDistortion',EffectSocket=Fan_Right)
	
	WheelParticleEffects[0]=(MaterialType=Generic,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Dirt')
	WheelParticleEffects[1]=(MaterialType=Dirt,ParticleTemplate=ParticleSystem'RX_FX_Vehicle.Wheel.P_FX_Wheel_Dirt')
    WheelParticleEffects[2]=(MaterialType=Water,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.P_Scorpion_Water_Splash')
	WheelParticleEffects[3]=(MaterialType=Snow,ParticleTemplate=ParticleSystem'Envy_Level_Effects_2.Vehicle_Snow_Effects.P_Scorpion_Wheel_Snow')

	BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle_Huge')
    BigExplosionSocket=VH_Death
	
	MaxGroundEffectDist=256.0
	GroundEffectIndices=(12,13)
	WaterGroundEffect=ParticleSystem'Envy_Level_Effects_2.Vehicle_Water_Effects.PS_Manta_Water_Effects'



//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\

	Begin Object Class=AudioComponent Name=ScorpionEngineSound
		SoundCue=SoundCue'RX_VH_HoverCraft.Sounds.SC_HoverCraft_Idle'
	End Object
	EngineSound=ScorpionEngineSound
	Components.Add(ScorpionEngineSound);
	
	Begin Object Class=AudioComponent Name=BaseScrapeSound
		SoundCue=SoundCue'A_Gameplay.A_Gameplay_Onslaught_MetalScrape01Cue'
	End Object
	ScrapeSound=BaseScrapeSound
	Components.Add(BaseScrapeSound);

	ExplosionSound=SoundCue'A_Vehicle_Scorpion.SoundCues.A_Vehicle_Scorpion_Explode'
    CollisionSound=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_Collide'
    EnterVehicleSound=SoundCue'RX_VH_MammothTank.Sounds.Mammoth_startCue'
	ExitVehicleSound=SoundCue'RX_VH_MammothTank.Sounds.Mammoth_StopCue'

	SquealThreshold=0.1
	SquealLatThreshold=0.02
	LatAngleVolumeMult = 30.0
	EngineStartOffsetSecs=0.5
	EngineStopOffsetSecs=0.5


//========================================================\\
//******** Vehicle Wheels & Suspension Properties ********\\
//========================================================\\

	Begin Object Class=UTHoverWheel Name=RFThruster
		BoneName="b_Base"
		BoneOffset=(X=850.0,Y=400.0,Z=-50.0)
		WheelRadius=100
		SuspensionTravel=100
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(0)=RFThruster

	Begin Object Class=UTHoverWheel Name=LFThruster
		BoneName="b_Base"
		BoneOffset=(X=850.0,Y=-400.0,Z=-50.0)
		WheelRadius=100
		SuspensionTravel=100
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(1)=LFThruster

	Begin Object Class=UTHoverWheel Name=RMThruster
		BoneName="b_Base"
		BoneOffset=(X=0.0,Y=400.0,Z=-50.0)
		WheelRadius=100
		SuspensionTravel=100
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(2)=RMThruster
	
	Begin Object Class=UTHoverWheel Name=LMThruster
		BoneName="b_Base"
		BoneOffset=(X=0.0,Y=-400.0,Z=-50.0)
		WheelRadius=100
		SuspensionTravel=100
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(3)=LMThruster

	Begin Object Class=UTHoverWheel Name=RRThruster
		BoneName="b_Base"
		BoneOffset=(X=-850.0,Y=400.0,Z=-50.0)
		WheelRadius=100
		SuspensionTravel=100
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(4)=RRThruster
	
	Begin Object Class=UTHoverWheel Name=LRThruster
		BoneName="b_Base"
		BoneOffset=(X=-850.0,Y=-400.0,Z=-50.0)
		WheelRadius=100
		SuspensionTravel=100
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(5)=LRThruster
	
	Begin Object Class=UTHoverWheel Name=CThruster
		BoneName="b_Base"
		BoneOffset=(X=-0.0,Y=-0.0,Z=-50.0)
		WheelRadius=100
		SuspensionTravel=100
		bPoweredWheel=false
		LongSlipFactor=0.0
		LatSlipFactor=0.0
		HandbrakeLongSlipFactor=0.0
		HandbrakeLatSlipFactor=0.0
		SteerFactor=1.0
		bHoverWheel=true
	End Object
	Wheels(6)=CThruster
	
}