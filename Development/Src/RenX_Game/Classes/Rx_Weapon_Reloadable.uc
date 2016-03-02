class Rx_Weapon_Reloadable extends Rx_Weapon
	abstract;

var() int ClipSize;
var() int InitalNumClips;
var() int MaxClips;

var repnotify int CurrentAmmoInClip;
var int CurrentAmmoInClipClientside; // localy have a copy of ammo to update immediatly, so independant of lag 
var repnotify bool CurrentlyReloading;
var repnotify bool CurrentlyBoltReloading;

/**
 * For reload time and Reload Anim name's 
 * 
 *  0 = Primary Fire - No Ammo in the clip
 *  1 = Secondary Fire - No Ammo in the clip
 *  2 = Primary Fire - 1 or more rounds left in the clip
 *  3 = Secondary Fire - 1 or more rounds left in the clip
 */
var() float ReloadTime[4];
var() name ReloadAnimName[4];
var() name ReloadAnim3PName[4];
var() name ReloadArmAnimName[4];
var() SoundCue ReloadSound[4];

var bool PerBulletReload;
var int CurrentReloadState;
var float BotDamagePercentage;

/**
 * For bolt-action reload time and Bolt Reload Anim name's 
 * 
 *  0 = Primary Fire - No Ammo in the clip
 *  1 = Secondary Fire - No Ammo in the clip
 *  2 = Primary Fire - 1 or more rounds left in the clip
 *  3 = Secondary Fire - 1 or more rounds left in the clip
 */
var() name BoltReloadAnimName[2];
var() name BoltReloadAnim3PName[2];
var() name BoltReloadArmAnimName[2];
var() SoundCue BoltReloadSound[2];
var() float BoltReloadTime[2];

// What percentage of the refire time to start the bolt reload. 1 = directly after, 0.5 = half way, 2 = twice the length
var() float RefireBoltReloadInterrupt[2];

var bool BoltActionReload;
var bool bUnzoomDuringBoltActionReloading;

//info for reload animation timing
var float reloadBeginTime;
var float currentReloadTime;

//returns partial bot damage
simulated function float GetBotDamagePercentage()
{
	return BotDamagePercentage;
}

replication
{
	if( bNetDirty && bNetOwner && Role == ROLE_Authority)
		CurrentAmmoInClip, CurrentlyReloading, CurrentlyBoltReloading, CurrentReloadState;
}

event PreBeginPlay()
{
	AmmoCount = ClipSize * InitalNumClips;
	MaxAmmoCount = ClipSize * MaxClips;
	CurrentAmmoInClip = ClipSize;
	CurrentAmmoInClipClientside = ClipSize;
	bForceNetUpdate = true;
	super.PreBeginPlay();
}

simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'CurrentlyReloading' ) 
	{
		if(CurrentlyReloading == false) 
		{
			CurrentAmmoInClipClientside = ClipSize;
			PostReloadUpdate();	
			
			//if( (PendingFire(0) && CurrentFireMode == 0) || (PendingFire(1) && CurrentFireMode == 1) ) 
			if( (ClientPendingFire[0] && CurrentFireMode == 0) || (ClientPendingFire[1] && CurrentFireMode == 1) ) 
			{
				RestartWeaponFiringAfterReload();	
			} 
			else if(!IsInState('WeaponPuttingDown')) 
			{
				
				GotoState('Active');
			}	
		} 
		else 
		{
			if(bIronsightActivated && UTPlayerController(Instigator.Controller) != None)
			{
				EndZoom(UTPlayerController(Instigator.Controller));
			}
			reloadBeginTime = WorldInfo.TimeSeconds;
			currentReloadTime = ReloadTime[CurrentFireMode];		
			PlayWeaponReloadAnim();
		}	
    }
	else if ( VarName == 'CurrentlyBoltReloading' ) 
	{
		if(CurrentlyBoltReloading == false) 
		{
			PostReloadUpdate();		
			/** EDIT: Bolt Action weapons ignore pending fire outside of not being able to shoot 
			if( PendingFire(0) || PendingFire(1) ) 
			{
				GotoState('WeaponFiring');	
			} 
			else*/
			if(!IsInState('WeaponPuttingDown'))  
			{
				GotoState('Active');
			}	
		} 
		else 
		{
			if(bIronsightActivated && UTPlayerController(Instigator.Controller) != None)
			{
				EndZoom(UTPlayerController(Instigator.Controller));
			}
			SetTimer(GetFireInterval(CurrentFireMode) * default.RefireBoltReloadInterrupt[CurrentFireMode],false,'PlayWeaponBoltReloadAnim');
			reloadBeginTime = WorldInfo.TimeSeconds;
			currentReloadTime = BoltReloadTime[CurrentFireMode];		
		}	
    }
	else if (VarName == 'CurrentAmmoInClip')
	{
		/*if(CurrentAmmoInClip < ClipSize)
		{}*/
		
		CurrentAmmoInClipClientside = CurrentAmmoInClip;	
		
		UpdateAmmoCounter();
		if(PerBulletReload && CurrentlyReloading)
		{
			PlayWeaponReloadAnim();		
		}
	}
    else 
    {
    	super.ReplicatedEvent(VarName);
    } 
}

