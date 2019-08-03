class SP_Game extends Rx_Game;

var class<Rx_FamilyInfo> HumanSpawnClass;
var class<Rx_FamilyInfo> GDIBotSpawnClass;
var class<Rx_FamilyInfo> NodBotSpawnClass;

function SetPlayerDefaults(Pawn PlayerPawn) {
	local UTPlayerReplicationInfo PRI;
	
	PRI = UTPlayerReplicationInfo(PlayerPawn.PlayerReplicationInfo);
	if (PRI != none) { 
		if (PRI.bBot == false) {
			// Human
			PRI.CharClassInfo = HumanSpawnClass;
		}
		else if (PRI.GetTeamNum() == TEAM_GDI) {
			// GDI Bot
			PRI.CharClassInfo = GDIBotSpawnClass;
		}
		else {
			// Nod Bot
			PRI.CharClassInfo = NodBotSpawnClass;
		}
		PlayerPawn.NotifyTeamChanged();
		`LogRxPub("GAME" `s "Spawn;" `s "player" `s `PlayerLog(PRI) `s "character" `s PRI.CharClassInfo);

		Super(UTTeamGame).SetPlayerDefaults(PlayerPawn);
		Rx_PRI(PRI).equipStartWeapons();
	}
}

DefaultProperties
{
	HumanSpawnClass = class'SP_FamilyInfo_GDI_Havoc'
	GDIBotSpawnClass = class'Rx_FamilyInfo_GDI_Soldier'
	NodBotSpawnClass = class'Rx_FamilyInfo_Nod_Soldier'
	PlayerControllerClass = class'SP_Controller'
	HUDClass = class'SP_HUD'

	MapPrefixes.Empty
	MapPrefixes.Add("SP")
	Acronym = "SP"
	GameType = 3 // 3 = SP_Game
}
