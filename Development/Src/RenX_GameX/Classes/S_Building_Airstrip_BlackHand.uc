class S_Building_Airstrip_BlackHand extends Rx_Building_GDI_VehicleFactory
   placeable;

var S_Building_AirTower_Internals_BlackHand AirTowerInternals;

replication
{
	if( bNetInitial && Role == ROLE_Authority )
		AirTowerInternals;
}

function RegsiterTowerInternals(S_Building_AirTower_Internals_BlackHand inAirTower)
{
	AirTowerInternals = inAirTower;
}

simulated function int GetHealth()
{
	return AirTowerInternals.GetHealth();
}

simulated function int GetMaxHealth()
{
	return AirTowerInternals.GetMaxHealth();
}

simulated function int GetArmor() 
{
	return AirTowerInternals.GetArmor();		
}

simulated function int GetMaxArmor() 
{
	return AirTowerInternals.GetMaxArmor();
}

simulated function string GetBuildingName()
{
	return AirTowerInternals.GetBuildingName();
}

simulated function bool IsDestroyed()
{
	return AirTowerInternals.IsDestroyed();
}

event TakeDamage( int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser )
{
	AirTowerInternals.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
}

event bool HealDamage( int Amount, Controller Healer, class<DamageType> DamageType )
{
	return AirTowerInternals.HealDamage(Amount,Healer,DamageType);
}

// Don't trigger Building Alarm if hitting the strip.
simulated function bool IsEffectedByEMP()
{
	return false;
}

simulated function String GetHumanReadableName()
{
	return "Airstrip";
}



defaultproperties
{
	BuildingInternalsClass = S_Building_AirStrip_Internals_BlackHand
	GDIColor    = "#3260FF"
	Begin Object Name=Static_Exterior
		StaticMesh = StaticMesh'S_BU_AirStrip.Mesh.SM_BU_AirStrip'
		Translation = (Z=0)
	End Object

	VehicleSpawnSocket = Veh_DropOff

	bSpawnsC130 = true
}