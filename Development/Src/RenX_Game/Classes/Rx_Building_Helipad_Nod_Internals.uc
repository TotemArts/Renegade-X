class Rx_Building_Helipad_Nod_Internals extends Rx_Building_Team_Internals;

var private name IdleAnimName;
var repnotify bool PlayIdleAnim;

replication
{
	if (bNetDirty && Role == ROLE_Authority)
		PlayIdleAnim;
}

simulated event ReplicatedEvent( name VarName )
{
	if (VarName == 'PlayIdleAnim')
	{
		ToggleIdleAnimation();
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated function Init(Rx_Building Visuals, bool isDebug )
{
	super.Init(Visuals, isDebug);
	if(WorldInfo.Netmode != NM_Client) {
		PlayIdleAnim = True;
		ToggleIdleAnimation();
	}
}

simulated function ToggleIdleAnimation()
{
	if(PlayIdleAnim)
	{
		BuildingSkeleton.PlayAnim(IdleAnimName,,True);
	}
	else
	{
		BuildingSkeleton.StopAnim();
	}
}

simulated function PlayDestructionAnimation() 
{
    PlayIdleAnim = False;
    ToggleIdleAnimation();

    Super.PlayDestructionAnimation();
}


DefaultProperties
{
	TeamID = TEAM_NOD
	
	Begin Object Name=BuildingSkeletalMeshComponent
        SkeletalMesh = SkeletalMesh'RX_BU_Helipad.Mesh.SK_Helipad'
        PhysicsAsset = PhysicsAsset'RX_BU_Helipad.Mesh.SK_Helipad_Physics'
        AnimSets(0)  = AnimSet'RX_BU_Helipad.Anims.AS_Helipad'
    End Object
    
    IdleAnimName    = "Idle"

	FriendlyBuildingSounds(BuildingDestroyed)           = SoundNodeWave'RX_EVA_VoiceClips_Extra.Nod_EVA.S_EVA_Nod_NodHelipad_Destroyed'
    FriendlyBuildingSounds(BuildingUnderAttack)         = SoundNodeWave'RX_EVA_VoiceClips_Extra.Nod_EVA.S_EVA_Nod_NodHelipad_UnderAttack'
    FriendlyBuildingSounds(BuildingRepaired)            = SoundNodeWave'RX_EVA_VoiceClips_Extra.Nod_EVA.S_EVA_Nod_NodHelipad_Repaired'
    FriendlyBuildingSounds(BuildingDestructionImminent) = SoundNodeWave'RX_EVA_VoiceClips_Extra.Nod_EVA.S_EVA_Nod_NodHelipad_DestructionImminent'
    EnemyBuildingSounds(BuildingDestroyed)              = SoundNodeWave'RX_EVA_VoiceClips_Extra.gdi_eva.S_EVA_GDI_NodHelipad_Destroyed'
    EnemyBuildingSounds(BuildingUnderAttack)            = SoundNodeWave'RX_EVA_VoiceClips_Extra.gdi_eva.S_EVA_GDI_NodHelipad_UnderAttack'

	AttachmentClasses.Add(Rx_BuildingAttachment_Door_Nod)
}
