class Rx_BuildingAttachment_MCT extends Rx_BuildingAttachment implements (Rx_ObjectTooltipInterface)
    placeable;
    
var StaticMeshComponent MCTSkeletalMesh;

simulated function string GetTooltip(Rx_Controller PC)
{
	if (OwnerBuilding != None)
	{
		if (Rx_Building_TechBuilding_Internals(OwnerBuilding) != none)
			return "Use the <font color='#ff0000' size='20'>Repair Gun</font> to capture.";

		if (OwnerBuilding.TeamID != PC.GetTeamNum())
			return "Plant <font color='#ff0000' size='20'>C4</font> on the MCT to destroy the building.";

		//return "Use the <font color='#ff0000' size='20'>Repair Gun</font> to repair.";
	}
	return "";
}

simulated function bool IsTouchingOnly()
{
	return false;
}

simulated function bool IsBasicOnly()
{
	return true;
}

simulated event byte ScriptGetTeamNum()
{
   if ( OwnerBuilding != none )
      return OwnerBuilding.GetTeamNum();
   else
      return 100;
}

function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser) 
{
	/*BUILDINGFIXME*/
	/*if (class<RenDmgType_Timed>(DamageType) != none)
	{
		OwnerBuilding.TakeDamage(1600, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	}
	else if(class<RenDmgType_Remote>(DamageType) != none)
	{
		OwnerBuilding.TakeDamage(800, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	}
	else*/
	if( OwnerBuilding != None )
	{
		OwnerBuilding.TakeDamage(DamageAmount * class<Rx_DmgType>(DamageType).static.MCTDamageScalingFor(), EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	}
}

function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType) 
{
   return OwnerBuilding.HealDamage(Amount * 2, Healer, DamageType);
}

simulated function string GetHumanReadableName()
{
	return "Master Control Terminal";
}

defaultproperties
{
	SpawnName     = "_MCT"
	SocketPattern = "MCT"

	Begin Object Class=StaticMeshComponent Name=MCTMeshCmp
		StaticMesh                   = StaticMesh'rx_deco_terminal.Mesh.SM_BU_MCT'
		CollideActors                = True
		BlockActors                  = True
		BlockRigidBody               = True
		BlockZeroExtent              = True
		BlockNonZeroExtent           = True
		bCastDynamicShadow           = True
		bAcceptsDynamicLights        = True
		bAcceptsLights               = True
		bAcceptsDecalsDuringGameplay = True
		bAcceptsDecals               = True
		RBChannel                    = RBCC_Pawn
		RBCollideWithChannels        = (Pawn=True)
	End Object
	Components.Add(MCTMeshCmp)
	MCTSkeletalMesh     = MCTMeshCmp

	RemoteRole          = ROLE_SimulatedProxy
	bCollideActors      = True
	bBlockActors        = True
	BlockRigidBody      = True
	bCollideComplex     = true
	bWorldGeometry = true
}