/*********************************************************
*
* File: Rx_Vehicle_Air_Jet.uc
* Author: RenegadeX-Team
* Project: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/


/** base class for vehicles that fly or hover */
class Rx_Vehicle_Air_Jet extends Rx_Vehicle
    abstract;
    

var float ForwardSpeed;
const MPHConversionFactor = 0.042612;   // speed conversion
var int MPH;

var bool bAutoLand;
var float PushForce;    // for AI when landing;

var localized string RadarLockMessage;                /** Displayed when enemy raptor fires locked missile at you */

var float LastRadarLockWarnTime;

/**
 * Console specific input modification
 */
simulated function SetInputs(float InForward, float InStrafe, float InUp)
{
    local bool bReverseThrottle;
    local UTConsolePlayerController ConsolePC;
    local rotator SteerRot, VehicleRot;
    local vector SteerDir, VehicleDir; // , AngVel
    local float VehicleHeading, SteerHeading, DeltaTargetHeading, Deflection, PPitch;

    Steering = InStrafe;

    if (InForward > 0)
    {
       if (Throttle > 1)
       {
          Throttle = 1;
       }
       else
       {
          Throttle += 0.05;
       }
    }

    if (InForward < 0)
    {
      if (Throttle < 0)
       {
        Throttle = 0;
       }
       else
       {
         Throttle -= 0.05;
       }
    }


     if (ForwardVel < 100)
      {
        //drop if not enough speed
        Rise = -0.2;
      }
      else if (ForwardVel > 100)
      {
      PPitch = 0.0000001*(Rotation.Pitch - Worldinfo.Rotation.Pitch);
      //UDKVehicleSimChopper(SimObj).MaxRiseForce = Rotation.Pitch - Worldinfo.Rotation.Pitch;
         if (PPitch >0.01)
         {Rise = FMax(PPitch, 1.0);}
         else if (PPitch <-0.01)
         {Rise = FMin(PPitch, -1.0);}
         else
         {Rise = 0;}

      }
     ///

    ConsolePC = UTConsolePlayerController(Controller);
    if (ConsolePC != None)
    {
        Steering = FClamp(Steering * ConsoleSteerScale, -1.0, 1.0);

        UpdateLookSteerStatus();

        // tank, wheeled / heavy vehicles will use this

        // If we desire 'look steering' on this vehicle, do it here.
        //if (bUsingLookSteer && IsHumanControlled())
        //{
            // If there is a deflection, look at the angle that its point in.
            Deflection = Sqrt(Throttle*Throttle + Steering*Steering);

            if(bStickDeflectionThrottle)
            {
                // The region we consider 'reverse' is anything below DeflectionReverseThresh, or anything withing the triangle below the center position.
                bReverseThrottle = ((Throttle < DeflectionReverseThresh) || (Throttle < 0.0 && Abs(Steering) < -Throttle));
                Throttle = Deflection;

                if (bReverseThrottle)
                {
                    Throttle *= -1;
                }
            }

            VehicleRot.Yaw = Rotation.Yaw;
            VehicleDir = vector(VehicleRot);

            SteerRot.Yaw = DriverViewYaw;
            SteerRot.Pitch = DriverViewPitch;
            SteerDir = vector(SteerRot);

            VehicleHeading = GetHeadingAngle(VehicleDir);
            SteerHeading = GetHeadingAngle(SteerDir);
            DeltaTargetHeading = FindDeltaAngle(SteerHeading, VehicleHeading);

            if (DeltaTargetHeading > LookSteerDeadZone)
            {
                Steering = FMin((DeltaTargetHeading - LookSteerDeadZone) * LookSteerSensitivity, 1.0);
                Rise = FMin((DeltaTargetHeading - LookSteerDeadZone) * LookSteerSensitivity, 1.0);
            }
            else if (DeltaTargetHeading < -LookSteerDeadZone)
            {
                Steering = FMax((DeltaTargetHeading + LookSteerDeadZone) * LookSteerSensitivity, -1.0);
                    Rise = FMax((DeltaTargetHeading + LookSteerDeadZone) * LookSteerSensitivity, -1.0);
                        }
            else
            {
                Steering = 0.0;
            }

        // Reverse steering when reversing
            if (Throttle < 0.0 && ForwardVel < 0.0)
            {
                Steering = -1.0 * Steering;
            }
        //`log( "Throttle: " $ Throttle $ " Steering: " $ Steering );
    }
}


