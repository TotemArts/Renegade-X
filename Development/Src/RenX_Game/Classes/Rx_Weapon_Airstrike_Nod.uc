class Rx_Weapon_Airstrike_Nod extends Rx_Weapon_Airstrike;

DefaultProperties
{
	AttachmentClass = class'Rx_Attachment_Airstrike_Nod'
	AirstrikeType=class'Rx_Airstrike_AC130'
	DecalM=DecalMaterial'RX_WP_Binoculars.Materials.DM_AirstrikePattern_AC130'
	BeamEffect=ParticleSystem'RX_WP_Binoculars.Beams.P_Airstrike_Beam_Nod'
	TargetActorClass=class'Rx_AirstrikeTarget_AC130'

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		Materials[1]=MaterialInstanceConstant'RX_WP_Binoculars.Materials.MI_Lense_Red'
	End Object
	
	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		Materials[1]=MaterialInstanceConstant'RX_WP_Binoculars.Materials.MI_Lense_Red'
	End Object
	
	InventoryMovieGroup=32

	WeaponIconTexture=Texture2D'RX_WP_Binoculars.UI.T_WeaponIcon_AC130'
}
