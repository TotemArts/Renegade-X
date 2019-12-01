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
	else if (Type == 'AdminMsg') {
		// Log broadcast
		if (Sender != None) {
			`LogRx("CHAT"`s "AdminMsg;" `s `PlayerLog(PRI)`s "said:" `s Msg);
		}
		else {
			`LogRx("CHAT" `s "HostAdminMsg;" `s "said:" `s Msg);
		}
	}
	else if (Type == 'AdminWarn') {
		// Log broadcast
		if (Sender != None) {
			`LogRx("CHAT"`s "AdminWarn;" `s `PlayerLog(PRI)`s "said:" `s Msg);
		}
		else {
			`LogRx("CHAT" `s "HostAdminWarn;" `s "said:" `s Msg);
		}
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
function BroadcastPM( PlayerController Sender, PlayerController Recipient, coerce string Msg, optional name Type)
{
	local PlayerReplicationInfo SenderPRI;

	// see if allowed (limit to prevent spamming)
	if ( Sender != None && !AllowsBroadcast(Sender, Len(Msg)) )
		return;

	// Get PRI of sender (may be None)
	if (Sender != None) {
		SenderPRI = Sender.PlayerReplicationInfo;
	}

	// Filter message based on server rules
	Msg = CleanMessage(Msg);
	Msg = ApplyChatFilter(Msg);

	// Fire off log (if needed) and set Type
	if (Type == 'PM_AdminMsg') {
		// Admin message
		if (SenderPRI != None) {
			`LogRx("CHAT"`s "PAdminMsg;" `s `PlayerLog(SenderPRI) `s "to" `s `PlayerLog(Recipient.PlayerReplicationInfo) `s "said:" `s Msg);
		}
		else {
			`LogRx("CHAT"`s "HostPAdminMsg;" `s `PlayerLog(Recipient.PlayerReplicationInfo) `s "message:" `s Msg);
		}
	}
	else if (Type == 'PM_AdminWarn') {
		// Admin message
		if (SenderPRI != None) {
			`LogRx("CHAT"`s "PAdminWarn;" `s `PlayerLog(SenderPRI) `s "to" `s `PlayerLog(Recipient.PlayerReplicationInfo) `s "said:" `s Msg);
		}
		else {
			`LogRx("CHAT"`s "HostPAdminWarn;" `s `PlayerLog(Recipient.PlayerReplicationInfo) `s "message:" `s Msg);
		}
	}
	else {
		// PM from Host
		if (SenderPRI == None) {
			`LogRx("CHAT"`s "HostPMsg;" `s `PlayerLog(Recipient.PlayerReplicationInfo) `s "message:" `s Msg);
		}
		// else // logging player-to-player PMs seems unethical, so if you're thinking about it, don't.

		Type = 'PM';
	}

	// Send to recipient
	BroadcastText(SenderPRI, Recipient, Msg, Type);

	// Play PM sound
	Recipient.ClientPlaySound(PMSound);

	// Send message back to sender to confirm that it was sent successfully (messages are considered unreliable)
	if (Sender != None) {
		BroadcastText(Recipient.PlayerReplicationInfo, Sender, Msg, 'PM_Loopback');
	}
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
