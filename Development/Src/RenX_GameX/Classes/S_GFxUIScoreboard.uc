class S_GFxUIScoreboard extends Rx_GFxUIScoreboard;

function UpdatePlayers()
{
	local int i, NODp, GDIp;
	local array<PlayerReplicationInfo> PRIArray;
	local PlayerReplicationInfo PRI;
	local Rx_PRI RPRI;
	local GFxObject DataProviderNod, DataProviderGDI, tmpObj;

	GDIp = 0;
	NODp = 0;
	
	DataProviderNod = CreateObject("scaleform.clik.data.DataProvider");
	DataProviderGDI = CreateObject("scaleform.clik.data.DataProvider");

	foreach RxGRI.PRIArray(pri)
	{
		if(Rx_Pri(pri) == None || Rx_PRI(pri).bIsScripted)	// skip if the bot is a scripted one
			continue;

		PRIArray.AddItem(pri);
	}

	PRIArray.Sort(SortPriDelegate);	
	
	for (i = 0; i < PRIArray.Length ; i++)
	{
		
		RPRI = Rx_PRI(PRIArray[i]);
		
		tmpObj = CreateObject("Object");
		tmpObj.SetString("PlayerName", PRIArray[i].GetHumanReadableName());
		tmpObj.SetInt("Score", RPRI.GetRenScore());
		tmpObj.SetInt("Kills", RPRI.GetRenKills());
		tmpObj.SetInt("Deaths", PRIArray[i].Deaths);
		tmpObj.SetInt("VehicleKills", RPRI.Total_Vehicle_Kills);
		tmpObj.SetInt("Ping", PRIArray[i].Ping * 4);
		tmpObj.SetInt("Vet_Rank", int(RPRI.VRank) + 1);
		tmpObj.SetString("Color", "0xD4F0FF");

		if (RPRI.bIsCommander)
		{
			switch (PRIArray[i].GetTeamNum())
			{
				case TEAM_GDI:
					tmpObj.SetString("Color", "0x3260FF");
				break;

				case TEAM_NOD:
					tmpObj.SetString("Color", "0xFF0000");
				break;
			}
		}
		else if(RPRI.bIsAFK) 
		{
			tmpObj.SetString("Color", "0x8A9CA6");
		}
		else if(RPRI.bBot)
		{
			tmpObj.SetString("Color", "0xE1C197");
		}

		if (PRIArray[i] == PC.PlayerReplicationInfo) 
			tmpObj.SetString("Color", "0x00FF00");

		if (PRIArray[i].GetTeamNum() == TEAM_GDI && GDIp < 32)
		{
			tmpObj.SetInt("Position", GDIp + 1);
			DataProviderGDI.SetElementObject(GDIp, tmpObj);
			GDIp++;
		}
		else if (PRIArray[i].GetTeamNum() == TEAM_NOD && NODp < 32)
		{
			tmpObj.SetInt("Position", NODp + 1);
			DataProviderNOD.SetElementObject(NODp, tmpObj);
			NODp++;
		}
		else
			continue;
	}

	if(NODPlayerList != none || GDIPlayerList != none)
	{
		NODPlayerList.SetObject("dataProvider", DataProviderNOD);
		GDIPlayerList.SetObject("dataProvider", DataProviderGDI);

		NODPlayerList.SetInt("rowCount", NODp);
		GDIPlayerList.SetInt("rowCount", GDIp);		

	}
}

DefaultProperties
{
	MovieInfo=SwfMovie'SHud.SScoreboard'
}