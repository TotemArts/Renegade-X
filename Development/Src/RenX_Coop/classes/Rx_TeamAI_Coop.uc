class Rx_TeamAI_Coop extends Rx_TeamAI;

function PostBeginPlay()
{
	Super(UTTeamAI).PostBeginPlay();	

//	SetTimer(1.0, false, 'CheckForAreaObjective');
	AssessPTLocations();

	bCanGetCheatBot = bCheetozBotzEnabled;

}

function UTGameObjective GetLeastDefendedObjective(Controller InController)
{
	if(IsPlayerTeam())
		return none;

	else
		return super.GetLeastDefendedObjective(InController);
}

function bool PutOnDefense(UTBot B)
{
	if(IsPlayerTeam())
		PutOnOffense(B);

	return false;
}

function UTGameObjective GetPriorityAttackObjectiveFor(UTSquadAI AnAttackSquad, Controller InController)
{
	local UTGameObjective O;
	local int BestIndex;
	local float BestRate,CurrentRate;
	local Rx_CoopObjective CoopO,BestCoopO;

	if(InController == None)
		return None;

	if(Rx_Bot_Scripted_Customizeable(InController) != None)
	{
		return Rx_Bot_Scripted_Customizeable(InController).MySpawner.SquadObjective;
	}

	for (O = Objectives; O != None; O = O.NextObjective)
	{
		if(O.bIsDisabled)
			continue;
	
		if(IsPlayerTeam())
		{
			`log(Self@": Checking and rating"@ O);

			if(Rx_CoopObjective(O) == None)
				continue;

			CoopO = Rx_CoopObjective(O);
			if(BestCoopO == None || BestIndex < CoopO.ObjectiveIndex)
			{
				BestIndex = CoopO.ObjectiveIndex;
				BestCoopO = CoopO;
				BestRate = RateCoopObjective(CoopO,InController);
			}
			else if (BestIndex == CoopO.ObjectiveIndex)
			{
				CurrentRate = RateCoopObjective(CoopO,InController);
				if(CurrentRate > BestRate)
				{
					BestCoopO = CoopO;
					BestRate = CurrentRate;
				}
			}
		}
	}

	return BestCoopO;	
}

function float RateCoopObjective(Rx_CoopObjective O, Controller InController)
{
	if(!O.bOptional)
		return 1.f / VSizeSq(InController.Pawn.location - O.location);
	else
		return 0.25f / VSizeSq(InController.Pawn.location - O.location);
}

function bool IsPlayerTeam()
{
	return (GetTeamNum() == Rx_Game_Cooperative(WorldInfo.Game).GetPlayerTeam());
}

DefaultProperties
{
	OrderList(0)=ATTACK
	OrderList(1)=ATTACK
	OrderList(2)=ATTACK
	OrderList(3)=ATTACK
	OrderList(4)=ATTACK
	OrderList(5)=ATTACK
	OrderList(6)=ATTACK
	OrderList(7)=ATTACK
}