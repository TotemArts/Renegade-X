class Rx_Weapon_NukeBeacon extends Rx_Weapon_Beacon;

DefaultProperties
{
	ArmsAnimSet=AnimSet'RX_WP_Nuke.Anims.AS_NukeBeacon_Arms'

	DeployedActorClass=class'Rx_Weapon_DeployedNukeBeacon'

    PanelWidth  = 0.25f
    PanelHeight = 0.033f
    PanelColor  = (B=128, G=255, R=0, A=255)

	AttachmentClass = class'Rx_Attachment_NukeBeacon'

    PlayerViewOffset=(X=10.0,Y=0.0,Z=-2.5)
	ChargeCue = SoundCue'RX_WP_Nuke.Sounds.Nuke_DeployingCue'

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_Nuke.Mesh.SK_NukeBeacon_1P'
		AnimSets(0)=AnimSet'RX_WP_Nuke.Anims.AS_NukeBeacon_1P'
		Animations=MeshSequenceA
		FOV=55.0
		Scale=2.0
	End Object
	
	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_Nuke.Mesh.SK_WP_Nuke_3P'
		Scale=1.0
	End Object
	
	InventoryMovieGroup=18

	WeaponIconTexture=Texture2D'RX_WP_Nuke.UI.T_WeaponIcon_NukeBeacon'
	PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_NukeBeacon'
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_NukeBeacon'
}
