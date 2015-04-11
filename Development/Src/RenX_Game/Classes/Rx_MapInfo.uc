class Rx_MapInfo extends UTMapInfo;

var(RenegadeX_Map_Properties) bool bAircraftDisabled;
var(RenegadeX_Map_Properties) bool bIsDeathmatchMap;
var(RenegadeX_Globals) float GlobalParticleValue;
var(RenegadeX_Globals) float GlobalSecondaryParticleValue;
var(RenegadeX_Globals) float GlobalStealthAddTranslucencyBias;
var(RenegadeX_Globals) float GlobalStealthEffectMultiplier;
var(RenegadeX_Globals) float GlobalStealthVisibilityMultiplier;
var(RenegadeX_Characters) float CharacterGdiBrightness;
var(RenegadeX_Characters) float CharacterNodBrightness;
var(RenegadeX_Characters) LinearColor CharacterReflection;
var(RenegadeX_Characters) TextureCube CharacterReflectionTexture;
var(RenegadeX_Vehicles) float VehicleGdiBrightness;
var(RenegadeX_Vehicles) float VehicleNodBrightness;
var(RenegadeX_Vehicles) LinearColor VehicleReflection;
var(RenegadeX_Vehicles) TextureCube VehicleReflectionTexture;
var(RenegadeX_Globals) float NightVisionMultiplier;
var(RenegadeX_Globals) float NightVisionContrast;
var(RenegadeX_Map_Properties) int MinimapTextureScale;
var(RenegadeX_Map_Properties) int NumCratesToBeActive;
var int MinimapRadius;
var int MinimapCurrentZoom;
var int MinimapNormalZoom;

DefaultProperties
{
	bAircraftDisabled=True
	GlobalParticleValue=1.0;
	GlobalSecondaryParticleValue=1.0;
	GlobalStealthAddTranslucencyBias=0.0;
	GlobalStealthEffectMultiplier=1.0;
	GlobalStealthVisibilityMultiplier=1.0;
	CharacterGdiBrightness=1.0
	CharacterNodBrightness=1.0
	CharacterReflection=(R=1,G=1,B=1,A=1)
	CharacterReflectionTexture=TextureCube'WP_All.Materials.M_WP_All_EnvMap01'
	VehicleGdiBrightness=1.0
	VehicleNodBrightness=1.0
	VehicleReflection=(R=1,G=1,B=1,A=1)
	VehicleReflectionTexture=TextureCube'WP_All.Materials.M_WP_All_EnvMap01'
	NightVisionMultiplier=200.0;
	NightVisionContrast=2.0;
	MinimapTextureScale=128;
	NumCratesToBeActive=2;
	MinimapCurrentZoom=32;
	MinimapNormalZoom=44;
	MinimapRadius=124;
}
