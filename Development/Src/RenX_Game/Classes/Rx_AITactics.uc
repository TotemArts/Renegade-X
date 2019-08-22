class Rx_AITactics extends Object
	abstract
	transient;

var float BaseProbability;			// Probability for bots to use this tactic
var float GameTimeRelevancy;			// This tactic becomes available once this amount of time passed
var float TimeUntilRelevancyExpires;	// This tactic becomes UNavailable once this amount of time passed
var float PreparationTime;			// Squads must wait for this amount of time before commencing 
var int CreditsNeeded;				// The amount of credits bots must save before commencing
var bool bTimeLimited;
var bool bIsBeaconRush;								// If true, then bots will also buy beacon if able to
var bool bIsRush;									// If true, abandons Rx_AreaObjective and go straight for the base
var bool bPersistentUntilTimelimit;
var float TacticsTimeLimit;
var int SkillMinimum;
var bool bCanExpire;					// if False, TimeUntilRelevancyExpires is not relevant (*badum tss*)
var bool bAdvancedClassOnly;			// if true, do this only when team has infantry building
var bool bInfantryBuildingPostMortem;	// if true, do this only after team's infantry building is destroyed

var bool bVehicleBuildingPostMortem;	// if true, do this only after team's vehicle factory is destroyed


var name Orders;									// Squad needs to use have this order to use this tactic
var array<class<Rx_Vehicle_PTInfo> > VehicleToMass; 		// Which vehicle is necessary to mass
var array<class<Rx_FamilyInfo> > InfantryToMass;	// Which character is necessary to mass
var bool bPrioritizeInfantry;
var Rx_SquadAI OwningSquadAI;
var int MinimumParticipant;
var string TacticName;
var WorldInfo WorldInfo;

var bool bVehicleAvailable, bInfantryAvailable;

function CommenceTactics()
{
	local Rx_TeamAI TeamAI;
	local UTBot S;

	TeamAI = Rx_TeamAI(UTTeamInfo(OwningSquadAI.Team).AI);

	if(bIsRush || bIsBeaconRush)
	{
		for(S=OwningSquadAI.SquadMembers; S != None; S=S.NextSquadMember)
			OwningSquadAI.SetObjective(TeamAI.GetAllInRushObjectiveFor(OwningSquadAI,S),true);

		OwningSquadAI.AnnounceAttackPlan();
	}
	else if (Orders == 'FREELANCE')
	{
		OwningSquadAI.FormDeathBall();
	}
}

