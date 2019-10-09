class Rx_Vehicle_MultiWeapon extends Rx_Vehicle_Weapon
	abstract;
//8AUG2015: Added SecondaryReloadTimer and ClientSide reloading of the secondary to fix reload bug.

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

var bool CurrentlyReloadingSecondaryClientside; //////////////ADDED TO DIFFERENTIATE WEAPONS (Also edited in RX_Controller so that pressing R to reload did not completely bone both weapons)

//Veterancy
var float Vet_ReloadSpeedModifier[4]; //*X
var int Vet_ClipSizeModifier[4];  //+X
var float Vet_ROFSpeedModifier[4];
//Secondary Weapons
var float Vet_SecondaryReloadSpeedModifier[4]; //*X
var int Vet_SecondaryClipSizeModifier[4];  //+X
var float Vet_SecondaryROFSpeedModifier[4];

var int ShotsFired[2]; 

var SoundCue ReloadSound[2] ;
/**
replication
{
	
	/Server->Client properties
	if ( bNetOwner && bNetDirty && Role == ROLE_Authority )
		CurrentAmmoInClip, PrimaryReloading, SecondaryReloading, 
			currentPrimaryReloadTime, currentSecondaryReloadTime;
}
*/

simulated event ReplicatedEvent( name VarName )
{
	if ( VarName == 'PrimaryReloading')
	{
		if(PrimaryReloading)
		{
			primaryReloadBeginTime = WorldInfo.TimeSeconds;
			
			//`log("Set Primary to Reload" @ primaryReloadBeginTime);
		}
		else
		{			
			CurrentAmmoInClipClientside[0] = ClipSize[0];
			
			if( (ClientPendingFire[0] && CurrentFireMode == 0) ) 
			{
				RestartWeaponFiringAfterReload(0);	
			} 
			//`log("Set Current Ammo in Clip" @ CurrentAmmoInClipClientside[0]);
		}
	}
	
	else if ( VarName == 'SecondaryReloading' )
	{
		if(SecondaryReloading)
		{
			secondaryReloadBeginTime = WorldInfo.TimeSeconds;
			//`log("Set Secondary Reload" @ secondaryReloadBeginTime);
		}
		else
		{
			CurrentAmmoInClipClientside[1] = ClipSize[1];
			
			if( (ClientPendingFire[1] && CurrentFireMode == 1) ) 
			{
				RestartWeaponFiringAfterReload(1);	
			} 
			//`log("Set Secondary ClipSize" @ CurrentAmmoInClipClientside[1]);
		}
	} 
	
	else if (VarName == 'CurrentAmmoInClip')
	{
		if(CurrentAmmoInClip[0] == ClipSize[0])
		{
			CurrentAmmoInClipClientside[0] = ClipSize[0];	
			//`log("Set Primary ClipSize after Ammo in Clip Replicated:" @ CurrentAmmoInClipClientside[0]);
		}
		if(CurrentAmmoInClip[1] == ClipSize[1])
		{
			CurrentAmmoInClipClientside[1] = ClipSize[1];
			//`log("Set Secondary ClipSize after Ammo in Clip Replicated:" @ CurrentAmmoInClipClientside[1]);
		}
    }
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

reliable client function ReplicateVRank(byte rank)
{
	super(Rx_Vehicle_Weapon).ReplicateVRank(rank); 
	ClipSize[0]=default.ClipSize[0]+Vet_ClipSizeModifier[VRank]; 
	ClipSize[1]=default.ClipSize[1]+Vet_SecondaryClipSizeModifier[VRank]; 
}

simulated event PreBeginPlay()
{
	if(ROLE == ROLE_Authority)
	{
		// setup primary ammo
		CurrentAmmoInClip[0] = ClipSize[0];
		PrimaryReloading = false;
		// setup secondary ammo
		CurrentAmmoInClip[1] = ClipSize[1];
		SecondaryReloading = false;
		bForceNetUpdate = true;
		super.PreBeginPlay();
	}
}

//Added from Rx_Weapon_Reloadable - May be used 
simulated function RestartWeaponFiringAfterReload(byte FireModeNum)
{
	GotoState('Active');		
	StartFire(FireModeNum);  	
}

simulated function Activate()
{	
	ServerReplicateAmmo();
	//`log("Activate"); 
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
	return ClipSize[0]; //default.
}
simulated function int GetMaxAltAmmoInClip()
{
	return ClipSize[1];//default.
}

simulated function ConsumeAmmo( byte FireModeNum )
{
	//`log("ConsumeAmmo called"); 
	CurrentAmmoInClip[FireModeNum] -= ShotCost[FireModeNum];
	
}

simulated function ConsumeClientsideAmmo( byte FireModeNum )
{
	CurrentAmmoInClipClientside[FireModeNum] -= ShotCost[FireModeNum];
}

// if this gun has any ammo in current firemode clip it will return true.
simulated function bool HasAmmo( byte FireModeNum, optional int Amount = 0 )
{
	//`log("Checking AMmo");
	
	//ScriptTrace(); 
	if( Amount==0 )
	{
		
			//`log( CurrentAmmoInClip[FireModeNum] >= ShotCost[FireModeNum]); 
		return CurrentAmmoInClip[FireModeNum] >= ShotCost[FireModeNum];
		
	}
	else
	{
		return CurrentAmmoInClip[FireModeNum] >= Amount ; 
	}
}

// If this gun has any ammo for a specific weapon it returns true.
simulated function bool HasAnyAmmoOfType( byte FireModeNum )
{
	if( ( FireModeNum == 0 &&  CurrentAmmoInClip[0] > 0 ) ||
		( FireModeNum == 1 &&  CurrentAmmoInClip[1] > 0 ) )
	{
		//`log("Has ammo in something");
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
			//`log("---"@self$" Coming from state"@PreviousState@"to state"@GetStateName());
		}

	}

	// boilerplate debug stuff
	simulated function EndState( Name NextState )
	{
		super.EndState(NextState);
		if (bDebugWeapon)
		{
			//`log("---"@self$" Goint to state"@NextState@"From state"@GetStateName());
		}
	}

	// make sure that one weapon isnt reloading
	simulated function bool bReadyToFire()
	{
		//return true;
		if(CurrentFireMode == 0)  
		{
			//`log("Refire timer active or primary reloading ");
			return !PrimaryReloading && !IsTimerActive('RefireCheckTimer') ;
		}
		else
		{
			//`log("Refire timer active or Secondary reloading ");
			return !SecondaryReloading && !IsTimerActive('SecondaryRefireCheckTimer') ;
		}
		 
	}

		/** Override BeginFire so that it will enter the firing state right away. */
	simulated function BeginFire(byte FireModeNum)
	{
		//`log("Made it to Begin Fire");
		if( !bDeleteMe && Instigator != None )
		{
			//`log("Made it to begin fire 2"); 
			Global.BeginFire(FireModeNum);

			// in the active state, fire right away if we have the ammunition
			//If there is no ammo, check to see if the reload timer is set
			//if the reload timer isn't set, go ahead and set it
			//This addresses a bug in the system where firing may cancel the reload timer
			
		
			
			//`log("Begin Fire: " @ PendingFire(FireModeNum) @ HasAmmo(FireModeNum) @ !IsReloading(FireModeNum) ); 
			
			if(PendingFire(FireModeNum) && HasAmmo(FireModeNum) && !IsReloading(FireModeNum) )
			{
				SendToFiringState(FireModeNum);
			}
			else 
			//if( CurrentFireMode == 0 && CurrentAmmoInClip[0] <= 0 && !PrimaryReloading )
			if(CurrentAmmoInClip[0] <= 0 && !PrimaryReloading )
			{
				PrimaryReload();
			}
			// Go to Reload for Secondary
			else// if( CurrentFireMode == 1 && CurrentAmmoInClip[1] <= 0 && !SecondaryReloading )
			if(CurrentAmmoInClip[1] <= 0 && !SecondaryReloading )
			{
				SecondaryReload();			
			}

		}
	}
}

