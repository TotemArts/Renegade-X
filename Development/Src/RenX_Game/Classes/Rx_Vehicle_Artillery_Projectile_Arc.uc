/*********************************************************
*
* File: Rx_Vehicle_Artillery_Projectile_Arc.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/
class Rx_Vehicle_Artillery_Projectile_Arc extends Rx_Vehicle_Artillery_Projectile;

// Note: TossZ lerps between min and max values, ad distance goes from min to max.
var float MinTossZ; // Minimum TossZ value to use
var float MinTossZDistance; // Distance at which to use Min TossZ
var float MaxTossZ; // Maximum Toss Z value to use
var float MaxTossZDistance; // Distance at which to use Max TossZ

function CalcTossZ (vector Direction)
{
	local Vector TraceHit;
	local Vector TraceNormal;
	local float Distance;
	
	if (Trace(TraceHit,TraceNormal,Location + (Direction * MaxTossZDistance)) != none)
	{
		Distance = VSize(self.Location - TraceHit);
		TossZ = Lerp(MinTossZ,MaxTossZ, FClamp((Distance - MinTossZDistance) / (MaxTossZDistance - MinTossZDistance),0,1));
	}
	else
	{
		TossZ = MaxTossZ;
	}
}


event Tick( float DeltaTime )
{
    SetRotation(Rotator(Velocity));
}

function Init(vector Direction)
{
	CalcTossZ(Direction);

    Velocity = Speed * Direction;
    //TossZ = TossZ + (FRand() * TossZ / 2.0) - (TossZ / 4.0);
    Velocity.Z += TossZ;
    Acceleration = AccelRate * Normal(Velocity);
    //ProjEffects.SetRotation(Rotator(Direction));
    //SetRotation(Rotator(Direction));
}

DefaultProperties
{
	MinTossZ = 0
	MinTossZDistance = 256
	MaxTossZ = 300
	MaxTossZDistance = 4096
    TossZ=300


    //TossZ=0
    CustomGravityScaling=0.5
    bRotationFollowsVelocity=true
    Physics=PHYS_Falling

    Speed=5000
    MaxSpeed=5000
    TerminalVelocity=5000.0
    LifeSpan=2.4
	
}
