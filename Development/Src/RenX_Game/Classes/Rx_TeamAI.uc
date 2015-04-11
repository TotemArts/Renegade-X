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
class Rx_TeamAI extends UTTeamAI;

var name OrderList_GDI[8];
var name OrderList_NOD[8];
var int	 NumBotsToSwitchToDefense;
var float  NumAttackingBots;
var float  NumDefendingBots;
var float MinAttackersRatio[2];


function PostBeginPlay()
{
	Super.PostBeginPlay();	
	
	SetTimer(1.5,true,'DefensiveStrategyTimer');
}


function InitializeOrderList()
{
	local int i;
	
	if(GetTeamNum() == 0) {
		for(i = 0; i < 8; i++) {
			OrderList[i] = OrderList_GDI[i];
		}
	} else {
		for(i = 0; i < 8; i++) {
			OrderList[i] = OrderList_NOD[i];
		}	
	}	
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


	for ( O=Objectives; O!=None; O=O.NextObjective )
	{
		if ( (O.DefenderTeamIndex == Team.TeamIndex) && !O.bIsDisabled && Rx_BuildingObjective(O).NeedsHealing())
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
		if(S.CurrentOrders == 'Attack' && NumBotsToSwitchToDefense > 0) {
			
		} else if(S.CurrentOrders != 'Defend') {
			continue;
		}
		
		i = 0;
		SquadSize = S.Size;
		for (M = S.SquadMembers; M != None; M = M.NextSquadMember)
		{
			if(i++ == SquadSize) {
				break;
			}
			if(Rx_Bot(M).BaughtVehicleIndex == -1) { // dont reassign when Bot just baught a vehicle and should go to it
				if(S.CurrentOrders == 'Attack' && NumBotsToSwitchToDefense > 0 && Vehicle(M.Pawn) == None) {
					NumBotsToSwitchToDefense--;
					PutOnDefense(M);	
					if(NumBotsToSwitchToDefense == 0)
						break; 
				} else if(S.CurrentOrders == 'Defend') {
 					if(UTVehicle(Rx_Bot(M).Pawn) == None && Rx_Bot(M).GetCredits() >= Rx_Bot(M).TargetMoney && M.Pawn != None) {
						if(M.GetTeamNum() == TEAM_GDI 
								&& Rx_Pri(M.PlayerReplicationInfo).CharClassInfo == Rx_Game(WorldInfo.Game).Purchasesystem.GDIInfantryClasses[0]) {
								Rx_Game(WorldInfo.Game).SetPlayerDefaults(M.Pawn); // makes bot buy something
						} else if(Rx_Pri(M.PlayerReplicationInfo).CharClassInfo == Rx_Game(WorldInfo.Game).Purchasesystem.NodInfantryClasses[0]) {
							Rx_Game(WorldInfo.Game).SetPlayerDefaults(M.Pawn); // makes bot buy something
						}
					}					
					if(OneNeedsHealing || Frand() < 0.6) {
						PutOnDefense(M);
					}
				}				
			}
		}
	}
}

