
class Rx_SquadAI extends UTSquadAI;

var bool bOnboardForTactics;
var bool bSquadTacticsAnnounced;
var float RepairerRatio;
var int NumberOfEngineer;
var Rx_AITactics CurrentTactics;
var Array<class<Rx_AITactics> >  GDITactics,NodTactics;
var bool bTacticsCommenced;
var int NumOfBotsOnboard;
var float BaseTacticsDelay;

event PostBeginPlay()
{
	super.PostBeginPlay();

	SetTimer(3.0, false, 'ChooseTactics');

}

function NotifyMembersOnDeployable(Rx_Weapon_DeployedActor DA)
{
	local Rx_Bot B;

	for(B=Rx_Bot(SquadMembers); B!=None; B=Rx_Bot(B.NextSquadMember))
	{
		if(B.DetectedDeployable == None)
			B.DetectedDeployable = DA;
	}
}

function InitializeNoObjective(UTTeamInfo T, Controller C)
{
	Team = T;
	SetLeader(C);
}

function CommenceTactics()
{
	bTacticsCommenced = true;
	CurrentTactics.CommenceTactics();
	ClearTimer('CheckReadiness');

	if(CurrentTactics.bTimeLimited)
		SetTimer(CurrentTactics.TacticsTimeLimit,false,'ResetStrategy');

}

function CheckReadiness()
{
	local UTBot S;
	local int i;
	local bool bHasVehicle;

	for(S=SquadMembers; S!= None; S=S.NextSquadMember)
	{
		if(Rx_Bot(S).bReadyForTactics)
			i++;

		if(!bHasVehicle && Vehicle(S.Pawn) != None)
			bHasVehicle = true;

	}

	if(i >= CurrentTactics.MinimumParticipant && (CurrentTactics.VehicleToMass.Length <= 0 || bHasVehicle || CurrentTactics.bPrioritizeInfantry))
	{

		ClearTimer('ResetStrategy');
		ClearTimer('CheckReadiness');
		SetTimer(3.0,false,'CommenceTactics');

	}
//	else
//		`log(self@":"@i@"out of"@CurrentTactics.MinimumParticipant@"remaining before tactics can start");
}

function FormDeathball()
{
	local UTBot S;

	for(S=SquadMembers; S!= None; S=S.NextSquadMember)
	{
		if(SquadLeader == S)
			S.FindRoamDest();
		else
			TellBotToFollow(S,SquadLeader);
	}
}

function bool IsStealthDiscovered()
{
	local Rx_Bot B;
	local int i;

	for(B=Rx_Bot(SquadMembers); B!=None; B=Rx_Bot(B.NextSquadMember))
	{
		if(!B.IsCurrentlyInvisible())
			i++;

		if(i >= Size * 0.5)
			return true;
	}

	return false;
}


// ToDo - Redesign the decision based on the framework

function ChooseTactics()
{
	local Array<class<Rx_AITactics> > TacList;
	local UTBot S;
	local int i;

	if(PlayerController(SquadLeader) != None || GetOrders() == 'DEFEND')
		return;

	if(Rx_BuildingObjective(SquadObjective) != None && Rx_Building_TechBuilding(Rx_BuildingObjective(SquadObjective).myBuilding) != None)
	{
		SetTimer((BaseTacticsDelay),false, 'ChooseTactics');
		return;
	}

	ReassignLeader();

	if(GetTeamNum() == 0)
		TacList = FilterTactics(GDITactics);

	else
		TacList = FilterTactics(NodTactics);

	if(TacList.Length <= 0)		//We can't find any viable tactics, rerun later
	{
//		`log(Self@"failed to choose tactics : No viable tactics found");
		ResetStrategy();
		return;
	}

	i = Rand(TacList.Length);

	CurrentTactics = new TacList[i];
	CurrentTactics.OwningSquadAI = self;

	RedistributeSquadMoney();

	for(S=SquadMembers; S!= None; S=S.NextSquadMember)
	{
		if(Rx_Bot(S).CheckIfOnboard(CurrentTactics.CreditsNeeded))
			NumOfBotsOnboard++;
	}

	if(NumOfBotsOnboard < CurrentTactics.MinimumParticipant)
	{
//		`log(Self@"failed to choose tactics : Insufficient participant");
		ResetStrategy();
		return;
	}


	if(CurrentTactics.PreparationTime > 0)
	{
		SetTimer(CurrentTactics.PreparationTime, false,'ResetStrategy');
	}
	else
	{
		CommenceTactics();
	}

	SetTimer(2.0,true,'CheckReadiness');

	bOnboardForTactics = true;
//	`log(Self@"successfully set up >>"@CurrentTactics@"<< as squad tactics");

}

