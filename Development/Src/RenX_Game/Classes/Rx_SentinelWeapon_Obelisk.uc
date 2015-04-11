//=============================================================================
// Fires high-momentum projectiles.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_SentinelWeapon_Obelisk extends Rx_SentinelWeapon;

var() const AudioComponent WindUpSound;
var() const AudioComponent RunningSound;
var() const AudioComponent WindDownSound;
var ParticleSystem BeamTemplate;
var class<UDKExplosionLight> ImpactLightClass;
var() Rx_SentinelWeaponComponent_MuzzleFlash ChargeUpMuzzleFlash;
var() Rx_SentinelWeaponComponent_HitEffects HitEffects;
var MaterialImpactEffect DefaultImpactEffect;

/** 0 = Idle, 1 = WindingUp, 2 = Running, 3 = WindingDown */
var repnotify byte FiringState;

/** How much more likely to attack flying targets. */
var() float FlyingTargetPreference;

/** Location of last hit, or 0 if not fired. */
var Vector LastHitLocation; //Might be wrong if packets arrive out of order.

/** This many seconds must pass after Sentinel goes idle before the Obelisk spins down. */
var() float WindDownDelay;

var ParticleSystemComponent E;
var ParticleSystemComponent impactEmitter;
var repnotify Actor targetedActor;
var bool bWaiting;
var Rx_Sentinel_LocationMarker beamEndPointLocationMarker;
var MaterialInstanceConstant CrystalGlowMIC;

replication
{
    if(Role == ROLE_Authority && bNetDirty)
        FiringState, targetedActor;
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
    else if ( VarName == 'targetedActor' )
    {
        if ( targetedActor != None )
        {
        }
    }
    else
    {
        super.ReplicatedEvent(VarName);
    }
}


simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    beamEndPointLocationMarker = Spawn(class'Rx_Sentinel_LocationMarker',,,,,,true);
	if(WorldInfo.NetMode == NM_Client) {
		SetTimer(2.0,false,'ClientInitializeFor');
	}    
}

/**
 * Called when Cannon is replicated, to allow client-side alterations to be made.
 */
simulated function ClientInitializeFor()
{
	local Rx_Building_Obelisk_Internals Ob;
	if(CrystalGlowMIC == None) {
		super.ClientInitializeFor();
		ForEach AllActors(class'Rx_Building_Obelisk_Internals',Ob)
		{
			CrystalGlowMIC = Ob.BuildingSkeleton.CreateAndSetMaterialInstanceConstant(0);
			InitAndAttachMuzzleFlashes(Ob.BuildingSkeleton, 'Ob_Fire');
			break;
		}	
	}
}


simulated function FlashMuzzleFlash()
{
    local Vector start;
    Start = Rx_Sentinel_Obelisk_Laser_Base(Cannon).FireStartLoc;
    start.z -= 90;

    super.FlashMuzzleFlash();

    WindUpSound.Stop();
    WindUpSound.Play();
    ChargeUpMuzzleFlash.Flash();

    SpawnBeam(start, LastHitLocation, false);

    CrystalGlowMIC.SetScalarParameterValue('Obelisk_Glow', 0.1);
    SetTimer(0.25, true, 'crystalChargingGlow');

}


simulated function SpawnBeam(vector Start, vector End, bool bFirstPerson)
{
    local vector HitNormal;

    E = WorldInfo.MyEmitterPool.SpawnEmitter(BeamTemplate, Start);
    E.SetVectorParameter('LaserRifle_Endpoint', End);
    beamEndPointLocationMarker.SetLocation(End);
    impactEmitter = WorldInfo.MyEmitterPool.SpawnEmitter(DefaultImpactEffect.ParticleTemplate, End, rotator(HitNormal), beamEndPointLocationMarker);
    if (bFirstPerson)
    {
        E.SetDepthPriorityGroup(SDPG_Foreground);
    }
    else
    {
        E.SetDepthPriorityGroup(SDPG_World);
    }
}

