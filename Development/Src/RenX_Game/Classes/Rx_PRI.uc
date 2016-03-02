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
class Rx_PRI extends UTPlayerReplicationInfo;

// Kills including bots
var protected int   RenTotalKills;
// Kills excuding bot kills
var protected int   RenPlayerKills;

var protected float Credits;
var protected float RenScore;
var protected int   ReplicatedRenScore;
var int   			ScoreLastMinutes;
var String 			PawnArea;
var() protected bool  bIsSpy;
var() protected bool  bSpotted;
var int             OldRenScore;    // score from last round, used for team shuffle.
var bool            bModeratorOnly; // for the temporary moderator system.
var int             ClanID;
var string			ReplicatedNetworkAddress;

var int MyVehicleLimitInQueue;

// AT Mine stuff ain't got anything to do with replication, it's all handled server-side only. It's in here because can't edit Controller, and don't want to write the same code twice for Rx_Controller and Rx_Bot.
var array<Rx_Weapon_DeployedATMine> ATMines;
var int ATMineLimit;
var array<Rx_Weapon_DeployedRemoteC4> RemoteC4;
var int RemoteC4Limit;
var int LastAirdropTime;
var repnotify int AirdropCounter;
var bool bCanMine; //Determines if a player can place proximity mines or not. 

replication
{
	if( bNetDirty && Role == ROLE_Authority)
		Credits, ReplicatedRenScore, RenTotalKills, bIsSpy, bSpotted, bModeratorOnly, AirdropCounter, bCanMine;
	//if( bNetDirty && Role == ROLE_Authority && bDemoRecording) 
	//	ReplicatedNetworkAddress; // want to try to live without this, so demos can be shared publically without showing IPs of the players
}

simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == 'CharClassInfo' )
    {
		UpdateCharClassInfo();
    }
    else if ( VarName == 'AirdropCounter' )
    {
		LastAirdropTime = Worldinfo.TimeSeconds;
    } 
    else
    {
		Super.ReplicatedEvent(VarName);
	}
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
	
if( (WorldInfo.NetMode == NM_ListenServer && RemoteRole == ROLE_SimulatedProxy) || WorldInfo.NetMode == NM_Standalone )
	{
		UpdateCharClassInfo();
	} else if(newFamily != None) {
		`log("setting pawn " @ pawn @ "Character info to" @ newFamily); 
		Rx_Pawn(pawn).SetCharacterClassFromInfo(newFamily);
	}

	if( Rx_Game(WorldInfo.Game).GetPurchaseSystem().IsStealthBlackHand(self) )
	{
		Rx_Controller(Owner).ChangeToSBH(true);
	}
	else
	{
		Rx_Controller(Owner).ChangeToSBH(false);
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

	rxCharInfo = class<Rx_FamilyInfo>(CharClassInfo);
	
	if(UDKBot(Owner) != none) {
		rxPawn = Rx_Pawn(UDKBot(Owner).Pawn);	
	} else {
    	rxPawn = Rx_Pawn(PlayerController(Owner).Pawn);	
    }

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
	rxPawn.SoundGroupClass = rxCharInfo.default.SoundGroupClass;
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
	rxPawn.SoundGroupClass = rxCharInfo.default.SoundGroupClass;
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
 	rxPawn.bForceNetUpdate = true;
}

function UpdateEventStatAchievements(name StatName) {
	// No Achievements yet
}

function UpdatePowerupAchievements(name StatName, int Time) {
	// No Achievements yet
}

// Takes the score and adds it to own score and team score.  if bAddCredits. then the player get credits in the amount of inScore
function AddScoreToPlayerAndTeam( float inScore, optional bool bAddCredits = true )
{
	RenScore += inScore;
	ReplicatedRenScore = RenScore;
	Rx_TeamInfo(Team).AddRenScore(inScore);
	
	if (bAddCredits)
	{
		AddCredits(inScore);
	}
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

simulated function String GetHumanReadableName()
{
	local string ret;
	ret = super.GetHumanReadableName();
	if(bBot) {
		ret = "[B]"$ret;
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

function SetSpotted()
{
	bSpotted = true;
	SetTimer(10.0,false,'ResetSpotted');
}

function ResetSpotted()
{
	bSpotted = false;
}

simulated function bool isSpotted()
{
	return bSpotted;
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
	local color MyColor;
	
	MyColor=MakeColor(255,128,255,255);
	if(bCanMine)
	{
		bCanMine=false;
		Rx_Controller(Owner).CTextMessage("GDI",100,"You Have Been Banned from Mining",MyColor,255,255, false,1,0.80);
	}
	else
	{
		bCanMine=true;
		Rx_Controller(Owner).CTextMessage("GDI",100,"Your Mine Ban Was Lifted",MyColor,255,255, false,1,0.80);
	}
}

function bool GetMineStatus()
{
	return bCanMine;
}

DefaultProperties
{
	
	CharClassInfo=class'Rx_FamilyInfo_GDI_Soldier'
//	CharPortrait=none
	VoiceClass=class'Rx_Voice_GDI_Male'
	MyVehicleLimitInQueue = 2
	OldRenScore=-1
	ATMineLimit=2
	RemoteC4Limit=4
	bCanMine=true
	LastAirdropTime=0
}
