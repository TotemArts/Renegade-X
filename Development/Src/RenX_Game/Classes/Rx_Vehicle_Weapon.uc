/*********************************************************
*
* File: RxVehicle_Weapon.uc
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
class Rx_Vehicle_Weapon extends UTVehicleWeapon
	abstract;

`include(RenX_Game\RenXStats.uci);


var MaterialInstanceConstant CrosshairMIC;
var MaterialInstanceConstant LockedOnCrosshairMIC;
var MaterialInstanceConstant HitIndicatorCrosshairMIC,HitIndicatorCrosshairMIC2,CrosshairMIC2,DotCrosshairMIC,DotCrosshairMIC2;
var float CrosshairWidth, CrosshairHeight;

var name FireSocket;
var ParticleSystem BeamTemplates[2];
var ParticleSystem BeamTemplates_Heroic[2]; 

var bool bDebugWeapon;
var float CloseRangeAimAdjustRange;


//-------------------- Recoil
var float RecoilImpulse;
var float recoiltime;
var float DeltaPitchX;
var float DeltaPitchXOld;
var int RecoilUps;
var bool bWasNegativeRecoil;
var bool bWasPositiveRecoilSecondTime;
var float RandRecoilIncrease;
var bool bHasRecoil;

// ---------------------------------  Targeting/Lock on vars. -------------------------------------- //
var bool                   bLockedOnTarget;           /* When true, this weapon is locked on target */
var bool                   bTargetLockingActive;      /* If true, weapon will try to lock onto targets */
var Actor                  LastPendingTarget;         /* What last tick test "target" is current pending to be locked on to */
var Actor                  PendingLockedTarget;       /* What "target" is current pending to be locked on to */
var Actor                  LockedTarget;              /* What "target" is this weapon locked on to */
var PlayerReplicationInfo  LockedTargetPRI;           /* if player is targeted then his PRI will be stored here */
var(Locking) float         LockTolerance;
var protected float        LastLockedOnTime;          /* How long since the Lock Target has been valid */
var protected float        LastTargetLockCheckTime;   /* Last time target lock was checked */
var() float                LockCheckTime;             /* The frequency with which we will check for a lock */
var() float                LockAcquireTime;           /* How long does the player need to target an actor to lock on to it*/
var() float                LockRange;                 /* How far out should we be considering actors for a lock */
var() float                StayLocked;                /* How long target stay locked before losing it*/
var float                  PendingLockedTargetTime;   /* When did the pending Target become valid */
var float                  LastValidTargetTime;       /* When was the last time we had a valid target */
var float                  LockAim;                   /* angle for locking for lock targets */
var float                  ConsoleLockAim;            /* angle for locking for lock targets when on Console */
var SoundCue               LockLostSound;             /* Sound Effects to play when Lock lost*/
var Soundcue               LockAcquiredSound;         /* Sound Effects to play when Locking */
var bool                   LockingStart;              /* if true then locking state was started */
var bool                   SecondaryLockingDisabled;  /* If true, secondary fire does not lock onto targets */
var bool 		           bCheckIfBarrelInsideWorldGeomBeforeFiring;
var bool 		           bCheckIfFireStartLocInsideOtherVehicle;
var bool 				   CurrentlyReloadingClientside;
var bool				   bReloadAfterEveryShot;
var bool				   bDropOnTarget; 
var float				   TossZ_Mod, TrackingMod; //Used for missiles that drop on their target. 

/**
 * For reload capable weapons. Reload time and Reload Anim name's 
 * 
 *  0 = Primary Fire - No Ammo in the clip
 *  1 = Secondary Fire - No Ammo in the clip
 *  2 = Primary Fire - 1 or more rounds left in the clip
 *  3 = Secondary Fire - 1 or more rounds left in the clip
 */
var() float ReloadTime[4];
var bool bCanReplicationFire;
var array<bool> ClientPendingFire;

var() class<UTDamageType> HeadShotDamageType;
var() float HeadShotDamageMult;

var array<float> InstantHitDamageRadius;
var array<bool> InstantHitDamageRadiusDoFull;
var array<bool> InstantHitDamageRadiusIgnoreTeam;

var byte ClientHitFiringMode;
var vector ClientHitHurtOrigin;

/** headshot scale factor when moving slowly or stopped */
var() float SlowHeadshotScale;

/** headshot scale factor when running or falling */
var() float RunningHeadshotScale;

//Veterancy
var repnotify byte VRank; 

var float Vet_DamageModifier[4]; //*X
var float Vet_ROFModifier[4];   //*X

//
var float SF_Tolerance; //Tolerance for weapon's ammo firing deviation 

var array< class<Projectile> > WeaponProjectiles_Heroic; 
var array<SoundCue>				WeaponFireSounds_Heroic;

var bool bROFChanged; //Track if our ROF changes mid firing 

//ROF Tracking FM0
var int FM0_LastFireTime;
var byte FM0_ROFTicker, FM0_ROFTurnover; //Iterator | How many shots until it takes an average and moves on.    Should never be more than 9 (Which will make it 10 shots averaged together)
var int FM0_ROFAvgs[10]; //10 though may not ever make it to ten. Saves AVG#
var int FM0_PrevAVG; 
var string FM0_AVGString; //String to send to controller when requested 

/***************************/

//ROF Tracking FM1
var int FM1_LastFireTime;
var byte FM1_ROFTicker, FM1_ROFTurnover; //Iterator | How many shots until it takes an average and moves on.    Should never be more than 9 (Which will make it 10 shots averaged together)
var int FM1_ROFAvgs[10]; //10 though may not ever make it to ten. Saves AVG#
var int FM1_PrevAVG; 
var string FM1_AVGString; //String to send to controller when requested 

// AI

var bool bOkAgainstBuildings;
var bool bOkAgainstLightVehicles;
var bool bOkAgainstArmoredVehicles;

replication
{
    if (Role == ROLE_Authority && bNetDirty)
        bLockedOnTarget,PendingLockedTarget, LockedTarget, VRank;
}

/**
* Just a Note for future reference: Child Replicated variables OVERWRITE parent ones.*
* Putting UpdateHeroicEffects here does nothing for Rx_Vehicle_MultiWeapon or Reloadable ones*
*/ 


simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	CrosshairMIC2 = new(Outer) class'MaterialInstanceConstant';
	CrosshairMIC2.SetParent(CrosshairMIC);	
	HitIndicatorCrosshairMIC2 = new(Outer) class'MaterialInstanceConstant';
	HitIndicatorCrosshairMIC2.SetParent(HitIndicatorCrosshairMIC);	
	DotCrosshairMIC2 = new(Outer) class'MaterialInstanceConstant';
	DotCrosshairMIC2.SetParent(DotCrosshairMIC);	
	bCanReplicationFire = true;										
}

simulated function ConsumeClientsideAmmo( byte FireModeNum );

simulated function DrawCrosshair( Hud HUD )
{
	local vector2d CrosshairSize;
	local float x,y;	
	local UTHUDBase H;
	local Pawn MyPawnOwner;
	local actor TargetActor;
	local int targetTeam;
	local LinearColor LC, LockColor, TempLC; //nBab
	local vector ScreenLoc;
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
	else
	{
		if (Rx_Vehicle_Weapon_Reloadable(self) != None 
				&& Rx_Vehicle_Weapon_Reloadable(self).CurrentlyReloading 
				&& !Rx_Vehicle_Weapon_Reloadable(self).bReloadAfterEveryShot) //reloading, go yellow
		{
			//nBab
			LC.R = 10.f;
			LC.G = 8.f;
			LC.B = 0.f;
		}
	}

	//nBab
	CrosshairMIC2.GetVectorParameterValue('Reticle_Colour', TempLC);
	if (TempLC != LC)
		CrosshairMIC2.SetVectorParameterValue('Reticle_Colour', LC);
	
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
				LockColor.R = 0.f;
				LockColor.G = 5.f;
				LockColor.B = 5.f;
				CrosshairMIC2.SetVectorParameterValue('Reticle_Colour', LockColor);
				ScreenLoc = PendingLockedTarget.location; 
				ScreenLoc = H.Canvas.Project(ScreenLoc);
				H.Canvas.SetPos( ScreenLoc.X - CrosshairWidth/2, ScreenLoc.Y - CrosshairWidth/2 );
				H.Canvas.DrawMaterialTile(CrosshairMIC2, CrosshairWidth, CrosshairHeight);
				}
			}
		DrawHitIndicator(H,x,y);
	}
	
}