auto state Idle
{
    simulated function BeginState(name PreviousStateName)
    {        
        if(Role == ROLE_Authority)
        {
            FiringState = 0;
        }        
        FiringState = 0;
        LastHitLocation = vect(0.0, 0.0, 0.0);
        ClearTimer('crystalChargingGlow');
        if(CrystalGlowMIC != None) {
        	CrystalGlowMIC.SetScalarParameterValue('Obelisk_Glow', 0.0);
        }
    }

    //Start winding up as soon as a target appears.
    function NotifyNewTarget(Actor NewTarget)
    {
        super.NotifyNewTarget(NewTarget);
    	GotoState('WindingUp');
    }

    function bool FireAt(Vector Start, Rotator BarrelDir, Vector End)
    {
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
        WindUpSound.Stop();
        WindUpSound.Play();
        SetTimer(0.25, true, 'crystalChargingGlow');
        ChargeUpMuzzleFlash.Flash();
        SetTimer(2.2, false);
    }

    function bool FireAt(Vector Start, Rotator BarrelDir, Vector End)
    {
        return false;
    }
    
    function NotifyNewTarget(Actor NewTarget)
    {
        super.NotifyNewTarget(NewTarget);
        if(IsTimerActive('GotoIdle')) {
    		ClearTimer('GotoIdle');
    		GotoState('Running');
    	}
    }    

    simulated function Timer()
    {
        if(Cannon != none && Cannon.Health > 0 && Cannon.bTracking)
        {
            GotoState('Running');
        }
        else
        {
            SetTimer(4.0, false, 'GotoIdle');
        }
    }
    
    simulated function GotoIdle() 
    {
    	GotoState('Idle');
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

    function NotifyWaiting()
    {
        global.NotifyWaiting();
        bWaiting = true;
        SetTimer(WindDownDelay, false, 'Idle_');
    }

    function NotifyNewTarget(Actor NewTarget)
    {
        ClearTimer('Idle_');
        global.NotifyNewTarget(NewTarget);
    }

    function NotifyDied(Controller Killer, out class<DamageType> DamageType, vector HitLocation)
    {
        ClearTimer('crystalChargingGlow');
        CrystalGlowMIC.SetScalarParameterValue('Obelisk_Glow', 0.0);        
        global.NotifyDied(Killer, DamageType, HitLocation);
        GotoState('Idle_');
    }

    function bool FireAt(Vector Start, Rotator BarrelDir, Vector End)
    {

        local Actor HitActor;
        local Vector HitLocation, HitNormal;

		Start = Rx_Sentinel_Obelisk_Laser_Base(Cannon).FireStartLoc;
        Start.Z -= 90;

        ClearTimer('Idle_');
        bWaiting=false;

        Start = Start + vector(rotator(End-Start)) * 300.0;

        HitActor = Cannon.Trace(HitLocation, HitNormal, End, Start, true, vect(0,0,0),, TRACEFLAG_Bullet);
        targetedActor = HitActor;

        if(HitActor != Cannon.Target)
        {
            return false;
        }
        else if(!Cannon.IsSameTeam(Pawn(HitActor)))
        {
            HitActor.TakeDamage(FireInfo.Damage, Cannon.InstigatorController, HitLocation, FireInfo.Momentum * Normal(End - Start), FireInfo.DamageType,, Cannon);
        } else {
            return false;
        }

        LastHitLocation = HitLocation;
        bForceNetUpdate = true;

        super.FireAt(Start, BarrelDir, End);
        
        return true;
    }

    function Idle_()
    {
        Cannon.Target = none;
        GotoState('Idle');

    }

    simulated function EndState(name NextStateName)
    {
    }

    simulated event Tick(float DeltaTime)
    {
        local vector hitLocation,norm;
        local Actor hitActor;
        Super.Tick(DeltaTime);

        if ( WorldInfo.NetMode != NM_DedicatedServer ) {
            if(!bWaiting && targetedActor != none) {
                hitActor = Trace(hitLocation, norm, targetedActor.Location, self.location, true);
                if(hitActor == targetedActor) {
                    LastHitLocation = hitLocation;
                }            
            }
            if(E != none) {
                E.SetVectorParameter('LaserRifle_Endpoint', LastHitLocation);
                beamEndPointLocationMarker.SetLocation(LastHitLocation);
            }
        }
    }

}

function bool CanHit(Pawn PotentialTarget) {
    local Actor HitActor;
    local Vector Start, End, HitLocation, HitNormal;


	Start = Cannon.GetPawnViewLocation();
    Start.Z -= 90;
    End = PotentialTarget.location;

    Start = Start + vector(rotator(End-Start)) * 300.0;

    HitActor = Cannon.Trace(HitLocation, HitNormal, End, Start, true, vect(0,0,0),, TRACEFLAG_Bullet);
    targetedActor = HitActor;

    if(HitActor != PotentialTarget)
    {
        return false;
    }
    return true;
}

simulated function crystalChargingGlow() {
    local float glow;
    CrystalGlowMIC.GetScalarParameterValue('Obelisk_Glow', glow);
    if(glow < 1) {
        glow += 0.1;
        CrystalGlowMIC.SetScalarParameterValue('Obelisk_Glow', glow);
    }
}

simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
    super.DisplayDebug(HUD, out_YL, out_YPos);

    HUD.Canvas.SetDrawColor(255, 255, 0);
    HUD.Canvas.SetPos(4, out_YPos);

    HUD.Canvas.DrawText("Physics:"@Physics);
}

