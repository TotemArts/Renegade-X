class Rx_PlayerMonitor extends Actor
	config(PlayerMonitor);

struct PlayersInfo
{
	var string PlayerName;
	var string UUID;
	var float SavedScore;
	var float LastGameScore;
	var int JoinedGame;
};

var config Array<PlayersInfo> MyPlayersInfo;

function AddNewinfo(string ID,float Score,string MyName)
{
	local PlayersInfo NewInfo;

	NewInfo.UUID = ID;
	NewInfo.SavedScore = Score;
	NewInfo.LastGameScore = Score;
	NewInfo.JoinedGame = 1;
	NewInfo.PlayerName = MyName;

	MyPlayersInfo.AddItem(NewInfo);
	SaveConfig();
}

function float UpdateInfo(Rx_Controller Player)
{
	local string PlayerID;
	local float Score;
	local int Index;

	PlayerID = Player.PlayerUUID;
	Score = CalcPlayerScore(Rx_PRI(Player.PlayerReplicationInfo));
	Index = MyPlayersInfo.Find('UUID',PlayerID);
	if(Index >= 0)
	{
		MyPlayersInfo[Index].LastGameScore = Score;
		MyPlayersInfo[Index].SavedScore += Score;
		SaveConfig();
	}
	else
		AddNewInfo(PlayerID,Score,Player.PlayerReplicationInfo.PlayerName); // shouldn't really happen, but just in case

	return Score;

}

function float CalcPlayerScore(Rx_Pri pri)
{
	local float ret;

	ret = pri.GetRenScore();
	if(ret < 1.0)
		ret = 0.0;
	else	
		ret = loge(pri.GetRenScore());

	if(pri.GetRenKills() - pri.Deaths > 0)
		ret += loge((pri.GetRenKills() - pri.Deaths) / 2.0);

	return ret;
}