simulated function DrawLockedOn( HUD H )
{
    local vector2d CrosshairSize;
    local float x, y;
    local LinearColor LC, TempLC; //nBab
	local vector ScreenLoc; 
	local bool bTargetBehindUs; 
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
	
	CrosshairMIC2.GetVectorParameterValue('Reticle_Colour', TempLC);
	if (TempLC != LC)
		CrosshairMIC2.SetVectorParameterValue('Reticle_Colour', LC);

	LockedOnCrosshairMIC.GetVectorParameterValue('Reticle_Colour', TempLC);
	if (TempLC != LC)
		LockedOnCrosshairMIC.SetVectorParameterValue('Reticle_Colour', LC);
	
   	if (H == none || H.Canvas == none)
      	return;

	XResScale = H.Canvas.SizeX/1920.0;	
		
    CrosshairSize.Y = CrosshairHeight * XResScale;
    CrosshairSize.X = CrosshairWidth * XResScale;


	X = H.Canvas.ClipX * 0.5 - (CrosshairSize.X * 0.5);
	Y = H.Canvas.ClipY * 0.5 - (CrosshairSize.Y * 0.5);
    if ( LockedOnCrosshairMIC != none )
    {
        H.Canvas.SetPos(x, y);
        H.Canvas.DrawMaterialTile(CrosshairMIC,CrosshairSize.X, CrosshairSize.Y,0.0,0.0,1.0,1.0);
        H.Canvas.SetPos(x, y);
        H.Canvas.DrawMaterialTile(LockedOnCrosshairMIC,CrosshairSize.X, CrosshairSize.Y,0.0,0.0,1.0,1.0);
		if(LockedTarget != none)
			{
				bTargetBehindUs = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(Rx_Controller(Instigator.Controller).ViewTarget.Location,Instigator.Controller.Rotation,LockedTarget.location) < -0.5;
			
				if(!bTargetBehindUs)
				{
				LC.R = 10.f;
				LC.G = 0.f;
				LC.B = 0.f;
				CrosshairMIC.SetVectorParameterValue('Reticle_Colour', LC);
				ScreenLoc = LockedTarget.location; 
				ScreenLoc = H.Canvas.Project(ScreenLoc);
				H.Canvas.SetPos( ScreenLoc.X - CrosshairWidth/2, ScreenLoc.Y - CrosshairWidth/2 );
				H.Canvas.DrawMaterialTile(CrosshairMIC, CrosshairWidth, CrosshairHeight);	
				}
			}
        DrawHitIndicator(H,x,y);
    }
}

simulated function DrawHitIndicator(HUD H, float x, float y)
{
	local vector2d CrosshairSize;
	local LinearColor LC; //nBab
	local float		XResScale;
	
	
	//set color based on settings (nBab)
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
	
	if(Rx_Hud(H).HitMarker_Color == Rx_Hud(H).LC_Red) LC = Rx_Hud(H).HitMarker_Color;
	HitIndicatorCrosshairMIC2.SetVectorParameterValue('Reticle_Colour', LC);
	
	if(Rx_Hud(H).GetHitEffectAplha() <= 0.0) {
		return;
	}	
	
	XResScale = H.Canvas.SizeX/1920.0;
	
    CrosshairSize.Y = default.CrosshairHeight*XResScale;
    CrosshairSize.X = default.CrosshairWidth*XResScale;
    H.Canvas.SetPos(x, y);
    HitIndicatorCrosshairMIC2.SetScalarParameterValue('Reticle_Opacity', Rx_Hud(H).GetHitEffectAplha()/100.0);
    H.Canvas.DrawMaterialTile(HitIndicatorCrosshairMIC2,CrosshairSize.X, CrosshairSize.Y,0.0,0.0,1.0,1.0);
}

simulated function int GetUseableAmmo()
{
	return 1;
}

simulated function int GetMaxAmmoInClip()
{
	return 1;
}

simulated function int GetReserveAmmo()
{
	return AmmoCount - 1;
}

function ConsumeAmmo( byte FireModeNum )
{
	super.ConsumeAmmo( FireModeNum );
}

simulated function FireAmmunition()
{
	local int Year, Month, DayOfWeek, Day, Hour, Min, Sec, MSec; 
	
	
	GetSystemTime(Year, Month,DayOfWeek, Day, Hour,Min, Sec, MSec ) ;
	
	if(CurrentFireMode == 0) CalcFM0ROF(Sec, MSec);
	else
	CalcFM1ROF(Sec,MSec); 
	//`log((Sec*1000+MSec) - LastFireTime @ "/" @ FireInterval[CurrentFireMode]*1000 @ "/" @ Sec*1000+MSec);
	
	
	
	
	if(Rx_Controller(Instigator.Controller) != none) Rx_Controller(Instigator.Controller).AddShot();
	
	/**if(WorldInfo.NetMode == NM_Client && bReloadAfterEveryShot)
	{
		if(!bCanReplicationFire)
		{
			`log("Fail on replication fire"); 
			return;
		}
		else
		{
			bCanReplicationFire = false;
			SetTimer(FireInterval[0]*Vet_ROFModifier[VRank],false,'resetCanReplicationFire');
		}
	}	*/	
	super.FireAmmunition();
	if(bHasRecoil) {
		SetWeaponRecoil();
	}

	
	if(Instigator.Controller != none)
	{
		`RecordWeaponIntStat(WEAPON_FIRED,Instigator.Controller,class,1);
		`RecordProjectileIntStat(WEAPON_FIRED,Instigator.Controller,GetProjectileClass(),1);
	}
	else
	{
		`RecordWeaponIntStat(WEAPON_FIRED,none,class,1);
		`RecordProjectileIntStat(WEAPON_FIRED,none,GetProjectileClass(),1);
	}
}

/**
 * Returns interval in seconds between each shot, for the firing state of FireModeNum firing mode.
 *
 * @param	FireModeNum	fire mode
 * @return	Period in seconds of firing mode
 */
simulated function float GetFireInterval( byte FireModeNum )
{
	return FireInterval[FireModeNum] > 0 ? FireInterval[FireModeNum]*GetROFModifier() : 0.01;
}

simulated function resetCanReplicationFire()
{
	bCanReplicationFire = true;	
}

simulated function bool CanReplicationFire()
{
	return true;//bCanReplicationFire && bReloadAfterEveryShot;
}

simulated function CalcFM0ROF(float Sec, float MSec) //Current seconds/Milliseconds
{
	local float ROFTotal; 
	local int	i; 
	
	if((Sec*1000+MSec) - FM0_LastFireTime <= FireInterval[0]*GetROFModifier()*1000 && (Sec*1000+MSec) - FM0_LastFireTime > 0) 
	{
		FM0_ROFAvgs[FM0_ROFTicker] = (Sec*1000+MSec) - FM0_LastFireTime ;
	
		if(FM0_ROFTicker >= FM0_ROFTurnover) 
		{
			for(i=0;i<FM0_ROFTicker;i++)
				ROFTotal += FM0_ROFAvgs[i];

			FM0_ROFTicker = 0; 
			ROFTotal=ROFTotal/FM0_ROFTurnover;
		
			//`log(ROFTotal @ "/" @ FireInterval[0]*1000);
		
			if(FM0_PrevAVG==0) FM0_PrevAVG=FireInterval[0]*GetROFModifier()*1000;
		
			FM0_PrevAVG = (FM0_PrevAVG+ROFTotal)/2;
		
			FM0_AVGString = FM0_PrevAVG @ "/" @ FireInterval[0]*GetROFModifier()*1000 @ "[FM:" $ 0 $"]";  
		}
		FM0_ROFTicker+=1;
	}
	else
	{
		FM0_ROFAvgs[FM0_ROFTicker] = FireInterval[0]*GetROFModifier()*1000;
		
		if(FM0_ROFTicker >= FM0_ROFTurnover) 
		{
			for(i=0;i<FM0_ROFTicker;i++)
				ROFTotal += FM0_ROFAvgs[i];

			FM0_ROFTicker = 0;
			ROFTotal=ROFTotal/FM0_ROFTurnover;
			//`log(ROFTotal @ "/" @ FireInterval[0]*1000); 
		
			if(FM0_PrevAVG==0) FM0_PrevAVG=FireInterval[0]*GetROFModifier()*1000;
		
			FM0_PrevAVG = (FM0_PrevAVG+ROFTotal)/2;
		
			FM0_AVGString = FM0_PrevAVG @ "/" @ FireInterval[0]*GetROFModifier()*1000 @ "[FM:" $ 0 $"]"; 
		}
		FM0_ROFTicker +=1; 
	}
	FM0_LastFireTime = Sec*1000+MSec;
}

simulated function CalcFM1ROF(float Sec, float MSec) //Current seconds/Milliseconds
{
	local float ROFTotal;
	local int	i; 
	
	if((Sec*1000+MSec) - FM1_LastFireTime <= FireInterval[1]*GetROFModifier()*1000 && (Sec*1000+MSec) - FM1_LastFireTime > 0) 
	{
	FM1_ROFAvgs[ FM1_ROFTicker ] = (Sec*1000+MSec) - FM1_LastFireTime ;
	
	if(FM1_ROFTicker >= FM1_ROFTurnover) 
		{
		for(i=0;i<FM1_ROFTicker;i++)
		ROFTotal += FM1_ROFAvgs[i];
		FM1_ROFTicker = 0; 
		ROFTotal=ROFTotal/FM1_ROFTurnover;
		
		//`log(ROFTotal @ "/" @ FireInterval[1]*1000);
		
		if(FM1_PrevAVG==0) FM1_PrevAVG=FireInterval[1]*GetROFModifier()*1000;
		
		FM1_PrevAVG = (FM1_PrevAVG+ROFTotal)/2;
		
		//96 
		
		
		FM1_AVGString = FM1_PrevAVG @ "/" @ FireInterval[1]*GetROFModifier()*1000 @ "[FM:" $ 1 $"]"; ; 
		//`log("["$self.class $"]" @ FM1_PrevAVG);
		}
		FM1_ROFTicker+=1;
		 
		
	}
	else
	{
		FM1_ROFAvgs[FM1_ROFTicker] = FireInterval[1]*GetROFModifier()*1000;
		
		if(FM1_ROFTicker >= FM1_ROFTurnover) 
		{
		for(i=0;i<FM1_ROFTicker;i++)
			ROFTotal += FM1_ROFAvgs[i];
		FM1_ROFTicker = 0;
		ROFTotal=ROFTotal/FM1_ROFTurnover;
		//`log(ROFTotal @ "/" @ FireInterval[1]*1000); 
		
		if(FM1_PrevAVG==0) FM1_PrevAVG=FireInterval[1]*GetROFModifier()*1000;
		
		FM1_PrevAVG = (FM1_PrevAVG+ROFTotal)/2;
		
		
		FM1_AVGString = FM1_PrevAVG @ "/" @ FireInterval[1]*GetROFModifier()*1000 @ "[FM:" $ 1 $"]"; 
		//`log("["$self.class $"]" @ FM1_AVGString);
		}
		FM1_ROFTicker +=1; 
		
		
	}
		FM1_LastFireTime = Sec*1000+MSec;
	
}


