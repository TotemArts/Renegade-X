class Rx_Message_Vehicle extends UTLocalMessage;

var localized array<string> VehicleMessages;

enum VehicleMessage
{
	VM_Bound,
	VM_Bound_Auto,
	VM_Unbound,
	
	VM_CanBind,
	VM_CanBind_Replace,
	VM_CanBind_PrevUnbound,
	VM_CannotBind,

	VM_Driver_Locked,
	VM_Driver_Unlocked,

	VM_NoEntry_DriverLocked,
	VM_NoEntry_BuyerReserved,
	VM_NoEntry_TeamReserved,

	VM_EnemyStolen_Team,
	VM_TeammateEntered,
	VM_Destroyed,

	VM_OwnerLocked,
	
	VM_EnemyStolen_Enemy,
	VM_EnemyStolen_Unbound,

	VM_TeammateEntered_Locked
};

static function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local string MessageString;

	MessageString = static.GetStringWithPC(Switch, (RelatedPRI_1 == P.PlayerReplicationInfo), RelatedPRI_1, RelatedPRI_2, OptionalObject, P);
	if ( MessageString != "" )
	{
		if ( P.myHud != None )
			P.myHUD.LocalizedMessage(
				Default.Class,
				RelatedPRI_1,
				RelatedPRI_2,
				MessageString,
				Switch,
				static.GetPos(Switch, P.myHUD),
				static.GetLifeTime(Switch),
				static.GetFontSize(Switch, RelatedPRI_1, RelatedPRI_2, P.PlayerReplicationInfo),
				static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject),
				OptionalObject );

		if(IsConsoleMessage(Switch) && LocalPlayer(P.Player) != None && LocalPlayer(P.Player).ViewportClient != None)
			LocalPlayer(P.Player).ViewportClient.ViewportConsole.OutputText( MessageString );
	}
}

//RelatedPRI1 = Owner
//RelatedPRI2 = Other
//OptionalObject = Rx_Vehicle Class
static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local string msg;

	msg = default.VehicleMessages[Switch];

	if (OptionalObject != None)
		msg = Repl(msg, "`VehicleClass`", class<Rx_Vehicle>(OptionalObject).default.VehicleNameString);

	if (RelatedPRI_1 != None)
		msg = Repl(msg, "`OwnerName`", RelatedPRI_1.PlayerName);

	if (RelatedPRI_2 != None)
		msg = Repl(msg, "`OtherName`", RelatedPRI_2.PlayerName);

	return msg;
}

static function string GetStringWithPC(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject,
	optional PlayerController PC
	)
{
	local string msg;

	msg = GetString(Switch, bPRI1HUD, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if (InStr(msg, "`LockKey`") > -1)
	{
		msg = Repl(msg, "`LockKey`", Caps(UDKPlayerInput(PC.PlayerInput).GetUDKBindNameFromCommand("GBA_ToggleVehicleLocking")) );
	}
	if (InStr(msg, "`IntegerValue`") > -1)
	{
		msg = Repl(msg, "`IntegerValue`", Rx_Controller(PC).VehicleMessageInt );
	}
	if (Switch == VM_NoEntry_TeamReserved)
	{
		msg = Repl(msg, "`OwnerTeam`", class'Rx_Game'.static.GetTeamName(RelatedPRI_1.GetTeamNum()) );
	}

	return msg;
}