/*********************************************************
*
* File: RxController.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
* 	
*
* ConfigFile: 
*
*********************************************************
*  
*********************************************************/
class Rx_PRI extends UTPlayerReplicationInfo
implements(RxIfc_RadarMarker);

// Kills including bots
var protected int   RenTotalKills;
// Kills excuding bot kills
var protected int   RenPlayerKills;

var float Veterancy_Points ; 
var float NonDefensiveVeterancy_Points ; 
var protected float Credits;
var protected float RenScore;
var protected int   ReplicatedRenScore;
var int   			ScoreLastMinutes;
var String 			PawnArea;
var() protected bool  bIsSpy;
var() protected bool  bSpotted;
var	 protected bool		bFocused; 
var() protected bool bIsVehicleStolen;
var() protected bool bIsVehicleFromCrate;
var float           OldRenScore;    // elo-ranking from last round, used for team shuffle.
var bool            bModeratorOnly; // for the temporary moderator system.
var int             ClanID;
var string			ReplicatedNetworkAddress;
var int 			LastFreeCharacterClass;

var int MyVehicleLimitInQueue;

// AT Mine stuff ain't got anything to do with replication, it's all handled server-side only. It's in here because can't edit Controller, and don't want to write the same code twice for Rx_Controller and Rx_Bot.
var array<Rx_Weapon_DeployedATMine> ATMines;
var int ATMineLimit;
var array<Rx_Weapon_DeployedRemoteC4> RemoteC4;
var int RemoteC4Limit;
var int LastAirdropTime;
var repnotify int AirdropCounter;
var bool bCanMine; //Determines if a player can place proximity mines or not. 

var repnotify byte VRank; //Players Veterancy Rank
var bool bVeterancyDisabled;  

var float Vet_RepairAmount_B; //A number that increases the more one repairs, and triggers a VP event if the person in question reaches it, thus reseting it. 
var float Vet_RepairAmount_P; //A number that increases the more one repairs, and triggers a VP event if the person in question reaches it, thus reseting it. 
var float Vet_RepairAmount_V; //A number that increases the more one repairs, and triggers a VP event if the person in question reaches it, thus reseting it. 
var float Vet_BDamageAmount; //A number that increases the more one Damages buildings, and triggers a VP event if the person in question reaches it, thus reseting it. 
var float Vet_VDamageAmount; //A number that increases the more one Damages vehicles, and triggers a VP event if the person in question reaches it, thus reseting it. 

var float Repair_Threshold_Building, Repair_Threshold_Pawn, Repair_Threshold_Vehicle, Damage_Threshold_Building, Damage_Threshold_Vehicle;


//All variables for tracking MVP stats
var int  Total_Kills, Offensive_Kills, Neutral_Kills,Neutral_Assists,Defensive_Kills, Beacon_Kills, Mine_Kills, Mines_Disarmed; //Kill Types
var float Infantry_Damage; //Infantry damage
var int	 Total_Assists, Offensive_Assists, Defensive_Assists ; // Infantry assists
var repnotify int Total_Vehicle_Kills; 
var int	 Offensive_Vehicle_Kills, Defensive_Vehicle_Kills, Neutral_Vehicle_Kills; //vehicle kills
var int  Total_Vehicle_Assists, Offensive_Vehicle_Assists, Defensive_Vehicle_Assists, Neutral_Vehicle_Assists; //Vehicle assists
var float  Vehicle_Damage, Vehicle_Repairs, Building_Repairs, Infantry_Repairs, Beacon_Damage ; //Supporting Roles
var float  Building_Damage, Building_ArmourDamage; //Building Damage Building_
var int Tech_Captures, Vehicle_EMPs, Infiltrator_Kills; //Miscellaneous

var float Score_Offense, Score_Defense, Score_Support; //Total scores  

/**************************
*Commander oriented stuff**
***************************/
var Rx_PRI Unit_Commander; 
var repnotify byte Unit_TargetStatus[2]; // Array: [0 GDI, 1 is Nod] | Value 1 for attack   
var repnotify byte Unit_TargetNumber[2]; //Number they show up as to the enemy for ID purposes 
var float TargetDecayTime ;
var repnotify bool bIsCommander; 
var float ClientTargetUpdatedTime;
var repnotify bool bUpdateTargetTimeFlag; 
var bool bNeedRelevancyInfo; //Do we need to replicate relevancy stufF?

var byte CurrentControlGroup;  

//Pawn Minimap Info
var  vector PawnLocation;
var repnotify vector PawnVelocity; 
var rotator PawnRotation; 
var class	PawnVehicleClass; 
var byte	PawnRadarVis; 

var float		TenthSecondsSinceLocationRep;

var bool		bUseLegacyScoreSystem; //Whether we're using Legacy or new scoring system

var bool bCanRequestCheatBots;
var int BotSkill;

replication
{
	if( bNetDirty && Role == ROLE_Authority)
		PawnVehicleClass, ReplicatedRenScore, RenTotalKills, bIsSpy, 
		bIsVehicleStolen, bIsVehicleFromCrate, bModeratorOnly, VRank, bUpdateTargetTimeFlag, bIsCommander, Veterancy_Points, 
		NonDefensiveVeterancy_Points, Credits, Total_Vehicle_Kills, bCanRequestCheatBots, BotSkill; 
	
	if(bNeedRelevancyInfo && !bNetOwner && bNetDirty && ROLE == ROLE_Authority)
		PawnLocation, PawnRotation, PawnRadarVis, PawnVelocity; 
	
	if(bNetDirty && bNetOwner)
		AirdropCounter, bCanMine;

	if(bNetDirty && !bNetOwner)
		Unit_TargetStatus, Unit_TargetNumber, bSpotted, bFocused;
	
		//if( bNetDirty && Role == ROLE_Authority && bDemoRecording) 
	//	ReplicatedNetworkAddress; // want to try to live without this, so demos can be shared publically without showing IPs of the players
}

simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'CharClassInfo' )
    {
		UpdateCharClassInfo();
    }
	else
	if ( VarName == 'bUpdateTargetTimeFlag' )
    {
		ClientTargetUpdatedTime = WorldInfo.TimeSeconds; 
    }
    else if ( VarName == 'AirdropCounter' )
    {
		
		LastAirdropTime = Worldinfo.TimeSeconds;
		
	} 
	else if(VarNAme == 'PawnVelocity')
	{
		ClearTimer('SimVelocityToLocationTimer');
		TenthSecondsSinceLocationRep = 0; 
		SetTimer(0.1,true,'SimVelocityToLocationTimer'); 
	}
	else
    {
		Super.ReplicatedEvent(VarName);
	}
}

simulated function PostBeginPlay()
{
	
	super.PostBeginPlay();
	if(ROLE == ROLE_Authority) 
	{
		bNeedRelevancyInfo = (!Rx_Game(WorldInfo.Game).bInfantryAlwaysRelevant || !Rx_Game(WorldInfo.Game).bVehiclesAlwaysRelevant);
		bUseLegacyScoreSystem = Rx_Game(WorldInfo.Game).bUseLegacyScoreSystem; 
	}
	if(Rx_Bot(Owner) != None)
		BotSkill = GetBotSkill();
		
}

simulated function UpdateCharClassInfo()
{
	local UTPawn UTP;
	foreach WorldInfo.AllPawns(class'UTPawn', UTP)
	{
		if (UTP.PlayerReplicationInfo == self || (UTP.DrivenVehicle != None && UTP.DrivenVehicle.PlayerReplicationInfo == self))
		{
			UTP.NotifyTeamChanged();
		}
	}
}

simulated function UpdateScoreLastMinutes()
{	
	ScoreLastMinutes = ReplicatedRenScore;
}

simulated function AddCredits( float amount )
{
	Credits += amount;
} 

simulated function RemoveCredits( float amount )
{
	Credits -= amount;
}

simulated function SetCredits( float amount )
{
	Credits = amount;
}

simulated function float GetCredits()
{
	return Credits;
}

simulated function bool isSpy()
{
	return bIsSpy;
}

function SetIsSpy(bool inIsSpy)
{
	bIsSpy = inIsSpy;
}

simulated function bool IsVehicleStolen()
{
	return bIsVehicleStolen;
}

function SetVehicleIsStolen(bool inIsVehicleStolen)
{
	bIsVehicleStolen = inIsVehicleStolen;
}


simulated function bool IsVehicleFromCrate()
{
	return bIsVehicleFromCrate;
}

function SetVehicleIsFromCrate(bool inIsVehicleFromCrate)
{
	bIsVehicleFromCrate = inIsVehicleFromCrate;
}

/**
 * Pawn is provided and not calculated from Owner because Owner sometimes takes a while to update
 */
function SetChar(class<Rx_FamilyInfo> newFamily, Pawn pawn, optional bool isFreeClass)
{
   local Rx_Pawn rxPawn;

   bIsSpy = false;

	if (newFamily != none )
	{
		CharClassInfo = newFamily;
	} 
	else
	{
		return;
	}
	if(Rx_Bot(Owner) != None)
	{
		UTPawn(pawn).NotifyTeamChanged();
	}
	else if((WorldInfo.NetMode == NM_ListenServer && RemoteRole == ROLE_SimulatedProxy) || WorldInfo.NetMode == NM_Standalone )
	{
		UpdateCharClassInfo();
	} else if(newFamily != None) {
		//`log("setting pawn " @ pawn @ "Character info to" @ newFamily); 
		Rx_Pawn(pawn).SetCharacterClassFromInfo(newFamily);
	}

	if(WorldInfo.GetGameClass() == Class'Rx_Game')
	{
		if( Rx_Game(WorldInfo.Game).GetPurchaseSystem().IsStealthBlackHand(self) )
		{
			if(Rx_Controller(Owner) != none)
				Rx_Controller(Owner).ChangeToSBH(true);
			else if(Rx_Bot(Owner) != none)
				Rx_Bot(Owner).ChangeToSBH(true);
		}
		else
		{
			if(Rx_Controller(Owner) != none)
				Rx_Controller(Owner).ChangeToSBH(false);
			else if(Rx_Bot(Owner) != none)
				Rx_Bot(Owner).ChangeToSBH(false);
		}
	}

   rxPawn = Rx_Pawn(pawn);

   if (rxPawn == none || Team == none) {
      return;
   }
   
   equipStartWeapons(isFreeClass);
}

function IncrementKills(bool bEnemyKill )
{
}

