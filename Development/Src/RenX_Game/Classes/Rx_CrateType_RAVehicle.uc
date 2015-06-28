class Rx_CrateType_RAVehicle extends Rx_CrateType;

var transient Rx_Vehicle GivenVehicle;
var config float ProbabilityIncreaseWhenVehicleProductionDestroyed;
var array<class<Rx_Vehicle> > Vehicles;

function string GetPickupMessage()
{
	return Repl(PickupMessage, "`vehname`", GivenVehicle.GetHumanReadableName(), false);
}

function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	return "GAME" `s "Crate;" `s "ravehicle" `s GivenVehicle.class.name `s "by" `s `PlayerLog(RecipientPRI);
}

function float GetProbabilityWeight(Rx_Pawn Recipient, Rx_CratePickup CratePickup)
{			
	local Rx_Building building;
	local float Probability;

	if (CratePickup.bNoVehicleSpawn || Vehicles.Length == 0)
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
	local Vector tmpSpawnPoint;

	tmpSpawnPoint = CratePickup.Location + vector(CratePickup.Rotation)*450;
	tmpSpawnPoint.Z += 200;

	GivenVehicle = CratePickup.Spawn(Vehicles[Rand(Vehicles.Length)],,, tmpSpawnPoint, CratePickup.Rotation,,true);

	GivenVehicle.DropToGround();
	if (GivenVehicle.Mesh != none)
		GivenVehicle.Mesh.WakeRigidBody();
}

DefaultProperties
{
	BroadcastMessageIndex = 15 
	PickupSound = SoundCue'Rx_Pickups.Sounds.SC_Crate_VehicleDrop'

	Vehicles.Add(class'APB_Vehicle_TeslaTank');
}
