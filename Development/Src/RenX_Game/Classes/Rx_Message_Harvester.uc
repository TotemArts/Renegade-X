class Rx_Message_Harvester extends UTLocalMessage;

var array<SoundNodeWave>	HarvesterAttackAnnouncment;

static function ClientReceive( PlayerController P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
								optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	local int imsg;

	imsg = -1;

	if ( P.GetTeamNum() == TEAM_GDI )
	{
		if(RelatedPRI_1.GetTeamNum() == TEAM_GDI && Switch == 0) // GDI Harv under attack 
			imsg = 0;
		else if(RelatedPRI_1.GetTeamNum() == TEAM_NOD && Switch == 0) // Nod Harv under attack 
			imsg = 1;
		else if(RelatedPRI_1.GetTeamNum() == TEAM_GDI && Switch == 1) //GDI Harv destroyed 
			imsg = 4;
		else if(RelatedPRI_1.GetTeamNum() == TEAM_NOD && Switch == 1) //Nod Harv destroyed
			imsg = 5;
	}
	else if ( P.GetTeamNum() == TEAM_NOD )
	{
		if(RelatedPRI_1.GetTeamNum() == TEAM_GDI && Switch == 0) //GDI Harv under attack 
			imsg = 2;
		else if(RelatedPRI_1.GetTeamNum() == TEAM_NOD && Switch == 0) //Nod Harv destroyed 
			imsg = 3;
		else if(RelatedPRI_1.GetTeamNum() == TEAM_GDI && Switch == 1) //GDI Harv destroyed 
			imsg = 6;
		else if(RelatedPRI_1.GetTeamNum() == TEAM_NOD && Switch == 1) //Nod Harv destroyed 
			imsg = 7;
	}

	if(imsg != -1)
		UTPlayerController(P).PlayAnnouncement(default.Class,imsg);
}

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{	
	return default.HarvesterAttackAnnouncment[MessageIndex];
}

static function byte AnnouncementLevel(byte MessageIndex)
{
	return 1;
}

DefaultProperties
{
	HarvesterAttackAnnouncment[0]   = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_GDIHarvester_UnderAttack'
	HarvesterAttackAnnouncment[1]   = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_NodHarvester_UnderAttack'
	HarvesterAttackAnnouncment[2]  = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_GDIHarvester_UnderAttack'
	HarvesterAttackAnnouncment[3]   = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodHarvester_UnderAttack'

	HarvesterAttackAnnouncment[4]   = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_GDIHarvester_Destroyed'
	HarvesterAttackAnnouncment[5]   = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_NodHarvester_Destroyed'
	HarvesterAttackAnnouncment[6]   = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_GDIHarvester_Destroyed'
	HarvesterAttackAnnouncment[7]   = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodHarvester_Destroyed'

	AnnouncementVolume=5.0
}