/** one1: Modified. */
function equipStartWeapons(optional bool FreeClass) 
{
   	local Rx_Pawn rxPawn;
    local class<Rx_FamilyInfo> rxCharInfo;   
	local float ArmourPCT; 
	local int	i; 

	rxCharInfo = class<Rx_FamilyInfo>(CharClassInfo);
	rxPawn = Rx_Pawn(Controller(Owner).Pawn);

	/** one1: Set starting inventory. */
	Rx_InventoryManager(rxPawn.InvManager).SetWeaponsForPawn();
	
	if(FreeClass) 
	{
		/*Give the pawn the same percentage of armour if they switch classes. E.G, switching from a RifleSoldier with 100 health and armour, 
		to a Grenadier would still make the grenadier have full health/armour*/ 
		ArmourPCT=float(rxPawn.Armor)/float(rxPawn.ArmorMax); 
		
		if(rxPawn.ArmorMax != rxCharInfo.default.MaxArmor) 
		{
			rxPawn.ArmorMax  = rxCharInfo.default.MaxArmor;
		
			rxPawn.Armor     = rxCharInfo.default.MaxArmor; //rxPawn.Armor > rxCharInfo.default.MaxArmor ? rxCharInfo.default.MaxArmor : rxPawn.Armor;	
		
			rxPawn.Armor*=ArmourPCT; 
		}
	 	
		rxPawn.setArmorType(rxCharInfo.default.Armor_Type);
	
		rxPawn.SpeedUpgradeMultiplier = rxCharInfo.default.SpeedMultiplier;	
		rxPawn.JumpHeightMultiplier = rxCharInfo.default.JumpMultiplier; 
		rxPawn.UpdateRunSpeedNode();
		rxPawn.SetGroundSpeed();
		//rxPawn.PromoteUnit(0); //Reset VRank
		rxPawn.SoundGroupClass = rxCharInfo.default.SoundGroupClass;
		rxPawn.Stamina = rxPawn.MaxStamina;
		rxPawn.ClientSetStamina(rxPawn.MaxStamina);
		rxPawn.PromoteUnit(VRank);
		
		
		//Clear and Set passive abilities
		rxPawn.ClearPassiveAbilities() ;
		
		for(i=0;i<3;i++){
			rxPawn.GivePassiveAbility(i, rxCharInfo.default.PassiveAbilities[i]) ;
		}
	
		//Reapply buffs/nerfs
		if(Rx_Controller(Owner) != none)
			Rx_Controller(Owner).UpdateModifiedStats(); 
		else if(Rx_Bot(Owner) != none)
			Rx_Bot(Owner).UpdateModifiedStats(); 
	
 		rxPawn.bForceNetUpdate = true;
		return;
	}
	
	//Set Health
	rxPawn.HealthMax = rxCharInfo.default.MaxHealth;
	rxPawn.Health    = rxPawn.HealthMax;
	
	//Set armour and type
	rxPawn.ArmorMax  = rxCharInfo.default.MaxArmor;
	rxPawn.Armor     = rxPawn.ArmorMax;	 	 	
	rxPawn.setArmorType(rxCharInfo.default.Armor_Type);
	
	rxPawn.SpeedUpgradeMultiplier = rxCharInfo.default.SpeedMultiplier;	
	rxPawn.JumpHeightMultiplier = rxCharInfo.default.JumpMultiplier; 
	rxPawn.UpdateRunSpeedNode();
	rxPawn.SetGroundSpeed();
	rxPawn.PromoteUnit(VRank);
	rxPawn.SoundGroupClass = rxCharInfo.default.SoundGroupClass;
	rxPawn.Stamina = rxPawn.MaxStamina;
	rxPawn.ClientSetStamina(rxPawn.MaxStamina);
	rxPawn.PromoteUnit(VRank);
	
	//Clear and Set passive abilities
	rxPawn.ClearPassiveAbilities() ;
	
	for(i=0;i<3;i++){
		rxPawn.GivePassiveAbility(i, rxCharInfo.default.PassiveAbilities[i]) ;
	}
	
	//Reapply buffs/nerfs
	if(Rx_Controller(Owner) != none)
			Rx_Controller(Owner).UpdateModifiedStats(); 
	else if(Rx_Bot(Owner) != none)
		Rx_Bot(Owner).UpdateModifiedStats(); 
	
 	rxPawn.bForceNetUpdate = true;
}

/** one1: Modified. */
function equipStartWeaponsFree() 
{
   	local Rx_Pawn rxPawn;
    local class<Rx_FamilyInfo> rxCharInfo;   

	rxCharInfo = class<Rx_FamilyInfo>(CharClassInfo);
	
	if(UDKBot(Owner) != none) {
		rxPawn = Rx_Pawn(UDKBot(Owner).Pawn);	
	} else {
    	rxPawn = Rx_Pawn(PlayerController(Owner).Pawn);	
    }

	/** one1: Set starting inventory. */
	Rx_InventoryManager(rxPawn.InvManager).SetWeaponsForPawn();
	//Set Health
	rxPawn.HealthMax = rxCharInfo.default.MaxHealth;
	rxPawn.Health    = rxPawn.HealthMax;
	//Set armour and type
	rxPawn.ArmorMax  = rxCharInfo.default.MaxArmor;
	rxPawn.Armor     = rxPawn.ArmorMax;	 	 	
	rxPawn.setArmorType(rxCharInfo.default.Armor_Type);
	
	rxPawn.SpeedUpgradeMultiplier = rxCharInfo.default.SpeedMultiplier;	
	rxPawn.JumpHeightMultiplier = rxCharInfo.default.JumpMultiplier; 
	rxPawn.UpdateRunSpeedNode();
	rxPawn.SetGroundSpeed();
	rxPawn.SoundGroupClass = rxCharInfo.default.SoundGroupClass;
	rxPawn.PromoteUnit(VRank);
 	rxPawn.bForceNetUpdate = true;
}

function UpdateEventStatAchievements(name StatName) {
	// No Achievements yet
}

function UpdatePowerupAchievements(name StatName, int Time) {
	// No Achievements yet
}

// Takes the score and adds it to own score and team score.  if bAddCredits. then the player get credits in the amount of inScore
function AddScoreToPlayerAndTeam(float inScore, optional bool bAddCredits = true )
{ 
	
	if (bAddCredits)
	{
		AddCredits(inScore);
	}
	
	if(!bUseLegacyScoreSystem){
		UpdateAllScores(inScore); //Converts inScore to the difference between scores for non-legacy mode 
		RenScore = GetTotalScore();	
	}
	else
	{
		RenScore += inScore;
	}
	
	ReplicatedRenScore = RenScore;
	
	if(Rx_Controller(Owner) != None && Worldinfo.NetMode != NM_Standalone)
		Rx_Controller(Owner).ResetAFKTimer();
	
	Rx_TeamInfo(Team).AddRenScore(inScore);	
}

