class Rx_Building_HandOfNod_Internals extends Rx_Building_Team_Internals;
// TODO: add skeletal information and Glass Building Components
var Rx_BuildingAttachment_RadialImpulse Impulse;

simulated function ChangeDamageLodLevel(int newDmgLodLevel)
{
	super.ChangeDamageLodLevel(newDmgLodLevel);
	if (newDmgLodLevel==4 && Impulse != None)
		Impulse.Fire();
}

DefaultProperties
{
	Begin Object Name=BuildingSkeletalMeshComponent
		SkeletalMesh = SkeletalMesh'RX_BU_Hand.Mesh.SK_HandofNod'
		PhysicsAsset = PhysicsAsset'RX_BU_Hand.Mesh.SK_HandofNod_Physics'
	End Object
	
	TeamID          = TEAM_NOD

	
	
	FriendlyBuildingSounds(BuildingDestroyed)           = SoundNodeWave'RX_EVA_VoiceClips.nod_eva.S_EVA_Nod_HON_Destroyed'
	FriendlyBuildingSounds(BuildingUnderAttack)         = SoundNodeWave'RX_EVA_VoiceClips.nod_eva.S_EVA_Nod_HON_UnderAttack'
	FriendlyBuildingSounds(BuildingRepaired)            = SoundNodeWave'RX_EVA_VoiceClips.nod_eva.S_EVA_Nod_HON_Repaired'
	FriendlyBuildingSounds(BuildingDestructionImminent) = SoundNodeWave'RX_EVA_VoiceClips.nod_eva.S_EVA_Nod_HON_DestructionImminent'
	EnemyBuildingSounds(BuildingDestroyed)              = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_HON_Destroyed'
	EnemyBuildingSounds(BuildingUnderAttack)            = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_HON_UnderAttack'

	AttachmentClasses.Add(Rx_BuildingAttachment_Door_Nod)
	//AttachmentClasses.Add(Rx_BuildingAttachment_Glass_TypeA)
	//AttachmentClasses.Add(Rx_BuildingAttachment_Glass_TypeB)
	//AttachmentClasses.Add(Rx_BuildingAttachment_Glass_TypeC)
	AttachmentClasses.Add( Rx_BuildingAttachment_RadialImpulse_HoN )
	AttachmentClasses.Add(Rx_BuildingAttachment_BeaconPedestal)
}
