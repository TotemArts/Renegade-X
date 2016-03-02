class Rx_Vehicle_Weapon_Reloadable extends Rx_Vehicle_Weapon
	abstract;

var() int ClipSize;
var() int InitalNumClips;
var() int MaxClips;

var repnotify int CurrentAmmoInClip;
var int CurrentAmmoInClipClientside;
var bool HasInfiniteAmmo;
var repnotify bool CurrentlyReloading;
var bool CurrentlyFireing;

var() name ReloadAnimName[4];
var() name ReloadArmAnimName[4];
var() SoundCue ReloadSound[4];

//info for reload animation timing
var float reloadBeginTime;
var float currentReloadTime;

replication
{
	if( bNetOwner && bNetDirty )
		CurrentAmmoInClip, CurrentlyReloading, CurrentlyFireing;
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
	//`log("Replicate Reloading"); 
		if(CurrentlyReloading == false) 
		{
			CurrentAmmoInClipClientside = ClipSize;
			/**REMOVE when confirmed to work 
			if( (PendingFire(0) || PendingFire(1)) && CurrentlyFireing) 
			{
				GotoState('WeaponFiring');	
			} */
			if( (ClientPendingFire[0] && CurrentFireMode == 0) || (ClientPendingFire[1] && CurrentFireMode == 1) && CurrentlyFireing ) 
			{
				RestartWeaponFiringAfterReload();	
			} 
			else 
			{
				if(!ShouldRefire()) {
					ClearPendingFire(0);
					ClearPendingFire(1);
				}
				GotoState('Active');
			}
			PostReloadUpdate();
		} 
		else 
		{
			reloadBeginTime = WorldInfo.TimeSeconds;
			currentReloadTime = ReloadTime[CurrentFireMode];		
		}	
    }
    else if (VarName == 'CurrentAmmoInClip')
	{
		if(CurrentAmmoInClip == ClipSize)
		{
			CurrentAmmoInClipClientside = ClipSize;	
		}
    }
	else
    {
    	super.ReplicatedEvent(VarName);
    } 
}

simulated function Activate()
{
	if (WorldInfo.NetMode == NM_Client)
		CurrentAmmoInClipClientside = CurrentAmmoInClip;
	super.Activate();
}

