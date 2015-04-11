//=============================================================================
// Ordinary rapid-fire, instant-hit weapon.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelWeapon_AGT_MG extends Rx_SentinelWeapon;

var() Rx_SentinelWeaponComponent_MuzzleFlash Tracer;
var() Rx_SentinelWeaponComponent_HitEffects HitEffects;
var() const AudioComponent WindUpSound;
var() const AudioComponent RunningSound;
var() const AudioComponent WindDownSound;

var() int NumBarrels;
/** Array of barrel distances radially from the centre. The array size must be equal to NumBarrels. */
var() array<float> BarrelOffsets;
/** A tracer will be spawned every this many shots. */
var() int TracerInterval;
/** This many seconds must pass after Sentinel goes idle before the minigun spins down. */
var() float WindDownDelay;

/** How much more likely to attack flying targets. */
var() float FlyingTargetPreference;

/** Location of last hit, or 0 if not fired. */
var Vector LastHitLocation; //Might be wrong if packets arrive out of order.
/** 0 = Idle, 1 = WindingUp, 2 = Running, 3 = WindingDown */
var protected repnotify byte FiringState;

var SkelControlSingleBone SkelControl;
var float CurrentBarrelRoll; //Do a barrel roll!

replication
{
    if(Role == ROLE_Authority && bNetDirty)
        LastHitLocation, FiringState;
}

simulated event ReplicatedEvent(name VarName)
{
    if(VarName == 'FiringState')
    {
        //n.b. This may behave strangely if network latency is extremely high.
        switch (FiringState)
        {
            case 0:
                GotoState('Idle');
                break;
            case 1:
                GotoState('WindingUp');
                break;
            case 2:
                GotoState('Running');
                break;
            case 3:
                GotoState('WindingDown');
                break;
            default:
                GotoState('Idle');
        }
    }
    else
    {
        super.ReplicatedEvent(VarName);
    }
}

simulated function InitMuzzleFlash()
{
    super.InitMuzzleFlash();

    Cannon.WeaponComponent.bCastDynamicShadow=false;
    if(Cannon != none && Tracer != none)
    {
        Tracer.Initialize(Cannon.WeaponComponent, MuzzleSocketName);
    }

}

function ModifyPawnTargetPriority(out float Weight, Pawn PawnTarget)
{
    //The minigun, being instant-hit, is particularly useful against flying targets.
    if(PawnTarget.Physics == PHYS_Flying || PawnTarget.bCanFly)
    {
        Weight += FlyingTargetPreference;
    }

    super.ModifyPawnTargetPriority(Weight, PawnTarget);
}


auto state Idle
{
    function BeginState(name PreviousStateName)
    {
        FiringState = 0;
        LastHitLocation = vect(0.0, 0.0, 0.0);
    }

    //Start winding up as soon as a target appears.
    function NotifyNewTarget(Actor NewTarget)
    {
        super.NotifyNewTarget(NewTarget);

        GotoState('WindingUp');
    }

    function bool FireAt(Vector Start, Rotator BarrelDir, Vector End)
    {
        GotoState('WindingUp');

        return false;
    }
}

state WindingUp
{
    simulated function BeginState(name PreviousStateName)
    {
        if(Role == ROLE_Authority)
        {
            FiringState = 1;
        }

        WindUpSound.Play();
        //Can't use the AudioComponent.OnAudioFinished delegate because it doesn't work on dedicated servers, so use a timer instead.
        //SetTimer(WindUpSound.SoundCue.GetCueDuration()/2, false);
        SetTimer(0.25, false);
        //SkelControl = SkelControlSingleBone(Cannon.WeaponComponent.FindSkelControl('GunSpinner'));
    }

    function bool FireAt(Vector Start, Rotator BarrelDir, Vector End)
    {
        return false;
    }

    simulated function Timer()
    {
        if(Cannon != none && Cannon.Health > 0 && Cannon.bTracking)
        {
            GotoState('Running');
        }
        else
        {
            GotoState('WindingDown');
        }
    }
}