simulated function RestartWeaponFiringAfterReload()
{
	
	
	GotoState('Active');	
	if(ROLE < ROLE_Authority || WorldInfo.Netmode == NM_Standalone) 
	{
	StartFire(CurrentFireMode);  	
	}
}

simulated function UpdateAmmoCounter(); // Needs overloaded if you need to update on weapon counteres

simulated function PerformRefill()
{
	AmmoCount = MaxAmmoCount;
	CurrentAmmoInClip = ClipSize;
	CurrentAmmoInClipClientside = ClipSize;
}

simulated function RestartReloading(float RestartDelay) 
{
	StopWeaponAnimation();
	Rx_Pawn(Owner).TopHalfAnimSlot.StopCustomAnim(0.15);	
	
	if(PerBulletReload)
	{
		ClearTimer('PerBulletReloadWeaponTimer');
	} 
	else
	{
		ClearTimer('ReloadWeaponTimer');
	}
	SetTimer( RestartDelay, false, 'RestartReloadingTimer');
	CurrentlyReloading = false; 
}

simulated function RestartReloadingTimer()
{
	if( CurrentlyBoltReloading && HasAmmo(CurrentFireMode) )
		GotoState('BoltActionReloading',, true);
	else
		GotoState('Reloading',, true);
}

state Reloading
{
	function BeginState( name PreviousState )
	{
		if (bDebugWeapon)
		{
			`log("---"@self$"."$GetStateName()$".BeginState("$PreviousState$")");
		}

		if (PerBulletReload)
		{
			CurrentReloadState = 2;
			SetTimer( ReloadTime[CurrentReloadState], false, 'PerBulletReloadWeaponTimer');
		}
		else
		{
			reloadBeginTime = WorldInfo.TimeSeconds;
			currentReloadTime = ReloadTime[CurrentFireMode];
			SetTimer( ReloadTime[CurrentFireMode], false, 'ReloadWeaponTimer');
			/*if(WorldInfo.Netmode == NM_DedicatedServer) 
			{	
			}*/
		
			ClearPendingFire(0);
			ClearPendingFire(1);
		}

		if(bIronsightActivated)
		{
			if(WorldInfo.Netmode != NM_DedicatedServer)
			{
				if(UTPlayerController(Instigator.Controller) != None)
				{
					EndZoom(UTPlayerController(Instigator.Controller));
				}
			}
		} 
		CurrentlyReloading = true;
		Rx_Pawn(Owner).SetHandIKEnabled(false);
		PlayWeaponReloadAnim();
	}

	function EndState( name NextState )
	{
		if (bDebugWeapon)
		{
			`log("---"@self$"."$GetStateName()$".EndState("$NextState$")");
		}
		CurrentlyReloading = false;
		CurrentlyBoltReloading = false;
		Rx_Pawn(Owner).SetHandIKEnabled(true);
		Rx_Pawn(Owner).ReloadAnim = '';
		ClearTimer('PerBulletReloadWeaponTimer');
		ClearTimer('ReloadWeaponTimer');
	}

	function PerBulletReloadWeaponTimer()
	{
		if (bDebugWeapon)
		{
			`log("---"@self$"."$GetStateName()$".PerBulletReloadWeaponTimer()");
		}
		if (CurrentReloadState == 0) // Weapon is lowered
		{
			if(PendingFire(0) || PendingFire(1) )  
			{
				CurrentlyReloading = false;
				GoToState('WeaponFiring');
				return;
			}
			else
			{
				CurrentlyReloading = false;
				GoToState('Active');
				return;
			}
		}
		else if (CurrentReloadState == 1) // Weapon currently reloading
		{
			if (CurrentAmmoInClip < default.ClipSize && AmmoCount > CurrentAmmoInClip)
			{
				CurrentAmmoInClip++;
				if (bHasInfiniteAmmo)
				{
					AmmoCount++;
				}
				PostReloadUpdate();
			}
			// If the player wants to shoot and has at least one bullet loaded, OR ammo is full, OR all ammo is already reloaded
			if(((PendingFire(0) || PendingFire(1)) && CurrentAmmoInClip > 0) || CurrentAmmoInClip == default.ClipSize || CurrentAmmoInClip >= AmmoCount) 
			{
				CurrentReloadState = 0;
			}
		}
		else // Weapon is raised
		{
			CurrentReloadState = 1;
		}

		PlayWeaponReloadAnim();
		SetTimer( ReloadTime[CurrentReloadState], false, 'PerBulletReloadWeaponTimer');
	}
	function ReloadWeaponTimer()
	{
		if (bDebugWeapon)
		{
			`log("---"@self$"."$GetStateName()$".ReloadWeapon()");
		}

		if (bHasInfiniteAmmo) 
		{
			AmmoCount = MaxAmmoCount;
			CurrentAmmoInClip = default.ClipSize;
		}
		else if( AmmoCount >= default.ClipSize )
		{
			CurrentAmmoInClip = default.ClipSize;
		}
		else
		{
			CurrentAmmoInClip = AmmoCount;
		}

		CurrentlyReloading = false;
		PostReloadUpdate();

		//if((PendingFire(0) && CurrentFireMode == 0) || (PendingFire(1) && CurrentFireMode == 1) ) 
		
		if((ClientPendingFire[0] && CurrentFireMode == 0) || (ClientPendingFire[1] && CurrentFireMode == 1) )
		{
			
			RestartWeaponFiringAfterReload();	
		}
		else
		{
			
			GotoState('Active');
		}
	}

	simulated function bool bReadyToFire()
	{
		return false;
	}

	// Undo reload
	simulated function PutDownWeapon() 
	{
		ClearTimer('ReloadWeaponTimer');
		ClearTimer('PerBulletReloadWeaponTimer');
		CurrentlyReloading = false;
		super.PutDownWeapon();
	}
	
	simulated event bool IsFiring()
	{
		return true;
	}
}

