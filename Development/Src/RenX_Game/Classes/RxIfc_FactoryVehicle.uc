interface RxIfc_FactoryVehicle;

simulated function bool IsDestroyed();

function GetVehicleSpawnPoint(out vector loc, out rotator rot);

function bool SpawnsC130();

simulated function bool CanProduceThisVehicle(class<Rx_Vehicle> Veh);