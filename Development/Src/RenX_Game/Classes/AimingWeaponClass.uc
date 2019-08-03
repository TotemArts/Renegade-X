/**
 * Iron sights zoom aiming class by DazJW
 *
 * This is a subclass of UTWeapon which is designed to be extended by your own weapon class
 * As such do not alter anything in this file, anything you wish to alter should be copied into your weapon class and altered there
 *
 * Check the end of the default properties section of this file for some values you will almost definitely want to configure to suit your weapon
 *
 * The file UTWeap_AimableWeapon is an example of a weapon using this code
 * It also shows how to add an extra setting change, in this case a rate of fire increase while zoom aiming
 *
 * In order to function correctly your weapon package requires the following extra animations in both your weapon and arm animation sets
 * WeaponZoomIn - An animation of your weapon moving to the centre of the screen, your iron sights should line up on 0,0,0
 * WeaponZoomOut - An animation of your weapon returning to the normal position in the bottom right of the screen
 * WeaponZoomFire - A firing animation with your weapon in the centre of the screen
 * WeaponZoomIdle - An idle animation with your weapon in the centre of the screen
 */

class AimingWeaponClass extends UTWeapon
	HideDropDown
	abstract;

/** New values for use while zoom aiming */
var float ZoomGroundSpeed;
var float ZoomAirSpeed;
var float ZoomWaterSpeed;
var float ZoomJumpZ;

/** Spread value while zoom aiming */
var float SpreadScoped;

/** Spread value while not zoom aiming */
var float SpreadNoScoped;

/** Boolean for if the player is zoom aiming */
var bool bIronsightActivated;

/** Boolean for if the crosshair should be displayed */
var bool bDisplayCrosshair;
var bool bDisplayCrosshairInIronsight;

/** Amount of FOV to subract from FOV when zoomed */
var float ZoomedFOVSub;
var float InverseZoomOffset;

var float ZoomedWeaponFov;

/** Zoom minimum time, from UT3 Sniper Rifle*/
var bool bAbortZoom;

/** Tracks number of zoom started calls, from UT3 Sniper Rifle */
var int ZoomCount;

var bool bIronSightCapable;
var float IronSightBobDamping;
var float IronSightPostAnimDurationModifier;
var vector NormalViewOffset;
var vector IronSightViewOffset;
var	vector IronSightFireOffset;
var bool bPlayingIdleAnim;

/** Tell the server that the client needs this information */
replication
{
  if ( Role == ROLE_Authority )
	bIronsightActivated;
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	if(!bIronSightCapable) {
		return;
	}
	//This is necessary so secondary fire doesn't actually fire
	InstantHitDamageTypes[1]=None;
	FiringStatesArray[1]='Active';
	FireInterval[1]=+0.00001;

	//This sets which fire mode is zoom mode
	bZoomedFireMode[0]=0;
	bZoomedFireMode[1]=1;
}

function byte BestMode()
{
	if (bIronSightCapable)
		return 0;
	else
		return Super.BestMode();
}

/** Function to run when zooming in or out, checks the bIronsightActivated boolean and decides which set of properties to use */
simulated function CheckMyZoom()
{
 	// overridden in Rx_Weapon
}

/** This adds to the Activate function to force CheckMyZoom when the weapon is equipped so we get the proper values for not zoom aiming */
simulated function Activate()
{
	if(bIronSightCapable) {
		CheckMyZoom();
		GetSetFOV();
	}
	super.Activate();
}

/** Checks the DisplayCrosshair boolean and acts accordingly, unedited from UT3 Sniper Rifle */
simulated function DrawWeaponCrosshair( Hud HUD )
{
	local UTPlayerController PC;
	
	if( bDisplayCrosshair )
	{
		PC = UTPlayerController(Instigator.Controller);
		if ( (PC == None) || PC.bNoCrosshair )
		{
			return;
		}
		super.DrawWeaponCrosshair(HUD);
	}
}

/** This retrieves the Player's FOV setting for later reference */
simulated function GetSetFOV()
{
	local UTPlayerController PC;
	PC = UTPlayerController(Instigator.Controller);
	if(PC != None) {
		ZoomedTargetFOV = PC.GetFOVAngle() - ZoomedFOVSub;
	}
}

