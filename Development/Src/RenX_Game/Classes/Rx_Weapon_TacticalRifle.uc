class Rx_Weapon_TacticalRifle extends Rx_Weapon_Charged;


var MaterialInstanceConstant    MCounterTens, MCounterOnes;
var MaterialInterface TeamSkin;
var byte TeamIndex;
var repnotify bool bUsingGrenade;
var bool bGrenadeCanBeFired;
var bool bSwitchingModes; 
var MaterialInstanceConstant AltCrosshairMIC; 

var float AltCrosshairHeight, AltCrosshairWidth, OffsetX, OffsetY, TextScale, TestAlpha, TestNum;
var color TestColor;

replication 
{
	if(ROLE == ROLE_AUTHORITY && bNetDirty)
		bUsingGrenade, bGrenadeCanBeFired; 
}


simulated event ReplicatedEvent(name VarName)
{
	if(VarName == 'bUsingGrenade') 
	{
		if(WorldInfo.NetMode==NM_Client && bSwitchingModes) bSwitchingModes=false; 
		//`log("Replicated bUsingGrenade" @ bUsingGrenade);
	}
    else 
    {
    	super.ReplicatedEvent(VarName);
    } 
}



simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	MCounterOnes = Mesh.CreateAndSetMaterialInstanceConstant(2);
	MCounterTens = Mesh.CreateAndSetMaterialInstanceConstant(1);
}

simulated function UpdateAmmoCounter()
{
	local int Ones, Tens;
	if ( WorldInfo.NetMode != NM_DedicatedServer)
	{
		Ones = CurrentAmmoInClip%10;
		Tens = ((CurrentAmmoInClip - Ones)/10)%10;

		MCounterOnes.SetScalarParameterValue('OnesClamp', Float(Ones));
		MCounterTens.SetScalarParameterValue('TensClamp', Float(Tens));
	}
}

simulated function SetSkin(Material NewMaterial)
{
	if( ( Instigator != none ) && ( NewMaterial == none ) )     // Clear the materials
	{

		Mesh.SetMaterial(0,TeamSkin);

		MCounterOnes.SetScalarParameterValue('TeamColour', TeamIndex);
		MCounterTens.SetScalarParameterValue('TeamColour', TeamIndex);
	}
	else
	{
		Super.SetSkin(NewMaterial);
	}
}

/**
 * Fires a projectile.
 * Spawns the projectile, but also increment the flash count for remote client effects.
 * Network: Local Player and Server
 */
simulated function Projectile ProjectileFire() //Modify to not use the same ammo if using the Grenade
{
	local vector		RealStartLoc;
	local Projectile	SpawnedProjectile;
	
	if(!bUsingGrenade && CurrentFireMode == 0) return super.ProjectileFire();
	else
	{
		// tell remote clients that we fired, to trigger effects
	IncrementFlashCount();

	// this is the location where the projectile is spawned.
	RealStartLoc = GetPhysicalFireStartLoc();
	
	// Spawn projectile	
	SpawnedProjectile = Spawn(GetProjectileClassSimulated(),,, RealStartLoc);
	if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
	{
		if(Rx_Bot(instigator.Controller) != None) {
			SpawnedProjectile.Init( Vector(GetAdjustedAim( RealStartLoc ) ) );
		} else {
			SpawnedProjectile.Init( Vector(GetAdjustedWeaponAim( RealStartLoc )) );
		}
		
	}
	
	// Return it up the line
	return SpawnedProjectile;
		
	}
}

function ConsumeAmmo( byte FireModeNum )
{
	if(!bUsingGrenade)
	{
	super.ConsumeAmmo(FireModeNum);
	UpdateAmmoCounter();
	}
}

//Override to allow firing of grenades even without 
simulated function bool HasAmmo( byte FireModeNum, optional int Amount )
{
	if(bUsingGrenade && bGrenadeCanBeFired) return true; 
	else
	return super.HasAmmo(FireModeNum, Amount); 
}

simulated function bool ShouldRefire()
{
	if(!bUsingGrenade) return super.ShouldRefire();
	 else { //Grenades should never have to re-fire 
	//	`log("Cleared ShouldRefire"); 
		ClearPendingFire(0);
		ClearPendingFire(1);
		return false;
	}
}