// This will get called after reloading is complete
// in case any weapons need to update displays and such
simulated function PostReloadUpdate();

simulated state Active
{
	simulated function BeginState(Name PrevStateName)
	{
		if( BoltActionReload && CurrentlyBoltReloading && HasAmmo(CurrentFireMode) )
			GoToState('BoltActionReloading');
		else if( CurrentAmmoInClip <= 0 && HasAnyAmmoOfType(CurrentFireMode) )
			GoToState('Reloading');
		if (bDebugWeapon)
		{
			`log("---"@self$"."$GetStateName()$".EndState("$PrevStateName$")");
		}
		super.BeginState(PrevStateName);
	}

	simulated function EndState( Name NextStateName )
	{
		super.EndState(NextStateName);
		if (bDebugWeapon)
		{
			`log("---"@self$"."$GetStateName()$".EndState("$NextStateName$")");
		}
	}

	simulated function bool bReadyToFire()
	{
		return  !IsTimerActive('RefireCheckTimer') && ( !CurrentlyReloading && !CurrentlyBoltReloading);
	}

	
	
}

function ConsumeAmmo( byte FireModeNum )
{
	CurrentAmmoInClip -= ShotCost[FireModeNum];
	super.ConsumeAmmo( FireModeNum );
}

// If this gun has any ammo in current clip it will return true.
simulated function bool HasAmmo( byte FireModeNum, optional int Amount )
{
	if( Amount==0 )
	{
		if (CurrentAmmoInClip < ShotCost[FireModeNum] || CurrentAmmoInClipClientside < ShotCost[FireModeNum])
			return false;
		else
			return true;
	}
	else
	{
		if (CurrentAmmoInClip < Amount || CurrentAmmoInClipClientside < Amount)
			return false;
		else
			return true;
	}
}

