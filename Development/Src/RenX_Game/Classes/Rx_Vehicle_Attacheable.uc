/*********************************************************
*
* File: RxDefence_GunEmplacement.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc: Attachables should have no collision. Keep this in mind, as it also means they should not be so large as to look like they SHOULD have collision. (E.g, don't make freaking 5ft tall turrets)
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/
class Rx_Vehicle_Attacheable extends Rx_Vehicle
	abstract;
	
var Rx_Vehicle		  ParentVehicle; 
var bool			  bEnabled; 

event bool DriverLeave(bool bForceLeave)
{
    local bool ret;
    
    if(ret && Controller != None && Rx_Bot(Controller) != None) {
        Rx_Bot(Controller).LeftVehicle();  
    }
    ret = super(UTVehicle).DriverLeave(bForceLeave);
    return ret;
}

//Turrets, for now, take no damage
simulated event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser);


simulated function bool CanEnterVehicle(Pawn P)
{
	return true; 
}

simulated function SetParentVehicle(Rx_Vehicle Parent)
{
	ParentVehicle = Parent; 
	SetBase(Parent);
	Attach(Parent);
}


DefaultProperties
{
	Health = 100
   bPushedByEncroachers    = false
   bIgnoreEncroachers      = true
   bOrientOnSlope          = true
   bIgnoreRigidBodyPawns   = true  
   bNoEncroachCheck        = true
   bAlwaysEncroachCheck    = false
   bCollideActors=false
   bCollideWorld=false 
    bCollideComplex=false
    bBlockActors=false 
   bProjTarget=true 
	bBindable=false
	
	bHardAttach= true ;
	
	PointsForDestruction = 50.0f
	bCanBePromoted = false 
}
