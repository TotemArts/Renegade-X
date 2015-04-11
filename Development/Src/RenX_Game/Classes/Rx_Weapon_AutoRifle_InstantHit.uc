class Rx_Weapon_AutoRifle_InstantHit extends Rx_Weapon_AutoRifle;


DefaultProperties
{
	AttachmentClass = class'Rx_Attachment_AutoRifle_InstantHit'

	WeaponRange=6000.0

	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_None

	InstantHitDamage(0)=8
	InstantHitDamage(1)=8
	
	HeadShotDamageMult=3.0

	InstantHitDamageTypes(0)=class'Rx_DmgType_AutoRifle'
	InstantHitDamageTypes(1)=class'Rx_DmgType_AutoRifle'

	InstantHitMomentum(0)=100000
	InstantHitMomentum(1)=100000
	
	bInstantHit=true
}
