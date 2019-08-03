/*********************************************************
*
* File: Rx_Vehicle_StealthTank_Weapon.uc
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
class Rx_Vehicle_StealthTank_Weapon extends Rx_Vehicle_Weapon_Reloadable;


var float Target_Distance; //Delete after debugging
var	SoundCue WeaponDistantFireSnd;	// A second firing sound to be played when weapon fires. (Used for distant sound)
//	var int      MissileRecoilCount;
//	var int 	 i;


simulated function FireAmmunition()
{
    Super.FireAmmunition();
	WeaponPlaySound( WeaponDistantFireSnd );
}

simulated function bool UsesClientSideProjectiles(byte CurrFireMode)
{
	return false;
}

simulated function GetFireStartLocationAndRotation(out vector SocketLocation, out rotator SocketRotation) {
    
    super.GetFireStartLocationAndRotation(SocketLocation, SocketRotation);    
    
    if( (Rx_Bot(MyVehicle.Controller) != None) && (Rx_Bot(MyVehicle.Controller).GetFocus() != None) ) {
        if(class'Rx_Utils'.static.OrientationOfLocAndRotToB(SocketLocation,SocketRotation,Rx_Bot(MyVehicle.Controller).GetFocus()) > 0.6) {
			MaxFinalAimAdjustment = 0.450;	
        } else {
            MaxFinalAimAdjustment = 0.990;
        }
    }
}


/**simulated function DrawCrosshair( Hud HUD )
{
	local vector2d CrosshairSize;
	local float x,y;	
	local UTHUDBase H;
	local Pawn MyPawnOwner;
	local actor TargetActor;
	local int targetTeam;
	local LinearColor LC; //nBab

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
		UpdateRange(); 
		
	H.Canvas.DrawText("Range" @ Target_Distance ,true,1,1);
	}
	
}*/ 


/**
simulated function SetWeaponRecoil() {
	DeltaPitchX = 0.0;
	if(recoiltime > 0) {
		MissileRecoilCount += 2;
	} else {
        MissileRecoilCount = 0;
	}
	recoiltime = 1.2;
	bWasNegativeRecoil = false;
	bWasPositiveRecoilSecondTime = false;
	RandRecoilIncrease = Rand(2);
}

simulated function ProcessViewRotation( float DeltaTime, out rotator out_ViewRotation, out Rotator out_DeltaRot )
{
	local float DeltaPitch;
	
	if(recoiltime > 0) {
		recoiltime -= Deltatime;
		DeltaPitchXOld = DeltaPitchX;
		DeltaPitchX += (Deltatime*(20.0-MissileRecoilCount-RandRecoilIncrease/2.0));
		DeltaPitch = (5.0+RandRecoilIncrease)*sin(DeltaPitchX);

		if(DeltaPitch>0) {		
			if(bWasNegativeRecoil) {
				bWasPositiveRecoilSecondTime = true;
				return;
			} else {
				DeltaPitch = Deltapitch;
			}
		}
		if(DeltaPitch<0) {
			if(bWasPositiveRecoilSecondTime) {
				return;
			}	
			bWasNegativeRecoil = true;
			if(MissileRecoilCount > 0) {	
				DeltaPitch = Deltapitch*1.8;	
			}
		}
		if(DeltaPitch > 1.5 || DeltaPitch < -1.5)
			out_DeltaRot.Pitch += DeltaPitch*2.0;
		//loginternal("DeltaPitchX"$DeltaPitchX-DeltaPitchXOld);
		//loginternal("DeltaPitch"$DeltaPitch);
	}
}

simulated function rotator AddSpread(rotator BaseAim)
{
	local vector X, Y, Z;
	local float CurrentSpread, RandY, RandZ;

	CurrentSpread = Spread[CurrentFireMode];
	if (CurrentSpread == 0)
	{
		return BaseAim;
	}
	else
	{
		// Add in any spread.
		GetAxes(BaseAim, X, Y, Z);
		//RandY = FRand() - 0.5;
		//RandZ = Sqrt(0.5 - Square(RandY)) * (FRand() - 0.5);
		
		if(i++ == 0)
			RandY = -0.4;
		else
			RandY = 0.4;
		if(i > 1)
			i = 0;	
		RandZ = 0.1;
		return rotator(X + RandY * CurrentSpread * Y + RandZ * CurrentSpread * Z);
	}
}
*/

simulated function UpdateRange()
{
	
	local vector startL, normthing, endL;
	local rotator ADir					;
	local Actor Actor_Discard			;
	// get aiming direction from our instigator (Assume this is the pawn from what I've read.)
	 ADir = Instigator.GetBaseAimRotation();
	
	startL=InstantFireStartTrace(); //Using function out of Rx_weapon to find the end of our weapon, or just our own location
	
	//.......... Yosh need learn math. Working in 3D space is making me twitchy X.x
	
	Actor_Discard=Trace(endL, normthing, startL + vector(Adir) * 20000, startL, true) ;
	
	if(Actor_Discard == none) 
	{
	Target_Distance = 0 ; 	
	return;	
	}
	
	Target_Distance = round(VSize(endL-startL) ) ; // /52.5) ; 
	
	//NULL_Target = Actor_Discard;	
	
}