function AddRenKill( optional int numKill = 1 , optional bool isBotKill = false)
{
	if (!isBotKill)
	{
		RenPlayerKills += numKill;
	}
	RenTotalKills += numKill;
}

simulated function int GetRenKills()
{
	return RenTotalKills;
}

simulated function int GetRenPlayerKills()
{
	return RenPlayerKills;
}

simulated function int GetRenScore()
{
	return ReplicatedRenScore;
}

simulated function float GetKDRatio()
{
	if(Deaths == 0)
	{
		return RenTotalKills;
	}
	return RenTotalKills/Deaths;
}

simulated function int GetVetRank()
{
	return VRank;
}

simulated function int GetVehicleKills()
{
	return Total_Vehicle_Kills;
}

reliable server function int GetBotSkill()
{
	if(UTBot(Owner) != none)
		return int(UTBot(Owner).Skill);

	return 0;
}

simulated function String GetHumanReadableName()
{
	local string ret;
	ret = super.GetHumanReadableName();
	if(bBot)
	{
		ret = "[B-"$BotSkill$"]"$ret;
	}
	else if(bIsSpectator)
		ret = "[Spec]"$ret;
	else if (Rx_Controller(Owner) != None)
	{
		if (left(ret,3) == "[B-")
			ret = Split(ret,"[B-",true);

		if (left(ret,5) == "[AFK]")
			ret = Split(ret,"[AFK]",true);

		if (Rx_Controller(Owner).bIsAFK)
			ret = "[AFK]"$ret;
	}

	return ret;
}

simulated function SetPawnArea(String area)
{
	PawnArea = area;
}

simulated function String GetPawnArea()
{
	return PawnArea;
}

function SeamlessTravelTo(PlayerReplicationInfo NewPRI)
{
	super.SeamlessTravelTo(NewPRI);
	Rx_PRI(NewPRI).OldRenScore = OldRenScore;
}

simulated static function String LogNameOf(PlayerReplicationInfo PRI)
{
	if (PRI.bBot)
		return class'Rx_Game'.static.GetTeamName(PRI.GetTeamNum())$",b"$PRI.PlayerID$","$PRI.PlayerName;
	else
		return class'Rx_Game'.static.GetTeamName(PRI.GetTeamNum())$","$PRI.PlayerID$","$PRI.PlayerName;
}

function SetSpotted(float SpottedTime)
{
	if(ROLE < ROLE_Authority) ServerSetSpotted(SpottedTime); 
	else
	{
		bSpotted = true;
		SetTimer(SpottedTime,false,'ResetSpotted');	
		//Controller(Owner).Pawn.bAlwaysRelevant = true;  
	}
	
}

reliable server function ServerSetSpotted(float SpottedTime)
{
	if(GetTimerRate('ResetSpotted') - GetTimerCount('ResetSpotted') >= SpottedTime) return; //Already spotted for longer by something else	
	bSpotted = true; 
	//Controller(Owner).Pawn.bAlwaysRelevant = false;
	PawnRadarVis=2; 
	SetTimer(SpottedTime,false,'ResetSpotted');
}

function ResetSpotted()
{
	bSpotted = false;
}

simulated function bool isSpotted()
{
	return bSpotted;
}

function SetFocused()
{
	if(ROLE < ROLE_Authority) ServerSetFocused(); 
	else
	{
	bFocused = true;
	SetTimer(10.0,false,'ResetFocused');	
	}
	
}


reliable server function ServerSetFocused()
{
	bFocused = true; 
	SetTimer(10.0,false,'ResetFocused');
}

function ResetFocused()
{
	bFocused=false;
}

simulated function bool IsFocused()
{
	return bFocused;
}

simulated function String GetReplicatedNetworkAddress()
{
	return ReplicatedNetworkAddress;
}

function CopyProperties(PlayerReplicationInfo PRI)
{
	local Rx_PRI RxPRI;

	Super.CopyProperties(PRI);

	RxPRI = Rx_PRI(PRI);
	if ( RxPRI == None )
		return;
	RxPRI.RenTotalKills = RenTotalKills;
	RxPRI.RenPlayerKills = RenPlayerKills;
	RxPRI.Credits = Credits;
	RxPRI.RenScore = RenScore;
	RxPRI.ReplicatedRenScore = ReplicatedRenScore;
	RxPRI.Veterancy_Points = Veterancy_Points;
	RxPRI.NonDefensiveVeterancy_Points = NonDefensiveVeterancy_Points;
	RxPRI.VRank = VRank;
}

function Reset()
{
	super.Reset();
	RenTotalKills = 0;
	RenPlayerKills = 0;
	RenScore = 0;
	ReplicatedRenScore = 0;
	LastAirdropTime = 0;
	AirdropCounter = 0;
}

function RemoveATMine(Rx_Weapon_DeployedATMine mine)
{
	ATMines.RemoveItem(mine);
}

function AddATMine(Rx_Weapon_DeployedATMine mine)
{
	local Rx_Weapon_DeployedATMine m, oldest;

	if (ATMines.Length >= ATMineLimit)
	{
		foreach ATMines(m)
		{
			if (oldest == None) 
				oldest = m;
			else if (m.CreationTime < oldest.CreationTime) 
				oldest = m;
		}
	}
	if (oldest != None)
		oldest.Destroy();
	ATMines.AddItem(mine);
}

function DestroyATMines()
{
	while (ATMines.Length > 0)
	{
		if (ATMines[0] == None)
			return;
		ATMines[0].Destroy();
	}
}

function RemoveRemoteC4(Rx_Weapon_DeployedRemoteC4 mine)
{
	RemoteC4.RemoveItem(mine);
}

