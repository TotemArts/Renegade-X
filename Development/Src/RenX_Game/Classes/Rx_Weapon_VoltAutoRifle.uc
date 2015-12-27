class Rx_Weapon_VoltAutoRifle extends Rx_Weapon_Charged
    abstract;

`define CancelledChargeSound WeaponPreFireSnd[1]
`define CooldownSound WeaponPostFireSnd[1]
var AudioComponent ChargeUpAudio;

// Weapon charged fire code, mostly based on UT3 BioRifle.

var int MinCharge;  // Smallest charge size that will result in a shot being fired.
var int MaxCharge;  // Largest charge size allowed.
var float AutoDischargeTime;   // Time after beginning charge that the shot will be automatically discharged.
var float CooldownLength; // Cooldown length after firing a charged shot.
var float AdditionalCoolDownTime;
// Use FireInterval(1) to define charge speed.

var int ChargeStrength;

// PreFire = Charging, PostFire = Cooldown - for sounds and animations.

var UDKParticleSystemComponent ChargingPSC;
var UDKParticleSystemComponent CoolingPSC;

simulated function PostBeginPlay()
{
    local UDKSkeletalMeshComponent SKMesh;
    super.PostBeginPlay();
    SKMesh = UDKSkeletalMeshComponent(Mesh);
    ChargingPSC.SetFOV(SKMesh.FOV);
    CoolingPSC.SetFOV(SKMesh.FOV);
    SKMesh.AttachComponentToSocket(ChargingPSC,MuzzleFlashSocket);
    SKMesh.AttachComponentToSocket(CoolingPSC,MuzzleFlashSocket);
}

// Volt Auto Rifle uses a different state for alt-fire, so can't use the super implementation which sends directly to fire.
simulated function RestartWeaponFiringAfterReload()
{
    GotoState('Active');
}

/**
 * Take the projectile spawned and if it's the proper type, adjust it's strength and speed
 */
simulated function Projectile ProjectileFire()
{
    local Projectile SpawnedProjectile;
    //local float percent;

    SpawnedProjectile = super.ProjectileFire();
    if ( Rx_Projectile_VoltBolt(SpawnedProjectile) != None )
    {
        //percent = ChargeStrength-MinCharge;
        //percent /= MaxCharge-MinCharge;
        Rx_Projectile_VoltBolt(SpawnedProjectile).InitCharge(self, float(ChargeStrength-MinCharge) / float(MaxCharge-MinCharge)); // projectile class deals in overcharge percentage 0-1.

        // A Clientside ammo consumption is done in ProjectileFire, which is not correct behaviour for this charging system, so revert the consumption;
        if(WorldInfo.Netmode == NM_Client)
            CurrentAmmoInClipClientside += default.ShotCost[CurrentFireMode];
    }
    return SpawnedProjectile;
}

/**
 * Tells the weapon to play a firing sound (uses CurrentFireMode)
 */
/* If we want varied fire sounds.
simulated function PlayFiringSound()
{
    if (CurrentFireMode<WeaponFireSnd.Length)
    {
        // play weapon fire sound
        if ( WeaponFireSnd[CurrentFireMode] != None )
        {
            MakeNoise(1.0);
            if(CurrentFireMode == 1 && ChargeStrength > 0.75*MaxCharge)
            {
                WeaponPlaySound( WeaponFireSnd[2] );
            }
            else
            {
                WeaponPlaySound( WeaponFireSnd[CurrentFireMode] );
            }
        }
    }
}*/