function Array<class<Rx_AITactics> > FilterTactics(Array<class<Rx_AITactics> > List)
{
	local Array<class<Rx_AITactics> > TacList;
	local class<Rx_AITactics> T;

	Foreach List(T)	
	{	

		if(T.static.IsAvailable(Rx_Bot(SquadLeader)))
		{
			TacList.AddItem(T);
		}
	}

	return TacList;
}

function RedistributeSquadMoney()
{
	local Rx_Bot S;
	local int SquadMoney, SquadMoneyAverage, SquadSize;

	for(S=Rx_Bot(SquadMembers); S!= None; S=Rx_Bot(S.NextSquadMember))
	{
		SquadMoney += S.GetCredits();
		SquadSize++;
	}

	SquadMoneyAverage = SquadMoney / SquadSize;

	for(S=Rx_Bot(SquadMembers); S!= None; S=Rx_Bot(S.NextSquadMember))
	{
		Rx_PRI(S.PlayerReplicationInfo).SetCredits(SquadMoneyAverage);
	}
}

function ReassignLeader()
{
	local int CurSkill, BestSkill;
	local UTBot BestB, S;


	for (S=SquadMembers; S != None; S=S.NextSquadMember)
	{
		if(BestB == None)
		{
			BestSkill = S.Skill;
			BestB = S;
		}
		else
		{
			CurSkill = S.Skill;
			if(CurSkill > BestSkill)
			{
				BestSkill = CurSkill;
				BestB = S;
			}
		}
	}

	SetLeader(BestB);

}

function DiscardFromTactic()
{
	NumOfBotsOnboard--;

	if(NumOfBotsOnboard <= 0)
		ResetStrategy();
	
}

function ResetStrategy()
{
	local Rx_Bot B;
	local int i;

	CurrentTactics = None;

	if(bOnboardForTactics)
		bOnboardForTactics = false;

	ClearTimer('CheckReadiness');


	for(B=Rx_Bot(SquadMembers); B != None;B=Rx_Bot(B.NextSquadMember))
	{
		if(B.bOnboardForTactics)
		{
			B.bOnboardForTactics = false;
			if(B.PTTask == B.TacticsPTTask)
				B.PTTask = "";
			else
			{
				for(i=0;i<B.PTQueue.length;i++)
				{
					if(B.PTQueue[i] == B.TacticsPTTask)
					{
						B.PTQueue.Remove(i,1);
						break;
					}
				}
			}
			B.TacticsPTTask = "";
		
			if(B.GetOrders() == 'ATTACK')
				SetObjective(UTTeamInfo(Team).AI.GetPriorityAttackObjectiveFor(Self,SquadMembers),false);
		}
	}
	
	bSquadTacticsAnnounced = false;

	SetTimer((BaseTacticsDelay/UTBot(SquadLeader).Skill + 1),false, 'ChooseTactics');
}

function AnnounceAttackPlan()
{

	if(!bSquadTacticsAnnounced)
	{
		bSquadTacticsAnnounced = true;
		SetTimer(RandRange(1.0,4.0), false, 'DelayedAnnounceAttackPlan');
	}

	
}

function bool GotoVehicle(UTVehicle SquadVehicle, UTBot B)
{
	if(Rx_Bot(B).PTTask != "" && PlayerStart(B.RouteGoal) != None)
		return false;

	return Super.GotoVehicle(SquadVehicle,B);
}