/** This runs when you right click to zoom aim - it turns the crosshair off, plays the zoom in animation for the weapon and arms and calls the GotoZoom, PlayMyZoomIdle and ServerGotoZoom functions */
simulated function StartZoom(UTPlayerController PC)
{
	local AnimNodeSequence AnimSeq;
	
	if(GetZoomedState() == ZST_NotZoomed && HasAmmo(0)) super.StartZoom(PC);
	else
	{
		return;
	}

	if(!bIronSightCapable) {
		return;
	}	
	
	ZoomCount++;
	//if (ZoomCount == 1 && !IsTimerActive('Gotozoom') && IsActiveWeapon() && HasAmmo(0) && Instigator.IsFirstPerson())
	if (ZoomCount == 1 && !IsTimerActive('Gotozoom') && HasAmmo(0))
	{
		bAbortZoom = false;
		if(!bDisplayCrosshairInIronsight)
			bDisplayCrosshair = false;
		UTPawn(Instigator).Bob = UTPawn(Instigator).Bob/IronSightBobDamping;
		if(Rx_Controller(Rx_Pawn(Instigator).Controller) != None && WorldInfo.NetMode != NM_DedicatedServer)
		{
			Rx_Pawn(Instigator).bWasInThirdPersonBeforeIronsight = Rx_Controller(Rx_Pawn(Instigator).Controller).bBehindView;
			if(Rx_Pawn(Instigator).bWasInThirdPersonBeforeIronsight)
				Rx_Controller(Rx_Pawn(Instigator).Controller).SetOurCameraMode(FirstPerson);
		}
		bIronsightActivated=true;
		ClearTimer('MoveWeaponOutOfIronSight');
		SetTimer(0.005,true,'MoveWeaponToIronSight');
		if(bPlayingIdleAnim) {
			UTPawn(Instigator).ArmsMesh[0].StopAnim();
			AnimSeq = GetWeaponAnimNodeSeq();
			if( AnimSeq != None )
			{
				AnimSeq.SetPosition(0,false);
			}
			StopWeaponAnimation();
		}
		NormalViewOffset = default.PlayerViewOffset;
		PC.StartZoomNonlinear(ZoomedTargetFOV, 10.0);
		SetTimer(0.001, false, 'Gotozoom'); //SetTimer(0.2, false, 'Gotozoom');
		if( Role < Role_Authority )
		{
			// if we're a client, synchronize server
			SetTimer(0.001, false, 'ServerGotozoom'); //SetTimer(0.2, false, 'ServerGotozoom');
		}
	}
}

simulated function MoveWeaponToIronSight() {

}

simulated function MoveWeaponOutOfIronSight() {
	
}

/** Subtracts the ZoomedFOVSub value in default properties from the players FOV to zoom in, sets bIronsightActivated to true and calls the CheckMyZoom function which will return true and set the zoom aiming values as bIronsightActivated is set to true */
simulated function Gotozoom()
{
	//local UTPlayerController PC;
	//`log("PROCESS GOTOZOOM"); Yosh Log
	//PC = UTPlayerController(Instigator.Controller);
	if (GetZoomedState() == ZST_NotZoomed)
	{
		if (bAbortZoom) // stop the zoom after 1 tick
		{
			SetTimer(0.0001, false, 'StopZoom');
		}
		//PC.SetFOV(ZoomedTargetFOV);
		//PlayerViewOffset = vect(14.0,-0.01,-9.6);
		//PlayerViewOffset = vect(8,-9,-0);
		//PC.StartZoom(ZoomedTargetFOV, ZoomedRate);
	}
	bIronsightActivated = true;
	CheckMyZoom();
}

/** Server version of the above to make sure everything is in sync, doesn't set the zoom level because that is a client side visual change */
reliable server function ServerGotoZoom()
{
	//`log("Run ServerGOTOZOOM"); Yosh Log
	bIronsightActivated = true;
	CheckMyZoom();
}

