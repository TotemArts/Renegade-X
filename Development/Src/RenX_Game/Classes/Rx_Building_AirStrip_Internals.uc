class Rx_Building_AirStrip_Internals extends Rx_Building_Team_Internals;

simulated function Init(Rx_Building Visuals, bool isDebug )
{
	super.Init(Visuals, isDebug);
	if(WorldInfo.Netmode != NM_Client) {
		if (Rx_Building_Airstrip(Visuals).AirTowerInternals != None) {
			Rx_Building_Airstrip(Visuals).AirTowerInternals.AirstripInternals = self;
		}
	}
}

simulated function int GetHealth() 
{
	return BuildingVisuals.GetHealth(); 
}

simulated function int GetMaxHealth() 
{
	return BuildingVisuals.GetMaxHealth(); 
}

simulated function bool IsDestroyed()
{
	return BuildingVisuals.IsDestroyed();
}

DefaultProperties
{
	TeamID = TEAM_NOD
	Begin Object Name=BuildingSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'RX_BU_AirStrip.Mesh.SK_BU_AirStrip'
		PhysicsAsset=PhysicsAsset'RX_BU_AirStrip.Mesh.SK_BU_AirStrip_Physics'
		Translation = (Z=0)
	End Object
}