simulated function FireAmmunition()
{
	//scripttrace();
	if(IsReloading(CurrentFireMode)) {
		//`log("Is Reloading Firemode" @ CurrentFireMode);
		return;
	}
	ShotsFired[CurrentFireMode]++;
	//`log("ShotsFired: " @ ShotsFired[CurrentFireMode]);
	
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
		//scriptrace(); 
		`LogInv("PreviousStateName:" @ PreviousState);
		// Fire the first shot right away EDIT: DO NOT DO THAT. WTF. EPIC?!
		if(bReadyToFire()) 
			FireAmmunition();
		
		TimeWeaponFiring( CurrentFireMode );
	}
	
	// boilerplate debug stuff
	simulated event EndState( Name NextState )
	{
		if (bDebugWeapon)
		{
			//`log("---"@self$" Goint to state"@NextState@"From state"@GetStateName());
		}
		
		super.EndState(NextState);
		ClearTimer( nameof(SecondaryRefireCheckTimer) );
	}

	/**
	 * We override BeginFire() so that we can check for zooming and/or empty weapons
	 */
	simulated function BeginFire( Byte FireModeNum )
	{
		if ( CheckZoom(FireModeNum) )
		{
			//`log("Weapon Zoomed");
			return;
		}

		Global.BeginFire(FireModeNum);

		// No Ammo, then do a quick exit.
		if( !HasAnyAmmoOfType(FireModeNum) )
		{
			//`log("Weapon empty" @ FireModeNum);
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
		if( bWeaponPutDown )
		{
			PutDownWeapon();
			return;
		}

		// If weapon should keep on firing, then do not leave state and fire again.
		if(CurrentFireMode == 0 && ShouldRefire() )
		{
			FireAmmunition();
			return;
		}
		// if we have no ammo then check to see if we can reload
		
		if( !IsReloading(0) && !HasAmmo(0) && !PrimaryReloading)
		
			{
				//`log("Reloading Primary");
				PrimaryReload();				
			}
			
			HandleFinishedFiring();
	}
	
	simulated function SecondaryRefireCheckTimer()
	{
		if( bWeaponPutDown )
		{
			PutDownWeapon();
			return;
		}

		// If weapon should keep on firing, then do not leave state and fire again.
		if(CurrentFireMode == 1 && ShouldRefire() )
		{
			FireAmmunition();
			return;
		}
			// if we have no ammo then check to see if we can reload
			// Go to Reload for Secondary
			if(!IsReloading(1) && !HasAmmo(1) && !SecondaryReloading )
			{
				//`log("Reloading Secondary");
				SecondaryReload();
			}
		
		// We're done firing this weapon, but possibly not our primary
			HandleFinishedFiring();
	}
	
	simulated function bool bReadyToFire()
	{
		return CurrentFireMode == 0 ? !IsTimerActive('RefireCheckTimer') : !IsTimerActive('SecondaryRefireCheckTimer') ; 
	}
}