simulated function BeginFire(Byte FireModeNum)
{
if(bUsingGrenade && !bGrenadeCanBeFired) return; 
	
	//`log("BeginFire Clientside"); 
	
if(!bUsingGrenade)
	{
		WeaponProjectiles[0]=default.WeaponProjectiles[0];
		WeaponFireSnd[0]=default.WeaponFireSnd[0];
	}
	else
	{
		WeaponProjectiles[0]=default.WeaponProjectiles[1];	
		WeaponFireSnd[0]=default.WeaponFireSnd[1];
	}
super.BeginFire(FireModeNum); 	
}

simulated function FireAmmunition()
{
	//`log("Fired At all..."); 
	super.FireAmmunition();	
	
	if(bUsingGrenade && bGrenadeCanBeFired) //placing it here should capture any attempts to ever fire off more than one. 
	{
		//`log("Fired Grenade"); 
	bGrenadeCanBeFired = false; 
	SetTimer(ReloadTime[1], false, 'ReloadGrenadeTimer'); 	
	}
}

simulated function Activate()
{
	UpdateAmmoCounter();
	super.Activate();
}

simulated function PostReloadUpdate()
{
	UpdateAmmoCounter();
}

simulated function ReloadGrenadeTimer()
{
	if(WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_Standalone) bGrenadeCanBeFired = true; //Only let the server determine if grenades can be fired or not.  
}

simulated state WeaponFiring
{
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

	}

}

simulated state Active
{

	simulated function bool bReadyToFire()
	{
	 if(!bUsingGrenade)	return !CurrentlyReloading && !CurrentlyBoltReloading;
	 else
	return bGrenadeCanBeFired; 
	}

}

simulated function SwitchMode()
{
	if(WorldInfo.NetMode == NM_Client) bSwitchingModes=true; 
	ClearPendingFire(0);
	ClearPendingFire(1);
	ServerSwitchMode();
}

reliable server function ServerSwitchMode()
{
	/*Catch before we have more rapid-fire grenades*/
	ClearPendingFire(0);
	ClearPendingFire(1);
		
	if(bUsingGrenade==true) 
	{
		bUsingGrenade=false; 
		return;
	}
	if(bUsingGrenade==false) 
	{
		bUsingGrenade=true; 
		return;
	}
	
	
}