simulated function SetWeaponRecoil() {
	DeltaPitchX = 50.0;
	recoiltime = 1.2;
	bWasNegativeRecoil = false;
	bWasPositiveRecoilSecondTime = false;
	RandRecoilIncrease = Rand(4);
}

simulated function ProcessViewRotation( float DeltaTime, out rotator out_ViewRotation, out Rotator out_DeltaRot )
{
	local float DeltaPitch;
	
	if(recoiltime > 0) {
		recoiltime -= Deltatime;
		DeltaPitchXOld = DeltaPitchX;
		DeltaPitchX += (Deltatime*(23.3 - RandRecoilIncrease/2.0));
		DeltaPitch = (sin(1.0/2.0*DeltaPitchX)*120.0)/(DeltaPitchX/2.0)^1.2;

		if(DeltaPitch>0) {		
			if(bWasNegativeRecoil) {
				DeltaPitch = DeltaPitch*2.4;
				bWasPositiveRecoilSecondTime = true;
			} else {
				DeltaPitch = Deltapitch*2.0;
			}
		}
		if(DeltaPitch<0) {
			if(bWasPositiveRecoilSecondTime) {
				return;
			}
			DeltaPitchX -= (Deltatime*10.0)/1.4;
			DeltaPitch = (sin(1.0/2.0*DeltaPitchX)*100.0)/(DeltaPitchX/2.0)^1.2;	
			bWasNegativeRecoil = true;
			DeltaPitch = Deltapitch*4.0;	
		}
		if(DeltaPitch<0) {
			DeltaPitch -= RandRecoilIncrease;
		} else {
			DeltaPitch += RandRecoilIncrease;
		}
		out_DeltaRot.Pitch += DeltaPitch;
		//loginternal("DeltaPitchX"$DeltaPitchX-DeltaPitchXOld);
		//loginternal("DeltaPitch"$DeltaPitch);
	}
}

simulated function Projectile ProjectileFire()	// Add impulse on the vehicle everytime the vehicle fires
{
    local UDKProjectile SpawnedProjectile;
    local vector ForceLoc;

	if(!UsesClientSideProjectiles(CurrentFireMode)) {
		return ProjectileFireOld();
	}
	
	IncrementFlashCount();
	//`log("Using New PF"); 
	if(bCheckIfBarrelInsideWorldGeomBeforeFiring && IsBarrelInGeometry()) SpawnedProjectile = UDKProjectile(Spawn(GetProjectileClassSimulated(),,, Rx_Vehicle(MyVehicle).GetAdjustedPhysicalFireStartLoc(self)));
	else
	SpawnedProjectile = UDKProjectile(Spawn(GetProjectileClassSimulated(),,, MyVehicle.GetPhysicalFireStartLoc(self)));
	if ( SpawnedProjectile != None )
	{
		SpawnedProjectile.Init( vector(AddSpread(MyVehicle.GetWeaponAim(self))) );
		if(Rx_Projectile(SpawnedProjectile) != none ) 
		{
			Rx_Projectile(SpawnedProjectile).SetWeaponInstigator(self);
			Rx_Projectile(SpawnedProjectile).Vrank=VRank; 
			Rx_Projectile(SpawnedProjectile).FMTag=CurrentFireMode;
			//Rx_Projectile(SpawnedProjectile).RxInitLifeSpan();
		}
		
		if ( Role==ROLE_Authority && MyVehicle != none && MyVehicle.Mesh != none)
		{
			// apply force to vehicle
			ForceLoc = MyVehicle.GetTargetLocation();
			ForceLoc.Z += 100;
			MyVehicle.Mesh.AddImpulse(RecoilImpulse*SpawnedProjectile.Velocity, ForceLoc);    
		} 

		if(WorldInfo.Netmode == NM_Client)
			ConsumeClientsideAmmo(CurrentFireMode);
	}

	
    if (bTargetLockingActive && Rx_Projectile_Rocket(SpawnedProjectile) != None)
    {
		SetRocketTarget(Rx_Projectile_Rocket(SpawnedProjectile));
    }    
    return SpawnedProjectile;
}

simulated function class<Projectile> GetProjectileClassSimulated()
{
	return (CurrentFireMode < WeaponProjectiles.length) ? WeaponProjectiles[CurrentFireMode] : None;
}

simulated function Projectile ProjectileFireOld()
{
    local UDKProjectile SpawnedProjectile;
    local vector ForceLoc;
	
	
	
    SpawnedProjectile = UDKProjectile(Super.ProjectileFire());
	
	//`log("Call Projectile Fire Old" @ SpawnedProjectile); 
	//ScriptTrace();
	
	if(Rx_Projectile(SpawnedProjectile) != none ) 
	{
		Rx_Projectile(SpawnedProjectile).Vrank=VRank; 
		Rx_Projectile(SpawnedProjectile).FMTag=CurrentFireMode; 
		Rx_Projectile(SpawnedProjectile).SetWeaponInstigator(self);
	}
	else if(Rx_Projectile_Rocket(SpawnedProjectile) != none)
	{
		Rx_Projectile_Rocket(SpawnedProjectile).SetWeaponInstigator(self);
	}
	
	if(bLockedOnTarget && bDropOnTarget && CurrentFireMode != 1) 
	{
		UseArcShot( Rx_Projectile_Rocket(SpawnedProjectile) );
		SpawnedProjectile.Init( vector(AddSpread(MyVehicle.GetWeaponAim(self))) );
	}
    if ( (Role==ROLE_Authority) && (SpawnedProjectile != None) && MyVehicle != none && MyVehicle.Mesh != none)
    {
        // apply force to vehicle
        ForceLoc = MyVehicle.GetTargetLocation();
        ForceLoc.Z += 100;
        MyVehicle.Mesh.AddImpulse(RecoilImpulse*SpawnedProjectile.Velocity, ForceLoc);
    }  

	
	if (bTargetLockingActive && Rx_Projectile_Rocket(SpawnedProjectile) != None)
    {
		SetRocketTarget(Rx_Projectile_Rocket(SpawnedProjectile));
    }    
    return SpawnedProjectile;
}

simulated function SetRocketTarget(Rx_Projectile_Rocket Rocket)
{
	local vector CameraLocation, HitLocation, HitNormal, DesiredAimPoint;
	local rotator CameraRotation;	
	local Controller C;
	
	if (bLockedOnTarget && (!SecondaryLockingDisabled || CurrentFireMode != 1 || AIController(UTVehicle(Owner).Controller) != None ))
	{
		Rocket.SeekTarget = LockedTarget;
		Rocket.GotoState('Homing');
	}
	else
	{
		//Rocket.Target = GetDesiredAimPoint() // The Trace in GetDesiredAimPoint() sometimes wasent accurate enough in all situations and has been modified below
		
		C = (MyVehicle != None) ? MyVehicle.Seats[SeatIndex].SeatPawn.Controller : None;
		if(PlayerController(C) != None)
		{
			PlayerController(Instigator.Controller).GetPlayerViewPoint(CameraLocation, CameraRotation);
			
			if(Rx_Controller(Instigator.Controller).bBehindView && Rx_Controller(Instigator.Controller).ViewTarget != none) CameraLocation = CameraLocation + vector(CameraRotation) * VSize(CameraLocation - MyVehicle.GetEffectLocation(SeatIndex) );//Rx_Controller(Instigator.Controller).ViewTarget.location); //Again, the camera is capable of getting stuck in both geometry and behind vehicles. Scan up closer to the actual vehicle so we don't shoot behind ourselves.
			//`log(VSize(CameraLocation -  MyVehicle.GetEffectLocation(SeatIndex)));//Rx_Controller(Instigator.Controller).ViewTarget.location));
			DesiredAimPoint = CameraLocation + Vector(CameraRotation) * GetTraceRange(); 
			if (GetTraceOwner().Trace(HitLocation, HitNormal, DesiredAimPoint, CameraLocation, true, vect(0,0,0),,TRACEFLAG_Bullet) != None)
			{
				DesiredAimPoint = HitLocation;
			}
		}
		else if ( C != None )
		{
			DesiredAimPoint = C.GetFocalPoint();
		}	
		Rocket.Target = DesiredAimPoint;	
		
		Rocket.GotoState('Homing');
	}
}

simulated function UseArcShot(Rx_Projectile_Rocket Rocket)
{
	Rocket.TossZ=TossZ_Mod;
	Rocket.BaseTrackingStrength=TrackingMod; 
	
}

function float GetOptimalRangeFor(Actor Target)
{
	if(!bSniping) {
		if(Vehicle(Target) != None) {
			return MaxRange() / 2;
		}
		if(Pawn(Target) != None) {
			return MaxRange() / 3;
		}		
	}
	return MaxRange();
}

