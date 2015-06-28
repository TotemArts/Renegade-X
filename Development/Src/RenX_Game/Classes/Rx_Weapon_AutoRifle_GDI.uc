class Rx_Weapon_AutoRifle_GDI extends Rx_Weapon_AutoRifle;


simulated function PostBeginPlay()
{
	super.PostBeginPlay();
}

DefaultProperties
{
	TeamSkin=MaterialInterface'RX_WP_AutoRifle.Materials.MI_WP_AR_GDI'
	TeamIndex = 1 

	AttachmentClass = class'Rx_Attachment_AutoRifle_GDI'

	WeaponProjectiles(0)=class'RenX_Game.Rx_Projectile_AutoRifle_GDI'
	WeaponProjectiles(1)=class'RenX_Game.Rx_Projectile_AutoRifle_GDI'
	
	//WeaponIconTexture
}