/**
 * Draw the Crosshairs
 * halo2pac - implemented code that changes crosshair color based on whats targeted.
 **/

 simulated function DrawCrosshair( Hud HUD )
{
	local float x,y;
	local UTHUDBase H;
	local Pawn MyPawnOwner;
	local actor TargetActor;
	local int targetTeam, rectColor;
	local string FireText; //Will make this an object variable if we break away from just the Tac-Rifle having firemodes
	local float TextL, TextH;
	local float AltWeaponTimeDifference; 
	local float ResScaleX, ResScaleY; 
	local float BarWidth; 
	
	H = UTHUDBase(HUD);
	if ( H == None )
		return;
	
	ResScaleX = H.Canvas.SizeX/1280.0;
	ResScaleY = H.Canvas.SizeY/720.0;
	
	// rectColor is an integer representing what we will pass to the texture's parameter(ReticleColourSwitcher):
	// 0=Default, 1=Red, 2=Green, 3=Yellow
	rectColor = 0;	
	
	
	/*Edited to take into account swapping crosshairs*/	
		if(!bUsingGrenade)
		{
		CrosshairMIC2.SetParent(CrosshairMIC);
		CrosshairWidth = default.CrosshairWidth + RecoilSpread*RecoilSpreadCrosshairScaling;	
		CrosshairHeight = default.CrosshairHeight + RecoilSpread*RecoilSpreadCrosshairScaling;
		
		CrosshairLinesX = H.Canvas.ClipX * 0.5 - (CrosshairWidth * 0.5);
		CrosshairLinesY = H.Canvas.ClipY * 0.5 - (CrosshairHeight * 0.5);	
		}
		else
		{
		CrosshairMIC2.SetParent(AltCrosshairMIC);
		CrosshairWidth = default.AltCrosshairWidth + RecoilSpread*RecoilSpreadCrosshairScaling;	
		CrosshairHeight = default.AltCrosshairHeight + RecoilSpread*RecoilSpreadCrosshairScaling;
		
		CrosshairLinesX = H.Canvas.ClipX * 0.5 - (CrosshairWidth * 0.5);
		CrosshairLinesY = H.Canvas.ClipY * 0.5 - (CrosshairHeight * 0.5);		
		}
		
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
		if (CurrentlyReloading ||
			CurrentlyBoltReloading || (BoltActionReload && HasAmmo(CurrentFireMode) && IsTimerActive('BoltActionReloadTimer'))) //reloading, go yellow
			rectColor = 3;
	}

	CrosshairMIC2. SetScalarParameterValue('ReticleColourSwitcher', rectColor);
	CrosshairDotMIC2. SetScalarParameterValue('ReticleColourSwitcher', rectColor);
	
	H.Canvas.SetPos( CrosshairLinesX, CrosshairLinesY );
	
	if(bDisplayCrosshair) 
		{
		H.Canvas.DrawMaterialTile(CrosshairMIC2, CrosshairWidth, CrosshairHeight);
		}
	
	if(!bUsingGrenade) // We don't need a dot for Grenades
	{
		CrosshairLinesX = H.Canvas.ClipX * 0.5 - (default.CrosshairWidth * 0.5);
		CrosshairLinesY = H.Canvas.ClipY * 0.5 - (default.CrosshairHeight * 0.5);
	
		GetCrosshairDotLoc(x, y, H);
		H.Canvas.SetPos( X, Y );
		if(bDisplayCrosshair)
			{
			H.Canvas.DrawMaterialTile(CrosshairDotMIC2, default.CrosshairWidth, default.CrosshairHeight);
			}
		DrawHitIndicator(H,x,y);
	}
	
	
	
	/***************************************************************/
	/*****Begin Drawing of Fire-Mode indicator and its friends******/
	/***************************************************************/
	
	X=H.Canvas.SizeX*OffsetX;
	Y=H.Canvas.SizeY*OffsetY; //The bottom right of the screen. 
	BarWidth=80*ResScaleX;
	
	
	
	if(bUsingGrenade) FireText="Launcher";
	else
	FireText="Rifle"; 


	H.Canvas.Font=Font'RenXTargetSystem.T_TargetSystemPercentage';
	//H.Canvas.Font=Font'RenxHud.Font.CTextFont24pt';
	H.Canvas.StrLen("Fire-Mode: " $ FireText ,TextL,TextH)		;
	
	
	//Draw Background
	H.Canvas.SetDrawColor(80,250,255,80) 	;
	H.Canvas.SetPos(X-(5*ResScaleX),Y)		; //Draw off to the left edge of where the text will be.  

	H.Canvas.DrawRect (TextL+(15*ResScaleX)*TextScale,TextH*TextScale, Texture2D'RenXPauseMenu.RenXPauseMenu_I14D'); //Rectangle should hang off of both sides.
	
	H.Canvas.SetPos( X, Y);
	H.Canvas.SetDrawColor(255,255,255,200); 
	
	H.Canvas.DrawText("Fire-Mode: " $ FireText ,true,TextScale,TextScale);
	H.Canvas.SetPos( X, Y);
	
	H.Canvas.SetPos( X-(5*ResScaleX), Y-(10*ResScaleY)) ;	
	
	
	
	
	
	//Set our color for the bar
	
	AltWeaponTimeDifference=(GetTimerRate('ReloadGrenadeTimer') - GetTimerCount('ReloadGrenadeTimer'));
	
	
	
	//MyIcon.UL/2*IconScale
	H.Canvas.SetPos(X-(5*ResScaleX),Y-(10*ResScaleY )); //Set position to draw the bar 
	//HUD.Canvas.SetPos(AttackVector.x-((MyIcon.UL/2)*IconScale), AttackVector.y-(MyIcon.VL*IconScale)); //Set position to draw the bar 
	
	if(AltWeaponTimeDifference != 0) //Don't divide by 0 
	{
		H.Canvas.SetDrawColor(255, 50, 50, 180); //Red
		H.Canvas.DrawBox(BarWidth-(BarWidth/(ReloadTime[1]/AltWeaponTimeDifference)) ,10*ResScaleY) ;
		
		//Draw Box background	
		
		H.Canvas.SetDrawColor(255,255,0,200); //Yellow
		H.Canvas.DrawBox(BarWidth,10*ResScaleY) ;	
	}		
	else
	{
		H.Canvas.SetDrawColor(100, 255, 128, 180); //Light blue
		H.Canvas.DrawBox(BarWidth,(10*ResScaleY))  ;
		
		//Draw Box background	
		H.Canvas.SetDrawColor(255,255,255,200);
		H.Canvas.DrawBox(BarWidth,10*ResScaleY) ;	
	}
	
	
	//100 - 100/(10/1) 
}