function float SuggestAttackStyle()
{
	local float EnemyDist;

	if (Instigator.Controller.Enemy != None)
	{
		// recommend backing off if target is too close
		EnemyDist = VSizeSq(Instigator.Controller.Enemy.Location - Owner.Location);
		if ( EnemyDist < Square(GetOptimalRangeFor(Instigator.Controller.Enemy) ))
		{
			return -1.5;
		} 
		else
		{
			return 0.5;
		}
	}

	return -0.1;
}

function float GetAO_OkDist() {
	return 800;
}


/*********************************************************************************************
 * Target Locking
 *********************************************************************************************/

simulated function GetWeaponDebug( out Array<String> DebugInfo )
{
    Super.GetWeaponDebug(DebugInfo);

    DebugInfo[DebugInfo.Length] = "Locked: "@bLockedOnTarget@LockedTarget@LastLockedontime@(WorldInfo.TimeSeconds-LastLockedOnTime);
    DebugInfo[DebugInfo.Length] = "Pending:"@PendingLockedTarget@PendingLockedTargetTime@WorldInfo.TimeSeconds;
}

/**
 *  This function is used to adjust the LockTarget.
 */
function AdjustLockTarget(actor NewLockTarget)
{
    if ( LockedTarget == NewLockTarget )
    {
        // no need to update
        return;
    }

    if (NewLockTarget == None)
    {
        // Clear the lock
        if (bLockedOnTarget)
        {
            LockedTarget = None;

            bLockedOnTarget = false;

            if (LockLostSound != None && Instigator != None && Instigator.IsHumanControlled() )
            {
                PlayerController(Instigator.Controller).ClientPlaySound(LockLostSound);
            }
        }
    }
    else
    {
        // Set the lcok
        bLockedOnTarget = true;
        LockedTarget = NewLockTarget;
        LockedTargetPRI = (Pawn(NewLockTarget) != None) ? Pawn(NewLockTarget).PlayerReplicationInfo : None;
        if ( LockAcquiredSound != None && Instigator != None  && Instigator.IsHumanControlled() )
        {
            PlayerController(Instigator.Controller).ClientPlaySound(LockAcquiredSound);
        }
    }
}

/**
* Given an potential target TA determine if we can lock on to it.  By default only allow locking on
* to pawns.  
*/
simulated function bool CanLockOnTo(Actor TA)
{
    if ( (TA == None) || !TA.bProjTarget || TA.bDeleteMe || (Pawn(TA) == None) || (TA == Instigator) || (Pawn(TA).Health <= 0)
    		|| TA.IsInState('Stealthed') || TA.IsInState('BeenShot') || Rx_Pawn(TA) != none || Rx_SupportVehicle_DropOffChinook(TA) != none)
    {
        return false;
    }

    return ( (WorldInfo.Game == None) || !WorldInfo.Game.bTeamGame || (WorldInfo.GRI == None) || !WorldInfo.GRI.OnSameTeam(Instigator,TA) );
}


/**
  * Check target locking - server-side only
  */
event Tick( FLOAT DeltaTime )
{
    if ( bTargetLockingActive && ( WorldInfo.TimeSeconds > LastTargetLockCheckTime + LockCheckTime ) )
    {
        LastTargetLockCheckTime = WorldInfo.TimeSeconds;
        CheckTargetLock();
    }
}


/**
* This function checks to see if we are locked on a target
*/
function CheckTargetLock()
{
    local Pawn P, LockedPawn;
    local Actor BestTarget, HitActor, TA;
    local AIController BotController;
    local vector StartTrace, EndTrace, Aim, HitLocation, HitNormal;
    local rotator AimRot;
    local float BestAim, BestDist;

    if ( (Instigator == None) || (Instigator.Controller == None) || (self != Instigator.Weapon) )
    {
        return;
    }

    if ( Instigator.bNoWeaponFiring )
    {
        AdjustLockTarget(None);
        PendingLockedTarget = None;
        return;
    }

    // support keeping lock as players get onto hoverboard
    if ( LockedTarget != None )
    {
        if ( LockedTarget.bDeleteMe )
        {
            if ( (LockedTargetPRI != None) && (UTVehicle_Hoverboard(LockedTarget) != None) )
            {
                // find the appropriate pawn
                for ( P=WorldInfo.PawnList; P!=None; P=P.NextPawn )
                {
                    if ( P.PlayerReplicationInfo == LockedTargetPRI )
                    {
                        AdjustLockTarget((Vehicle(P) != None) ? None : P);
                        break;
                    }
                }
            }
            else
            {
                AdjustLockTarget(None);
            }
        }
        else 
        {
            LockedPawn = Pawn(LockedTarget);
            if ( (LockedPawn != None) && (LockedPawn.DrivenVehicle != None) )
            {
                AdjustLockTarget(UTVehicle_Hoverboard(LockedPawn.DrivenVehicle));
            }
        }
    }

    BestTarget = None;
    BotController = AIController(Instigator.Controller);
    if ( BotController != None )
    {
        // only try locking onto bot's target
        if ( (BotController.Focus != None) && CanLockOnTo(BotController.Focus) )
        {
        	if(VSizeSq(BotController.Focus.Velocity) < 22500) {
				BestTarget = BotController.Focus;
			} else {
				if(Rx_Bot(BotController) != None) {
					if(BotController.Skill < 4) {
						if(FRand() < 0.3)
							BestTarget = BotController.Focus;
					} else if(BotController.Skill == 4) { 
						if(FRand() < 0.5)
							BestTarget = BotController.Focus;
					} else if(BotController.Skill <=6) { 
						if(FRand() < 0.7)
							BestTarget = BotController.Focus;
					} else {
						BestTarget = BotController.Focus;
					}
				} else {
					BestTarget = BotController.Focus;
				}
			}
        }
    }
    else
    {
        // Begin by tracing the shot to see if it hits anyone
        Instigator.Controller.GetPlayerViewPoint( StartTrace, AimRot );
        Aim = vector(AimRot);
		if(Rx_Controller(Instigator.Controller).bBehindView) StartTrace = StartTrace + Aim * VSize(StartTrace - MyVehicle.GetEffectLocation(SeatIndex)); //150 offset to account for the camera possibly being stuck in something
        EndTrace = StartTrace + Aim * LockRange;
        HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true,,, TRACEFLAG_Bullet);

        // Check for a hit
        if ( (HitActor == None) || !CanLockOnTo(HitActor) )
        {
            // We didn't hit a valid target, have the controller attempt to pick a good target
            BestAim = ((UDKPlayerController(Instigator.Controller) != None) && UDKPlayerController(Instigator.Controller).bConsolePlayer) ? ConsoleLockAim : LockAim;
            BestDist = 0.0;
            TA = Instigator.Controller.PickTarget(class'Vehicle', BestAim, BestDist, Aim, StartTrace, LockRange);
            if ( TA != None && CanLockOnTo(TA) )
            {
                BestTarget = TA;
            }
        }
        else    // We hit a valid target
        {
            BestTarget = HitActor;
        }
    }

    // If we have a "possible" target, note its time mark
    if ( BestTarget != None )
    {
        LastValidTargetTime = WorldInfo.TimeSeconds;

        if ( BestTarget == LockedTarget )
        {
            LastLockedOnTime = WorldInfo.TimeSeconds;
        }
        else
        {
            if ( LockedTarget != None && ((WorldInfo.TimeSeconds - LastLockedOnTime > LockTolerance) || !CanLockOnTo(LockedTarget)) )
            {
                // Invalidate the current locked Target
                AdjustLockTarget(None);
            }

            // We have our best target, see if they should become our current target.
            // Check for a new Pending Lock
            if (PendingLockedTarget != BestTarget)
            {
                PendingLockedTarget = BestTarget;
                PendingLockedTargetTime = ((Vehicle(PendingLockedTarget) != None) && (UDKPlayerController(Instigator.Controller) != None) && UDKPlayerController(Instigator.Controller).bConsolePlayer)
                                        ? WorldInfo.TimeSeconds + 0.5*LockAcquireTime
                                        : WorldInfo.TimeSeconds + LockAcquireTime;
            }

            // Otherwise check to see if we have been tracking the pending lock long enough
            else if (PendingLockedTarget == BestTarget && WorldInfo.TimeSeconds >= PendingLockedTargetTime )
            {
                AdjustLockTarget(PendingLockedTarget);
                LastLockedOnTime = WorldInfo.TimeSeconds;
                PendingLockedTarget = None;
                PendingLockedTargetTime = 0.0;
            }
        }
    }
    else 
    {
        if ( LockedTarget != None && ((WorldInfo.TimeSeconds - LastLockedOnTime > LockTolerance) || !CanLockOnTo(LockedTarget)) )
        {
            // Invalidate the current locked Target
            AdjustLockTarget(None);
        }

        // Next attempt to invalidate the Pending Target
        if ( PendingLockedTarget != None && ((WorldInfo.TimeSeconds - LastValidTargetTime > LockTolerance) || !CanLockOnTo(PendingLockedTarget)) )
        {
            PendingLockedTarget = None;
        }
    }
}

simulated function ActiveRenderOverlays( HUD H )
{
   local PlayerController PC;
   PC = PlayerController(Instigator.Controller);
   
   if ( bLockedOnTarget && (LockedTarget != None) && (Instigator != None) && WorldInfo.NetMode != NM_DedicatedServer ) {
      if ( ((LocalPlayer(PC.Player) == None) || !LocalPlayer(PC.Player).GetActorVisibility(LockedTarget))) {
          DrawCrosshair(H);
          return;
      }
      else {
         DrawLockedOn( H );
      }
   }
   else {
   	  DrawCrosshair(H);
      bWasLocked = false;
   }
}

