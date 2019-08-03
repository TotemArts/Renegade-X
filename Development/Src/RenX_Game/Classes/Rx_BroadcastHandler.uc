/** Adds RxLogging functionality. */
class Rx_BroadcastHandler extends BroadcastHandler
	config(RenegadeX);

/** Controls whether non-admins can send messages to the admins. */
var config bool bAllowGuestToMsgAdmin;

var config array<string> ChatFilter;
var array<string> HardcodedFilter;  // For censoring cheat-related stuff.
var SoundCue PMSound; 

/** Copy of BroadcastHandler::Broadcast(...) with RxLog added. */
function Broadcast( Actor Sender, coerce string Msg, optional name Type )
{
	local PlayerController P;
	local PlayerReplicationInfo PRI;

	// see if allowed (limit to prevent spamming)
	if ( !AllowsBroadcast(Sender, Len(Msg)) )
		return;

	if ( Pawn(Sender) != None )
		PRI = Pawn(Sender).PlayerReplicationInfo;
	else if ( Controller(Sender) != None )
		PRI = Controller(Sender).PlayerReplicationInfo;

	// EDIT START:
	Msg = CleanMessage(Msg);
	Msg = ApplyChatFilter(Msg);

	if (Type == 'Say')
	{
		if (PRI != None)
			`LogRx("CHAT"`s "Say;"`s `PlayerLog(PRI)`s "said:"`s Msg);
		else
			`LogRx("CHAT" `s "HostSay;" `s "said:" `s Msg);
	}
	// EDIT END.

	foreach WorldInfo.AllControllers(class'PlayerController', P)
	{
		BroadcastText(PRI, P, Msg, Type);
	}
}

/** Copy of BroadcastHandler::BroadcastTeam(...) with RxLog added. */
function BroadcastTeam( Controller Sender, coerce string Msg, optional name Type )
{
	local PlayerController P;

	// see if allowed (limit to prevent spamming)
	if ( !AllowsBroadcast(Sender, Len(Msg)) )
		return;

	// EDIT START:
	Msg = CleanMessage(Msg);
	Msg = ApplyChatFilter(Msg);

	if (Type == 'TeamSay')
		`LogRx("CHAT"`s "TeamSay;"`s `PlayerLog(Sender.PlayerReplicationInfo)`s "said:"`s Msg);
	// EDIT END.
	
	if(Type == 'TeamSay' && Rx_Game(WorldInfo.Game).Commander_PRI[Sender.GetTeamNum()] == Rx_PRI(Sender.PlayerReplicationInfo) ) Type = 'Commander';
	
	foreach WorldInfo.AllControllers(class'PlayerController', P)
	{
		if (P.PlayerReplicationInfo.Team == Sender.PlayerReplicationInfo.Team)
		{
			BroadcastText(Sender.PlayerReplicationInfo, P, Msg, Type);
		}
	}
}

/** Broadcast to the moderators. */
function BroadcastAdmin( Controller Sender, coerce string Msg )
{
	local PlayerController P;

	if (!Sender.PlayerReplicationInfo.bAdmin && !bAllowGuestToMsgAdmin)
	{
		if (PlayerController(Sender) != None)
			PlayerController(Sender).ClientMessage("This server doesn't allow you to send messages to the moderators.");
		return;
	}

	// see if allowed (limit to prevent spamming)
	if ( !AllowsBroadcast(Sender, Len(Msg)) )
		return;

	Msg = CleanMessage(Msg);
	Msg = ApplyChatFilter(Msg);

	if (Sender.PlayerReplicationInfo.bAdmin)
	{
		`LogRx("CHAT"`s "AdminSay;" `s `PlayerLog(Sender.PlayerReplicationInfo)`s"said:"`s Msg);

		foreach WorldInfo.AllControllers(class'PlayerController', P)
		{
			if (P.PlayerReplicationInfo.bAdmin)
				BroadcastText(Sender.PlayerReplicationInfo, P, Msg, 'AdminSay');
		}
	}
	else
	{
		`LogRx("CHAT"`s "ReportSay;" `s `PlayerLog(Sender.PlayerReplicationInfo)`s "said:"`s Msg);
		foreach WorldInfo.AllControllers(class'PlayerController', P)
		{
			if (P.PlayerReplicationInfo.bAdmin)
				BroadcastText(Sender.PlayerReplicationInfo, P, Msg, 'ReportSay');
		}

		if (!Sender.PlayerReplicationInfo.bAdmin && PlayerController(Sender) != None)
			BroadcastText(Sender.PlayerReplicationInfo, PlayerController(Sender), Msg, 'ReportSay');
	}

	
}

/** */
function BroadcastPM( PlayerController Sender, PlayerController Recipent, coerce string Msg)
{
	// see if allowed (limit to prevent spamming)
	if ( Sender != None && !AllowsBroadcast(Sender, Len(Msg)) )
		return;

	Msg = CleanMessage(Msg);
	Msg = ApplyChatFilter(Msg);

	if (Sender != None)
	{
		BroadcastText(Sender.PlayerReplicationInfo, Recipent, Msg, 'PM');
		Recipent.ClientPlaySound(PMSound);
		// Also send back to Sender, to confirm that it went thru (given that it was an unreliable call)
		BroadcastText(Recipent.PlayerReplicationInfo, Sender, Msg, 'PM_Loopback');
	}
	else
		BroadcastText(None, Recipent, Msg, 'PM');
}

function string ApplyChatFilter(string Msg)
{
	local string check;
	foreach HardcodedFilter(check)
		Msg = Repl(Msg, check, "", false);
	foreach ChatFilter(check)
		Msg = Repl(Msg, check, "***", false);
	return Msg;
}

function static string CleanMessage(string Msg)
{
	Msg = Repl(Msg, "\n", " ");
	Msg = Repl(Msg, `rcon_delim, " ");
	Msg = Repl(Msg, Chr(9), " ");
	return Msg;
}

DefaultProperties
{
	HardcodedFilter(0)="redarmy.pw"
	PMSound=SoundCue'rx_interfacesound.Wave.SC_PM_Yo'
}
