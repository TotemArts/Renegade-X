/**
 * This class is basically a cloned RxWeapon_Spray, tweaked to work with weapons
 * like the minigun that have pre and post fire animations and delayed fire. Because
 * of this, some of the code in Spray may also be here. 
 * 
 * TODO: Refactor this class as well as spray so that code that is common to both is in
 * another abstract class that both classes extend.
 * 
 */

class Rx_Weapon_Charged extends Rx_Weapon_Reloadable
	abstract;

/** The Particle System Template for the Beam */
var ParticleSystem BeamTemplate[2];
var ParticleSystemComponent BeamEmitter[2];
var name BeamSocket[2];

/** Extra firing animations */
var name WeaponPreFireAnim[2];
var name WeaponPostFireAnim[2];
var name ArmPreFireAnim[2];
var name ArmPostFireAnim[2];

/** Extra firing sounds */
var	SoundCue WeaponPreFireSnd[2];
var	SoundCue WeaponPostFireSnd[2];

var int ProjectileCount;

/** The time to delay firing */
var float FireDelayTime;
var bool bCharge;
var bool bCharged;
var bool bPlayingADSFire;

simulated function AddBeamEmitter()
{
	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		if( BeamEmitter[CurrentFireMode] != None )
		{
			BeamEmitter[CurrentFireMode].SetActive(true);
		}
		else
		{
			if( BeamTemplate[CurrentFireMode] != None )
			{
				BeamEmitter[CurrentFireMode] = new(Outer) class'UTParticleSystemComponent';
				BeamEmitter[CurrentFireMode].SetTemplate(BeamTemplate[CurrentFireMode]);
				BeamEmitter[CurrentFireMode].bAutoActivate = false;
				BeamEmitter[CurrentFireMode].SetTickGroup( TG_PostAsyncWork );
				BeamEmitter[CurrentFireMode].bUpdateComponentInTick = true;
				BeamEmitter[CurrentFireMode].SetIgnoreOwnerHidden(TRUE);
				SkeletalMeshComponent(Mesh).AttachComponentToSocket( BeamEmitter[CurrentFireMode],BeamSocket[CurrentFireMode] );
			}
		}
	}
}

simulated function SetBeamEmitterActive(bool bActive)
{
	if( BeamEmitter[CurrentFireMode] != none )
		BeamEmitter[CurrentFireMode].SetActive(bActive);
}

simulated function LoopFireAnims()
{
	PlayWeaponAnimation(WeaponFireAnim[CurrentFireMode], 0.f, true);
	if( CurrentFireMode < ArmFireAnim.Length && ArmFireAnim[CurrentFireMode] != '' && ArmsAnimSet != none )
		PlayArmAnimation( ArmFireAnim[CurrentFireMode], 0.f,, true );

	bPlayingADSFire = false;
}

simulated function LoopADSFireAnims()
{
	if ( CurrentFireMode < WeaponADSFireAnim.Length && WeaponADSFireAnim[CurrentFireMode] != '')
		PlayWeaponAnimation(WeaponADSFireAnim[CurrentFireMode], 0.f, true);
	else
		PlayWeaponAnimation(WeaponFireAnim[CurrentFireMode], 0.f, true);

	if( CurrentFireMode < ArmADSFireAnim.Length && ArmADSFireAnim[CurrentFireMode] != '' && ArmsAnimSet != none )
		PlayArmAnimation( ArmADSFireAnim[CurrentFireMode], 0.f,, true );
	else if( CurrentFireMode < ArmFireAnim.Length && ArmFireAnim[CurrentFireMode] != '' && ArmsAnimSet != none )
		PlayArmAnimation( ArmFireAnim[CurrentFireMode], 0.f,, true );

	bPlayingADSFire = true;
}

