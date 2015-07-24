class Rx_Building_Airstrip extends Rx_Building
   placeable;

var Rx_Building_AirTower_Internals AirTowerInternals;

simulated function PostBeginPlay()
{
    local Vector loc;
    local Rotator rot;	
	super.PostBeginPlay();
	if(WorldInfo.Netmode != NM_Client) {
		BuildingInternals.BuildingSkeleton.GetSocketWorldLocationAndRotation('Veh_DropOff', loc, rot);
		Rx_Game(WorldInfo.Game).GetVehicleManager().Set_NOD_ProductionPlace(loc, rot);
	}
}

replication
{
	if( bNetInitial && Role == ROLE_Authority )
		AirTowerInternals;
}

function RegsiterTowerInternals(Rx_Building_AirTower_Internals inAirTower)
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
	BuildingInternalsClass  = Rx_Building_AirStrip_Internals 
	TeamID                  = TEAM_NOD

	Begin Object Name=Static_Exterior
		StaticMesh = StaticMesh'RX_BU_AirStrip.Mesh.SM_BU_AirStrip'
		Translation = (Z=0)
	End Object

	
}