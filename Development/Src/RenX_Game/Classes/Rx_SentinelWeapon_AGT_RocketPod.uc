//=============================================================================
// Ordinary rapid-fire, instant-hit weapon.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelWeapon_AGT_RocketPod extends Rx_SentinelWeapon;

var() Rx_SentinelWeaponComponent_HitEffects HitEffects;
var() Rx_SentinelWeaponComponent_MuzzleFlash MuzzleFlash1;
var() Rx_SentinelWeaponComponent_MuzzleFlash MuzzleFlash2;
var() Rx_SentinelWeaponComponent_MuzzleFlashLight MuzzleFlashLight1;
var() Rx_SentinelWeaponComponent_MuzzleFlashLight MuzzleFlashLight2;
var() name MuzzleSocketName2;

/** How much more likely to attack flying targets. */
var() float FlyingTargetPreference;

/** Location of last hit, or 0 if not fired. */
var Vector LastHitLocation; //Might be wrong if packets arrive out of order.
/** 0 = Idle, 1 = WindingUp, 2 = Running, 3 = WindingDown */
var protected repnotify byte FiringState;
var int currentMuzzleflashNumber;

replication
{
    if(Role == ROLE_Authority && bNetDirty)
        currentMuzzleflashNumber, FiringState;
}


simulated function InitMuzzleFlash()
{
    if(Cannon != none)
    {
        MuzzleFlash1.Initialize(Cannon.WeaponComponent, MuzzleSocketName);
        MuzzleFlash2.Initialize(Cannon.WeaponComponent, MuzzleSocketName2);
        MuzzleFlashLight1.Initialize(Cannon.WeaponComponent, MuzzleSocketName);
        MuzzleFlashLight2.Initialize(Cannon.WeaponComponent, MuzzleSocketName2);
    }
    Cannon.WeaponComponent.bCastDynamicShadow=false;
}

function ModifyPawnTargetPriority(out float Weight, Pawn PawnTarget)
{

    //if(PawnTarget.Physics == PHYS_Flying || PawnTarget.bCanFly)
    //{
    //    Weight -= FlyingTargetPreference;
    //}

    if(UTVehicle(PawnTarget) != none) {
        Weight += 1.5;
    }

    super.ModifyPawnTargetPriority(Weight, PawnTarget);
}

auto state Running
{
    simulated function BeginState(Name PreviousStateName)
    {
        if(Role == ROLE_Authority)
        {
            FiringState = 2;
        }

    }

    function NotifyWaiting()
    {
        global.NotifyWaiting();
    }

    function NotifyNewTarget(Actor NewTarget)
    {
        global.NotifyNewTarget(NewTarget);
    }

    function NotifyDied(Controller Killer, out class<DamageType> DamageType, vector HitLocation)
    {
        global.NotifyDied(Killer, DamageType, HitLocation);
    }

    function bool FireAt(Vector Start, Rotator BarrelDir, Vector End)
    {        

        local Actor HitActor;
        local Vector HitLocation, HitNormal;
        
        Start.Z -= 150;

        Start = Start + vector(rotator(End-Start)) * 300.0;

        HitActor = Cannon.Trace(HitLocation, HitNormal, End, Start, true, vect(0,0,0),, TRACEFLAG_Bullet);

        if(HitActor != Cannon.Target)
        {
            return false;
        }

        ProjectileFire();
        bCanFire = false;
        SetTimer(FireInfo.FireInterval, false, 'FireTimer');
        return true;
    }

    simulated function EndState(name NextStateName)
    {
    }
}

function bool CanHit(Pawn PotentialTarget) {
    local Actor HitActor;
    local Vector Start, End, HitLocation, HitNormal;

    Start = Cannon.GetPawnViewLocation();
    Start.Z -= 150;
	End = PotentialTarget.location;

    Start = Start + vector(rotator(End-Start)) * 300.0;

    HitActor = Cannon.Trace(HitLocation, HitNormal, End, Start, true, vect(0,0,0),, TRACEFLAG_Bullet);

    if(HitActor != PotentialTarget)
    {
        return false;
    }
    return true;
}


simulated function FlashMuzzleFlash()
{
    local Vector FireSoundLocation;

    if(Cannon != none)
    {
        if(currentMuzzleflashNumber == 0)
        {
            //MuzzleFlash1.Flash();
            MuzzleFlashLight1.Flash();
            Cannon.WeaponComponent.GetSocketWorldLocationAndRotation(MuzzleSocketName, FireSoundLocation);
            //currentMuzzleflashNumber = 2;
        
        } else {
            //MuzzleFlash2.Flash();
            MuzzleFlashLight2.Flash();
            Cannon.WeaponComponent.GetSocketWorldLocationAndRotation(MuzzleSocketName2, FireSoundLocation);
            //currentMuzzleflashNumber = 1;
        }
        PlaySound(FireInfo.FireSound, true,,, FireSoundLocation);
    }
}



/**
 * Fires a projectile.
 * Spawns the projectile, but also increment the flash count for remote client effects.
 * Network: Local Player and Server
 */
