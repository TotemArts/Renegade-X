class Rx_Building_Refinery_Nod_Internals extends Rx_Building_Refinery_Internals;

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
        SkeletalMesh = SkeletalMesh'RX_BU_Refinery.Mesh.SK_BU_Refinery'
        PhysicsAsset = PhysicsAsset'RX_BU_Refinery.Mesh.SK_BU_Refinery_Physics'
        AnimSets(0)  = AnimSet'RX_BU_Refinery.Anims.AS_BU_Refinery'
    	End Object
    
    	IdleAnimName    = "PumpIdle"
	
	FriendlyBuildingSounds(BuildingDestroyed)           = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodRefinery_Destroyed'
	FriendlyBuildingSounds(BuildingUnderAttack)         = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodRefinery_UnderAttack'
	FriendlyBuildingSounds(BuildingRepaired)            = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodRefinery_Repaired'
	FriendlyBuildingSounds(BuildingDestructionImminent) = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodRefinery_DestructionImminent'
	EnemyBuildingSounds(BuildingDestroyed)              = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_NodRefinery_Destroyed'
	EnemyBuildingSounds(BuildingUnderAttack)            = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_NodRefinery_UnderAttack'
	
	AttachmentClasses.Add(Rx_BuildingAttachment_Door_Nod)
}
