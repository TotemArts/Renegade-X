class Rx_Message_Deployed extends UTLocalMessage;

static function ClientReceive( PlayerController P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
								optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	super.ClientReceive(P,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);

	if (Switch == -1)
	{
		if (P.GetTeamNum() == TEAM_GDI)
			P.ClientPlaySound(class<Rx_Weapon_DeployedBeacon>(OptionalObject).default.GdiDeployedSound);
		else
			P.ClientPlaySound(class<Rx_Weapon_DeployedBeacon>(OptionalObject).default.NodDeployedSound);
	}
	else
	{
		if (P.GetTeamNum() == TEAM_GDI)
			P.ClientPlaySound(class<Rx_Weapon_DeployedBeacon>(OptionalObject).default.GdiDisarmSound);
		else
			P.ClientPlaySound(class<Rx_Weapon_DeployedBeacon>(OptionalObject).default.NodDisarmSound);
	}
}

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (Switch == -1)
		return RelatedPRI_1.PlayerName@"deployed"@class<Rx_Weapon_DeployedBeacon>(OptionalObject).default.DeployableName;
	else
		return RelatedPRI_1.PlayerName@"disarmed"@class<Rx_Weapon_DeployedBeacon>(OptionalObject).default.DeployableName;
}

DefaultProperties
{
}
