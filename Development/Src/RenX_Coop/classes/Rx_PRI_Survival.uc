class Rx_PRI_Survival extends Rx_PRI;

var bool bOverrun;

replication
{
	if(bNetDirty)
		bOverrun;
}


simulated function String GetHumanReadableName()
{
	local string ret;
	ret = super(UTPlayerReplicationInfo).GetHumanReadableName();

	if(bOverrun)
	{
		ret = "[--DEAD--]"$ret;
	}
	else if(bBot && !bIsScripted)
	{
		ret = "[B-"$BotSkill$"]"$ret;
	}
	else if(bIsSpectator)
		ret = "[Spec]"$ret;
	else
	{
		if (left(ret,3) == "[B-")
			ret = Split(ret,"[B-",true);

		if (left(ret,5) == "[AFK]")
			ret = Split(ret,"[AFK]",true);

		if (bIsAFK)
			ret = "[AFK]"$ret;
	}

	return ret;
}