simulated state WeaponCharging
{
	simulated function BeginState( Name PreviousStateName )
	{
		PlayPreFireEffects();
		super.BeginState(PreviousStateName);
	}

	simulated function EndState(Name NextStateName)
	{
		ClearTimer('GotoWeaponFiring');
		super.EndState(NextStateName);				
	}

	simulated function PlayPreFireEffects()
	{		

		// Play pre-fire weapon anim
		if( WeaponPreFireAnim[CurrentFireMode] != '' )
			PlayWeaponAnimation( WeaponPreFireAnim[CurrentFireMode], FireDelayTime );
		else if( WeaponFireAnim[CurrentFireMode] != '' )
			PlayWeaponAnimation( WeaponFireAnim[CurrentFireMode], GetFireInterval(CurrentFireMode) );

		// Play pre-fire arms anim
		if( ArmsAnimSet != none )
		{
			if( ArmPreFireAnim[CurrentFireMode] != '' )
				PlayArmAnimation( ArmPreFireAnim[CurrentFireMode], FireDelayTime);
			else if( ArmFireAnim[CurrentFireMode] != '' )
				PlayArmAnimation( ArmFireAnim[CurrentFireMode], GetFireInterval(CurrentFireMode) );
		}				

		// Attract attention of nearby AI's
		MakeNoise(1.0);
		
		bCharged = true;

		// Play weapon pre-fire sound
		if( WeaponPreFireSnd[CurrentFireMode] != None )
			WeaponPlaySound( WeaponPreFireSnd[CurrentFireMode] );	
		
		SetTimer(FireDelayTime,false,'GotoWeaponFiring');	
	}

	simulated function GotoWeaponFiring()
	{
		local AnimNodeSequence WeapNode;
		
		if( WorldInfo.NetMode != NM_DedicatedServer )
		{
			// Let pre-fire anim finish playing
			WeapNode = GetWeaponAnimNodeSeq();
			if( WeapNode != None && WeapNode.AnimSeqName == WeaponPreFireAnim[0] && WeapNode.GetTimeLeft() > 0 )
			{
				SetTimer(WeapNode.GetTimeLeft(), false,'GotoWeaponFiring');
				return;
			}
		}		
		GotoState('WeaponFiring');
	}

}

