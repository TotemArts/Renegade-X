class Rx_GameObjective extends UTGameObjective;

/* TellBotHowToDisable()
tell bot what to do to disable me.
return true if valid/useable instructions were given
*/
simulated function PostBeginPlay()
{
	local PlayerController PC;
	local int i;

	super(UDKGameObjective).PostBeginPlay();
	StartTeam = DefenderTeamIndex;

	if ( Role == Role_Authority )
	{
		StartTeam	= DefenderTeamIndex;

		// find defensepoints
		ForEach WorldInfo.AllNavigationPoints(class'UTDefensePoint', DefensePoints)
			if ( DefensePoints.bFirstScript && (DefensePoints.DefendedObjective == self) )
				break;

		// find AreaVolume
		if ( MyBaseVolume != None )
		{
			MyBaseVolume.AssociatedActor = Self;
		}
	}

	// add to local HUD's post-rendered list
	ForEach LocalPlayerControllers(class'PlayerController', PC)
		if ( PC.MyHUD != None )
			PC.MyHUD.AddPostRenderedActor(self);

	// clear out any empty parking spot entries
	while (i < VehicleParkingSpots.length)
	{
		if (VehicleParkingSpots[i] == None)
		{
			VehicleParkingSpots.Remove(i, 1);
		}
		else
		{
			i++;
		}
	}
}

function bool TellBotHowToDisable(UTBot B)
{
	return UTSquadAI(B.Squad).FindPathToObjective(B,self);
}

DefaultProperties
{
	bFirstObjective = false			// disable the fixed objective
}