function AddRemoteC4(Rx_Weapon_DeployedRemoteC4 mine)
{
	local Rx_Weapon_DeployedRemoteC4 m, oldest;

	if (RemoteC4.Length >= RemoteC4Limit)
	{
		foreach RemoteC4(m)
		{
			if (oldest == None) 
				oldest = m;
			else if (m.CreationTime < oldest.CreationTime) 
				oldest = m;
		}
	}
	if (oldest != None)
		oldest.Destroy();
	RemoteC4.AddItem(mine);
}

function DestroyRemoteC4()
{
	while (RemoteC4.Length > 0)
	{
		if (RemoteC4[0] == None)
			return;
		RemoteC4[0].Destroy();
	}
}

function SwitchMineStatus()
{	

	if(bCanMine)
	{
		bCanMine=false;
		Rx_Controller(Owner).CTextMessage("You Have Been Banned from Mining",,120,1.0);
	}
	else
	{
		bCanMine=true;
		Rx_Controller(Owner).CTextMessage("Your Mine Ban Was Lifted",,100,1.0);
	}
}

function bool GetMineStatus()
{
	return bCanMine;
}

function AddVP(float Amount)
{
	local Rx_Game G; 
	
	G = Rx_Game(WorldInfo.Game);
	
	if(bVeterancyDisabled) return; 
	
	Veterancy_Points += Amount; 
	
	if(VRank < ArrayCount(G.default.VPMilestones) && Veterancy_Points >= G.default.VPMilestones[VRank] ) 
	{
		VRank++; //Must promote 
		if(Rx_Controller(Owner) != none)
			Rx_Controller(Owner).PromoteMe(VRank);
		else if(Rx_Bot(Owner) != none)
			Rx_Bot(Owner).PromoteMe(VRank);
	} 
}

function RecordNonDefensiveVP(float Amount)
{
	NonDefensiveVeterancy_Points += Amount; 			
}

function TickVPToFull()
{
	local Rx_Game G; 
	
	G = Rx_Game(WorldInfo.Game);
	
	if(Veterancy_Points <  G.default.VPMilestones[2]) {
		AddVP(100); 
		SetTimer(0.50,false,'TickVPToFull');
		}
		else
		if(IsTimerActive('TickVPToFull')) ClearTimer('TickVPToFull') ; 
}

//Add Building repair points toward VP, and trigger a VP event if you hit the necesary amount
function AddRepairPoints_B(float Amount)
{
	Vet_RepairAmount_B += Amount; 
	
	Building_Repairs+=Amount; 
	
	if(Vet_RepairAmount_B ==  Repair_Threshold_Building) 
	{
		if(Rx_Controller(Owner) != none)
			Rx_Controller(Owner).DisseminateVPString("[Building Repair]&" $ class'Rx_VeterancyModifiers'.default.Ev_BuildingRepair $ "&");
		else if(Rx_Bot(Owner) != none)
			Rx_Bot(Owner).DisseminateVPString("[Building Repair]&" $ class'Rx_VeterancyModifiers'.default.Ev_BuildingRepair $ "&");

		Vet_RepairAmount_B = 0;
	}
	else
	if(Vet_RepairAmount_B >  Repair_Threshold_Building) 
	{
		if(Rx_Controller(Owner) != none)
			Rx_Controller(Owner).DisseminateVPString("[Building Repair]&" $ class'Rx_VeterancyModifiers'.default.Ev_BuildingRepair $ "&");
		else if(Rx_Bot(Owner) != none)
			Rx_Bot(Owner).DisseminateVPString("[Building Repair]&" $ class'Rx_VeterancyModifiers'.default.Ev_BuildingRepair $ "&");

		Vet_RepairAmount_B = Vet_RepairAmount_B -  Repair_Threshold_Building;
	}
	
}

//Add Pawn repair points toward VP, and trigger a VP event if you hit the necessary amount
function AddRepairPoints_P(float Amount)
{
	Vet_RepairAmount_P += Amount; 
	
	Infantry_Repairs+=Amount;
	
	if(Vet_RepairAmount_P == Repair_Threshold_Pawn) //Pawns are of the least amount 
	{
		if(Rx_Controller(Owner) != none)
			Rx_Controller(Owner).DisseminateVPString("[Infantry Healing]&" $ class'Rx_VeterancyModifiers'.default.Ev_PawnRepair $ "&");
		else if(Rx_Bot(Owner) != none)
			Rx_Bot(Owner).DisseminateVPString("[Infantry Healing]&" $ class'Rx_VeterancyModifiers'.default.Ev_PawnRepair $ "&");

		Vet_RepairAmount_P = 0;
	}
	else
	if(Vet_RepairAmount_P > Repair_Threshold_Pawn) 
	{
		if(Rx_Controller(Owner) != none)
			Rx_Controller(Owner).DisseminateVPString("[Infantry Healing]&" $ class'Rx_VeterancyModifiers'.default.Ev_PawnRepair $ "&");
		else if(Rx_Bot(Owner) != none)
			Rx_Bot(Owner).DisseminateVPString("[Infantry Healing]&" $ class'Rx_VeterancyModifiers'.default.Ev_PawnRepair $ "&");

		Vet_RepairAmount_P = Vet_RepairAmount_P - Repair_Threshold_Pawn;
	}
	
}

