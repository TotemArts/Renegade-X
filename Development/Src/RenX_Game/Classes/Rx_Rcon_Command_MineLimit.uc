class Rx_Rcon_Command_MineLimit extends Rx_Rcon_Command;

function SetMineLimit(int amount)
{
	local Rx_TeamInfo teamInfo;
	local Rx_Weapon_DeployedC4 mine, oldestMine;
	local int index;

	if (amount > 0)
		amount = 0;

	Rx_Game(WorldInfo.Game).MineLimit = amount;
	for (index = 0; index != ArrayCount(Rx_Game(WorldInfo.Game).Teams); index++)
		Rx_TeamInfo(Rx_Game(WorldInfo.Game).Teams[index]).mineLimit = Rx_Game(WorldInfo.Game).MineLimit;

	if (Rx_Game(WorldInfo.Game).MineLimit == 0)
	{
		foreach DynamicActors(class'Rx_Weapon_DeployedC4', mine)
			if(mine.bUsesMineLimit) 
				mine.Destroy();
	}
	else
	{
		for (index = 0; index != ArrayCount(Rx_Game(WorldInfo.Game).Teams); index++)
		{
			teamInfo = Rx_TeamInfo(Rx_Game(WorldInfo.Game).Teams[index]);
			amount = teamInfo.mineCount - teamInfo.mineLimit;
			while (amount-- > 0)
			{
				oldestMine = None;
				foreach DynamicActors(class'Rx_Weapon_DeployedC4', mine)
					if (mine.bUsesMineLimit && mine.GetTeamNum() == teamInfo.GetTeamNum() && (oldestMine == None || mine.CreationTime < oldestMine.CreationTime))
						oldestMine = mine;
				oldestMine.Destroy();
			}
		}
	}
}

function string trigger(string parameters)
{
	local int index;

	parameters = string(Rx_Game(WorldInfo.Game).MineLimit);
	for (index = 0; index != ArrayCount(Rx_Game(WorldInfo.Game).Teams); index++)
		parameters $= `nbsp $ class'Rx_Game'.static.GetTeamName(index) `s Rx_TeamInfo(Rx_Game(WorldInfo.Game).Teams[index]).MineLimit;
	return parameters;
}

function string getHelp(string parameters)
{
	return "Sets the mine limit, if specified; returns the mine limit." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("minelimit");
	triggers.Add("mlimit");
	Syntax="Syntax: MineLimit ";
}