/** This runs when you right click to leave zoom aim mode and calls LeaveZoom and ServerLeaveZoom so everything is in sync again */
simulated function EndZoom(UTPlayerController PC)
{
	//`log("PROCESS END ZOOM"); Yosh Log 
	if(!bIronSightCapable) {
		super.EndZoom(PC);
		return;
	}	
	bAbortZoom = false;
	if (IsTimerActive('Gotozoom'))
	{
		ClearTimer('Gotozoom');
	}
	SetTimer(0.001,false,'LeaveZoom');
	
	UTPawn(Instigator).Bob = class'Rx_Pawn'.default.Bob;
	
	if( Role < Role_Authority )
	{
		// if we're a client, synchronize server
		SetTimer(0.001,false,'ServerLeaveZoom');
	}
}

/** This reverses the effects of StartZoom - it resets the zoom level, plays the zoom out animation for the weapon and arms, runs RestartCrosshair which makes the crosshair visible again, sets bIronsightActivated to false and runs CheckMyZoom which returns false and sets us back to the original values for everything */
simulated function LeaveZoom()
{

	local UTPlayerController PC;
	
	//`log("Process LEAVE ZOOM"); Yosh Log 
	PC = UTPlayerController(Instigator.Controller);
	ZoomCount = 0;
	ClearTimer('MoveWeaponToIronSight');
	SetTimer(0.005,true,'MoveWeaponOutOfIronSight');
	
	PC.StartZoomNonlinear(PC.DefaultFOV+InverseZoomOffset, 10.0);
	//PC.EndZoomNonlinear(10.0);
	SetTimer(0.3,false,'RestartCrosshair');
	bIronsightActivated = false;
	if(Rx_Controller(Rx_Pawn(Instigator).Controller) != None && WorldInfo.NetMode != NM_DedicatedServer)
	{
		if(Rx_Pawn(Instigator).bWasInThirdPersonBeforeIronsight)
			Rx_Controller(Rx_Pawn(Instigator).Controller).SetOurCameraMode(ThirdPerson);
	}	
	bAbortZoom = false;
	CheckMyZoom();
}

/** Server version of the above, doesn't reset the zoom level because it was never changed server side and doesn't play the animations because they're a client side visual effect */
reliable server function ServerLeaveZoom()
{
	//`log("ServerLeaveZoom"); Yosh log  
	bIronsightActivated = false;
	CheckMyZoom();
}

/** This stops the zooming in, unedited from UT3 Sniper Rifle */
simulated function StopZoom()
{
	local UTPlayerController PC;
	
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		PC = UTPlayerController(Instigator.Controller);
		if (PC != None && LocalPlayer(PC.Player) != none)
		{
			PC.StopZoom();
		}
	}
}

simulated function RestartCrosshair()
{
	bDisplayCrosshair = true;
}

/** This adds LeaveZoom to the PutDownWeapon function in UTWeapon so we get our original zoom level, etcetera back if we switch weapons while zoom aiming, unedited from the UT3 Sniper Rifle */
simulated function PutDownWeapon()
{
	if(bIronSightCapable && bIronsightActivated) {
		LeaveZoom();
	}
	Super.PutDownWeapon();
}

/** This stops autoswitching to a newly picked up weapon while zoom aiming, unedited from the UT3 Sniper Rifle */
simulated function bool DenyClientWeaponSet()
{
	// don't autoswitch while zoomed
	return (GetZoomedState() != ZST_NotZoomed);
}

/** Adds to UTweapon's PlayWeaponPutDown to stop zoom aiming related stuff if we switch away from the weapon */
simulated function PlayWeaponPutDown()
{
	if(!bIronSightCapable) {
		super.PlayWeaponPutDown();
		return;
	}
	
	ClearTimer('GotoZoom');
	ClearTimer('StopZoom');
	if(UTPlayerController(Instigator.Controller) != none)
	{
		UTPlayerController(Instigator.Controller).EndZoom();
	}
	super.PlayWeaponPutDown();
}

