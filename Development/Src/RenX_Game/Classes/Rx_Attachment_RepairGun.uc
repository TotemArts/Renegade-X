class Rx_Attachment_RepairGun extends Rx_Attachment_BeamWeapon;

var bool bHittingWall;
/** emitter playing the endpoint effect */
var UTEmitter BeamEndpointEffect;
var color BeamColor;
var AudioComponent LinkHitSound;
var SoundCue BeamHealSound;
var ParticleSystem BeamEndpointTemplateWhenHealing;
var bool bHealing;

simulated function SetImpactedActor(Actor HitActor, vector HitLocation, vector HitNormal, TraceHitInfo HitInfo)
{
    local SoundCue DesiredLinkHitSound;
    	
    super.SetImpactedActor(HitActor,HitLocation,HitNormal,HitInfo);

    if (WorldInfo.NetMode != NM_DedicatedServer)
    {
		if (Rx_Pawn(Instigator) != none)
		{
			bHealing = Rx_Pawn(Instigator).bRepairing;
		}
		else
		{
			bHealing = false;
		}


        if (HitActor != None)
        {
            
            DesiredLinkHitSound = BeamHealSound;
            
            if(!bHealing) {
                KillEndpointEffect();    
            }
            
            if(!bHittingWall) {
                bHittingWall = UTPawn(HitActor) == none;
            }

            if (LinkHitSound == None || LinkHitSound.SoundCue != DesiredLinkHitSound)
            {
                if (LinkHitSound != None)
                {
                    LinkHitSound.FadeOut(0.1f, 0.0f);
                }
                if (Instigator != None)
                {
                    LinkHitSound = Instigator.CreateAudioComponent(DesiredLinkHitSound, false, true);
                }
                if (LinkHitSound != None)
                {
                    LinkHitSound.FadeIn(0.1f, 1.0f);
                }
            }
			if (LinkHitSound != None)
			{
				if (LinkHitSound.IsPlaying() && !bHealing)
				{
					LinkHitSound.Stop();
				}
				else if (!LinkHitSound.IsPlaying() && bHealing)
				{
					LinkHitSound.Play();
				}
			}

            if (BeamEndpointEffect != None)
            {
                BeamEndpointEffect.SetRotation(rotator(HitNormal));
            }
        }
        else
        {
            if (LinkHitSound != None)
            {
            	LinkHitSound.FadeOut(0.1f,0.0f);
            	LinkHitSound = None;
            }
            bHittingWall = false;
            KillEndpointEffect();
        } 
    }
}

simulated function StopMuzzleFlash()
{
    bHittingWall = false;
    super.StopMuzzleFlash();
}

simulated function StopThirdPersonFireEffects()
{
    Super.StopThirdPersonFireEffects();

    if (LinkHitSound != None)
    {
        LinkHitSound.FadeOut(0.1f, 0.0f);
        LinkHitSound = none;
    }
}


simulated function UpdateBeam(byte FireModeNum)
{
    local vector EndPoint;

    if (BeamEmitter[FireModeNum] != None)
    {
        EndPoint = PawnOwner.FlashLocation;
        if(UTPawn(Owner).Weapon != None && !WorldInfo.IsPlayingDemo()) {
        	EndPoint = Rx_BeamWeapon(UTPawn(Owner).Weapon).CurrHitLocation;
        }

        BeamEmitter[FireModeNum].SetVectorParameter(EndPointParamName, EndPoint);

        if (WorldInfo.NetMode != NM_DedicatedServer && bHealing)
        {
            if (BeamEndpointEffect != None && !BeamEndpointEffect.bDeleteMe)
            {
                BeamEndpointEffect.SetLocation(EndPoint);
                BeamEndpointEffect.SetFloatParameter('Touch',bHittingWall?1:0);
    			if(BeamEndpointEFfect.LifeSpan > 0.0)
				{
					BeamEndpointEffect.ParticleSystemComponent.ActivateSystem();
					BeamEndpointEFfect.LifeSpan = 0.0;
				}
            }
            else
            {
                BeamEndpointEffect = Spawn(class'UTEmitter', self,, EndPoint);
                BeamEndpointEFfect.LifeSpan = 0.0;
                BeamEndpointEffect.SetFloatParameter('Touch',bHittingWall?1:0);
            }
        }
                
    }
    if (BeamEndpointEffect != None && BeamEndpointEffect.ParticleSystemComponent.Template != BeamEndpointTemplateWhenHealing)
    {
        BeamEndpointEffect.SetTemplate(BeamEndpointTemplateWhenHealing, true);
    }
    
    HideEmitter(FireModeNum, false);
}

simulated function KillEndpointEffect()
{
    if (BeamEndpointEffect != None)
    {
        BeamEndpointEffect.ParticleSystemComponent.DeactivateSystem();
        BeamEndpointEffect.LifeSpan = 2.0;
        BeamEndpointEffect = None;
    }
}

simulated event Destroyed()
{
    Super.Destroyed();

    if (LinkHitSound != None)
    {
        LinkHitSound.Stop();
    }

    KillEndpointEffect();
}

simulated function HideEmitter(int Index, bool bHide)
{
    
    Super.HideEmitter(Index, bHide);
    if(bHide) {
        KillEndpointEffect();
    }
}

DefaultProperties
{
    Begin Object Name=SkeletalMeshComponent0
        SkeletalMesh=SkeletalMesh'RX_WP_RepairGun.Mesh.SK_WP_RepairGun_3P'    
    End Object

    DefaultImpactEffect=(ParticleTemplate=ParticleSystem'RX_WP_RepairGun.Effects.P_RepairGun_MuzzleFlash_3P')
    DefaultAltImpactEffect=(ParticleTemplate=ParticleSystem'RX_WP_RepairGun.Effects.P_RepairGun_MuzzleFlash_3P')

    BeamTemplate[0]=ParticleSystem'RX_WP_RepairGun.Effects.P_RepairGun_Beam'
    BeamTemplate[1]=ParticleSystem'RX_WP_RepairGun.Effects.P_RepairGun_Beam'
    
    BeamSockets[0]=MuzzleFlashSocket
    BeamSockets[1]=MuzzleFlashSocket
    
    WeaponClass = class'Rx_Weapon_RepairGun'
    MuzzleFlashSocket=MuzzleFlashSocket
    MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_RepairGun.Effects.P_RepairGun_MuzzleFlash_3P'
    MuzzleFlashLightClass=class'Rx_Light_RepairBeam'
    MuzzleFlashDuration=2.5    
    
    AimProfileName = Shotgun
	WeaponAnimSet = AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_Shotgun'
    EndPointParamName=BeamEnd
    
    BeamColor=(R=128,G=120,B=220,A=255)
    
    BeamEndpointTemplateWhenHealing=ParticleSystem'RX_WP_RepairGun.Effects.P_Repairing_Sparks'
    BeamHealSound=SoundCue'RX_WP_RepairGun.Sounds.SC_RepairGun_WeldingSparks'
    
}
