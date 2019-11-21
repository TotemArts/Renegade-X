class Rx_GRI extends UTGameReplicationInfo;
  
`define MapVoteMaxSize 9

var Rx_VehicleManager VehManager;
var Rx_ORI ObjectiveManager; 
var byte WinnerTeamNum;
var bool WinBySurrender;
var String WinnerReason;
var int MapVotes[`MapVoteMaxSize];
var string MapVoteList[`MapVoteMaxSize];
var int MapVoteIndexMapping[`MapVoteMaxSize];
var array<MaterialInstanceConstant> GlobalParticleMIC;
var MaterialInstanceConstant NightVisionMIC;
var MaterialInstanceConstant GlobalStealthAddTranslucencyBiasMIC;
var MaterialInstanceConstant GlobalStealthEffectMultiplierMIC;
var MaterialInstanceConstant GlobalStealthVisibilityMultiplierMIC;
var MaterialInstanceConstant CharacterGdiBrightnessMIC;
var MaterialInstanceConstant CharacterNodBrightnessMIC;
var MaterialInstanceConstant CharacterReflectionMIC;
var MaterialInstanceConstant CharacterReflectionTextureMIC;
var MaterialInstanceConstant VehicleGdiBrightnessMIC;
var MaterialInstanceConstant VehicleGdiAdaptiveBrightnessMIC;
var MaterialInstanceConstant VehicleNodBrightnessMIC;
var MaterialInstanceConstant VehicleNodAdaptiveBrightnessMIC;
var MaterialInstanceConstant VehicleReflectionMIC;
var MaterialInstanceConstant VehicleAdaptiveReflectionMIC;
var MaterialInstanceConstant VehicleReflectionTextureMIC;
var MaterialInstanceConstant VehicleCloakCamoMIC;
var int MaxActiveEmitters;
var Rx_PurchaseSystem PurchaseSystem;
var int MapVotesSize;
var float RenEndTime;
var string NextMap;
var int buildingArmorPercentage;
var string MVP[2], BestOP[2], BestDP[2], BestSP[2];
var bool bPureServer;
var bool bEnableCommanders;
var bool bEnableBotVotes;
var bool bEnableNuke;

var array<class<Rx_StatModifierInfo> >		StatClasses; 
var array<MaterialInstanceConstant> CustomWeaponMICs; 

var array<Actor> SpottingArray; //Array of spot locations on the map
var array<Actor> TechBuildingArray; //Array to hold map tech buildings (Optimization to reduce constantly iterating 'AllActors')

replication
{
	if (bNetDirty)
		WinnerTeamNum,WinnerReason,MapVotes,PurchaseSystem,MapVoteList,NextMap,buildingArmorPercentage, WinBySurrender, MVP, BestOP, BestDP, BestSP, bEnableCommanders, bEnableBotVotes, bEnableNuke;
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	if(WorldInfo.Netmode != NM_Client && Rx_Game(WorldInfo.Game).UsePurchaseSystem)
		SetTimer(1.0f,false,'GetPurchaseSystem');

	switch (Rx_MapInfo(WorldInfo.GetMapInfo()).Theater)
	{
	case THEATER_NORMAL:
		VehicleGdiAdaptiveBrightnessMIC.SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_GDI_Default');
		VehicleNodAdaptiveBrightnessMIC.SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_Nod_Default');
		VehicleCloakCamoMIC.SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_Nod_Default');
		break;

	case THEATER_FORESTA:
		VehicleGdiAdaptiveBrightnessMIC.SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_GDI_Forest');
		VehicleNodAdaptiveBrightnessMIC.SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_Nod_Forest');
		VehicleCloakCamoMIC.SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_Nod_Forest');
		break;


	case THEATER_FORESTB:
		VehicleGdiAdaptiveBrightnessMIC.SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_GDI_ForestB');
		VehicleNodAdaptiveBrightnessMIC.SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_Nod_ForestB');
		VehicleCloakCamoMIC.SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_Nod_ForestB');
		break;

	case THEATER_SNOW:
		VehicleGdiAdaptiveBrightnessMIC.SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_GDI_Arctic');
		VehicleNodAdaptiveBrightnessMIC.SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_Nod_Arctic');
		VehicleCloakCamoMIC.SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_Nod_Arctic');
		break;

	case THEATER_DESERT:
		VehicleGdiAdaptiveBrightnessMIC.SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_GDI_Desert');
		VehicleNodAdaptiveBrightnessMIC.SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_Nod_Desert');
		VehicleCloakCamoMIC.SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_Nod_Desert');
		break;

	case THEATER_URBAN:
		VehicleGdiAdaptiveBrightnessMIC.SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_GDI_Urban');
		VehicleNodAdaptiveBrightnessMIC.SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_Nod_Urban');
		VehicleCloakCamoMIC.SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_Nod_Urban');
		break;

	case THEATER_CUSTOM:
		VehicleGdiAdaptiveBrightnessMIC.SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_GDI_Custom');
		VehicleNodAdaptiveBrightnessMIC.SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_Nod_Custom');
		VehicleCloakCamoMIC.SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_Nod_Urban');
		break;

	}

	VehicleGdiAdaptiveBrightnessMIC.SetVectorParameterValue('Camo_Colour', Rx_MapInfo(WorldInfo.GetMapInfo()).GdiCamoColour);
	VehicleNodAdaptiveBrightnessMIC.SetVectorParameterValue('Camo_Colour', Rx_MapInfo(WorldInfo.GetMapInfo()).NodCamoColour);
	VehicleCloakCamoMIC.SetVectorParameterValue('Camo_Colour', Rx_MapInfo(WorldInfo.GetMapInfo()).NodCamoColour);
	
	CreateListArrays();
	/**if(WorldInfo.Netmode == NM_Client || WorldInfo.Netmode == NM_Standalone)
		SetTimer(1.0f,true,'FindORI'); */
}