state Running
{
    simulated function BeginState(Name PreviousStateName)
    {
        if(Role == ROLE_Authority)
        {
            FiringState = 2;
        }
    }

    //simulated function Tick(float DeltaTime)
    //{
    //    if(SkelControl != none)
    //    {
    //        CurrentBarrelRoll += (-65536.0 / (NumBarrels * FireInfo.FireInterval)) * DeltaTime;
    //        SkelControl.BoneRotation.Roll = CurrentBarrelRoll;
    //    }
    //}

    function NotifyWaiting()
    {
        global.NotifyWaiting();

        SetTimer(WindDownDelay, false, 'WindDown');
    }

    function NotifyNewTarget(Actor NewTarget)
    {
        global.NotifyNewTarget(NewTarget);

        ClearTimer('WindDown');
    }

    function NotifyDied(Controller Killer, out class<DamageType> DamageType, vector HitLocation)
    {
        global.NotifyDied(Killer, DamageType, HitLocation);

        GotoState('WindingDown');
    }

    function bool FireAt(Vector Start, Rotator BarrelDir, Vector End)
    {
        local Vector TraceStart, TraceEnd;
        local Actor HitActor;
        local Vector HitLocation, HitNormal;

        TraceStart = Start;
        TraceEnd = Vector(BarrelDir) + (Normal(VRand()) * FireInfo.Spread);
        TraceEnd = Normal(TraceEnd);
        TraceEnd *= FireInfo.MaxRange;
        TraceEnd += TraceStart;

        HitActor = Cannon.Trace(HitLocation, HitNormal, TraceEnd, TraceStart, true, vect(0,0,0),, TRACEFLAG_Bullet);
    
        if(HitActor == none)
        {
            HitLocation    = TraceEnd;
        }
        else if(Pawn(HitActor) == none || !Cannon.IsSameTeam(Pawn(HitActor)))
        {
            HitActor.TakeDamage(FireInfo.Damage, Cannon.InstigatorController, HitLocation, FireInfo.Momentum * Normal(TraceEnd - TraceStart), FireInfo.DamageType,, Cannon);
        }

//        HitActor = Cannon.Target; // possible performance optimization ? need to get hitlocation on mesh somehow too though 

        LastHitLocation = HitLocation;

        bCanFire = false;
        SetTimer(FireInfo.FireInterval, false, 'FireTimer');
        if(HitActor != Cannon.Target) {
            return false;
        } else {
            return true;
        }
    }

    function WindDown()
    {
        GotoState('WindingDown');
    }

    simulated function EndState(name NextStateName)
    {
    }
}

function bool CanHit(Pawn PotentialTarget) {
    local Actor HitActor;
    local Vector TraceStart, TraceEnd, HitLocation, HitNormal;

    TraceStart = Cannon.GetPawnViewLocation();
    TraceEnd = PotentialTarget.location;

    HitActor = Cannon.Trace(HitLocation, HitNormal, TraceEnd, TraceStart, true, vect(0,0,0),, TRACEFLAG_Bullet);

    if(HitActor != PotentialTarget)
    {
        return false;
    }
    return true;
}

state WindingDown
{
    simulated function BeginState(name PreviousStateName)
    {
        if(Role == ROLE_Authority)
        {
            FiringState = 3;
        }

        WindDownSound.Play();
        SetTimer(WindDownSound.SoundCue.GetCueDuration(), false);
        if(Cannon != None)
        	Cannon.Target = none;
    }

    function bool FireAt(Vector Start, Rotator BarrelDir, Vector End)
    {
        return false;
    }

    simulated function Timer()
    {
        if(Cannon != None && Cannon.bTracking)
        {
            GotoState('WindingUp');
        }
        else
        {
            GotoState('Idle');
        }
    }
}

simulated function FlashMuzzleFlash()
{
    local Vector FireSoundLocation;

    if(Cannon != none)
    {

        if(FireInfo.FireSound != none)
        {
            Cannon.WeaponComponent.GetSocketWorldLocationAndRotation(MuzzleSocketName, FireSoundLocation);
            PlaySound(FireInfo.FireSound, true,,, FireSoundLocation);
        }

        if(MuzzleFlash != none)
        {
            MuzzleFlash.Flash();
        }

        if(MuzzleFlashLight != none)
        {
            MuzzleFlashLight.Flash();
        }

        if(!IsZero(LastHitLocation))
        {
            FireInfo.CheckBulletWhip(Cannon.GetPawnViewLocation(), LastHitLocation);

            if(HitEffects != none)
            {
                HitEffects.PlayImpactEffects(Cannon.GetPawnViewLocation(), LastHitLocation, self);
            }

            if(FlashCount % TracerInterval == 0 && Tracer != none)
            {
                Tracer.SetVectorParameter('BeamEnd', LastHitLocation);
                Tracer.Flash();
            }
        }
    }
}


