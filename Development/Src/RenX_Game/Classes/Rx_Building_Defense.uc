class Rx_Building_Defense extends Rx_Building
	abstract;

var() float Range_Multiplier;
var() bool bDisabled;
var vector SentinelLocation;

replication {
	if( bNetDirty && Role == ROLE_Authority )
		SentinelLocation;
}
	
DefaultProperties
{
	myBuildingType=BT_Def
	Range_Multiplier = 1.0
	SupportedEvents.Add(class'Rx_SeqEvent_DefenseEvent')
}