function DelayedAnnounceAttackPlan()
{
	local UTBot S,FirstS;
	local String Announcement, OtherMembers;
	local int i;

	if(Rx_BuildingObjective(SquadObjective) == None)
		return;

	if(Size == 1 && Rx_Bot(SquadMembers).bOnboardForTactics)
	{
		FirstS = SquadMembers;
		Announcement = "I'm commencing"@CurrentTactics.TacticName@"on"@Rx_BuildingObjective(SquadObjective).myBuilding.GetHumanReadableName()@" on my own!";
		i = 1;
	}

	else
	{
		for ( S=SquadMembers; S!=None; S=S.NextSquadMember )
		{
			if(Rx_Bot(S).bOnboardForTactics)
			{
				if(FirstS == None)
				{
					FirstS = S;
					continue;
				}
				else
				{
					OtherMembers = OtherMembers@S.GetHumanReadableName()$",";
				}

				i++;
			}
		}

		if(i > 1)		
			Announcement = OtherMembers@"and I are commencing"@CurrentTactics.TacticName@"on"@Rx_BuildingObjective(SquadObjective).myBuilding.GetHumanReadableName()$"!";
		else
			Announcement = "I'm commencing"@CurrentTactics.TacticName@"on"@Rx_BuildingObjective(SquadObjective).myBuilding.GetHumanReadableName()@" on my own!";
			
	}
	if(FirstS == None)
	{
		ResetStrategy(); // Nobody's onboard, reset
		return;
	}

	Rx_Bot(FirstS).BroadcastSpotMessage(12,Announcement);
}

function int GetEngiNumber()
{
	local Rx_Bot B;
	local int i;
	local class<UTFamilyInfo> FamInfo;

	
	for (B=Rx_Bot(SquadMembers); B!=None; B=Rx_Bot(B.NextSquadMember) )
	{
		FamInfo = Rx_Pri(B.PlayerReplicationInfo).CharClassInfo;

		if( Rx_Game(WorldInfo.Game).PurchaseSystem.DoesHaveRepairGun( FamInfo ) && (B.PTTask == "" || B.PTTask == "Refill")) 
			i += 1;

	}

	return i;
}

function float VehicleDesireability(UTVehicle V, UTBot B)
{

	if (Rx_Defence(V) != None)		// Defenses are vehicles, but they will never be able to be entered normally. Leave it be
		return 0;

	// if a vehicle was purchased by the bot AND is bound to the bot, treat normally
	if(Rx_Vehicle(V) != None && (Rx_Vehicle(V).buyerPri != B.PlayerReplicationInfo || (Rx_Vehicle(V).BoundPRI != None && Rx_Vehicle(V).BoundPRI != B.PlayerReplicationInfo)))
	{
		if (Rx_Vehicle(V).bReservedToBuyer) // Reserved to buyer (nobody can enter but buyer)
			return 0;

		if (Rx_Vehicle(V).GetTeamNum() != B.GetTeamNum() && (Rx_Vehicle(V).BoundPRI == None || (B.GetTeamNum() != Rx_Vehicle(V).BoundPRI.GetTeamNum()))) // Prioritize stealing enemy vehicles
			return super.VehicleDesireability(V,B) * 2.0;

		if ((Rx_Vehicle(V).BoundPRI != None && Rx_Vehicle(V).TimeLastOccupied >= 0 && WorldInfo.TimeSeconds - Rx_Vehicle(V).TimeLastOccupied < 30) // Bound & empty for 30 seconds
			|| Rx_Vehicle(V).bDriverLocked) // Locked
			return 0;

	}

	// Attackers should not use a 'Defence' Emplacement in the first place. 
	// Bots are like cats though, if it fits, they sits.

	if (B.GetOrders() == 'DEFEND')
	{
		if(Rx_Defence_Emplacement(V) == None || Rx_Bot(B).HasRepairGun())
			return 0;
	}
	else if (Rx_Defence_Emplacement(V) != None) 
		return 0;



	return super.VehicleDesireability(V,B);
}