// If this gun has any ammo at all it returns true.
simulated function bool HasAnyAmmoOfType( byte FireModeNum )
{
	if( AmmoCount <= 0 )
	{
		return false;
	}
	return true;
}

simulated function PlayWeaponReloadAnim()
{
	if (PerBulletReload)
	{
		PlayWeaponAnimation( ReloadAnimName[CurrentReloadState], ReloadTime[CurrentReloadState] );
		PlayArmAnimation( ReloadArmAnimName[CurrentReloadState], ReloadTime[CurrentReloadState] );
		if(Rx_Pawn(Owner) != None)
		{
			Rx_Pawn(Owner).ReloadAnim = ReloadAnim3PName[CurrentReloadState];
			Rx_Pawn(Owner).TopHalfAnimSlot.PlayCustomAnimByDuration(Rx_Pawn(Owner).ReloadAnim,ReloadTime[CurrentReloadState],0.1f,0.1f,false,true);
		}
		PlaySound( ReloadSound[CurrentReloadState] );
	}
	else
	{
		if( CurrentFireMode == 0 ) 
		{
			// Primary Fire with no ammo in clip reload animations and sounds
			if( CurrentAmmoInClip == 0 || ReloadAnimName[2] == '' )
			{
				PlayWeaponAnimation( ReloadAnimName[0], ReloadTime[0] );
				PlayArmAnimation( ReloadArmAnimName[0], ReloadTime[0] );
				if(Rx_Pawn(Owner) != None) {
					Rx_Pawn(Owner).ReloadAnim = ReloadAnim3PName[0];
					Rx_Pawn(Owner).TopHalfAnimSlot.PlayCustomAnimByDuration(Rx_Pawn(Owner).ReloadAnim,ReloadTime[0],0.1f,0.1f,false,true);
				}
				PlaySound( ReloadSound[0] );
			}
			// Primary Fire with 1 ore more rounds the the clip reload anims and sounds
			else
			{
				PlayWeaponAnimation( ReloadAnimName[2], ReloadTime[2] );
				PlayArmAnimation( ReloadArmAnimName[2], ReloadTime[2] );
				if(Rx_Pawn(Owner) != None) {
					Rx_Pawn(Owner).ReloadAnim = ReloadAnim3PName[0];
					Rx_Pawn(Owner).TopHalfAnimSlot.PlayCustomAnimByDuration(Rx_Pawn(Owner).ReloadAnim,ReloadTime[0],0.1f,0.1f,false,true);
				}
				PlaySound( ReloadSound[2] );
			}
		}
		else
		{
			// Secondary Fire with no ammo in clip reload animations and sounds
			if( CurrentAmmoInClip == 0 || ReloadAnimName[3] == '' )
			{
				PlayWeaponAnimation( ReloadAnimName[1], ReloadTime[1] );
				PlayArmAnimation( ReloadArmAnimName[1], ReloadTime[1] );
				if(Rx_Pawn(Owner) != None) {
					Rx_Pawn(Owner).ReloadAnim = ReloadAnim3PName[1];
					Rx_Pawn(Owner).TopHalfAnimSlot.PlayCustomAnimByDuration(Rx_Pawn(Owner).ReloadAnim,ReloadTime[1],0.1f,0.1f,false,true);
				}
				PlaySound( ReloadSound[1] );
			}
			// Secondary Fire with 1 ore more rounds the the clip reload anims and sounds
			else
			{
				PlayWeaponAnimation( ReloadAnimName[3], ReloadTime[3] );
				PlayArmAnimation( ReloadArmAnimName[3], ReloadTime[3] );
				if(Rx_Pawn(Owner) != None) {
					Rx_Pawn(Owner).ReloadAnim = ReloadAnim3PName[3];
					//Rx_Pawn(Owner).TopHalfAnimSlot.PlayCustomAnim( Rx_Pawn(Owner).ReloadAnim, 1.0, 0.1, 0.1, false, true );
					Rx_Pawn(Owner).TopHalfAnimSlot.PlayCustomAnimByDuration(Rx_Pawn(Owner).ReloadAnim,ReloadTime[3],0.1f,0.1f,false,true);
				}
				PlaySound( ReloadSound[3] );
			}
		}
	}
}

