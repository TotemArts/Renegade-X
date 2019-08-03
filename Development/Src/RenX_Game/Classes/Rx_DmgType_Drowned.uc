class Rx_DmgType_Drowned extends Rx_DmgType;

defaultproperties
{
    GibPerterbation=0.15
    AlwaysGibDamageThreshold=0
	RewardAnnouncementSwitch=0
    bNeverGibs=false 
	bThrowRagdoll=false
    bBulletHit=false
    bCausesBloodSplatterDecals=false
    bCausesBlood=false
	GibTrail=ParticleSystem'RX_CH_Gibs.Effects.P_BloodTrail'
	
	KDamageImpulse=3000
	KDeathUpKick=200

	IconTexture=Texture2D'RenX_AssetBase.DeathIcons.T_DeathIcon_GenericSkull'
	
	bUnsourcedDamage=true
} 