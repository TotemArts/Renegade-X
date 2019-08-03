class Rx_Vehicle_Weapon_Reloadable extends Rx_Vehicle_Weapon
	abstract;

var() int ClipSize;
var int ClipSizeMax;
var() int InitalNumClips;
var() int MaxClips;

var  int CurrentAmmoInClip;
var int CurrentAmmoInClipClientside;
var bool HasInfiniteAmmo;
var bool CurrentlyReloading;
var bool CurrentlyFireing;
var int ShotsFired; 

var() name ReloadAnimName[4];
var() name ReloadArmAnimName[4];
var() SoundCue ReloadSound[4];

//info for reload animation timing
var float reloadBeginTime;
var float currentReloadTime;
var bool bRepAmmo; 

//Veterancy
var float Vet_ReloadSpeedModifier[4]; //*X
var int Vet_ClipSizeModifier[4];  //+X

replication
{
	if( bNetOwner && bNetDirty )
		 CurrentlyFireing; 
	/** if(bNetOwner && bNetDirty && bRepAmmo)
	 CurrentAmmoInClip, CurrentlyReloading; */
}

simulated event PreBeginPlay()
{
	if(ROLE == ROLE_AUTHORITY) 
	{
		AmmoCount = ClipSize * InitalNumClips;
		MaxAmmoCount = ClipSize * MaxClips;
		CurrentAmmoInClip = ClipSize;
		CurrentAmmoInClipClientside = ClipSize;
		bForceNetUpdate = true;
		super.PreBeginPlay();	
	}
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
			currentReloadTime = ReloadTime[CurrentFireMode]*GetReloadSpeedModifier();		
		}	
    }
    else if (VarName == 'CurrentAmmoInClip')
	{
		/**if(CurrentAmmoInClip == ClipSize)
		{
			CurrentAmmoInClipClientside = ClipSize;	
		}*/
		//`log("--CAIC Replicated--");
		CurrentAmmoInClipClientside = CurrentAmmoInClip;
		//SetRepAmmoFlag(false); 
    }
	else
    {
    	super.ReplicatedEvent(VarName);
    } 
}

simulated function Activate()
{	
	if(ROLE < ROLE_Authority) ServerReplicateAmmo();
	//`log("Activate"); 
	super.Activate();
}

//Added from Rx_Weapon_Reloadable - May be used 
simulated function RestartWeaponFiringAfterReload()
{
	//local vector FireStartLoc;
	GotoState('Active');	
	//We don't use the original ShouldRefire(), but we do need to check this just in case. 
	/**if(bCheckIfBarrelInsideWorldGeomBeforeFiring) {
	 	FireStartLoc = MyVehicle.GetEffectLocation(SeatIndex);
	 	if(!FastTrace(FireStartLoc,MyVehicle.location)) {
		ClearPendingFire(CurrentFireMode);
			ClientPendingFire[CurrentFireMode] = false;
			return;
		}
	} */
	StartFire(CurrentFireMode);  	
	
}

