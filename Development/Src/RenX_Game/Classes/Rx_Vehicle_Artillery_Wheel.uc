class Rx_Vehicle_Artillery_Wheel extends UDKVehicleWheel;

defaultproperties
{
    WheelRadius=40
    SuspensionTravel=100
    SuspensionSpeed=100
    bPoweredWheel=True
    BoneOffset=(X=0.0,Y=0.0,Z=0.0)
    SteerFactor=0.0
    
//    LongSlipFactor=2.0
//    LatSlipFactor=2.75
//    HandbrakeLongSlipFactor=1.0
//    HandbrakeLatSlipFactor=1.0
//    ParkedSlipFactor=10.0
    
    LongSlipFactor=15.0
    LatSlipFactor=0.5
    HandbrakeLongSlipFactor=15.0
    HandbrakeLatSlipFactor=0.5
    ParkedSlipFactor=10.0
    
    bUseMaterialSpecificEffects=false
    EffectDesiredSpinDir=1.0
}