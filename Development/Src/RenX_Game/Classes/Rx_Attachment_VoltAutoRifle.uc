class Rx_Attachment_VoltAutoRifle extends Rx_WeaponAttachment
    abstract;

var ParticleSystem BeamTemplate;
var ParticleSystem AltBeamTemplate;
var ParticleSystemComponent ChargeComponent;

var int CurrentPath;

simulated function AttachTo(UTPawn OwnerPawn)
{
    if (OwnerPawn.Mesh != None)
    {
        if (Mesh != None && MuzzleFlashSocket != '')
        {
            Mesh.AttachComponentToSocket(ChargeComponent, MuzzleFlashSocket);
        }
    }
    Super.AttachTo(OwnerPawn);
}

/*simulated function FireModeUpdated(byte FireModeNum, bool bViaReplication)
{
    if(FireModeNum == 1)
    {
        StartCharging();
    }
}*/

simulated function StartCharging()
{
    ChargeComponent.ActivateSystem();
}

simulated event StopThirdPersonFireEffects()
{
    ChargeComponent.DeactivateSystem();
    ChargeComponent.KillParticlesForced();
    Super.StopThirdPersonFireEffects();
}

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
        End = Start + vector(Instigator.Controller.Rotation) * class'RenX_Game.Rx_Weapon_VoltAutoRifle'.default.WeaponRange;
        HitActor = Instigator.Trace(HitLocation, HitNormal, End, Start, TRUE, vect(0,0,0),, TRACEFLAG_Bullet);
        if ( HitActor != None )
        {
            End = HitLocation;
        }
    }

	if (Instigator.FiringMode == 0 || Instigator.FiringMode == 3)
	{
		E = WorldInfo.MyEmitterPool.SpawnEmitter(BeamTemplate, Start);
		E.SetVectorParameter('BeamEnd', End);
		if (bFirstPerson && !class'Engine'.static.IsSplitScreen())
		{
			/** one1: changed foreground rendering to world rendering for beam */
			//E.SetDepthPriorityGroup(SDPG_Foreground);
			E.SetDepthPriorityGroup(SDPG_World);
		}
	}
		
	if (Instigator.FiringMode == 1 || Instigator.FiringMode == 4)
	{
		E = WorldInfo.MyEmitterPool.SpawnEmitter(AltBeamTemplate, Start);
		E.SetVectorParameter('BeamEnd', End);
		if (bFirstPerson && !class'Engine'.static.IsSplitScreen())
		{
			/** one1: changed foreground rendering to world rendering for beam */
			//E.SetDepthPriorityGroup(SDPG_Foreground);
			E.SetDepthPriorityGroup(SDPG_World);
		}
	}
	
    else
    {
        E.SetDepthPriorityGroup(SDPG_World);
    }
}

simulated function FirstPersonFireEffects(Weapon PawnWeapon, vector HitLocation)
{
    local vector EffectLocation;

    Super.FirstPersonFireEffects(PawnWeapon, HitLocation);

    if (Instigator.FiringMode >= 0 || Instigator.FiringMode == 3)
    {
        EffectLocation = UTWeapon(PawnWeapon).GetEffectLocation();
        SpawnBeam(EffectLocation, HitLocation, true);
    }
}

simulated function ThirdPersonFireEffects(vector HitLocation)
{

    Super.ThirdPersonFireEffects(HitLocation);

    if ((Instigator.FiringMode >= 0 || Instigator.FiringMode == 3))
    {
        SpawnBeam(GetEffectLocation(), HitLocation, false);
    }

    ChargeComponent.DeactivateSystem();
    ChargeComponent.KillParticlesForced();
    FireModeUpdated(0,false); // force bio back to 'base' state
}



DefaultProperties
{
    Begin Object Name=SkeletalMeshComponent0
        SkeletalMesh=SkeletalMesh'RX_WP_VoltAutoRifle.Mesh.SK_WP_Volt_3P'
        Scale=0.7
    End Object

    DefaultImpactEffect=(ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_Volt_Impact_Small',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltAutoRifle_Impact')
	DefaultAltImpactEffect=(ParticleTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_Volt_Impact_Small',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltAutoRifle_Impact')

    BulletWhip=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_WhipCue'
    BeamTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_Lightning_Thick'
	AltBeamTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_Lightning'

    WeaponClass = class'Rx_Weapon_VoltAutoRifle'
    MuzzleFlashSocket=MuzzleFlashSocket
    MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltRifle_MuzzleFlash_3P'
    MuzzleFlashLightClass=class'UTGame.UTShockMuzzleFlashLight'
    MuzzleFlashDuration=0.1
    
    AimProfileName = AutoRifle
    WeaponAnimSet = AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_AutoRifle'

    Begin Object Class=ParticleSystemComponent Name=AltChargeEffect
        Template=ParticleSystem'RX_WP_VoltAutoRifle.Effects.P_VoltBolt_Blue'
        Scale=0.25
        bAutoActivate=false
        SecondsBeforeInactive=1.0f
    End Object
    ChargeComponent = AltChargeEffect
}