simulated event Destroyed()
{
    AdjustLockTarget(none);
    super.Destroyed();
}

/*
 * Dist
 * Distance function, returns the range between 2 vectors
 *
 * @param V1      - Location Point1
 * @param V2      - Location Point2
*/
function float Dist (vector V1, vector V2)
{
   return vSize(V1 - V2);
}

simulated function InstantFire()
{
	local vector StartTrace, EndTrace;
	local Array<ImpactInfo>	ImpactList;
	local ImpactInfo RealImpact;
	local int i;
	
	//`log("Instant Fire");
	
	if(WorldInfo.NetMode == NM_DedicatedServer && AIController(Instigator.Controller) == None) {
		return;	
	} else if(WorldInfo.Netmode == NM_Client ) {
		ConsumeClientsideAmmo(CurrentFireMode);
	}
	
	//This code is basically just going to find what the crosshairs are on, to set the end point of our direction vector
	StartTrace = InstantFireStartTrace();
	EndTrace = InstantFireEndTrace(StartTrace);
	bUsingAimingHelp = false;
	RealImpact = CalcWeaponFire(StartTrace, EndTrace, ImpactList);

	
	for (i = 0; i < ImpactList.length; i++)
	{
		if(WorldInfo.NetMode != NM_DedicatedServer && Instigator.Controller.IsLocalPlayerController()) {
			
			
			
			if(WorldInfo.NetMode == NM_Client && FracturedStaticMeshActor(RealImpact.HitActor) != None) {
				ProcessInstantHit(CurrentFireMode, ImpactList[i]);
			}
			
			if(Pawn(ImpactList[i].HitActor) != None && Pawn(ImpactList[i].HitActor).Health > 0 && Pawn(ImpactList[i].HitActor).GetTeamNum() != Instigator.GetTeamNum()) {
				Rx_Hud(Rx_Controller(Instigator.Controller).myHud).ShowHitMarker();
			}
			if(!TryHeadshot(CurrentFireMode,ImpactList[i])) {
				ServerALInstanthitHit(CurrentFireMode, ImpactList[i], RealImpact.HitLocation);
			}
		} else if(ROLE == ROLE_Authority && AIController(Instigator.Controller) != None) {
			ProcessInstantHit(CurrentFireMode, ImpactList[i]);
		}
		//`log("Did not process == Worldinfo:" @ WorldInfo.NetMode @ "FracturedStaticMeshActor" @ FracturedStaticMeshActor(RealImpact.HitActor));
	}

	if (Role == ROLE_Authority && (AIController(Instigator.Controller) != None || WorldInfo.NetMode == NM_StandAlone))
	{
		// Set flash location to trigger client side effects.
		// if HitActor == None, then HitLocation represents the end of the trace (maxrange)
		// Remote clients perform another trace to retrieve the remaining Hit Information (HitActor, HitNormal, HitInfo...)
		// Here, The final impact is replicated. More complex bullet physics (bounce, penetration...)
		// would probably have to run a full simulation on remote clients.
		SetFlashLocation(RealImpact.HitLocation);
	}
	if (InstantHitDamageRadius[CurrentFireMode] > 0)
		InstantFireRadiusDamage(CurrentFireMode, RealImpact.HitLocation, RealImpact.HitNormal, RealImpact.HitActor);
	if(Role < ROLE_Authority) {
		MyVehicle.WeaponFired(self,false,RealImpact.HitLocation);
	}
}

simulated function bool TryHeadshot(byte FiringMode, ImpactInfo Impact) 
{
	local float Scaling;
	local int HeadDamage;
    	
		
		//`log("In TryHS" @ WeaponFireTypes[FiringMode] == EWFT_InstantHit); 
		
	//scripttrace();	
	if(WeaponFireTypes[FiringMode] == EWFT_InstantHit)
	{
		if (Instigator == None || VSizeSq(Instigator.Velocity) < Square(Instigator.GroundSpeed * Instigator.CrouchedPct))
		{
			Scaling = SlowHeadshotScale;
		}
		else
		{
			Scaling = RunningHeadshotScale;
		}

		HeadDamage = InstantHitDamage[FiringMode] * GetDamageModifier() * HeadShotDamageMult;
		
		//`log("TryHS" @ WeaponFireTypes[FiringMode] == EWFT_InstantHit @ HeadDamage );
		if ( (Rx_Pawn(Impact.HitActor) != None && Rx_Pawn(Impact.HitActor).TakeHeadShot(Impact, HeadShotDamageType, HeadDamage, Scaling, Instigator.Controller, false)))
		{
			SetFlashLocation(Impact.HitLocation);
		//	`log("True");
			return true;
		}
	}
		//`log("False");
	return false;
}

simulated function ProcessInstantHit( byte FiringMode, ImpactInfo Impact, optional int NumHits)
{
	local bool bFixMomentum;
	local KActorFromStatic NewKActor;
	local StaticMeshComponent HitStaticMesh;
	//We need all of this, as calling super doesn't account for veterancy.
	local int TotalDamage;
	
	
	//`log("Process Instant Hit");
	
	if(WorldInfo.NetMode != NM_DedicatedServer && TryHeadshot(FiringMode, Impact)) { // cause Headshotsphere detection is done clientside and then send as a ServerALHeadshotHit()
	//`log("Returned"); 	
	return;
	}

	if ( Impact.HitActor != None )
	{
		if ( Impact.HitActor.bWorldGeometry )
		{
			HitStaticMesh = StaticMeshComponent(Impact.HitInfo.HitComponent);
			if ( (HitStaticMesh != None) && HitStaticMesh.CanBecomeDynamic() )
			{
				NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitStaticMesh);
				if ( NewKActor != None )
				{
					Impact.HitActor = NewKActor;
				}
			}
		}
		if ( (Rx_Building(Impact.HitActor) != None || !Impact.HitActor.bStatic) && (Impact.HitActor != Instigator) )
		{
			if ( Impact.HitActor.Role == ROLE_Authority && Impact.HitActor.bProjTarget
				&& !WorldInfo.GRI.OnSameTeam(Instigator, Impact.HitActor)
				&& Impact.HitActor.Instigator != Instigator
				&& PhysicsVolume(Impact.HitActor) == None )
			{
				HitEnemy++;
				LastHitEnemyTime = WorldInfo.TimeSeconds;
			}
			if ( (UTPawn(Impact.HitActor) == None) && (InstantHitMomentum[FiringMode] == 0) )
			{
				InstantHitMomentum[FiringMode] = 1;
				bFixMomentum = true;
			}
			//Super(UDKWeapon).ProcessInstantHit(FiringMode, Impact, NumHits);
			
			//Copied from SUPER(Weapon) Adjusted to include Veterancy multipliers
			if (Impact.HitActor != None)
		{
		// default damage model is just hits * base damage
		NumHits = Max(NumHits, 1);
		TotalDamage = InstantHitDamage[CurrentFireMode] * GetDamageModifier() * NumHits;

		if ( Impact.HitActor.bWorldGeometry )
		{
			HitStaticMesh = StaticMeshComponent(Impact.HitInfo.HitComponent);
			if ( (HitStaticMesh != None) && HitStaticMesh.CanBecomeDynamic() )
			{
				NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitStaticMesh);
				if ( NewKActor != None )
				{
					Impact.HitActor = NewKActor;
				}
			}
		}
		Impact.HitActor.TakeDamage( TotalDamage, Instigator.Controller,
						Impact.HitLocation, InstantHitMomentum[FiringMode] * Impact.RayDir,
						InstantHitDamageTypes[FiringMode], Impact.HitInfo, self );
		}
			
			
			if (bFixMomentum)
			{
				InstantHitMomentum[FiringMode] = 0;
			}
		}
	}

}

reliable server function ServerALInstanthitHit( byte FiringMode, ImpactInfo Impact, vector RealImpactLocation)
{
	ProcessInstantHit(FiringMode, Impact);
	SetFlashLocation(RealImpactLocation);
}