function bool FindNewEnemyFor(UTBot B, bool bSeeEnemy)
{
	local int i;
	local Pawn BestEnemy, OldEnemy;
	local bool bSeeNew;
	local float BestThreat,NewThreat;

	if ( B.Pawn == None )
		return true;
	if ( (B.Enemy != None) && MustKeepEnemy(B.Enemy) && B.LineOfSightTo(B.Enemy) )
		return false;

	BestEnemy = B.Enemy;
	OldEnemy = B.Enemy;
	if ( BestEnemy != None )
	{
		if ( (BestEnemy.Health < 0) || (BestEnemy.Controller == None) )
		{
			B.Enemy = None;
			BestEnemy = None;
		}
		else
		{
			if ( ModifyThreat(0,BestEnemy,bSeeEnemy,B) > 5 )
				return false;
			BestThreat = AssessThreat(B,BestEnemy,bSeeEnemy);
		}
	}
	for ( i=0; i<ArrayCount(Enemies); i++ )
	{
		if (Enemies[i] != None && Enemies[i].Health > 0 && Enemies[i].Controller != None && (B.bBetrayTeam || !WorldInfo.GRI.OnSameTeam(Enemies[i], B)) )
		{
			if ( BestEnemy == None || (Rx_Bot(B) != None && !Rx_Bot(B).IdealToAttack(BestEnemy)) && Rx_Bot(B).IdealToAttack(Enemies[i]))
			{
				BestEnemy = Enemies[i];
				bSeeEnemy = B.CanSee(Enemies[i]);
				BestThreat = AssessThreat(B,BestEnemy,bSeeEnemy);
			}
			else if ( Enemies[i] != BestEnemy )
			{
				if ( VSizeSq(Enemies[i].Location - B.Pawn.Location) < 2250000 )
					bSeeNew = B.LineOfSightTo(Enemies[i]);
				else
					bSeeNew = B.CanSee(Enemies[i]);	// only if looking at him
				NewThreat = AssessThreat(B,Enemies[i],bSeeNew);
				if ( NewThreat > BestThreat )
				{
					BestEnemy = Enemies[i];
					BestThreat = NewThreat;
					bSeeEnemy = bSeeNew;
				}
			}
		}
		else
			Enemies[i] = None;
	}
	B.Enemy = BestEnemy;
	if ( (B.Enemy != OldEnemy) && (B.Enemy != None) )
	{
		B.EnemyChanged(bSeeEnemy);
		return true;
	}
	return false;
}

function float AssessThreat( UTBot B, Pawn NewThreat, bool bThreatVisible )
{
	local float ThreatValue, Dist, BuildingDist;
	local bool bCloseThreat;
	local class<Rx_FamilyInfo> FI;

	ThreatValue = 0.5;

	Dist = VSizeSq(NewThreat.Location - B.Pawn.Location);

	if(GetOrders() == 'DEFEND')
	{
		BuildingDist = VSizeSq(NewThreat.Location - Rx_BuildingObjective(SquadObjective).myBuilding.location);
		Dist = FMax(Dist,BuildingDist);
	}
	
	if ( Dist < 6250000 )
	{
		bCloseThreat = true;
		ThreatValue += (6250000 - Dist)/6250000;
	}

	if (Rx_Pawn(NewThreat) != None)
	{
		FI = class<Rx_FamilyInfo>(Rx_Pawn(NewThreat).CurrCharClassInfo);

		if(Rx_Pawn_Scripted(NewThreat) == None)
			ThreatValue += FI.static.Cost(Rx_PRI(NewThreat.PlayerReplicationInfo)) / 1000.0;
		else
			ThreatValue += FI.default.BasePurchaseCost / 1000.0;
	}

	else if (Rx_Vehicle(NewThreat) != None && Rx_Bot(B).IdealToAttack(NewThreat))
	{
		if(Rx_Vehicle_Harvester(NewThreat) != None)
			ThreatValue += 3;
		else
			ThreatValue += Rx_Vehicle(NewThreat).BasePurchaseCost / 1000.0;
	}

	// prefer enemies bot is good at killing
	if ( (B.Pawn != None) && (B.Pawn.Weapon != None) )
	{
		ThreatValue += UTWeapon(B.Pawn.Weapon).RelativeStrengthVersus(NewThreat, Dist);
	}

	if (Rx_Pawn_SBH(NewThreat) != None || Rx_Vehicle_StealthTank(NewThreat) != None)
		ThreatValue += 0.25;

	if ( bThreatVisible )
		ThreatValue += 1;

	if ( (UTVehicle(NewThreat) != None) && UTVehicle(NewThreat).bKeyVehicle )
	{
		ThreatValue += 0.25;
	}

	if ( NewThreat == B.Enemy )
	{
		if ( bThreatVisible && bCloseThreat )
		{
			ThreatValue += 0.1 * FMax(0, 5 - B.Skill);
		}
	}
	else if ( B.Enemy != None )
	{
		if ( !bThreatVisible )
			ThreatValue -= 5;
		else if ( WorldInfo.TimeSeconds - B.LastSeenTime > 2 )
		{
			ThreatValue += 1;
		}
		if ( Dist > 0.49 * VSizeSq(B.Enemy.Location - B.Pawn.Location) )
			ThreatValue -= 0.25;
		ThreatValue -= 0.2;
	}

	ThreatValue = ModifyThreat(ThreatValue,NewThreat,bThreatVisible,B);

	//`log(B.GetHumanReadableName()$" assess threat "$ThreatValue$" for "$NewThreat.GetHumanReadableName());
	return ThreatValue;
}

