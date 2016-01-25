/**
 * This file is in the public domain, furnished "as is", without technical
 * support, and with no warranty, express or implied, as to its usefulness for
 * any purpose.
 *
 * Written by Jessica James <jessica.aj@outlook.com>
 */

class SuddenDeath extends Rx_Mutator config(AgentMutators);

var config int sudden_death_time;

function ActivateSuddenDeath()
{
	local Rx_Rcon_Command_SuddenDeath cmd;
	Super.MatchStarting();
	cmd = Rx_Rcon_Command_SuddenDeath(Rx_Game(WorldInfo.Game).RconCommands.GetCommand("suddendeath"));
	if (cmd != None && cmd.bSuddenDeathActivated == false)
	{
		cmd.ActivateSuddenDeath();
		WorldInfo.Game.BroadcastHandler.Broadcast(None, "*WARNING* Sudden Death: Activated *WARNING*", 'Say');
	}
}

function MatchStarting()
{
	Super.MatchStarting();
	SetTimer(sudden_death_time, false, 'ActivateSuddenDeath');
}

function InitRconCommands()
{
	Rx_Game(WorldInfo.Game).RconCommands.SpawnCommand(class'Rx_Rcon_Command_SuddenDeath');
	Super.InitRconCommands();
}

defaultproperties
{
}