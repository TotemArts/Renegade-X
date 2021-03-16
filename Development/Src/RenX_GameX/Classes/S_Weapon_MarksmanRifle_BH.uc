class S_Weapon_MarksmanRifle_BH extends Rx_Weapon_MarksmanRifle_Nod;

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_SniperRifle.Mesh.SK_MarksmanRifle_1P_Nod'
		Materials[1]=Material'S_WP_SniperRifle.Materials.M_Counter_Ones'
		Materials[2]=Material'S_WP_SniperRifle.Materials.M_Counter_Tens'		
		Materials[3]=MaterialInstanceConstant'S_WP_SniperRifle.Materials.MI_Lense_Translucent'
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		Materials[2]=MaterialInstanceConstant'S_WP_SniperRifle.Materials.MI_Lense_Translucent'
	End Object
	
	WeaponProjectiles(0)=class'S_Projectile_MarksmanRifle_BH'

	AttachmentClass = class'S_Attachment_MarksmanRifle_BH'
}