//Add Pawn repair points toward VP, and trigger a VP event if you hit the necessary amount
function AddRepairPoints_V(float Amount)
{
	Vet_RepairAmount_V += Amount; 
	
	Vehicle_Repairs+=Amount; 
	
	if(Vet_RepairAmount_V == Repair_Threshold_Vehicle) 
	{
		if(Rx_Controller(Owner) != none)
			Rx_Controller(Owner).DisseminateVPString("[Vehicle Repair]&" $ class'Rx_VeterancyModifiers'.default.Ev_VehicleRepair $ "&");
		else if(Rx_Bot(Owner) != none)
			Rx_Bot(Owner).DisseminateVPString("[Vehicle Repair]&" $ class'Rx_VeterancyModifiers'.default.Ev_VehicleRepair $ "&");

		Vet_RepairAmount_V = 0;
	}
	else
	if(Vet_RepairAmount_V > Repair_Threshold_Vehicle) 
	{
		if(Rx_Controller(Owner) != none)
			Rx_Controller(Owner).DisseminateVPString("[Vehicle Repair]&" $ class'Rx_VeterancyModifiers'.default.Ev_VehicleRepair $ "&");
		else if(Rx_Bot(Owner) != none)
			Rx_Bot(Owner).DisseminateVPString("[Vehicle Repair]&" $ class'Rx_VeterancyModifiers'.default.Ev_VehicleRepair $ "&");

		Vet_RepairAmount_V = Vet_RepairAmount_V - Repair_Threshold_Vehicle;
	}
	
}

function AddBuildingDamagePoints(float Amount)
{
	local float Overflow, OverflowMultiplier; //Overflow = remainder. OverFlow Multiplier is how many times we actually went OVER Building Threshhold 
	
	Vet_BDamageAmount += Amount; 
	
	//Building_Damage+=Amount; 
	
	if(Vet_BDamageAmount == Damage_Threshold_Building) 
	{
		if(Rx_Controller(Owner) != none)
			Rx_Controller(Owner).DisseminateVPString("[Building Damage]&" $ class'Rx_VeterancyModifiers'.default.Ev_VehicleRepair $ "&");
		else if(Rx_Bot(Owner) != none)
			Rx_Bot(Owner).DisseminateVPString("[Building Damage]&" $ class'Rx_VeterancyModifiers'.default.Ev_VehicleRepair $ "&");

		Vet_BDamageAmount = 0;
	}
	else
	if(Vet_BDamageAmount > Damage_Threshold_Building) 
	{
		Overflow=Vet_BDamageAmount % Damage_Threshold_Building;
		OverFlowMultiplier=FFloor(Vet_BDamageAmount/Damage_Threshold_Building);
		if(Rx_Controller(Owner) != none)
			Rx_Controller(Owner).DisseminateVPString("[Building Damage]&" $ class'Rx_VeterancyModifiers'.default.Ev_VehicleRepair*OverflowMultiplier $ "&");
		else if(Rx_Bot(Owner) != none)
			Rx_Bot(Owner).DisseminateVPString("[Building Damage]&" $ class'Rx_VeterancyModifiers'.default.Ev_VehicleRepair*OverflowMultiplier $ "&");


		Vet_BDamageAmount = Overflow; //Vet_BDamageAmount -  Damage_Threshold_Building;
		//AddBuildingDamagePoints(0); //Loop once more incase it is over 400 still
	}
	
}

function AddVehicleDamagePoints(float Amount)
{
	local float Overflow, OverflowMultiplier; //Overflow = remainder. OverFlow Multiplier is how many times we actually went OVER Building Threshhold 
	
	Vet_VDamageAmount += Amount; 
	
	Vehicle_Damage+=Amount; 
	//Building_Damage+=Amount; 
	
	if(Vet_VDamageAmount == Damage_Threshold_Vehicle) 
	{
		if(Rx_Controller(Owner) != none)
			Rx_Controller(Owner).DisseminateVPString("[Vehicle Damage]&" $ class'Rx_VeterancyModifiers'.default.Ev_VehiclesDamaged $ "&");
		else if(Rx_Bot(Owner) != none)
			Rx_Bot(Owner).DisseminateVPString("[Vehicle Damage]&" $ class'Rx_VeterancyModifiers'.default.Ev_VehiclesDamaged $ "&");

		Vet_VDamageAmount = 0;
	}
	else
	if(Vet_VDamageAmount > Damage_Threshold_Vehicle) 
	{
		Overflow=Vet_VDamageAmount % Damage_Threshold_Vehicle;
		OverFlowMultiplier=FFloor(Vet_VDamageAmount/Damage_Threshold_Vehicle);
		if(Rx_Controller(Owner) != none)
			Rx_Controller(Owner).DisseminateVPString("[Vehicle Damage]&" $ class'Rx_VeterancyModifiers'.default.Ev_VehiclesDamaged*OverflowMultiplier $ "&");
		else if(Rx_Bot(Owner) != none)
			Rx_Bot(Owner).DisseminateVPString("[Vehicle Damage]&" $ class'Rx_VeterancyModifiers'.default.Ev_VehiclesDamaged*OverflowMultiplier $ "&");


		Vet_VDamageAmount = Overflow; //Vet_BDamageAmount -  Damage_Threshold_Building;
		//AddBuildingDamagePoints(0); //Loop once more incase it is over 400 still
	}
	
}

///////////////////////////////////////////////
////////START Stat tracking functions/////////////
////////////////////////////////////////////////

function AddInfantryDamage(float Amount)
{
	Infantry_Damage += Amount; 
}


function AddBeaconDisarmPoints(float Amount)
{
	Beacon_Damage+=Amount; 
}

function AddBeaconKill()
{
	Beacon_Kills++; 
}

function AddOffensiveKill()
{
	Offensive_Kills++; 
}

function AddNeutralKill()
{
	Neutral_Kills++;
}

function AddNeutralAssists()
{
	Neutral_Assists++;
}

function AddMineKill() 
{
	Mine_Kills++;
}

function AddDefensiveKill()
{
	Defensive_Kills++ ; 
}

function AddTotalKill()
{
	Total_Kills++; 
}

function AddTotalAssists()
{
	Total_Assists++;
}

function AddOffensiveAssist()
{
	Offensive_Assists++;
}

function AddDefensiveAssist() 
{
	Defensive_Assists++;
}

//Vehicle things 

function AddDefensiveVehAssist()
{
	Defensive_Vehicle_Assists++;
}

