class S_Building_AirTower_Internals_BlackHand extends Rx_Building_AirTower_Internals
	notplaceable;

/*function FindAirStrip()
{
	local S_Building_AirStrip_BlackHand strip;
	ForEach AllActors(class'S_Building_AirStrip_BlackHand',strip)
	{
		strip.RegsiterTowerInternals(self);
		if (AirstripInternals == None)
			AirstripInternals = S_Building_AirStrip_Internals_BlackHand(strip.BuildingInternals);
		break; // found Air Strip no need to search anymore
	}
}*/

function FindAirStrip()
{
	local S_Building_AirStrip_BlackHand strip,beststrip;
	local float BestDist,CurDist;

	if(S_Building_AirTower_BlackHand(BuildingVisuals).LinkedAirstrip != None && S_Building_AirTower_BlackHand(BuildingVisuals).LinkedAirstrip.GetTeamNum() == GetTeamNum())
	{
		beststrip = S_Building_AirTower_BlackHand(BuildingVisuals).LinkedAirstrip;
	}
	else
	{
		ForEach AllActors(class'S_Building_AirStrip_BlackHand',strip)
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
		AirstripInternals = S_Building_AirStrip_Internals_BlackHand(beststrip.BuildingInternals);

}

DefaultProperties
{
	TeamID = TEAM_GDI
	FriendlyBuildingSounds(BuildingDestroyed)           = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_AirStripDestroyed'
	FriendlyBuildingSounds(BuildingUnderAttack)         = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_AirStripUnderAttack'
	FriendlyBuildingSounds(BuildingRepaired)            = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_AirStripRepaired'
	EnemyBuildingSounds(BuildingDestroyed)              = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_EnemyAirStripDestroyed'
	EnemyBuildingSounds(BuildingUnderAttack)            = SoundNodeWave'S_EVA_VoiceClips.S_CABAL_EnemyAirStripUnderAttack'

	AttachmentClasses.Remove(Rx_BuildingAttachment_Door_Nod)	
	AttachmentClasses.Add(S_BuildingAttachment_Door_BH)
}