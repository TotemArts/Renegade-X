class Rx_DeathMessage extends UTDeathMessage;

static function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if ( Switch == 1 )
	{
		if ( !Default.bNoConsoleDeathMessages )
		{
			Super(UTLocalMessage).ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
		}
		return;
	}
	if ( (RelatedPRI_1 == P.PlayerReplicationInfo)
		|| ((P.PlayerReplicationInfo != None) && P.PlayerReplicationInfo.bIsSpectator && (Pawn(P.ViewTarget) != None) && (Pawn(P.ViewTarget).PlayerReplicationInfo == RelatedPRI_1)) )
	{
		// Interdict and send the child message instead.
		if ( P.myHud != None )
			P.myHUD.LocalizedMessage(
		class'UTKillerMessage',
			RelatedPRI_1,
			RelatedPRI_2,
		class'UTKillerMessage'.static.GetString(Switch, RelatedPRI_1 == P.PlayerReplicationInfo, RelatedPRI_1, RelatedPRI_2, OptionalObject),
			Switch,
		class'UTKillerMessage'.static.GetPos(Switch, P.myHUD),
		class'UTKillerMessage'.static.GetLifeTime(Switch),
		class'UTKillerMessage'.static.GetFontSize(Switch, RelatedPRI_1, RelatedPRI_2, P.PlayerReplicationInfo),
		class'UTKillerMessage'.static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2),
			OptionalObject );

		if ( !Default.bNoConsoleDeathMessages )
			Super(UTLocalMessage).ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	}
	else if (RelatedPRI_2 == P.PlayerReplicationInfo)
	{
		if ( P.myHud != None )
			P.myHUD.LocalizedMessage(
		class'UTVictimMessage',
			RelatedPRI_1,
			RelatedPRI_2,
		class'UTVictimMessage'.static.GetString(Switch, true, RelatedPRI_1, RelatedPRI_2, OptionalObject),
			0,
		class'UTVictimMessage'.static.GetPos(Switch, P.myHUD),
		class'UTVictimMessage'.static.GetLifeTime(Switch),
		class'UTVictimMessage'.static.GetFontSize(Switch, RelatedPRI_1, RelatedPRI_2, P.PlayerReplicationInfo),
		class'UTVictimMessage'.static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2),
			OptionalObject );

		if ( !Default.bNoConsoleDeathMessages )
			Super(UTLocalMessage).ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	}
	else if ( !Default.bNoConsoleDeathMessages )
		Super(UTLocalMessage).ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

DefaultProperties
{
}