function AddOffensiveVehAssist()
{
	Offensive_Vehicle_Assists++;
}

function AddOffensiveVehKill()
{
	Offensive_Vehicle_Kills++;
}

function AddNeutralVehKill()
{
	Neutral_Vehicle_Kills++;
}

function AddNeutralVehAssist()
{
	Neutral_Vehicle_Assists++;
}

function AddDefensiveVehKill()
{
	Defensive_Vehicle_Kills++;
}

function AddVehicleKill()
{
	Total_Vehicle_Kills++;
}

function AddVehicleAssist()
{
	Total_Vehicle_Assists++;
}

//The weirder things 

function AddMineDisarm()
{
	Mines_Disarmed++;
}

function AddBuildingDamage(float Amount)
{
	Building_Damage+=Amount; 
}

function AddBuildingArmourDamage(float Amount)
{
	Building_ArmourDamage+=Amount; 
}

function AddTechBuildingCapture()
{
	Tech_Captures++;
}

function AddEMPHit()
{
	Vehicle_EMPs++; 
}

function AddInfiltratorKill(){
	Infiltrator_Kills++;
}

//END of Addition functions 


//VEHICLE DAMAGE is double-dipped for Offensive/Defensive... so adjust its weight in both accordingly 
//(Checking for pawn locations for EVERY SINGLE PROJECTILE HIT is pretty expensive, so it's not separated)

function UpdateOffensiveScore()
{
	 Score_Offense= ((Offensive_Kills*15.0) + (Offensive_Assists*8.0) + (Neutral_Kills*8.0) + (Neutral_Assists*4.0) + (Building_Damage/2.4) + (Building_ArmourDamage/75.0) + (Beacon_Kills*10.0) + (Offensive_Vehicle_Kills*20.0) + (Offensive_Vehicle_Assists*10.0) + (Neutral_Vehicle_Kills * 10.0) + (Neutral_Vehicle_Assists * 5.0)  + (Vehicle_Damage/100.0) + (Infantry_Damage/50.0));
}

function UpdateDefensiveScore()
{
	 Score_Defense= ((Defensive_Kills*10.0) + (Defensive_Assists*5.0) + (Mine_Kills*2.0) + (Building_Repairs/150.0) +  (Defensive_Vehicle_Kills*12.0) + (Defensive_Vehicle_Assists*6.0) + (Vehicle_Damage/100.0) + (Infiltrator_Kills*10.0));
}

function UpdateSupportScore()
{
	 Score_Support=((Vehicle_Repairs/150.0) + (Infantry_Repairs/50.0) + (Beacon_Damage/10.0) + (Tech_Captures*15.0) + (Mines_Disarmed) + (Vehicle_EMPs*3.0)) ;
}

function UpdateAllScores(optional out float Difference)
{
	local float LastScore;
	
	LastScore = GetTotalScore();
	
	UpdateOffensiveScore(); 
	UpdateDefensiveScore();
	UpdateSupportScore();

	Difference = GetTotalScore()-LastScore;
}

function float GetTotalScore()
{
	return Score_Offense + Score_Defense + Score_Support; 
}

///////////////////////////////////////////////
////////END Stat tracking functions/////////////
////////////////////////////////////////////////
function InitVP(int AvgVeterancy, int VP1, int VP2, int VP3)
{ 
	
	//`log("-------GRI =" @ WorldInfo.GRI @ "-----------------");
	//`log("Init VP"); 
	if(Veterancy_Points == 0) AddVP(AvgVeterancy);
}

simulated function setLastFreeCharacter(int fClass)
{
	ServerSetLastFreeCharacter(fClass); 
}

reliable server function ServerSetLastFreeCharacter(int fClass)
{
	local byte TeamID;
	local array<class<Rx_FamilyInfo> > ClassList;

	TeamID = GetTeamNum();

	if(TeamID == TEAM_GDI)
	{
		ClassList = class'Rx_PurchaseSystem'.default.GDIInfantryClasses;
	}
	else if(TeamID == TEAM_NOD)
	{
		ClassList = class'Rx_PurchaseSystem'.default.NodInfantryClasses;
	}

	if(fClass < 0 || fClass > ClassList.Length || ClassList[fClass].default.BasePurchaseCost != 0)
	{
		return;
	}

	LastFreeCharacterClass = fClass;
}

function DisableVeterancy(bool bStripPoints)
{
	bVeterancyDisabled = true; 
	
	if(bStripPoints) 
	{
		Veterancy_Points = 0;
		VRank = 0; 	
	}
}

/********************************
*Commander functions 
*********************************/

function SetCommander(Rx_PRI RxPRI)
{
	Unit_Commander = RxPRI;
	
	RemoveCommander(Unit_Commander.GetTeamNum()); //Clear current commander (As we're currently still just using a one commander system)
	
	if(Rx_Bot(Owner) != none) return; //The hell does a bot need a text message for ? 
	
	if(RxPRI != none && RxPRI != self) Rx_Controller(Owner).CTextMessage("--" $ RxPRI.PlayerName @ "is your new team Commander--",'LightBlue',120); 	
	else
	if(RxPRI != none && RxPRI == self) 
	{
		Rx_Controller(Owner).CTextMessage("--You are your team's new Commander--",'LightBlue',120); 
		Rx_Controller(Owner).CTextMessage("--" @ "Use CTRL+C to open the COMMANDER menu",'White',300);
		bIsCommander = true; 
	}
}

function RemoveCommander(byte ToTeam)
{
	if(bIsCommander) bIsCommander = false; 
	Unit_Commander = none;
	//Rx_Controller(Owner).CTextMessage("No Team Commander Set",'LightBlue',120); 	
}

