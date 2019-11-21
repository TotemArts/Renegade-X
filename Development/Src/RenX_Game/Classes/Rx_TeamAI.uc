/*********************************************************
*
* File: Rx_CharInfo_Singleplayer.uc
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
class Rx_TeamAI extends UTTeamAI
	config(RenegadeXAISetup);

var name OrderList_GDI[8];
var name OrderList_NOD[8];
var int	 NumBotsToSwitchToDefense;
var float  NumAttackingBots;
var float  NumDefendingBots;
var float MinAttackersRatio[2];
var bool bAOExist;
var array<NavigationPoint> GDIPlayerStarts;
var array<NavigationPoint> NodPlayerStarts;
var array<UTGameObjective> AreaO;
var bool bBuildingsDetermined;
var config bool bCheetozBotzEnabled;
var bool bCanGetCheatBot;
var class<UTSquadAI> ScriptedSquadType;
var bool bDeployableWarnCD;



//var class<Object> DeterminedClass[100];
//var string PTString[100];

var UTGameObjective DefendObjectiveRequest;
/*
struct PTRequest
{
	var class<Object> ClassToCheck;
	var string StringToGet;
};

var PTRequest PTParser[100];
*/




function PostBeginPlay()
{
	Super.PostBeginPlay();	
	
	SetTimer(3,true,'DefensiveStrategyTimer');

//	SetTimer(1.0, false, 'CheckForAreaObjective');
	AssessPTLocations();

	bCanGetCheatBot = bCheetozBotzEnabled;

}

function SetObjectiveLists()
{

	Objectives = Rx_Game(WorldInfo.Game).FirstObjective;

}

/*

//DEPRECATED - String parsing is now done in Rx_FamilyInfo and Rx_Vehicle_PTInfo
function string GetPurchaseString(Class<Object> CheckedClass)
{

	local int i;
	for(i=0;i<100;i++)
	{
		if(DeterminedClass[i] == CheckedClass)
			return PTString[i];
	}


}
*/

function bool CheckForAreaObjective()
{
	local UTGameObjective O;

	if(bAOExist)
		return true;

	for (O = Objectives; O != None; O = O.NextObjective)
	{
		if(Rx_AreaObjective(O) != None)
		{
			bAOExist = true;
			return true;
		}
	}
	return false;	// Mapper neglected to create AreaObjective. AI will only rush buildings now
}

function AssessPTLocations()
{
	local UTTeamPlayerStart N;

	foreach WorldInfo.AllNavigationPoints(class'UTTeamPlayerStart',N)
	{
		if(N.TeamNumber == 0)
			GDIPlayerStarts.AddItem(N);
		else
			NodPlayerStarts.AddItem(N);
	}

	if(GDIPlayerStarts.length <= 0)
		`log("Failed to get GDI PT");
	if(NodPlayerStarts.length <= 0)
		`log("Failed to get Nod PT");
}

function InitializeOrderList()
{
	local int i;
	
	if(GetTeamNum() == 0) 
	{
		for(i = 0; i < 8; i++) 
		{
			OrderList[i] = OrderList_GDI[i];
		}
	} 
	else 
	{
		for(i = 0; i < 8; i++) 
		{
			OrderList[i] = OrderList_NOD[i];
		}	
	}	
}

function WarnBotsForDeployables(Rx_Weapon_DeployedActor DA, Rx_Bot B)
{
	local UTSquadAI S;

	if(bDeployableWarnCD || FRand() + (B.Skill / 6.0) < 1.0)
		return;

	for (S = Squads; S != None; S = S.NextSquad)
	{
		if (S.GetOrders() == 'DEFEND')
			Rx_SquadAI(S).NotifyMembersOnDeployable(DA);
	}

	bDeployableWarnCD = true;
	SetTimer(5.0,false,'ReEnableDeployableWarn');
}

function ReEnableDeployableWarn()
{
	bDeployableWarnCD = false;	
}

function DefensiveStrategyTimer()
{

	ReAssessDefendedObjective();
}

/** Changes what buildings/places to defend/repair based on situation */
function ReAssessDefendedObjective()
{
	local UTSquadAI S;
	local UTGameObjective O;
	local UTBot M;
	local bool OneNeedsHealing;
	local int i,SquadSize;


	for (O = Objectives; O != None; O = O.NextObjective)
	{
		if (!O.bIsDisabled && Rx_BuildingObjective(O) != None && O.DefenderTeamIndex == Team.TeamIndex && Rx_BuildingObjective(O).NeedsHealing())
		{
			OneNeedsHealing = true;
			break;	
		}
	}	
	
	/**
	if(!OneNeedsHealing) {
		return; // then no need to reposition the defenders to buildings to repair
	}
	*/
	
	for (S = Squads; S != None; S = S.NextSquad)
	{
		if(S.CurrentOrders == 'ATTACK' && NumBotsToSwitchToDefense > 0) 
		{
			
		} 
		else if(S.CurrentOrders != 'DEFEND') 
		{
			continue;
		}
		
		i = 0;
		SquadSize = S.Size;
		for (M = S.SquadMembers; M != None; M = M.NextSquadMember)
		{
			if(i++ == SquadSize) {
				break;
			}
			if(Rx_Bot(M).BaughtVehicleIndex == -1) 
			{ // dont reassign when Bot just baught a vehicle and should go to it
				if(S.CurrentOrders == 'ATTACK' && NumBotsToSwitchToDefense > 0 && Vehicle(M.Pawn) == None) 
				{
					NumBotsToSwitchToDefense--;
					PutOnDefense(M);	
					if(NumBotsToSwitchToDefense == 0)
						break; 
				} 
				else if(S.CurrentOrders == 'DEFEND') 
				{					
					if(OneNeedsHealing || Frand() < 0.6) 
					{
						PutOnDefense(M);
					}
				}				
			}
		}
	}
}