simulated function HandleClientReload()
{
	//`log("Handle Client Reload Called");
	if (!IsReloading(0) && NeedsReload(0))
	{
		/**CurrentlyReloadingClientside=true;
		if(!IsTimerActive('SetCurrentlyReloadingClientsideToFalseTimer')) SetTimer(ReloadTime[0]*Vet_ReloadSpeedModifier[Vrank],false,'SetCurrentlyReloadingClientsideToFalseTimer');
		*/
	}
	
	if (!IsReloading(1) && NeedsReload(1))
	{
		/**CurrentlyReloadingSecondaryClientside=true;
		if(!IsTimerActive('SetCurrentlyReloadingSecondaryClientsideToFalseTimer')) SetTimer(ReloadTime[1]*Vet_SecondaryReloadSpeedModifier[Vrank],false,'SetCurrentlyReloadingSecondaryClientsideToFalseTimer');
		*/
	}
	
	
}


simulated function bool IsReloading( byte FireMode )
{
	
	
	if( FireMode == 0 )
	{	
	//`log("Reloading Primary" @ PrimaryReloading);	
	return PrimaryReloading;
	}
	
	else if( FireMode == 1 )
	
	{		
		//`log("Reloading Secondary" @ SecondaryReloading);
		return SecondaryReloading;
	}
}

simulated function bool NeedsReload( byte FireMode )
{
	if ( FireMode == 0 )
	{
		if( CurrentAmmoInClip[0] < ClipSize[0] )
		{
			//`log("Primary Needs Reload" @ CurrentAmmoInClip[0] $ "/" $ ClipSize[0]);
			return true;
		}
		return false;
	}
	else if ( FireMode == 1 )
	{
		if( CurrentAmmoInClip[1] < ClipSize[1] )
		{
			//`log("Secondary Needs Reload" @ CurrentAmmoInClip[1] $ "/" $ ClipSize[1]);
			return true;
		}
		return false;
	}
	else
	return false; 
}
// a reload caused by the player pushing the reload key
simulated function PlayerRelaod()
{
	if (!IsReloading(0) && NeedsReload(0) )
	{
		//`log("Pushed Primary Reload" @ NeedsReload(0) @ IsReloading(0));
		
		PrimaryReload();
	}
	if (!IsReloading(1) && NeedsReload(1))
	{
		//`log("Pushed Secondary Reload" @ NeedsReload(1) @ IsReloading(1));
		
		SecondaryReload();
	}
	//`log("Primary ReloadingV: " @ PrimaryReloading);
	//`log("Secondary ReloadingV: " @ SecondaryReloading);
}

