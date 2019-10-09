class Rx_Building_AirTower_Internals extends Rx_Building_Team_Internals
	notplaceable;

var private name IdleAnimName;
var Rx_Building_AirStrip_Internals AirstripInternals;

var Rx_BuildingAttachment_RadialImpulse Impulse;

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

// Initialize the building and set the visual section of the building
simulated function Init(Rx_Building Visuals, bool isDebug )
{
	super.Init(Visuals, isDebug);
	if(WorldInfo.Netmode != NM_Client) {
		PlayIdleAnim = True;
		ToggleIdleAnimation();
		FindAirStrip();
	}
}

function FindAirStrip()
{
	local Rx_Building_AirStrip strip,beststrip;
	local float BestDist,CurDist;

	if(Rx_Building_AirTower(BuildingVisuals).LinkedAirstrip != None && Rx_Building_AirTower(BuildingVisuals).LinkedAirstrip.GetTeamNum() == GetTeamNum())
	{
		beststrip = Rx_Building_AirTower(BuildingVisuals).LinkedAirstrip;
	}
	else
	{
		ForEach AllActors(class'Rx_Building_AirStrip',strip)
		{
			if(strip.GetTeamNum() != GetTeamNum())
				continue;

			if(beststrip == None)
			{
				beststrip = strip;
				BestDist = VSizeSq(BuildingVisuals.location - strip.location);
			}
			else if (strip.AirTowerInternals == none)
			{
				CurDist = VSizeSq(BuildingVisuals.location - strip.location);
				if(BestDist > CurDist)
				{
					beststrip = strip;
					BestDist = CurDist;			
				}
			}
		}
	}

	if(beststrip == None)
	{
		`warn(self@" : Cannot find an airstrip to link to!");
		return;
	}

	beststrip.RegsiterTowerInternals(self);
	if (AirstripInternals == None)
		AirstripInternals = Rx_Building_AirStrip_Internals(beststrip.BuildingInternals);

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

simulated function ChangeDamageLodLevel(int newDmgLodLevel)
{
	super.ChangeDamageLodLevel(newDmgLodLevel);
	if (newDmgLodLevel==4 && Impulse != None)
	{
		PlayIdleAnim = False;
		ToggleIdleAnimation();
		Impulse.Fire();
	}
	// replicate damage visual state over to the strip.
	if (WorldInfo.NetMode != NM_Client && AirstripInternals != None)
	{
		AirstripInternals.DamageLodLevel = newDmgLodLevel;
		AirstripInternals.ChangeDamageLodLevel(newDmgLodLevel);
	}
}

DefaultProperties
{
	Begin Object Name=BuildingSkeletalMeshComponent
		SkeletalMesh        = SkeletalMesh'RX_BU_AirStrip.Mesh.SK_BU_AirTower_Skeleton'
		AnimSets(0)         = AnimSet'RX_BU_AirStrip.Anim.BU_AirTower'
		AnimTreeTemplate    = AnimTree'RX_BU_AirStrip.Anim.AT_BU_AirTrower'
		PhysicsAsset        = PhysicsAsset'RX_BU_AirStrip.Mesh.SK_BU_AirTower_Skeleton_Physics'
	End Object

	IdleAnimName    = "AirTower_Idle"
	TeamID          = TEAM_NOD

	FriendlyBuildingSounds(BuildingDestroyed)           = SoundNodeWave'RX_EVA_VoiceClips.nod_eva.S_EVA_Nod_AirStrip_Destroyed'
    FriendlyBuildingSounds(BuildingUnderAttack)         = SoundNodeWave'RX_EVA_VoiceClips.nod_eva.S_EVA_Nod_AirStrip_UnderAttack'
    FriendlyBuildingSounds(BuildingRepaired)            = SoundNodeWave'RX_EVA_VoiceClips.nod_eva.S_EVA_Nod_AirStrip_Repaired'
    FriendlyBuildingSounds(BuildingDestructionImminent) = SoundNodeWave'RX_EVA_VoiceClips.nod_eva.S_EVA_Nod_AirStrip_DestructionImminent'
    EnemyBuildingSounds(BuildingDestroyed)              = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_AirStrip_Destroyed'
    EnemyBuildingSounds(BuildingUnderAttack)            = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_AirStrip_UnderAttack'

	AttachmentClasses.Add( Rx_BuildingAttachment_Glass_AirTower )
	AttachmentClasses.Add( Rx_BuildingAttachment_Door_NOD )
	AttachmentClasses.Add( Rx_BuildingAttachment_RadialImpulse_Air )
}
