class Rx_Vehicle_LightTank_Wheel extends UDKVehicleWheel;

defaultproperties
{
    WheelRadius=12
    SuspensionTravel=45
    SuspensionSpeed=100
    bPoweredWheel=True
    BoneOffset=(X=0.0,Y=0.0,Z=0.0)
    SteerFactor=1.0
//    LongSlipFactor=250
//    LatSlipFactor=20000.0
//    HandbrakeLongSlipFactor=250.0
//    HandbrakeLatSlipFactor=1000.0
//    ParkedSlipFactor=10

    LongSlipFactor=2.0
    LatSlipFactor=60.0
    HandbrakeLongSlipFactor=1.0
    HandbrakeLatSlipFactor=60.0
    ParkedSlipFactor=10.0

    bUseMaterialSpecificEffects=false
    EffectDesiredSpinDir=1.0
}