simulated state Reloading
{
	simulated function BeginState( name PreviousState )
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
		currentReloadTime = ReloadTime[CurrentFireMode]*GetReloadSpeedModifier();
		SetTimer( ReloadTime[CurrentFireMode]*GetReloadSpeedModifier(), false, 'ReloadWeaponTimer');
		//`log("Set Reload Timer" @ GetStateName());  
		CurrentlyFireing = false;
		
		if(WorldInfo.Netmode == NM_Client) NotifyServerOfReload(ShotsFired); //Add audit info

	}

	simulated function EndState( name NextState )
	{
		if (bDebugWeapon)
		{
			`log("---"@self$"."$GetStateName()$".EndState("$NextState$")");
		}
	}

	simulated function ReloadWeaponTimer()
	{
		//`log("-----RELOAD WEAPON TIMER------" @ GetStateName());
		if (bDebugWeapon)
		{
			`log("---"@self$"."$GetStateName()$".ReloadWeapon()");
		}

		if (HasInfiniteAmmo) 
		{
			AmmoCount = MaxAmmoCount;
			CurrentAmmoInClip = ClipSize;//default.ClipSize;
			CurrentAmmoInClipClientSide = ClipSize;
		}
		else if( AmmoCount >= ClipSize)//default.ClipSize )
		{
			CurrentAmmoInClip = ClipSize; //default.ClipSize;
			CurrentAmmoInClipClientSide = ClipSize;
		}
		else
		{
			CurrentAmmoInClip = AmmoCount;
			CurrentAmmoInClipClientSide = ClipSize;
		}

		CurrentlyReloading = false;
		ShotsFired = 0; 
		
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
			//`log("Start firing again based on CPF");
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
		return true; //!CurrentlyReloading; //false;
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

simulated function ConsumeAmmo( byte FireModeNum )
{
	//`log("Consume Ammo" @ GetStateName()); 
	ShotsFired++ ; 
	//`log("----------------" $ ShotsFired $ "--------------"); 
	//ScriptTrace(); 
	if(bReloadAfterEveryShot) CurrentAmmoInClip = 0; 
	else
	CurrentAmmoInClip -= ShotCost[FireModeNum];
	super.ConsumeAmmo( FireModeNum );
}

simulated function ConsumeClientsideAmmo( byte FireModeNum )
{
	//`log("Consume Ammo CS");
	if(bReloadAfterEveryShot) CurrentAmmoInClipClientSide = 0; 
	else
	CurrentAmmoInClipClientSide -= ShotCost[FireModeNum];
}

// if this gun has any ammo in current clip it will return true.
simulated function bool HasAmmo( byte FireModeNum, optional int Amount )
{
	if( Amount==0 )
	{
		/**if(ROLE < ROLE_AUTHORITY || WorldInfo.NetMode == NM_Client) return CurrentAmmoInClip >= ShotCost[FireModeNum];
			else
		return true;*/
		return CurrentAmmoInClip >= ShotCost[FireModeNum];
	}
		/**if(ROLE < ROLE_AUTHORITY || WorldInfo.NetMode == NM_Client) 
			else
		return true; */ 
	return CurrentAmmoInClip >= Amount;
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

simulated function ReloadWeapon()
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
	
	simulated event ReplicatedEvent(name VarName)
	{
		if ( VarName == 'AmmoCount' && !HasAnyAmmo() )
		{
			//`log("Returning on lack of ammo on WeaponFiringState"); 
			return;
		}
	}
	
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
			//`log("Set reload timer in WeaponFiringState"); 
			SetTimer((ReloadTime[CurrentFireMode]*GetReloadSpeedModifier()),false,'GoToReloading');

			//`log("Set Reload Timer" @ GetStateName()); 
			return;
		}	
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
		//if(UsesClientSideProjectiles(CurrentFireMode) && WorldInfo.NetMode == NM_DedicatedServer) return; //ignore this on servers. 
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
	local int targetTeam;
	local vector ScreenLoc;		
	local LinearColor LC; //nBab
	local bool	bTargetBehindUs;
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
	
 	CrosshairSize.Y = CrosshairHeight*XResScale;
	CrosshairSize.X = CrosshairWidth*XResScale;

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
	else
	{
		if ( CurrentlyReloading && bReloadAfterEveryShot) //reloading, go yellow
		{
			//nBab
			LC.R = 10.f;
			LC.G = 8.f;
			LC.B = 0.f;
		}
	}

	//nBab
	CrosshairMIC2.SetVectorParameterValue('Reticle_Colour', LC);
	H.Canvas.SetDrawColor(Clamp(LC.R*255,0,255),Clamp(LC.G*255,0,255),Clamp(LC.B*255,0,255),100);

	//CrosshairMIC2.SetScalarParameterValue('ReticleColourSwitcher', rectColor);
	if ( CrosshairMIC2 != none )
	{
		//H.Canvas.SetPos( X+1, Y+1 );
		H.Canvas.SetPos( X, Y );
		H.Canvas.DrawMaterialTile(CrosshairMIC2,CrosshairSize.X, CrosshairSize.Y,0.0,0.0,1.0,1.0);
		if(PendingLockedTarget != none)
			{
				bTargetBehindUs = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(Rx_Controller(Instigator.Controller).ViewTarget.Location,Instigator.Controller.Rotation,PendingLockedTarget.location) < -0.5;
			
				if(!bTargetBehindUs)
				{
				LC.R = 0.f;
				LC.G = 5.f;
				LC.B = 5.f;
				CrosshairMIC2.SetVectorParameterValue('Reticle_Colour', LC);
				ScreenLoc = PendingLockedTarget.location; 
				ScreenLoc = H.Canvas.Project(ScreenLoc);
				H.Canvas.SetPos( ScreenLoc.X - CrosshairWidth/2, ScreenLoc.Y - CrosshairWidth/2 );
				H.Canvas.DrawMaterialTile(CrosshairMIC2, CrosshairWidth, CrosshairHeight);
				}
			}
		
		DrawHitIndicator(H,x,y);
		
		if(MyPawnOwner != None && VSize(MyVehicle.location - Rx_Hud(HUD).AimLoc) < 2000)
		{
			ScreenLoc = Rx_Vehicle(MyVehicle).GetWeaponAimLocation(Rx_Hud(HUD).AimLoc);
			if(ScreenLoc != vect(0,0,0) && VSize(ScreenLoc - Rx_Hud(HUD).AimLoc) > 50)
			{
				ScreenLoc = H.Canvas.Project(ScreenLoc);
			    H.Canvas.SetPos( ScreenLoc.X, ScreenLoc.Y ); 		    
				H.Canvas.DrawText("+");			    
				//H.Canvas.DrawMaterialTile(DotCrosshairMIC2,CrosshairSize.X, CrosshairSize.Y,0.0,0.0,1.0,1.0);			    
		    }
	    }		
		
	}
	/*DEBUG INFO*/
	if(bDebugWeapon)
	{
		H.Canvas.DrawText("Reloading: " @ CurrentlyReloading ,true,1,1);
		Y+=20;
		H.Canvas.DrawText("Accuracy:" @ Rx_Controller(MyPawnOwner.Controller).Acc_Shots/Rx_Controller(MyPawnOwner.Controller).Acc_Hits $ "%",true,1,1);
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
		Y+=20;
		H.Canvas.DrawText("---VEHICLE---",true,1,1);
		Y+=20;
		H.Canvas.DrawText(GetTimerRate('GotoWeaponFiring') - GetTimerCount('GotoWeaponFiring'));
		
		
		if(Rx_Vehicle(MyVehicle) != none)
		{
			H.Canvas.DrawText("Vehicle Turntrack Modifier: " @ Rx_Vehicle(MyVehicle).GetTurnTrackSpeedModifier() ,true,1,1);
			Y+=20;
			H.Canvas.DrawText("Vehicle Speed Modifier: " @ Rx_Vehicle(MyVehicle).GetSpeedModifier() ,true,1,1);
			Y+=20;
			H.Canvas.DrawText("Vehicle Sprinting: " @ Rx_Vehicle(MyVehicle).bSprinting ,true,1,1);
			Y+=20;
			H.Canvas.DrawText("Vehicle MinSprintSpeedMultiplier: " @ Rx_Vehicle(MyVehicle).MinSprintSpeedMultiplier ,true,1,1);
			Y+=20;
			H.Canvas.DrawText("Vehicle Throttle: " @ Rx_Vehicle(MyVehicle).GetThrottle() ,true,1,1);
			Y+=20;
			H.Canvas.DrawText("Vehicle MaxSpeed: " @ Rx_Vehicle(MyVehicle).MaxSpeed ,true,1,1);
			Y+=20;
			H.Canvas.DrawText("Driving: " @ Rx_Vehicle(MyVehicle).bDriving ,true,1,1);
			Y+=20;
			H.Canvas.DrawText("Driving: " @ Rx_Vehicle(MyVehicle).GetInwardTurnTrack() ,true,1,1);
			 
		}
		
		
	}
	
}

function PromoteWeapon(byte rank)
{
	super.PromoteWeapon(rank);  
	ClipSize=default.ClipSize+Vet_ClipSizeModifier[rank]; 
}

reliable server function NotifyServerOfReload(int Count) //deviation integer
{
local int DeviInt;

	//Add log of difference
	DeviInt = ShotsFired - Count ; 
	
	if(DeviInt < -SF_Tolerance) `LogRx("PLAYER" `s "FLAG_VehicleShotNumber;" `s self.class `s DeviInt `s `PlayerLog(Instigator.PlayerReplicationInfo));	
	//`log("---------Weapon" @ self @ "Reload with ammo deviation of " @ DeviInt @ "---------") ;	
	if(GetStateName() != 'Reloading') GoToState('Reloading');	

}

simulated function GoToReloading()
	{
		GotoState('Reloading');
	}

reliable server function ServerReplicateAmmo()
{
	local float RTimerTime; 
	
	//`log("Server Rep Ammo" @ self);

	RTimerTime=(GetTimerRate('ReloadWeaponTimer') - GetTimerCount('ReloadWeaponTimer'));
	if(RTimerTime == 0 && bReloadAfterEveryShot && IsTimerActive('GoToReloading')) 
	{
	RTimerTime = (GetTimerRate('GoToReloading') - GetTimerCount('GoToReloading')) + ReloadTime[CurrentFireMode]*GetReloadSpeedModifier();	
	}
	
	ClientReplicateAmmo(AmmoCount,MaxAmmoCount,CurrentAmmoInClip, (CurrentlyReloading || IsTimerActive('GoToReloading')), RTimerTime);	
}

reliable client function ClientReplicateAmmo(float AC,float MAC,float CAIC, bool CR, float RT)
{
	//`log("----------Call CRA----" @ CAIC);
	
	AmmoCount = AC;
	MaxAmmoCount = MAC;
	CurrentAmmoInClip = CAIC;
	CurrentAmmoInClipClientside = CAIC;
	if(CR) 
	{
		//`log("Reload From server replication" @ RT);
		ReloadWeapon();
		if(IsTimerActive('ReloadWeaponTimer'))
		{
			//`log("ReloadTimer should get cleared");
			SetTimer( RT, false, 'ReloadWeaponTimer');
		}
		
	}
	
	
}

reliable client function ClientGetAmmo()
{
	//`log("--------CGA---------" @ CurrentAmmoInClip @ CurrentlyReloading @ self);
	if(CurrentAmmoInClip <= 0 && !CurrentlyReloading) 
	{
		//`log("Should replicate");
	SetTimer(0.01, false,'CallAmmoReplication'); 
	}
}


simulated function FireAmmunition()
{
	super.FireAmmunition();
	
}

simulated function CallAmmoReplication()
{
	//`log("Replicate to server"); 
	ServerReplicateAmmo(); 
	
}


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

reliable client function ReplicateVRank(byte rank)
{
	super(Rx_Vehicle_Weapon).ReplicateVRank(rank); 
	ClipSize=default.ClipSize+Vet_ClipSizeModifier[VRank];  //update clipsize clientside, as it's the only thing that's dependent on it
	
}

DefaultProperties
{
	InventoryGroup=6
	ReloadTime(0) = 1.0f
	ReloadTime(1) = 1.0f
	HasInfiniteAmmo = true;
	bDebugWeapon=false; 
	
Vet_ClipSizeModifier(0)=0 //Normal (should be 1)
Vet_ClipSizeModifier(1)=0 //Veteran 
Vet_ClipSizeModifier(2)=0 //Elite
Vet_ClipSizeModifier(3)=0 //Heroic


Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1)
Vet_ReloadSpeedModifier(1)=1 //Veteran 
Vet_ReloadSpeedModifier(2)=1 //Elite
Vet_ReloadSpeedModifier(3)=1 //Heroic


}