function ProjectileFire()
{
    local vector                RealStartLoc;
    local Rx_Projectile_Rocket_AGT            SpawnedProjectile;
    local Rotator               Aim;
    local Vector                FireSoundLocation;

    if( Role == ROLE_Authority )
    {
        // this is the location where the projectile is spawned.
        if(currentMuzzleflashNumber == 0) {
            RealStartLoc = MuzzleFlash1.GetPosition();
            currentMuzzleflashNumber = 1;
            Cannon.WeaponComponent.GetSocketWorldLocationAndRotation(MuzzleSocketName, FireSoundLocation);
        } else {
            RealStartLoc = MuzzleFlash2.GetPosition();
            currentMuzzleflashNumber = 0;
            Cannon.WeaponComponent.GetSocketWorldLocationAndRotation(MuzzleSocketName2, FireSoundLocation);
        }
        //FlashMuzzleFlash();

        // Spawn projectile
        Aim = Cannon.CurrentAim;
        Aim.Pitch = 0;
        //SpawnedProjectile = Spawn(class'UTProj_SeekingRocket',,, RealStartLoc, Aim,,true);
        SpawnedProjectile = Spawn(class'Rx_Projectile_Rocket_AGT',,, RealStartLoc, Aim,,true);
        SpawnedProjectile.InitialDir = vector(Aim);
        if ( SpawnedProjectile != None )
        {
            SpawnedProjectile.Init(vector(Aim));
            SpawnedProjectile.SeekTarget = Cannon.Target;
        }
        //SpawnedProjectile.InitialDir=Aim;
        
    }
}


defaultproperties
{
    FriendlyName="AGT_Missiles"
//    Description="In acknowledgement of the continuing popularity of kinetic weapons, Evil Corp. has developed a new minigun attachment for the Mk III Sentinel. Incorporating patented \"3-wave\" technology, the new minigun exhibits far higher barrel strength and thermal capacity compared to previous models, allowing for an indefinitely sustainable high rate of fire*.\n\nThe 15mm aluminium rounds fired by this weapon exhibit hypersonic muzzle velocity and maintain that velocity with the use of miniature gravitomagnetic thrusters, giving exceptional damage potential against lightly armoured targets at all ranges. Standard configuration is one tracer every fourth round.\n\n\n*Non-military model limited to 600rpm to meet NEG safety guidelines."

    FlyingTargetPreference=0.0 // dont prefer aircrafts
    WeaponMesh=SkeletalMesh'RX_BU_AGT.Mesh.SK_BU_AGT_MissilePod'
    AnimTreeTemplate=AnimTree'RX_BU_AGT.Anims.AT_MissilePod'

    WeaponScale=1.0
    RootBone=Base

    ActivateSound=None

    ExtraStrength=0.1
    AmmoCost=50
    MuzzleSocketName=MuzzleFlashSocket_01
    MuzzleSocketName2=MuzzleFlashSocket_02

    Begin Object Class=Rx_SentinelWeaponComponent_FireInfo Name=FireInfo0
        FireInterval=2.7
        FireOffset=(X=0.0,Y=0.0,Z=0.0) //(X=70.0,Y=0.0,Z=10.0)
        Damage=220.0
        Momentum=0.0
        DamageType=class'Rx_DmgType_AGT_Rocket'
        MaxRange=8000.0
        Spread=0.00
        FireSound=SoundCue'RX_BU_AGT.Sounds.SC_AGT_Missile_Fire'
    End Object
    FireInfo=FireInfo0

    Begin Object Class=Rx_SentinelWeaponComponent_MuzzleFlash Name=MuzzleFlash0
        bIgnoreOwnerHidden=true
        Template=ParticleSystem'RX_BU_AGT.Effects.P_MuzzleFlash_Gun'
        MuzzleFlashDuration=1.25
        MuzzleFlashOffset=(X=4.0,Y=0.0,Z=0.0)
    End Object
    MuzzleFlash1=MuzzleFlash0

    Begin Object Class=Rx_SentinelWeaponComponent_MuzzleFlash Name=MuzzleFlash02
        bIgnoreOwnerHidden=true
        Template=ParticleSystem'RX_BU_AGT.Effects.P_MuzzleFlash_Gun'
        MuzzleFlashDuration=1.25
        MuzzleFlashOffset=(X=4.0,Y=0.0,Z=0.0)
    End Object
    MuzzleFlash2=MuzzleFlash02

    Begin Object Class=Rx_SentinelWeaponComponent_MuzzleFlashLight Name=MuzzleFlashLightComponent0
        LightOffset=(X=30.0,Y=0.0,Z=0.0)
        TimeShift=((StartTime=0.0,Radius=200,Brightness=5,LightColor=(R=255,G=190,B=64,A=255)),(StartTime=0.8,Radius=64,Brightness=0,LightColor=(R=255,G=190,B=64,A=255)))
    End Object
    MuzzleFlashLight1=MuzzleFlashLightComponent0

    Begin Object Class=Rx_SentinelWeaponComponent_MuzzleFlashLight Name=MuzzleFlashLightComponent02
        LightOffset=(X=30.0,Y=0.0,Z=0.0)
        TimeShift=((StartTime=0.0,Radius=200,Brightness=5,LightColor=(R=255,G=190,B=64,A=255)),(StartTime=0.8,Radius=64,Brightness=0,LightColor=(R=255,G=190,B=64,A=255)))
    End Object
    MuzzleFlashLight2=MuzzleFlashLightComponent02

    Begin Object Class=Rx_SentinelWeaponComponent_HitEffects Name=HitEffectsComp
    End Object
    HitEffects=HitEffectsComp


    //Begin Object Class=AudioComponent Name=RunningSound0
    //    SoundCue=SoundCue'Sentinel_Resources.Sounds.Weapons.SMinigunLoopCue'
    //    bStopWhenOwnerDestroyed=true
    //End Object
    //RunningSound=RunningSound0
    //Components.Add(RunningSound0)

}