function bool PutOnDefense(UTBot B)
{
	local UTGameObjective O;
	local UTGameObjective CurrentObjective;

	if(Vehicle(B.Pawn) != None) {
		PutOnOffense(B);		
		return true;	
	}

	O = GetLeastDefendedObjective(B);
	if ( O != None )
	{
		if(B.Squad != None && B.Squad.SquadObjective != None) {
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

function UTGameObjective GetLeastDefendedObjective(Controller InController)
{
	local UTGameObjective O, Best;
	local UTGameObjective CurrentObjective;
	local int CurrHealthDiff;
	local int BestHealthDiff;
	
	for ( O=Objectives; O!=None; O=O.NextObjective )
	{
		if ( (O.DefenderTeamIndex == Team.TeamIndex) && !O.bIsDisabled )
		{
			if ( (Best == None) || (Best.DefensePriority < O.DefensePriority) )
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
	
	
	if(Best == None) {
		return None;
	}
	
	if(UTBot(InController).Squad != None && UTBot(InController).Squad.SquadObjective != None) {
		CurrentObjective = UTGameObjective(UTBot(InController).Squad.SquadObjective);	
	}
	
	if(Rx_BuildingObjective(CurrentObjective) == None || CurrentObjective == Best || CurrentObjective.GetTeamNum() != InController.GetTeamNum()) {
		return Best;
	}
	
	CurrHealthDiff = Rx_BuildingObjective(CurrentObjective).HealthDiff();
	BestHealthDiff = Rx_BuildingObjective(Best).HealthDiff();
	
	if(Rx_BuildingObjective(CurrentObjective).NeedsHealing() && !Rx_BuildingObjective(Best).NeedsHealing()) {
		return CurrentObjective;
	} else if(!Rx_BuildingObjective(CurrentObjective).NeedsHealing() && Rx_BuildingObjective(Best).NeedsHealing()) {
		return Best;
	} else if(!Rx_BuildingObjective(CurrentObjective).NeedsHealing() && !Rx_BuildingObjective(Best).NeedsHealing()) {
		return Best;
	} else { // both need healing
		if(Abs(CurrHealthDiff - BestHealthDiff) < 500) {
			return CurrentObjective;	
		}
		if(CurrHealthDiff > BestHealthDiff) {
			return CurrentObjective;	
		}
	}
	return Best;
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
				bTestObjectiveCovered = ObjectiveCoveredByAnotherSquad(BO, AnAttackSquad, AnAttackSquad.CurrentOrders == 'Attack', AnAttackSquad.Size);
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
 * @param bRequireAttackSquad (opt) - if true, only count as covered if at least one squad has 'Attack' orders
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
			bGotAttackSquad = (bGotAttackSquad || S.GetOrders() == 'Attack');
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
	
	O = GetPriorityAttackObjectiveFor(None, B);
	if(B.Squad == None || B.Squad.SquadObjective != O) {
		PutOnOffenseAttackO(B, O);
	}
}

function PutOnOffenseAttackO(UTBot B, UTGameObjective O)
{
	if(Rx_AreaObjective(O) != None) {
		if(Rx_AreaObjective(O).TeamSquads[B.GetTeamNum()] == None) {
			Rx_AreaObjective(O).TeamSquads[B.GetTeamNum()] = Rx_SquadAI(AddSquadWithLeader(B, O));
		} else {
			Rx_AreaObjective(O).TeamSquads[B.GetTeamNum()].AddBot(B);
		}
		return;
	}
	
	if ( (AttackSquad == None) || (AttackSquad.Size >= AttackSquad.MaxSquadSize) )
		AttackSquad = AddSquadWithLeader(B, O);
	else
		AttackSquad.AddBot(B);
}

function UpdateNumDefAttack() {
	local UTSquadAI S;
	NumDefendingBots = 0;
	NumAttackingBots = 0;
	for ( S=Squads; S!=None; S=S.NextSquad ) {
		if(S.SquadMembers != None && S.SquadMembers.GetOrders() == 'DEFEND') {
			NumDefendingBots += S.Size;
		} else {
			NumAttackingBots += S.Size;
		}
	}
}

function SetBotOrders(UTBot NewBot)
{
	UpdateNumDefAttack();
	if(UTVehicle(NewBot.Pawn) != None || NumAttackingBots/Max(1,(NumDefendingBots+NumAttackingBots)) < MinAttackersRatio[GetTeamNum()]) {
		OrderOffset++;
		PutOnOffense(NewBot);
	} else {
		super.SetBotOrders(NewBot);
	}
}

DefaultProperties
{
	SquadType=class'Rx_SquadAI'
	
	MinAttackersRatio(0)=0.90
	MinAttackersRatio(1)=0.90
	
	OrderList_GDI(0)=ATTACK
	OrderList_GDI(1)=ATTACK
	OrderList_GDI(2)=ATTACK
	OrderList_GDI(3)=DEFEND
	OrderList_GDI(4)=ATTACK
	OrderList_GDI(5)=DEFEND
	OrderList_GDI(6)=ATTACK
	OrderList_GDI(7)=DEFEND	
	
	OrderList_NOD(0)=ATTACK
	OrderList_NOD(1)=ATTACK
	OrderList_NOD(2)=ATTACK
	OrderList_NOD(3)=DEFEND
	OrderList_NOD(4)=ATTACK
	OrderList_NOD(5)=DEFEND
	OrderList_NOD(6)=ATTACK
	OrderList_NOD(7)=DEFEND	
	
	
	//FREELANCE, DEFEND, ATTACK	
}