reliable server function ServerALHeadshotHit(Actor Target, vector HitLocation, TraceHitInfo HitInfo)
{
	local class<Rx_Projectile>	ProjectileClass;
	local class<Rx_Projectile_Rocket> ProjectileClassRocket; 
	local class<DamageType> 	DamageType, TempDamageType; //TempDamageType Holds the REAL damage type for a weapon
	local Rx_Vehicle			Shooter;
	local vector				Momentum, FireDir;
	local float 				Damage, ArmorMultiplier;

	//`log("Process Headshot");
	
	ArmorMultiplier=1; //Used for infantry armour, so it will also apply to headshots
	
	Shooter = Rx_Vehicle(Owner);
	if(Shooter == None && UTWeaponPawn(Owner) != None)
		Shooter = Rx_Vehicle(UTWeaponPawn(Owner).MyVehicle); 
	
	ProjectileClass = class<Rx_Projectile>(GetProjectileClass());
	//If it is a rocket it won't be an Rx_Projectile
	if(ProjectileClass == none) ProjectileClassRocket = class<Rx_Projectile_Rocket>(GetProjectileClass());
	
	//`log("Shooter:" @ Shooter @ "Projectile: " @ ProjectileClass @ ProjectileClassRocket);
	
	//`log("WeaponFireTypes" @ WeaponFireTypes[CurrentFireMode]); 
	
	if(WorldInfo.Netmode == NM_DedicatedServer && AIController(Instigator.Controller) == None) {
		if(UTPlayercontroller(Instigator.Controller) == None || Rx_Controller(Instigator.Controller) == None) {
			return;
		} 
	}	

	// If we don't have a projectile class, and are not an instant hit weapon
	//if (ProjectileClass == none && !self.bInstantHit)
	
	if (ProjectileClass == none && ProjectileClassRocket == none && WeaponFireTypes[CurrentFireMode] != EWFT_InstantHit)
	{
		return;
	}
	if (Shooter == none || Target == none)
	{
		return;  
	}
	if (Target != none && VSizeSq(Target.Location - HitLocation) > 62500 )
	{
		return;
	}
	if (Shooter.Health <= 0 && !IsInsideGracePeriod(VSize(Target.Location - Shooter.Location)) )
	{
		return;
	}

	
	
	//if (!self.bInstantHit)
	if(WeaponFireTypes[CurrentFireMode] != EWFT_InstantHit)
	{
		if(ProjectileClassRocket == none)
		{
			
		
			Damage  = ProjectileClass.default.Damage * ProjectileClass.static.GetDamageModifier(VRank, Instigator.Controller) * ProjectileClass.default.HeadShotDamageMult;
			TempDamageType = ProjectileClass.default.MyDamageType;
			
			FireDir = Normal(Target.Location - Instigator.Location);
			Momentum = ProjectileClass.default.MomentumTransfer * FireDir;

			if(ProjectileClass.default.HeadShotDamageType != None) 
			{
				DamageType = ProjectileClass.default.HeadShotDamageType; 
				
			} 
			else 
			{
				DamageType = ProjectileClass.default.MyDamageType; 
			}
		}
		else
		if(ProjectileClassRocket != none)
		{
			
		
			Damage  = ProjectileClassRocket.default.Damage * ProjectileClassRocket.static.GetDamageModifier(VRank, Instigator.Controller) * ProjectileClassRocket.default.HeadShotDamageMult;
			TempDamageType = ProjectileClassRocket.default.MyDamageType;
			
			FireDir = Normal(Target.Location - Instigator.Location);
			Momentum = ProjectileClassRocket.default.MomentumTransfer * FireDir;

			if(ProjectileClassRocket.default.HeadShotDamageType != None) 
			{
				DamageType = ProjectileClassRocket.default.HeadShotDamageType; 
				
			} 
			else 
			{
				DamageType = ProjectileClassRocket.default.MyDamageType; 
			}
		}
			
	} else {
		Damage  = self.InstantHitDamage[CurrentFireMode] * GetDamageModifier() * self.HeadShotDamageMult;
		TempDamageType = self.InstantHitDamageTypes[CurrentFireMode];

		FireDir = Normal(Target.Location - Instigator.Location);
		Momentum = self.InstantHitMomentum[CurrentFireMode] * FireDir;

		if(self.HeadShotDamageType != None) 
		{
			DamageType = self.HeadShotDamageType;
		} 
		else 
		{
			DamageType = self.InstantHitDamageTypes[CurrentFireMode];
		}
	}

	if(Rx_Pawn(Target) != None && Rx_Pawn(Target).Armor > 0 ) 
	{
		Rx_Pawn(Target).setbHeadshot(true);	
		
		//Adjust for armour, as Rx_Pawn does not inherently adjust damage if it is a headshot 
		if(Rx_Pawn(Target).GetArmor() == A_KEVLAR) ArmorMultiplier=class<Rx_DmgType>(TempDamageType).static.KevlarDamageScalingFor(); 
		else
		if(Rx_Pawn(Target).GetArmor() == A_FLAK) ArmorMultiplier=class<Rx_DmgType>(TempDamageType).static.FlakDamageScalingFor(); 
		else
		if(Rx_Pawn(Target).GetArmor() == A_LAZARUS) ArmorMultiplier=class<Rx_DmgType>(TempDamageType).static.LazarusDamageScalingFor(); 
		else
		ArmorMultiplier=1;
	}
	
		Damage*=ArmorMultiplier;

	
	if(WorldInfo.Netmode == NM_DedicatedServer)
	{
		SetFlashLocation(HitLocation);
	}		
	//`log("ServerALHeadshot Armor Multiplier: " @ ArmorMultiplier @ Damage);
	Target.TakeDamage(Damage, Instigator.Controller, HitLocation, Momentum, DamageType, HitInfo, self);	
}

reliable server function ServerALHit(Actor Target, vector HitLocation, TraceHitInfo HitInfo, bool mctDamage, byte FMTag)
{
	local class<Rx_Projectile>	ProjectileClass;
	local class<DamageType> 	DamageType;
	local Rx_Vehicle			Shooter;
	local vector				Momentum, FireDir;
	local float 				Damage;
	local float 				HitDistDiff;

	//`log("Process ServerALHit");
	
	Shooter = Rx_Vehicle(Owner);
	if(Shooter == None && UTWeaponPawn(Owner) != None)
		Shooter = Rx_Vehicle(UTWeaponPawn(Owner).MyVehicle); 

	if(Rx_Vehicle_MultiWeapon(self) != none) ProjectileClass=class<Rx_Projectile>(WeaponProjectiles[FMTag]) ;
	else
	ProjectileClass = class<Rx_Projectile>(GetProjectileClass());
	//`log("ProjectileClass IS: " @ ProjectileClass @ CurrentFireMode @ Shooter);
	
	/**
	if(Rx_Vehicle_MultiWeapon(self) != none && ProjectileClass==None) //Hack to fix the Mammoth for the moment. Honestly weapon to projectile relationships seem pretty bad all over
		{
		if(CurrentFireMode==0) ProjectileClass=class<Rx_Projectile>(WeaponProjectiles[1]); //Use the other
		else
		ProjectileClass=class<Rx_Projectile>(WeaponProjectiles[0]);
		}
	*/
	
	
	
	if(WorldInfo.Netmode == NM_DedicatedServer && AIController(Instigator.Controller) == None) {
		if(UTPlayercontroller(Instigator.Controller) == None || Rx_Controller(Instigator.Controller) == None) {
			return;
		} 
	}

	
	
	if (Shooter == none || Target == none || ProjectileClass == none)
	{
		
		
		return;  
	}
	if (Target != none)
	{
		HitDistDiff = VSizeSq(Target.Location - HitLocation);
		if(Rx_Building(Target) != None) {
			if(HitDistDiff > 9000000) {
				return;
			}
		} else if(HitDistDiff > 640000) {
			return;
		}
	}
	if (Shooter.Health <= 0 && !IsInsideGracePeriod(VSize(Target.Location - Shooter.Location)) )
	{
		return;
	}

	FireDir = Normal(Target.Location - Instigator.Location);

	Momentum = ProjectileClass.default.MomentumTransfer * FireDir;
	DamageType = ProjectileClass.default.MyDamageType;
	Damage = ProjectileClass.default.Damage * ProjectileClass.static.GetDamageModifier(VRank, Instigator.Controller);
	if(mctDamage) {
		Damage = Damage * class<Rx_DmgType>(DamageType).static.MCTDamageScalingFor();
	}
		
	//SetFlashLocation(HitLocation);
	//SetReplicatedImpact(HitLocation, FireDir, Shooter.Location, class, 0.0, true );

	Target.TakeDamage(Damage, Instigator.Controller, HitLocation, Momentum, DamageType, HitInfo, self);
}

reliable server function ServerALRadiusDamage(Actor Target, vector HurtOrigin, bool bFullDamage, byte FMTag)
{
	local class<Rx_Projectile>	ProjectileClass;
	local class<DamageType> 	DamageType;
	local Rx_Vehicle			Shooter;
	local float					Momentum;
	local float 				Damage,DamageRadius;

	

	//Shooter = Rx_Vehicle(Owner);
	Shooter = Rx_Vehicle(MyVehicle); 
	//ProjectileClass = class<Rx_Projectile>(GetProjectileClass());
	
	if(Rx_Vehicle_MultiWeapon(self) != none) ProjectileClass=class<Rx_Projectile>(WeaponProjectiles[FMTag]) ;
	else
	ProjectileClass = class<Rx_Projectile>(GetProjectileClass());
	
	//`log("ServerALRadiusDamage" @ Shooter @ ProjectileClass);
	
	if(WorldInfo.Netmode == NM_DedicatedServer && AIController(Instigator.Controller) == None) {
		if(Rx_Controller(Instigator.Controller) == None) {
			return;
		} 
	}		

	if (Shooter == none || Target == none || ProjectileClass == none)
	{
		return;  
	}
	/** Useless lines ??
	if (Target != none && VSizeSq(Target.Location - HurtOrigin) > 160000 )
	{
		return;
	}
	*/
	if (Shooter.Health <= 0 && !IsInsideGracePeriod(VSize(Target.Location - Shooter.Location)) )
	{
		return;
	}

	Momentum = ProjectileClass.default.MomentumTransfer;
	DamageType = ProjectileClass.default.MyDamageType;
	Damage = ProjectileClass.default.Damage*ProjectileClass.static.GetDamageModifier(VRank, Instigator.Controller);
	DamageRadius = ProjectileClass.default.DamageRadius;
	
	Target.TakeRadiusDamage(Instigator.Controller,Damage,DamageRadius,DamageType,Momentum,HurtOrigin,bFullDamage,self);
}


/*****************************
 * Instant Hit Radius Damage *  This section is an exact copy of what is in Rx_Weapon, so update accordingly.
 *****************************/

