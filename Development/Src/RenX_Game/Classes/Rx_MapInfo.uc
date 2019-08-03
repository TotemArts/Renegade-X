class Rx_MapInfo extends UTMapInfo;

enum TheaterType
{
	THEATER_NORMAL,
	THEATER_FORESTA,
	THEATER_FORESTB,
	THEATER_SNOW,
	THEATER_DESERT,
	THEATER_URBAN,
	THEATER_CUSTOM
};

enum BotType
{
	Waypoints<ToolTip=Older>,
	NavMesh<ToolTip=Newer - In Alpha>
};

var(RenegadeX_Map_Properties) bool bAircraftDisabled;
var(RenegadeX_Map_Properties) bool bIsDeathmatchMap;
var(RenegadeX_Map_Properties) TheaterType Theater;
var(RenegadeX_Globals) float GlobalParticleValue;
var(RenegadeX_Globals) float GlobalSecondaryParticleValue;
var(RenegadeX_Globals) float GlobalStealthAddTranslucencyBias;
var(RenegadeX_Globals) float GlobalStealthEffectMultiplier;
var(RenegadeX_Globals) float GlobalStealthVisibilityMultiplier;
var(RenegadeX_Characters) float CharacterGdiBrightness;
var(RenegadeX_Characters) float CharacterNodBrightness;
var(RenegadeX_Characters) LinearColor CharacterReflection;
var(RenegadeX_Characters) TextureCube CharacterReflectionTexture;
var(RenegadeX_Characters) float CharacterShadowBoundsScale;
var(RenegadeX_Characters) array<class<Rx_FamilyInfo> > GDIInfantryArray, NodInfantryArray; //Allow custom infantry lists per map
var(RenegadeX_Vehicles) array<class<Rx_Vehicle_PTInfo> > GDIVehicleArray, NodVehicleArray; //Allow custom vehicle lists per map
var(RenegadeX_Vehicles) float VehicleGdiBrightness;
var(RenegadeX_Vehicles) float VehicleNodBrightness;
var(RenegadeX_Vehicles) LinearColor VehicleReflection;
var(RenegadeX_Vehicles) TextureCube VehicleReflectionTexture;
var(RenegadeX_Vehicles) float HarvesterHarvestTimeMultiplier;
var(RenegadeX_Vehicles) float GroundVehicleShadowBoundsScale;
var(RenegadeX_Vehicles) float AirVehicleShadowBoundsScale;
var(RenegadeX_Vehicles) LinearColor GdiCamoColour, NodCamoColour;
var(RenegadeX_Globals) float NightVisionMultiplier;
var(RenegadeX_Globals) float NightVisionContrast;
var(RenegadeX_Map_Properties) int MinimapTextureScale;
var(RenegadeX_Map_Properties) int NumCratesToBeActive;
var(RenegadeX_Map_Properties) float SoftLevelBoundaryCornerTimeThreshold;
var(RenegadeX_Map_Properties) float NodAirstripDropoffHeightOffset;
var(RenegadeX_Map_Properties) int MinNumPlayers;
var(RenegadeX_Map_Properties) int VehicleLimit;
var(RenegadeX_Map_Properties) int MineLimit;
var(RenegadeX_Map_Properties) float AirStrikeCoolDown;
var(RenegadeX_Map_Properties) float BaseCreditsPerTick;
var(RenegadeX_Map_Properties) BotType MapBotType<ToolTip=The class of bot to use on the map. Navmesh is newer but in alpha.>;
var(RenegadeX_Map_Properties) bool DisableMusicAutoPlay<ToolTip=Dont play music automatically when the map starts>;
var(RenegadeX_OutOfBounds) bool EnablePostProcessing;
var(RenegadeX_OutOfBounds) float SceneDesaturation;
var(RenegadeX_OutOfBounds) float SceneTonemapperScale;
var(RenegadeX_OutOfBounds) float SceneInterpolationDuration;

var int MinimapRadius;
var int MinimapCurrentZoom;
var int MinimapNormalZoom;

