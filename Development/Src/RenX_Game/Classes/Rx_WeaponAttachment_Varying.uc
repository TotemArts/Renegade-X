class Rx_WeaponAttachment_Varying extends Rx_WeaponAttachment
abstract;


var ParticleSystem MuzzleFlashPSCTemplate_Heroic;
var ParticleSystem BeamTemplate_Heroic;	
var MaterialImpactEffect DefaultImpactEffect_Heroic;
var class<UDKExplosionLight> MuzzleFlashLightClass_Heroic;
var repnotify	bool		bUseHeroicEffects;
var ParticleSystem BeamTemplate;

replication
{
	if(bNetDirty)
		bUseHeroicEffects; 
}

simulated event ReplicatedEvent(name VarName)
{
	if(VarName == 'bUseHeroicEffects')
	{
		if(BeamTemplate_Heroic != none) BeamTemplate = BeamTemplate_Heroic;
		if(MuzzleFlashPSCTemplate_Heroic != none) MuzzleFlashPSCTemplate = MuzzleFlashPSCTemplate_Heroic;
		if(MuzzleFlashLightClass_Heroic != none) MuzzleFlashLightClass = MuzzleFlashLightClass_Heroic;
		if(DefaultImpactEffect_Heroic.ParticleTemplate != none) DefaultImpactEffect = DefaultImpactEffect_Heroic;
		
	}
	else
		super.ReplicatedEvent(VarName);
}

simulated function SetHeroic(bool bHeroic)
{
	bUseHeroicEffects=bHeroic;
	if(bHeroic) 
	{
		if(BeamTemplate_Heroic != none) BeamTemplate = BeamTemplate_Heroic;
		if(MuzzleFlashPSCTemplate_Heroic != none) MuzzleFlashPSCTemplate = MuzzleFlashPSCTemplate_Heroic;
		if(MuzzleFlashLightClass_Heroic != none) MuzzleFlashLightClass = MuzzleFlashLightClass_Heroic;
		if(DefaultImpactEffect_Heroic.ParticleTemplate != none) DefaultImpactEffect = DefaultImpactEffect_Heroic;
	}
	else
	{
		BeamTemplate = default.BeamTemplate;
		MuzzleFlashPSCTemplate = default.MuzzleFlashPSCTemplate;
		MuzzleFlashLightClass = default.MuzzleFlashLightClass;
		DefaultImpactEffect = default.DefaultImpactEffect;
	}
}



DefaultProperties
{

}