DefaultProperties
{
    InventoryGroup=17

    // reload config
    ClipSize = 2
    InitalNumClips = 999
    MaxClips = 999
    
    ShotCost(0)=1
    ShotCost(1)=1
    
    ReloadTime(0) = 1.5
    ReloadTime(1) = 1.5
    
	CloseRangeAimAdjustRange = 600    
    
    ReloadAnimName(0) = "weaponreload"
    ReloadAnimName(1) = "weaponreload"
    ReloadArmAnimName(0) = "weaponreload"
    ReloadArmAnimName(1) = "weaponreload"
 
    // gun config
    FireTriggerTags(0) = "TurretFireRight"
    FireTriggerTags(1) = "TurretFireLeft"
    AltFireTriggerTags(0) = "TurretFireRight"
    AltFireTriggerTags(1) = "TurretFireLeft"
	
	
    VehicleClass=Class'RenX_Game.Rx_Vehicle_StealthTank'

    FireInterval(0)=0.15
    FireInterval(1)=0.15
    bFastRepeater=true

    Spread(0)=0.03
    Spread(1)=0.03
	
	/****************************************/
	/*Veterancy*/
	/****************************************/
	
	//*X Reverse percentage (0.75 is 25% increase in speed)
	Vet_ROFModifier(0) = 1 //Normal
	Vet_ROFModifier(1) = 1  //Veteran
	Vet_ROFModifier(2) = 1  //Elite
	Vet_ROFModifier(3) = 0.80  //Heroic
 
	//+X
	Vet_ClipSizeModifier(0)=0 //Normal (should be 1)
	Vet_ClipSizeModifier(1)=0 //Veteran 
	Vet_ClipSizeModifier(2)=0 //Elite
	Vet_ClipSizeModifier(3)=0 //Heroic

	//*X Reverse percentage (0.75 is 25% increase in speed)
	Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1)
	Vet_ReloadSpeedModifier(1)=0.8 //Veteran 
	Vet_ReloadSpeedModifier(2)=0.65 //Elite
	Vet_ReloadSpeedModifier(3)=0.45 //Heroic
	
	
	/********************************/
	
    WeaponFireSnd(0)     = SoundCue'RX_VH_StealthTank.Sounds.SC_StealthTank_Fire'
    WeaponFireTypes(0)   = EWFT_Projectile
    WeaponProjectiles(0) = Class'Rx_Vehicle_StealthTank_Projectile'
    WeaponFireSnd(1)     = SoundCue'RX_VH_StealthTank.Sounds.SC_StealthTank_Fire'
    WeaponFireTypes(1)   = EWFT_Projectile
    WeaponProjectiles(1) = Class'Rx_Vehicle_StealthTank_Projectile'
	
	WeaponProjectiles_Heroic(0)= Class'Rx_Vehicle_StealthTank_Projectile_Heroic'
	WeaponProjectiles_Heroic(1)= Class'Rx_Vehicle_StealthTank_Projectile_Heroic'
	
	ReloadSound(0)=SoundCue'RX_VH_Apache.Sounds.SC_Reload_Missiles'
    ReloadSound(1)=SoundCue'RX_VH_Apache.Sounds.SC_Reload_Missiles'
	
	WeaponDistantFireSnd=SoundCue'RX_SoundEffects.Missiles.SC_Missile_DistantFire'
   
    CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_Tank_Type5A'

    // AI
    bRecommendSplashDamage=True
    
    //==========================================
    // LOCKING PROPERTIES
    //==========================================
    LockAcquiredSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_SeekLock_Cue'
    LockLostSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_SeekLost_Cue'

    LockTolerance		 = 0.5//0.2 			// 0.5		// How many seconds to stay locked

    LockRange            = 6000 //5200 //4500
    ConsoleLockAim       = 0.99			// 0.997000
    LockAim              = 0.99//0.997			// 0.998000
    LockCheckTime        = 0.1			// 0.1
    LockAcquireTime      = 0.5 			// 0.7
    StayLocked           = 0.1 			// 0.1		// This does nothing

	TossZ_Mod = 2000
	TrackingMod=20.0
	bDropOnTarget=false
	
    bTargetLockingActive = true
    bHasRecoil = true
    bIgnoreDownwardPitch = true
    bCheckIfFireStartLocInsideOtherVehicle = true
	
	FM0_ROFTurnover = 2; //9 for most automatics. Single shot weapons should be more, except the shotgun
	FM1_ROFTurnover = 2
	
    bOkAgainstLightVehicles = True
    bOkAgainstArmoredVehicles = True
    bOkAgainstBuildings = True
}