/** Based on Rx_Projectile::ProjectileHurtRadius - update accordingly. */
simulated function InstantFireRadiusDamage(byte FiringMode, vector HurtOrigin, vector HitNormal, Actor ImpactedActor)
{
	local vector AltOrigin, TraceHitLocation, TraceHitNormal;
	local Actor TraceHitActor;

	//`log("Process InstantFireRadiusDamage");
	
	// early out if already in the middle of hurt radius
	if ( bHurtEntry )
		return;

	AltOrigin = HurtOrigin;

	if ( (ImpactedActor != None) && ImpactedActor.bWorldGeometry )
	{
		// try to adjust hit position out from hit location if hit world geometry
		AltOrigin = HurtOrigin + 2.0 * class'Pawn'.Default.MaxStepHeight * HitNormal;
		//AltOrigin.Z += AddedZTranslate;
		TraceHitActor = Trace(TraceHitLocation, TraceHitNormal, AltOrigin, HurtOrigin, false,,,TRACEFLAG_Bullet);
		if ( TraceHitActor == None )
		{
			// go half way if hit nothing
			AltOrigin = HurtOrigin + class'Pawn'.Default.MaxStepHeight * HitNormal;
			//AltOrigin.Z += AddedZTranslate;
		}
		else
		{
			AltOrigin = HurtOrigin + 0.5*(TraceHitLocation - HurtOrigin);
		}
	}

	if (WorldInfo.NetMode == NM_Client)
	{
		InstantFireClientRadiusCheck(FiringMode, AltOrigin, ImpactedActor);
	}
	else if (AIController(Instigator.Controller) != None || WorldInfo.NetMode != NM_DedicatedServer)
	{
		InstantFireHurtRadius(FiringMode, AltOrigin, ImpactedActor, false);
	}
}

simulated function InstantFireClientRadiusCheck(byte FiringMode, vector HurtOrigin, Actor ImpactedActor)
{
	local Actor A;
	local array<ClientSideHit> Hits;
	local ClientSideHit Temp;
	
	//`log("Process InstantFireCLIENTRadiusDamage");
	
	// client radius check
	foreach VisibleCollidingActors( class'Actor', A, InstantHitDamageRadius[FiringMode], HurtOrigin,,,,class'RxIfc_ClientSideInstantHitRadius' )
	{
		if (A == ImpactedActor || RxIfc_ClientSideInstantHitRadius(A).ClientHitIsNotRelevantForServer() || (!InstantHitDamageRadiusIgnoreTeam[FiringMode] && Instigator.GetTeamNum() == A.GetTeamNum()) )
			continue;
		Temp.Distance = RxIfc_ClientSideInstantHitRadius(A).CalcRadiusDmgDistance(HurtOrigin);
		Temp.Actor = A;
		Hits[Hits.Length] = Temp;
	}
	
	if (Hits.Length > 0)
		Rx_Hud(Rx_Controller(Instigator.Controller).myHud).ShowHitMarker();

	ServerInstantFireRadiusStart(FiringMode, HurtOrigin, ImpactedActor);
	foreach Hits(Temp)
	{
		ServerInstantFireRadiusHit(Temp.Actor, Temp.Distance);
	}
}

reliable server function ServerInstantFireRadiusStart(byte FiringMode, vector HurtOrigin, Actor ImpactedActor)
{
	//`log("Process InstantFireRadiusSTART");
	ClientHitFiringMode = FiringMode;
	ClientHitHurtOrigin = HurtOrigin;
	InstantFireHurtRadius(FiringMode, HurtOrigin, ImpactedActor, true);
}

reliable server function ServerInstantFireRadiusHit(Actor HitActor, float Distance)
{
	//`log("Process InstantFireRadiusHIT");
	// Redo this check on the server due to lag consideration. ie a vehicle may have changed teams but that has yet to be replicated to the client
	if (!InstantHitDamageRadiusIgnoreTeam[ClientHitFiringMode] && Instigator.GetTeamNum() == HitActor.GetTeamNum())
		return;
	RxIfc_ClientSideInstantHitRadius(HitActor).TakeDamageFromDistance(FMax(Distance, 0), Instigator.Controller, InstantHitDamage[ClientHitFiringMode]*GetDamageModifier(), InstantHitDamageRadius[ClientHitFiringMode], 
			InstantHitDamageTypes[ClientHitFiringMode], InstantHitMomentum[ClientHitFiringMode], ClientHitHurtOrigin, InstantHitDamageRadiusDoFull[ClientHitFiringMode], self );
}

function InstantFireHurtRadius(byte FiringMode, vector HurtOrigin, Actor ImpactedActor, bool bSkipClientSideCalculated)
{
	local Actor	Victim;
	local TraceHitInfo HitInfo;
	local StaticMeshComponent HitComponent;
	local KActorFromStatic NewKActor;
	local bool bShowHit;

	//`log("Process InstantFireRadiuesHURT" @ FiringMode @ HurtOrigin @ ImpactedActor @ bSkipClientSideCalculated @ InstantHitDamage[FiringMode]);
	
	// Prevent HurtRadius() from being reentrant.
	if ( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class'Actor', Victim, InstantHitDamageRadius[FiringMode], HurtOrigin,,,,, HitInfo )
	{
		if ( (bSkipClientSideCalculated && RxIfc_ClientSideInstantHitRadius(Victim) != None) || ImpactedActor == Victim )
			continue;
		if ( Victim.bWorldGeometry )
		{
			// check if it can become dynamic
			// @TODO note that if using StaticMeshCollectionActor (e.g. on Consoles), only one component is returned.  Would need to do additional octree radius check to find more components, if desired
			HitComponent = StaticMeshComponent(HitInfo.HitComponent);
			if ( (HitComponent != None) && HitComponent.CanBecomeDynamic() )
			{
				NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitComponent);
				if ( NewKActor != None )
				{
					Victim = NewKActor;
				}
			}
		}
		if ( !Victim.bWorldGeometry && (Victim != self) && (Victim.bCanBeDamaged || Victim.bProjTarget) )
		{
			Victim.TakeRadiusDamage(Instigator.Controller, InstantHitDamage[FiringMode]*GetDamageModifier(), InstantHitDamageRadius[FiringMode], 
				InstantHitDamageTypes[FiringMode], InstantHitMomentum[FiringMode], HurtOrigin, InstantHitDamageRadiusDoFull[FiringMode], self);

			if (!bSkipClientSideCalculated && !bShowHit && PlayerController(Instigator.Controller) != None && Pawn(Victim) != None && (InstantHitDamageRadiusIgnoreTeam[ClientHitFiringMode] || Instigator.GetTeamNum() != Victim.GetTeamNum()) )
				bShowHit = true;
		}
	}
	if (bShowHit)
		Rx_Hud(Rx_Controller(Instigator.Controller).myHud).ShowHitMarker();

	bHurtEntry = false;
}
/*****************************/

function bool IsInsideGracePeriod(float ShotDistance)
{
	local float DiedTime, FlightTime;
	local class<Projectile> ProjClass;

	ProjClass = GetProjectileClass();
	if (ProjClass != none )		
		FlightTime = ShotDistance / ProjClass.default.Speed;
	else
		FlightTime = 0.075 ; 
		
	DiedTime = Rx_Controller(Instigator.Controller).GetLastDiedTime();
	
	if (DiedTime + FlightTime + 0.075 > WorldInfo.TimeSeconds)
		return true;
		
	return false;
}

simulated function bool UsesClientSideProjectiles(byte FireMode)
{
	return true;
}

simulated function bool ShouldRefire()
{
 	//local vector FireStartLoc;
 	local Rx_Vehicle veh;
 	
 	if(CurrentlyReloadingClientside)
 	{
		//`log("(RX_Weapon: Still reloading clientside)"); 
 		return false;
 	}
 		
 	if(bCheckIfFireStartLocInsideOtherVehicle)
 	{
 	    foreach CollidingActors(class'Rx_Vehicle', veh, 3, Owner.location, true)
   		{
			if(veh == Pawn(Owner))
				continue;
			//`log("Cleared Pending Fire"); 
			ClearPendingFire(CurrentFireMode);
			ClientPendingFire[CurrentFireMode] = false;
			return false;
		}
	} 	
	
	if(bROFChanged && IsTimerActive('RefireCheckTimer')) UpdateRateofFire() ;
	
	return super.ShouldRefire();
}

simulated function UpdateRateofFire()
{
	SetTimer(GetFireInterval(CurrentFireMode),true,'RefireCheckTimer');
	SetROFChanged(false); //Reset 
}

simulated function SetROFChanged(bool SetTo)
{
	bROFChanged = SetTo;
}

simulated function bool IsBarrelInGeometry()
{
local vector FireStartLoc;
	
	 	FireStartLoc = MyVehicle.GetEffectLocation(SeatIndex);
	 	if(!FastTrace(FireStartLoc,MyVehicle.location)) {
			return true;
		}
	return false;  	
	
}


simulated function bool IsBarrelInAnotherVehicle()

{
	local Rx_Vehicle veh;
	
 	    foreach CollidingActors(class'Rx_Vehicle', veh, 3, Owner.location, true)
   		{
			if(veh == Pawn(Owner))
				continue;
			return true;
		}
		return false; 
}

simulated function SetCurrentlyReloadingClientside(bool NewValue)	
{
	CurrentlyReloadingClientside = NewValue;	
}

simulated function SetCurrentlyReloadingClientsideToFalseTimer()	
{
	CurrentlyReloadingClientside = false;	
}

