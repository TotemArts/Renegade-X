class Rx_Attachment_RepairTool extends Rx_Attachment_RepairGun;

DefaultProperties
{
    Begin Object Name=SkeletalMeshComponent0
        SkeletalMesh=SkeletalMesh'RX_WP_RepairGun.Mesh.SK_WP_RepairTool_3P' 
    End Object

    DefaultImpactEffect=(ParticleTemplate=ParticleSystem'RX_WP_RepairGun.Effects.P_RepairGun_MuzzleFlash_3P')
    DefaultAltImpactEffect=(ParticleTemplate=ParticleSystem'RX_WP_RepairGun.Effects.P_RepairGun_MuzzleFlash_3P')

    BeamTemplate[0]=ParticleSystem'RX_WP_RepairGun.Effects.P_RepairGun_Beam_Small'
    BeamTemplate[1]=ParticleSystem'RX_WP_RepairGun.Effects.P_RepairGun_Beam_Small'
    
    BeamSockets[0]=MuzzleFlashSocket
    BeamSockets[1]=MuzzleFlashSocket
    
    WeaponClass = class'Rx_Weapon_RepairTool'
    MuzzleFlashSocket=MuzzleFlashSocket
    MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_RepairGun.Effects.P_RepairGun_MuzzleFlash_3P'
    MuzzleFlashLightClass=class'Rx_Light_RepairBeam'
    MuzzleFlashDuration=2.5    
    
    AimProfileName = Pistol
	WeaponAnimSet = AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_Pistol'
    EndPointParamName=BeamEnd
    
    BeamColor=(R=128,G=220,B=120,A=255)
    
    BeamEndpointTemplateWhenHealing=ParticleSystem'RX_WP_RepairGun.Effects.P_Repairing_Sparks'
    BeamHealSound=SoundCue'RX_WP_RepairGun.Sounds.SC_RepairGun_WeldingSparks'
    
}
