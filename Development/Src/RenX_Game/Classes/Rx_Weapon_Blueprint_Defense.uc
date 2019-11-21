class Rx_Weapon_Blueprint_Defense extends Rx_Weapon_Blueprint;

var class<Rx_Defence> DefenseClass;

reliable server function DeployBlueprint(vector DeployLoc, rotator DeployRot)
{
	local Rx_Defence SpawnedDefense;

	SpawnedDefense = Spawn(DefenseClass,,,DeployLoc,DeployRot);
	if(SpawnedDefense == None)
		return;

	SpawnedDefense.Deployer = Rx_PRI(Instigator.PlayerReplicationInfo);

	Super.DeployBlueprint(DeployLoc, DeployRot);
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