class Rx_VictoryMessage extends UTVictoryMessage;

var SoundNodeWave VictoryAnnouncements[4];

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{
	return Default.VictoryAnnouncements[MessageIndex];
}

DefaultProperties
{
	bIsConsoleMessage=true

	VictoryAnnouncements(0)=SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_MissionAccomplished'
	VictoryAnnouncements(1)=SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_MissionAccomplished'
	VictoryAnnouncements(2)=SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_MissionFailed'
	VictoryAnnouncements(3)=SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_MissionFailed'
	MessageArea=2
}
