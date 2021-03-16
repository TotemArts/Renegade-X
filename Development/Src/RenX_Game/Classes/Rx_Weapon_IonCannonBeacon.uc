class Rx_Weapon_IonCannonBeacon extends Rx_Weapon_Beacon;

simulated function bool IsValidPosition() 
{
	local Rx_Weapon_DeployedBeacon DeployedB;

	ForEach WorldInfo.DynamicActors(class'Rx_Weapon_DeployedBeacon', DeployedB)
	{
		if (DeployedB.IsA(DeployedActorClass.name) && DeployedB.InstigatorController == Pawn(Owner).Controller)
		{
			Rx_Controller(Pawn(Owner).Controller).ClientMessage("You can only have one beacon deployed at once.");
			return false;
			break;
		}
	}

	return super.IsValidPosition();
}

DefaultProperties
{
	ArmsAnimSet=AnimSet'RX_WP_IonCannon.Anims.AS_IonCannonBeacon_Arms'

	DeployedActorClass=class'Rx_Weapon_DeployedIonCannonBeacon'

   	PanelWidth  = 0.25f
   	PanelHeight = 0.033f
   	PanelColor  = (B=128, G=255, R=0, A=255)
   	
   	AttachmentClass = class'Rx_Attachment_IonCannonBeacon'

   	PlayerViewOffset=(X=10.0,Y=0.0,Z=-2.5)
	ChargeCue = SoundCue'RX_WP_Nuke.Sounds.Nuke_DeployingCue'
	
	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_IonCannon.Mesh.SK_IonCannonBeacon_1P'
		AnimSets(0)=AnimSet'RX_WP_IonCannon.Anims.AS_IonCannonBeacon_1P'
		Animations=MeshSequenceA
		FOV=55.0
		Scale=2.0
	End Object
	
	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_IonCannon.Mesh.SK_ICBeacon_3P'
		Scale=1.0
	End Object

	InventoryMovieGroup=17

	WeaponIconTexture=Texture2D'RX_WP_IonCannon.UI.T_WeaponIcon_IonCannonBeacon'
	PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_IonCannonBeacon'
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_IonCannonBeacon'
}