simulated function PrimaryReload()
{
	//`log("Called For PrimaryReload");
	PrimaryReloading = true;
	primaryReloadBeginTime = WorldInfo.TimeSeconds;
	currentPrimaryReloadTime = ReloadTime[0]*GetReloadSpeedModifier();
	SetTimer(ReloadTime[0]*GetReloadSpeedModifier(),false,'PrimaryReloadTimer' );
	
	if(Role == ROLE_Authority)
		PlayWeaponReloadEffects(0); 
	
	if(WorldInfo.NetMode == NM_Client) 
		NotifyServerOfReload(ShotsFired[0], 0); 
	ShotsFired[0] = 0;
}

simulated function SecondaryReload()
{
	//`log("Called For SecondaryReload");
	SecondaryReloading = true;
	secondaryReloadBeginTime = WorldInfo.TimeSeconds;
	currentSecondaryReloadTime = ReloadTime[1]*GetSecondaryReloadSpeedModifier();
	SetTimer(ReloadTime[1]*GetSecondaryReloadSpeedModifier(),false,'SecondaryReloadTimer');
	
	if(Role == ROLE_Authority)
		PlayWeaponReloadEffects(1); 
	
	if(WorldInfo.NetMode == NM_Client) 
		NotifyServerOfReload(ShotsFired[1],1); 
	ShotsFired[1] = 0;
}

simulated function PrimaryReloadTimer()
{
	ReloadWeapon(0);
	//`log("Primary Reloaded");
}

simulated function SecondaryReloadTimer()
{
	ReloadWeapon(1);
	//`log("Secondary Reloaded");
}

simulated function ReloadWeapon( byte FireMode )
{
	CurrentAmmoInClip[FireMode] = ClipSize[FireMode];
	if(ROLE < ROLE_Authority) CurrentAmmoInClipClientSide[FireMode] = ClipSize[FireMode];

	if( FireMode == 0 )
	{
		PrimaryReloading = false;
	}
	else if( FireMode == 1 )
	{   
		SecondaryReloading = false;
	}

	if(ClientPendingFire[FireMode] ) 
	{
		RestartWeaponFiringAfterReload(FireMode); 
	}
	else if(((FireMode == 0 && !ClientPendingFire[1]) || (FireMode == 1 && !ClientPendingFire[0])) && !PrimaryReloading && !SecondaryReloading)
	{
		GotoState('Active');
	}
	
	//`log("Completed Manual Reload");
}

//EDIT: ShouldRefire() was never edited to question just WHICH weapon was reloading. Fixed (OR  broken... 'cuz Yosh breaks lots of things in the name of fixing.)
simulated function bool ShouldRefire()
{
 	local vector FireStartLoc;
 	local Rx_Vehicle veh;
 	
	//`log("Got to shouldrefire");
	
 	if(PrimaryReloading && SecondaryReloading)
 	{
		//`log("Both Weapons Reloading: Doing nothing");
 		return false;
 	}
 		
 	if(bCheckIfBarrelInsideWorldGeomBeforeFiring) {
	 	FireStartLoc = MyVehicle.GetEffectLocation(SeatIndex);
	 	if(!FastTrace(FireStartLoc,MyVehicle.location)) {
			ClearPendingFire(CurrentFireMode);
			return false;
		}
	} 
	
 	if(bCheckIfFireStartLocInsideOtherVehicle)
 	{
 	    foreach CollidingActors(class'Rx_Vehicle', veh, 3, Owner.location, true)
   		{
			if(veh == Pawn(Owner))
				continue;
			ClearPendingFire(CurrentFireMode);
			return false;
		}
	} 	
	
	return super.ShouldRefire();
}

simulated function SetCurrentFireMode(byte FiringModeNum)
{
	super.SetCurrentFireMode(FiringModeNum);
}

simulated function SetCurrentlyReloadingSecondaryClientsideToFalseTimer()
{
	//`log("Secondary Client-side reload set to FALSE");
	CurrentlyReloadingSecondaryClientside = false;	
}