reliable server function SetAsTarget(byte TType) //Type of target to be set as. Simplified from commander mod
{
	local byte TeamByte; 
	
	local int FreeNum; 
	
	TeamByte = GetTeamNum();

	FreeNum = Rx_Game(WorldInfo.Game).GetFreeTarget(TeamByte, TType, self);	

	if(FreeNum == -1) //Reset as we're already a target
	{
		SetTimer(TargetDecayTime, false, 'ResetEnemyTargetStatus'); 
		if(ROLE == ROLE_Authority) 
		{
			ClientTargetUpdatedTime = WorldInfo.TimeSeconds;
			bUpdateTargetTimeFlag = !bUpdateTargetTimeFlag; 
		}
		return; 
	}
	
	//Attack
	if(TType == 1) 
	{
		Unit_TargetStatus[TeamByte] = 1; 
		Unit_TargetNumber[TeamByte] = FreeNum; 
		SetTimer(TargetDecayTime, false, 'ResetEnemyTargetStatus'); 
		if(ROLE == ROLE_Authority) 
		{
			if(Controller(Owner).Pawn != none && Rx_Game(WorldInfo.Game) != none) 
			{
				if(Rx_Vehicle(Controller(Owner).Pawn) != none) 
					Rx_Vehicle(Controller(Owner).Pawn).SetTemporaryRelevance(TargetDecayTime);
				else if(Rx_Vehicle(Controller(Owner).Pawn) != none ) 
					Rx_Pawn(Controller(Owner).Pawn).SetTemporaryRelevance(TargetDecayTime);
			}
			ClientTargetUpdatedTime = WorldInfo.TimeSeconds;
			bUpdateTargetTimeFlag = !bUpdateTargetTimeFlag; 
		}
	}
} 

function ResetEnemyTargetStatus()
{
	local byte TeamByte, Special; 
	
	TeamByte = GetTeamNum();
	
	if(Unit_TargetStatus[TeamByte] != 0) 
	{
		Unit_TargetStatus[TeamByte] = 0; 
		Unit_TargetNumber[TeamByte] = 255; 
		
		if(Rx_Defence(Controller(Owner).Pawn) != none) Special = 30; 
		else
		if(Rx_Vehicle_Air(Controller(Owner).Pawn) != none) Special = 40;  
		else
		if(Rx_Vehicle(Controller(Owner).Pawn) != none) Special = 10;  
		
		Rx_Game(WorldInfo.Game).RemoveTarget(GetTeamNum(), self, Special);
	}
}

function SetTargetEliminated(byte TTYPE) //Blanket function for target doing anything but decaying: e.g: Going back into stealth or what not.
{
	local byte TeamByte; 
	
	TeamByte = GetTeamNum();
	
	if(Unit_TargetStatus[TeamByte] == 0) return; 
	else
	{
		Unit_TargetStatus[TeamByte] = 0; 
		Unit_TargetNumber[TeamByte] = 255; 
		Rx_Game(WorldInfo.Game).RemoveTarget(GetTeamNum(), self, TTYPE);
	}
	
}

simulated function bool bGetIsCommander()
{
	return bIsCommander;
}

function SetControlGroup(byte Group)
{
	CurrentControlGroup = Group; 
}

function UpdatePawnLocation(vector L, rotator R, vector V)
{
	PawnLocation=L;
	PawnRotation=R; 
	PawnVelocity=V;
}

simulated function class GetPawnVehicleClass()
{
	return PawnVehicleClass; 
}

function UpdateVehicleClass(class<Rx_Vehicle> C)
{
	PawnVehicleClass = C; 
}

function RemoveVehicleClass()
{
	PawnVehicleClass = none; 
}



/******************
*RxIfc_RadarMarker*
*******************/

//0:Infantry 1: Vehicle 2:Miscellaneous  
simulated function int GetRadarIconType()
{
	return PawnVehicleClass == none ? 0 : 1 ; 
} 

simulated function bool ForceVisible()
{
	return bNeedRelevancyInfo && bSpotted;  
}

simulated function vector GetRadarActorLocation() 
{
	return  PawnLocation+(PawnVelocity*TenthSecondsSinceLocationRep); 
} 
simulated function rotator GetRadarActorRotation()
{
	return PawnRotation; 
}

simulated function byte GetRadarVisibility()
{
	return bNeedRelevancyInfo ? PawnRadarVis : 0; 
}
 
simulated function Texture GetMinimapIconTexture()
{
	return PawnVehicleClass == none ? none : class<Rx_Vehicle>(PawnVehicleClass).default.MinimapIconTexture ; 
}

/******************
*END RadarMarker***
*******************/

simulated function class GetPawnClass()
{	
	if(PawnVehicleClass == none)
		return CharClassInfo;
	else
		return PawnVehicleClass ; 
}

simulated function SimVelocityToLocationTimer()
{
	TenthSecondsSinceLocationRep+=0.1;
}

DefaultProperties
{
	
	CharClassInfo=class'Rx_FamilyInfo_GDI_Soldier'
//	CharPortrait=none
	VoiceClass=class'Rx_Voice_GDI_Male'
	MyVehicleLimitInQueue = 2
	OldRenScore=0
	ATMineLimit=2
	RemoteC4Limit=4
	bCanMine=true
	LastAirdropTime=0
	Veterancy_Points=0
	NonDefensiveVeterancy_Points=0
	VRank = 0
	//Set by Rx_Game.
	LastFreeCharacterClass = 0
	
	//Amount of healing/Damage needed for certain goals 
	Repair_Threshold_Building = 600
	Repair_Threshold_Pawn = 100
	Repair_Threshold_Vehicle = 250
	Damage_Threshold_Building = 450
	Damage_Threshold_Vehicle = 350 //250
	
	//Decay time of attack targets in seconds 
	TargetDecayTime = 20.0 //12.0
	
	//ControlGroup
	CurrentControlGroup = 255
}