simulated function array<Rx_UIDataProvider_MapInfo> GetMapDataProviderList()
{
	local array<UDKUIResourceDataProvider> ProviderList; 
	local array<Rx_UIDataProvider_MapInfo> MapDataList;
	local int i;

	// make sure default map exists
	class'UTUIDataStore_MenuItems'.static.GetAllResourceDataProviders(class'Rx_UIDataProvider_MapInfo', ProviderList);
	
	//hack until we solve the sorting issue
	for (i = ProviderList.length - 1; i >= 0; i--)
	{		
		if (Rx_UIDataProvider_MapInfo(ProviderList[i]) == none) {
			`log("NONE - ProviderList[i]? " $ Rx_UIDataProvider_MapInfo(ProviderList[i]).MapName);
			continue;
		}
		MapDataList.AddItem(Rx_UIDataProvider_MapInfo(ProviderList[i]));
	} 
	if (MapDataList.Length > 0) {
		MapDataList.Sort(MapListSort);
	} 
	return MapDataList;

}

delegate int MapListSort(Rx_UIDataProvider_MapInfo A, Rx_UIDataProvider_MapInfo B) 
{
	return A.FriendlyName < B.FriendlyName ? 0 : -1;
}

function SetupEndMapVote(array<string> MapList, bool bScramble)
{
	local int i, random;

	MapVotesSize=0;
	for (i=0; i<`MapVoteMaxSize; ++i)
	{
		if (bScramble)
		{
			if (MapList.Length == 0)
				break;
			random = Rand(MapList.Length);
			if (MapVoteList[i] != MapList[random])
				MapVoteList[i] = MapList[random];
			MapList.Remove(random, 1);
		}
		else
		{
			if (i<MapList.Length)
				break;
			if (MapVoteList[i] != MapList[i])
				MapVoteList[i] = MapList[i];
		}
		++MapVotesSize;
	}
	while (i<`MapVoteMaxSize)
	{
		if (MapVoteList[i] != "")
			MapVoteList[i] = "";
		++i;
	}
}

function SetFixedNextMap(string MapName)
{
	NextMap = Mapname;

	MapVotesSize = 0;
}

function GetPurchaseSystem()
{
	PurchaseSystem = Rx_Game(WorldInfo.Game).GetPurchaseSystem();	
	buildingArmorPercentage = Rx_Game(WorldInfo.Game).buildingArmorPercentage;
	bEnableCommanders = Rx_Game(WorldInfo.Game).bEnableCommanders;
	
	if(Rx_Game(WorldInfo.Game).bBotsDisabled == true || Rx_Game(WorldInfo.Game).bBotVotesDisabled == true)
	{
		bEnableBotVotes = false;
	} else {
		bEnableBotVotes = true;
	}
}

function VehChangedTeam(UTVehicle rxVehicle) {
	Rx_Game(WorldInfo.Game).VehicleManager.vehChangedTeam(rxVehicle);
}

simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'bMatchHasBegun' )
	{
		if(bMatchHasBegun) {
			SetTimer(1.0, false, 'InitMICs');
		}		
	}
	super.ReplicatedEvent(VarName);
}

simulated function InitMICs()
{
	if(Rx_HUD(GetALocalPlayerController().myHUD).Scoreboard != None)
	{
		if (Rx_HUD(GetALocalPlayerController().myHUD).Scoreboard.bMovieIsOpen) {
			Rx_HUD(GetALocalPlayerController().myHUD).Scoreboard.Close(true);
		}
		Rx_HUD(GetALocalPlayerController().myHUD).Scoreboard = None;
	}
	GetNightVisionMIC();
	GetGlobalParticleMICList();
	SetGlobalStealthAddTranslucencyBias();
	SetGlobalStealthEffectMultiplier();
	SetGlobalStealthVisibilityMultiplier();
	UDKEmitterPool(WorldInfo.MyEmitterPool).MaxActiveEffects=MaxActiveEmitters;
	
	//Weapon Overlay Material setup
	SetupWeaponOverlays(); 
	CreateCustomRxWeaponOverlays();
	 
}

simulated function GetNightVisionMIC()
{
	local float NightVisionMultiplier;
	local float NightVisionContrast;

	NightVisionMultiplier = GetNightVisionMultiplier();
	NightVisionContrast = GetNightVisionContrast();
	if(NightVisionMIC != None)
	{
		NightVisionMIC.SetScalarParameterValue('NightVisionMultiplier', NightVisionMultiplier);
		NightVisionMIC.SetScalarParameterValue('NightVisionContrast', NightVisionContrast);
	}
}

simulated function GetGlobalParticleMICList()
{
	local int i;
	local float GlobalParticleValue;
	local float GlobalSecondaryParticleValue;

	GlobalParticleValue = GetGlobalParticleValue();
	GlobalSecondaryParticleValue = GetGlobalSecondaryParticleValue();
	for(i = 0; i < GlobalParticleMIC.Length; i++)
	{
		if(GlobalParticleMIC[i] != None)
		{
			GlobalParticleMIC[i].SetScalarParameterValue('GlobalParticleValue', GlobalParticleValue);
			GlobalParticleMIC[i].SetScalarParameterValue('GlobalSecondaryParticleValue', GlobalSecondaryParticleValue);
		}
	}
}

simulated function float GetNightVisionMultiplier()
{
	local Rx_MapInfo MapInfo;

	MapInfo = Rx_MapInfo(WorldInfo.GetMapInfo());
	if(MapInfo != None)
	{
		return MapInfo.NightVisionMultiplier;
	}
	else {
		return 200.0;
	}
}

simulated function float GetNightVisionContrast()
{
	local Rx_MapInfo MapInfo;

	MapInfo = Rx_MapInfo(WorldInfo.GetMapInfo());
	if(MapInfo != None)
	{
		return MapInfo.NightVisionContrast;
	}
	else
		return 2.0;
}

simulated function float GetGlobalParticleValue()
{
	local Rx_MapInfo MapInfo;

	MapInfo = Rx_MapInfo(WorldInfo.GetMapInfo());
	if(MapInfo != None)
	{
		return MapInfo.GlobalParticleValue;
	}
	else
		return 1.0;
}
 
simulated function float GetGlobalSecondaryParticleValue()
{
	local Rx_MapInfo MapInfo;

	MapInfo = Rx_MapInfo(WorldInfo.GetMapInfo());
	if(MapInfo != None)
	{
		return MapInfo.GlobalSecondaryParticleValue;
	}
	else
		return 1.0;
}

simulated function float GetGlobalStealthAddTranslucencyBias()
{
	local Rx_MapInfo MapInfo;

	MapInfo = Rx_MapInfo(WorldInfo.GetMapInfo());
	if(MapInfo != None)
	{
		return MapInfo.GlobalStealthAddTranslucencyBias;
	}
	else
		return 0.5;
}

simulated function SetGlobalStealthAddTranslucencyBias()
{
	local float GlobalStealthAddTranslucencyBias;

	GlobalStealthAddTranslucencyBias = GetGlobalStealthAddTranslucencyBias();
	if(GlobalStealthAddTranslucencyBiasMIC != None)
	{
		GlobalStealthAddTranslucencyBiasMIC.SetScalarParameterValue('AddTranslucent_Bias', GlobalStealthAddTranslucencyBias);
		VehicleCloakCamoMIC.SetScalarParameterValue('AddTranslucent_Bias', GlobalStealthAddTranslucencyBias);
	}
}

simulated function float GetGlobalStealthEffectMultiplier()
{
	local Rx_MapInfo MapInfo;

	MapInfo = Rx_MapInfo(WorldInfo.GetMapInfo());
	if(MapInfo != None)
	{
		return MapInfo.GlobalStealthEffectMultiplier;
	}
	else
		return 1.0;
}

simulated function SetGlobalStealthEffectMultiplier()
{
	local float GlobalStealthEffectMultiplier;

	GlobalStealthEffectMultiplier = GetGlobalStealthEffectMultiplier();
	if(GlobalStealthEffectMultiplierMIC != None)
	{
		GlobalStealthEffectMultiplierMIC.SetScalarParameterValue('Stealth_Effect_Multiplier', GlobalStealthEffectMultiplier);
		VehicleCloakCamoMIC.SetScalarParameterValue('Stealth_Effect_Multiplier', GlobalStealthEffectMultiplier);
	}
}

simulated function float GetGlobalStealthVisibilityMultiplier()
{
	local Rx_MapInfo MapInfo;

	MapInfo = Rx_MapInfo(WorldInfo.GetMapInfo());
	if(MapInfo != None)
	{
		return MapInfo.GlobalStealthVisibilityMultiplier;
	}
	else
		return 1.0;
}

simulated function SetGlobalStealthVisibilityMultiplier()
{
	local float GlobalStealthVisibilityMultiplier;

	GlobalStealthVisibilityMultiplier = GetGlobalStealthVisibilityMultiplier();
	if(GlobalStealthVisibilityMultiplierMIC != None)
	{
		GlobalStealthVisibilityMultiplierMIC.SetScalarParameterValue('Stealth_Visibility_Multiplier', GlobalStealthVisibilityMultiplier);
		VehicleCloakCamoMIC.SetScalarParameterValue('Stealth_Visibility_Multiplier', GlobalStealthVisibilityMultiplier);
	}
}

/**
  *  Update Character global parameters
 **/

simulated function float GetCharacterGdiBrightness()
{
	local Rx_MapInfo MapInfo;

	MapInfo = Rx_MapInfo(WorldInfo.GetMapInfo());
	if(MapInfo != None)
	{
		return MapInfo.CharacterGdiBrightness;
	}
	else
		return 1.0;
}

simulated function SetCharacterGdiBrightness()
{
	local float CharacterGdiBrightness;

	CharacterGdiBrightness = GetCharacterGdiBrightness();
	if(CharacterGdiBrightnessMIC != None)
	{
		CharacterGdiBrightnessMIC.SetScalarParameterValue('GlobalCharacterBrightness', CharacterGdiBrightness);
	}
}

simulated function float GetCharacterNodBrightness()
{
	local Rx_MapInfo MapInfo;

	MapInfo = Rx_MapInfo(WorldInfo.GetMapInfo());
	if(MapInfo != None)
	{
		return MapInfo.CharacterNodBrightness;
	}
	else
		return 1.0;
}

simulated function SetCharacterNodBrightness()
{
	local float CharacterNodBrightness;

	CharacterNodBrightness = GetCharacterNodBrightness();
	if(CharacterNodBrightnessMIC != None)
	{
		CharacterNodBrightnessMIC.SetScalarParameterValue('GlobalCharacterBrightness', CharacterNodBrightness);
	}
}

simulated function LinearColor GetCharacterReflection()
{
	local Rx_MapInfo MapInfo;

	MapInfo = Rx_MapInfo(WorldInfo.GetMapInfo());
	if(MapInfo != None)
	{
		return MapInfo.CharacterReflection;
	}
	else
		return MakeLinearColor(1,1,1,1);
}

simulated function SetCharacterReflection()
{
	local LinearColor CharacterReflection;

	CharacterReflection = GetCharacterReflection();
	if(CharacterReflectionMIC != None)
	{
		CharacterReflectionMIC.SetVectorParameterValue('Reflection_Colour', CharacterReflection);
	}
}

simulated function TextureCube GetCharacterReflectionTexture()
{
	local Rx_MapInfo MapInfo;

	MapInfo = Rx_MapInfo(WorldInfo.GetMapInfo());
	if(MapInfo != None)
	{
		return MapInfo.CharacterReflectionTexture;
	}
	else
		return TextureCube'WP_All.Materials.M_WP_All_EnvMap01';
}

simulated function SetCharacterReflectionTexture()
{
	local TextureCube CharacterReflectionTexture;

	CharacterReflectionTexture = GetCharacterReflectionTexture();
	if(CharacterReflectionTextureMIC != None)
	{
		CharacterReflectionTextureMIC.SetTextureParameterValue('CubeMap_Exterior', CharacterReflectionTexture);
	}
}

/**
  *  Update Vehicle global parameters
 **/


simulated function float GetVehicleGdiBrightness()
{
	local Rx_MapInfo MapInfo;

	MapInfo = Rx_MapInfo(WorldInfo.GetMapInfo());
	if(MapInfo != None)
	{
		return MapInfo.VehicleGdiBrightness;
	}
	else
		return 1.0;
}

simulated function SetVehicleGdiBrightness()
{
	local float VehicleGdiBrightness;

	VehicleGdiBrightness = GetVehicleGdiBrightness();
	if(VehicleGdiBrightnessMIC != None)
	{
		VehicleGdiBrightnessMIC.SetScalarParameterValue('GlobalVehicleBrightness', VehicleGdiBrightness);
		VehicleGdiAdaptiveBrightnessMIC.SetScalarParameterValue('GlobalVehicleBrightness', VehicleGdiBrightness);
	}
}

simulated function float GetVehicleNodBrightness()
{
	local Rx_MapInfo MapInfo;

	MapInfo = Rx_MapInfo(WorldInfo.GetMapInfo());
	if(MapInfo != None)
	{
		return MapInfo.VehicleNodBrightness;
	}
	else
		return 1.0;
}

simulated function SetVehicleNodBrightness()
{
	local float VehicleNodBrightness;

	VehicleNodBrightness = GetVehicleNodBrightness();
	if(VehicleNodBrightnessMIC != None)
	{
		VehicleNodBrightnessMIC.SetScalarParameterValue('GlobalVehicleBrightness', VehicleNodBrightness);
		VehicleNodAdaptiveBrightnessMIC.SetScalarParameterValue('GlobalVehicleBrightness', VehicleNodBrightness);
	}
}

simulated function LinearColor GetVehicleReflection()
{
	local Rx_MapInfo MapInfo;

	MapInfo = Rx_MapInfo(WorldInfo.GetMapInfo());
	if(MapInfo != None)
	{
		return MapInfo.VehicleReflection;
	}
	else
		return MakeLinearColor(1,1,1,1);
}

simulated function SetVehicleReflection()
{
	local LinearColor VehicleReflection;

	VehicleReflection = GetVehicleReflection();
	if(VehicleReflectionMIC != None)
	{
		VehicleReflectionMIC.SetVectorParameterValue('Reflection_Colour', VehicleReflection);
		VehicleAdaptiveReflectionMIC.SetVectorParameterValue('Reflection_Colour', VehicleReflection);
	}
}

simulated function TextureCube GetVehicleReflectionTexture()
{
	local Rx_MapInfo MapInfo;

	MapInfo = Rx_MapInfo(WorldInfo.GetMapInfo());
	if(MapInfo != None)
	{
		return MapInfo.VehicleReflectionTexture;
	}
	else
		return TextureCube'WP_All.Materials.M_WP_All_EnvMap01';
}

simulated function SetVehicleReflectionTexture()
{
	local TextureCube VehicleReflectionTexture;

	VehicleReflectionTexture = GetVehicleReflectionTexture();
	if(VehicleReflectionTextureMIC != None)
	{
		VehicleReflectionTextureMIC.SetTextureParameterValue('CubeMap_Exterior', VehicleReflectionTexture);
		VehicleAdaptiveReflectionMIC.SetTextureParameterValue('CubeMap_Exterior', VehicleReflectionTexture);
	}
}


   
/**
  * returns true if P1 should be sorted before P2
  */
simulated function bool InOrder( PlayerReplicationInfo P1, PlayerReplicationInfo P2 )
{
	// spectators are sorted last
   if( P1.bOnlySpectator )
   {
	   return P2.bOnlySpectator;
   }
   else if ( P2.bOnlySpectator )
	{
		return true;
	}

   // sort out bots
   if (P1.bBot)
   {
      return P2.bBot;
   }
   else if (P2.bBot)
   {
      return true;
   }
   
	// sort by Score
   if( P1.Score < P2.Score )
	{
		return false;
	}
   if( P1.Score == P2.Score )
   {
      // sort by kills
      if ( (Rx_PRI(P1) != none && Rx_PRI(P2) != none) && ( Rx_PRI(P1).GetRenKills() > Rx_PRI(P2).GetRenKills() ) )
		   return true;
		   
		// sort by deaths
	   if ( P1.Deaths > P2.Deaths )
		   return false;
   }
   return true;
}

//ha..
function Rx_Pri FindPlayerByNick( string PlayerID )
{
   local int i;

   for( i=0; i<PRIArray.Length; i++ )
   {
      if(InStr(Caps(PRIArray[i].PlayerName), Caps(PlayerID)) >= 0 )
         return Rx_Pri(PRIArray[i]);
   }

   return none;
}

// bypassing UTGameReplicationInfo's Timer function 
// so it doesn't do the countdown
simulated function Timer()
{
	super(GameReplicationInfo).Timer();
}

simulated function MapVotesInc(int i) {
	MapVotes[i]++;
}

simulated function MapVotesDec(int i) {
	MapVotes[i]--;
}

simulated function int GetMapVote() {
	local int i,MaxVotes,VotedMapIndex;

	VotedMapIndex = -1;
	for(i = 0; i < MapVotesSize; i++) {
		if(MapVotes[i] > MaxVotes) {
			MaxVotes = MapVotes[i];
			VotedMapIndex = i;
		}
	}
	return VotedMapIndex;
}

simulated function string GetMapVoteName()
{
	local string BasePackageName;
	
	BasePackageName = MapVoteList[ GetMapVote() != -1 ? GetMapVote() : 0 ];
		
	//If it has a day/night version, give us a random seed 
	if(MapPackageHasDayNight(BasePackageName)) 
	{
		if(Rand(2) == 0)
			return BasePackageName$"_Day" ;
		else
			return BasePackageName$"_Night";
	}
	else
		return BasePackageName;
}

function bool MapPackageHasDayNight(string ThePackage)
{
	return false;
}

function ResetMapVotes() {
	local int i;

	for(i = 0; i < MapVotesSize; i++) {
		MapVotes[i] = 0;
	}
}

simulated function StartMatch()
{
	super.StartMatch();
	if(WorldInfo.Netmode != NM_DedicatedServer) {
		GetNightVisionMIC();
		GetGlobalParticleMICList();
		SetGlobalStealthAddTranslucencyBias();
		SetGlobalStealthEffectMultiplier();
		SetGlobalStealthVisibilityMultiplier();
		SetCharacterGdiBrightness();
		SetCharacterNodBrightness();
		SetCharacterReflection();
		SetCharacterReflectionTexture();
		SetVehicleGdiBrightness();
		SetVehicleNodBrightness();
		SetVehicleReflection();
		SetVehicleReflectionTexture();
		UDKEmitterPool(WorldInfo.MyEmitterPool).MaxActiveEffects=MaxActiveEmitters;
	}
}

simulated function FindORI()
{
	local Rx_ORI ORI;
		
		foreach AllActors(class'Rx_ORI', ORI)
		{
			ObjectiveManager = ORI ;
			ClearTimer('FindORI'); //found, stop. 
			break;	
		}
}


function SetAwards(byte ForTeam,string MVPA, string BestOPA, string BestDPA, string BestSPA)
{
	MVP[ForTeam]=MVPA;
	BestOP[ForTeam]=BestOPA;
	BestDP[ForTeam]=BestDPA;
	BestSP[ForTeam]=BestSPA;

	bnetdirty=true;
}

simulated function SetupWeaponOverlays()
{
	local int i; 
	local MaterialInstanceConstant MIC;
	//Simplified system for weapon buffs	
	
	CreateCustomRxWeaponOverlays();
	
	for(i=0;i<WeaponOverlays.Length;i++)
	{	
		MIC=MaterialInstanceConstant(WeaponOverlays[i]);

		if(MIC != none) 
		{
				//Don't be so overbearingly large on weapons 
				MIC.SetScalarParameterValue('Opacity', 0.10);
				MIC.SetScalarParameterValue('Inflate', 0.20);
		}
	}
}

simulated function CreateCustomRxWeaponOverlays()
{
	local class<Rx_StatModifierInfo> SM; 
	local MaterialInstanceConstant TempMIC;
	
	foreach StatClasses (SM)
	{
		 TempMIC = new(outer) class'MaterialInstanceConstant';
  		 TempMIC.SetParent(MaterialInstanceConstant'RenX_AssetBase.Stealth.MI_PowerUp_Main');
		 
		TempMIC.SetVectorParameterValue('Effect_Colour', SM.default.EffectColor);
		TempMIC.SetScalarParameterValue('Inflate', 0.10); //Minimize both of these effects for weapons so they don't hinder ironsights
		TempMIC.SetScalarParameterValue('Opacity', 0.20);
			
		WeaponOverlays.AddItem(TempMIC); 
	}
}

simulated function CreateListArrays(){
	local Actor TempActor;
	
	foreach AllActors(class'Actor',TempActor,class'RxIfc_SpotMarker') {
		SpottingArray.AddItem(TempActor); 
	}
}

defaultproperties
{
	GameClass   = class'Rx_Game'
	bStopCountDown = false
   
	MaxActiveEmitters = 200
    
	NightVisionMIC=MaterialInstanceConstant'RenX_AssetBase.PostProcess.MI_NightVision'
	GlobalStealthAddTranslucencyBiasMIC=MaterialInstanceConstant'RenX_AssetBase.Stealth.MI_Cloak_Enemy'
	GlobalStealthEffectMultiplierMIC=MaterialInstanceConstant'RenX_AssetBase.Stealth.MI_Cloak_Enemy'
	GlobalStealthVisibilityMultiplierMIC=MaterialInstanceConstant'RenX_AssetBase.Stealth.MI_Cloak_Enemy'
	CharacterGdiBrightnessMIC=MaterialInstanceConstant'RenX_AssetBase.Characters.MI_CH_GDI'
	CharacterNodBrightnessMIC=MaterialInstanceConstant'RenX_AssetBase.Characters.MI_CH_Nod'
	CharacterReflectionMIC=MaterialInstanceConstant'RenX_AssetBase.Characters.MI_CH_All'
	CharacterReflectionTextureMIC=MaterialInstanceConstant'RenX_AssetBase.Characters.MI_CH_All'
	VehicleGdiBrightnessMIC=MaterialInstanceConstant'RenX_AssetBase.Vehicle.MI_VH_GDI'
	VehicleGdiAdaptiveBrightnessMic=MaterialInstanceConstant'RenX_AssetBase.Vehicle.MI_VH_GDI_Adaptive'
	VehicleNodBrightnessMIC=MaterialInstanceConstant'RenX_AssetBase.Vehicle.MI_VH_Nod'
	VehicleNodAdaptiveBrightnessMic=MaterialInstanceConstant'RenX_AssetBase.Vehicle.MI_VH_Nod_Adaptive'
	VehicleReflectionMIC=MaterialInstanceConstant'RenX_AssetBase.Vehicle.MI_VH_All'
	VehicleAdaptiveReflectionMIC=MaterialInstanceConstant'RenX_AssetBase.Vehicle.MI_VH_All_Adaptive'
	VehicleReflectionTextureMIC=MaterialInstanceConstant'RenX_AssetBase.Vehicle.MI_VH_All'
	VehicleCloakCamoMIC=MaterialInstanceConstant'RenX_AssetBase.Stealth.MI_Cloak_Enemy_Adaptive'
	MapVotesSize = 8
	
	//========================================================\\
	// ************** Particle Visual Properties *************\\
	//========================================================\\	

	GlobalParticleMIC(0)=MaterialInstanceConstant'RX_FX_Munitions2.MIC.MI_Dirt'
	GlobalParticleMIC(1)=MaterialInstanceConstant'RX_FX_Munitions2.MIC.MI_Dirt_Slow'
	GlobalParticleMIC(2)=MaterialInstanceConstant'RX_FX_Munitions2.MIC.MI_Dirt_WhiteSand'
	GlobalParticleMIC(3)=MaterialInstanceConstant'RX_FX_Munitions2.MIC.MI_Dirt_YellowSand'
	GlobalParticleMIC(4)=MaterialInstanceConstant'RX_FX_Munitions2.MIC.MI_Mud'
	GlobalParticleMIC(5)=MaterialInstanceConstant'RX_FX_Munitions2.MIC.MI_RockDirt'
	GlobalParticleMIC(6)=MaterialInstanceConstant'RX_FX_Munitions2.MIC.MI_Smoke'
	GlobalParticleMIC(7)=MaterialInstanceConstant'RX_FX_Munitions2.MIC.MI_Smoke_BW'
	GlobalParticleMIC(8)=MaterialInstanceConstant'RX_FX_Munitions2.MIC.MI_Smoke_Slow'
	GlobalParticleMIC(9)=MaterialInstanceConstant'RX_FX_Munitions2.MIC.MI_SmokeA'
	GlobalParticleMIC(10)=MaterialInstanceConstant'RX_FX_Munitions.Impact_Bullet.MI_Dirt_FakeLit'
	GlobalParticleMIC(11)=MaterialInstanceConstant'RX_FX_Munitions.Impact_Bullet.MI_Dirt_Thin_FakeLit'
	GlobalParticleMIC(12)=MaterialInstanceConstant'RX_FX_Munitions.Impact_Bullet.MI_Grain_FakeLit'
	GlobalParticleMIC(13)=MaterialInstanceConstant'RX_FX_Munitions.Impact_Bullet.MI_Mud_FakeLit'
	GlobalParticleMIC(14)=MaterialInstanceConstant'RX_FX_Munitions.Impact_Bullet.MI_RockDirt_FakeLit'
	GlobalParticleMIC(15)=MaterialInstanceConstant'RX_FX_Munitions.Impact_Bullet.MI_Smoke_FakeLit'
	GlobalParticleMIC(16)=MaterialInstanceConstant'RX_FX_Munitions.Impact_Bullet.MI_Smoke_SlowMoving_FakeLit'
	GlobalParticleMIC(17)=MaterialInstanceConstant'RX_FX_Munitions.Impact_Bullet.MI_Smoke_Thin_FakeLit'
	GlobalParticleMIC(18)=MaterialInstanceConstant'RX_FX_Munitions.Impact_Bullet.MI_Smoke_Thin_NotLit'
	GlobalParticleMIC(19)=MaterialInstanceConstant'RX_FX_Munitions.Impact_Bullet.MI_WhiteSand_Thin_FakeLit'
	GlobalParticleMIC(20)=MaterialInstanceConstant'RX_FX_Munitions.Impact_Bullet.MI_YellowSand_Thin_FakeLit'
	GlobalParticleMIC(21)=MaterialInstanceConstant'RX_FX_Munitions2.MIC.MI_FloatingDirt_Unlit'   
	GlobalParticleMIC(22)=MaterialInstanceConstant'RX_FX_Munitions2.MIC.MI_Mist'
	GlobalParticleMIC(23)=MaterialInstanceConstant'RX_FX_Munitions2.MIC.MI_WaterRadial'
	GlobalParticleMIC(24)=MaterialInstanceConstant'RX_FX_Munitions2.MIC.MI_Snow'
	GlobalParticleMIC(25)=MaterialInstanceConstant'RX_FX_Munitions.shells.MI_Shell_Trail_Master'
	
	MVP(0) = "Some Guy's NAme"
 
	//WeaponOverlays(0) = MaterialInstanceConstant'RenX_AssetBase.Stealth.MI_PowerUp_Main_Gold'
	//WeaponOverlays(1) = MaterialInstanceConstant'RenX_AssetBase.Stealth.MI_PowerUp_Main' //Simplified.. cuz this is a lot of time wasted on this. Weapons are either buffed or they're not
 
	//These need to sync up with the 'Effect_Priority' byte in the classes themselves
	StatClasses(0) = class'Rx_StatModifierInfo_GDI_OI'
	StatClasses(1) = class'Rx_StatModifierInfo_Nod_PTP' 
	StatClasses(2) = class'Rx_StatModifierInfo_Nod_UTP'
	StatClasses(3) = class'Rx_StatModifierInfo_GDI_DI'
	StatClasses(4) = class'Rx_StatModifierInfo_ChemGrenadeDebuff'
	StatClasses(5) = class'Rx_StatModifierInfo_Crate_Defense'
	StatClasses(6) = class'Rx_StatModifierInfo_Crate_Speed'
}
