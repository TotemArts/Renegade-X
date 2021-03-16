class S_Building_AirStrip_Internals_BlackHand extends Rx_Building_AirStrip_Internals;

simulated function Init(Rx_Building Visuals, bool isDebug )
{
	super.Init(Visuals, isDebug);
	if(WorldInfo.Netmode != NM_Client) {
		if (S_Building_Airstrip_BlackHand(Visuals).AirTowerInternals != None) {
			S_Building_Airstrip_BlackHand(Visuals).AirTowerInternals.AirstripInternals = self;
		}
	}
}

DefaultProperties
{
	TeamID = TEAM_GDI
}