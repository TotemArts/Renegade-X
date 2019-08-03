/*********************************************************
*
* File: Rx_Bot.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
* The Base class of all the PlayerBots
* The class contains all basic logistics that doesn't involve moving. Refer to the Rx_Bot_Waypoints or Rx_Bot_Mesh for such.
* ConfigFile: 
* DefaultRenegadeXAISetup.ini
*********************************************************
*  
*********************************************************/
class Rx_Bot extends UTBot
	config(RenegadeXAISetup);

var int TargetMoney;
var int BaughtVehicleIndex; // vehicle i just baught and want to get in to
var Rx_Vehicle BaughtVehicle; // vehicle i just baught and want to get in to

var bool bInvalidatePreviousSO; // set after death so that bot forgets about its previous SquadObjective and picks a new one on next occasion

var class<Rx_BotCharInfo> CharInfoClass;
var int DeathsTillTargetMoneySwitch;
var name OrdersBeforeBaughtVehicle;
var UTVehicle shouldWaitVehicle;
var bool bWaitingAtAreaSpot;
var Rx_AreaObjective ClosestNextRO;
var Rx_BuildingObjective ClosestEnemyBO;
var Rx_Sentinel_Obelisk_Laser_Base Obelisk;
var Rx_Sentinel_AGT_Rockets_Base AGT;
var float ReevaluateAreaObjectiveTime;
var bool bStrafingDisabled;
var bool bAttackingEnemyBase;
var int WaitingInAreaCount;
var int CantAttackCheckCount;
var bool bCheckIfBetterSoInCurrentGroup;



// HANDEPSILON NEW VARIABLES

// Base vars
var bool bInfiltrating;								// When this is set to true, pawn will attempt to
var string PTTask, TacticsPTTask;
var bool bOnboardForTactics;
var bool bJustRebought;
var float RefillDelay;
var bool bIsEmergencyRepairer;
var Rx_Weapon_DeployedActor DetectedDeployable;
var bool bCheetozBotz;	// Who actually wants to enable this anyways??
var Rx_Vehicle LastVehicle;


// Tactics var
var int MoneySaving;
var array<String> PTQueue;
var bool bEquippedForTactics, bReadyForTactics;


// Radio Var
var string NodColor, GDIColor, HostColor, ArmourColor;
var bool bCanTalk;
var config bool bQuietBots;
var localized array<string> RadioCommandsText;
var() array<SoundCue>       RadioCommands;
var bool					bCanPlayEnemySpotted; 
var float					MessageCooldown; //Cooldown on Enemy spotted sound (As it gets spammed a lot)
var Rx_Controller			AckPlayer;

var Actor tempActor;

var float lastFindStrafeDestTime;



//Weapons
var float Misc_DamageBoostMod; 
var float Misc_RateOfFireMod;
var float Misc_ReloadSpeedMod;

//Survivablity
var float Misc_DamageResistanceMod;
var float Misc_RegenerationMod; 

//Healing Related Variables//
var int	LastSupportHealTime;

//Buff/Debuff modifiers//

var float Misc_SpeedModifier; 

//Comm Centre
var byte RadarVisibility, LastRadarVisibility; //Set radar visibility. 0: Invisible to all 1: visible to your team 2: visible to enemy team 
var Rx_BuildingObjective CurrentBO;
var UTGameObjective LastO;

struct ActiveModifier
{
	var class<Rx_StatModifierInfo> ModInfo; 
	var float				EndTime; 
	var bool				Permanent; 
};

var array<ActiveModifier> ActiveModifications; 
var RX_TeamAI OurTeamAI;

function RxInitialize(float InSkill, const out CharacterInfo BotInfo, UTTeamInfo BotTeam)
{
	local UTPlayerReplicationInfo PRI;

	super.Initialize(InSkill, BotInfo);
	//super.Initialize(4.0, BotInfo);

	if(bQuietBots)
		bCanTalk = false;
	PRI = UTPlayerReplicationInfo(PlayerReplicationInfo);

	if(Rx_TeamInfo(BotTeam).GetTeamName() == "GDI")
		PRI.CharClassInfo = CharInfoClass.static.FindFamilyInfo("GDI");
	else
		PRI.CharClassInfo = CharInfoClass.static.FindFamilyInfo("Nod");


//	setStrafingDisabled(true);
	SetTimer(0.5,true,'ConsiderStartSprintTimer');
	
	SetTimer(0.05, false, 'CheckRadarVisibility');

	SetTimer(0.1,true,'CheckActiveModifiers');

	if(OurTeamAI == None)
		OurTeamAI = Rx_TeamAI(BotTeam.AI);




}

function ToggleBotVoice()
{
	if(bQuietBots)
	{
		bQuietBots = false;
		bCanTalk = true;
	}
	else
	{
		bQuietBots = true;
		bCanTalk = false;
	}
}

function bool AssessPurchasing()
{
	local NavigationPoint N;
	local class<Rx_FamilyInfo> PickedClass;

	if(PTTask == "")
		return false;

	if(Left(PTTask,8) == "Buy Char")
	{
		PickedClass = ParseBuyChar(PTTask);

		if(Rx_PRI(PlayerReplicationInfo).CharClassInfo == PickedClass)
		{
			if(RetreatToPTNecessary())
				PTTask = "Refill";
			else
			{
				PTTask = "";
				return false;
			}
		}
	}

	if(CanBuyCurrentPTTask())
	{
		N = GetNearestPT();

		return FindDestinationToPT(N);
	}

	return false;
}



function bool AssignSquadResponsibility()
{	
	local Rx_Weapon_DeployedActor DA;

	if(Rx_Vehicle(Pawn) != None && Enemy != None && !Rx_Vehicle(Pawn).ValidEnemyForVehicle(Enemy)) 
	{
		//loginternal("LoseEnemy");
		Enemy = None;
		//LoseEnemy();
	}

	if(DetectedDeployable != None || GetNearbyDeployables(false) != None)	
	{
		if(Rx_Weapon_DeployedBeacon(DetectedDeployable) != None || (Rx_Weapon_DeployedC4(DetectedDeployable) != None && Rx_BuildingAttachment_MCT(DetectedDeployable.Base) != None && Rx_BuildingAttachment_MCT(DetectedDeployable.Base).GetTeamNum() == GetTeamNum()))
			OurTeamAI.WarnBotsForDeployables(DetectedDeployable,Self);

		BroadcastDeployableSpotMessage(DetectedDeployable);
	}	
	if(class'Rx_Weapon_Deployable'.static.DeployablesNearby(Pawn, Pawn.Location, 500,DA) 
		&& Rx_Weapon_DeployedBeacon(DA) != None && DA.GetTeamNum() == GetTeamNum())
	{
		HoldPosition();
		return true;
	}


	if(BaughtVehicleIndex != -1) 
	{
		if(GoToBaughtVehicle()) 
		{
			return true;
		}
	}
	if(bOnboardForTactics && !ReviewTactics())	
	{
		return true;
	}
	if(Vehicle(Pawn) == None && LastVehicle == None && !Rx_Game(WorldInfo.Game).GetPurchaseSystem().AreVehiclesDisabled(GetTeamNum(), None) && BaughtVehicle == None)
	{
		if(TryBuyingNewTank())
			return true;
	} 

    if(bStrafingDisabled && Pawn.Anchor == None) 
    {
    	return false;
    }	

	
	if(UTVehicle(Pawn) == None && HasRepairGun() && !bInfiltrating) 
	{
		if(!DefendedBuildingNeedsHealing() && PTTask == "" && Rx_SquadAI(Squad).Size > 3 
			&& Rx_SquadAI(Squad).GetEngiNumber()/Rx_SquadAI(Squad).Size > Rx_SquadAI(Squad).RepairerRatio)
			RebuyDefense();

		else if(RepairCloseVehicles()) 
		{
			return true;		
		}
	}
	return super.AssignSquadResponsibility();
}

function bool CheckIfOnboard(float MinimumCredits)
{
	if(MinimumCredits > GetCredits() * 5)
		return false;

	MoneySaving = Rx_SquadAI(Squad).CurrentTactics.CreditsNeeded;

	bOnboardForTactics = true;
	return true;
}

function bool PurchaseTacticsEquipment()
{
	
	if((GetCredits() + MoneySaving) < Rx_SquadAI(Squad).CurrentTactics.CreditsNeeded)
	{
		return false;	
	}
	MoneySaving = 0;

	
	if(Vehicle(Pawn) == None && BaughtVehicle == None && BaughtVehicleIndex == -1 && Rx_SquadAI(Squad).CurrentTactics.PurchaseMaterial(Self))
	{
		bEquippedForTactics=True;
		return AssessPurchasing();
	}

	return false;


	
}

function bool TryBuyingNewTank()
{
	local Rx_TeamInfo T;

	if(GetOrders() == 'DEFEND' || Vehicle(RouteGoal) != None || PTTask != "")
		return false;

	if(WorldInfo.TimeSeconds < 30.0 + (10.0 * (8.0 - Skill) / 2))
		return false;

	if(GetCredits() < 600)
		return false;

	if(FRand() * Skill < 0.6)
		return false;

	// Determine if our vehicle count is barren or not, depending on skill

	T= Rx_TeamInfo(PlayerReplicationInfo.Team);
	if(T == None)
		return false;

	if(Skill > 6)
	{
		if(T.VehicleCount > T.VehicleLimit * 0.6)
			return false;
	}
	else if(Skill > 4)
	{
		if(T.VehicleCount > T.VehicleLimit * 0.4)
			return false;
	}
	else
	{
		if(T.VehicleCount > T.VehicleLimit * 0.25)
			return false;
	}





	PTTask = "Random Buy Vehicle";
	return AssessPurchasing();


	return false;

}

function RebuyDefense()
{
	local int i,c;

	i = Rand(4);
	c = Rand(10);

	Switch (i)
	{
		Case 0:
			if(!Rx_Game(WorldInfo.Game).GetPurchaseSystem().AreHighTierPayClassesDisabled(GetTeamNum()) && Skill > 5 && GetCredits() > 1000 && (c > 6 || Skill > 8))
			{
					PTTask = "Buy Char - Destroyer";
					Break;
			}
		Case 1:
			if(!Rx_Game(WorldInfo.Game).GetPurchaseSystem().AreHighTierPayClassesDisabled(GetTeamNum()) && Skill > 4 && GetCredits() > 600 && c > 3)
			{
				if(GetTeamNum() == 0)
					PTTask = "Buy Char - Patch";
				else
					PTTask = "Buy Char - Heavy";

				Break;
			}
		Case 2:
			if(GetCredits() > 350)
			{
				if(c > 1)
					PTTask = "Buy Char - AdvShotgun";
					
				else
					PTTask = "Buy Char - Officer";

				Break;
			}
		Case 3:
			PTTask = "Buy Char - Shotgun";
			Break;
	}


	
}
function bool RepairCloseVehicles()
{
	return false;
}

function bool ReviewTactics()
{

	if(Squad == None || Rx_SquadAI(Squad).CurrentTactics == None)
		return true; 								//Pass by, we got nothing special

	if((GetCredits() + MoneySaving) >= MoneySaving && !bEquippedForTactics && PurchaseTacticsEquipment())
	{
		return false;
	}
	if(!Rx_SquadAI(Squad).bTacticsCommenced && ((PTQueue.Length <= 0 && PTTask == "") || !CanBuyCurrentPTTask()) && BaughtVehicle == None && BaughtVehicleIndex == -1)
	{
		if(Rx_SquadAI(Squad).SquadLeader == Self)
			HoldPosition();
		else if (Rx_SquadAI(Squad).TellBotToFollow(Self,Rx_SquadAI(Squad).SquadLeader))
			return false;
		else
			return true;
	}

	else if(Vehicle(Pawn) == None && BaughtVehicleIndex == -1 && BaughtVehicle == None)
		bInfiltrating = true;

	return true;

}


function HoldPosition()
{
	if(Enemy != None)
	{
		ChooseAttackMode();
		return;
	}


	if(Vehicle(Pawn) == None)
		GoToState('WaitForTactics');

	else
	{
		FindRoamDest();
	}
}

state WaitForTactics
{

Begin :
	WaitForLanding();
	SwitchToBestWeapon();

	GoalString = "Awaiting Task....";

	StopMovement();

	if(Enemy != None)
		ChooseAttackMode();

	Sleep(1.0);
	LatentWhatToDoNext();

}

// This is called when the bot is doing an MCT rush. Use this to direct the bot's path

function bool FindInfiltrationPath()
{
	return false;
}
function bool FindVehicleAssaultPath()
{
	return false;
}

function bool LoseEnemy ()
{
	if (Super.LoseEnemy())
	{	
		bCanPlayEnemySpotted = true;
		return true;
	}

	return false;
}