function UTGameObjective GetLeastDefendedObjective(Controller InController)
{
	local UTGameObjective O, Best;
	local bool bCheckDistance;
	local float BestDistSq, NewDistSq;

	bCheckDistance = (InController != None) && (InController.Pawn != None);
	for ( O=Objectives; O!=None; O=O.NextObjective )
	{

		if(Rx_BuildingObjective(O) != None && Rx_Building_Techbuilding(Rx_BuildingObjective(O).myBuilding) != None)
			continue;

		if ( (O.DefenderTeamIndex == Team.TeamIndex) && !O.bIsDisabled )
		{
			if ( (Best == None) || (Best.DefensePriority < O.DefensePriority) )
			{
				Best = O;
				if (bCheckDistance)
				{
					BestDistSq = VSizeSq(Best.Location - InController.Pawn.Location);
				}
			}
			else if ( Best.DefensePriority == O.DefensePriority )
			{
				// prioritize less defended or closer nodes
				if (Best.GetNumDefenders() > O.GetNumDefenders())
				{
					Best = O;
					if (bCheckDistance)
					{
						BestDistSq = VSizeSq(Best.Location - InController.Pawn.Location);
					}
				}
				else if (bCheckDistance)
				{
					NewDistSq = VSizeSq(Best.Location - InController.Pawn.Location);
					if (NewDistSq < BestDistSq)
					{
						Best = O;
						BestDistSq = NewDistSq;
					}
				}
			}
		}
	}
	return Best;
}

function bool PutOnDefense(UTBot B)
{
	local UTGameObjective O;
	local UTGameObjective CurrentObjective;
	local Rx_Building Building;

	if(Rx_Bot_Scripted(B) != None)
		return false;

	if(Vehicle(B.Pawn) != None) 
	{
		PutOnOffense(B);		
		return true;	
	}

	if(Rx_Bot(B).DefendedBuildingNeedsHealing())
		return true;

	if((Rx_Bot(B).bIsEmergencyRepairer && Rx_Bot(B).IsInBuilding(Building)))
		O = Building.myObjective;
	else 
		O = GetLeastDefendedObjective(B);

	if ( O != None )
	{
		if(B.Squad != None && B.Squad.SquadObjective != None) 
		{
			CurrentObjective = UTGameObjective(B.Squad.SquadObjective);	
		}
		
		if(CurrentObjective != None && CurrentObjective == O) {
			return true;
		}
				
		if ( O.DefenseSquad == None )
			O.DefenseSquad = AddSquadWithLeader(B, O);
		else
			O.DefenseSquad.AddBot(B);
		return true;
	}
	return false;
}

function PutOnDefenseExplicit(UTBot B, UTGameObjective O)
{
	if ( O.DefenseSquad == None )
		O.DefenseSquad = AddSquadWithLeader(B, O);
	else
		O.DefenseSquad.AddBot(B);
}

function UTGameObjective VehicleSpawnerManagersDefendedObjective(Controller InController)
{
	local UTGameObjective O, Best;
	local float BestDefensePriority, CurrentDefensePriority;
	
	Best = None;

	for (O = Objectives; O != None; O = O.NextObjective)
	{
		if (!O.bIsDisabled && O.DefenderTeamIndex == Team.TeamIndex)
		{
			if(Rx_BuildingObjective(O) != None)
			{
				if(Best == None || (Best != None && Rx_BuildingObjective(Best) == None))
				{
					Best = O;
					BestDefensePriority = Rx_BuildingObjective(Best).CalcDefensePriority(InController);
				}
				
				else 
				{	
					CurrentDefensePriority = Rx_BuildingObjective(O).CalcDefensePriority(InController);
					
					if(CurrentDefensePriority > BestDefensePriority)
					{
						BestDefensePriority = CurrentDefensePriority;
						Best = O;
					}
				}

			}

			else
			{
				if ( (Best == None) || (Best != None && Best.DefensePriority < O.DefensePriority) )
				{
					Best = O;
				}
				else if ( Best.DefensePriority == O.DefensePriority )
				{
					// prioritize less defended or closer nodes
					if (Best.GetNumDefenders() > O.GetNumDefenders() && FRand() < 0.5)
					{
						Best = O;
					}
				}
			}
		}
	}	
	

	if(DefendObjectiveRequest != None && (Best == None || (Rx_BuildingObjective(Best).myBuilding.GetArmor() > Rx_BuildingObjective(Best).myBuilding.GetMaxArmor() * 0.75 && !Rx_BuildingObjective(DefendObjectiveRequest).bIsDisabled)))
		Best = DefendObjectiveRequest;
	
	if(Best == None) 
	{
		return None;
	}


	return Best;
}