simulated function DrawCrosshair( Hud HUD )
{
	local vector2d CrosshairSize;
	local float x,y;	
	local UTHUDBase H;
	local Pawn MyPawnOwner;
	local actor TargetActor;
	local int targetTeam;
	local LinearColor LC; //nBab	
	local float XResScale; 
	
	//set initial color based on settings (nBab)
	LC.A = 1.f;
	switch (Rx_HUD(Rx_Controller(Instigator.Controller).myHUD).SystemSettingsHandler.GetCrosshairColor())
	{
		//white
		case 0:
			LC.R = 1.f;
			LC.G = 1.f;
			LC.B = 1.f;
			break;
		//orange
		case 1:
			LC.R = 2.f;
			LC.G = 0.5f;
			LC.B = 0.f;
			break;
		//violet
		case 2:
			LC.R = 2.f;
			LC.G = 0.f;
			LC.B = 2.f;
			break;
		//blue
		case 3:
			LC.R = 0.f;
			LC.G = 0.f;
			LC.B = 2.f;
			break;
		//cyan
		case 4:
			LC.R = 0.f;
			LC.G = 2.f;
			LC.B = 2.f;
			break;	
	}

	H = UTHUDBase(HUD);
	if ( H == None )
		return;

	XResScale = H.Canvas.SizeX/1920.0;	
	
 	CrosshairSize.Y = CrosshairHeight * XResScale;
    CrosshairSize.X = CrosshairWidth * XResScale;

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
					{
						//enemy, go red, except if stealthed (else would be cheating ;] )
						//nBab
						LC.R = 10.f;
						LC.G = 0.f;
						LC.B = 0.f;
					}
				}
				else
				{
					//Friendly
					//nBab
					LC.R = 0.f;
					LC.G = 10.f;
					LC.B = 0.f;
				}
			}
		}
	}
	
	if (!HasAnyAmmo()) //no ammo, go yellow
	{
		//nBab
		LC.R = 10.f;
		LC.G = 8.f;
		LC.B = 0.f;
	}

	//nBab
	CrosshairMIC2.SetVectorParameterValue('Reticle_Colour', LC);

	if ( CrosshairMIC2 != none )
	{
		//H.Canvas.SetPos( X+1, Y+1 );
		H.Canvas.SetPos( X, Y );
		H.Canvas.DrawMaterialTile(CrosshairMIC2,CrosshairSize.X, CrosshairSize.Y,0.0,0.0,1.0,1.0);
		DrawHitIndicator(H,x,y);
	}
	if(bDebugWeapon)
	{
		H.Canvas.DrawText("PrimaryReloading: " @ PrimaryReloading @ "Clientside Reloding: " @ CurrentlyReloadingClientside,true,1,1);
		Y+=20;
		H.Canvas.DrawText("Ammo: S: " @ CurrentAmmoInClip[0] @ "C: " @ CurrentAmmoInClipClientSide[0],true,1,1);
		Y+=20;
		H.Canvas.DrawText("Refire Timer: " @ (GetTimerRate('PrimaryReloadTimer') - GetTimerCount('PrimaryReloadTimer')),true,1,1);
		Y+=20;
		H.Canvas.DrawText("PendingFire:" @ PendingFire(0),true,1,1);
		Y+=20;
		H.Canvas.DrawText("ClientPendingFire:" @ ClientPendingFire[0],true,1,1);
		Y+=20;
		H.Canvas.DrawText("ReFire:" @ ShouldRefire(),true,1,1);
		Y+=20;
		H.Canvas.DrawText("Has Ammo:" @ HasAmmo(0),true,1,1);
		Y+=20;
		H.Canvas.DrawText("State" @ GetStateName(),true,1,1);
		Y+=20;
		H.Canvas.DrawText("CRCS" @ CurrentlyReloadingClientside,true,1,1);
		Y+=20;
		H.Canvas.DrawText("ReadyToFire" @ bReadyToFire(),true,1,1);
		Y+=20;
		H.Canvas.DrawText("CurrentFireMode" @ CurrentFireMode,true,1,1);
	}
	
}



