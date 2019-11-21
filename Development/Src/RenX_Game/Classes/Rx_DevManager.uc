class Rx_DevManager extends Object;

struct Developer
{
	var string SteamID;
	var Texture2D FlagTexture;
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

DefaultProperties
{
	DefaultFlagTexture = Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_RenX'

	Developers(0)=(SteamID="0x0110000104F6DF15",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_Handepsilon')
	Developers(1)=(SteamID="0x01100001027D810B",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_Havoc89')
	Developers(2)=(SteamID="0x01100001022ABF16",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_Kenz')
	Developers(3)=(SteamID="0x0110000108C01817",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_Sarah')
	Developers(4)=(SteamID="0x011000010312CEAA",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_Yosh')
	Developers(5)=(SteamID="0x01100001129759DD",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_TK')
	Developers(6)=(SteamID="0x0110000107CAD64F",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_Fobby')
	Developers(7)=(SteamID="0x0110000104AE0666",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_Agent')
	Developers(8)=(SteamID="0x0110000103299B73",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_Freak')
	Developers(9)=(SteamID="0x0110000108C77076",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_Henk')
	//DevFlags(10)=(SteamID="0x00",FlagTexture=Texture2D'RX_Deco_Flag.banner.Texture.T_Banner_RenX')
}