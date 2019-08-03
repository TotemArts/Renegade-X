class Rx_GameplayEventsWriter extends GameplayEventsWriter;

`define INCLUDE_RENX_GAME_STATS(dummy)
`include(RenX_Game\RenXStats.uci);
`undefine(INCLUDE_RENX_GAME_STATS)


DefaultProperties
{
	SupportedEvents.Add((EventID=GAMEEVENT_VEHICLE_LOCATION_POLL,EventName="Vehicle Locations",StatGroup=(Group=GSG_Player,Level=10),EventDataType=`GET_PlayerLocationPoll))
	SupportedEvents.Add((EventID=GAMEEVENT_VEHICLE_LOCATION_POLL_GDI,EventName="GDI Vehicle Locations",StatGroup=(Group=GSG_Player,Level=10),EventDataType=`GET_PlayerLocationPoll))
	SupportedEvents.Add((EventID=GAMEEVENT_VEHICLE_LOCATION_POLL_NOD,EventName="NOD Vehicle Locations",StatGroup=(Group=GSG_Player,Level=10),EventDataType=`GET_PlayerLocationPoll))
	SupportedEvents.Add((EventID=GAMEEVENT_VEHICLE_WITH_HARV_LOCATION_POLL,EventName="Vehicle & Harvester Locations",StatGroup=(Group=GSG_Player,Level=10),EventDataType=`GET_PlayerLocationPoll))
	SupportedEvents.Add((EventID=GAMEEVENT_BUILDING_DAMAGE_ATTACKER_LOCATION,EventName="Building Damage Attaker Location",StatGroup=(Group=GSG_Damage,Level=10),EventDataType=`GET_GamePosition))
	SupportedEvents.Add((EventID=GAMEEVENT_BUILDING_DAMAGE_AMOUNT,EventName="Building Damage Amount",StatGroup=(Group=GSG_Damage,Level=10),EventDataType=`GET_GamePosition))
	SupportedEvents.Add((EventID=GAMEEVENT_BUILDING_DAMAGE_LOCATION,EventName="Building Damage Location",StatGroup=(Group=GSG_Damage,Level=10),EventDataType=`GET_GamePosition))
	SupportedEvents.Add((EventID=GAMEEVENT_TEAM_BUILDING_DESTROYED,EventName="Building Destroyed",StatGroup=(Group=GSG_Team,Level=10),EventDataType=`GET_TeamString))
	SupportedEvents.Add((EventID=GAMEEVENT_PICKUP_CRATE,EventName="Pickup Crate",StatGroup=(Group=GSG_Player,Level=10),EventDataType=`GET_GamePosition))
	SupportedEvents.Add((EventID=GAMEEVENT_WEAPON_BEACON_DEPLOYED,EventName="Beacon Deployed",StatGroup=(Group=GSG_Weapon,Level=10),EventDataType=`GET_GamePosition))
	SupportedEvents.Add((EventID=GAMEEVENT_WEAPON_BEACON_DISARMED,EventName="Beacon Disarmed",StatGroup=(Group=GSG_Weapon,Level=10),EventDataType=`GET_GamePosition))
	SupportedEvents.Add((EventID=GAMEEVENT_WEAPON_BEACON_EXPLODED,EventName="Beacon Exploded",StatGroup=(Group=GSG_Weapon,Level=10),EventDataType=`GET_GamePosition))
	SupportedEvents.Add((EventID=GAMEEVENT_WEAPON_MINE_DEPLOYED,EventName="Mine Deployed",StatGroup=(Group=GSG_Weapon,Level=10),EventDataType=`GET_GamePosition))
	SupportedEvents.Add((EventID=GAMEEVENT_WEAPON_MINE_EXPLODED,EventName="Mine Exploded",StatGroup=(Group=GSG_Weapon,Level=10),EventDataType=`GET_GamePosition))
	SupportedEvents.Add((EventID=GAMEEVENT_DAMAGE,EventName="Damage",StatGroup=(Group=GSG_Weapon,Level=10),EventDataType=`GET_GamePosition))
	SupportedEvents.Add((EventID=GAMEEVENT_DAMAGE_TIBERIUM,EventName="Tiberium Damage",StatGroup=(Group=GSG_Weapon,Level=10),EventDataType=`GET_GamePosition))
}
