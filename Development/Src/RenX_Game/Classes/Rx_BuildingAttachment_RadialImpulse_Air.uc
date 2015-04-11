class Rx_BuildingAttachment_RadialImpulse_Air extends Rx_BuildingAttachment_RadialImpulse;

simulated function Init( Rx_Building_Internals inBuilding, optional name SocketName )
{
	if (Rx_Building_AirTower_Internals(inBuilding) != None)
		Rx_Building_AirTower_Internals(inBuilding).Impulse = self;
	else
		`log("BUILDING ERROR: Attemped to add RadialImpulse_Air to non-Air building.");
}

DefaultProperties
{
	Begin Object Name=ImpulseComp
		ImpulseRadius=500
		ImpulseStrength=900
	End Object
}
