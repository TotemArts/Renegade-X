class Rx_SupportVehicle_MIG35_SpyPlane extends Rx_SupportVehicle_MIG35; 

DefaultProperties
{
	 /**************************************/
	 
	 /*****Pawn Characteristics*******/
		AirSpeed=+15000.0
		GroundSpeed=+15000.0
		AccelRate = +1050.0 
		
		bForceMaxAccel = false 
		
		bSimulateGravity = false; 
		bSimGravityDisabled = true
		
		Mass =+5000.00; //Try not to get too knocked around by SAMs
	/***********************/	

	   Begin Object Name=VehicleAudioComponent
        SoundCue=SoundCue'RX_VH_Mig35.Sounds.SC_Mig35_FlyOver_Fast'
    End Object

}