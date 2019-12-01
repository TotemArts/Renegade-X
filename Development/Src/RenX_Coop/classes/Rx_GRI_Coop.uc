class Rx_GRI_Coop extends Rx_GRI;

var int PlayerTeam;

replication
{
	if (bNetDirty)
		PlayerTeam;
}

simulated function PostBeginPlay()
{
	if(Rx_MapInfo_Cooperative(WorldInfo.GetMapInfo()) != None)
		PlayerTeam = Rx_MapInfo_Cooperative(WorldInfo.GetMapInfo()).PlayerTeam;

	super.PostBeginPlay();
}