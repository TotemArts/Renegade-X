class Rx_BuildingObjective_Dynamic extends Rx_BuildingObjective;

simulated function PostBeginPlay()
{
	// all stuff is handled elsewhere, just do Game Objective's usual PostBeginPlay
	super(Rx_GameObjective).PostBeginPlay();

}

function GenerateInfiltrationPoint()
{
	local array<NavigationPoint> NavPoints;
	local NavigationPoint N,BestN;
	local float Dist, BestDist;

	class'NavigationPoint'.static.GetAllNavInRadius(myBuilding.GetMCT(),myBuilding.GetMCT().location,1000.0,NavPoints);
	
		Foreach NavPoints(N)
		{
			if(N == Self)
				continue;

			if(N.PathList.Length <= 0)
				continue;
 
			Dist = VSizeSq(myBuilding.GetMCT().location - N.location);

			if(Dist <= BestDist)
			{
				BestDist = Dist;
				BestN = N;
			}	
		}

	InfiltrationPoint = BestN;
}