var(RenegadeX_Map_Properties) int OverviewScale; 

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
	GdiCamoColour=(R=1,G=1,B=1,A=1)
	NodCamoColour=(R=1,G=1,B=1,A=1)
	HarvesterHarvestTimeMultiplier = 1.0
	NightVisionMultiplier=200.0;
	NightVisionContrast=2.0;
	MinimapTextureScale=128;
	NumCratesToBeActive=2;
	SoftLevelBoundaryCornerTimeThreshold=0.0;
	MinimapCurrentZoom=32;
	MinimapNormalZoom=44;
	MinimapRadius=124;
	OverviewScale=1
	NodAirstripDropoffHeightOffset=0
	VehicleLimit=8
	MineLimit=24
	AirStrikeCoolDown=30
	GroundVehicleShadowBoundsScale=0.12
	AirVehicleShadowBoundsScale=0.35
	CharacterShadowBoundsScale=0.2
	BaseCreditsPerTick=0.5
	DisableMusicAutoPlay=false;
	MapBotType=Waypoints;
	SceneDesaturation=1.0;
	SceneTonemapperScale=0.2;
	SceneInterpolationDuration=1.0;
	EnablePostProcessing=true;
	
	GDIVehicleArray[0]   = class'RenX_Game.Rx_Vehicle_GDI_Humvee_PTInfo'
	GDIVehicleArray[1]   = class'RenX_Game.Rx_Vehicle_GDI_APC_PTInfo'
	GDIVehicleArray[2]  = class'RenX_Game.Rx_Vehicle_GDI_MRLS_PTInfo'
	GDIVehicleArray[3]   = class'RenX_Game.Rx_Vehicle_GDI_MediumTank_PTInfo'
	GDIVehicleArray[4]   = class'RenX_Game.Rx_Vehicle_GDI_MammothTank_PTInfo'
	GDIVehicleArray[5]   = class'RenX_Game.Rx_Vehicle_GDI_Chinook_PTInfo'
	GDIVehicleArray[6]   = class'RenX_Game.Rx_Vehicle_GDI_Orca_PTInfo'
	
	NodVehicleArray[0]   = class'RenX_Game.Rx_Vehicle_Nod_Buggy_PTInfo'
	NodVehicleArray[1]   = class'RenX_Game.Rx_Vehicle_Nod_APC_PTInfo'
	NodVehicleArray[2]   = class'RenX_Game.Rx_Vehicle_Nod_Artillery_PTInfo'
	NodVehicleArray[3]   = class'RenX_Game.Rx_Vehicle_Nod_FlameTank_PTInfo'
	NodVehicleArray[4]  = class'RenX_Game.Rx_Vehicle_Nod_LightTank_PTInfo'
	NodVehicleArray[5]   = class'RenX_Game.Rx_Vehicle_Nod_StealthTank_PTInfo'
	NodVehicleArray[6]   = class'RenX_Game.Rx_Vehicle_Nod_Chinook_PTInfo'
	NodVehicleArray[7]  = class'RenX_Game.Rx_Vehicle_Nod_Apache_PTInfo'
	
	GDIInfantryArray[0]  = class'Rx_FamilyInfo_GDI_Soldier'	
	GDIInfantryArray[1]  = class'Rx_FamilyInfo_GDI_Shotgunner'
	GDIInfantryArray[2]  = class'Rx_FamilyInfo_GDI_Grenadier'
	GDIInfantryArray[3]  = class'Rx_FamilyInfo_GDI_Marksman'
	GDIInfantryArray[4]  = class'Rx_FamilyInfo_GDI_Engineer'
	GDIInfantryArray[5]  = class'Rx_FamilyInfo_GDI_Officer'
	GDIInfantryArray[6]  = class'Rx_FamilyInfo_GDI_RocketSoldier'
	GDIInfantryArray[7]  = class'Rx_FamilyInfo_GDI_McFarland'
	GDIInfantryArray[8]  = class'Rx_FamilyInfo_GDI_Deadeye'
	GDIInfantryArray[9]  = class'Rx_FamilyInfo_GDI_Gunner'
	GDIInfantryArray[10] = class'Rx_FamilyInfo_GDI_Patch'
	GDIInfantryArray[11] = class'Rx_FamilyInfo_GDI_Havoc'
	GDIInfantryArray[12] = class'Rx_FamilyInfo_GDI_Sydney'
	GDIInfantryArray[13] = class'Rx_FamilyInfo_GDI_Mobius'
	GDIInfantryArray[14] = class'Rx_FamilyInfo_GDI_Hotwire'
	
	NodInfantryArray[0]  = class'Rx_FamilyInfo_Nod_Soldier'
	NodInfantryArray[1]  = class'Rx_FamilyInfo_Nod_Shotgunner'
	NodInfantryArray[2]  = class'Rx_FamilyInfo_Nod_FlameTrooper'
	NodInfantryArray[3]  = class'Rx_FamilyInfo_Nod_Marksman'
	NodInfantryArray[4]  = class'Rx_FamilyInfo_Nod_Engineer'
	NodInfantryArray[5]  = class'Rx_FamilyInfo_Nod_Officer'
	NodInfantryArray[6]  = class'Rx_FamilyInfo_Nod_RocketSoldier'	
	NodInfantryArray[7]  = class'Rx_FamilyInfo_Nod_ChemicalTrooper'
	NodInfantryArray[8]  = class'Rx_FamilyInfo_Nod_blackhandsniper'
	NodInfantryArray[9]  = class'Rx_FamilyInfo_Nod_Stealthblackhand'
	NodInfantryArray[10] = class'Rx_FamilyInfo_Nod_LaserChainGunner'
	NodInfantryArray[11] = class'Rx_FamilyInfo_Nod_Sakura'		
	NodInfantryArray[12] = class'Rx_FamilyInfo_Nod_Raveshaw'//_Mutant'
	NodInfantryArray[13] = class'Rx_FamilyInfo_Nod_Mendoza'
	NodInfantryArray[14] = class'Rx_FamilyInfo_Nod_Technician'
}
