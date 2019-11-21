class Rx_Weapon_Airstrike_GDI extends Rx_Weapon_Airstrike;

DefaultProperties
{
	AttachmentClass = class'Rx_Attachment_Airstrike_GDI'
	AirstrikeType=class'Rx_Airstrike_A10'
	DecalM=DecalMaterial'RX_WP_Binoculars.Materials.DM_AirstrikePattern_A10'
	BeamEffect=ParticleSystem'RX_WP_Binoculars.Beams.P_Airstrike_Beam_GDI'
	//BeamEffect=ParticleSystem'RX_WP_LaserRifle.Effects.P_LaserRifle_Beam'
	TargetActorClass=class'Rx_AirstrikeTarget_A10'
	
	InventoryMovieGroup=31

	WeaponIconTexture=Texture2D'RX_WP_Binoculars.UI.T_WeaponIcon_A10'
	PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_Airstrike_A10'
}