simulated function ReloadWeapon()
{
	local Rx_Controller controller;
	if (Rx_Pawn(Owner) != none)
	{
		controller = Rx_Controller(Rx_Pawn(Owner).Controller);
		
		if( controller != none && CurrentAmmoInClip <= ClipSize && CurrentAmmoInClip < AmmoCount && !CurrentlyReloading &&  controller.DoubleClickDir != controller.eDoubleClickDir.DCLICK_Active)
		{
			GotoState('Reloading');
		}
	}
}

simulated function int GetUseableAmmo()
{
	return CurrentAmmoInClip;
}

simulated function int GetMaxAmmoInClip()
{
	return default.ClipSize;
}

simulated function int GetReserveAmmo()
{
	return AmmoCount - CurrentAmmoInClip;
}

simulated function bool IsReloading()
{
	return CurrentlyReloading;
}
simulated function bool IsBoltActionReloading()
{
	return CurrentlyBoltReloading;
}

// Custom Weapon Firing state to handle reloading
simulated state WeaponFiring
{
	simulated event BeginState( Name PreviousState )
	{
		if (bDebugWeapon)
		{
			`log("---"@self$"."$GetStateName()$".BeginState("$PreviousState$")");
		}
		super.BeginState(PreviousState);
	}
	
	simulated event EndState( Name NextState )
	{
		if (bDebugWeapon)
		{
			`log("---"@self$"."$GetStateName()$".EndState("$NextState$")");
		}
		
		ClearTimer( nameof(BoltActionReloadTimer) );
		super.EndState(NextState);
	}

	/**
	 * We override BeginFire() so that we can check for zooming and/or empty weapons
	 */
	simulated function BeginFire( Byte FireModeNum )
	{
		if ( CheckZoom(FireModeNum) )
		{
			return;
		}

		Global.BeginFire(FireModeNum);

		// No Ammo, then do a quick exit.
		if( !HasAnyAmmoOfType(FireModeNum) )
		{
			WeaponEmpty();
			return;
		}
	}

	simulated function TimeWeaponFiring( byte FireModeNum )
	{
		if( BoltActionReload && !IsTimerActive('BoltActionReloadTimer') )
		{
			CurrentlyBoltReloading = true;
			SetTimer( GetFireInterval(FireModeNum) * RefireBoltReloadInterrupt[FireModeNum], false, nameof(BoltActionReloadTimer) );
		}
		else 
		{
			if(CurrentAmmoInClip <= 0 && GetFireInterval(FireModeNum) >= 0.5)
			{
				if( !IsTimerActive('RefireCheckTimer') )
				{
					SetTimer( 0.5, true, nameof(RefireCheckTimer) );
					//SetTimer( GetFireInterval(FireModeNum), true, nameof(RefireCheckTimer) );
				}
			} 
			Global.TimeWeaponFiring(FireModeNum);
		}
	}

	/**
	 * Timer event, call is set up in Weapon::TimeWeaponFiring().
	 * The weapon is given a chance to evaluate if another shot should be fired.
	 * This event defines the weapon's rate of fire.
	 */
	simulated function RefireCheckTimer()
	{
		// if switching to another weapon, abort firing and put down right away
		if( bWeaponPutDown )
		{
			PutDownWeapon();
			return;
		}


		// If weapon should keep on firing, then do not leave state and fire again.
		if( ShouldRefire() )
		{
			FireAmmunition();
			return;
		}
		
		if( CurrentAmmoInClip <= 0 && HasAnyAmmoOfType(CurrentFireMode) )
		{
			
			GotoState('Reloading');
			
			return;
		}

		// Otherwise we're done firing
		HandleFinishedFiring();
	}
	
	
	simulated function bool bReadyToFire()
	{
		
		if(!bAutoFire) return  !IsTimerActive('RefireCheckTimer');
		else
		return true; 
	}
}