simulated function InitAndAttachMuzzleFlashes(SkeletalMeshComponent NewBase, name SocketName)
{
    InitMuzzleFlash();

    if(Cannon != none && ChargeUpMuzzleFlash != none)
    {
       
       ChargeUpMuzzleFlash.Initialize(NewBase, SocketName);
       MuzzleFlash.Initialize(NewBase, SocketName);
    }
}

/**
event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	super.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
}

simulated event Destroyed() {
	super.Destroyed();
	loginternal("warum?");
}
*/


defaultproperties
{
    bAlwaysRelevant=true;
    FriendlyName="Obelisk Laser"
    RootBone=Weapon

    //Description="The Mass Oscillation Generator creates dense projectiles of negative mass, which strongly repel any normal mass in proximity. Normally unstable, the negative mass is kept in a tenuous equilibrium sufficient to give a large effective range in the absence of obstacles. The repulsive force is stronger on more massive objects, creating some spectacular interactions.\n\nThe reduced lethality of the MOG makes it ideal for crowd pacification with minimal risk of lawsuits."

    BeamTemplate=ParticleSystem'RX_BU_Oblisk.Effects.P_Obelisk_LaserBeam'
    ImpactLightClass=Class'UTGame.UTShockImpactLight'
    
   // bHidden=true

    WindDownDelay=2.5
    //FlyingTargetPreference=0.5
    FlyingTargetPreference=0.0 // dont prefer aircrafts
    RotationRate=(Pitch=32768,Yaw=60000,Roll=0)

    WeaponMesh=None 
    WeaponScale=1.0

//    ActivateSound=SoundCue'Sentinel_Resources.Sounds.Weapons.SwitchToMiniGunCue'

    ExtraStrength=0
    AmmoCost=50
    ActivateSound=None
    DefaultImpactEffect=(ParticleTemplate=ParticleSystem'RX_BU_Oblisk.Effects.P_Obelisk_Impact')
    
    Begin Object Class=Rx_SentinelWeaponComponent_FireInfo Name=FireInfo0
        FireInterval = 4.0
        FireOffset=(X=-100.0,Y=0.0,Z=-90.0)
        Damage=300.0
        //Momentum=5000.0
        DamageType=class'Rx_DmgType_Obelisk'
        MaxRange=11000.0
        //Spread=0.03
        FireSound=SoundCue'RX_BU_Oblisk.Sounds.SC_Obelisk_Fire'
    End Object
    FireInfo=FireInfo0

    Begin Object Class=Rx_SentinelWeaponComponent_MuzzleFlash Name=MuzzleFlash0
        bIgnoreOwnerHidden=true
        Template=ParticleSystem'RX_BU_Oblisk.Effects.P_Obelisk_Fire'
        MuzzleFlashDuration=2.25
        //MuzzleFlashOffset=(X=-100.0,Y=0.0,Z=-90.0)        
        bConstantFlash=false
    End Object
    MuzzleFlash=MuzzleFlash0

    Begin Object Class=Rx_SentinelWeaponComponent_MuzzleFlash Name=MuzzleFlash1
        Template=ParticleSystem'RX_BU_Oblisk.Effects.P_Obelisk_ChargeUp'
        bIgnoreOwnerHidden=true
        MuzzleFlashDuration=4
        //MuzzleFlashOffset=(X=-100.0,Y=0.0,Z=-90.0)        
        bConstantFlash=false
    End Object
    ChargeUpMuzzleFlash=MuzzleFlash1

    Begin Object Class=Rx_SentinelWeaponComponent_MuzzleFlashLight Name=MuzzleFlashLightComponent0
        LightOffset=(X=-100.0,Y=0.0,Z=-90.0)
        TimeShift=((StartTime=0.0,Radius=200,Brightness=5,LightColor=(R=255,G=10,B=10,A=255)),(StartTime=0.8,Radius=64,Brightness=0,LightColor=(R=255,G=10,B=10,A=255)))
    End Object
    MuzzleFlashLight=MuzzleFlashLightComponent0

    Begin Object Class=Rx_SentinelWeaponComponent_HitEffects Name=HitEffectsComp
    End Object
    HitEffects=HitEffectsComp

    Begin Object Class=AudioComponent Name=WindUpSound0
        SoundCue=SoundCue'RX_BU_Oblisk.Sounds.SC_Obelisk_ChargeUp'
        bStopWhenOwnerDestroyed=true
    End Object
    WindUpSound=WindUpSound0
    Components.Add(WindUpSound0)

    Begin Object Class=AudioComponent Name=WindDownSound0
        SoundCue=none //SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltAutoRifle_FireStop'
        bStopWhenOwnerDestroyed=true
        End Object
    WindDownSound=WindDownSound0
    Components.Add(WindDownSound0)
}