function bool PurchaseMaterial(Rx_Bot B)
{
	local class<Rx_Vehicle_PTInfo> V;
	local class<Rx_FamilyInfo> FI;

	local array<class<Rx_Vehicle_PTInfo> > FilteredV; 
	local array<class<Rx_FamilyInfo> > FilteredFI;

	local int Choice, InfantryCost, VehicleCost; 

	local String TempString;
	local int i;
	local bool bOverridingPurchase;

	if(WorldInfo == None)
		WorldInfo = class'WorldInfo'.static.GetWorldInfo();

	if(bIsBeaconRush)
	{
		if(B.PTTask != "")
			B.PTQueue.AddItem("Buy Beacon");
		else
			B.PTTask = "Buy Beacon";

		B.TacticsPTTask = "Buy Beacon";
	}

	if(VehicleToMass.Length > 0)
	{
		foreach VehicleToMass(V)
		{
			if(!Rx_Game(WorldInfo.Game).GetPurchaseSystem().AreHighTierVehiclesDisabled(OwningSquadAI.GetTeamNum()) && B.GetCredits() > V.static.GetCost(Rx_PRI(B.PlayerReplicationInfo)))
				FilteredV.AddItem(V);
		}
	}

	if(InfantryToMass.Length > 0)
	{
		foreach InfantryToMass(FI)
		{
			if(FI.static.Available(Rx_PRI(B.PlayerReplicationInfo)) == PURCHASE_AVAILABLE && B.GetCredits() > FI.static.Cost(Rx_PRI(B.PlayerReplicationInfo)))
				FilteredFI.AddItem(FI);
		}
	}

	if((FilteredV.length + FilteredFI.length) <= 0)
		return false;

	if((FilteredV.length <= 0 || bPrioritizeInfantry) && FilteredFI.Length > 0)
	{
		Choice = Rand(FilteredFI.length);
		InfantryCost = FilteredFI[Choice].Static.Cost(Rx_PRI(B.PlayerReplicationInfo));

		TempString = FilteredFI[Choice].static.BotPTString();

		if(B.PTTask != "" && B.PTTask != "Refill" && Left(B.PTTask,8) != "Buy Char" && B.PTTask != "Rebuy Char")
		{
			for (i = 0; i < B.PTQueue.Length; i++)
			{
				if( Left(B.PTQueue[i],8) == "Buy Char" || B.PTQueue[i] == "Rebuy Char")
				{
					bOverridingPurchase = true;
					B.PTQueue[i] = TempString;
					break;
				}
			}	

			if(!bOverridingPurchase) 
				B.PTQueue.AddItem(TempString);
		}
		else
			B.PTTask = TempString;

		B.TacticsPTTask = TempString;

		bOverridingPurchase = false;

		if(FilteredV.length > 0)	
		{
			Choice = Rand(FilteredV.length);
			VehicleCost = FilteredV[Choice].Static.GetCost(Rx_PRI(B.PlayerReplicationInfo)) + InfantryCost;

			TempString = FilteredV[Choice].static.BotPTString();

			if(B.PTTask != "" && B.PTTask != "Random Buy Vehicle" && Left(B.PTTask, 11) != "Buy Vehicle")
			{
				for (i = 0; i < B.PTQueue.Length; i++)
				{
					if( Left(B.PTTask, 11) == "Buy Vehicle" || B.PTQueue[i] == "Random Buy Vehicle")
					{
						bOverridingPurchase = true;
						B.PTQueue[i] = TempString;
						break;
					}
				}

				if(!bOverridingPurchase) 
				B.PTQueue.AddItem(TempString);
			}	

	
			else
				B.PTTask = TempString;
		}
	}

	else
	{
		if(FilteredV.length > 0)	
		{
			Choice = Rand(FilteredV.length);
			VehicleCost = FilteredV[Choice].Static.GetCost(Rx_PRI(B.PlayerReplicationInfo)) + InfantryCost;

			TempString = FilteredV[Choice].static.BotPTString();

			bOverridingPurchase = false;

			if(B.PTTask != "" && B.PTTask != "Random Buy Vehicle" && Left(B.PTTask, 11) != "Buy Vehicle")
			{
				for (i = 0; i < B.PTQueue.Length; i++)
				{
					if( Left(B.PTTask, 11) == "Buy Vehicle" || B.PTQueue[i] == "Random Buy Vehicle")
					{
						bOverridingPurchase = true;
						B.PTQueue[i] = TempString;
						break;
					}
				}

				if(!bOverridingPurchase) 
					B.PTQueue.AddItem(TempString);
			}	


			else
				B.PTTask = TempString;

			B.TacticsPTTask = TempString;

		}

		if(FilteredFI.length > 0)	
		{
			Choice = Rand(FilteredFI.length);
			InfantryCost = FilteredFI[Choice].Static.Cost(Rx_PRI(B.PlayerReplicationInfo)) + VehicleCost;

			TempString = FilteredFI[Choice].static.BotPTString();

			bOverridingPurchase = false;
		
			if(B.PTTask != "" && B.PTTask != "Refill" && Left(B.PTTask,8) != "Buy Char" && B.PTTask != "Rebuy Char")
			{
				for (i = 0; i < B.PTQueue.Length; i++)
				{
					if( Left(B.PTQueue[i],8) == "Buy Char" || B.PTQueue[i] == "Rebuy Char")
					{
						bOverridingPurchase = true;
						B.PTQueue[i] = TempString;
						break;
					}
				}	

				if(!bOverridingPurchase) 
					B.PTQueue.AddItem(TempString);
			}
			else
				B.PTTask = TempString;

		}
	}

	return true;
}


static function bool IsAvailable(Rx_Bot B)
{
	local WorldInfo GameWorld;

	GameWorld = class'WorldInfo'.static.GetWorldInfo();

	if(GameWorld.TimeSeconds > Default.TimeUntilRelevancyExpires && Default.bCanExpire)
		return false;

	if(GameWorld.TimeSeconds < Default.GameTimeRelevancy)
		return false;

	if(B.Skill < Default.SkillMinimum)
		return false;

	if(Rx_SquadAI(B.Squad).GetOrders() != Default.Orders)
		return false;

	if(Rx_Game(GameWorld.Game).GetPurchaseSystem().AreHighTierPayClassesDisabled(B.GetTeamNum()))
	{
		if(Default.bAdvancedClassOnly)
			return false;
	}
	else if (Default.bInfantryBuildingPostMortem)
		return false;

	if(Rx_Game(GameWorld.Game).GetPurchaseSystem().AreVehiclesDisabled(B.GetTeamNum(),B))
	{
		if(Default.VehicleToMass.Length > 0 && Default.InfantryToMass.Length <= 0)
			return false;


	}
	else if (Default.bVehicleBuildingPostMortem)
		return false;



	return true;


}


DefaultProperties
{

	TacticName= "a strategic tactic"
	MinimumParticipant = 1;
}