function NavigationPoint PickRetreatFromAODestination()
{
	local bool bOkStrafeSpot;
	local Vehicle veh;
	local int i,Start;
	local float Dist,DistToAreaObjective;
	local NavigationPoint Nav, AlrightNavpoint;
	local Rx_AreaObjective AreaObjective;
	
	AreaObjective = Rx_AreaObjective(Squad.SquadObjective);
	DistToAreaObjective = VSize(Pawn.location - AreaObjective.location);
	 
	// get on path network if not already
	if (!Pawn.ValidAnchor())
	{
		Pawn.SetAnchor(Pawn.GetBestAnchor(Pawn, Pawn.Location, true, true, Dist));
		if (Pawn.Anchor == None)
		{
			// can't get on path network
			return None;
		}
		else
		{
			bOkStrafeSpot = VSize(Pawn.Anchor.Location - AreaObjective.location) < DistToAreaObjective;	
			if (bOkStrafeSpot )
			{
				return Pawn.Anchor;
			}
			else
			{
				return None;
			}
		}
	} 
	else if (Pawn.Anchor.PathList.length > 0)
	{
		// pick a random point linked to anchor within range of Area
		Start = Rand(Pawn.Anchor.PathList.length);
		i = Start;
		do
		{
			if (!Pawn.Anchor.PathList[i].IsBlockedFor(Pawn))
			{
				Nav = Pawn.Anchor.PathList[i].GetEnd();
				if (!Nav.bSpecialMove)
				{
					// one that gets us closer to the AreaObjective
					bOkStrafeSpot = VSize(Nav.Location - AreaObjective.location) < DistToAreaObjective;					
					if(bOkStrafeSpot && UTVehicle(Pawn) != None) {
						if(VolumePathNode(Nav) != None && !UTVehicle(Pawn).bCanFly) {
							bOkStrafeSpot = false;
						} else {							
							ForEach CollidingActors(class'Vehicle', veh, 500, Nav.location)
							{
								if(veh != Pawn) {
									if(VSize(veh.location - Nav.location) < VSize(Pawn.location - veh.location)) {
										bOkStrafeSpot = false; // so that we dont ramm into vehicles
										AlrightNavpoint = Nav;	
										break;
									}
								}
							}
						}
					}
					if (bOkStrafeSpot )
					{
						if(VSize(Nav.location - AreaObjective.location) < DistToAreaObjective) {
							return Nav;
						}
					} 
				}
			}
			i++;
			if (i == Pawn.Anchor.PathList.length)
			{
				i = 0;
			}
		} until (i == Start);
		
		if(AlrightNavpoint != None) {
			return AlrightNavpoint;
		} else {
			return None;
		}
	}	
	return None;
}

function OnEMPHit(Controller InstigatedByController, Actor EMPCausingActor, optional int TimeModifier = 0)
{
//	`logd("bot EMPd");
}

function OnEMPBleed(bool finish=false)
{

}


function bool RetreatToAvoidAO(vector AO_Location) 
{
	local float WeaponAO_OkDist;
	local vector CheckLoc;
		
	if(FastTrace(Enemy.location, AO_Location)) 
	{
		if(Rx_Vehicle(Pawn) != None) 
		{
			WeaponAO_OkDist = Rx_Vehicle_Weapon(Pawn.Weapon).GetAO_OkDist();	
		} 
		else 
		{
			WeaponAO_OkDist = Rx_Weapon(Pawn.Weapon).GetAO_OkDist();
		}
		
		// check for a location ahead in direction of enemy
		CheckLoc = Pawn.location + vector(rotator(Enemy.location - Pawn.location)) * WeaponAO_OkDist;
		
		if(FastTrace(CheckLoc, AO_Location) || FastTrace(Pawn.location, AO_Location)) {
			GoalString = "Retreating to avoid AGT/OB";
			MoveTarget = PickRetreatFromAODestination();
			GotoState('Retreating');
			return true;			
		}
	} 
	else if(FastTrace(Pawn.location, AO_Location)) 
	{
		GoalString = "Retreating to avoid AGT/OB";
		MoveTarget = PickRetreatFromAODestination();
		GotoState('Retreating');
		return true;
	}	
	return false;
}

/** called when a ReachSpec the AI wants to use is blocked by a dynamic obstruction
 * gives the AI an opportunity to do something to get rid of it instead of trying to find another path
 * @note MoveTarget is the actor the AI wants to move toward, CurrentPath the ReachSpec it wants to use
 * @param BlockedBy the object blocking the path
 * @return true if the AI did something about the obstruction and should use the path anyway, false if the path
 * is unusable and the bot must find some other way to go
 */
event bool HandlePathObstruction(Actor BlockedBy)
{
	local Rx_DestroyableObstacle Destructible;
	local Rx_DestroyableObstaclePlus DestructiblePlus;
	local Vehicle V;
	local Weapon Weap;

	if(Rx_BuildingAttachment_Door(BlockedBy) != None)
		return true;		// We can always pass the door, unless somebody had the idea to make locked doors for whatever reason

	if(Rx_DestroyableObstacle(BlockedBy) != None)
	{
		Destructible = Rx_DestroyableObstacle(BlockedBy);

		if(!Destructible.bExplodes || (Destructible.bExplodes && VSize(BlockedBy.Location - Pawn.Location) > Destructible.ExplosionRadius))
		{
			Focus = BlockedBy;
			DoRangedAttackOn(Blockedby);
		}
	}

	else if(Rx_DestroyableObstaclePlus(BlockedBy) != None)
	{
		DestructiblePlus = Rx_DestroyableObstaclePlus(BlockedBy);

		if(!DestructiblePlus.bExplodes || (DestructiblePlus.bExplodes && VSize(BlockedBy.Location - Pawn.Location) > DestructiblePlus.ExplosionRadius))
		{
			Focus = BlockedBy;
			DoRangedAttackOn(Blockedby);
		}
	}

	V = Vehicle(BlockedBy);
	if (V != None && V.Driver != None && Enemy != V && !WorldInfo.GRI.OnSameTeam(self, V))
	{
		GoalString = V @ "is blocking path to" @ MoveTarget @ " - kill it";
		Focus = V;
		Enemy = V;
		SwitchToBestWeapon();
		Weap = (Pawn.InvManager != None && Pawn.InvManager.PendingWeapon != None) ? Pawn.InvManager.PendingWeapon : Pawn.Weapon;
		if (Weap != None && Weap.CanAttack(V))
		{
			LastCanAttackCheckTime = WorldInfo.TimeSeconds;
			FireWeaponAt(V);
			MoveTimer = 1.0;
			return false;
		}
		else if (Vehicle(Pawn) != None && CanAttack(V))
		{
			LastCanAttackCheckTime = WorldInfo.TimeSeconds;
			FireWeaponAt(V);
			MoveTimer = 1.0;
			return false;
		}
	}
	//loginternal("HandlePathObstruction");
	return super.HandlePathObstruction(BlockedBy);
}

function ChooseAttackMode()
{
	if(!IsInState('Defending') && Rx_Pawn_SBH(Pawn) != None && !Rx_SquadAI(Squad).IsStealthDiscovered())
		return;

	if(Enemy != None && GetOrders() == 'Attack' && CurrentBO == None) 
	{
		if(GetTeamNum() == TEAM_GDI) 
		{
			if(Obelisk == None) 
				GetObelisk();

			if(Obelisk != None) 
			{
				if(RetreatToAvoidAO(Obelisk.location)) 
					return;
			}
		} 

		else if(GetTeamNum() == TEAM_NOD) 
		{
			if(AGT == None) 
				GetAGT();

			if(AGT != None) 
			{
				if(RetreatToAvoidAO(AGT.location)) 
				{
					return;
				}
			}
		}
	}
	super.ChooseAttackMode();
}



function array<class<Rx_FamilyInfo> > FilterCredits(array<class<Rx_FamilyInfo> > Classes, float Credits) {
	local array<class<Rx_FamilyInfo> > Result;
	local class<Rx_FamilyInfo> CharacterClass;
	
	foreach Classes(CharacterClass) 
	{
		if (CharacterClass.static.Cost(Rx_PRI(PlayerReplicationInfo)) <= Credits) 
			Result.AddItem(CharacterClass);
	}
	
	return Result;
}

function array<class<Rx_FamilyInfo> > OffensiveClasses() {
	local array<class<Rx_FamilyInfo> > Result, TeamClasses;
	local class<Rx_FamilyInfo> CharacterClass;
	
	TeamClasses = Rx_Game(WorldInfo.Game).GetPurchaseSystem().ClassesForTeam(GetTeamNum());
	
	foreach TeamClasses(CharacterClass) 
	{
		if (CharacterClass.default.Role == ROLE_Offense) 
			Result.AddItem(CharacterClass);
	}
	
	return Result;
}

function array<class<Rx_FamilyInfo> > DefensiveClasses() 
{
	local array<class<Rx_FamilyInfo> > Result, TeamClasses;
	local class<Rx_FamilyInfo> CharacterClass;
	
	TeamClasses = Rx_Game(WorldInfo.Game).GetPurchaseSystem().ClassesForTeam(GetTeamNum());
	
	foreach TeamClasses(CharacterClass) 
	{
		if (CharacterClass.default.Role == ROLE_Defense) 
			Result.AddItem(CharacterClass);
	}
	
	return Result;
}

function bool CanHeal(Actor Other)
{
	local Vector Dummy1, Dummy2;

	if(Pawn == None)
		return false;

	if(VSize(Other.Location - Pawn.Location) <= 450 && Trace(Dummy1,Dummy2,Other.Location,Pawn.GetWeaponStartTraceLocation(),,,,TRACEFLAG_Bullet) == Other)
		return true;	

	return false;
}

function bool CanAttack(Actor Other)
{
	local bool ret;
	local Rx_Vehicle V;

	if(Pawn == None)
		return false;

	if(Rx_Weapon_SmokeGrenade_Rechargeable(Pawn.Weapon) != None)
		return true;

	if(Rx_Weapon_RepairGun(Pawn.Weapon) != None)
	{
		if(Pawn(Other) != None && Pawn(Other).GetTeamNum() != GetTeamNum())
			return false;
		if(VSize(Other.Location - Pawn.Location) <= 700)
			return true;
	}
	else if (Rx_Vehicle(Pawn) != None)
	{
		V = Rx_Vehicle(Pawn);
		if(Rx_Building(Other) != None && !Rx_Vehicle_Weapon(V.Weapon).bOkAgainstBuildings)
			return false;


	}

	ret = super.CanAttack(Other);
	


	if(!ret) 
		CantAttackCheckCount++;
	else 
		CantAttackCheckCount = 0;
	
	return ret;
}

function bool IdealToAttack(Pawn Other)
{
	local Rx_Vehicle V;

	if(Rx_Vehicle(Pawn) != None)
		V = Rx_Vehicle(Pawn);

	if(Rx_Vehicle(Other) != None)
	{
		if(V != None)
		{
			if(Rx_Vehicle_Weapon(V.Weapon) == None)
				return false;
			if((Rx_Vehicle(Other).bLightArmor || Rx_Vehicle(Other).bIsAircraft))
				return Rx_Vehicle_Weapon(V.Weapon).bOkAgainstLightVehicles;
			else if(!Rx_Vehicle(Other).bLightArmor && !Rx_Vehicle(Other).bIsAircraft)
				return Rx_Vehicle_Weapon(V.Weapon).bOkAgainstArmoredVehicles;
		}
		else if (Rx_Weapon(Pawn.Weapon) != None)
			return Rx_Weapon(Pawn.Weapon).bOkAgainstVehicles;
	}	

	return true;
}


//Check if we have any deployables on the loose
function Rx_Weapon_DeployedActor GetNearbyDeployables(bool bOverrideFocus) 
{
	local Rx_Weapon_DeployedActor B;
	local float CheckRadius;

	if(DetectedDeployable != None)
	{	
		if(bOverrideFocus)
			Focus = DetectedDeployable;
		return DetectedDeployable;
	}

	CheckRadius = Skill / 3.0 * 600.0;

	foreach OverlappingActors(class'Rx_Weapon_DeployedActor',B,CheckRadius,Pawn.Location)
	{
		if(B.TeamNum != GetTeamNum())
		{
			if(Rx_Weapon_DeployedC4(B) != None && (Rx_Weapon_DeployedProxyC4(B) == None && GetOrders() != 'ATTACK')) 
			{
				if(Rx_Vehicle(B.Base) != None || Rx_Building(B.Base) != None)
				{
					DetectedDeployable = B;

					if(bOverrideFocus)
						Focus = B;

					settimer(2,false,'DelayedDetectionMessage');
						
					return B;
				}				
			}
			else
			{
				DetectedDeployable = B;

				if(bOverrideFocus)
					Focus = B;

				settimer(2,false,'DelayedDetectionMessage');

				return B;
			}
		}
	}
	return None;
}

function DelayedDetectionMessage ()
{
	if(DetectedDeployable != None)
		BroadcastDeployableSpotMessage(DetectedDeployable);
}

function bool NavCanBeHitByAO(Navigationpoint Nav) 
{
	if(GetTeamNum() == TEAM_GDI) {
		if(Obelisk == None) GetObelisk();
		if(Obelisk != None) {
			if(FastTrace(Obelisk.location, Nav.Location)) {
				return true;
			}
		}
	} else if(GetTeamNum() == TEAM_NOD) {
		if(AGT == None) 
			GetAGT();
		if(AGT != None) 
		{
			if(FastTrace(AGT.location, Nav.Location)) 
			{
				return true;
			}
		}
	}
	return false;
}

function bool DefendedBuildingNeedsHealing() 
{
	if(GetOrders() != 'Defend')
		return false;

	if(CurrentBO != None && CurrentBO.DefenderTeamIndex == GetTeamNum() && CurrentBO.NeedsHealing()) 
	{
		return true;
	}
	return false;
}



