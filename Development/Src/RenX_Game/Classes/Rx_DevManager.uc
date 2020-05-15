class Rx_DevManager extends Object;

struct Developer
{
	var string SteamID;
	var Texture2D FlagTexture;
	var SoundCue HornSound; 
};

var const array<Developer> Developers;
var const Texture2D DefaultFlagTexture;

static function bool IsDev(string SteamID)
{
	return default.Developers.Find('SteamID', SteamID) >= 0;
}

static function Texture2D GetFlagTexture(string SteamID, bool bIsDev)
{
	local int i;
	i = default.Developers.Find('SteamID', SteamID);

	if (i >= 0)
		return default.Developers[i].FlagTexture;
	else if (bIsDev) // Remove this and line below to remove default texture for all devs
		return default.DefaultFlagTexture;

	return None;
}

static function SoundCue GetHornSound(string SteamID, bool bIsDev, SoundCue DefaultHornSound)
{
	local int i;

	i = default.Developers.Find('SteamID', SteamID);

	if (i >= 0 && default.Developers[i].HornSound != none)
		return default.Developers[i].HornSound;

	return DefaultHornSound;
}

DefaultProperties
{
	DefaultFlagTexture = Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_RenX'

	Developers(0)=(SteamID="0x0110000104F6DF15",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_Handepsilon')
	Developers(1)=(SteamID="0x01100001027D810B",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_Havoc89', HornSound=SoundCue'RX_SoundEffects.RX_VH_Horns.SN_Horn_Havoc89_Cue')
	Developers(2)=(SteamID="0x01100001022ABF16",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_Kenz', HornSound=SoundCue'RX_SoundEffects.RX_VH_Horns.SN_Horn_Kenz_Cue')
	Developers(3)=(SteamID="0x0110000108C01817",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_Sarah')
	Developers(4)=(SteamID="0x011000010312CEAA",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_Yosh',HornSound=SoundCue'RX_SoundEffects.RX_VH_Horns.SN_Horn_Yosh_Cue')
	Developers(5)=(SteamID="0x01100001129759DD",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_TK', HornSound=SoundCue'RX_SoundEffects.RX_VH_Horns.SN_Horn_TK_Cue')
	Developers(6)=(SteamID="0x0110000107CAD64F",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_Fobby')
	Developers(7)=(SteamID="0x0110000104AE0666",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_Agent')
	Developers(8)=(SteamID="0x0110000103299B73",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_Freak', HornSound=SoundCue'RX_SoundEffects.RX_VH_Horns.SN_Horn_fffreak_Cue')
	Developers(9)=(SteamID="0x0110000108C77076",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_Henk', HornSound=SoundCue'RX_SoundEffects.RX_VH_Horns.SN_Horn_Henk_Cue')
	Developers(10)=(SteamID="0x0110000117E950EC",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_Bruno', HornSound=SoundCue'RX_SoundEffects.RX_VH_Horns.SN_Horn_Bruno_Cue')
	Developers(11)=(SteamID="0x01100001055A48CF",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_SMaywho')
	Developers(12)=(SteamID="0x011000010646AA9C",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_SgtIgram', HornSound=SoundCue'RX_SoundEffects.RX_VH_Horns.SN_Horn_SgtIgram_Cue')
	Developers(13)=(SteamID="0x01100001098F1C63",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_Nexus', HornSound=SoundCue'RX_SoundEffects.RX_VH_Horns.SN_Horn_Nexus_Cue')
	Developers(14)=(SteamID="0x0110000138C15A9F",FlagTexture=Texture2D'Rx_Deco_Flag.banner.Texture.T_Banner_HIHIHI')
	Developers(15)=(SteamID="0x01100001028434CE",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_Shrewd', HornSound=SoundCue'RX_SoundEffects.RX_VH_Horns.SN_Horn_Shrewd_Cue')
	//DevFlags(10)=(SteamID="0x00",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_RenX')
}