simulated function SetDriving(bool bNewDriving)
{
    if (bAutoLand && !bNewDriving && !bChassisTouchingGround && Health > 0)
    {
        if (Role == ROLE_Authority)
        {
            GotoState('AutoLanding');
        }
    }
    else
    {
        Super.SetDriving(bNewDriving);
    }
}

/** state to automatically land when player jumps out while high above land */
state AutoLanding
{
    simulated function SetDriving(bool bNewDriving)
    {
        if ( bNewDriving )
        {
            GotoState('Auto');
            Global.SetDriving(bNewDriving);
        }
    }

    function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
    {
        if (Global.Died(Killer, DamageType, HitLocation))
        {
            SetDriving(false);
            return true;
        }
        else
        {
            return false;
        }
    }

    function Tick(float DeltaTime)
    {
        local actor HitActor;
        local vector HitNormal, HitLocation;

        //speed
// calculate speed
        ForwardSpeed = (Velocity << Rotation).X;
        MPH = ForwardSpeed * MPHConversionFactor;
    if (MPH <= 0)
        {
          MPH -=MPH;
        }

        if (bChassisTouchingGround)
        {
            GotoState('Auto');
            SetDriving(false);
        }
        else
        {
            HitActor = Trace(HitLocation, HitNormal, Location - vect(0,0,2500), Location, false);
            if ( Velocity.Z < -1200 )
                OutputRise = 1.0;
            else if ( HitActor == None )
                OutputRise = -1.0;
            else if ( VSize(HitLocation - Location) < -2*Velocity.Z )
            {
                if ( Velocity.Z > -100 )
                    OutputRise = 0;
                else
                    OutputRise = 1.0;
            }
            else if ( Velocity.Z > -500 )
                OutputRise = -0.4;
            else
                OutputRise = -0.1;
        }
    }
}

defaultproperties
{

    Begin Object Class=UDKVehicleSimChopper Name=SimObject
        MaxThrustForce=700.0
        MaxReverseForce=0.0
        LongDamping=0.1
        MaxStrafeForce=0.0
        LatDamping=0.7
        MaxRiseForce=1000.0
        UpDamping=0.0
        TurnTorqueFactor=7000.0
        TurnTorqueMax=10000.0
        TurnDamping=1.2
        MaxYawRate=1.8
        PitchTorqueFactor=1000.0
        PitchTorqueMax=2000.0
        PitchDamping=0.3
        RollTorqueTurnFactor=8000.0
        RollTorqueStrafeFactor=100.0
        RollTorqueMax=3000.0
        RollDamping=0.1
        MaxRandForce=00.0
        RandForceInterval=1.5
        StopThreshold=100
        bShouldCutThrustMaxOnImpact=true
        PitchViewCorrelation=9999.0
        bAllowZThrust=True
    End Object
    SimObj=SimObject
    Components.Add(SimObject)
	
	DestroyedRotatorAddend = (Pitch=0,Roll=50000,Yaw=0)

    bAutoLand=true
    ContrailColorParameterName=ContrailColor
    bNoZDampingInAir=false

    bReducedFallingCollisionDamage=true

    bCanStrafe=true
    bCanFly=true
    bTurnInPlace=false
    bFollowLookDir=true
    bDriverHoldsFlag=false
    bCanCarryFlag=false
	
	bHomingTarget=True

    LookForwardDist=100.0
    
    CustomGravityScaling=0.35

    CollisionDamageMult=0.003

    IconCoords=(U=989,V=24,UL=43,VL=48)

    bEjectPassengersWhenFlipped=false
    bMustBeUpright=false
    UpsideDownDamagePerSec=0.0

    bDropDetailWhenDriving=true
    bFindGroundExit=false

    //@todo: it would be nice if the alternate path code would count being in a VolumePathNode above the intended alternate path
    bUseAlternatePaths=false

    bJostleWhileDriving=true
    bFloatWhenDriven=true
	
	BurnOutTime=1.5
	DeadVehicleLifeSpan=2.0
	SecondaryExplosion=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle'

    bisAircraft=true
}