simulated function StartFire(byte FireModeNum)
{
	if( (bUsingGrenade && !bGrenadeCanBeFired) && bSwitchingModes  ) return;
	
	if( Instigator == None || !Instigator.bNoWeaponFiring )
	{
		
		ClientPendingFire[FireModeNum]=true; 
		
		if(bReadyToFire() && (Role < Role_Authority || WorldInfo.NetMode == NM_StandAlone))
		{
			// if we're a client, synchronize server
			//`log("Sending Fire Request"); 
			ServerStartFire(FireModeNum);
			BeginFire(FireModeNum);
			return;
		}

	
	}
}

defaultproperties
{
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_TacticalRifle.Mesh.SK_TacticalRifle_1P'
		AnimSets(0)=AnimSet'RX_WP_TacticalRifle.Anims.AS_TacticalRifle_1P'
		Animations=MeshSequenceA
		FOV=55
		Scale=2.0
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_TacticalRifle.Mesh.SK_WP_TacticalRifle_Back'
		// Translation=(X=-5)
		Scale=1.0
	End Object

	AttachmentClass=class'Rx_Attachment_TacticalRifle'
	
	LeftHandIK_Offset=(X=0.75,Y=-5,Z=1.5)
	RightHandIK_Offset=(X=-2,Y=3,Z=2)

	ArmsAnimSet=AnimSet'RX_WP_TacticalRifle.Anims.AS_TacticalRifle_Arms'
	
	FireOffset=(X=10,Y=7,Z=-5)
	
	PlayerViewOffset=(X=2.0,Y=1.0,Z=-1.0)
	
	//-------------- Recoil
	RecoilDelay = 0.02
	MinRecoil = 70.0
	MaxRecoil = 90.0
	MaxTotalRecoil = 7000.0
	RecoilYawModifier = 0.5 // will be a random value between 0 and this value for every shot
	RecoilInterpSpeed = 20.0
	RecoilDeclinePct = 0.4
	RecoilDeclineSpeed = 4.0
	MaxSpread = 0.04
	RecoilSpreadIncreasePerShot = 0.001
	RecoilSpreadDeclineSpeed = 0.1
	RecoilSpreadDecreaseDelay = 0.3
	RecoilSpreadCrosshairScaling = 1000;	// 2500

	bSplashJump=false
	bRecommendSplashDamage=false
	bSniping=true
	GroupWeight=5
	AimError=600

	InventoryGroup=2

	bGrenadeCanBeFired=true
	ShotCost(0)=1
	ShotCost(1)=0
	FireInterval(0)=+0.14
	FireInterval(1)=+0.0
	ReloadTime(0) = 3.0
	ReloadTime(1) = 15.0 //Grenade Reload time 
	
	EquipTime=0.5
//	PutDownTime=0.5
	
	Spread(0)=0.001
/*	
	WeaponRange=10000.0

	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_None

	InstantHitDamage(0)=16
	InstantHitDamage(1)=16

	InstantHitDamageRadius(0)=80
	
	HeadShotDamageMult=2.5

	InstantHitDamageTypes(0)=class'Rx_DmgType_TacticalRifle'
	InstantHitDamageTypes(1)=class'Rx_DmgType_TacticalRifle'

	InstantHitMomentum(0)=20000
	InstantHitMomentum(1)=20000
	
	bInstantHit=false
*/
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_Projectile //Used as the secondary when UsingGrenade is true 
	
	WeaponProjectiles(0)=class'Rx_Projectile_TacticalRifle'
	WeaponProjectiles(1)=class'Rx_Projectile_TacticalRifleGrenade' // Again, for the grenade

	FiringStatesArray(1)=Active


	ClipSize = 50
	InitalNumClips = 8
	MaxClips = 8
	
	FireDelayTime = 0.01
    bCharge = true

	ReloadAnimName(0) = "weaponreload"
	ReloadAnimName(1) = "weaponaltreload"
	ReloadAnim3PName(0) = "H_M_Autorifle_Reload"
	ReloadAnim3PName(1) = "H_M_Autorifle_Reload"
	ReloadArmAnimName(0) = "weaponreload"
	ReloadArmAnimName(1) = "weaponaltreload"
	
	WeaponPreFireAnim[0]="WeaponFireStart"
    WeaponPreFireAnim[1]="WeaponAltFire"
    WeaponFireAnim[0]="WeaponFireloop"
    WeaponFireAnim[1]="WeaponAltFire"
    WeaponPostFireAnim[0]="WeaponFireStop"
    WeaponPostFireAnim[1]="WeaponAltFire"

    ArmPreFireAnim[0]="WeaponFireStart"
    ArmPreFireAnim[1]="WeaponAltFire"
    ArmFireAnim[0]="WeaponFireloop"
    ArmFireAnim[1]="WeaponAltFire"
    ArmPostFireAnim[0]="WeaponFireStop"
    ArmPostFireAnim[1]="WeaponAltFire"	
	
	WeaponADSFireAnim[0]="WeaponFireADS"
	ArmADSFireAnim[0]="WeaponFireADS"
	
	WeaponPreFireSnd[0]=none
    WeaponPreFireSnd[1]=none
    WeaponFireSnd[0]=SoundCue'RX_WP_TacticalRifle.Sounds.SC_TacticalRifle_FireLoop'
    WeaponFireSnd[1]=SoundCue'RX_WP_TacticalRifle.Sounds.SC_GrenadeLauncher_Fire'
    WeaponPostFireSnd[0]=SoundCue'RX_WP_TacticalRifle.Sounds.SC_TacticalRifle_FireStop'
    WeaponPostFireSnd[1]=none

	WeaponPutDownSnd=SoundCue'RX_WP_TacticalRifle.Sounds.SC_TacticalRifle_PutDown'
	WeaponEquipSnd=SoundCue'RX_WP_TacticalRifle.Sounds.SC_TacticalRifle_Equip'
	ReloadSound(0)=SoundCue'RX_WP_TacticalRifle.Sounds.SC_TacticalRifle_Reload'
	ReloadSound(1)=SoundCue'RX_WP_TacticalRifle.Sounds.SC_TacticalRifle_Reload'

	PickupSound=SoundCue'RX_WP_TacticalRifle.Sounds.SC_TacticalRifle_Equip'

	MuzzleFlashSocket=MuzzleFlashSocket
	FireSocket=MuzzleFlashSocket
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_TacticalRifle.Effects.P_MuzzleFlash_1P'
	MuzzleFlashDuration=0.1
	MuzzleFlashLightClass=class'Rx_Light_AutoRifle_MuzzleFlash'

	CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_AutoRifle'
	
	/*Alternate Crosshair vars*/
	AltCrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_GrenadeLauncher'
	AltCrosshairWidth = 256
	AltCrosshairHeight = 256
	
	
	CrosshairWidth = 195
	CrosshairHeight = 195

	CrossHairCoordinates=(U=256,V=64,UL=64,VL=64)
	IconCoordinates=(U=726,V=532,UL=165,VL=51)
	InventoryMovieGroup=3
	WeaponIconTexture=Texture2D'RX_WP_TacticalRifle.UI.T_WeaponIcon_TacticalRifle'
	
	//==========================================
	// IRON SIGHT PROPERTIES
	//==========================================
	
	// IronSight:
	bIronSightCapable = true	
	IronSightViewOffset=(X=-12.0,Y=-6.08,Z=0.08)
	IronSightFireOffset=(X=10,Y=0,Z=-1)
	IronSightBobDamping=20
	IronSightPostAnimDurationModifier=0.2
	// This sets how much we want to zoom in, this is a value to be subtracted because smaller FOV values are greater levels of zoom
	ZoomedFOVSub=60.0 
	// New lower speed movement values for use while zoom aiming
	ZoomGroundSpeed=130.0
	ZoomAirSpeed=340.0
	ZoomWaterSpeed=11
	
	// IronSight additional vars to the vars in AimingWeaponClass (1 means unchanged, higher values mean more dmaping):
	IronSightMinRecoilDamping = 1.5					// 2		1.5
	IronSightMaxRecoilDamping = 1.5					// 2		1.5
	IronSightMaxTotalRecoilDamping = 1.5			// 2		1.5
	IronSightRecoilYawDamping = 1					// 1		1.0
	IronSightMaxSpreadDamping = 2					// 2		1.5
	IronSightSpreadIncreasePerShotDamping = 100		// 4		1.7

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_TacticalRifle'
	
	/*Test variables*/
	OffsetX = 0.825
	OffsetY = 0.90 
	TextScale = 1 
	TestNum=1
	
	bSwitchingModes=false
}