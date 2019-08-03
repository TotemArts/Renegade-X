interface RxIfc_Airlift; //Interface in use to interact with a support vehicle, like a Chinook, to be dropped somewhere. 

simulated function bool bReadyToLift() ; 

simulated function OnAttachToVehicle(); 

simulated function DetachFromVehicle();