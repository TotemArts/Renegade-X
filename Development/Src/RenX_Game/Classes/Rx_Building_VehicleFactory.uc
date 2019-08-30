class Rx_Building_VehicleFactory extends Rx_Building
	abstract;

var bool SpawnsC130;

DefaultProperties
{
	SpawnsC130 = false
	myBuildingType=BT_Veh

	SupportedEvents.Add(class'Rx_SeqEvent_FactoryEvent')
}