simulated function BoltActionReloadTimer()
{
	if (bDebugWeapon)
	{
		`log("BoltActionReloadTimer");
	}
	
	//Once Bolt Action reloading is instated, disallow holding down the fire button. 
	ClientPendingFire[0] = false; 
	ClientPendingFire[1] = false; 
	ClearPendingFire(0); 
	ClearPendingFire(1);  
	
	if(!BoltActionReload)
		return;
	if( HasAmmo(CurrentFireMode) )
		GotoState('BoltActionReloading');
	else 
		RefireCheckTimer();
}

simulated state BoltActionReloading
{
	 function BeginState( name PreviousState )
	{
		if (bDebugWeapon)
		{
			`log("---"@self$"."$GetStateName()$".BeginState("$PreviousState$")");
		}

		reloadBeginTime = WorldInfo.TimeSeconds;
		currentReloadTime = BoltReloadTime[CurrentFireMode];
		SetTimer( BoltReloadTime[CurrentFireMode], false, 'ReloadWeaponTimer');

		if(bIronsightActivated && bUnzoomDuringBoltActionReloading)
		{
			if(WorldInfo.Netmode != NM_DedicatedServer)
			{
				if(UTPlayerController(Instigator.Controller) != None)
				{
					EndZoom(UTPlayerController(Instigator.Controller));
				}
			}
		} 
		CurrentlyBoltReloading = true;
		
		
	}

	 function EndState( name NextState )
	{
		if (bDebugWeapon)
		{
			`log("---"@self$"."$GetStateName()$".EndState("$NextState$")");
		}
		Rx_Pawn(Owner).SetHandIKEnabled(true);
		Rx_Pawn(Owner).BoltReloadAnim = '';
		ClearTimer('ReloadWeaponTimer');
	}

	simulated function ReloadWeaponTimer()
	{
		if (bDebugWeapon)
		{
			`log("---"@self$"."$GetStateName()$".ReloadWeapon()");
		}

		CurrentlyBoltReloading = false;
		PostReloadUpdate();

		//if(  (PendingFire(0) || PendingFire(1)) && ShouldRefire() ) 
		if(  (ClientPendingFire[0] || ClientPendingFire[1]) && ShouldRefire() ) 
		{
			GotoState('WeaponFiring');	
		}
		else
		{
			GotoState('Active');
		}
	}

	simulated function bool bReadyToFire()
	{
		return false ; //return true;
	}
	
	simulated function BeginFire( Byte FireModeNum )
	{
		if ( FireModeNum == 0 )
		{
			return;
		}
		global.BeginFire(FireModeNum);
	}	

	// Undo reload
	simulated function PutDownWeapon() 
	{
		ClearTimer('ReloadWeaponTimer');
		super.PutDownWeapon();
	}
	
	simulated event bool IsFiring()
	{
		return false;
	}
}