function bool NavBlockedByVeh(NavigationPoint Nav)
{
	local UTVehicle veh;
	local bool bOkStrafeSpot;
	
	bOkStrafeSpot = true;
	if(UTVehicle(Pawn) != None && Nav.bBlockedForVehicles) {
		return false;
	}
	ForEach CollidingActors(class'UTVehicle', veh, 500, Nav.location)
	{
		if(veh != Pawn) {
			if(VSize(veh.location - Nav.location) < VSize(Pawn.location - veh.location)) {
				
				// When Veh moves away from nav and at the same time won't come back
				if(VSize(veh.velocity) > 80 
						&& ( (veh.Throttle > 0.5 && class'Rx_Utils'.static.OrientationToB(veh,Nav) < 0.4) 
								|| (veh.Throttle < -0.5 && class'Rx_Utils'.static.OrientationToB(veh,Nav) > 0.4) )) {
					//DrawDebugLine(Pawn.location,veh.location,255,0,0,true);
					//DrawDebugLine(Pawn.location,Nav.location,0,255,0,true);	
					continue;
				}
				bOkStrafeSpot = false; // so that we dont ramm into vehicles
				
				//DrawDebugLine(Pawn.location,veh.location,255,0,0,true);
				//DrawDebugLine(Pawn.location,Nav.location,0,255,0,true);
				//DrawDebugSphere(veh.location,700,10,255,0,0,true);
				break;
			}
		}
	}
	return bOkStrafeSpot;
} 

function SmokeOutOn(Actor Target)
{
	local Rx_Weapon_SmokeGrenade_Rechargeable Smoke;

	Smoke = Rx_Weapon_SmokeGrenade_Rechargeable(Pawn.InvManager.FindInventoryType(Class'Rx_Weapon_SmokeGrenade_Rechargeable', true));

	if(Smoke == None)
		return;

	if(Pawn.Weapon != Smoke && Smoke.bReadyToFire())
		Pawn.InvManager.SetCurrentWeapon(Smoke);

	Pawn.Weapon.StartFire(0);
}

function bool HasC4()
{
	local Weapon C4;

	C4 = Weapon(Pawn.InvManager.FindInventoryType(Class'Rx_Weapon_TimedC4', true));

	return (C4 != None && C4.HasAmmo(0));
}

function bool SwitchToC4()
{
	local Weapon C4;

	if(Rx_Pawn(Focus) != None || ((Focus == Enemy) && (Vehicle(Enemy) == None)) )
		return false;

	C4 = Weapon(Pawn.InvManager.FindInventoryType(Class'Rx_Weapon_TimedC4', true));

	if(Pawn.Weapon == C4)
	{
		return true;
	}

	if(C4 != None && C4.HasAmmo(0))
	{
		Pawn.InvManager.SetCurrentWeapon(C4);
		return true;
	}

	// `log(Pawn@"doesn't have C4, unable to infiltrate");

	return false;
}

function setStrafingDisabled(bool bEnabled)
{
	bStrafingDisabled = bEnabled;
	//loginternal("Strafing:"@GetHumanReadableName()@" "@bEnabled);
}

function bool ShouldStrafeTo(Actor WayPoint)
{
	if(bStrafingDisabled) {
		return false;
	}
	return super.ShouldStrafeTo(WayPoint);
}

function bool IsInBuilding(optional out Rx_Building B) {
	local Vector TraceStart;
	local Vector TraceEnd;
	local Vector TraceExtent;
	local Vector OutHitLocation, OutHitNormal;
	local TraceHitInfo HitInfo;

	if ( Pawn != None ) {
		TraceStart = Pawn.Location;
		TraceEnd = Pawn.Location;
		TraceEnd.Z += 400.0f;
		// trace up and see if we are hitting a building ceiling  
		B = Rx_Building(Trace(OutHitLocation, OutHitNormal, TraceEnd, TraceStart, TRUE, TraceExtent, HitInfo, TRACEFLAG_Bullet));
		if(B != None) {

			return true;
		}
	} else {
		`log("Rx_Bot: IsInBuilding(): Pawn is None");
	}
	return false;
}

function bool GoToBaughtVehicle() 
{
	return false;
}

function Actor FindNearestFactory()
{
	local Rx_PurchaseSystem Purchase;
	local int i;
	local float BestDist,CurDist;
	local Actor BestBO;

	Purchase = Rx_Game(WorldInfo.Game).GetPurchaseSystem();

	if(GetTeamNum() == TEAM_GDI && Purchase.WeaponsFactory.length > 0)
	{
		for(i=0; i<Purchase.WeaponsFactory.length; i++)
		{
			if(Purchase.WeaponsFactory[i].myObjective == None)
				continue;

			if(BestBO != None)
			{
				BestBO = Purchase.WeaponsFactory[i].myObjective;
				BestDist = VSize(Pawn.Location - Purchase.WeaponsFactory[i].myObjective.location);
			}
			else
			{

				CurDist = VSize(Pawn.Location - Purchase.WeaponsFactory[i].myObjective.location);				
				if(BestDist < CurDist)
				{
						BestBO = Purchase.WeaponsFactory[i].myObjective;
						BestDist = CurDist;
				}
			}
		}

		return BestBO;
	}

	else if (GetTeamNum() == TEAM_NOD && Purchase.AirStrip.length > 0)
	{
		for(i=0; i<Purchase.Airstrip.length; i++)
		{
			if(BestBO != None)
			{
				BestBO = Purchase.Airstrip[i].myObjective;
				BestDist = VSize(Pawn.Location - Purchase.Airstrip[i].myObjective.location);
			}
			else
			{
				CurDist = VSize(Pawn.Location - Purchase.Airstrip[i].myObjective.location);
				if(BestDist < CurDist)
				{
					BestBO = Purchase.Airstrip[i].myObjective;
					BestDist = CurDist;
				}
			}
		}		

		return BestBO;
	}
	else
		return none;
}

event bool NotifyBump(Actor Other, Vector HitNormal)
{
	if(Rx_BuildingObjective(Squad.SquadObjective) != None && Squad.SquadObjective.DefenderTeamIndex != GetTeamNum() && Other == Rx_BuildingObjective(Squad.SquadObjective).myBuilding.GetMCT() && SwitchToC4())
	{
		Focus = Other;
		BombMCT();
	}

	return Super.NotifyBump(Other,HitNormal);
}

function AssaultMCT ()
{
	local Actor MCT;

	MCT = CurrentBO.myBuilding.GetMCT();

	Focus = MCT;

	if((Rx_Weapon_TimedC4(Pawn.Weapon) != None || SwitchToC4()) && Skill > 4 && VSize(MCT.location-Pawn.Location) <= 450)  // Skill level 4 below will only use their weapon instead
	{
		if(CanAttack(MCT))
		{
			LastCanAttackCheckTime = WorldInfo.TimeSeconds;
			BombMCT();
			return;
		}
	}

	else if (CanAttack(MCT))		
	{
		LastCanAttackCheckTime = WorldInfo.TimeSeconds;
		DoRangedAttackOn(MCT);
	}

}

function bool BombMCT() {

	local Rx_BuildingAttachment MCT;


//	`log("Bombing the building");
	if (CurrentBO != None)	
	{
		MCT = CurrentBO.myBuilding.GetMCT();
		if(MCT != None && SwitchToC4())
		{
			DoRangedAttackOn(MCT);

			if(Skill > 4 && bCanTalk)			
				BroadCastSpotMessage(15, "Planting &gt;&gt;C4&lt;&lt; inside "@CurrentBO.myBuilding.GetHumanReadableName()$"!");
			
			return true;
		}
	}

	return false;
}

function DoRandomJumps()
{
	if ( (NumRandomJumps > 10) || PhysicsVolume.bWaterVolume )
	{
		// can't suicide during physics tick, delay it
		Pawn.SetTimer(0.01, false, 'Suicide');
		return;
	}
	else
	{
		// jump
		NumRandomJumps++;
		if (!Pawn.IsA('Vehicle') && Pawn.Physics != PHYS_Falling && Pawn.DoJump(false))
		{
			Pawn.SetPhysics(PHYS_Falling);
			Pawn.Velocity = 0.5 * Pawn.GroundSpeed * VRand();
			Pawn.Velocity.Z = Pawn.JumpZ;
		}
	}
}

function ChangeToSBH(bool sbh) {
	local pawn p;
	local vector l;
	local rotator r; 
	
	p = Pawn;
	l = Pawn.Location;
	r = Pawn.Rotation; 
	
	if(sbh) 
	{
		if(self.Pawn.class != class'Rx_Pawn_SBH' )
		{
			UnPossess();
			p.Destroy(); 
			p = Spawn(class'Rx_Pawn_SBH', , ,l,r);
		}
		else
		{
			return;
		}
	}
	else 
	{
		if(self.Pawn.class != Rx_Game(WorldInfo.Game).DefaultPawnClass )
		{
			UnPossess();
			p.Destroy(); 
			p = Spawn(Rx_Game(WorldInfo.Game).DefaultPawnClass, , ,l,r);
		}
		else
		{
			return;
		}
		
	}
	Possess(p, false);
	Rx_Pri(PlayerReplicationInfo).equipStartWeapons();	
}

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);
	SetRadarVisibility(RadarVisibility);
}

function bool TryDuckTowardsMoveTarget(vector Dir, vector Y)
{
	return false;
}

function bool IsShootingObjective()
{
	if(Rx_Building(Focus) != None || Rx_BuildingAttachment(Focus) != None) {
		return true;
	}
	return false;
}

function ConsiderStartSprintTimer()
{
	local float Stamina;
	
	if(Rx_Pawn(pawn) == None) 
	{
		StopSprinting();
		return;
	}
	if(Pawn(Focus) != None)
	{
		StopSprinting();
		return;
	}
	if(Rx_Pawn(pawn).IsFiring() || Pawn.Acceleration == vect(0,0,0) || Stopped() || IsInState('TacticalMove')) {
		StopSprinting();
		return;
	}
	if(Rx_Pawn(pawn).bSprinting) 
	{
		return;
	}
	Stamina = Rx_Pawn(pawn).Stamina;	
	
	if(IsRetreating() && (Stamina >= 10 + Rand(20))) 
	{
		StartSprinting();
		return;	
	}
	if(Stamina >= 80) 
	{
		StartSprinting();	
	} 
	else if(Stamina  >= 0.5 && FRand() < 0.5) 
	{
		StartSprinting();
	}
}



event SeePlayer(Pawn Seen) 
{
	local float distanceToPlayer;
	local float playerSpeed;
	local bool inDetectionRange;
	local bool inWalkingDetectionRange;
	local bool inRunningDetectionRange;

	distanceToPlayer = VSizeSq(pawn.location - Seen.location);
	playerSpeed = VSizeSq(Seen.velocity);
	inDetectionRange = distanceToPlayer <= Square(150);
	inWalkingDetectionRange = distanceToPlayer <= Square(250) && playerSpeed >= Square(100);
	inRunningDetectionRange = distanceToPlayer <= Square(350) && playerSpeed >= Square(200);

	if (IsStealthed(Seen) && !(inDetectionRange || inWalkingDetectionRange || inRunningDetectionRange))
		return;
	
	
	if (Rx_Pawn(Seen) != None && Rx_Pawn(Seen).IsInvisible() && !(inDetectionRange || inWalkingDetectionRange || inRunningDetectionRange)) 
		return;

	else if (Rx_Vehicle_StealthTank(Seen) != None && Rx_Vehicle_StealthTank(Seen).IsInvisible() && !(inDetectionRange || inWalkingDetectionRange || inRunningDetectionRange)) 
		return;

	if(Rx_PRI(Seen.PlayerReplicationInfo) != None && Rx_PRI(Seen.PlayerReplicationInfo).IsSpy() && !inDetectionRange)
		return;

	super.SeePlayer(Seen);
}


function bool IsStealthed(Pawn Seen)
{
	if (RxIfc_Stealth(Seen) != none && RxIfc_Stealth(Seen).GetIsinTargetableState() == false && VSize(pawn.location - Seen.location) > 100)
		return true;
	return false;	
}

function bool IsCurrentlyInvisible()
{
	local Rx_Pawn_SBH P;
	local Rx_Vehicle_StealthTank V;

	P=Rx_Pawn_SBH(Pawn);
	V=Rx_Vehicle_StealthTank(Pawn);


	if(P != None)
	{
		if(!P.IsInState('BeenShot') && P.IsInvisible())
			return true;
	}
	else if (V != None)
	{
		if(!V.IsInState('BeenShot') && V.IsInvisible())
			return true;
	}

	return false;
}

function bool LostContact(float MaxTime)
{
	local bool ret;
	
	ret = super.LostContact(MaxTime);
	if(ret) return true;

	if(IsStealthed(Enemy))
		return true;

	return false;
}

function Rotator GetAdjustedAimFor( Weapon W, vector StartFireLoc )
{
	return super.GetAdjustedAimFor(W,StartFireLoc);
}

function WaitAtAreaTimer() 
{
	bWaitingAtAreaSpot = false;
	ClosestNextRO = None; // invalidate, since bot moves to another point/area now
	ClosestEnemyBO = None; // invalidate, since bot moves to another point/area now
	ClearTimer('LookarroundWhileWaitingInAreaTimer');		
	if(WaitingInAreaCount++ > 4) {
		WaitingInAreaCount = 0;
		bCheckIfBetterSoInCurrentGroup = true;
		Rx_TeamInfo(PlayerReplicationInfo.Team).AI.PutOnOffense(self);
		bCheckIfBetterSoInCurrentGroup = false;
	}
	WhatToDoNext();
}

// NEW PURCHASE LOGIC STARTS HERE

