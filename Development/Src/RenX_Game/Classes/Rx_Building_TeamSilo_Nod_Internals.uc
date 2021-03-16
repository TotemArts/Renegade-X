class Rx_Building_TeamSilo_Nod_Internals extends Rx_Building_TeamSilo_Internals;

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

defaultproperties
{
	Begin Object Name=BuildingSkeletalMeshComponent
        SkeletalMesh = SkeletalMesh'RX_BU_TeamSilo.Meshes.SK_BU_Silo'
		Materials[0]=MaterialInstanceConstant'RX_BU_TeamSilo.Materials.MI_Flag_Nod'
        PhysicsAsset = PhysicsAsset'RX_BU_Silo.Meshes.SK_BU_Silo_Physics'
	AnimTreeTemplate    		= AnimTree'RX_BU_Silo.Anims.AT_BU_Silo'
        AnimSets(0)  = AnimSet'RX_BU_Silo.Anims.AS_BU_Silo'
	bEnableClothSimulation 	 	= True
	bClothAwakeOnStartup   	 	= True
	ClothWind              	 	= (X=100.000000,Y=-100.000000,Z=20.000000)
    	End Object
    
    	IdleAnimName    = "Anim_Silo_Idle"

   FriendlyBuildingSounds(BuildingDestroyed)		=	SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodSilo_Destroyed'
   FriendlyBuildingSounds(BuildingUnderAttack)		=	SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodSilo_UnderAttack'
   FriendlyBuildingSounds(BuildingRepaired)		=	None
   FriendlyBuildingSounds(BuildingDestructionImminent) 	=	None
   EnemyBuildingSounds(BuildingDestroyed)		=	SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_NodSilo_Destroyed'
   EnemyBuildingSounds(BuildingUnderAttack)		=	SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_NodSilo_UnderAttack'

   TeamID = TEAM_NOD
      

}