simulated function PlayWeaponBoltReloadAnim()
{
	if(BoltActionReload && HasAmmo(CurrentFireMode) && bZoomedFireMode[CurrentFireMode] == 0)
	{

		PlayWeaponAnimation( BoltReloadAnimName[CurrentFireMode], BoltReloadTime[CurrentFireMode] );
		PlayArmAnimation( BoltReloadArmAnimName[CurrentFireMode], BoltReloadTime[CurrentFireMode] );
		if(Rx_Pawn(Owner) != None) 
		{
			Rx_Pawn(Owner).BoltReloadAnim = BoltReloadAnim3PName[CurrentFireMode];
			Rx_Pawn(Owner).TopHalfAnimSlot.PlayCustomAnimByDuration(Rx_Pawn(Owner).BoltReloadAnim, BoltReloadTime[CurrentFireMode],0.1f,0.1f,false,true);
		}
		//PlaySound( BoltReloadSound[CurrentFireMode], false,true);
		PlaySound( BoltReloadSound[CurrentFireMode] );
	}
}

simulated function DrawCrosshair( Hud HUD )
{
	local float x,y;
	local UTHUDBase H;
	local Pawn MyPawnOwner;
	local actor TargetActor;
	local int targetTeam, rectColor;
	
	// rectColor is an integer representing what we will pass to the texture's parameter(ReticleColourSwitcher):
	// 0=Default, 1=Red, 2=Green, 3=Yellow
	rectColor = 0;	
	
	H = UTHUDBase(HUD);
	if ( H == None )
		return;
		
	CrosshairWidth = default.CrosshairWidth + RecoilSpread*RecoilSpreadCrosshairScaling;	
	CrosshairHeight = default.CrosshairHeight + RecoilSpread*RecoilSpreadCrosshairScaling;
		
	CrosshairLinesX = H.Canvas.ClipX * 0.5 - (CrosshairWidth * 0.5);
	CrosshairLinesY = H.Canvas.ClipY * 0.5 - (CrosshairHeight * 0.5);	
	
	MyPawnOwner = Pawn(Owner);

	//determines what we are looking at and what color we should use based on that.
	if (MyPawnOwner != None)
	{
		TargetActor = Rx_Hud(HUD).GetActorWeaponIsAimingAt();
		if (Pawn(TargetActor) == None && Rx_Weapon_DeployedActor(TargetActor) == None && 
			Rx_Building(TargetActor) == None && Rx_BuildingAttachment(TargetActor) == None)
		{
			TargetActor = (TargetActor == None) ? None : Pawn(TargetActor.Base);
		}
		
		if(TargetActor != None)
		{
			targetTeam = TargetActor.GetTeamNum();
			
			if (targetTeam == 0 || targetTeam == 1) //has to be gdi or nod player
			{
				if (targetTeam != MyPawnOwner.GetTeamNum())
				{
					if (!TargetActor.IsInState('Stealthed') && !TargetActor.IsInState('BeenShot'))
						rectColor = 1; //enemy, go red, except if stealthed (else would be cheating ;] )
				}
				else
					rectColor = 2; //Friendly
			}
		}
	}
	
	if (!HasAnyAmmo()) //no ammo, go yellow
		rectColor = 3;
	else
	{
		if (CurrentlyReloading 
				|| (CurrentlyBoltReloading || (BoltActionReload && HasAmmo(CurrentFireMode) && IsTimerActive('BoltActionReloadTimer')))) //reloading, go yellow
			rectColor = 3;
	}

	CrosshairMIC2. SetScalarParameterValue('ReticleColourSwitcher', rectColor);
	CrosshairDotMIC2. SetScalarParameterValue('ReticleColourSwitcher', rectColor);
	
	H.Canvas.SetPos( CrosshairLinesX, CrosshairLinesY );
	if(bDisplayCrosshair) {
		H.Canvas.DrawMaterialTile(CrosshairMIC2, CrosshairWidth, CrosshairHeight);
	}

	CrosshairLinesX = H.Canvas.ClipX * 0.5 - (default.CrosshairWidth * 0.5);
	CrosshairLinesY = H.Canvas.ClipY * 0.5 - (default.CrosshairHeight * 0.5);
	GetCrosshairDotLoc(x, y, H);
	H.Canvas.SetPos( X, Y );
	if(bDisplayCrosshair) {
		H.Canvas.DrawMaterialTile(CrosshairDotMIC2, default.CrosshairWidth, default.CrosshairHeight);
	}
	DrawHitIndicator(H,x,y);
	
	
	if(bDebugWeapon)
	{
	H.Canvas.DrawText("Reloading: " @ CurrentlyReloading ,true,1,1);
	Y+=20;
	H.Canvas.DrawText("Ammo: S: " @ CurrentAmmoInClip @ "C: " @ CurrentAmmoInClipClientSide,true,1,1);
	Y+=20;
	H.Canvas.DrawText("PendingFire:" @ PendingFire(0),true,1,1);
	Y+=20;
	H.Canvas.DrawText("ClientPendingFire:" @ ClientPendingFire[0],true,1,1);
	Y+=20;
	H.Canvas.DrawText("ReadyFire:" @ bReadyToFire(),true,1,1);
	Y+=20;
	H.Canvas.DrawText("Has Ammo:" @ HasAmmo(0),true,1,1);
	Y+=20;
	H.Canvas.DrawText("State" @ GetStateName(),true,1,1);
	Y+=20;
	H.Canvas.DrawText("RefireTimer" @ IsTimerActive('RefireCheckTimer') ,true,1,1);
	}
	
}

