class Rx_Building_Airstrip extends Rx_Building_Nod_VehicleFactory
   placeable;

var Rx_Building_AirTower_Internals AirTowerInternals;

replication
{
	if( bNetInitial && Role == ROLE_Authority )
		AirTowerInternals;
}

function CheckObjective()
{
}

function RegsiterTowerInternals(Rx_Building_AirTower_Internals inAirTower)
{
	AirTowerInternals = inAirTower;
}

simulated function Rx_BuildingAttachment GetMCT()
{

	local int i;
	local Rx_BuildingAttachment Attachment;
	
	if(MCT != None)
		return MCT;
	else if(AirTowerInternals != None)
	{
		for (i = 0; i < AirTowerInternals.BuildingAttachments.length; i++)
		{
			Attachment=AirTowerInternals.BuildingAttachments[i];
			
			if(Attachment.IsA('Rx_BuildingAttachment_MCT'))
			{
				MCT = Attachment;
				return Attachment;	//found it, abandon everything else
			}
		}
	}

	return none;
	
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

simulated function Rx_BuildingObjective GetObjective()
{
	return AirTowerInternals.BuildingVisuals.myObjective;
}

defaultproperties
{
	BuildingInternalsClass  = Rx_Building_AirStrip_Internals 

	Begin Object Name=Static_Exterior
		StaticMesh = StaticMesh'RX_BU_AirStrip.Mesh.SM_BU_AirStrip'
		Translation = (Z=0)
	End Object

	SpawnsC130 = true
}