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
			if((Recipient.GetTeamNum() == TEAM_GDI && Rx_Building_GDI_VehicleFactory(building) != none  && Rx_Building_GDI_VehicleFactory(building).IsDestroyed()) || 
				(Recipient.GetTeamNum() == TEAM_NOD && Rx_Building_Nod_VehicleFactory(building) != none  && Rx_Building_Nod_VehicleFactory(building).IsDestroyed()))
			{
				Probability += ProbabilityIncreaseWhenVehicleProductionDestroyed;
			}
		}

		return Probability;
	}
}

function array<class<Rx_Vehicle> > GetCrateVehicles() {
	local array<class<Rx_Vehicle> > result;
	local Rx_PurchaseSystem purchaseSystem;
	local bool includeAircraft;
	local class<Rx_Vehicle_PTInfo> vehicleInfo;

	purchaseSystem = `RxGameObject.PurchaseSystem;
	includeAircraft = !Rx_MapInfo(`WorldInfoObject.GetMapInfo()).bAircraftDisabled;

	// Add GDI vehicles
	foreach purchaseSystem.GDIVehicleClasses(vehicleInfo) {
		if (includeAircraft || !vehicleInfo.default.bAircraft) {
			result.AddItem(vehicleInfo.default.VehicleClass);
		}
	}

	// Add Nod vehicles
	foreach purchaseSystem.NodVehicleClasses(vehicleInfo) {
		if (includeAircraft || !vehicleInfo.default.bAircraft) {
			result.AddItem(vehicleInfo.default.VehicleClass);
		}
	}

	return result;
}

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	local Vector spawnPoint;
	local array<class<Rx_Vehicle> > vehicleClasses;
	local class<Rx_Vehicle> vehicleClass;

	// Setup spawn point
	spawnPoint = CratePickup.Location + vector(CratePickup.Rotation)*450;
	spawnPoint.Z += 200;

	// Pull a random vehicle class
	vehicleClasses = GetCrateVehicles();
	vehicleClass = vehicleClasses[Rand(vehicleClasses.Length)];

    // Spawn the vehicle
	GivenVehicle = CratePickup.Spawn(vehicleClass,,, spawnPoint, CratePickup.Rotation,,true);
	GivenVehicle.DropToGround();
	if (GivenVehicle.Mesh != none)
		GivenVehicle.Mesh.WakeRigidBody();

	RecipientPRI.SetVehicleIsFromCrate (true);
}

DefaultProperties
{
	BroadcastMessageIndex = 6
	PickupSound = SoundCue'Rx_Pickups.Sounds.SC_Crate_VehicleDrop'
}