//Inject to keep server and client in sync with reloading weapons 
simulated function StartFire(byte FireModeNum)
{
	//`log(self @ "-----------Firing------------"); 
	if(Rx_Bot(instigator.Controller) != None) 
	{
		super.StartFire(FireModeNum); 
		return; 
	}
	
	if( Instigator == None || !Instigator.bNoWeaponFiring )
	{
		/*For Multi Weapons, set the firing mode earlier than usual so it can change even when reloading*/
		if(FireModeNum == 1)  
			{
				ClearPendingFire(0);
				ServerStopFire(0);
				ClientPendingFire[0]=false;
			}
			else
			if(FireModeNum == 0)
			{
				ClearPendingFire(1);
				ServerStopFire(1);
				ClientPendingFire[1]=false;
			}
		
		SetCurrentFireMode(FireModeNum);
		
		ClientPendingFire[FireModeNum]=true; 
		
		if(bReadyToFire() && !IsReloading(FireModeNum) && (Role < Role_Authority || WorldInfo.NetMode == NM_StandAlone))
		{
			// if we're a client, synchronize server
			//`log("Sending Fire Request[Vehicle]"); 
			ServerStartFire(FireModeNum);
			BeginFire(FireModeNum);
			return;
		}

		// Start fire locally
		//if(ROLE == Role_Authority) BeginFire(FireModeNum);
	}
}

reliable server function ServerStartFire(byte FireModeNum)
{
		
		if(!UsesClientSideProjectiles(FireModeNum)) //Client was finished with reload already 
			{
				
				if(FireModeNum == 0 && IsTimerActive('PrimaryReloadTimer'))
				{
					//`log("Primary wasn't done reloading: Seconds left:" @ (GetTimerRate('PrimaryReloadTimer') - GetTimerCount('PrimaryReloadTimer'))); 
					ClearTimer('PrimaryReloadTimer');
					PrimaryReloadTimer(); 
				}
				if(FireModeNum == 1 && IsTimerActive('SecondaryReloadTimer'))
				{
					//`log("Secondary wasn't done reloading: Seconds left:" @ (GetTimerRate('SecondaryReloadTimer') - GetTimerCount('SecondaryReloadTimer'))); 
					ClearTimer('SecondaryReloadTimer');
					SecondaryReloadTimer(); 
				}					
			}
			
	super.ServerStartFire(FireModeNum);
}

function PromoteWeapon(byte rank)
{
	super.PromoteWeapon(rank);  
	ClipSize[0]=default.ClipSize[0]+Vet_ClipSizeModifier[rank]; 
	ClipSize[1]=default.ClipSize[1]+Vet_SecondaryClipSizeModifier[rank]; 
}

simulated function float GetFireInterval( byte FireModeNum )
{
	//Multi-dimensional arrays....would be love.
	switch (FireModeNum)
	{
		case 0:
			return FireInterval[FireModeNum]*GetROFModifier() ;
			break;
		
		case 1:
			return FireInterval[FireModeNum]*GetSecondaryROFModifier() ;
			break;
		
		default :
			return 0.01; 
			break;
	}
}

reliable server function NotifyServerOfReload(int Count, byte FireModeNum) //deviation integer
{
local int DeviInt;

	//Add log of difference
	DeviInt = ShotsFired[FireModeNum] - Count ; 
	//`log("---------Weapon" @ self @ "Reload with ammo deviation of " @ DeviInt @ "---------") ;	
	
	if(DeviInt < -SF_Tolerance) `LogRx("PLAYER" `s "FLAG_VehicleShotNumber;" `s self.class `s DeviInt `s `PlayerLog(Instigator.PlayerReplicationInfo));	
	
	if(!IsReloading(FireModeNum) && FireModeNum == 0) PrimaryReload();
	else	
	if(!IsReloading(FireModeNum) && FireModeNum == 1) SecondaryReload();
}

reliable server function ServerReplicateAmmo() //Runs when weapon is activated on the client
{
	local float RTimerTime, SecondaryRTime; //Sync reload timer to prevent having to manually reload when first entering a vehicle that's reloading
	
	if(PrimaryReloading) RTimerTime = (GetTimerRate('PrimaryReloadTimer') - GetTimerCount('PrimaryReloadTimer'));
	
	if(SecondaryReloading) SecondaryRTime = (GetTimerRate('SecondaryReloadTimer') - GetTimerCount('SecondaryReloadTimer'));
	
	ClientReplicateAmmo(AmmoCount,MaxAmmoCount,CurrentAmmoInClip[0], CurrentAmmoInClip[1], PrimaryReloading, SecondaryReloading, RTimerTime, SecondaryRTime);	
}

