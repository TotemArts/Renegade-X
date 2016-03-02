// This is an actor so that it can be included in the seamless travel list without depending on Rx_Rcon.
class Rx_Rcon_Commands_Container extends Actor;

var array<Rx_Rcon_Command> RconCommands;
var array<string> BlockedConsoleCommands;

function InitRconCommands()
{
	local Rx_Mutator M;
	SpawnCommand(class'Rx_Rcon_Command_Help');
	SpawnCommand(class'Rx_Rcon_Command_ClientList');
	SpawnCommand(class'Rx_Rcon_Command_LoadMutator');
	SpawnCommand(class'Rx_Rcon_Command_UnloadMutator');
	SpawnCommand(class'Rx_Rcon_Command_ListMutators');
	SpawnCommand(class'Rx_Rcon_Command_HostSay');
	SpawnCommand(class'Rx_Rcon_Command_HostPrivateSay');
	SpawnCommand(class'Rx_Rcon_Command_Kick');
	SpawnCommand(class'Rx_Rcon_Command_KickBan');
	SpawnCommand(class'Rx_Rcon_Command_ForceKick');
	SpawnCommand(class'Rx_Rcon_Command_TextMute');
	SpawnCommand(class'Rx_Rcon_Command_TextUnMute');
	SpawnCommand(class'Rx_Rcon_Command_ChangeMap');
	SpawnCommand(class'Rx_Rcon_Command_RecordDemo');
	SpawnCommand(class'Rx_Rcon_Command_SwapTeams');
	SpawnCommand(class'Rx_Rcon_Command_EndMap');
	SpawnCommand(class'Rx_Rcon_Command_ForceNonSeamless');
	SpawnCommand(class'Rx_Rcon_Command_ForceSeamless');
	SpawnCommand(class'Rx_Rcon_Command_CancelVote');
	SpawnCommand(class'Rx_Rcon_Command_MutateAsNone');
	SpawnCommand(class'Rx_Rcon_Command_MutateAsPlayer');
	SpawnCommand(Class'Rx_Rcon_Command_HasCommand');
	SpawnCommand(class'Rx_Rcon_Command_Map');
	SpawnCommand(class'Rx_Rcon_Command_Ping');
	SpawnCommand(class'Rx_Rcon_Command_Team');
	SpawnCommand(class'Rx_Rcon_Command_Team2');
	SpawnCommand(class'Rx_Rcon_Command_ClientVarList');
	SpawnCommand(class'Rx_Rcon_Command_BotList');
	SpawnCommand(class'Rx_Rcon_Command_BotVarList');
	SpawnCommand(class'Rx_Rcon_Command_PlayerInfo');
	SpawnCommand(class'Rx_Rcon_Command_MineLimit');
	SpawnCommand(class'Rx_Rcon_Command_VehicleLimit');
	SpawnCommand(class'Rx_Rcon_Command_ChangeName');
	SpawnCommand(class'Rx_Rcon_Command_ServerInfo');
	SpawnCommand(class'Rx_Rcon_Command_GameInfo');
	SpawnCommand(class'Rx_Rcon_Command_BuildingInfo');
	SpawnCommand(class'Rx_Rcon_Command_Rotation');
	SpawnCommand(class'Rx_Rcon_Command_MineBan');
	SpawnCommand(class'Rx_Rcon_command_TeamInfo');
	SpawnCommand(class'Rx_Rcon_Command_SpectateMode');
	SpawnCommand(class'Rx_Rcon_Command_NormalMode');
	SpawnCommand(class'Rx_Rcon_Command_AddMap');
	SpawnCommand(class'Rx_Rcon_Command_RemoveMap');
	if (!Rx_Game(WorldInfo.Game).bIsCompetitive)
	{
		SpawnCommand(class'Rx_Rcon_Command_Kill');
		SpawnCommand(class'Rx_Rcon_Command_GiveCredits');
		SpawnCommand(class'Rx_Rcon_Command_Disarm');
		SpawnCommand(class'Rx_Rcon_Command_DisarmBeacon');
		SpawnCommand(class'Rx_Rcon_Command_DisarmC4');
	}
	//SpawnCommand(class'Rx_Rcon_Command_');
	for (M = Rx_Game(WorldInfo.Game).GetBaseRxMutator(); M != None; M = M.GetNextRxMutator())
		M.InitRconCommands();
}

function SpawnCommand(class<Rx_Rcon_Command> command)
{
	RconCommands.AddItem(new(self) command);
}

function Rx_Rcon_Command GetCommand(string trigger)
{
	local int index;
	for (index = 0; index != RconCommands.Length; index++)
		if (RconCommands[index].matches(trigger))
			return RconCommands[index];
	return None;
}

function bool IsBlockedCommand(string trigger)
{
	local string command;
	foreach BlockedConsoleCommands(command)
		if (command == trigger)
			return true;
	return false;
}

DefaultProperties
{
	BlockedConsoleCommands.Add("SAY");
}
