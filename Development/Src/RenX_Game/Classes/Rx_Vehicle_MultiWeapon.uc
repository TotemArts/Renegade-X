
class Rx_Vehicle_MultiWeapon extends Rx_Vehicle_Weapon
	abstract;

var	localized string	AltItemName;

var() int ClipSize[2];

var repnotify int CurrentAmmoInClip[2];
var int CurrentAmmoInClipClientSide[2];

/** Reload bools for both primary and secondary weapons */
var repnotify bool PrimaryReloading, SecondaryReloading;

//info for reload animation timing
var float primaryReloadBeginTime;
var float currentPrimaryReloadTime;
var float secondaryReloadBeginTime;
var float currentSecondaryReloadTime;



replication
{
	// Server->Client properties
	if ( bNetOwner && bNetDirty && Role == ROLE_Authority )
		CurrentAmmoInClip, PrimaryReloading, SecondaryReloading, 
			currentPrimaryReloadTime, currentSecondaryReloadTime;
}

simulated event ReplicatedEvent( name VarName )
{
	if ( VarName == 'PrimaryReloading')
	{
		if(PrimaryReloading)
		{
			primaryReloadBeginTime = WorldInfo.TimeSeconds;
		}
		else
		{
			CurrentAmmoInClipClientside[0] = ClipSize[0];
		}
	}
	else if ( VarName == 'SecondaryReloading' )
	{
		if(SecondaryReloading)
		{
			secondaryReloadBeginTime = WorldInfo.TimeSeconds;
		}
		else
		{
			CurrentAmmoInClipClientside[1] = ClipSize[1];
		}
	} 
	else if (VarName == 'CurrentAmmoInClip')
	{
		if(CurrentAmmoInClip[0] == ClipSize[0])
		{
			CurrentAmmoInClipClientside[0] = ClipSize[0];	
		}
		if(CurrentAmmoInClip[1] == ClipSize[1])
		{
			CurrentAmmoInClipClientside[1] = ClipSize[1];
		}
    }
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

event PreBeginPlay()
{
	// setup primary ammo
	CurrentAmmoInClip[0] = ClipSize[0];
	PrimaryReloading = false;
	CurrentAmmoInClipClientSide[0] = ClipSize[0];
	// setup secondary ammo
	CurrentAmmoInClip[1] = ClipSize[1];
	SecondaryReloading = false;
	CurrentAmmoInClipClientSide[1] = ClipSize[1];
	bForceNetUpdate = true;
	super.PreBeginPlay();
}

simulated function Activate()
{
	if (WorldInfo.NetMode == NM_Client)
	{
		CurrentAmmoInClipClientside[0] = CurrentAmmoInClip[0];
		CurrentAmmoInClipClientside[1] = CurrentAmmoInClip[1];
	}
	super.Activate();
}

simulated function int GetUseableAmmo()
{
	return CurrentAmmoInClip[0];
}
simulated function int GetAltUseableAmmo()
{
	return CurrentAmmoInClip[1];
}
simulated function int GetMaxAmmoInClip()
{
	return default.ClipSize[0];
}
simulated function int GetMaxAltAmmoInClip()
{
	return default.ClipSize[1];
}

function ConsumeAmmo( byte FireModeNum )
{

	// ammo must get remmoved from clip and it doesnt change weither 
	// or not it is primary or secondary fire
	CurrentAmmoInClip[FireModeNum] -= ShotCost[FireModeNum];
	if(CurrentAmmoInClip[FireModeNum] < 0)
		`log("---");
}

simulated function ConsumeClientsideAmmo( byte FireModeNum )
{
	CurrentAmmoInClipClientside[FireModeNum] -= ShotCost[FireModeNum];
}

// if this gun has any ammo in current firemode clip it will return true.
simulated function bool HasAmmo( byte FireModeNum, optional int Amount = 0 )
{
	if( Amount==0 )
	{
		if (CurrentAmmoInClip[FireModeNum] < ShotCost[FireModeNum] || CurrentAmmoInClipClientside[FireModeNum] < ShotCost[FireModeNum])
			return false;
		else
			return true;
	}
	else
	{
		if (CurrentAmmoInClip[FireModeNum] < Amount || CurrentAmmoInClipClientside[FireModeNum] < Amount)
			return false;
		else
			return true;
	}
}

// If this gun has any ammo for a specific weapon it returns true.
simulated function bool HasAnyAmmoOfType( byte FireModeNum )
{
	if( ( FireModeNum == 0 &&  CurrentAmmoInClip[0] > 0 ) ||
		( FireModeNum == 1 &&  CurrentAmmoInClip[1] > 0 ) )
	{
		return true;
	}
	return false;
}


simulated state Active
{
	// boilerplate debug stuff
	simulated function BeginState(Name PreviousState)
	{
		super.BeginState(PreviousState);
		if (bDebugWeapon)
		{
			`log("---"@self$" Coming from state"@PreviousState@"to state"@GetStateName());
		}

	}

	// boilerplate debug stuff
	simulated function EndState( Name NextState )
	{
		super.EndState(NextState);
		if (bDebugWeapon)
		{
			`log("---"@self$" Goint to state"@NextState@"From state"@GetStateName());
		}
	}

	// make sure that one weapon isnt reloading
	simulated function bool bReadyToFire()
	{
		return (!PrimaryReloading || !SecondaryReloading);
	}

		/** Override BeginFire so that it will enter the firing state right away. */
	simulated function BeginFire(byte FireModeNum)
	{
		if( !bDeleteMe && Instigator != None )
		{
			
			Global.BeginFire(FireModeNum);

			// in the active state, fire right away if we have the ammunition
			//If there is no ammo, check to see if the reload timer is set
			//if the reload timer isn't set, go ahead and set it
			//This addresses a bug in the system where firing may cancel the reload timer
			if( PendingFire(FireModeNum) && HasAmmo(FireModeNum) && !IsReloading(FireModeNum) )
			{
				SendToFiringState(FireModeNum);
			}
			// Go to reload for Primary
			else if( CurrentFireMode == 0 && CurrentAmmoInClip[0] <= 0 && !PrimaryReloading )
			{
				PrimaryReload();
			}
			// Go to Reload for Secondary
			else if( CurrentFireMode == 1 && CurrentAmmoInClip[1] <= 0 && !SecondaryReloading )
			{
				SecondaryReload();
			}

		}
	}

}

simulated function FireAmmunition()
{
	if(IsReloading(CurrentFireMode)) {
		return;
	}
	super.FireAmmunition();
}

// Custom Weapon Firing state to handle reloading
simulated state WeaponFiring
{
	// boilerplate debug stuff
	simulated event BeginState( Name PreviousState )
	{
		if (bDebugWeapon)
		{
			`log("---"@self$" Coming from state"@PreviousState@"to state"@GetStateName());
		}

		super.BeginState(PreviousState);
	}
	// boilerplate debug stuff
	simulated event EndState( Name NextState )
	{
		if (bDebugWeapon)
		{
			`log("---"@self$" Goint to state"@NextState@"From state"@GetStateName());
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
		// if we have no ammo then check to see if we can reload
		if( !IsReloading(CurrentFireMode) && !HasAmmo(CurrentFireMode) )
		{
			//ClearTimer(nameof(RefireCheckTimer));
			// Go to reload for Primary
			if( CurrentFireMode == 0 && !PrimaryReloading )
			{
				PrimaryReload();
			}
			// Go to Reload for Secondary
			else if( CurrentFireMode == 1 && !SecondaryReloading )
			{
				SecondaryReload();
			}
		}

		// Otherwise we're done firing
		HandleFinishedFiring();
	}
}

simulated function bool IsReloading( byte FireMode )
{
	if(CurrentlyReloadingClientside) 
		return true;
		
	if( FireMode == 0 )
	{
		return PrimaryReloading;
	}
	else if( FireMode == 1 )
	{
		return SecondaryReloading;
	}
}

simulated function bool NeedsReload( byte FireMode )
{
	if ( FireMode == 0 )
	{
		if( CurrentAmmoInClip[0] < ClipSize[0] )
		{
			return true;
		}
		return false;
	}
	else if ( FireMode == 1 )
	{
		if( CurrentAmmoInClip[1] < ClipSize[1] )
		{
			return true;
		}
		return false;
	}
}
// a reload caused by the player pushing the reload key
simulated function PlayerRelaod()
{
	if (!IsReloading(0) && NeedsReload(0) )
	{
		PrimaryReload();
	}
	if (!IsReloading(1) && NeedsReload(1))
	{
		SecondaryReload();
	}
}

simulated function PrimaryReload()
{
	PrimaryReloading = true;
	primaryReloadBeginTime = WorldInfo.TimeSeconds;
	currentPrimaryReloadTime = ReloadTime[0];
	SetTimer(ReloadTime[0],false,'PrimaryReloadTimer' );
}

simulated function SecondaryReload()
{
	SecondaryReloading = true;
	secondaryReloadBeginTime = WorldInfo.TimeSeconds;
	currentSecondaryReloadTime = ReloadTime[1];
	SetTimer(ReloadTime[1],false,'SecondaryReloadTimer');
}

simulated function PrimaryReloadTimer()
{
	ReloadWeapon(0);
}

simulated function SecondaryReloadTimer()
{
	ReloadWeapon(1);
}

simulated function ReloadWeapon( byte FireMode )
{

	CurrentAmmoInClip[FireMode] = ClipSize[FireMode];

	if( FireMode == 0 )
	{
		PrimaryReloading = false;
	}
	else if( FireMode == 1 )
	{   
		SecondaryReloading = false;
	}

	if( PendingFire(FireMode) ) 
	{
		SetCurrentFireMode(FireMode);
		GotoState('WeaponFiring');	
	}
	else if(!PrimaryReloading && !SecondaryReloading)
	{
		GotoState('Active');
	}
}

simulated function SetCurrentFireMode(byte FiringModeNum)
{
	super.SetCurrentFireMode(FiringModeNum);
}


DefaultProperties
{
	InventoryGroup=16

	AmmoCount = 999
}
