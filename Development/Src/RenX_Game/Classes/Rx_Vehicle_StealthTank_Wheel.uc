class Rx_Vehicle_StealthTank_Wheel extends UDKVehicleWheel;

defaultproperties
{
    WheelRadius=34
    SuspensionTravel=30
    SuspensionSpeed=50
    bPoweredWheel=True
    BoneOffset=(X=0.0,Y=0.0,Z=0.0)
    SteerFactor=1.1
//    LongSlipFactor=250
//    LatSlipFactor=20000.0
//    HandbrakeLongSlipFactor=250.0
//    HandbrakeLatSlipFactor=1000.0
//    ParkedSlipFactor=10

    LongSlipFactor=15.0
    LatSlipFactor=60.0
    HandbrakeLongSlipFactor=15.0
    HandbrakeLatSlipFactor=60.0
    ParkedSlipFactor=10.0

    bUseMaterialSpecificEffects=false
    EffectDesiredSpinDir=1.0
}