function bool MustKeepEnemy(Pawn E)
{
	local Rx_Building B;

	if(E.GetTeamNum() == SquadLeader.GetTeamNum())
		return false;

	if(GetOrders() == 'DEFEND')
	{
		if(ActorInBuilding(E,B) && B.GetTeamNum() == GetTeamNum() && !B.IsDestroyed())
			return true; // Infiltrators will not be ignored
	}

	return false;
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

//
//	BOT ORDERING SYSTEM - WIP
//	Functions that handles all the orders given to bots
//	This is Squad-wide handler
//

function bool OnBuildingNeedsRepair (Rx_Controller OrderingPlayer, Rx_Building B)
{

	if(B.myObjective == SquadObjective)
		return false;

	if(GetOrders() != 'DEFEND' && GetOrders() != 'FOLLOW')
	{
		return false;
	}

	if(Rx_Bot(SquadLeader).AckPlayer == None)
		Rx_Bot(SquadLeader).AckPlayer = OrderingPlayer;

	if(B.GetArmor() < B.GetMaxArmor())
	{
		if(OrderingPlayer.bPlayerIsCommander() || (Rx_BuildingObjective(SquadObjective).myBuilding.GetArmor() > Rx_BuildingObjective(SquadObjective).myBuilding.GetMaxArmor() * 0.75)) // Commanders will be obeyed. Otherwise, check their own building
		{
			SquadObjective = B.myObjective;
			Rx_Bot(SquadLeader).AcknowledgeOrder();
			return true;
		}
	}

	Rx_Bot(SquadLeader).RejectOrder();
	return false;
}

function bool OnDisarmObject(Rx_Controller OrderingPlayer, Rx_Weapon_DeployedActor D)
{
	local Rx_Bot S;
	local bool bOrderSuccessful;

	if(GetOrders() != 'DEFEND' && GetOrders() != 'FOLLOW')
	{
		return false;
	}
	for(S=Rx_Bot(SquadMembers); S!= None; S=Rx_Bot(S.NextSquadMember))
	{
		if(S != None)
		{
			if(OrderingPlayer.bPlayerIsCommander() || S.DetectedDeployable == None || CheckDeployablePriority(S,D))
			{
				S.DetectedDeployable = D;
				if(!bOrderSuccessful)
					bOrderSuccessful = true;
			}	
		}
	}

	return bOrderSuccessful;
}

function bool CheckDeployablePriority(Rx_Bot B, Rx_Weapon_DeployedActor D)
{
	local bool bSelectedIsImportant, bCurrentIsImportant;
	local Rx_Weapon_DeployedActor DA;

	DA = B.DetectedDeployable;

	if(Rx_Weapon_DeployedBeacon(DA) != None && VSizeSq(DA.location - Rx_BuildingObjective(SquadObjective).myBuilding.location) < 1000000)
	{
		bCurrentIsImportant = true;
	}
	else if(Rx_Weapon_DeployedC4(DA) != None && Rx_BuildingAttachment_MCT(DA.Base) != None)
	{
		bCurrentIsImportant = true;
	}

	if(Rx_Weapon_DeployedBeacon(D) != None && VSizeSq(D.location - Rx_BuildingObjective(SquadObjective).myBuilding.location) < 1000000)
	{
		bSelectedIsImportant = true;
	}
	else if(Rx_Weapon_DeployedC4(D) != None && Rx_BuildingAttachment_MCT(D.Base) != None)
	{
		bSelectedIsImportant = true;
	}

	if(bSelectedIsImportant && !bCurrentIsImportant)
		return true;

	return false;

}

function AlertSquad(Rx_Bot B, Pawn Seen)
{
	local Rx_Bot SM;

	if(B.GetOrders() != 'Defend')
		return;

	for(SM=Rx_Bot(SquadMembers); SM!=None; SM=Rx_Bot(SM.NextSquadMember))
	{
		if(SM.Enemy == None)
		{
			SM.Enemy = Seen;
			SM.WhatToDoNext();
		}
	}
}

DefaultProperties
{
	RepairerRatio = 0.4
	BaseTacticsDelay = 90;

	GDITactics.Add(class'Rx_AITactics_Opening_GDI_EngiRush')
	GDITactics.Add(class'Rx_AITactics_Opening_GDI_FarlandRush')
	GDITactics.Add(class'Rx_AITactics_Opening_GDI_Shotgun')
	GDITactics.Add(class'Rx_AITactics_Opening_GDI_Standard')
	GDITactics.Add(class'Rx_AITactics_Opening_GDI_OfficerRush')

	GDITactics.Add(class'Rx_AITactics_GDI_MobiusRush')
	GDITactics.Add(class'Rx_AITactics_GDI_PatchRush')
	GDITactics.Add(class'Rx_AITactics_GDI_MiniBeaconRush')
	GDITactics.Add(class'Rx_AITactics_GDI_CommandoDeathball')
	GDITactics.Add(class'Rx_AITactics_GDI_HavocRapeFest')
	GDITactics.Add(class'Rx_AITactics_GDI_GunnerRush')
	GDITactics.Add(class'Rx_AITactics_GDI_SydneyParty')



	GDITactics.Add(class'Rx_AITactics_GDI_APCRush')
	GDITactics.Add(class'Rx_AITactics_GDI_MedRush')


	NodTactics.Add(class'Rx_AITactics_Opening_Nod_ChemRush')
	NodTactics.Add(class'Rx_AITactics_Opening_Nod_OfficerRush')
	NodTactics.Add(class'Rx_AITactics_Opening_Nod_Shotgun')
	NodTactics.Add(class'Rx_AITactics_Opening_Nod_FlameTroopers')
	NodTactics.Add(class'Rx_AITactics_Opening_Nod_EngiRush')	

	NodTactics.Add(class'Rx_AITactics_Nod_MendozaRush')
	NodTactics.Add(class'Rx_AITactics_Nod_MiniBeaconRush')
	NodTactics.Add(class'Rx_AITactics_Nod_StealthBeaconRush')
	NodTactics.Add(class'Rx_AITactics_Nod_CommandoDeathball')
	NodTactics.Add(class'Rx_AITactics_Nod_SakuraRapeFest')
	NodTactics.Add(class'Rx_AITactics_Nod_LCGRush')
	NodTactics.Add(class'Rx_AITactics_Nod_RaveParty')

	NodTactics.Add(class'Rx_AITactics_Nod_FlameRush')
	NodTactics.Add(class'Rx_AITactics_Nod_StankRush')
	NodTactics.Add(class'Rx_AITactics_Nod_ArtyParty')

