class Rx_Gib_Human extends UTGib
	abstract;


defaultproperties
{
	HitSound=SoundCue'RX_SoundEffects.BodyImpact.SC_FleshBounce'

	MITV_DecalTemplate=MaterialInstanceTimeVarying'RX_CH_Gibs.Decals.BloodSplatter'

	MITV_GibMeshTemplate=MaterialInstanceTimeVarying'RX_CH_Gibs.Materials.MITV_CH_Gibs_Gore01'
	MITV_GibMeshTemplateSecondary=MaterialInstanceTimeVarying'RX_CH_Gibs.Materials.MITV_CH_Gibs_Gore01'
	
	LifeSpan=5.0

	GibMeshDissolveParamName="BurnTime"
	GibMeshWaitTimeBeforeDissolve=3.0f
	
	DecalDissolveParamName="DissolveAmount"
	DecalWaitTimeBeforeDissolve=3.0f

}