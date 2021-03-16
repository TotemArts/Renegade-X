/*********************************************************
*
* File: Rx_Vehicle_Deployable.uc
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
class Rx_Vehicle_Deployable extends Rx_Vehicle_Treaded;

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
	if (VSizeSq(Velocity) > Square(MaxDeploySpeed))
	{

		return false;
	}
	else if (Rx_Vehicle_Multiweapon(Weapon) != None)
	{
		if(Weapon.PendingFire(0) || Weapon.PendingFire(1))
			return false;
	}
	else if (IsFiring() && !Weapon.IsInState('Reloading'))
	{
		return false;
	}

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
		return true;
	}

	return true;
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
		if (CanDeploy())
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

defaultproperties
{
	DeployTime=2.1
	UnDeployTime=2.0
	MaxDeploySpeed=100.000000
	bRequireAllWheelsOnGround=False
	DeployIconOffset=0.950000
}