//Added from Rx_Weapon_Reloadable - May be used 
simulated function RestartWeaponFiringAfterReload()
{
	`log("Fire After Reload"); 
	if(ROLE < ROLE_Authority || WorldInfo.Netmode == NM_Standalone) 
	{
	GotoState('Active');	
	
	StartFire(CurrentFireMode);  	
	}
}

state Reloading
{
	function BeginState( name PreviousState )
	{
		if (bDebugWeapon)
		{
			`log("---"@self$"."$GetStateName()$".BeginState("$PreviousState$")");
		}
		if(!bReloadAfterEveryShot) {
			PlayWeaponReloadAnim();
		}
		CurrentlyReloading = true;
		reloadBeginTime = WorldInfo.TimeSeconds;
		currentReloadTime = ReloadTime[CurrentFireMode];
		SetTimer( ReloadTime[CurrentFireMode], false, 'ReloadWeaponTimer');
		CurrentlyFireing = false;
		if(WorldInfo.Netmode == NM_DedicatedServer) 
			{
			ClearPendingFire(0);
			ClearPendingFire(1);			
			}
	}

	function EndState( name NextState )
	{
		if (bDebugWeapon)
		{
			`log("---"@self$"."$GetStateName()$".EndState("$NextState$")");
		}
	}

	function ReloadWeaponTimer()
	{
		if (bDebugWeapon)
		{
			`log("---"@self$"."$GetStateName()$".ReloadWeapon()");
		}

		if (HasInfiniteAmmo) 
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

		/**if( (PendingFire(0) || PendingFire(1)) && ShouldRefire() ) 
		
		{
			CurrentlyFireing = true;
			GotoState('WeaponFiring');	
		}
		else
		{
			GotoState('Active');
		}
		bForceNetUpdate = true;*/
		
		if((ClientPendingFire[0] && CurrentFireMode == 0) || (ClientPendingFire[1] && CurrentFireMode == 1) )
		{
			RestartWeaponFiringAfterReload();	
		}
		else
		{
			GotoState('Active');
		}
		bForceNetUpdate = true;
	}

	simulated function bool bReadyToFire()
	{
		return !CurrentlyReloading; //false;
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
		super.BeginState(PrevStateName);
		if (bDebugWeapon)
		{
			`log("---"@self$"."$GetStateName()$".EndState("$PrevStateName$")");
		}
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
		return  !IsTimerActive('RefireCheckTimer') && !CurrentlyReloading; //!CurrentlyReloading;
	}

}

function ConsumeAmmo( byte FireModeNum )
{
	CurrentAmmoInClip -= ShotCost[FireModeNum];
	super.ConsumeAmmo( FireModeNum );
}

simulated function ConsumeClientsideAmmo( byte FireModeNum )
{
	CurrentAmmoInClipClientside -= ShotCost[FireModeNum];
}

// if this gun has any ammo in current clip it will return true.
simulated function bool HasAmmo( byte FireModeNum, optional int Amount )
{
	if( Amount==0 )
	{
		if (CurrentAmmoInClip < ShotCost[FireModeNum] || CurrentAmmoInClipClientside < ShotCost[FireModeNum] )
			return false;
		else
			return true;
	}
	else
	{
		if (CurrentAmmoInClip < Amount || CurrentAmmoInClipClientside < Amount )
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

function PlayWeaponReloadAnim()
{
	if( CurrentFireMode == 0 )
	{
		// Primary Fire with no ammo in clip reload animations and sounds
		if( CurrentAmmoInClip == 0 || ReloadAnimName[2] == '' )
		{
			//PlayWeaponAnimation( ReloadAnimName[0], ReloadTime[0] );
			//PlayArmAnimation( ReloadArmAnimName[0], ReloadTime[0] );
			if(Role == ROLE_Authority && ReloadSound[0] != None) {
				MyVehicle.PlaySound( ReloadSound[0]);
			}
		}
		// Primary Fire with 1 ore more rounds the the clip reload anims and sounds
		else
		{
			//PlayWeaponAnimation( ReloadAnimName[2], ReloadTime[2] );
			//PlayArmAnimation( ReloadArmAnimName[2], ReloadTime[2] );
			if(Role == ROLE_Authority && ReloadSound[2] != None) {
				MyVehicle.PlaySound( ReloadSound[2]);
			}
		}
	}
	else
	{
		// Secondary Fire with no ammo in clip reload animations and sounds
		if( CurrentAmmoInClip == 0 || ReloadAnimName[3] == '' )
		{
			//PlayWeaponAnimation( ReloadAnimName[1], ReloadTime[1] );
			//PlayArmAnimation( ReloadArmAnimName[1], ReloadTime[1] );
			if(Role == ROLE_Authority && ReloadSound[1] != None) {
				MyVehicle.PlaySound( ReloadSound[1]);
			}
		}
		// Secondary Fire with 1 ore more rounds the the clip reload anims and sounds
		else
		{
			//PlayWeaponAnimation( ReloadAnimName[3], ReloadTime[3] );
			//PlayArmAnimation( ReloadArmAnimName[3], ReloadTime[3] );
			if(Role == ROLE_Authority && ReloadSound[3] != None) {
				MyVehicle.PlaySound( ReloadSound[3]);
			}
		}
	}
}

function ReloadWeapon()
{	
	if( CurrentAmmoInClip != ClipSize  && !CurrentlyReloading )
	{
		GotoState('Reloading');
	}
}

simulated function int GetUseableAmmo()
{
	return CurrentAmmoInClip;
}

simulated function int GetReserveAmmo()
{
	return AmmoCount - CurrentAmmoInClip;
}

simulated function bool IsReloading()
{
	return CurrentlyReloading || CurrentlyReloadingClientside;
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
		
		if( bReloadAfterEveryShot && !HasAmmo(CurrentFireMode) )
		{
			PlayWeaponReloadAnim();
			`log("Set reload timer in WeaponFiringState"); 
			SetTimer(ReloadTime[CurrentFireMode],false,'GoToReloading');
			return;
		}	
	}
	
	simulated function GoToReloading()
	{
		GotoState('Reloading');
	}
	
	simulated event EndState( Name NextState )
	{
		if (bDebugWeapon)
		{
			`log("---"@self$"."$GetStateName()$".EndState("$NextState$")");
		}
		
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
		
		if( !HasAmmo(CurrentFireMode) )
		{
			GotoState('Reloading');
			return;
		}		

		// Otherwise we're done firing
		HandleFinishedFiring();
	}
simulated function bool bReadyToFire()
	{
		
		return true; 
	}

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

	if ( Instigator != none && Instigator.IsLocallyControlled() )
	{
		Instigator.InvManager.SwitchToBestWeapon( true );
	}
}

simulated function int GetMaxAmmoInClip()
{
	return ClipSize;
}

simulated function DrawCrosshair( Hud HUD )
{
	local vector2d CrosshairSize;
	local float x,y;	
	local UTHUDBase H;
	local Pawn MyPawnOwner;
	local actor TargetActor;
	local int targetTeam, rectColor;	
	
	H = UTHUDBase(HUD);
	if ( H == None )
		return;

 	CrosshairSize.Y = CrosshairHeight;
	CrosshairSize.X = CrosshairWidth;

	X = H.Canvas.ClipX * 0.5 - (CrosshairSize.X * 0.5);
	Y = H.Canvas.ClipY * 0.5 - (CrosshairSize.Y * 0.5);

	
	MyPawnOwner = Pawn(Owner);

	//determines what we are looking at and what color we should use based on that.
	if (MyPawnOwner != None)
	{
		TargetActor = Rx_Hud(HUD).GetActorWeaponIsAimingAt();
		
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
		if ( CurrentlyReloading && bReloadAfterEveryShot) //reloading, go yellow
			rectColor = 3;
	}

	CrosshairMIC2.SetScalarParameterValue('ReticleColourSwitcher', rectColor);
	if ( CrosshairMIC2 != none )
	{
		//H.Canvas.SetPos( X+1, Y+1 );
		H.Canvas.SetPos( X, Y );
		H.Canvas.DrawMaterialTile(CrosshairMIC2,CrosshairSize.X, CrosshairSize.Y,0.0,0.0,1.0,1.0);
		DrawHitIndicator(H,x,y);
	}
	
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

DefaultProperties
{
	InventoryGroup=6
	ReloadTime(0) = 1.0f
	ReloadTime(1) = 1.0f
	HasInfiniteAmmo = true;
	bDebugWeapon=false; 
}
