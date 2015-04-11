class Rx_BuildingAttachment_RadialImpulse_HoN extends Rx_BuildingAttachment_RadialImpulse;

simulated function Init( Rx_Building_Internals inBuilding, optional name SocketName )
{
	if (Rx_Building_HandOfNod_Internals(inBuilding) != None)
		Rx_Building_HandOfNod_Internals(inBuilding).Impulse = self;
	else
		`log("BUILDING ERROR: Attemped to add RadialImpulse_HoN to non-HoN building.");
}

DefaultProperties
{
	Begin Object Name=ImpulseComp
		ImpulseRadius=600
		ImpulseStrength=6000
	End Object
}