simulated state WeaponFiring
{
	simulated function BeginState( Name PreviousStateName )
	{
		local UTPawn POwner;

		//PlayPreFireEffects();
		
		if (bCharge && !bCharged)
			GotoState('WeaponCharging');
		else
		{
			POwner = UTPawn(Instigator);
			if( POwner != None )
			{
				// Activate beam
				AddBeamEmitter();
				SetBeamEmitterActive(true);

				// Set ambient sound
				POwner.SetWeaponAmbientSound(WeaponFireSnd[CurrentFireMode]);

				// Loop firing animation
				if (bIronsightActivated)
					LoopADSFireAnims();
				else
					LoopFireAnims();
			}						

			super.BeginState(PreviousStateName);
		}
	}

	simulated function EndState(Name NextStateName)
	{
		// Play post-fire effects
		if (bCharged)
			PlayPostFireEffects();
		
		// Set weapon as not firing
		super.EndState(NextStateName);
		
		bCharged = false;
	}

	simulated function RefireCheckTimer()
	{
		local UTPlayerController PC;

		// if switching to another weapon, abort firing and put down right away
		if( bWeaponPutDown )
		{
			PutDownWeapon();
			return;
		}

		// If weapon should keep on firing, then do not leave state and fire again.
		if( ShouldRefire() )
		{
			// trigger a view shake for the local player here, because effects are called every tick
			// but we don't want to shake that often
			PC = UTPlayerController(Instigator.Controller);
			if(PC != None && LocalPlayer(PC.Player) != None && CurrentFireMode < FireCameraAnim.length && FireCameraAnim[CurrentFireMode] != None)
			{
				PC.PlayCameraAnim(FireCameraAnim[CurrentFireMode], (GetZoomedState() > ZST_ZoomingOut) ? PC.GetFOVAngle() / PC.DefaultFOV : 1.0);
			}

			if (bIronsightActivated && !bPlayingADSFire)
				LoopADSFireAnims();
			else if (!bIronsightActivated && bPlayingADSFire)
				LoopFireAnims();

			FireAmmunition();
			return;
		}

		// Otherwise we're done firing, so go back to active state.
		GotoState('Active');

	}

	function SetFlashLocation(vector HitLocation)
	{
		Super.SetFlashLocation(HitLocation);

		// SetFlashLocation() resets Instigator's FiringMode so we need to make sure our overridden value stays applied
		SetCurrentFireMode(CurrentFireMode);
	}

	
	simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
	{
		local UTPlayerController PC;

		// Play controller vibration
		PC = UTPlayerController(Instigator.Controller);
		if( PC != None && LocalPlayer(PC.Player) != None )
			PC.ClientPlayForceFeedbackWaveform( WeaponFireWaveForm );

		// Start muzzle flash effect
		CauseMuzzleFlash();

		ShakeView();
	}

	simulated function PlayPostFireEffects()
	{
		local UTPawn POwner;

		// Stop ambient sound
		POwner = UTPawn(Instigator);
		if( POwner != None )
		{
			POwner.SetWeaponAmbientSound(None);
		}

		// Play post-fire weapon anim
		if( WeaponPostFireAnim[CurrentFireMode] != '' )
			PlayWeaponAnimation( WeaponPostFireAnim[CurrentFireMode], 1 * IronSightPostAnimDurationModifier );//PlayWeaponAnimation( WeaponPostFireAnim[CurrentFireMode], GetFireInterval(CurrentFireMode) );

		// Play post-fire arms anim
		if( ArmPostFireAnim[CurrentFireMode] != '' && ArmsAnimSet != none )
			PlayArmAnimation( ArmPostFireAnim[CurrentFireMode], 1 * IronSightPostAnimDurationModifier );//PlayArmAnimation( ArmPostFireAnim[CurrentFireMode], GetFireInterval(CurrentFireMode) );

		// Play weapon post-fire sound
		if( WeaponPostFireSnd[CurrentFireMode] != None )
			WeaponPlaySound( WeaponPostFireSnd[CurrentFireMode] );

		// Attract attention of nearby AI's
		MakeNoise(1.0);

		// Disable beam
		SetBeamEmitterActive(false);
	}

	/** view shaking for the beam mode is handled in RefireCheckTimer() */
	simulated function ShakeView();

	/** Do not play firing sound, use ambient one instead */
	simulated function PlayFiringSound()
	{
		// Attract attention of nearby AI's
		if(Rx_Weapon_AutoRifle(self) == None)
			MakeNoise(1.0);
	}	
}

simulated state Active
{
	simulated event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
	{
		local AnimNodeSequence WeapNode;

		if( WorldInfo.NetMode != NM_DedicatedServer )
		{
			// Let post-fire anim finish playing
			WeapNode = GetWeaponAnimNodeSeq();
			if( WeapNode != None && WeapNode.AnimSeqName == WeaponPostFireAnim[0] && WeapNode.GetTimeLeft() > 0 )
			{
				ClearTimer('OnAnimEnd');
				SetTimer(WeapNode.GetTimeLeft(), false,'OnAnimEnd');
				return;
			}
		}

		super.OnAnimEnd(SeqNode,PlayedTime,ExcessTime);
	}
}

function HolderDied()
{
	Super.HolderDied();

	//ExplosionOnDeath();
}

//function ExplosionOnDeath()
//{
//	local RenProj_FlameExplosion P;

//	//`log("ExplosionOnDeath" @Instigator);
//	if( Instigator != None )
//	{
//		P = Instigator.Spawn( class'RenProj_FlameExplosion' );
//		P.Explode(P.Location, vect(0,0,1));
//	}
//}