reliable client function ClientReplicateAmmo(float AC,float MAC,float CAIC, float CAIC2, bool CR, bool CR2, float RTime, float RTime2)
{
	AmmoCount = AC;
	MaxAmmoCount = MAC;
	CurrentAmmoInClip[0] = CAIC;
	CurrentAmmoInClipClientside[0] = CAIC;
	CurrentAmmoInClip[1] = CAIC2;
	CurrentAmmoInClipClientside[1] = CAIC2;
	
	if(CR) //CR being our primary fire is currently reloading according to the server
	{
		//`log("Reload From server replication [Primary]" @ RTime);
		PrimaryReload();
		if(IsTimerActive('PrimaryReloadTimer'))
		{
			//`log("ReloadTimer should get cleared");
			SetTimer(RTime, false, 'PrimaryReloadTimer');
		}
	}
	if(CR2) //CR2 being our secondary fire is currently reloading according to the server
	{
		//`log("Reload From server replication [secondary]" @ RTime2);
		SecondaryReload();
		if(IsTimerActive('SecondaryReloadTimer'))
		{
			//`log("ReloadTimer should get cleared");
			SetTimer(RTime2, false, 'SecondaryReloadTimer');
		}
	}
	
}

reliable client function ClientGetAmmo()
{
	//`log("--------CGA---------" @ CurrentAmmoInClip @ CurrentlyReloading @ self);
	if(CurrentAmmoInClip[0] <= 0 && !PrimaryReloading) //Can assume if both of these are true, something's wrong
	{
		//`log("Should replicate");
		SetTimer(0.01, false,'CallAmmoReplication'); 
	}
}

simulated function CallAmmoReplication()
{
	//`log("Replicate to server"); 
	ServerReplicateAmmo(); 
	
}

//Rx_Vehicle_HarvesterController Rx_Defence_Controller

simulated function float GetReloadSpeedModifier()
{
	if(Rx_Controller(Instigator.Controller) != none) return Vet_ReloadSpeedModifier[VRank]+Rx_Controller(Instigator.Controller).Misc_ReloadSpeedMod; 
	else
	if(Rx_Bot(Instigator.Controller) != none) return Vet_ReloadSpeedModifier[Vrank]+Rx_Bot(Instigator.Controller).Misc_ReloadSpeedMod; 
	else
	if(Rx_Vehicle_HarvesterController(Instigator.Controller) != none) return Vet_ReloadSpeedModifier[Vrank]+Rx_Vehicle_HarvesterController(Instigator.Controller).Misc_ReloadSpeedMod; 
	else
	if(Rx_Defence_Controller(Instigator.Controller) != none) return Vet_ReloadSpeedModifier[Vrank]+Rx_Defence_Controller(Instigator.Controller).Misc_ReloadSpeedMod; 
	else
	return 1.0; 
}

simulated function float GetSecondaryReloadSpeedModifier()
{
	if(Rx_Controller(Instigator.Controller) != none) return Vet_SecondaryReloadSpeedModifier[VRank]+Rx_Controller(Instigator.Controller).Misc_ReloadSpeedMod; 
	else
	if(Rx_Bot(Instigator.Controller) != none) return Vet_SecondaryReloadSpeedModifier[Vrank]+Rx_Bot(Instigator.Controller).Misc_ReloadSpeedMod;
	else
	if(Rx_Vehicle_HarvesterController(Instigator.Controller) != none) return Vet_SecondaryReloadSpeedModifier[Vrank]+Rx_Vehicle_HarvesterController(Instigator.Controller).Misc_ReloadSpeedMod; 
	else
	if(Rx_Defence_Controller(Instigator.Controller) != none) return Vet_SecondaryReloadSpeedModifier[Vrank]+Rx_Defence_Controller(Instigator.Controller).Misc_ReloadSpeedMod; 
	else
	return 1.0; 
}

simulated function float GetROFModifier()
{
	if(Rx_Controller(Instigator.Controller) != none) return Vet_ROFSpeedModifier[VRank]+Rx_Controller(Instigator.Controller).Misc_RateOfFireMod; 
	else
	if(Rx_Bot(Instigator.Controller) != none) return Vet_ROFSpeedModifier[Vrank]+Rx_Bot(Instigator.Controller).Misc_RateOfFireMod; 
	else
	if(Rx_Vehicle_HarvesterController(Instigator.Controller) != none) return Vet_ROFSpeedModifier[Vrank]+Rx_Vehicle_HarvesterController(Instigator.Controller).Misc_RateOfFireMod; 
	else
	if(Rx_Defence_Controller(Instigator.Controller) != none) return Vet_ROFSpeedModifier[Vrank]+Rx_Defence_Controller(Instigator.Controller).Misc_RateOfFireMod; 
	else
	return 1.0; 
}

