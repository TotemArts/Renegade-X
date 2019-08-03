class Rx_Message_VehicleProduced extends UTLocalMessage;

//var array<SoundNodeWave> GDIVehicleAnnouncments;
//var array<SoundNodeWave> NodVehicleAnnouncments;

var SoundNodeWave	GDIHarvesterAnnouncment, NodHarvesterAnnouncment; 

static function ClientReceive( PlayerController P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
								optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	UTPlayerController(P).PlayAnnouncement(default.Class,Switch,RelatedPRI_1,OptionalObject);
}

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{	
	local Rx_PurchaseSystem RxPS; 
	
	if(Rx_PurchaseSystem(OptionalObject) != none)
		RxPS = Rx_PurchaseSystem(OptionalObject);
	else
		return none; 
	
	
	if ( PC.GetTeamNum() == TEAM_GDI )
	{
		if(MessageIndex == 254)
			return default.GDIHarvesterAnnouncment;
		else
			return RxPS.GDIVehicleClasses[MessageIndex].default.GDIVehicleAnnouncment;
	}
	else if ( PC.GetTeamNum() == TEAM_NOD )
	{
		if(MessageIndex == 255)
			return default.NodHarvesterAnnouncment;
		else
			return RxPS.NodVehicleClasses[MessageIndex].default.NodVehicleAnnouncment;
	}
	return none;
}
static function byte AnnouncementLevel(byte MessageIndex)
{
	return 1;
}


DefaultProperties
{
	
	GDIHarvesterAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_Harvester' ; 
	NodHarvesterAnnouncment = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_Harvester' ; 
	
	/**
	/DEPRECATED (too static)
	
	GDIVehicleAnnouncments[0]   = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_Humvee'
	GDIVehicleAnnouncments[1]   = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_APC'
	GDIVehicleAnnouncments[2]   = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_MRLS'
	GDIVehicleAnnouncments[3]   = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_MediumTank'
	GDIVehicleAnnouncments[4]   = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_MammothTank'
	GDIVehicleAnnouncments[5]   = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_TransportHelicopter'
	GDIVehicleAnnouncments[6]   = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_Orca'
	GDIVehicleAnnouncments[7]   = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_UnitReady_Harvester'

	NodVehicleAnnouncments[0]   = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_Buggy'
	NodVehicleAnnouncments[1]   = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_APC'
	NodVehicleAnnouncments[2]   = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_Artillery'
	NodVehicleAnnouncments[3]   = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_FlameTank'
	NodVehicleAnnouncments[4]   = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_LightTank'
	NodVehicleAnnouncments[5]   = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_StealthTank'
	NodVehicleAnnouncments[6]   = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_TransportHelicopter'
	NodVehicleAnnouncments[7]   = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_Apache'
	NodVehicleAnnouncments[8]   = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_UnitReady_Harvester'
	*/
	AnnouncementVolume=5.0
}