simulated function CustomFire()
{
	local vector		StartTrace, EndTrace, RealStartLoc, AimDir,X,Y,Z, RandomAim;
	local rotator		AdjustedAim;
	local ImpactInfo	TestImpact;
	local Projectile	SpawnedProjectile;
	local int			i;

	// tell remote clients that we fired, to trigger effects
	IncrementFlashCount();

	if( Role == ROLE_Authority )
	{
		// This is where we would start an instant trace. (what CalcWeaponFire uses)
		StartTrace = Instigator.GetWeaponStartTraceLocation();
		AdjustedAim = GetAdjustedAim( StartTrace );
		AimDir = Vector(AdjustedAim);

		// this is the location where the projectile is spawned.
		RealStartLoc = GetPhysicalFireStartLoc(AimDir);

		if( StartTrace != RealStartLoc )
		{
			// if projectile is spawned at different location of crosshair,
			// then simulate an instant trace where crosshair is aiming at, Get hit info.
			EndTrace = StartTrace + AimDir * GetTraceRange();
			TestImpact = CalcWeaponFire( StartTrace, EndTrace );

			// Then we realign projectile aim direction to match where the crosshair did hit.
			AimDir = Normal(TestImpact.HitLocation - RealStartLoc);
		}

		GetAxes(rotator(AimDir), X,Y,Z);

		// Spawn projectiles
		for( i=0; i<ProjectileCount; ++i )
		{
			// make max spread +-32uu at 768uu
			RandomAim = Normal(X * 768 - (Y * RandRange(-32,+32) + Z * RandRange(-32,+32)));

			SpawnedProjectile = Spawn(GetProjectileClass(), Self,, RealStartLoc);
			if( SpawnedProjectile != None && !SpawnedProjectile.bDeleteMe )
			{
				SpawnedProjectile.Init( RandomAim );
			}
		}
	}
}

defaultproperties
{
    ProjectileCount=1

	BeamSocket[0]=MuzzleFlashSocket
	BeamSocket[1]=MuzzleFlashSocket

	WeaponPreFireAnim[0]="WeaponFireStart"
	WeaponPreFireAnim[1]="WeaponFireStart"
	WeaponFireAnim[0]="WeaponFireIdle"
	WeaponFireAnim[1]="WeaponFireIdle"
	WeaponPostFireAnim[0]="WeaponFireStop"
	WeaponPostFireAnim[1]="WeaponFireStop"

	ArmPreFireAnim[0]="WeaponFireStart"
	ArmPreFireAnim[1]="WeaponFireStart"
	ArmFireAnim[0]="WeaponFireIdle"
	ArmFireAnim[1]="WeaponFireIdle"
	ArmPostFireAnim[0]="WeaponFireStop"
	ArmPostFireAnim[1]="WeaponFireStop"

    ClipSize = 100
	InitalNumClips = 5
    MaxClips = 5
    ReloadTime = 3.3667

	FireInterval(0)=+0.1
	FireInterval(1)=+0.1
	ShotCost(0)=1
	ShotCost(1)=1

	WeaponFireTypes(0)=EWFT_Custom
	WeaponFireTypes(1)=EWFT_Custom

	AimingHelpRadius[0]=20.0
	AimingHelpRadius[1]=12.0

	MaxDesireability=0.3
	AIRating=+0.3
	CurrentRating=0.3
	bFastRepeater=true
	bSplashJump=False
	bRecommendSplashDamage=True
	bSniping=false
	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=0
	AimError=600

	ReloadAnimName(0) = "weaponreload"
	ReloadAnimName(1) = "weaponreload"
	ReloadArmAnimName(0) = "weaponreload"
	ReloadArmAnimName(1) = "weaponreload"

	Begin Object Class=ForceFeedbackWaveform Name=ForceFeedbackWaveformLooping1
		Samples(0)=(LeftAmplitude=20,RightAmplitude=10,LeftFunction=WF_Constant,RightFunction=WF_Constant,Duration=0.100)
		bIsLooping=TRUE
	End Object
	WeaponFireWaveForm=ForceFeedbackWaveformLooping1
}