simulated function DrawHitIndicator(HUD H, float x, float y)
{
	local vector2d CrosshairSize;
	
	if(Rx_Hud(H).GetHitEffectAplha() <= 0.0) {
		return;
	}	
    CrosshairSize.Y = default.CrosshairHeight;
    CrosshairSize.X = default.CrosshairWidth;
    H.Canvas.SetPos(x, y);
    HitIndicatorCrosshairMIC2.SetScalarParameterValue('Reticle_Opacity', Rx_Hud(H).GetHitEffectAplha()/100.0);
    H.Canvas.DrawMaterialTile(HitIndicatorCrosshairMIC2,CrosshairSize.X, CrosshairSize.Y,0.0,0.0,1.0,1.0);
}
/**
 * Called when the weapon runs out of ammo during firing
 */
simulated function WeaponEmpty()
{
	if (bDebugWeapon) 
	{
		`log("---"@self$"."$GetStateName()$".WeaponEmpty()"@IsFiring()@Instigator@Instigator.IsLocallyControlled());
		ScriptTrace();
	}

	// If we were firing, stop
	if ( IsFiring() )
	{
		GotoState('Active');
	}

	
	if ( (Rx_Weapon_Deployable(self) != None || Rx_Weapon_Airstrike(Self) != None) && Instigator != none && Instigator.IsLocallyControlled() )
	{
		Instigator.InvManager.SwitchToBestWeapon( true );
	}
}


DefaultProperties
{
	ReloadTime(0) = 1.0f
	ReloadTime(1) = 1.0f
	ReloadAnim3PName(0) = "H_M_Autorifle_Reload"
	ReloadAnim3PName(1) = "H_M_Autorifle_Reload"
	bDebugWeapon = true
	
	BoltActionReload=false
	BoltReloadTime(0) = 1.0f
	BoltReloadTime(1) = 1.0f
	RefireBoltReloadInterrupt(0) = 0.25f
	RefireBoltReloadInterrupt(1) = 0.25f
	BoltReloadAnimName(0) = "WeaponBolt"
	BoltReloadAnimName(1) = "WeaponBolt"
	BoltReloadAnim3PName(0) = "H_M_BoltReload"
	BoltReloadAnim3PName(1) = "H_M_BoltReload"
	BoltReloadArmAnimName(0) = "WeaponBolt"
	BoltReloadArmAnimName(1) = "WeaponBolt"
	BoltReloadSound(0)=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_Reload'
	BoltReloadSound(1)=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_Reload'

	PerBulletReload = false;
	bHasInfiniteAmmo = false;
}
