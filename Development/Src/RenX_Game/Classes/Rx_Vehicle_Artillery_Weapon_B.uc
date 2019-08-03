/*********************************************************
*
* File: Rx_Vehicle_Artillery_Weapon_B.uc
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
class Rx_Vehicle_Artillery_Weapon_B extends Rx_Vehicle_Artillery_Weapon;

var vector TargetVelocity;
var bool bCanHitTargetVector;


simulated function FireAmmunition()
{
	CalcTargetVelocity();
	super.FireAmmunition();
}

simulated function Projectile ProjectileFire()
{
	local Projectile Proj;

	// Tweak the projectile afterwards
	// Check to see if it's a camera.  If it is, set the view from it
	Proj = Super.ProjectileFire();

	if (bCanHitTargetVector)
	{
		Proj.Velocity = TargetVelocity;
	}
	else
	{
		Proj.Velocity = VSize(TargetVelocity) * Normal(Proj.Velocity);
	}
	
	return Proj;
}

function bool CanAttack(Actor Other)
{
	local vector Start, Extent, RequiredVelocity;
	local class<Rx_Projectile> ProjectileClass;
	local bool bResult;
	local Rx_Bot B;

	ProjectileClass = class<Rx_Projectile>(WeaponProjectiles[0]);
	Extent = ProjectileClass.default.CollisionComponent.Bounds.BoxExtent;
	Start = MyVehicle.GetPhysicalFireStartLoc(self);
	B = Rx_Bot(Instigator.Controller);
	if ( B == None )
	{ 
		B = Rx_Bot(MyVehicle.Controller);
	}

	// Get the Suggested toss velocity
	bResult = SuggestTossVelocity( RequiredVelocity, Other.GetTargetLocation(MyVehicle), Start, ProjectileClass.default.Speed,
					ProjectileClass.default.TossZ, 0.5, Extent, ProjectileClass.default.TerminalVelocity );
	if (bResult)
	{
		if (B != None && B.Focus == Other)
		{
			B.bTargetAlternateLoc = false;
		}
	}
	else if (Other.bHasAlternateTargetLocation)
	{
		bResult = SuggestTossVelocity( RequiredVelocity, Other.GetTargetLocation(MyVehicle, true), Start, ProjectileClass.default.Speed,
						ProjectileClass.default.TossZ, 0.5, Extent, ProjectileClass.default.TerminalVelocity );
		if (bResult && B != None && B.Focus == Other)
		{
			B.bTargetAlternateLoc = true;
		}
	}

	return bResult;
}


simulated event CalcTargetVelocity()
{
	local vector TargetLoc, StartLoc, Extent, Aim, SocketLocation;
	local rotator SocketRotation;
	local class<Rx_Projectile> ProjectileClass;

	ProjectileClass = class<Rx_Projectile>(WeaponProjectiles[0]);
	Extent = ProjectileClass.default.CollisionComponent.Bounds.BoxExtent;

	MyVehicle.GetBarrelLocationAndRotation(SeatIndex, SocketLocation, SocketRotation);
	Aim = vector(SocketRotation);

	TargetLoc = GetDesiredAimPoint();

	StartLoc = MyVehicle.GetPhysicalFireStartLoc(self);

	// Get the Suggested toss velocity
	bCanHitTargetVector = SuggestTossVelocity(TargetVelocity, TargetLoc, StartLoc, ProjectileClass.default.Speed, ProjectileClass.default.TossZ, 1.0, Extent, ProjectileClass.default.TerminalVelocity);

	if ( bCanHitTargetVector )
	{
		bCanHitTargetVector = ( (Aim Dot Normal(TargetVelocity)) > 0.98 );
	}
}

simulated event vector GetPhysFireStartLocation()
{
	return MyVehicle.GetPhysicalFireStartLoc(self);
}

/**
 * IsAimCorrect - Returns true if the turret associated with a given seat is aiming correctly
 *
 * @return TRUE if we can hit where the controller is aiming
 */
simulated event bool IsAimCorrect()
{
	if (WeaponProjectiles.length == 0 || WeaponProjectiles[0] == None || !ClassIsChildOf(WeaponProjectiles[0], class'Rx_Projectile'))
	{
		return Super.IsAimCorrect();
	}
	else
	{
		return (bCanHitTargetVector);
	}
}


DefaultProperties
{
	WeaponProjectiles(0) = Class'Rx_Vehicle_Artillery_Projectile_Arc_B'
	WeaponProjectiles(1) = Class'Rx_Vehicle_Artillery_Projectile_Arc_B'
}
