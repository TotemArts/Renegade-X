class Rx_CrateType_Vehicle extends Rx_CrateType;

var transient Rx_Vehicle GivenVehicle;
var config float ProbabilityIncreaseWhenVehicleProductionDestroyed;

function string GetPickupMessage()
{
	return Repl(PickupMessage, "`vehname`", GivenVehicle.GetHumanReadableName(), false);
}

function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	return "GAME" `s "Crate;" `s "vehicle" `s GivenVehicle.class.name `s "by" `s `PlayerLog(RecipientPRI);
}

function float GetProbabilityWeight(Rx_Pawn Recipient, Rx_CratePickup CratePickup)
{			
	local Rx_Building building;
	local float Probability;

	if (CratePickup.bNoVehicleSpawn)
		return 0;
	else
	{
		Probability = Super.GetProbabilityWeight(Recipient,CratePickup);

		ForEach CratePickup.AllActors(class'Rx_Building',building)
		{
			if((Recipient.GetTeamNum() == TEAM_GDI && Rx_Building_WeaponsFactory(building) != none  && Rx_Building_WeaponsFactory(building).IsDestroyed()) || 
				(Recipient.GetTeamNum() == TEAM_NOD && Rx_Building_AirStrip(building) != none  && Rx_Building_AirStrip(building).IsDestroyed()))
			{
				Probability += ProbabilityIncreaseWhenVehicleProductionDestroyed;
			}
		}

		return Probability;
	}
}

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	local int tmpInt, tmpInt2;
	local Vector tmpSpawnPoint;

	tmpSpawnPoint = CratePickup.Location + vector(CratePickup.Rotation)*450;
	tmpSpawnPoint.Z += 200;
	tmpInt = Rand(2);

	// If not flying map, make sure no flying vehicles are given
	// TODO: Actually verify flying vehicles, if flying vehicles aren't the last two in the list, this will break.
	if (Rx_MapInfo(CratePickup.WorldInfo.GetMapInfo()).bAircraftDisabled)
		tmpInt2 = (tmpInt == TEAM_GDI ? Rand(class'Rx_PurchaseSystem'.default.GDIVehicleClasses.Length - 2) : Rand(class'Rx_PurchaseSystem'.default.NodVehicleClasses.Length - 2));
	else
		tmpInt2 = (tmpInt == TEAM_GDI ? Rand(class'Rx_PurchaseSystem'.default.GDIVehicleClasses.Length) : Rand(class'Rx_PurchaseSystem'.default.NodVehicleClasses.Length));
         
	GivenVehicle = CratePickup.Spawn((tmpInt == TEAM_GDI ?
		class'Rx_PurchaseSystem'.default.GDIVehicleClasses[tmpInt2] : 
		class'Rx_PurchaseSystem'.default.NodVehicleClasses[tmpInt2]),,, tmpSpawnPoint, CratePickup.Rotation,,true);

	GivenVehicle.DropToGround();
	if (GivenVehicle.Mesh != none)
		GivenVehicle.Mesh.WakeRigidBody();
}

DefaultProperties
{
	BroadcastMessageIndex = 6
	PickupSound = SoundCue'Rx_Pickups.Sounds.SC_Crate_VehicleDrop'
}