//Inject to keep server and client in sync with reloading weapons 
simulated function StartFire(byte FireModeNum)
{
	//`log(self @ "-----------Firing------------"); 
	if(UTBot(instigator.Controller) != None || AIController(Instigator.Controller) != none) 
	{
		
		super.StartFire(FireModeNum); 
		return; 
	}
	
	if( Instigator == None || !Instigator.bNoWeaponFiring )
	{
		
		ClientPendingFire[FireModeNum]=true; 
		
		if(bReadyToFire() && (Role < Role_Authority || WorldInfo.NetMode == NM_StandAlone))
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

simulated function StopFire(byte FireModeNum)
{
	super.StopFire(FireModeNum); 
	ClientPendingFire[FireModeNum]=false; 
}

function bool CanAttack(Actor Other)
{
	local float Dist;
	local vector out_HitLocation, projStart;
	local vector out_HitNormal;
	local float CachedMaxRangeTemp;
	local bool ret;
	local Actor RealTarget;
	
	if (Instigator == None || Instigator.Controller == None)
	{
		return false;
	}	

	projStart = bInstantHit ? InstantFireStartTrace() : GetPhysicalFireStartLoc();
	
	RealTarget = Other;
	CachedMaxRangeTemp = CachedMaxRange;
	// check that target is within range
	Dist = VSizeSq(Instigator.Location - Other.Location);
	if (Dist > Square(MaxRange()))
	{
		if(Rx_Building(Other) != None || Rx_BuildingObjective(Other) != None || Rx_BuildingAttachment(Other) != None) 
		{
			if(Rx_BuildingObjective(Other) != None && Rx_BuildingObjective(Other).myBuilding != None) 
				RealTarget = Rx_BuildingObjective(Other).myBuilding;

			if(RealTarget != Trace( out_HitLocation, out_HitNormal, RealTarget.GetTargetLocation(), projStart,TRUE,,,TRACEFLAG_Bullet)) {
				return false;
			}
			Dist = VSizeSq(Instigator.GetWeaponStartTraceLocation() - out_HitLocation);
			if(Dist <= Square(MaxRange() - 50))
			{
				CachedMaxRange = 20000;		
			} 
			else 
			{
	            //DrawDebugLine(Instigator.Location,Other.location,0,0,255,true);
	            //DrawDebugLine(Instigator.Location,out_HitLocation,0,255,0,true);
            	//DebugFreezeGame();   
				return false;
			} 
		} 
		else 
		{
			return false;
		}
	}
	ret = Super.CanAttack(RealTarget);
	CachedMaxRange = CachedMaxRangeTemp;
	return ret;
}

function PromoteWeapon(byte rank) /*Covers most of what needs to be done(Damage,ROF,ClipSize,etc.) Special things obviously need to be added for special weapons*/
{
	VRank = rank; 
	UpdateHeroicEffects(rank==3); 
	CachedMaxRange = 0 ; //Ensure if the range changes after being promoted.
	ReplicateVRank(rank);
}

/**
 * Returns the Maximum Range for this weapon
 */
simulated function float MaxRange()
{
	local int i;
	local class<Rx_Projectile> RxProj;
	
	if ( CachedMaxRange > 0 )
	{
		return CachedMaxRange;
	}

	// return the range of the fire mode that fires farthest
	if (bInstantHit)
	{
		CachedMaxRange = WeaponRange;
	}

	for (i = 0; i < WeaponProjectiles.length; i++)
	{
		if(WeaponProjectiles[i] == none) continue;
		if (class<Rx_Projectile>(WeaponProjectiles[i]) != None)
		{
			RxProj=class<Rx_Projectile>(WeaponProjectiles[i]);
			CachedMaxRange = FMax(CachedMaxRange, WeaponProjectiles[i].static.GetRange()*RxProj.default.Vet_SpeedIncrease[VRank]*RxProj.default.Vet_LifespanModifier[VRank] );
		}
		else
		CachedMaxRange = FMax(CachedMaxRange, WeaponProjectiles[i].static.GetRange());
	}
	return CachedMaxRange;
}

reliable client function ClientGetAmmo();


simulated function UpdateHeroicEffects(bool bHeroic)
{
//	local Rx_Vehicle UTP;
	
	//`log("Update Heroic Effects" @ bHeroic @VRank); 
	if(bHeroic)
	{ 
		//If we have Heroic projectiles, switch to them
		if(WeaponProjectiles_Heroic.Length > 0) WeaponProjectiles[0]=WeaponProjectiles_Heroic[0];
		if(WeaponProjectiles_Heroic.Length > 1) WeaponProjectiles[1]=WeaponProjectiles_Heroic[1];	
		
		//Same for sounds
		if(WeaponFireSounds_Heroic.Length > 0) WeaponFireSnd[0]=WeaponFireSounds_Heroic[0];
		if(WeaponFireSounds_Heroic.Length > 1) WeaponFireSnd[1]=WeaponFireSounds_Heroic[1];	
		bNetDirty = true; 
	}
	else
	{
		WeaponProjectiles[0] = default.WeaponProjectiles[0];
		WeaponProjectiles[1] = default.WeaponProjectiles[1];	
		
		WeaponFireSnd[0] = default.WeaponFireSnd[0];
		WeaponFireSnd[1] = default.WeaponFireSnd[1];	
	}
}

simulated function string GetROFAVG()
{
	if(CurrentFireMode == 0) return "["$self.class $"]:" @ FM0_AVGString ; 
	else
	return "["$self.class $"]:" @ FM1_AVGString ; 	
}


simulated function float GetDamageModifier()
{
	if(Rx_Controller(Instigator.Controller) != none) return Vet_DamageModifier[VRank]+Rx_Controller(Instigator.Controller).Misc_DamageBoostMod; 
	else
	if(Rx_Bot(Instigator.Controller) != none) return Vet_DamageModifier[Vrank]+Rx_Bot(Instigator.Controller).Misc_DamageBoostMod; 
	else
	if(Rx_Defence_Controller(Instigator.Controller) != none) return Vet_DamageModifier[Vrank]+Rx_Defence_Controller(Instigator.Controller).Misc_DamageBoostMod; 
	else
	if(Rx_Vehicle_HarvesterController(Instigator.Controller) != none) return Vet_DamageModifier[Vrank]+Rx_Vehicle_HarvesterController(Instigator.Controller).Misc_DamageBoostMod; 
	else
	return 1.0; 
}

simulated function float GetROFModifier()
{
	if(Rx_Controller(Instigator.Controller) != none) return Vet_ROFModifier[VRank]+Rx_Controller(Instigator.Controller).Misc_RateOfFireMod; 
	else
	if(Rx_Bot(Instigator.Controller) != none) return Vet_ROFModifier[Vrank]+Rx_Bot(Instigator.Controller).Misc_RateOfFireMod; 
	else
	if(Rx_Vehicle_HarvesterController(Instigator.Controller) != none) return Vet_ROFModifier[Vrank]+Rx_Vehicle_HarvesterController(Instigator.Controller).Misc_RateOfFireMod;
	else
	if(Rx_Defence_Controller(Instigator.Controller) != none) return Vet_ROFModifier[Vrank]+Rx_Defence_Controller(Instigator.Controller).Misc_RateOfFireMod; 
	else
	return 1.0; 
}

reliable client function ReplicateVRank(byte rank)
{
	VRank = rank;
	UpdateHeroicEffects(rank==3);
	CachedMaxRange = 0 ; //Recache range
}

DefaultProperties
{
	InventoryGroup=0
	FireOffset=(X=0,Y=0,Z=0)

	bDebugWeapon = false
	BobDamping=0.7
	JumpDamping=1.0

	CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_Default_NoDot'
	LockedOnCrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_MissileLock'
	HitIndicatorCrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_HitMarker'
	DotCrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Simple'
	
	SecondaryLockingDisabled = true
	
	CrosshairWidth = 256
	CrosshairHeight = 256
	CloseRangeAimAdjustRange = 0.0
	
	RecoilImpulse = -0.3f

	HeadShotDamageType=class'Rx_DmgType_Headshot'
	HeadShotDamageMult=5.0
	SlowHeadshotScale=1.75
	RunningHeadshotScale=1.5

	InstantHitDamageRadius(0) = 0
	InstantHitDamageRadius(1) = 0
	InstantHitDamageRadiusDoFull(0) = false
	InstantHitDamageRadiusDoFull(1) = false
	InstantHitDamageRadiusIgnoreTeam(0) = false
	InstantHitDamageRadiusIgnoreTeam(1) = false
	
	ClientPendingFire(0) = false
	ClientPendingFire(1) = false
	
	//Veterancy
	
	VRank = 0 

	Vet_DamageModifier(0)=1  //Applied to instant-hits only
	Vet_DamageModifier(1)=1 
	Vet_DamageModifier(2)=1 
	Vet_DamageModifier(3)=1 
	
	Vet_ROFModifier(0) = 1
	Vet_ROFModifier(1) = 1  
	Vet_ROFModifier(2) = 1  
	Vet_ROFModifier(3) = 1  
	
	SF_Tolerance = 50; //For now, till it becomes an issue   
	
	FM0_ROFTurnover = 5; //9 for most automatics. Single shot weapons should be more, except the shotgun
	FM1_ROFTurnover = 5;
	
	FM0_AVGString = "X/X"
	FM1_AVGString = "X/X"

	bOkAgainstLightVehicles=true
	MaxFinalAimAdjustment=0.85
	}
