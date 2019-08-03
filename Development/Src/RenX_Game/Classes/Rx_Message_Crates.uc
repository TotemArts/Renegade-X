class Rx_Message_Crates extends UTLocalMessage;

var localized array<string> PickupBroadcastMessages;

static function string GetString(
   optional int Switch,
   optional bool bPRI1HUD,
   optional PlayerReplicationInfo RelatedPRI_1,
   optional PlayerReplicationInfo RelatedPRI_2,
   optional Object OptionalObject
   )
{
	local Rx_Mutator RxMut;
	local string customMessage;
	
	// This allows us to overwrite the message displayed to everyone when picking up a crate
	if ( class'WorldInfo'.static.GetWorldInfo() != None && class'WorldInfo'.static.GetWorldInfo().NetMode == NM_DedicatedServer )
	{
		RxMut = Rx_Game(class'WorldInfo'.static.GetWorldInfo().Game).GetBaseRxMutator();
		if ( RxMut != None )
		{
			customMessage = RxMut.OnCratePickupMessageBroadcastPre(Switch, RelatedPRI_1);
			if ( customMessage != "" )
				return customMessage;
		}
	}

	return Repl(default.PickupBroadcastMessages[Switch], "`PlayerName`", RelatedPRI_1.PlayerName);
}

DefaultProperties
{
}
