class Rx_Attachment_PersonalIonCannon extends Rx_WeaponAttachment_Varying;

var class<UDKExplosionLight> ImpactLightClass;

var int CurrentPath;

simulated function SpawnBeam(vector Start, vector End, bool bFirstPerson)
{
    local ParticleSystemComponent E;
    local actor HitActor;
    local vector HitNormal, HitLocation;

    if ( End == Vect(0,0,0) )
    {
        if ( !bFirstPerson || (Instigator.Controller == None) )
        {
            return;
        }
		
        // guess using current viewrotation;
        End = Start + vector(Instigator.Controller.Rotation) * WeaponClass.default.WeaponRange;
        HitActor = Instigator.Trace(HitLocation, HitNormal, End, Start, TRUE, vect(0,0,0),, TRACEFLAG_Bullet);
        if ( HitActor != None )
        {
            End = HitLocation;
        }
    }

    E = WorldInfo.MyEmitterPool.SpawnEmitter(BeamTemplate, Start);
    E.SetVectorParameter('BeamEnd', End);
	/** one1: changed foreground rendering to world rendering for beam */
    //if (bFirstPerson && !class'Engine'.static.IsSplitScreen())
    //{
    //    E.SetDepthPriorityGroup(SDPG_Foreground);
    //}
    //else
    //{
        E.SetDepthPriorityGroup(SDPG_World);
    //}
}

simulated function FirstPersonFireEffects(Weapon PawnWeapon, vector HitLocation)
{
    local vector EffectLocation;

    Super.FirstPersonFireEffects(PawnWeapon, HitLocation);

    if (Instigator.FiringMode == 0 || Instigator.FiringMode == 3)
    {
        EffectLocation = UTWeapon(PawnWeapon).GetEffectLocation();
        SpawnBeam(EffectLocation, HitLocation, true);

        if (!WorldInfo.bDropDetail && Instigator.Controller != None && ImpactLightClass != None)
        {
            UDKEmitterPool(WorldInfo.MyEmitterPool).SpawnExplosionLight(ImpactLightClass, HitLocation);
        }
    }
}

simulated function ThirdPersonFireEffects(vector HitLocation)
{

    Super.ThirdPersonFireEffects(HitLocation);

    if ((Instigator.FiringMode == 0 || Instigator.FiringMode == 3))
    {
        SpawnBeam(GetEffectLocation(), HitLocation, false);
    }
}

function PreBeginPlay()
{
    super.PreBeginPlay();
    //WeaponSocketMesh.SetSkeletalMesh(SkeletalMesh'RX_WP_Pistol.Mesh.SK_WP_Pistol_Back');
}

DefaultProperties
{
    Begin Object Name=SkeletalMeshComponent0
        SkeletalMesh=SkeletalMesh'RX_WP_PersonalIonCannon.Mesh.SK_PersonalIonCannon_3P'
    End Object

    DefaultImpactEffect=(ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_PersonalIonCannon_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')
    DefaultAltImpactEffect=(ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_PersonalIonCannon_Impact',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')
    DefaultImpactEffect_Heroic=(ParticleTemplate=ParticleSystem'RX_FX_Munitions.Beams.P_PersonalIonCannon_Impact_Heroic',Sound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_Electric')

    BulletWhip=SoundCue'RX_WP_LaserRifle.Sounds.SC_LaserRifle_WizzBy'
    BeamTemplate=ParticleSystem'RX_WP_PersonalIonCannon.Effects.P_PersonalIonCannon_Beam'
    BeamTemplate_Heroic=ParticleSystem'RX_WP_PersonalIonCannon.Effects.P_PersonalIonCannon_Beam_Heroic'

    WeaponClass = class'Rx_Weapon_PersonalIonCannon'
    MuzzleFlashSocket=MuzzleFlashSocket
    MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_PersonalIonCannon.Effects.P_MuzzleFlash_3P'
    MuzzleFlashPSCTemplate_Heroic=ParticleSystem'RX_WP_PersonalIonCannon.Effects.P_MuzzleFlash_3P_Heroic'
    MuzzleFlashLightClass=class'UTGame.UTShockMuzzleFlashLight'
    ImpactLightClass=Rx_Light_RepairBeam
    MuzzleFlashDuration=2.5    
    
    AimProfileName = AutoRifle
	WeaponAnimSet = AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_AutoRifle'
}