simulated function float GetSecondaryROFModifier()
{
	if(Rx_Controller(Instigator.Controller) != none) return Vet_SecondaryROFSpeedModifier[VRank]+Rx_Controller(Instigator.Controller).Misc_RateOfFireMod; 
	else
	if(Rx_Bot(Instigator.Controller) != none) return Vet_SecondaryROFSpeedModifier[Vrank]+Rx_Bot(Instigator.Controller).Misc_RateOfFireMod;
	else
	if(Rx_Vehicle_HarvesterController(Instigator.Controller) != none) return Vet_SecondaryROFSpeedModifier[Vrank]+Rx_Vehicle_HarvesterController(Instigator.Controller).Misc_RateOfFireMod;
	else
	if(Rx_Defence_Controller(Instigator.Controller) != none) return Vet_SecondaryROFSpeedModifier[Vrank]+Rx_Defence_Controller(Instigator.Controller).Misc_RateOfFireMod; 
	else
	return 1.0; 
}

function PlayWeaponReloadEffects(byte FM)
{
		if(CurrentAmmoInClip[FM] > 0)
			return; 
			
			if(Role == ROLE_Authority && ReloadSound[FM] != None) {
				MyVehicle.PlaySound( ReloadSound[FM]);
		}
}

simulated function SecondaryRefireCheckTimer()
{
	`log("Called Secondary Refire outside of Correct state"); 
}

simulated function TimeWeaponFiring( byte FireModeNum )
{
	// if weapon is not firing, then start timer. Firing state is responsible to stopping the timer.
	
	if(FireModeNum == 0 && !IsTimerActive('RefireCheckTimer') )
	{
		SetTimer( GetFireInterval(FireModeNum), true, nameof(RefireCheckTimer) );
	}
	else if(FireModeNum == 1 && !IsTimerActive('SecondaryRefireCheckTimer') )
	{
		SetTimer( GetFireInterval(FireModeNum), true, nameof(SecondaryRefireCheckTimer) );
	}
}

DefaultProperties
{
	InventoryGroup=16
	
	bDebugWeapon=false;

	AmmoCount = 999

	/***********************/
	/*Veterancy*/
	/**********************/
	Vet_ClipSizeModifier(0)=0 //Normal +X
	Vet_ClipSizeModifier(1)=0 //Veteran 
	Vet_ClipSizeModifier(2)=0 //Elite
	Vet_ClipSizeModifier(3)=0 //Heroic


	Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1) Reverse *X
	Vet_ReloadSpeedModifier(1)=1 //Veteran 
	Vet_ReloadSpeedModifier(2)=1 //Elite
	Vet_ReloadSpeedModifier(3)=1 //Heroic

	Vet_SecondaryClipSizeModifier(0)=0 //Normal +X
	Vet_SecondaryClipSizeModifier(1)=0 //Veteran 
	Vet_SecondaryClipSizeModifier(2)=0 //Elite
	Vet_SecondaryClipSizeModifier(3)=0 //Heroic

	Vet_ROFSpeedModifier(0)=1 //Normal (should be 1) Reverse *X
	Vet_ROFSpeedModifier(1)=1 //Veteran 
	Vet_ROFSpeedModifier(2)=1 //Elite
	Vet_ROFSpeedModifier(3)=1 //Heroic

	Vet_SecondaryROFSpeedModifier(0)=1 //Normal (should be 1) Reverse *X
	Vet_SecondaryROFSpeedModifier(1)=1 //Veteran 
	Vet_SecondaryROFSpeedModifier(2)=1 //Elite
	Vet_SecondaryROFSpeedModifier(3)=1 //Heroic

	Vet_SecondaryReloadSpeedModifier(0)=1
	Vet_SecondaryReloadSpeedModifier(1)=1
	Vet_SecondaryReloadSpeedModifier(2)=1
	Vet_SecondaryReloadSpeedModifier(3)=1

	/***********************************/

	FM0_ROFTurnover = 2; //9 for most automatics. Single shot weapons should be more, except the shotgun
	FM1_ROFTurnover = 4; 
}