function UTGameObjective GetAllInRushObjectiveFor(UTSquadAI AnAttackSquad, Controller InController)
{
	local UTGameObjective O; 
	local UTGameObjective TowerBO, PPBO;
	local Array<UTGameObjective> EnemyBO;
	local int R;

	if(Rx_Game(WorldInfo.Game).bPedestalDetonated)
		return None;

	for (O = Objectives; O != None; O = O.NextObjective)
	{
		if(Rx_BuildingObjective(O) != None && O.DefenderTeamIndex != Team.TeamIndex && !Rx_BuildingObjective(O).myBuilding.IsDestroyed())
		{
			if(Rx_BuildingObjective(O).myBuilding.IsA('Rx_Building_Techbuilding'))
			{
				if((AnAttackSquad != None && AnAttackSquad.Size > 2) || (Rx_BuildingObjective(O).myBuilding.GetTeamNum() == InController.GetTeamNum() && Rx_BuildingObjective(O).myBuilding.GetHealth() >= Rx_BuildingObjective(O).myBuilding.GetMaxHealth()))
					continue;

				else if (FRand() > 0.6 && Rx_Bot(InController).HasRepairGun(true))
					return O;
			}

			if(Rx_BuildingObjective(O).myBuilding.IsA('Rx_Building_Obelisk') || Rx_BuildingObjective(O).myBuilding.IsA('Rx_Building_AdvancedGuardTower'))
			{
				TowerBO = O;
			}
			else if(Rx_BuildingObjective(O).myBuilding.IsA('Rx_Building_PowerPlant'))
			{	
				PPBO = O;
			}

			EnemyBO.AddItem(O);
		}

	}

	if(EnemyBO.Length <= 0 && !Rx_Game(WorldInfo.Game).bPedestalDetonated)
	{
		if(Rx_SquadAI_Scripted(AnAttackSquad) == None)
			`warn(Self@" : Enemy team has no buildings or is missing Rx_BuildingObjective! Unable to resolve AllIn attack!");

		return None;
	}

	if(Vehicle(InController.Pawn) == None && TowerBO != None)
	{
		if(PPBO != None)
			PickedObjective = PPBO;
		else if(!Rx_Building_Defense(Rx_BuildingObjective(TowerBO).MyBuilding).bDisabled)
			PickedObjective = TowerBO;
	}
	else
	{
		R = Rand(EnemyBO.length);
		PickedObjective = EnemyBO[R];
	}

	Rx_Bot(InController).bAttackingEnemyBase = true;
	return PickedObjective;

}

function UTGameObjective GetPriorityAttackObjectiveFor(UTSquadAI AnAttackSquad, Controller InController)
{

	local UTGameObjective O;
	local float CurGroupRating;
	local bool pickHigherGroup;
	local UTGameObjective PreviousSO;
	local int CurrentGroupNum,highestGroupNum,HighestImportance;
	local Rx_AreaObjective RO;
	local bool bAttackBuildings;
	local array<float> teamPresence;
	local int importanceTemp;
	local int NumAggressors;
	local Rx_Building B;

	if(Rx_SquadAI(AnAttackSquad) != None && Rx_SquadAI(AnAttackSquad).CurrentTactics != None && (Rx_SquadAI(AnAttackSquad).CurrentTactics.bIsRush || Rx_SquadAI(AnAttackSquad).CurrentTactics.bIsBeaconRush))
		return GetAllInRushObjectiveFor(AnAttackSquad,InController);

	if(InController != None && InController.Pawn != None)
	{
		foreach InController.Pawn.VisibleCollidingActors(class'Rx_Building',B,400,InController.Pawn.Location)
		{
			if(B.GetTeamNum() != InController.GetTeamNum() && !B.IsDestroyed() && Vehicle(InController.Pawn) == None)
			{
				PickedObjective = B.myObjective;
				Rx_Bot(InController).bAttackingEnemyBase = true;

				return PickedObjective;		//There's no need to reevaluate. Just go Rambo
			}
		}
	}
	
/* TODO - Reenable this when the AreaObjective logic gets better
//	IF AreaObjective is absent, repeat the rushing tactics
//	script is repeated so the TeamAI can prioritize the 'proximity check' before 

//	if(!CheckForAreaObjective() || (Rx_Bot(Incontroller) != None && Rx_Bot(InController).Skill > 3 && Rand(10) > 4))
//	{
//		return GetAllInRushObjectiveFor(AnAttackSquad,InController);
//	}
*/

	if(Rx_Bot(Incontroller) != None)
	{
		return GetAllInRushObjectiveFor(AnAttackSquad,InController);
	}

	else if(Rx_Bot(Incontroller) == None)
		return UTGameObjective(AnAttackSquad.SquadObjective);

// TODO - Fix the Area Objective logic

	pickHigherGroup = InController.GetTeamNum() == TEAM_GDI; 
	if(Rx_Bot(InController).Squad != None && !Rx_Bot(InController).bInvalidatePreviousSO) {
		PreviousSO = UTGameObjective(Rx_Bot(InController).Squad.SquadObjective);
	}
	else if(Rx_Bot(InController).bInvalidatePreviousSO) {
		Rx_Bot(InController).bInvalidatePreviousSO = false;
	} 
	PickedObjective = PreviousSO;
	
	if(!Rx_Bot(InController).bAttackingEnemyBase || (Rx_BuildingObjective(PreviousSO) != None && Rx_BuildingObjective(PreviousSO).GetTeamNum() == GetTeamNum())) {	
		if(Rx_AreaObjective(PreviousSO) != None) {
			CurrentGroupNum	= Rx_AreaObjective(PreviousSO).GroupNum;	
		}
		for (O = Objectives; O != None; O = O.NextObjective)
		{
			if ( Rx_AreaObjective(O) == None ){	
				continue;
			}
			if(highestGroupNum == 0 || Rx_AreaObjective(O).GroupNum > highestGroupNum) {
				highestGroupNum = Rx_AreaObjective(O).GroupNum;
			}
			if(CurrentGroupNum != 0 && Rx_AreaObjective(O).GroupNum == CurrentGroupNum) {
				teamPresence = Rx_AreaObjective(O).getTeamPresence();
				if(InController.GetTeamNum() == TEAM_GDI) {
					CurGroupRating += teamPresence[TEAM_GDI] - teamPresence[TEAM_NOD];		
				} else {
					CurGroupRating += teamPresence[TEAM_NOD] - teamPresence[TEAM_GDI];
				}
			}
		}
		
		/**
		NumAggressors = Rx_TeamAI(UTTeamInfo(InController.PlayerReplicationInfo.Team).AI).NumAttackingBots;
		NumDefBots = Rx_TeamAI(UTTeamInfo(InController.PlayerReplicationInfo.Team).AI).NumDefendingBots;
		NumAggressors += InController.PlayerReplicationInfo.Team.Size - NumAggressors - NumDefendingBots;	
		*/

		UpdateNumDefAttack();

		NumAggressors = NumAttackingBots;		
		NumAggressors += InController.PlayerReplicationInfo.Team.Size - NumAttackingBots - NumDefendingBots;
		//loginternal(GetTeamNum()@NumAggressors);		
		
		if(Rx_AreaObjective(PreviousSO) != None) {
			if(InController.GetTeamNum() == TEAM_GDI) {
				if(CurrentGroupNum == highestGroupNum) { // so in group next to enemy base
					if(CurGroupRating > 1 && CurGroupRating/Max(1,NumAggressors) >= 1/2) {
						PickedObjective = None; // so that a Buildingobjective will be picked
						bAttackBuildings = true;	
					}		
				}
			} else {
				if(CurrentGroupNum == 1) { // so in group next to enemy base			
					if(CurGroupRating > 1 && CurGroupRating/Max(1,NumAggressors) >= 1/2) {
						PickedObjective = None; // so that a Buildingobjective will be picked
						bAttackBuildings = true;	
					}		
				}
			}	
		}	
		
		if(!bAttackBuildings && Rx_AreaObjective(PreviousSO) == None || (Rx_AreaObjective(PreviousSO) != None 
					&& (Rx_Bot(InController).bCheckIfBetterSoInCurrentGroup || CurGroupRating/Max(1,NumAggressors) >= 0.4))) {
			if(Rx_AreaObjective(PreviousSO) == None) {
				if(InController.GetTeamNum() == TEAM_GDI) {
					CurrentGroupNum = 0;	
				} else {
					CurrentGroupNum = highestGroupNum+1;
				}
			}				
			
			for (O = Objectives; O != None; O = O.NextObjective)
			{
				if ( Rx_AreaObjective(O) != None && !O.bIsDisabled )
				{	
					if(O.bBlockedForVehicles && UTVehicle(InController.Pawn) != None) {
						continue;
					}
					
					RO = Rx_AreaObjective(O);
					
					if(Rx_Bot(InController).bCheckIfBetterSoInCurrentGroup) {
						if(RO.GroupNum != CurrentGroupNum) {
							continue;
						}	
					} else {
						if(pickHigherGroup) {
							if(RO.GroupNum != CurrentGroupNum+1) {
								continue;	
							} 
						} else {
							if(RO.GroupNum != CurrentGroupNum-1) {
								continue;	
							} 
						}	
					}		
					
					importanceTemp = RO.GetImportance(InController.GetTeamNum());
					if(PickedObjective == None || (importanceTemp > HighestImportance && FRand() < 0.7) 
							|| FRand() < 0.25) {	 			
						PickedObjective = O;
						HighestImportance = importanceTemp;
					}
				}
			}			
		}
	}
	if((Rx_Bot(InController).bAttackingEnemyBase || bAttackBuildings)
			&&  PickedObjective == None || Rx_Bot(InController).bAttackingEnemyBase || Rx_BuildingObjective(PickedObjective) != None) {
		PickedObjective = PickBuildingObjective(AnAttackSquad,InController);
		if(PickedObjective != None && Rx_BuildingObjective(PickedObjective).GetTeamNum() != GetTeamNum()) {
			Rx_Bot(InController).bAttackingEnemyBase = true;

		}
	}	

	return PickedObjective;
}

/*
function UTGameObjective GetPriorityAttackObjectiveFor(UTSquadAI AnAttackSquad, Controller InController)
{



	local UTGameObjective PreviousSO;

	if(Rx_Bot(InController).Squad != None && !Rx_Bot(InController).bInvalidatePreviousSO)
		PreviousSO = UTGameObjective(Rx_Bot(InController).Squad.SquadObjective);

	else if(Rx_Bot(InController).bInvalidatePreviousSO)
		Rx_Bot(InController).bInvalidatePreviousSO = false;
	
	PickedObjective = PreviousSO;

	if(Rx_BuildingObjective(PreviousSO) != None && Rx_BuildingObjective(PreviousSO).DefenderTeamIndex != Team.TeamIndex && !Rx_BuildingObjective(PreviousSO).bIsDisabled)
		return PreviousSO;

	else
		return PickBuildingObjective(AnAttackSquad, InController);
}
*/
function Rx_BuildingObjective PickBuildingObjective(UTSquadAI AnAttackSquad, Controller InController) 
{
	local UTGameObjective O;
	local Rx_BuildingObjective BO, PickedBO;
	local bool bPickedObjectiveCovered, bTestObjectiveCovered;
	local bool bCheckDistance;
	local float BestDistSq, NewDistSq;
	
	bCheckDistance = (InController != None) && (InController.Pawn != None);

	PickedObjective = None;
	for (O = Objectives; O != None; O = O.NextObjective)
	{
		BO = Rx_BuildingObjective(O);
		if ( BO != None && !BO.bIsDisabled && BO.DefenderTeamIndex != Team.TeamIndex )
		{

			if (AnAttackSquad != None)
			{
				bTestObjectiveCovered = ObjectiveCoveredByAnotherSquad(BO, AnAttackSquad, AnAttackSquad.CurrentOrders == 'ATTACK', AnAttackSquad.Size);
			}
			else
			{
				bTestObjectiveCovered = ObjectiveCoveredByAnotherSquad(BO, None);
			}
			//if ( (PickedBO == None) || (!bTestObjectiveCovered && (bPickedObjectiveCovered || PickedBO.DefensePriority < BO.DefensePriority)) )
			
			if ( (PickedBO == None) || (!bTestObjectiveCovered && (bPickedObjectiveCovered && PickedBO.DefensePriority <= BO.DefensePriority)) )
			{
				PickedBO = BO;
				bPickedObjectiveCovered = bTestObjectiveCovered;
				if (bCheckDistance)
				{
					BestDistSq = VSizeSq(PickedBO.Location - InController.Pawn.Location);
				}
			}
			else if ( bCheckDistance && (PickedBO.DefensePriority == O.DefensePriority) && (bPickedObjectiveCovered == bTestObjectiveCovered) )
			{
				// prioritize closer Buildings
				NewDistSq = VSizeSq(BO.Location - InController.Pawn.Location);
				if ( NewDistSq < BestDistSq )
				{
					PickedBO = BO;
					BestDistSq = NewDistSq;
					bPickedObjectiveCovered = bTestObjectiveCovered;
				}
			}
		}
	}
	return PickedBO;
}

function Rx_BuildingObjective GetClosestEnemyBuildingObjective(Controller InController)
{
	local UTGameObjective O;
	local Rx_BuildingObjective BO, PickedBO;
	local float BestDistSq, NewDistSq;
	
	for (O = Objectives; O != None; O = O.NextObjective)
	{
		BO = Rx_BuildingObjective(O);
		if ( BO != None && BO.DefenderTeamIndex != Team.TeamIndex )
		{
			NewDistSq = VSizeSq(BO.Location - InController.Pawn.Location);
			if ( NewDistSq < BestDistSq || BestDistSq == 0.0)
			{
				PickedBO = BO;
				BestDistSq = NewDistSq;
			}
		}
	}
	return PickedBO;
}

function Rx_AreaObjective GetClosestNextAreaObjective(Controller InController, bool bVehOnlyWhenOnVehSO)
{
	local UTGameObjective O, CurrentSO;
	local Rx_AreaObjective RO, PickedRO;
	local float BestDistSq, NewDistSq;
	local int NextAoNum;
	
	if(Rx_Bot(InController).Squad != None)
		CurrentSO = UTGameObjective(Rx_Bot(InController).Squad.SquadObjective);
	if(CurrentSO == None) {
		return None;
	}
	if(InController.GetTeamNum() == TEAM_GDI) {
		NextAoNum = Rx_AreaObjective(CurrentSO).GroupNum + 1;	
	} else {
		NextAoNum = Rx_AreaObjective(CurrentSO).GroupNum - 1;
	}
	
	for (O = Objectives; O != None; O = O.NextObjective)
	{
		if ( Rx_AreaObjective(O) == None ){	
			continue;
		}
		RO = Rx_AreaObjective(O);
		if(RO.GroupNum != NextAoNum) {
			continue;
		}
		if(bVehOnlyWhenOnVehSO && Rx_AreaObjective(CurrentSO) != None 
				&& !Rx_AreaObjective(CurrentSO).bBlockForVehicles && RO.bBlockForVehicles) {
			continue;
		}
		NewDistSq = VSizeSq(RO.Location - InController.Pawn.Location);
		if ( NewDistSq < BestDistSq || BestDistSq == 0.0)
		{
			PickedRO = RO;
			BestDistSq = NewDistSq;
		}
	}
	return PickedRO;
}

/** returns true if the given objective is a SquadObjective for some other squad on this team than the passed in squad
 * @param O - the objective to test for
 * @param IgnoreSquad - squad to ignore (because we're calling this while evaluating changing its objective)
 * @param bRequireAttackSquad (opt) - if true, only count as covered if at least one squad has 'ATTACK' orders
 * @param RequiredAttackers (opt) - only valid if bRequireAttackSquad - only count as covered if this many bots are covering it
 * @return whether the objective is sufficiently covered by another squad
 */
function bool ObjectiveCoveredByAnotherSquad(UTGameObjective O, UTSquadAI IgnoreSquad, optional bool bRequireAttackSquad, optional int RequiredAttackers)
{
	local UTSquadAI S;
	local int NumCovering;
	local bool bGotAttackSquad;

	for (S = Squads; S != None; S = S.NextSquad)
	{
		if (S.SquadObjective == O && S != IgnoreSquad)
		{
			if (!bRequireAttackSquad)
			{
				return true;
			}
			bGotAttackSquad = (bGotAttackSquad || S.GetOrders() == 'ATTACK');
			NumCovering += S.Size;
			if (bGotAttackSquad && NumCovering >= RequiredAttackers)
			{
				return true;
			}
		}
	}

	return false;
}

function PutOnOffense(UTBot B)
{
	local UTGameObjective O;

	if(Rx_Bot_Scripted(B) != None)
		return;
	
	O = GetPriorityAttackObjectiveFor(None, B);

	if(B.Squad == None || B.Squad.SquadObjective != O) 
	{
			PutOnOffenseAttackO(B, O);
	}
}

function PutOnOffenseAttackO(UTBot B, UTGameObjective O)
{
	if(Rx_AreaObjective(O) != None) 
	{
		
		if(Rx_AreaObjective(O).TeamSquads[B.GetTeamNum()] == None) 
			Rx_AreaObjective(O).TeamSquads[B.GetTeamNum()] = Rx_SquadAI(AddSquadWithLeader(B, O));
		

		else 
			Rx_AreaObjective(O).TeamSquads[B.GetTeamNum()].AddBot(B);

		return;
	}
	
	if ( (AttackSquad == None) || (AttackSquad.Size >= AttackSquad.MaxSquadSize) )
	{
		AttackSquad = AddSquadWithLeader(B, O);
	}
	else
		AttackSquad.AddBot(B);
}

function UpdateNumDefAttack() 
{
	local UTSquadAI S;
	NumDefendingBots = 0;
	NumAttackingBots = 0;
	for ( S=Squads; S!=None; S=S.NextSquad ) 
	{
		if(S.SquadMembers != None && S.SquadMembers.GetOrders() == 'DEFEND') {
			NumDefendingBots += S.Size;
		} else {
			NumAttackingBots += S.Size;
		}
	}
}

function UTSquadAI AddSquadWithLeader(Controller C, UTGameObjective O)
{
	local UTSquadAI S;

	if(Rx_Bot_Scripted(C) == None)
	{
		S = spawn(SquadType);
		S.Initialize(UTTeamInfo(Team),O,C);
		S.NextSquad = Squads;
		Squads = S;
	}
	else
	{
		S = spawn(ScriptedSquadType);
		S.Initialize(UTTeamInfo(Team),O,C);
		S.NextSquad = Squads;
		Squads = S;
	}
	return S;
}


function UTSquadAI AddScriptedSquadWithLeader(Controller C, UTGameObjective O)
{
	local UTSquadAI S;

	S = spawn(SquadType);
	S.Initialize(UTTeamInfo(Team),O,C);
	S.NextSquad = Squads;
	Squads = S;
	return S;
}


function SetBotOrders(UTBot NewBot)
{
	if(Rx_Bot_Scripted(NewBot) == None)
	{
		UpdateNumDefAttack();
		if(UTVehicle(NewBot.Pawn) != None || NumAttackingBots/Max(1,(NumDefendingBots+NumAttackingBots)) < MinAttackersRatio[GetTeamNum()]) {
			OrderOffset++;
			PutOnOffense(NewBot);
		}
		else 
		{
		super.SetBotOrders(NewBot);
		}
	}
}

function RequestDisarm(Rx_Controller Requester, Rx_Weapon_DeployedActor D)
{
	local UTSquadAI S;

	for (S = Squads; S != None; S = S.NextSquad)
	{
		if(Rx_SquadAI(S) != None && S.GetOrders() == 'DEFEND')
			Rx_SquadAI(S).OnDisarmObject(Requester, D);
	}
}

function CriticalObjectiveWarning(UTGameObjective G, Pawn NewEnemy)
{
	local UTSquadAI S;
	local UTBot B;

	for (S = Squads; S != None; S = S.NextSquad)
	{
		if(S.GetOrders() != 'DEFEND')
			continue;

		for (B = S.SquadMembers; B != None; B = B.NextSquadMember)
		{
			if(B.Pawn != None)
				S.CheckSquadObjectives(B);
		}

		if(NewEnemy != None)
			S.AddEnemy(NewEnemy);
	}
}

function OnBuildingDefenseRequest(Rx_Controller C,Rx_Building B)
{
	if(C.bPlayerIsCommander() || DefendObjectiveRequest == None)

	if(B.GetTeamNum() == GetTeamNum())
	{
		DefendObjectiveRequest = B.myObjective;
		SetTimer(20.0,false,'ResetDefenseRequest');
	}
}

function ResetDefenseRequest()
{
	DefendObjectiveRequest = None;
}

DefaultProperties
{
	SquadType=class'Rx_SquadAI_Waypoints'
	ScriptedSquadType=class'Rx_SquadAI_Scripted'
	
    MinAttackersRatio(0)=0.80
    MinAttackersRatio(1)=0.80
    
    OrderList_GDI(0)=DEFEND
    OrderList_GDI(1)=ATTACK
    OrderList_GDI(2)=ATTACK
    OrderList_GDI(3)=ATTACK
    OrderList_GDI(4)=ATTACK
    OrderList_GDI(5)=DEFEND
    OrderList_GDI(6)=ATTACK
    OrderList_GDI(7)=DEFEND    
    
    OrderList_NOD(0)=DEFEND
    OrderList_NOD(1)=ATTACK
    OrderList_NOD(2)=ATTACK
    OrderList_NOD(3)=ATTACK
    OrderList_NOD(4)=ATTACK
    OrderList_NOD(5)=DEFEND
    OrderList_NOD(6)=ATTACK
    OrderList_NOD(7)=DEFEND   

/*
	DeterminedClass(0)=class'Rx_FamilyInfo_GDI_Soldier'
	PTString(0)="Buy Char - Soldier"
	PTParser(0)=(ClassToCheck=class'Rx_FamilyInfo_GDI_Soldier',StringToGet="Buy Char - Soldier")

	DeterminedClass(1)=class'Rx_FamilyInfo_GDI_Shotgunner'
	PTString(1)="Buy Char - Shotgun"
	PTParser(1)=(ClassToCheck=class'Rx_FamilyInfo_GDI_Shotgunner',StringToGet="Buy Char - Shotgun")

	DeterminedClass(2)=class'Rx_FamilyInfo_GDI_Grenadier'
	PTString(2)="Buy Char - BasicAT"
	PTParser(2)=(ClassToCheck=class'Rx_FamilyInfo_GDI_Grenadier',StringToGet="Buy Char - BasicAT")

	DeterminedClass(3)=class'Rx_FamilyInfo_GDI_Marksman'
	PTString(3)="Buy Char - Marksman"

	DeterminedClass(4)=class'Rx_FamilyInfo_GDI_Engineer'
	PTString(4)="Buy Char - Engi"

	DeterminedClass(5)=class'Rx_FamilyInfo_GDI_Patch'
	PTString(5)="Buy Char - Patch"

	DeterminedClass(6)=class'Rx_FamilyInfo_GDI_Hotwire'
	PTString(6)="Buy Char - AdvEngi"

	DeterminedClass(7)=class'Rx_FamilyInfo_GDI_RocketSoldier'
	PTString(7)="Buy Char - Rocket"

	DeterminedClass(8)=class'Rx_FamilyInfo_GDI_Gunner'
	PTString(8)="Buy Char - Heavy"

	DeterminedClass(9)=class'Rx_FamilyInfo_GDI_Havoc'
	PTString(9)="Buy Char - Ramjet"

	DeterminedClass(10)=class'Rx_FamilyInfo_GDI_Mobius'
	PTString(10)="Buy Char - Destroyer"

	DeterminedClass(11)=class'Rx_FamilyInfo_GDI_Sydney'
	PTString(11)="Buy Char - PIC"

	DeterminedClass(12)=class'Rx_FamilyInfo_GDI_Officer'
	PTString(12)="Buy Char - Officer"

	DeterminedClass(13)=class'Rx_FamilyInfo_GDI_Deadeye'
	PTString(13)="Buy Char - Sniper"

	DeterminedClass(14)=class'Rx_FamilyInfo_Nod_Soldier'
	PTString(14)="Buy Char - Soldier"

	DeterminedClass(15)=class'Rx_FamilyInfo_Nod_Shotgunner'
	PTString(15)="Buy Char - Shotgun"

	DeterminedClass(16)=class'Rx_FamilyInfo_Nod_FlameTrooper'
	PTString(16)="Buy Char - BasicAT"

	DeterminedClass(17)=class'Rx_FamilyInfo_Nod_Marksman'
	PTString(17)="Buy Char - Marksman"

	DeterminedClass(18)=class'Rx_FamilyInfo_Nod_Engineer'
	PTString(18)="Buy Char - Engi"

	DeterminedClass(19)=class'Rx_FamilyInfo_Nod_StealthBlackHand'
	PTString(19)="Buy Char - SBH"

	DeterminedClass(20)=class'Rx_FamilyInfo_Nod_Technician'
	PTString(20)="Buy Char - AdvEngi"

	DeterminedClass(21)=class'Rx_FamilyInfo_Nod_RocketSoldier'
	PTString(21)="Buy Char - Rocket"

	DeterminedClass(22)=class'Rx_FamilyInfo_Nod_LaserChainGunner'
	PTString(22)="Buy Char - Heavy"

	DeterminedClass(23)=class'Rx_FamilyInfo_Nod_Sakura'
	PTString(23)="Buy Char - Ramjet"

	DeterminedClass(24)=class'Rx_FamilyInfo_Nod_Mendoza'
	PTString(24)="Buy Char - Destroyer"

	DeterminedClass(25)=class'Rx_FamilyInfo_Nod_Raveshaw'
	PTString(25)="Buy Char - PIC"

	DeterminedClass(26)=class'Rx_FamilyInfo_Nod_Officer'
	PTString(26)="Buy Char - Officer"

	DeterminedClass(27)=class'Rx_FamilyInfo_Nod_BlackHandSniper'
	PTString(27)="Buy Char - Sniper"

	DeterminedClass(28)=class'Rx_Vehicle_Humvee'
	PTString(28)="Buy Vehicle - Humvee"

	DeterminedClass(29)=class'Rx_Vehicle_APC_GDI'
	PTString(29)="Buy Vehicle - APC"

	DeterminedClass(30)=class'Rx_Vehicle_MRLS'
	PTString(30)="Buy Vehicle - MRLS"

	DeterminedClass(31)=class'Rx_Vehicle_MediumTank'
	PTString(31)="Buy Vehicle - Med"

	DeterminedClass(32)=class'Rx_Vehicle_MammothTank'
	PTString(32)="Buy Vehicle - Mammoth"

	DeterminedClass(33)=class'Rx_Vehicle_Orca'
	PTString(33)="Buy Vehicle - Orca"

	DeterminedClass(34)=class'Rx_Vehicle_Chinook_GDI'
	PTString(34)="Buy Vehicle - Chinook"

	DeterminedClass(35)=class'Rx_Vehicle_Buggy'
	PTString(35)="Buy Vehicle - Buggy"

	DeterminedClass(36)=class'Rx_Vehicle_APC_Nod'
	PTString(36)="Buy Vehicle - APC"

	DeterminedClass(37)=class'Rx_Vehicle_Artillery'
	PTString(37)="Buy Vehicle - Artillery"

	DeterminedClass(38)=class'Rx_Vehicle_LightTank'
	PTString(38)="Buy Vehicle - LightTank"

	DeterminedClass(39)=class'Rx_Vehicle_FlameTank'
	PTString(39)="Buy Vehicle - FlameTank"

	DeterminedClass(40)=class'Rx_Vehicle_StealthTank'
	PTString(40)="Buy Vehicle - Stank"

	DeterminedClass(41)=class'Rx_Vehicle_Chinook_Nod'
	PTString(41)="Buy Vehicle - Chinook"

	DeterminedClass(42)=class'Rx_Vehicle_Apache'
	PTString(42)="Buy Vehicle - Apache"

	DeterminedClass(43)=class'Rx_FamilyInfo_Nod_ChemicalTrooper'
	PTString(43)="Buy Char - AdvShotgun"

	DeterminedClass(44)=class'Rx_FamilyInfo_GDI_McFarland'
	PTString(44)="Buy Char - AdvShotgun"

*/

/*
 	GDIOpeningStrategyList(0) = "Engineer Rush"
  	GDIOpeningStrategyList(1) = "Shotgun Rush"
   	GDIOpeningStrategyList(2) = "Grenadier Rush"

  	NodOpeningStrategyList(0) = "Engineer Rush"
  	NodOpeningStrategyList(1) = "Shotgun Rush"
  	NodOpeningStrategyList(2) = "FlameGuy Rush"
*/

 /*
	MinAttackersRatio(0)=0.80
    MinAttackersRatio(1)=0.80
    
    OrderList_GDI(0)=ATTACK
    OrderList_GDI(1)=ATTACK
    OrderList_GDI(2)=ATTACK
    OrderList_GDI(3)=ATTACK
    OrderList_GDI(4)=ATTACK
    OrderList_GDI(5)=ATTACK
    OrderList_GDI(6)=ATTACK
    OrderList_GDI(7)=ATTACK   
    
    OrderList_NOD(0)=DEFEND
    OrderList_NOD(1)=ATTACK
    OrderList_NOD(2)=ATTACK
    OrderList_NOD(3)=DEFEND
    OrderList_NOD(4)=ATTACK
    OrderList_NOD(5)=DEFEND
    OrderList_NOD(6)=ATTACK
    OrderList_NOD(7)=DEFEND   
*/
	//FREELANCE, DEFEND, ATTACK	
}