defaultproperties
{
    FriendlyName="AGT_MG"
//    Description="In acknowledgement of the continuing popularity of kinetic weapons, Evil Corp. has developed a new minigun attachment for the Mk III Sentinel. Incorporating patented \"3-wave\" technology, the new minigun exhibits far higher barrel strength and thermal capacity compared to previous models, allowing for an indefinitely sustainable high rate of fire*.\n\nThe 15mm aluminium rounds fired by this weapon exhibit hypersonic muzzle velocity and maintain that velocity with the use of miniature gravitomagnetic thrusters, giving exceptional damage potential against lightly armoured targets at all ranges. Standard configuration is one tracer every fourth round.\n\n\n*Non-military model limited to 600rpm to meet NEG safety guidelines."

    WindDownDelay=6.0
    FlyingTargetPreference=0.0 // dont prefer aircrafts

    WeaponDeadMaterial=MaterialInstanceConstant'RX_DEF_CeilingTurret.Materials.MI_CeilingTurret_BO'
    WeaponMesh=SkeletalMesh'RX_DEF_CeilingTurret.Mesh.SK_Turret_MG'
    AnimTreeTemplate=AnimTree'RX_DEF_CeilingTurret.Anim.AT_Turret_MG'
//    AnimSets.Add(AnimSet'BU_RenX_CeilingTurrets.Anim.Anim_Turret_MG')
    

//    DefaultImpactEffect=(ParticleTemplate=ParticleSystem'VH_Goliath.EffectS.PS_Goliath_Gun_Impact',Sound=SoundCue'A_Weapon_Enforcer.Cue.A_Weapon_Enforcer_ImpactDirt_Cue',DecalMaterials=(MaterialInterface'VH_Goliath.Decals.MIC_VH_Goliath_Impact_Decal01'),DecalWidth=16.0,DecalHeight=16.0)

    WeaponScale=1.0
    RootBone=Gun_Base

    ActivateSound=None

    ExtraStrength=0.1
    AmmoCost=50
    MuzzleSocketName=MuzzleFlashSocket
    TracerInterval=3    // Leuchtspur

    Begin Object Class=Rx_SentinelWeaponComponent_FireInfo Name=FireInfo0
        FireInterval=0.20
        FireOffset=(X=70.0,Y=0.0,Z=10.0)
        Damage=10.0		// 40
        Momentum=0.0
        DamageType=class'Rx_DmgType_AGT_MG'
        MaxRange=10000.0
        Spread=0.00
        FireSound=SoundCue'RX_BU_AGT.Sounds.SC_AGT_Gun_Fire'
    End Object
    FireInfo=FireInfo0

    Begin Object Class=Rx_SentinelWeaponComponent_MuzzleFlash Name=MuzzleFlash0
        bIgnoreOwnerHidden=true
        Template=ParticleSystem'RX_BU_AGT.Effects.P_MuzzleFlash_Gun'
        MuzzleFlashDuration=1.25
        MuzzleFlashOffset=(X=2.0,Y=0.0,Z=0.0)
        //bConstantFlash=true
    End Object
    MuzzleFlash=MuzzleFlash0

    Begin Object Class=Rx_SentinelWeaponComponent_MuzzleFlashLight Name=MuzzleFlashLightComponent0
        LightOffset=(X=30.0,Y=0.0,Z=0.0)
        TimeShift=((StartTime=0.0,Radius=200,Brightness=5,LightColor=(R=255,G=190,B=64,A=255)),(StartTime=0.8,Radius=64,Brightness=0,LightColor=(R=255,G=190,B=64,A=255)))
    End Object
    MuzzleFlashLight=MuzzleFlashLightComponent0

    Begin Object Class=Rx_SentinelWeaponComponent_HitEffects Name=HitEffectsComp
    End Object
    HitEffects=HitEffectsComp

    Begin Object Class=AudioComponent Name=WindUpSound0
        SoundCue=SoundCue'RX_WP_ChainGun.Sounds.SC_ChainGun_Start'
        bStopWhenOwnerDestroyed=true
    End Object
    WindUpSound=WindUpSound0
    Components.Add(WindUpSound0)

    //Begin Object Class=AudioComponent Name=RunningSound0
    //    SoundCue=SoundCue'Sentinel_Resources.Sounds.Weapons.SMinigunLoopCue'
    //    bStopWhenOwnerDestroyed=true
    //End Object
    //RunningSound=RunningSound0
    //Components.Add(RunningSound0)

    Begin Object Class=Rx_SentinelWeaponComponent_MuzzleFlash Name=TracerComp
        Template=ParticleSystem'RX_FX_Munitions.Beams.P_InstantHit_Tracer_GDI'
    End Object
    Tracer=TracerComp

    Begin Object Class=AudioComponent Name=WindDownSound0
        SoundCue=SoundCue'RX_WP_ChainGun.Sounds.SC_ChainGun_Stop'
        bStopWhenOwnerDestroyed=true
    End Object
    WindDownSound=WindDownSound0
    Components.Add(WindDownSound0)
}
