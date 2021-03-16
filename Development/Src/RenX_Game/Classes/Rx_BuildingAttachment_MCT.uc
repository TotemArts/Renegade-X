class Rx_BuildingAttachment_MCT extends Rx_BuildingAttachment implements (Rx_ObjectTooltipInterface)
    placeable;
    
var StaticMeshComponent MCTSkeletalMesh;
var string tooltip;

simulated function bool ShouldSubstitute()
{
	return false;
}

simulated function string GetTooltip(Rx_Controller PC)
{
	local string temp;

	if (OwnerBuilding != None)
	{
		if (Rx_Building_TechBuilding_Internals(OwnerBuilding) != none)
			return "Use the <font color='#ff0000' size='20'>Repair Gun</font> to capture.";

		if (OwnerBuilding.TeamID != PC.GetTeamNum())
			return "Plant <font color='#ff0000' size='20'>C4</font> on the MCT to destroy the building.";

		if (Rx_Building_Team_Internals(OwnerBuilding) != None)
		{
			if (PC.GetTeamNum() == OwnerBuilding.TeamID && OwnerBuilding.IsDestroyed() && Rx_Building_Team_Internals(OwnerBuilding).GetBuybackCost() > 0 && PC.BuildingReviveCreditAmount <= Rx_PRI(PC.PlayerReplicationInfo).GetCredits())
			{
				temp = Repl(tooltip, "{GBA_USE}", Caps(UDKPlayerInput(PC.PlayerInput).GetUDKBindNameFromCommand("GBA_Use")), true);
				temp = Repl(temp, "$DONATEAMOUNT$", PC.BuildingReviveCreditAmount, true);
				temp = Repl(temp, "$PROGRESS$", OwnerBuilding.BuybackProgress, true);
				return Repl(temp, "$TOTAL$", OwnerBuilding.BuybackCost, true);
			}
			else if (PC.GetTeamNum() == OwnerBuilding.TeamID && OwnerBuilding.IsDestroyed() && Rx_Building_Team_Internals(OwnerBuilding).GetBuybackCost() > 0 && PC.BuildingReviveCreditAmount >= Rx_PRI(PC.PlayerReplicationInfo).GetCredits())
			{
				return "You need<font color='#ff0000' size='20'>" @ int(PC.BuildingReviveCreditAmount - Rx_PRI(PC.PlayerReplicationInfo).GetCredits()) @ "</font>more credits to contribute to restoring.";
			}
			else if (PC.GetTeamNum() == OwnerBuilding.TeamID && OwnerBuilding.IsDestroyed() && Rx_Building_Team_Internals(OwnerBuilding).GetBuybackCost() == -1 && PC.BuildingReviveCreditAmount >= Rx_PRI(PC.PlayerReplicationInfo).GetCredits())
			{
				return "Unable to restore, no Construction Yard.";
			}
		}

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
	return "MCT";
}

//RxIFc_Targetable
simulated function Actor GetActualTarget() {return self;} //Should return 'self' most of the time, save for things that should return something else (like building internals should return the actual building)


defaultproperties
{
	SpawnName     = "_MCT"
	SocketPattern = "MCT"
	tooltip = "Press <font color='#ff0000' size='20'>[ {GBA_USE} ]</font> to donate $DONATEAMOUNT$ credits to restore this building ($PROGRESS$ / $TOTAL$)"

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