function bool RetreatToPTNecessary()
{
	local Rx_InventoryManager IM;
	local array<Rx_Weapon> PrimaryWeapons;
	local Rx_Weapon W;
	local bool bCanBustBuildings;
	local bool bRefillHealth, bRefillWeapon;

	if(bJustRebought || (PTTask != "" && PTTask != "Refill"))
		return false;		//To prevent bot exploiting the PT, prevent them from retreating if they just rebought

	IM = Rx_InventoryManager(Pawn.InvManager);
	IM.GetPrimaryWeaponList(PrimaryWeapons);

	if(PrimaryWeapons.length > 0)
	{
		foreach PrimaryWeapons (W)
		{
			if(W.bOkAgainstBuildings)
			{
				bCanBustBuildings = true;
				break;
			}
		}
	}

	if(Vehicle(Pawn) != None )
		return false;

	if(Pawn.Health < Pawn.HealthMax*0.7)
		bRefillHealth = true;


	if(bInfiltrating && (bCanBustBuildings || Rx_Weapon(IM.FindInventoryType(Class'Rx_Weapon_TimedC4')).HasAnyAmmo()))
		return false;

	if(W != None && W.AmmoCount < W.MaxAmmoCount/10 && Rx_Weapon_RepairGun(W) == None && Rx_Weapon_LaserRifle(W) == None && Rx_Weapon_LaserChainGun(W) == None)
		bRefillWeapon = true;

	if(bRefillHealth || bRefillWeapon)
	{
		GoalString @= "Needs Refill";
		return true;
	}

	return false;
}

function NavigationPoint GetNearestPT()
{
	local Array<NavigationPoint> PT;
	local NavigationPoint N, BestN;
	local Float BestDist, CurrentDist;

	if(GetTeamNum() == Team_GDI)
		PT = OurTeamAI.GDIPlayerStarts;
	else
		PT = OurTeamAI.NodPlayerStarts;

	foreach PT(N)
	{
		CurrentDist = VSize(Pawn.Location - N.Location);

		if((BestN == None || BestDist > CurrentDist) && ActorInBuilding(N))
		{
				BestN = N;
				BestDist = CurrentDist;
		}
	}
	if(BestN != None)
		return BestN;

	return N;
}

function bool FindDestinationToPT(Actor PTPoint)
{
	return false;
}

function SetItem(class<Rx_Weapon> classname)
{
	local Rx_InventoryManager invmngr;
	local array<class<Rx_Weapon> > wclasses;

	invmngr = Rx_InventoryManager(Pawn.InvManager);
	if (invmngr == none) return;

	if (!invmngr.IsItemAllowed(classname)) return;
	wclasses = invmngr.GetWeaponsOfClassification(CLASS_ITEM);
	if (invmngr.GetItemSlots() == wclasses.Length)
		invmngr.RemoveWeaponOfClass(wclasses[wclasses.Length - 1]);

	// add requested weapon
	invmngr.AddWeaponOfClass(classname, CLASS_ITEM);
}

function ProcessPurchaseOrder()
{
	local bool bPTSuccess;

	if(PTTask == "Refill")
	{
		
		bPTSuccess = BotRefill();
	}

	else if(Left(PTTask, 11) == "Buy Vehicle")
	{
		bPTSuccess = BotBuyVehicle(PTTask);
	}

	else if(Left(PTTask,8) == "Buy Char")
	{
		bPTSuccess = BotBuyChar(PTTask);
	}

	else if(PTTask == "Rebuy Char")
	{
		bPTSuccess = BotRebuyChar();
	}

	else if(PTTask == "Random Buy Vehicle")
	{
		bPTSuccess = BotRandomBuyVehicle();
	}

	else if (PTTask == "Buy Beacon")
	{
		bPTSuccess = BotBuyBeacon();
	}

	if(!bPTSuccess)
		return;

	if(bEquippedForTactics && PTTask == TacticsPTTask)
	{
		bReadyForTactics = true;
		TacticsPTTask = "";
	}

	PTTask = "";

}

function bool BotRefill()
{
	if(!bJustRebought)
	{
		bJustRebought = true;
		SetTimer(RefillDelay, false,'RemoveRefillDelay');
		Rx_Game(WorldInfo.Game).GetPurchaseSystem().BotPerformRefill(self);
		return true;
	}

	return false;
}

function RemoveRefillDelay()
{
	bJustRebought = false;
}

function bool BotRandomBuyVehicle()
{
	local Rx_PurchaseSystem PurchaseSystem;
	local int PickedVehicle;

	PurchaseSystem = Rx_Game(WorldInfo.Game).GetPurchaseSystem();

	if(PurchaseSystem.AreVehiclesDisabled(GetTeamNum(), None))
		return false;	
	
	if(GetTeamNum() == TEAM_GDI)
		PickedVehicle = GetGdiVehicle();	
	else
		PickedVehicle = GetNodVehicle();

	if(PurchaseSystem.PurchaseVehicle(Rx_Pri(PlayerReplicationInfo), GetTeamNum(), PickedVehicle)) 	
	{
		SetBaughtVehicle(PickedVehicle);
		return true;
	}

	return false;
}

function bool BotRebuyChar()
{
	local array<class<Rx_FamilyInfo> > PotentialPicks,Picks;
	local class<Rx_FamilyInfo> PickedClass, P;

	if(GetOrders() == 'ATTACK')
		// Pick offensive infantry
		PotentialPicks = OffensiveClasses();

	else 
		// Pick defensive infantry
		PotentialPicks = DefensiveClasses();
		
	foreach PotentialPicks(P)
	{
		if(class<Rx_FamilyInfo>(Rx_Pri(PlayerReplicationInfo).CharClassInfo).static.Cost(Rx_Pri(PlayerReplicationInfo)) < PickedClass.Static.Cost(Rx_PRI(PlayerReplicationInfo)))
			Picks.AddItem(P);
	}


	// Filter picks to what we can afford
	Picks = FilterCredits(PotentialPicks, GetCredits());

	// Make a pick
	if (Picks.Length > 0)
		PickedClass = Picks[Rand(Picks.Length)];

	if(PickedClass.static.Cost(Rx_PRI(PlayerReplicationInfo)) <= GetCredits())
	{
		ProcessCharacterChange(PickedClass);
		return true;
	}

	return false;
}

function bool CanBuyCurrentPTTask()
{
	local class<Rx_FamilyInfo> PickedClass;
	local int PickedVehicle;
	local int VehicleCost;


	if(Left(PTTask, 11) == "Buy Vehicle")
	{
		PickedVehicle = -1;

		ParseBuyVehicle(PTTask, PickedVehicle, VehicleCost);

		if(PickedVehicle != -1 && VehicleCost <= GetCredits())
			return true;

		return false;
	}

	else if(Left(PTTask,8) == "Buy Char")
	{
		PickedClass = ParseBuyChar(PTTask);

		if(PickedClass != None && PickedClass.static.Cost(Rx_PRI(PlayerReplicationInfo)) <= GetCredits())
			return true;

		return false;

	}


	else if (PTTask == "Buy Beacon")
	{
		return (GetCredits() >= 1000);
	}

	return true;
	
}

function class<Rx_FamilyInfo> ParseBuyChar(String CharID)
{
	local Rx_PurchaseSystem PurchaseSystem;
	local class<Rx_FamilyInfo> FI;

	PurchaseSystem = Rx_Game(WorldInfo.Game).GetPurchaseSystem();

	if(GetTeamNum() == TEAM_GDI)
	{
		ForEach PurchaseSystem.GDIInfantryClasses(FI)
		{
			if(FI.static.BotPTString() == CharID)
				return FI;
		}
	}

	else if(GetTeamNum() == TEAM_NOD)
	{
		ForEach PurchaseSystem.NodInfantryClasses(FI)
		{
			if(FI.static.BotPTString() == CharID)
				return FI;
		}
	}
	`warn(GetHumanReadableName@"received invalid class CharID, returning none");
	return none;
}
function bool BotBuyChar(string CharID)
{
	local class<Rx_FamilyInfo> PickedClass;

	PickedClass = ParseBuyChar(CharID);

	if(PickedClass != None)
	{	
		
		return ProcessCharacterChange(PickedClass);
	}

	else
	{
		return false;
	}
}

function bool ProcessCharacterChange(class<Rx_FamilyInfo> PickedClass)
{	
	local int BuyCost;
//	local ETickingGroup LastTG;
//	local bool bWasPostAsync;

	if(Rx_PRI(PlayerReplicationInfo).CharClassInfo == PickedClass)
	{
		PTQueue.AddItem("Refill");	//We already have this class. Issue a refill instead
		return true;
	}

	BuyCost = PickedClass.static.Cost(Rx_PRI(PlayerReplicationInfo));
	if(BuyCost > GetCredits())
		return false;

	Rx_PRI(PlayerReplicationInfo).RemoveCredits(BuyCost);

	Rx_PRI(PlayerReplicationInfo).CharClassInfo = PickedClass;

/*
	if(Pawn.Mesh.TickGroup != TG_PostAsyncWork)
	{
		LastTG = Pawn.Mesh.TickGroup;
		Pawn.Mesh.SetTickGroup(TG_PostAsyncWork);
		`log(GetHumanReadableName()@" : temporarily changing to PostAsyncWork");
	}
	else
		bWasPostAsync = true;
*/
	Rx_PRI(PlayerReplicationInfo).SetChar(PickedClass, Pawn, BuyCost <= 0);
/*
	if(!bWasPostAsync)
	{
		Pawn.Mesh.SetTickGroup(LastTG);
		`log(GetHumanReadableName()@" : returning tick group back to previous state");
	}
*/
	return true;

//	Rx_Pri(PlayerReplicationInfo).SetChar(PickedClass,Pawn,false);
}

function ParseBuyVehicle(string VID, out int PickedVehicle, out int VehicleCost)
{
	local Rx_PurchaseSystem PurchaseSystem;
	local class<Rx_Vehicle_PTInfo> V;
	local int i;

	PurchaseSystem = Rx_Game(WorldInfo.Game).GetPurchaseSystem();

	if(GetTeamNum() == TEAM_GDI)
	{
		for(i=0;i<PurchaseSystem.GDIVehicleClasses.Length;i++)
		{
			V = PurchaseSystem.GDIVehicleClasses[i];
			if(V.static.BotPTString() == VID)
			{
				VehicleCost = V.static.GetCost(Rx_Pri(PlayerReplicationInfo));
				PickedVehicle = i;
				return;
			}
		}
	}

	else if(GetTeamNum() == TEAM_NOD)
	{
		for(i=0;i<PurchaseSystem.NodVehicleClasses.Length;i++)
		{
			V = PurchaseSystem.NodVehicleClasses[i];
			if(V.static.BotPTString() == VID)
			{
				VehicleCost = V.static.GetCost(Rx_Pri(PlayerReplicationInfo));
				PickedVehicle = i;
				return;
			}
		}
	}

	`warn(GetHumanReadableName()@"received invalid class VID (was "$VID$"), returning none");
	return;	
	
}

function bool BotBuyVehicle(string VID)
{
	local Rx_PurchaseSystem PurchaseSystem;
	local int PickedVehicle, VehicleCost;

	PurchaseSystem = Rx_Game(WorldInfo.Game).GetPurchaseSystem();
	PickedVehicle = -1;

	if(PurchaseSystem.AreVehiclesDisabled(GetTeamNum(), None))
		return false;

	ParseBuyVehicle(VID,PickedVehicle,VehicleCost);

	if(PickedVehicle == -1)
	{
		`warn(GetHumanReadableName()@"received invalid vehicle request. Cancelling order");
		return false;
	}


	if(VehicleCost <= GetCredits() && PurchaseSystem.PurchaseVehicle(Rx_Pri(PlayerReplicationInfo), GetTeamNum(), PickedVehicle)) 	
	{
		SetBaughtVehicle(PickedVehicle);
		return true;
	}

	else
	{
//		`log(GetHumanReadableName()@"failed buying vehicle");
		return false;
	}

}

function bool BotBuyBeacon()
{
	if(GetCredits() < 1000)
		return false;

	Rx_PRI(PlayerReplicationInfo).RemoveCredits(1000);

	if(GetTeamNum() == 0)
		Pawn.InvManager.CreateInventory(class'Rx_Weapon_IonCannonBeacon');
	else
		Pawn.InvManager.CreateInventory(class'Rx_Weapon_NukeBeacon');

	return true;
}

// NEW PURCHASE LOGIC ENDS HERE
// Keeping old one to handle purchases when bot just respawned

