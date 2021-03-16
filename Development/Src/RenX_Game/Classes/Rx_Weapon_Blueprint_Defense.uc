class Rx_Weapon_Blueprint_Defense extends Rx_Weapon_Blueprint;

var class<Rx_Defence> DefenseClass;

reliable server function DeployBlueprint(vector DeployLoc, rotator DeployRot)
{
	local Rx_Defence SpawnedDefense;

	SpawnedDefense = Spawn(DefenseClass,,,DeployLoc,DeployRot);
	if(SpawnedDefense == None)
		return;

	SpawnedDefense.Deployer = Rx_PRI(Instigator.PlayerReplicationInfo);
	SpawnedDefense.bOwnedDefence = true;
	Rx_PRI(Instigator.PlayerReplicationInfo).DeployedDefenses.AddItem(SpawnedDefense);
	Rx_PRI(Instigator.PlayerReplicationInfo).DeployedDefenseNumber += 1;
	Super.DeployBlueprint(DeployLoc, DeployRot);
}


simulated function string GetWeaponTips()
{
	local int CurDef, MaxDef;
	local Rx_PRI RxPRI;
	local string TempString;

	RxPRI = Rx_PRI(Pawn(Owner).PlayerReplicationInfo);

	if(RxPRI == None)
		return "";

	MaxDef = RxPRI.DeployedDefenseLimit;
	CurDef = RxPRI.DeployedDefenseNumber;

	TempString = "DEFENSES COUNT: "$CurDef$"/"$MaxDef;

	return TempString;
}

simulated function LinearColor GetTipsColor()
{
	local int CurDef, MaxDef;
	local Rx_PRI RxPRI;

	RxPRI = Rx_PRI(Pawn(Owner).PlayerReplicationInfo);

	if(RxPRI == None)
		return MakeLinearColor(0.0,1.0,0.0,1.0);

	MaxDef = RxPRI.DeployedDefenseLimit;
	CurDef = RxPRI.DeployedDefenseNumber;

	if(MaxDef <= CurDef)
	{
		return MakeLinearColor(1.0,0.0,0.0,1.0);
	}

	return MakeLinearColor(0.0,1.0,0.0,1.0);
}

simulated function string GetWeaponSecondaryTips()
{
	local int CurDef, MaxDef;
	local Rx_PRI RxPRI;

	RxPRI = Rx_PRI(Pawn(Owner).PlayerReplicationInfo);

	if(RxPRI == None)
		return "";

	MaxDef = RxPRI.DeployedDefenseLimit;
	CurDef = RxPRI.DeployedDefenseNumber;

	if(MaxDef <= CurDef)
		return ">>>>LIMIT REACHED<<<<";

	return "";
}

simulated function LinearColor GetSecondTipsColor()
{
	return MakeLinearColor(1.0,0.0,0.0,1.0);
}

// iterator is needed sadly, because I can't for the life of me figure out how to use Dynamic Array for this
simulated function bool TooManyDefenses() 
{
	local Rx_Defence Def;
	local int i;

	foreach WorldInfo.AllPawns(class'Rx_Defence',Def)
	{
		if(Def.Deployer == Rx_PRI(Instigator.PlayerReplicationInfo))
			i++;

		if(i >= 4)
			return true;
	}

	return false;
}

simulated function Vector GetBlueprintModelLocation()
{
	return BuildLoc;
}

DefaultProperties
{
	BuildClearRadius = 300
	Price = 450
	PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_Sentry_MG'
}