/** Adds to UTweapon's Active state to decide whether we should be playing the normal idle animation or the zoom aiming idle animation */
simulated state Active
{
	simulated event OnAnimEnd(AnimNodeSequence SeqNode,float PlayedTime,float ExcessTime)
	{		
		if(!bIronSightCapable) {
			super.OnAnimEnd(SeqNode,PlayedTime,ExcessTime);
			return;
		}
		if(!bIronsightActivated) {
			PlayIdleAnims();
		}
	}
}

simulated function PlayIdleAnims()
{
	local int IdleIndex;
	if ( WorldInfo.NetMode != NM_DedicatedServer && WeaponIdleAnims.Length > 0 )
	{
		IdleIndex = Rand(WeaponIdleAnims.Length);
		PlayWeaponAnimation(WeaponIdleAnims[IdleIndex], 0.0, true);
		bPlayingIdleAnim = true;
		if(ArmIdleAnims.Length > IdleIndex && ArmsAnimSet != none)
		{
			PlayArmAnimation(ArmIdleAnims[IdleIndex], 0.0,, true);
		}
	}
}


simulated function PlayWeaponAnimation(name Sequence, float fDesiredDuration, optional bool bLoop, optional SkeletalMeshComponent SkelMesh)
{
	if(Sequence == WeaponIdleAnims[0] && Rx_Pawn(Instigator).bSprinting)
		return;
	bPlayingIdleAnim = false;
	Super.PlayWeaponAnimation(Sequence, fDesiredDuration, bLoop, SkelMesh);
}

simulated function PlayArmAnimation( Name Sequence, float fDesiredDuration, optional bool OffHand, optional bool bLoop, optional SkeletalMeshComponent SkelMesh)
{
	if(Sequence == ArmIdleAnims[0] && Rx_Pawn(Instigator).bSprinting)
		return;
	super.PlayArmAnimation(Sequence,fDesiredDuration,OffHand,bLoop,SkelMesh);
}
simulated function EndFire(Byte FireModeNum)
{
    if(bIronSightCapable) {
    	super(UDKWeapon).EndFire(FireModeNum);
    } else {
    	super.EndFire(FireModeNum);
    }
}

defaultproperties
{
	//
	//These values do not need to be present in your weapon class if you extend this class
	//

	//This says to display the crosshair when the weapon is first equipped
	bDisplaycrosshair = true;

	//This vastly reduces the weapon bob effect when landing from a jump or fall in order to prevent model clipping while aiming
	JumpDamping=0.1

	//These reduce the weapon lagging behind the crosshair effect to ensure the sights are properly lined up when you enter zoom aiming mode
	MaxPitchLag=40
	MaxYawLag=70

	//This says the weapon isn't zoom aiming when the weapon is first equipped
	bIronsightActivated=false

	//This sets how fast we want to zoom, a very high value gives an instant zoom rather than the UT3 Sniper Rifle's hold to zoom setup
	ZoomedRate=300000.0

	//
	//This value does not need to be present in your weapon class but can be if you wish to have a different amount of zoom while zoom aiming
	//

	//
	//These values should be present in your weapon class and be altered to suit your needs
	//

	//This is the spread value for use while zoom aiming, smaller number is more accurate
	SpreadScoped=0.0025

	//This is the spread value for use while not zoom aiming, larger number is less accurate
	SpreadNoScoped=0.045
	
	//Ironsight weaponspecific vars:
	bIronSightCapable=false
	IronSightViewOffset=(X=-7,Y=-9.37,Z=-0.187)
	IronSightFireOffset=(X=0,Y=0,Z=0)
	IronSightBobDamping=3
	IronSightPostAnimDurationModifier=0.2
	//This sets how much we want to zoom in, this is a value to be subtracted because smaller FOV values are greater levels of zoom
	ZoomedFOVSub=20.0	
	ZoomedWeaponFov=15.0
	InverseZoomOffset=10.0
	//New lower speed movement values for use while zoom aiming
	ZoomGroundSpeed=210.0
	ZoomAirSpeed=340.0
	ZoomWaterSpeed=110.0
	ZoomJumpZ=256.0	
	bDisplayCrosshairInIronsight=false
}