function class<UTFamilyInfo> BotBuy(Rx_Bot Bot, bool bJustRespawned, optional string SpecificOrder)
{
	local int PickedVehicle;
	local array<class<Rx_FamilyInfo> > PotentialPicks;
	local class<Rx_FamilyInfo> PickedClass;
	local Rx_PurchaseSystem PurchaseSystem;
	local int MaxPickCost;
	local int LastTargetMoney;
	
	PurchaseSystem = Rx_Game(WorldInfo.Game).GetPurchaseSystem();

	if(SpecificOrder == "" && Rx_SquadAI(Squad).bOnboardForTactics)
	{
		if(Bot.GetTeamNum() == 0)
		{
			return class'Rx_FamilyInfo_GDI_Soldier';
		}
		else
		{
			return class'Rx_FamilyInfo_Nod_Soldier';
		}
	}

	LastTargetMoney = Bot.TargetMoney;

	if(SpecificOrder == "")
	{
		if(bCheetozBotz && Rand(10) > 5 && Bot.GetOrders() == 'ATTACK')
		{	
			if(GetTeamNum() == Team_GDI)
				return class'Rx_FamilyInfo_GDI_Sydney_Suit';
			else
				return class'Rx_FamilyInfo_Nod_Raveshaw_Mutant';
		}

		if(Bot.TargetMoney == 0) 
			Bot.TargetMoney = Bot.GetNewTargetMoney();	

		if(Bot.GetCredits() >= LastTargetMoney) 
		{
			PickedVehicle = -1;
			MaxPickCost = Bot.GetCredits();
			
			if(Bot.GetOrders() == 'ATTACK')
			{
				// Offense
				if (Bot.GetCredits() >= 350 && !PurchaseSystem.AreVehiclesDisabled(GetTeamNum(), None) && FRand() <= 0.3)
				{
					// Pick offensive vehicle
					if(Bot.GetTeamNum() == TEAM_GDI)
						PickedVehicle = GetGdiVehicle();	
					else
						PickedVehicle = GetNodVehicle();
					
					// We only want a free infantry
					MaxPickCost = 0;
				}
				// Pick offensive infantry
				PotentialPicks = OffensiveClasses();
			}
			else // Pick defensive infantry
				PotentialPicks = DefensiveClasses();
		
			// Filter picks to what we can afford
			PotentialPicks = FilterCredits(PotentialPicks, MaxPickCost);
		
			// Make a pick
			if (PotentialPicks.Length > 0)
				PickedClass = PotentialPicks[Rand(PotentialPicks.Length)];
		}
	
		if(PickedVehicle != -1) 
		{
			if(PurchaseSystem.PurchaseVehicle(Rx_Pri(Bot.PlayerReplicationInfo), Bot.GetTeamNum(), PickedVehicle)) 	
				Bot.SetBaughtVehicle(PickedVehicle);
		}
	
		if(PickedClass != None) 
		{
			Rx_Pri(Bot.PlayerReplicationInfo).RemoveCredits(PickedClass.default.BasePurchaseCost);
			Bot.TargetMoney = 0;

			if(PickedVehicle == -1 && Skill > 8 && GetOrders() == 'ATTACK' && Rand(10) > 4)
			{
				if(GetTeamNum() == 0)
					Pawn.InvManager.CreateInventory(class'Rx_Weapon_IonCannonBeacon');
				else
					Pawn.InvManager.CreateInventory(class'Rx_Weapon_NukeBeacon');
			}

				`LogRxPub("GAME" `s "Purchase;" `s "character" `s PickedClass.name `s "by" `s `PlayerLog(Bot.PlayerReplicationInfo));
				return PickedClass;
		
		} 
		else if(Bot.GetCredits() > 0) {
			Bot.DeathsTillTargetMoneySwitch--;
		}
	}
	else if(SpecificOrder == "ENGINEERCLASS")
	{
		if(Bot.GetTeamNum() == TEAM_GDI)
		{
			if(Bot.GetCredits() >= 350)
			{
				PickedClass = class'Rx_FamilyInfo_GDI_Hotwire';
				Rx_Pri(Bot.PlayerReplicationInfo).RemoveCredits(350);
			}
			else
				PickedClass = class'Rx_FamilyInfo_GDI_Engineer';
		}
		else
		{
			if(Bot.GetCredits() >= 350)
			{
				PickedClass = class'Rx_FamilyInfo_Nod_Technician';
				Rx_Pri(Bot.PlayerReplicationInfo).RemoveCredits(350);
			}
			else
				PickedClass = class'Rx_FamilyInfo_Nod_Engineer';
		}
		Bot.TargetMoney = 0;

		return PickedClass;
	}
	
	if(bJustRespawned) {
		return PurchaseSystem.GetStartClass(Bot.Pawn.GetTeamNum(), PlayerReplicationInfo);
	} else {
		return UTPlayerReplicationInfo(Bot.PlayerReplicationInfo).CharClassInfo;
	}
}

function bool ActorInBuilding(Actor A, optional out Rx_Building B)
{
	local vector Dummy1,Dummy2;

	if(A == None)
		return false;

	B = Rx_Building(Trace(Dummy1, Dummy2, A.location + vect(0,0,2000), A.location, TRUE, , , TRACEFLAG_Bullet));

	if(B != None)
		return true;

	return false;
}

function bool ShouldRebuy(int ClassValue)				// Handepsilon - Can we afford to rebuy character?
{
	local int ConsideredValue, CurrentClassValue;

	ConsideredValue = ClassValue*2;
	CurrentClassValue = class<Rx_FamilyInfo>(Rx_Pri(PlayerReplicationInfo).CharClassInfo).static.Cost(Rx_Pri(PlayerReplicationInfo));

	//Skip calculation altogether for freebies
	if(CurrentClassValue <= 0)
		return true;

	//Check credits, see if we can afford to lose the current character
	if(ConsideredValue > CurrentClassValue || (CurrentClassValue*5 < GetCredits()))
		return true;

	return false;
}

function int GetGdiVehicle() {

	local int PickedVehicle;

	if(GetCredits() >= 15000) {
		if(!Rx_MapInfo(WorldInfo.GetMapInfo()).bAircraftDisabled && FRand() < 0.3)
			return 7;	
		else
			return Rand(5);
	}
	
	if(GetCredits() >= 1500 && FRand() <= 0.20) {
		PickedVehicle = 4; // Mammoth
	} else if(GetCredits() >= 900 && !Rx_MapInfo(WorldInfo.GetMapInfo()).bAircraftDisabled && FRand() <= 0.6) {
		PickedVehicle = 7; // Orca
	} else if(GetCredits() >= 800 && FRand() <= 0.6) {
		PickedVehicle = 3; // MedTank
	} else if(GetCredits() >= 450 && FRand() <= 0.6) {
		PickedVehicle = 2; // MRLS
 	} else if(GetCredits() >= 500 && FRand() <= 0.5) {
		PickedVehicle = 1; // APC
	} else if(GetCredits() >= 350) {
		PickedVehicle = 0; // Humvee
	}
	return PickedVehicle;
}

function int GetNodVehicle() {

	local int PickedVehicle;

	if(GetCredits() >= 15000) {
		if(!Rx_MapInfo(WorldInfo.GetMapInfo()).bAircraftDisabled && FRand() < 0.3)
			return 7;	
		else	
			return Rand(6);
	}
	if(GetCredits() >= 900 && FRand() <= 0.4) {
		PickedVehicle = 5; // StealhTank
 	} else if(GetCredits() >= 900 && !Rx_MapInfo(WorldInfo.GetMapInfo()).bAircraftDisabled && FRand() <= 0.6) {
		PickedVehicle = 7; // Apache		
	} else if(GetCredits() >= 600 && FRand() <= 0.6) {
		PickedVehicle = 4; // LightTank
	} else if(GetCredits() >= 450 && FRand() <= 0.6) {
		PickedVehicle = 2; // Artillery
	} else if(GetCredits() >= 800 && FRand() <= 0.4) {
		PickedVehicle = 3; // FlameTank
	} else if(GetCredits() >= 500 && FRand() <= 0.5) {
		PickedVehicle = 1; // APC
	} else if(GetCredits() >= 300) {
		PickedVehicle = 0; // Buggy
	}
	return PickedVehicle;
}


function ResetSkill()
{
	Super.ResetSkill();

	if(Skill >= 9)
	{
		bCheetozBotz = true;
		Rx_PRI(PlayerReplicationInfo).AddCredits(90010);
		Aggressiveness = 1;
		BaseAggressiveness = Aggressiveness;
		Accuracy = 5;
		StrafingAbility = 5;
		Tactics = 5;
		ReactionTime = 5;
		RefillDelay = 0.1;
		Rx_PRI(PlayerReplicationInfo).TickVPToFull();
	}
}

//Rx_Controller rollover

/**Set modifiers**/

function AddActiveModifier(class<Rx_StatModifierInfo> Info)//class<Rx_StatModifierInfo> Info) 
{
	local int FindI; 
	local ActiveModifier TempModifier; 
	//local class<Rx_StatModifierInfo> Info; 
	
	//Info = class'Rx_StatModifierInfo_Nod_PTP';
	
	FindI = ActiveModifications.Find('ModInfo', Info);
	
	//Do not allow stacking of the same modification. Instead, reset the end time of said modification
	if(FindI != -1) 
	{
		//`log("Found in array");
		ActiveModifications[FindI].EndTime = WorldInfo.TimeSeconds+Info.default.Mod_Length; 
		//return; 	
	}
	else //New modifier, so add it in and re-update modification numbers
	{
		//`log("Adding to array"); 
		TempModifier.ModInfo = Info; 
		if(Info.default.Mod_Length > 0) TempModifier.EndTime = WorldInfo.TimeSeconds+Info.default.Mod_Length;
		else
		TempModifier.Permanent = true; 
		ActiveModifications.AddItem(TempModifier);	
	}
	
	UpdateModifiedStats(); 
}


function UpdateModifiedStats()
{
	local ActiveModifier TempMod;
	local byte			 HighestPriority; 
	//local LinearColor	 PriorityColor; 
	local bool			 bAffectsWeapon;
	local class<Rx_StatModifierInfo> PriorityModClass; /*Highest priority modifier class (For deciding what overlay to use)*/
	
	ClearAllModifications(); //start from scratch
	HighestPriority = 255 ; // 255 for none
	
	if(ActiveModifications.Length < 1) 
	{
		if(Rx_Pawn(Pawn) != none) 
		{
			//In case speed was modified. Update animation info
			Rx_Pawn(Pawn).SetSpeedUpgradeMod(0.0);
			Rx_Pawn(Pawn).UpdateRunSpeedNode(); 
			Rx_Pawn(Pawn).SetGroundSpeed();
			Rx_Pawn(Pawn).ClearOverlay();
		}
		else if(Rx_Vehicle(Pawn) != none)
		{
			Rx_Vehicle(Pawn).ClearOverlay();
		}
		//TODO: Insert code to handle vehicles 
		return; 	
	}
	
	foreach ActiveModifications(TempMod) //Build all buffs
	{
		Misc_SpeedModifier+=TempMod.ModInfo.default.SpeedModifier;	
		Misc_DamageBoostMod+=TempMod.ModInfo.default.DamageBoostMod;	
		Misc_RateOfFireMod-=TempMod.ModInfo.default.RateOfFireMod;
		Misc_ReloadSpeedMod-=TempMod.ModInfo.default.ReloadSpeedMod;
		Misc_DamageResistanceMod-=TempMod.ModInfo.default.DamageResistanceMod;
		Misc_RegenerationMod+=TempMod.ModInfo.default.RegenerationMod;
		bAffectsWeapon=TempMod.ModInfo.static.bAffectsWeapons();
		if(TempMod.ModInfo.default.EffectPriority < HighestPriority || TempMod.ModInfo.default.EffectPriority == 0) 
		{
			HighestPriority = TempMod.ModInfo.default.EffectPriority;
			//PriorityColor = TempMod.ModInfo.default.EffectColor;
			PriorityModClass = TempMod.ModInfo;
		}
	}
	
	
	if(Rx_Pawn(Pawn) != none) 
	{
		//In case speed was modified. Update animation info
		Rx_Pawn(Pawn).SetSpeedUpgradeMod(Misc_SpeedModifier);
		Rx_Pawn(Pawn).UpdateRunSpeedNode();
		Rx_Pawn(Pawn).SetGroundSpeed();
		Rx_Pawn(Pawn).SetOverlay(PriorityModClass, bAffectsWeapon) ; 
		
		if(Rx_Weapon(Pawn.Weapon) != none) Rx_Weapon(Pawn.Weapon).SetROFChanged(true);	
	}
	else if(Rx_Vehicle(Pawn) != none) 
	{
		//Misc_SpeedModifier+=1.0; //Add one to account for vehicles not operating like Rx_Pawn 
		Rx_Vehicle(Pawn).UpdateThrottleAndTorqueVars();
		Rx_Vehicle(Pawn).SetOverlay(PriorityModClass.default.EffectColor) ; 
		
		if(Rx_Vehicle_Weapon(Pawn.Weapon) != none) Rx_Vehicle_Weapon(Pawn.Weapon).SetROFChanged(true);	
	}
}

function ClearAllModifications()
{
	//Buff/Debuff modifiers
	Misc_SpeedModifier 			= default.Misc_SpeedModifier;

	//Weapons
	Misc_DamageBoostMod 		= default.Misc_DamageBoostMod; 
	Misc_RateOfFireMod 			= default.Misc_RateOfFireMod; 
	Misc_ReloadSpeedMod 		= default.Misc_ReloadSpeedMod; 

	//Survivablity
	Misc_DamageResistanceMod 	= default.Misc_DamageResistanceMod;
	Misc_RegenerationMod 		= default.Misc_RegenerationMod; 	
}

function RemoveAllEffects()
{
	ActiveModifications.Length = 0; 
	
	UpdateModifiedStats(); 
}

function CheckActiveModifiers()
{
	local ActiveModifier TempMod;
	local float			 TimeS; 
	
	if(ActiveModifications.Length < 1) return; 
	
	TimeS=WorldInfo.TimeSeconds; 
	
	//Should never be more than 1 or 2 of these at any given time, so shouldn't affect tick, though can be moved to a timer if necessary. 
	foreach ActiveModifications(TempMod) 
	{
		if(!TempMod.Permanent && TimeS >= TempMod.EndTime) 
		{
			ActiveModifications.RemoveItem(TempMod);
			
			UpdateModifiedStats(); 
		}
	}
}


/****End Modifier Functions*****/

function StartSprinting()
{
	if(Rx_Pawn(pawn) == None || Rx_Pawn(pawn).bSprinting) {
		return;
	} 
	Rx_Pawn(pawn).StartSprint();
}

function StopSprinting()
{
	if(Rx_Pawn(pawn) == None || !Rx_Pawn(pawn).bSprinting) {
		return; 
	} 
	Rx_Pawn(pawn).StopSprinting();
}

function bool FireWeaponAt(Actor A)
{
	StopSprinting();

	if ( A == None )
		A = Enemy;
	if (A == None)
		return false;

	if(Rx_Weapon_RechargeableGrenade(Pawn.Weapon) != None && Rx_Weapon_RechargeableGrenade(Pawn.Weapon).bReadyToFire())
		return WeaponFireAgain(false);

	if (Focus != A)
	{
		if(Rx_BuildingAttachment(Focus) == None || Rx_Weapon_RepairGun(Pawn.Weapon) == None)
			return false;
	}

	if ( Pawn.Weapon != None )
	{
		if ( Pawn.Weapon.HasAnyAmmo() )
			return WeaponFireAgain(false);
	}
	else
		return WeaponFireAgain(false);

	return false;

}

function bool WeaponFireAgain(bool bFinishedFire)
{
	LastFireAttempt = WorldInfo.TimeSeconds;
	bFireSuccess = false;
	if(Rx_Weapon_Beacon(Pawn.Weapon) != None && !Rx_Weapon_Beacon(Pawn.Weapon).IsInState('Charging'))
	{
		return true;
	}
	if (ScriptedTarget != None)
	{
		Focus = ScriptedTarget;
	}
	else if (Focus == None)
	{
		Focus = Enemy;
	}
	if (Focus != None)
	{
		if ( !Pawn.IsFiring() )
		{
			if ( (Pawn.Weapon != None && (Pawn.Weapon.bMeleeWeapon || (Rx_Weapon_RechargeableGrenade(Pawn.Weapon) != None && Rx_Weapon_RechargeableGrenade(Pawn.Weapon).bReadyToFire()))) || Rx_Weapon_RepairGun(Pawn.Weapon) != None || (!Pawn.NeedToTurn(GetFocalPoint()) && CanAttack(Focus)) )
			{
				LastCanAttackCheckTime = WorldInfo.TimeSeconds;
				bCanFire = true;
				bStoppedFiring = false;
				bFireSuccess = Pawn.BotFire(bFinishedFire);
				LastFireTarget = Focus;
				return bFireSuccess;
			}
			else
			{
				bCanFire = false;
			}
		}
		else if ( bCanFire && ShouldFireAgain() )
		{
			if ( !Focus.bDeleteMe )
			{
				bStoppedFiring = false;
				bFireSuccess = Pawn.BotFire(bFinishedFire);
				LastFireTarget = Focus;
				return bFireSuccess;
			}
		}
	}
	StopFiring();
	return false;
}

function StopMovement()
{
	StopSprinting();
	super.StopMovement();
}

function DoTacticalMove()
{
	StopSprinting();
	super.DoTacticalMove();
}

function PromoteMe(byte rank)
{
	if(rank > 3) return; 
	if( Rx_Vehicle(Pawn) !=none) Rx_Vehicle(Pawn).PromoteUnit(rank) ; 
	else
	if( Rx_Pawn(Pawn) !=none) Rx_Pawn(Pawn).PromoteUnit(rank) ; 
}

function bool HasRepairGun(optional bool bMandatory)
{
	local class<UTFamilyInfo> FamInfo;

	FamInfo = Rx_Pri(PlayerReplicationInfo).CharClassInfo;
	
	if((PTTask == "" || PTTask == "Buy Char - AdvEngi") && (FamInfo == class'Rx_FamilyInfo_Nod_Engineer' || FamInfo == class'Rx_FamilyInfo_GDI_Engineer') && GetCredits() >= 350)
	{
		if(!Rx_Game(WorldInfo.Game).GetPurchaseSystem().AreHighTierPayClassesDisabled(GetTeamNum()))
		{
			PTTask = "Buy Char - AdvEngi";
			return true;
		}
	}

	if( Rx_Game(WorldInfo.Game).PurchaseSystem.DoesHaveRepairGun( FamInfo ) ) 
	{
		return true;
	}

	if(bMandatory && ShouldRebuy(350) && (PTTask == "" || PTTask == "Buy Char - Engi" || PTTask == "Buy Char - AdvEngi"))
	{
		if(GetCredits() > 350)
			PTTask = "Buy Char - AdvEngi";
		else
			PTTask = "Buy Char - Engi";
		return true;
	}

	return false;
	
}

function int GetCredits() 
{
	local int TempCred;

	TempCred = Rx_Pri(PlayerReplicationInfo).GetCredits() - MoneySaving;

	if(TempCred > 0)
		return TempCred;

	return 0;
}

function int GetNewTargetMoney() 
{	
	if(GetOrders() == 'Defend') 
	{
		if (FRand() <= 0.6)
			return 350;

		if (FRand() <= 0.6)
			return 500;
	
		if (FRand() <= 0.6)
			return 750;
		
		return 225;
	}
	if(GetTeamNum() == TEAM_GDI) 
		return GetNewTargetMoneyGDI();

	else 
		return GetNewTargetMoneyNod();
	
}

function int GetNewTargetMoneyGDI() 
{	
	local float Rand;
	local int CurrentCredits;
	
	CurrentCredits = Rx_Pri(PlayerReplicationInfo).GetCredits();
	Rand = FRand();
	
	if (Rand <= 0.5)
	{
		if (CurrentCredits < 225)
			return 225;	

		else if (CurrentCredits < 500)
			return 500;

		else
			return 900;
		
	} 
	else if (Rand < 0.8) 
	{
		if (CurrentCredits < 225) 
			return 225;	

		else if (CurrentCredits < 500) 
			return 750;

		else 
			return 900;

	} 
	else 
	{
		if (CurrentCredits < 225) 
			return 500;	
		
		else if (CurrentCredits < 500) 
			return 900;

		else if(FRand() <= 0.5) 
			return 1500;
		
		else	
			return 900;
	}
}

function int GetNewTargetMoneyNod() 
{	
	local float Rand;
	local int CurrentCredits;
	
	CurrentCredits = Rx_Pri(PlayerReplicationInfo).GetCredits();
	Rand = FRand();
	if (Rand < 0.5) 
	{
		if (CurrentCredits < 225) 
			return 225;

		else if (CurrentCredits < 500)
			return 500;

		else 
			return 600;
		
	} 
	else if (Rand < 0.8) 
	{
		if (CurrentCredits < 225)
			return 225;	

		else if (CurrentCredits < 500) 
			return 750;

		else
			return 900;
			
	} 
	else 
	{
		if (CurrentCredits < 225)
			return 500;	

		else if (CurrentCredits < 500)
			return 800;

		else
			return 900;
		
	}
}

function PawnDied(Pawn P)
{
	if ( Pawn != P )
		return;
	Super.PawnDied(P);
	bAttackingEnemyBase = false;
	bInvalidatePreviousSO = true;
	if(PTTask == "Refill")
		PTTask = "";
	bInfiltrating = false;
	bJustRebought = false;
	bCanPlayEnemySpotted = true;
	bEquippedForTactics = false;
	bReadyForTactics = false;


	if(Rx_SquadAI(Squad) != None && Rx_SquadAI(Squad).CurrentTactics != None && Rx_SquadAI(Squad).bTacticsCommenced)
	{	
		if(GetCredits() < Rx_SquadAI(Squad).CurrentTactics.CreditsNeeded)
		{
			bOnboardForTactics = false;
			Rx_SquadAI(Squad).DiscardFromTactic();
		}
		else
		{

		}
	}

}

function SetLastSupportHealTime()
{
	LastSupportHealTime = WorldInfo.TimeSeconds;
	
}


function SetRadarVisibility(byte Visibility)
{
	//`log("--------- BOT set Pawn Radar Visibility---------" @ RadarVisibility) ; 
	RadarVisibility = Visibility; 
	if(Rx_Pawn(Pawn) != none ) Rx_Pawn(Pawn).SetRadarVisibility(Visibility); 
	else
	if(Rx_Vehicle(Pawn) != none ) Rx_Vehicle(Pawn).SetRadarVisibility(Visibility); 
}

simulated function byte GetRadarVisibility()
{
	return RadarVisibility; 
}

function CheckRadarVisibility()
{
	local Actor CommTower;
	local Rx_GRI GRI; 
	
	GRI = Rx_GRI(WorldInfo.GRI); 
		//`log("controller check Radar Visibility") ; 
		foreach GRI.TechBuildingArray(CommTower)
		{
			if(CommTower.isA('Rx_Building_CommCentre_Internals') == false)
				continue; 
			
			if(CommTower.GetTeamNum() < 0 || CommTower.GetTeamNum() > 1  ) 
				return; 
			
			if(CommTower.GetTeamNum() == GetTeamNum() ) 
				SetRadarVisibility(1);
			
			else if(CommTower.GetTeamNum() != GetTeamNum() ) 
				SetRadarVisibility(2);
			
			break;
		
		}
}

function SetSpottedRadarVisibility()
{
	LastRadarVisibility = RadarVisibility; 
	
	SetRadarVisibility(2); //Set full visible from spotting
	
	SetTimer(8.0,false, 'ResetRadarVisibility' ); //8 seconds just seems fair
}

function ResetRadarVisibility()
{
	SetRadarVisibility(LastRadarVisibility); 
}

simulated function Actor GetFocus() {
	return Focus;
}

function DisseminateVPString(coerce string VPString)
{
	local int VP_Total, WorkingLength; 
	local string CurStr; //Hold our string as it's broken up
	local string StringPiece; //Current piece of string we're working with 
	
	CurStr = VPString ;
	while ( Instr(CurStr,"&") != -1) 
	{
		//First piece should ALWAYS be a string
		StringPiece = Left(CurStr, InStr(CurStr, "&"));
		//Feat_List.AddItem(StringPiece); 
		CurStr=Right(CurStr, (Len(CurStr)-(Len(StringPiece)+1) )); //Delete the piece we were working with

		//Second piece should ALWAYS be a number
		StringPiece = Left(CurStr, InStr(CurStr, "&"));
		
		WorkingLength=int(StringPiece);  //Repurposed variable
		VP_Total+=WorkingLength;
		 
		CurStr=Right(CurStr, (Len(CurStr)-(Len(StringPiece)+1) )); //Delete the piece we were working with
	}
	
	Rx_PRI(PlayerReplicationInfo).AddVP(VP_Total);
	
	
	
}


/****End Active Modifier Functions******/

function SetBaughtVehicle(int vehIndex) 
{
	BaughtVehicleIndex = vehIndex;
	if(BaughtVehicleIndex == -1) 
		BaughtVehicle = None;

	OrdersBeforeBaughtVehicle = GetOrders();
}

function ResetVehStationary() 
{
	shouldWaitVehicle.bStationary = false;
}

function setShouldWait(UTVehicle shouldWaitVeh)
{
	SetTimer(Rand(2) + 1,false,'ResetVehStationary');
	shouldWaitVehicle = shouldWaitVeh;
}

function Actor GetAGT()
{
	local Rx_Sentinel_AGT_Rockets_Base AdGT;
	if(Rx_Game(WorldInfo.Game).AGT == None)
		return None;	
	if(AGT != None) return AGT;
	ForEach DynamicActors(class'Rx_Sentinel_AGT_Rockets_Base', AdGT) {
		AGT = AdGT;
	}
	return AGT;		
}

function LeftVehicle()
{

}





function EnteredVehicle()
{
/*
	if(BaughtVehicleIndex != -1) {
		if(OrdersBeforeBaughtVehicle != GetOrders()) {
			if(OrdersBeforeBaughtVehicle == 'ATTACK') { // because while waiting for the veh orders are set to DEFEND
				Rx_TeamInfo(PlayerReplicationInfo.Team).AI.PutOnOffense(self);	
			} else if(OrdersBeforeBaughtVehicle == 'FREELANCE') {
				// todo
			}
		}
		BaughtVehicleIndex = -1;
		BaughtVehicle = None;
	} else if(GetOrders() == 'Defend') {
		Rx_TeamInfo(PlayerReplicationInfo.Team).AI.PutOnOffense(self);
		Rx_TeamAi(Rx_TeamInfo(PlayerReplicationInfo.Team).AI).NumBotsToSwitchToDefense++;
	} else if(Rx_AreaObjective(squad.SquadObjective) != None && Rx_AreaObjective(squad.SquadObjective).bBlockedForVehicles){
		Rx_TeamInfo(PlayerReplicationInfo.Team).AI.PutOnOffense(self);
	}
	*/
	if(BaughtVehicleIndex != -1)
	{
		BaughtVehicleIndex = -1;
		BaughtVehicle = None;
	}
}


function Actor GetObelisk()
{
	local Rx_Sentinel_Obelisk_Laser_Base Ob;

	if(Rx_Game(WorldInfo.Game).Obelisk == None)
		return None;

	if(Obelisk != None || !Rx_Building_Defense(Obelisk.MyBuilding).bDisabled) 
		return Obelisk;
	
	ForEach DynamicActors(class'Rx_Sentinel_Obelisk_Laser_Base', Ob) 
	{
		if(!Rx_Building_Defense(Ob.MyBuilding).bDisabled)
			Obelisk = Ob;
	}
	return Obelisk;		
}

/*
function MoveToDefensePoint()
{
	if(IsInState('Defending')) 
	{
		if(HasRepairGun() && DefendedBuildingNeedsHealing()) 
			CurrentBO.TellBotHowToHeal(Self);	

		
		
	}
	GotoState('Defending', 'Begin');
}
*/

function bool ShouldDefendPosition()
{

    if(HasRepairGun() && DefendedBuildingNeedsHealing()) 
    {
			MoveToDefensePoint();
    		return true;
    }

    if(bStrafingDisabled && Pawn.Anchor == None) {
    	return false;
    }
    
    return super.ShouldDefendPosition();
}

function bool IsHealing(bool bOrAboutToHeal) {
    if(IsInState('RangedAttack') || IsInState('Defending') || bOrAboutToHeal) 
    {
    	if(!bOrAboutToHeal && bStoppedFiring)
    		return false;

    	if(Rx_Weapon_DeployedActor(Focus) != None)
    		return true;

    	if((Rx_BuildingAttachment(Focus) != None && Rx_BuildingAttachment(Focus).GetTeamNum() == GetTeamNum()) || (Rx_Building(Focus) != None && Rx_Building(Focus).GetTeamNum() == GetTeamNum()))
    		return true; 
    	
    	else if(Rx_BuildingObjective(Focus) != None && Rx_BuildingObjective(Focus).GetTeamNum() == GetTeamNum() 
    			&& Rx_BuildingObjective(Focus).NeedsHealing()) 
    		return true;
    	
    	else  if(UTVehicle(Focus) != None && (UTVehicle(Focus).GetTeamNum() == GetTeamNum() || UTVehicle(Focus).GetTeamNum() == 255))
    	{
    		if(Rx_Vehicle(Focus).NeedsHealing() || bOrAboutToHeal) 
    			return true;
    	}

    }
    return false;
}

function bool CanStakeOut()
{
	if((Pawn.Weapon != None && Rx_Weapon_RepairGun(Pawn.Weapon) != None) || bInfiltrating) {
		return false;
	}

	return super.CanStakeOut();
}

function bool VehicleShouldAttackEnemyInRush()
{
	if(Enemy == None)
		return false;

	if((CanAttack(Enemy) && VSize(Enemy.Location-Pawn.Location) <= 250) || (Rx_Pawn(Enemy) != None && Rx_Weapon(Rx_Pawn(Enemy).Weapon) != None && Rx_Weapon(Rx_Pawn(Enemy).Weapon).bOkAgainstVehicles) 
		|| (Rx_Pawn(Enemy) != None && Rx_Game(WorldInfo.Game).PurchaseSystem.DoesHaveRepairGun(Rx_Pri(Enemy.PlayerReplicationInfo).CharClassInfo)))
	{
		LastCanAttackCheckTime = WorldInfo.TimeSeconds;
		return true; 
	}

	return false;
}

exec function SwitchToBestWeapon(optional bool bForceNewWeapon)
{
	local Rx_Building B;
	local Rx_Weapon_RepairGun R;
	local Rx_Weapon_SmokeGrenade_Rechargeable Smoke;
	local Rx_Weapon_EMPGrenade_Rechargeable EMP;

	if ( Pawn == None || Pawn.InvManager == None  || Vehicle(Pawn) != None) 
		return;

	if(HasRepairGun() && Focus != Enemy && IsHealing(True))
	{
		if(Rx_Weapon_RepairGun(Pawn.Weapon) != None)
			return;

		ForEach Pawn.InvManager.InventoryActors( class'Rx_Weapon_RepairGun', R )
		{
			Pawn.InvManager.SetCurrentWeapon(R);
			return;

		}

	}

	if(Focus != Enemy && Rx_BuildingObjective(Squad.SquadObjective) != None && IsInBuilding(B) && B.GetTeamNum() != GetTeamNum() && !B.IsDestroyed() 
		&& VSize(Rx_BuildingObjective(Squad.SquadObjective).myBuilding.GetMCT().Location - Pawn.Location) < 500 && SwitchToC4())
		return;

	//	Smoke grenade - Try to choose if needed to disorient enemy

	if(Enemy != None && Focus == Enemy && (Rx_Pawn(Pawn).Armor < Rx_Pawn(Pawn).ArmorMax * 0.25 || Skill > 6.0))
	{
		if((Rx_Weapon_SmokeGrenade_Rechargeable(Pawn.Weapon) != None && Rx_Weapon_SmokeGrenade_Rechargeable(Pawn.Weapon).bReadyToFire()))
			return;

		if(FRand() >= 2/Skill)
		{
			Smoke = Rx_Weapon_SmokeGrenade_Rechargeable(Pawn.InvManager.FindInventoryType(Class'Rx_Weapon_SmokeGrenade_Rechargeable', true));

			if(Smoke != None && Smoke.bReadyToFire())
			{
				Pawn.InvManager.SetCurrentWeapon(Smoke);
				return;
			}
		}
	}

	//	EMP grenade - Try to choose if needed to disorient enemy

	if(Rx_Vehicle(Focus) != None && Rx_Defence(Focus) == None && Rx_Defence_Emplacement(Focus) == None)
	{
		if((Rx_Weapon_EMPGrenade_Rechargeable(Pawn.Weapon) != None && Rx_Weapon_EMPGrenade_Rechargeable(Pawn.Weapon).bReadyToFire()))
			return;

		if(FRand() >= 1.4/Skill)
		{
			EMP = Rx_Weapon_EMPGrenade_Rechargeable(Pawn.InvManager.FindInventoryType(Class'Rx_Weapon_EMPGrenade_Rechargeable', true));

			if(EMP != None && EMP.bReadyToFire())
			{
				Pawn.InvManager.SetCurrentWeapon(EMP);
				return;
			}
		}
	}

	if(Rx_Vehicle(Enemy) != None && !Rx_Weapon(Pawn.Weapon).bOkAgainstVehicles && !Rx_Vehicle(Enemy).bLightArmor && !Rx_Vehicle(Enemy).bIsAircraft && SwitchToC4())
		return;

		
	super.SwitchToBestWeapon(bForceNewWeapon);
}

state Dead
{


	function bool FireWeaponAt(Actor A)
	{
		`log(self @ "FireWeaponAt while Dead");
		return false;
	}

}

state RoundEnded
{

	function BeginState(Name PreviousStateName)
	{
		StopMovement();

		Super.BeginState(PreviousStateName);
	}

	function MoveToDefensePoint()
	{
		`log(self @ "MoveToDefensePoint while RoundEnded");
	}

	function SetBaughtVehicle(int vehIndex) 
	{
		`log(self @ "SetBaughtVehicle while RoundEnded");
	}

	function ChooseAttackMode()
	{
		`log(self @ "ChooseAttackMode while RoundEnded");
	}

	function DoRandomJumps()
	{
		`log(self @ "DoRandomJumps while RoundEnded");
	}

	function DoTacticalMove()
	{
		`log(self @ "DoTacticalMove while RoundEnded");
	}

	function DoCharge()
	{
		`log(self @ "DoCharge while RoundEnded");
	}

	function DoStakeOut()
	{
		`log(self @ "DoStakeOut while RoundEnded");
	}

	function WaitAtAreaTimer() 
	{
		`log(self @ "WaitAtAreaTimer while RoundEnded");
	}

	function bool FireWeaponAt(Actor A)
	{
		`log(self @ "FireWeaponAt while RoundEnded");
		return false;
	}
}

function bool NeedWeapon()
{
	return false;
}

// CATEGORY : BOT RADIO SYSTEM
//
//	All function regarding bot communcations go here
//
//

function MsgCooldown()
{
	bCanTalk = true;
}

function BroadcastDeployableSpotMessage(Rx_Weapon_DeployedActor DA)
{	
	local string BuildingName;

	if(!bCanTalk)
		return;

	if(DA == None)
	{
		return;
	}
	if(LineOfSightTo(DA))
	{
		if(Rx_Weapon_DeployedBeacon(DA) != None)
		{
			if(DA.GetTeamNum() == GetTeamNum())
				BroadCastSpotMessage(15, "Defend BEACON"@GetSpottargetLocationInfo(Rx_Weapon_DeployedBeacon(DA))@"!!!");
			else
				BroadCastSpotMessage(-1, "I've located an ENEMY BEACON"@GetSpottargetLocationInfo(Rx_Weapon_DeployedBeacon(DA))@"!!!");	
		}
		else if (Rx_Weapon_DeployedC4(DA) != None)
		{	
			if(Rx_Building(Rx_Weapon_DeployedC4(DA).ImpactedActor) != None)
				BuildingName = Rx_Weapon_DeployedC4(DA).ImpactedActor.GetHumanReadableName();

			if(BuildingName == "MCT" || Rx_Building(Rx_Weapon_DeployedC4(DA).ImpactedActor) != None)
			{	
				if(BuildingName == "MCT")
					BuildingName = "MCT"@GetSpottargetLocationInfo(Rx_Weapon_DeployedC4(DA));			
				if(DA.GetTeamNum() == GetTeamNum())
					BroadCastSpotMessage(15, "Defend &gt;&gt;C4&lt;&lt; at "@BuildingName@"!!!");
				else if (Rx_Building(Rx_Weapon_DeployedC4(DA).ImpactedActor).GetTeamNum() == GetTeamNum())
					BroadCastSpotMessage(-1, "I've located an ENEMY &gt;&gt;C4&lt;&lt; at "@BuildingName@"!!!");
			}
		}
	}

	else
	{
		if(Rx_Weapon_DeployedBeacon(DA) != None && DA.GetTeamNum() != GetTeamNum() && Skill > 5)	// Skilled enough Bots can announce beacon from afar
		{
			BroadCastSpotMessage(25, "I'm detecting a BEACON near"@GetSpottargetLocationInfo(Self)@"!!!");
		}
	}
}

function BroadcastBuildingSpotMessages(Rx_Building Building) 
{
	local String msg;
	local int nr;
	
	if(!bCanTalk)
		return;

	if(Building.GetTeamNum() == GetTeamNum()) 
	{
		
		if(Building.GetMaxArmor() <= 0) 
		{ /*We're not using armour*/
		
		if(Building.GetHealth() == Building.GetMaxHealth() || Rx_Building_Techbuilding(Building) != none) { 
			
			msg = "Defend the "$Building.GetHumanReadableName()$"!";
			
			if(Rx_Building_Refinery(Building) != None)
				nr = 28;
			else if(Rx_Building_PowerPlant(Building) != None)
				nr = 29;
			else
				nr = 27;
		}
		else if((Building.GetHealth() + Building.GetArmor()) > Building.GetMaxHealth()/3) 
		{
			msg = "The"@Building.GetHumanReadableName()@ "<font color='"$ArmourColor$"'>"$Building.GetArmor()/24$"%</font>"@"needs repair!";
			nr = 0;
		} 
		else 
		{
			msg = "The"@Building.GetHumanReadableName()@ "<font color='"$ArmourColor$"'>"$Building.GetArmor()/24$"%</font>"@"needs repair immediately!";	
			nr = 0;
			}
		
									}
			else /*We are using armour*/
			
		 { 
		
		if((Building.GetArmor()) == Building.GetMaxArmor() || Rx_Building_Techbuilding(Building) != none) 
		{ 
			
			if(Rx_Building_Techbuilding(Building) != none) 
			{
				msg = "Defend the "$Building.GetHumanReadableName()$"!";
				BroadCastSpotMessage(0, msg);
				return;
			}

			msg = "Defend the"@Building.GetHumanReadableName()@"<font color='"$ArmourColor$"'>"$Building.GetArmor()/24$"%</font>"$"!";
			
			if(Rx_Building_Refinery(Building) != None)
				nr = 28;
			else if(Rx_Building_PowerPlant(Building) != None)
				nr = 29;
			else
				nr = 27;
		}
		else if((Building.GetArmor()) > Building.GetMaxArmor()/4) 
		{
			msg = "The"@Building.GetHumanReadableName()@"<font color='"$ArmourColor$"'>"$Building.GetArmor()/24$"%</font>"@"needs repair!";
			nr = 0;
		} 
		else 
		{
			msg = "The"@Building.GetHumanReadableName()@"<font color='"$ArmourColor$"'>"$Building.GetArmor()/24$"%</font>"@"needs repair immediately!";	
			nr = 0;
			}
			
		}
	} 
	else 
	{ //Enemy building
		if(Rx_Building_Techbuilding(Building) != none)
		{
			msg="Capture the"@Building.GetHumanReadableName()$"!";
			nr=11;
		}
		msg = "Attack the"@Building.GetHumanReadableName()$"!";
		if(Rx_Building_Refinery(Building) != None)
			nr = 23;
		else if(Rx_Building_PowerPlant(Building) != None)
			nr = 24;
		else
			nr = 22;		
	}

	BroadCastSpotMessage(nr, msg);
}

function DetermineEnemySpotBroadcast()
{
	local float TotalRatio, BuildingRatio, ClassRatio;
	local bool bShouldBroadcast;
	local int NearAlliedBuilding;

	if(Enemy == None)	// in freaky incidents where enemy is not valid....
		return;

	if(Rx_Defence(Enemy) != none)
	{
		TotalRatio = FRand();
		if (TotalRatio > 0.6)
			bShouldBroadcast = true;
	}
	else 
	{
		if(Rx_Vehicle(Enemy) != None)
		{
			GetSpottargetLocationInfo(Enemy,NearAlliedBuilding);
			if(NearAlliedBuilding > 0)
				BuildingRatio = 0.5;

			if(Vehicle(Pawn) == None)
				ClassRatio = 0.6;

			else
				ClassRatio = 0.2;

		}
		else if(Rx_Pawn(Enemy) != None)
		{
			GetSpottargetLocationInfo(Enemy,NearAlliedBuilding);
			if(NearAlliedBuilding > 0)
			BuildingRatio = 0.5;

			if(class<Rx_FamilyInfo>(Rx_Pawn(Enemy).CurrCharClassInfo).static.Cost(Rx_PRI(Enemy.PlayerReplicationInfo)) <= 400)
				ClassRatio = class<Rx_FamilyInfo>(Rx_Pawn(Pawn).CurrCharClassInfo).static.Cost(Rx_PRI(Enemy.PlayerReplicationInfo))/400;
			else
				ClassRatio = class<Rx_FamilyInfo>(Rx_Pawn(Pawn).CurrCharClassInfo).static.Cost(Rx_PRI(Enemy.PlayerReplicationInfo))/class<Rx_FamilyInfo>(Rx_Pawn(Enemy).CurrCharClassInfo).static.Cost(Rx_PRI(Enemy.PlayerReplicationInfo));
		}
		else
		{
			return;
		}

		bShouldBroadcast = (BuildingRatio + ClassRatio) >= 0.5;
	}


	if(bShouldBroadcast)
		BroadcastEnemySpotMessages();
}

//Handle this differently than players.
function BroadcastEnemySpotMessages() 
{
	local string SpottingMsg,LocationInfo;
	local int NearAlliedBuilding;

	if(!bCanTalk)
		return;

	LocationInfo = GetSpottargetLocationInfo(Enemy,NearAlliedBuilding);

	if(class<Rx_FamilyInfo>(Rx_Pawn(Enemy).CurrCharClassInfo).static.Cost(Rx_PRI(Enemy.PlayerReplicationInfo)) <= 300)
	{
		if(NearAlliedBuilding < 0)
			return;	
	}

	if(Rx_Pawn(Enemy) != None) 
	{
		SpottingMsg = Rx_Pawn(Enemy).GetCharacterClassName();

		if(Enemy.GetTeamNum() == TEAM_GDI)
			SpottingMsg = "<font color ='" $GDIColor$ "'>"$SpottingMsg$"</font>";
		else
			SpottingMsg = "<font color ='" $NodColor$ "'>"$SpottingMsg$"</font>";
	}
	
	else if(Rx_Vehicle_Harvester(Enemy) != None)
	{
		BroadCastSpotMessage(21, RadioCommandsText[21]);
		return;
	}
	
	else if(Rx_Defence(Enemy) != None)
	{
		SpottingMsg = Rx_Vehicle(Enemy).GetHumanReadableName();
		if(Enemy.GetTeamNum() == TEAM_GDI)
			SpottingMsg = "<font color ='" $GDIColor$ "'>"$SpottingMsg$"</font>";
		else
			SpottingMsg = "<font color ='" $NodColor$ "'>"$SpottingMsg$"</font>";

		BroadCastSpotMessage(11, "Attack that"@SpottingMsg);
	}
	else if(Rx_Vehicle(Enemy) != None)
	{
		SpottingMsg = Rx_Vehicle(Enemy).GetHumanReadableName();

		if(((GetTeamNum() == TEAM_GDI && Rx_Vehicle(Enemy).IsVehicleStolen()) || (Enemy.GetTeamNum() == TEAM_GDI && !Rx_Vehicle(Enemy).IsVehicleStolen())))
			SpottingMsg = "<font color ='" $GDIColor$ "'>"$SpottingMsg$"</font>";
		else if (((GetTeamNum() == TEAM_NOD && Rx_Vehicle(Enemy).IsVehicleStolen()) || (Enemy.GetTeamNum() == TEAM_NOD && !Rx_Vehicle(Enemy).IsVehicleStolen())))
			SpottingMsg = "<font color ='" $NodColor$ "'>"$SpottingMsg$"</font>";
	}
	else 
		return;


	BroadCastSpotMessage(9, "An enemy"@SpottingMsg@"has been spotted"@LocationInfo);
}



function string GetSpottargetLocationInfo(Actor FirstSpotTarget, optional out int NearAlliedBuilding) 
{
	local string LocationInfo;
	local Rx_GRI WGRI;
	local RxIfc_SpotMarker SpotMarker;
	local Actor Spots;
	local float NearestSpotDist;
	local RxIfc_SpotMarker NearestSpotMarker;
	local float DistToSpot;	
	local Rx_Building B;

	
	WGRI = Rx_GRI(WorldInfo.GRI);
	
	if(WGRI == none) 
		return "";
	
	foreach WGRI.SpottingArray(Spots) 
	{
		SpotMarker = RxIfc_SpotMarker(Spots);
		DistToSpot = VSize(Spots.location - FirstSpotTarget.location);
		if(NearestSpotMarker == None || DistToSpot < NearestSpotDist) 
		{
			NearestSpotDist = DistToSpot;	
			NearestSpotMarker = SpotMarker;
		}
	}
	
	if(ActorInBuilding(FirstSpotTarget,B))
		LocationInfo = "INSIDE"@B.GetHumanReadableName();
	else
		LocationInfo = "near"@NearestSpotMarker.GetSpotName();	

	if(Rx_Building(NearestSpotMarker) != None && Rx_Building(NearestSpotMarker).GetTeamNum() == GetTeamNum())
	{
		NearAlliedBuilding = 1;
	}
	else
	{
		NearAlliedBuilding = 0;
	}

	return LocationInfo;
}

function BroadCastSpotMessage(int nr, String Text)
{
	local PlayerController PC;
	local bool	bBroadcastSound; 

	if(!bCanTalk)
		return;

		
	bBroadcastSound = true; 
		
	if(nr == 11) 
		Rx_Pawn(Pawn).setUISymbol(2); //Take the point e.g for Tech Building.
		
	if(nr==9)
	{
		bBroadcastSound = bCanPlayEnemySpotted; 
		bCanPlayEnemySpotted = false;
	}
		
	foreach WorldInfo.AllControllers(class'PlayerController', PC) 
	{
		if (PC.PlayerReplicationInfo.Team ==  PlayerReplicationInfo.Team)
		{
			if(nr > -1 && bBroadcastSound)  
				PC.ClientPlaySound(RadioCommands[nr]);
			
			WorldInfo.Game.BroadcastHandler.BroadcastText(PlayerReplicationInfo, PC,Text, 'Radio');
		}
	}
	
	bCanTalk = false;
	SetTimer(5,false,'MsgCooldown');
	//Sound Spam filters 
}

//
// BOT RADIO SYSTEM ENDS HERE
//

function bool HasABeacon()
{

	return Weapon(Pawn.InvManager.FindInventoryType(Class'Rx_Weapon_Beacon', true)) != None;

}

function bool SwitchToBeacon()
{

	local Weapon Beacon;

	Beacon = Weapon(Pawn.InvManager.FindInventoryType(Class'Rx_Weapon_Beacon', true));

	if(Pawn.Weapon == Beacon)
	{
		return true;
	}

	if(Beacon != None)
	{
		Pawn.InvManager.SetCurrentWeapon(Beacon);
		return true;
	}

	return false;

}

State DeployingBeacon
{
	ignores SeePlayer, SeeMonster, FightEnemy, ChooseAttackMode,HearNoise,ExecuteWhatToDoNext,WhatToDoNext;
	// Disable bot ability to do stuff


Begin:
	if(Vehicle(Pawn) != None)
		LeaveVehicle(false);

	if(SwitchToBeacon())
	{
		StopMovement();
		Pawn.BotFire(true);

		Sleep(0.5);
		While(Rx_Weapon_Beacon(Pawn.Weapon) != None && Rx_Weapon_Beacon(Pawn.Weapon).IsInState('Charging'))
		{
			StopMovement();
			Sleep(2.0);
		}

	}
	AssignSquadResponsibility();
}

function bool CanImpactJump()
{
	return false;
}

function LeaveVehicle(bool bBlocking)
{
	LastVehicle = Rx_Vehicle(Pawn);
	Super.LeaveVehicle(bBlocking);
}

function bool IsRushing()
{
	return Rx_SquadAI(Squad).CurrentTactics != None && Rx_SquadAI(Squad).CurrentTactics.bIsRush;
}

//
//	BOT ORDERING SYSTEM - WIP
//	Functions that handles all the orders given to bots
//
//

function bool OnFocusFire(Rx_Controller Requester, Pawn Target)
{
	if(Requester.bPlayerIsCommander() || Enemy == None || (!CanAttack(Enemy) && !Rx_SquadAI(Squad).MustKeepEnemy(Enemy)) || !IdealToAttack(Enemy))
	{
		if(Enemy == None || CanAttack(Target))
		{
			Enemy = Target;
			Focus = Target;
		}
		else
			return false;
	}

	return false;

}

function AcknowledgeOrder()
{
	if(bCanTalk)
	{
		SetTimer(FRand() * 2, false, 'PlayAffirmative');		
	}
}

function PlayAffirmative()
{
	BroadCastSpotMessage(6, "Affirmative,"@AckPlayer.GetHumanReadableName());
	AckPlayer = None;
}

function RejectOrder()
{
	if(bCanTalk)
	{
		SetTimer(FRand() * 2.0, false, 'PlayNegative');
	}
}

function PlayNegative()
{
	BroadCastSpotMessage(7, "Negative,"@AckPlayer.GetHumanReadableName());
	AckPlayer = None;
}

DefaultProperties
{
	CharInfoClass = class'RenX_Game.Rx_BotCharInfo'
	BaughtVehicleIndex = -1
	WaitingInAreaCount = 0;
	RadarVisibility = 1 
	//bSoaking = true
	
		

	//Buff/Debuff modifiers//

	Misc_SpeedModifier 			= 0.0 

	//Weapons
	Misc_DamageBoostMod 		= 0.0  
	Misc_RateOfFireMod 			= 0.0f //1.0 
	Misc_ReloadSpeedMod 		= 0.0f //1.0 

	//Survivablity
	Misc_DamageResistanceMod 	= 1.0 
	Misc_RegenerationMod 		= 1.0  
	
	RefillDelay					= 10.0


	//--------------Radio commands	
	// CTRL + Number
	
	RadioCommands(0)     =   SoundCue'RX_RadioSounds.Ctrl.01_BuildingNeedsRepairCue'
	RadioCommands(1)     =   SoundCue'RX_RadioSounds.Ctrl.02_GetInTheVehicleCue'
	RadioCommands(2)     =   SoundCue'RX_RadioSounds.Ctrl.03_GetOutofVehCue'
	RadioCommands(3)     =   SoundCue'RX_RadioSounds.Ctrl.04_DestroyThatVehCue'
	RadioCommands(4)     =   SoundCue'RX_RadioSounds.Ctrl.05_WatchWhereYourPointingThatCue'
	RadioCommands(5)     =   SoundCue'RX_RadioSounds.Ctrl.06_DontGetInMyWayCue'
	RadioCommands(6)     =   SoundCue'RX_RadioSounds.Ctrl.07_AffermativeCue'
	RadioCommands(7)     =   SoundCue'RX_RadioSounds.Ctrl.08_NegativeCue'
	RadioCommands(8)     =   SoundCue'RX_RadioSounds.Ctrl.09_ImInPositionCue'
	RadioCommands(9)     =   SoundCue'RX_RadioSounds.Ctrl.10_EnemySpotedCue'
	
	// ALT + Number
	
	RadioCommands(10)    =   SoundCue'RX_RadioSounds.Alt.01_INeedRepairsCue'
	RadioCommands(11)    =   SoundCue'RX_RadioSounds.Alt.02_TakeThePointCue'
	RadioCommands(12)    =   SoundCue'RX_RadioSounds.Alt.03_MoveOutCue'
	RadioCommands(13)    =   SoundCue'RX_RadioSounds.Alt.04_FollowMeCue'
	RadioCommands(14)    =   SoundCue'RX_RadioSounds.Alt.05_HoldPosisitionCue'
	RadioCommands(15)    =   SoundCue'RX_RadioSounds.Alt.06_CoverMeCue'
	RadioCommands(16)    =   SoundCue'RX_RadioSounds.Alt.07_TakeCoverCue'
	RadioCommands(17)    =   SoundCue'RX_RadioSounds.Alt.08_FallBackCue'
	RadioCommands(18)    =   SoundCue'RX_RadioSounds.Alt.09_ReturnToBaseCue'
	RadioCommands(19)    =   SoundCue'RX_RadioSounds.Alt.10_DestroyItNowCue'
	
	// CTRL+ALT + Number
	
	RadioCommands(20)    =   SoundCue'RX_RadioSounds.Ctrl_Alt.01_AttackTheBaseDefencesCue'
	RadioCommands(21)    =   SoundCue'RX_RadioSounds.Ctrl_Alt.02_AttackTheHarvCue'
	RadioCommands(22)    =   SoundCue'RX_RadioSounds.Ctrl_Alt.03_AttachThatStructureCue'
	RadioCommands(23)    =   SoundCue'RX_RadioSounds.Ctrl_Alt.04_AttackTheRefinaryCue'
	RadioCommands(24)    =   SoundCue'RX_RadioSounds.Ctrl_Alt.05_AttackThePowerPlantCue'
	RadioCommands(25)    =   SoundCue'RX_RadioSounds.Ctrl_Alt.06_DefendTheBaseCue'
	RadioCommands(26)    =   SoundCue'RX_RadioSounds.Ctrl_Alt.07_DefendTheHarvesterCue'
	RadioCommands(27)    =   SoundCue'RX_RadioSounds.Ctrl_Alt.08_DefendThatStrustureCue'
	RadioCommands(28)    =   SoundCue'RX_RadioSounds.Ctrl_Alt.09_DefendTheRefinaryCue'
	RadioCommands(29)    =   SoundCue'RX_RadioSounds.Ctrl_Alt.10_DefentThePowerplantCue'


	NodColor            = "#FF0000"
	GDIColor            = "#FFC600"
	HostColor           = "#22BBFF"
	ArmourColor         = "#05DAFD"

	bCanTalk = true
}