simulated state WeaponOverCharge
{
    simulated function WeaponEmpty();

    simulated function bool TryPutdown()
    {
        bWeaponPutDown = true;
        return true;
    }

    /**
     * Adds a rocket to the count and uses up some ammo.  In Addition, it plays
     * a sound so that other pawns in the world can here it.
     */
    simulated function IncreaseCharge()
    {
        if (ChargeStrength < MaxCharge && HasAmmo(CurrentFireMode))
        {
            ChargeStrength+=ShotCost[CurrentFireMode];
            ConsumeAmmo(CurrentFireMode);
            if (WorldInfo.Netmode == NM_Client)
                CurrentAmmoInClipClientside-=ShotCost[CurrentFireMode];
        }
    }

    /**
     * Fire off a shot w/ effects
     */
    simulated function WeaponFireCharge()
    {
        ProjectileFire();
        PlayFiringSound();
        //InvManager.OwnerEvent('FiredWeapon');
    }

    /**
     * This is the timer event for each shot
     */
    simulated event RefireCheckTimer()
    {
        IncreaseCharge();
    }

    simulated function SendToFiringState( byte FireModeNum )
    {
        return;
    }


    /**
     * We need to override EndFire so that we can correctly fire off the
     * current load if we have any.
     */
    simulated function EndFire(byte FireModeNum)
    {
        Global.EndFire(FireModeNum);

        if (FireModeNum == CurrentFireMode)
        {
            ClearTimer('AutoDischarge');

            // Attempt fire the charge
            ChargingPSC.DeactivateSystem();

            if (ChargeStrength >= MinCharge)
            {
                WeaponFireCharge();

                // Cool Down
                AdditionalCoolDownTime = GetTimerRate('RefireCheckTimer') - GetTimerCount('RefireCheckTimer');
                GotoState('WeaponCoolDown');
            }
            else
            {
                WeaponPlaySound(`CancelledChargeSound);
                // Give the ammo back.
                AddAmmo(ChargeStrength);
                CurrentAmmoInClip += ChargeStrength;
                if (WorldInfo.Netmode == NM_Client)
                    CurrentAmmoInClipClientside += ChargeStrength;

                //Instigator.WeaponStoppedFiring(self, true);
                if (UTPawn(Instigator) != None && UTPawn(Instigator).CurrentWeaponAttachment != none)
                    UTPawn(Instigator).CurrentWeaponAttachment.StopThirdPersonFireEffects();

                GotoState('Active');
            }
        }
    }

    /**
     * Initialize the loadup
     */
    simulated function BeginState(Name PreviousStateName)
    {
        local UTPawn POwner;
        //local UTAttachment_BioRifle ABio;

        ChargeStrength = 0;

        super.BeginState(PreviousStateName);

        ChargeUpAudio.Play();

        POwner = UTPawn(Instigator);
        if (POwner != None)
        {
            //POwner.SetWeaponAmbientSound(WeaponLoadSnd);
            if(Rx_Attachment_VoltAutoRifle(POwner.CurrentWeaponAttachment) != none)
            {
                Rx_Attachment_VoltAutoRifle(POwner.CurrentWeaponAttachment).StartCharging();
            }
        }
        ChargingPSC.ActivateSystem();
        LoopFireAnims();
    }

    /**
     * Insure that the GlobStrength is 1 when we leave this state
     */
    simulated function EndState(Name NextStateName)
    {
        //local UTPawn POwner;

        Cleartimer('RefireCheckTimer');

        //ChargeStrength = 1; // why?

        /*POwner = UTPawn(Instigator);
        if (POwner != None)
        {
            POwner.SetWeaponAmbientSound(None);
            POwner.SetFiringMode(0); // return to base fire mode for network anims
        }*/
        ChargingPSC.DeactivateSystem();
        ChargeUpAudio.Stop();

        PlayWeaponAnimation(WeaponPostFireAnim[0], 1 * IronSightPostAnimDurationModifier, false);
        PlayArmAnimation(ArmPostFireAnim[0], 1 * IronSightPostAnimDurationModifier,false);

        Super.EndState(NextStateName);
    }

    simulated function bool IsFiring()
    {
        return true;
    }

    /**
     * This determines whether or not the Weapon can have ViewAcceleration when Firing.
     *
     * When you are FULLY charged up and running around the level looking for someone to Glob,
     * you need to be able to view accelerate
     **/
    simulated function bool CanViewAccelerationWhenFiring()
    {
        return( ChargeStrength == MaxCharge );
    };

    simulated function AutoDischarge()
    {
        EndFire(CurrentFireMode);
    }


Begin:
    SetTimer(AutoDischargeTime, false, 'AutoDischarge');
    IncreaseCharge();
    TimeWeaponFiring(CurrentFireMode);

}

/*simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
    if(FireModeNum == 0)
    {
        CurrentFireAnim = (CurrentFireAnim+1)%(PrimaryFireAnims.Length);
        WeaponFireAnim[0] = PrimaryFireAnims[CurrentFireAnim];
        ArmFireAnim[0] = PrimaryArmAnims[CurrentFireAnim];
    }
    super.PlayFireEffects(FireModeNum,HitLocation);
}*/

simulated state WeaponCoolDown
{
    simulated function BeginState(name PreviousStateName)
    {
        super.BeginState(PreviousStateName);

        WeaponPlaySound(`CooldownSound);

        /*POwner = UTPawn(Instigator);
        if (POwner != None)
        {
            POwner.SetWeaponAmbientSound(WeaponLoadSnd);
            ABio = UTAttachment_BioRifle(POwner.CurrentWeaponAttachment);
            if(ABio != none)
            {
                ABio.StartCharging();
            }
        }*/
        CoolingPSC.ActivateSystem();
    }

    simulated function WeaponCooled()
    {
        GotoState('Active');
    }

    simulated function EndState(name NextStateName)
    {
        ClearFlashCount();
        ClearFlashLocation();

        ClearTimer('WeaponCooled');

        CoolingPSC.DeactivateSystem();

        super.EndState(NextStateName);
    }

begin:
    SetTimer(CooldownLength + AdditionalCoolDownTime,false,'WeaponCooled');
}


reliable server function ServerALHitCharged(Actor Target, vector HitLocation, TraceHitInfo HitInfo, bool mctDamage, float ChargePercentage)
{
    local class<DamageType>     DamageType;
    local Rx_Pawn               Shooter;
    local vector                Momentum, FireDir;
    local float                 Damage;
    local float                 HitDistDiff;

    ChargePercentage = FClamp(ChargePercentage,0,1);
    Shooter = Rx_Pawn(Owner);
    
    if(WorldInfo.Netmode == NM_DedicatedServer && AIController(Instigator.Controller) == None) {
        if(Rx_Controller(Instigator.Controller) == None) {
            return;
        } 
    }       
    //loginternal(target);
    if (Shooter == none || Target == none)
    {
        return;  
    }
    HitDistDiff = VSize(Target.Location - HitLocation);
    if (Target != none)
    {
        if(Rx_Building(Target) != None) {
            if(HitDistDiff > 3000) {
                return;
            }
        } else if(HitDistDiff > 250) {
            return;
        }
    }
    if (Shooter.Health <= 0 && !IsInsideGracePeriod(VSize(Target.Location - Shooter.Location)) )
    {
        return;
    }

    FireDir = Normal(Target.Location - Instigator.Location);

    Momentum = class'Rx_Projectile_VoltBolt'.default.MomentumTransfer * FireDir;
    DamageType = class'Rx_Projectile_VoltBolt'.default.MyDamageType;
    Damage = class'Rx_Projectile_VoltBolt'.default.Damage + class'Rx_Projectile_VoltBolt'.default.BonusDamage*ChargePercentage;
    if(mctDamage) {
        Damage = Damage * class<Rx_DmgType>(DamageType).static.MCTDamageScalingFor();
    }   
        
    //SetFlashLocation(HitLocation);
    //SetReplicatedImpact(HitLocation, FireDir, Shooter.Location, class, 0.0, true );

    Target.TakeDamage(Damage, Instigator.Controller, HitLocation, Momentum, DamageType, HitInfo, self);     
}

reliable server function ServerALRadiusDamageCharged(Actor Target, vector HurtOrigin, bool bFullDamage, float ChargePercentage)
{
    local class<DamageType>     DamageType;
    local Rx_Pawn               Shooter;
    local float                 Momentum;
    local float                 Damage,DamageRadius;

    ChargePercentage = FClamp(ChargePercentage,0,1);
    Shooter = Rx_Pawn(Owner);
    
    if(WorldInfo.Netmode == NM_DedicatedServer && AIController(Instigator.Controller) == None) {
        if(Rx_Controller(Instigator.Controller) == None) {
            return;
        } 
    }       

    if (Shooter == none || Target == none)
    {
        return;  
    }
    if (Target != none && VSize(Target.Location - HurtOrigin) > 400 )
    {
        return;
    }
    if (Shooter.Health <= 0 && !IsInsideGracePeriod(VSize(Target.Location - Shooter.Location)) )
    {
        return;
    }

    Momentum = class'Rx_Projectile_VoltBolt'.default.MomentumTransfer;
    DamageType = class'Rx_Projectile_VoltBolt'.default.MyDamageType;
    Damage = class'Rx_Projectile_VoltBolt'.default.Damage + class'Rx_Projectile_VoltBolt'.default.BonusDamage*ChargePercentage;
    DamageRadius = class'Rx_Projectile_VoltBolt'.default.DamageRadius + class'Rx_Projectile_VoltBolt'.default.BonusDamageRadius*ChargePercentage;
    
    Target.TakeRadiusDamage(Instigator.Controller,Damage,DamageRadius,DamageType,Momentum,HurtOrigin,bFullDamage,self);
}

DefaultProperties
{
    Begin Object class=AnimNodeSequence Name=MeshSequenceA
        bCauseActorAnimEnd=true
    End Object

    // Weapon SkeletalMesh
    Begin Object Name=FirstPersonMesh
        SkeletalMesh=SkeletalMesh'RX_WP_VoltAutoRifle.Mesh.SK_VoltAutoRifle_1P'
        AnimSets(0)=AnimSet'RX_WP_VoltAutoRifle.Anims.AS_VoltAutoRifle_1P'
        Animations=MeshSequenceA
		Scale=2.0
        FOV=55
    End Object

    // Weapon SkeletalMesh
    Begin Object Name=PickupMesh
        SkeletalMesh=SkeletalMesh'RX_WP_VoltAutoRifle.Mesh.SK_WP_Volt_Back'
        Scale=0.7 
    End Object

    AttachmentClass=class'Rx_Attachment_VoltAutoRifle'
	
	LeftHandIK_Offset=(X=0,Y=6,Z=0)
	RightHandIK_Offset=(X=6,Y=-3,Z=-3)
	
	FireOffset=(X=0,Y=15,Z=-15)

    ArmsAnimSet=AnimSet'RX_WP_VoltAutoRifle.Anims.AS_VoltAutoRifle_Arms'
	
	//-------------- Recoil
	RecoilDelay = 0.02
	MinRecoil = 45.0
	MaxRecoil = 60.0
	MaxTotalRecoil = 2000.0
	RecoilYawModifier = 0.5 // will be a random value between 0 and this value for every shot
	RecoilYawMultiplier = 2.0
	RecoilInterpSpeed = 30.0
	RecoilDeclinePct = 0.5
	RecoilDeclineSpeed = 6.0
	MaxSpread = 0.2
	RecoilSpreadIncreasePerShot = 0.00025
	RecoilSpreadDeclineSpeed = 0.3
	RecoilSpreadDecreaseDelay = 0.2
	RecoilSpreadCrosshairScaling = 1000

    bInstantHit=true
    bSplashJump=false
    bRecommendSplashDamage=false
    bSniping=false
    GroupWeight=1
    AimError=600

    PlayerViewOffset=(X=6.0,Y=2.0,Z=-3.0)		// (X=-2.0,Y=2.0,Z=-2.0)

    InventoryGroup=2

    ShotCost(0)=1
    ShotCost(1)=1
	
    FireInterval(0)=0.06 //+0.065
    FireInterval(1)=0.06 //+0.065
    ReloadTime(0) = 3.5
    ReloadTime(1) = 3.5
    
    EquipTime=1.0
//	PutDownTime=0.7

    Spread(0)=0.001//0.01
    Spread(1)=0.001//0.01
    
    WeaponRange=3000.0

    InstantHitDamage(0)=10
	
	HeadShotDamageMult=2.0
	
    InstantHitMomentum(0)=10000.0

    WeaponFireTypes(0)=EWFT_InstantHit
    WeaponFireTypes(1)=EWFT_Projectile

    FiringStatesArray(1)=WeaponOverCharge

    WeaponProjectiles(1)=class'Rx_Projectile_VoltBolt'

    InstantHitDamageTypes(0)=class'Rx_DmgType_VoltAutoRifle'

    ClipSize = 100
    InitalNumClips = 7
    MaxClips = 7
    
    FireDelayTime = 0.01
    bCharge = true

    ReloadAnimName(0) = "weaponreload"
    ReloadAnimName(1) = "weaponreload"
    ReloadAnim3PName(0) = "H_M_AutoRifle_Reload_1"
    ReloadAnim3PName(1) = "H_M_AutoRifle_Reload_1"
    ReloadArmAnimName(0) = "weaponreload"
    ReloadArmAnimName(1) = "weaponreload"
    
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

    // WeaponFireSnd[0]=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltAutoRifle_Fire'
    // WeaponFireSnd[1]=None
    
    WeaponPreFireSnd[0]=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltAutoRifle_FireStart'
    //WeaponPreFireSnd[1]=none // SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Charge'
    WeaponFireSnd[0]=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltAutoRifle_FireLoop'
    WeaponFireSnd[1]=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Fire'
    WeaponPostFireSnd[0]=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltAutoRifle_FireStop'
    //WeaponPostFireSnd[1]=none // SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltAutoRifle_FireStop'

    Begin Object Class=AudioComponent Name=ChargeSndComp
        SoundCue=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Charge'
    End Object
    ChargeUpAudio=ChargeSndComp
    Components.Add(ChargeSndComp);

    `CooldownSound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_CoolDown'
    `CancelledChargeSound=SoundCue'RX_WP_ChainGun.Sounds.SC_ChainGun_Stop'

    WeaponPutDownSnd=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltAutoRifle_PutDown'
    WeaponEquipSnd=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltAutoRifle_Equip'
    ReloadSound(0)=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltAutoRifle_Reload'
    ReloadSound(1)=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltAutoRifle_Reload'

    PickupSound=SoundCue'RX_WP_SniperRifle.Sounds.SC_Sniper_Reload'

    MuzzleFlashSocket=MuzzleFlashSocket
    FireSocket=MuzzleFlashSocket
    MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltRifle_MuzzleFlash_1P'
    MuzzleFlashDuration=0.1
    MuzzleFlashLightClass=class'Rx_Light_RepairBeam'

    Begin Object Class=UDKParticleSystemComponent Name=ChargePart
        Template=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_ChargeUp_1P_Blue'
        DepthPriorityGroup=SDPG_Foreground
        bAutoActivate=false
    End Object
    ChargingPSC=ChargePart
    Components.Add(ChargePart)

    Begin Object Class=UDKParticleSystemComponent Name=CoolPart
        Template=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_CoolDown_1P_Blue'
        DepthPriorityGroup=SDPG_Foreground
        bAutoActivate=false
    End Object
    CoolingPSC=CoolPart
    Components.Add(CoolPart)
    
    CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_AutoRifle'

    CrossHairCoordinates=(U=256,V=64,UL=64,VL=64)
    IconCoordinates=(U=726,V=532,UL=165,VL=51)

    InventoryMovieGroup=13

	WeaponIconTexture=Texture2D'RX_WP_VoltAutoRifle.UI.T_WeaponIcon_VoltAutoRifle'

	bOkAgainstBuildings=true	
	bOkAgainstVehicles=true	    
	
	//==========================================
	// IRON SIGHT PROPERTIES
	//==========================================
	
	// IronSight:
	bIronSightCapable = false
	bDisplayCrosshairInIronsight = false
	IronSightViewOffset=(X=-15,Y=-5.7,Z=-0.64)		// (X=-30,Y=-11.3,Z=1.5)
	IronSightFireOffset=(X=0,Y=0,Z=0)
	IronSightBobDamping=6
	IronSightPostAnimDurationModifier=0.1
	// This sets how much we want to zoom in, this is a value to be subtracted because smaller FOV values are greater levels of zoom
	ZoomedFOVSub=25.0 
	// New lower speed movement values for use while zoom aiming
	ZoomGroundSpeed=180.0
	ZoomAirSpeed=340.0
	ZoomWaterSpeed=11
	
	// IronSight additional vars to the vars in AimingWeaponClass (1 means unchanged, higher values mean more dmaping):
	IronSightMinRecoilDamping = 2
	IronSightMaxRecoilDamping = 2
	IronSightMaxTotalRecoilDamping = 2
	IronSightRecoilYawDamping = 1
	IronSightMaxSpreadDamping = 2
	IronSightSpreadIncreasePerShotDamping = 4

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_VoltAutoRifle'
    
    MaxCharge=30
    AutoDischargeTime=5
    MinCharge=10
    CooldownLength=2
}
