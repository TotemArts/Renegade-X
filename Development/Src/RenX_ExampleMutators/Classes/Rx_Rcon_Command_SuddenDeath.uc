/**
 * This file is in the public domain, furnished "as is", without technical
 * support, and with no warranty, express or implied, as to its usefulness for
 * any purpose.
 *
 * Written by Jessica James <jessica.aj@outlook.com>
 */

class Rx_Rcon_Command_SuddenDeath extends Rx_Rcon_Command;

var bool bSuddenDeathActivated;

function ActivateSuddenDeath()
{
	local Actor A;

	bSuddenDeathActivated = true;
	foreach AllActors(class'Actor', A)
	{
		if (Rx_Building_Team_Internals(A) != None)
		{
			if ((Rx_Building_Obelisk_Internals(A) != None || Rx_Building_AdvancedGuardTower_Internals(A) != None) && Rx_Building_Team_Internals(A).bNoPower == false)
				Rx_Building_Team_Internals(A).PowerLost();
		}
		else if (Rx_Defence(A) != None)
			Rx_Defence(A).Died(None, class'DamageType', A.Location);
	}
}

function string trigger(string parameters)
{
	if (bSuddenDeathActivated)
		return "Sudden Death:" `s "Already Active";
	ActivateSuddenDeath();
	return "Sudden Death:" `s "Activated";
}

function string getHelp(string parameters)
{
	return "Disables base defenses." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("suddendeath");
	Syntax="Syntax: SuddenDeath";
	bSuddenDeathActivated = false;
}