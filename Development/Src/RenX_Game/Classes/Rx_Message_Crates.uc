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
   return Repl(default.PickupBroadcastMessages[Switch], "`PlayerName`", RelatedPRI_1.PlayerName);
}

DefaultProperties
{
}
