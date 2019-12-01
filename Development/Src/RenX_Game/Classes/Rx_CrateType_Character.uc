class Rx_CrateType_Character extends Rx_CrateType;

var config float ProbabilityIncreaseWhenInfantryProductionDestroyed;

function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	return "GAME" `s "Crate;" `s "character" `s RecipientPRI.CharClassInfo.name `s "by" `s `PlayerLog(RecipientPRI);
}

function float GetProbabilityWeight(Rx_Pawn Recipient, Rx_CratePickup CratePickup)
{
	local Rx_Building building;
	local float Probability;
	Probability = Super.GetProbabilityWeight(Recipient,CratePickup);

	if (!HasFreeUnit(Recipient)) // Don't swap character if we have paid for a unit
		return 0;

	ForEach CratePickup.AllActors(class'Rx_Building',building)
	{
		if((Recipient.GetTeamNum() == TEAM_GDI && Rx_Building_GDI_InfantryFactory(building) != none  && !Rx_Building_GDI_InfantryFactory(building).IsDestroyed()) || 
			(Recipient.GetTeamNum() == TEAM_NOD && Rx_Building_Nod_InfantryFactory(building) != none  && !Rx_Building_Nod_InfantryFactory(building).IsDestroyed()))
		{
			return Probability;
		}
	}
	Probability += ProbabilityIncreaseWhenInfantryProductionDestroyed;

	return Probability;
}

function bool HasFreeUnit(Rx_Pawn Recipient)
{
	/*
	if(Recipient.GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Soldier')
		return true;
	if(Recipient.GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Shotgunner')
		return true;
	if(Recipient.GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Grenadier')
		return true;
	if(Recipient.GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Marksman')
		return true;
	if(Recipient.GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Engineer')
		return true;
		
	if(Recipient.GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Soldier')
	 	return true;
	if(Recipient.GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Shotgunner')
		return true;
	if(Recipient.GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_FlameTrooper')
		return true;
	if(Recipient.GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Marksman')
		return true;
	if(Recipient.GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Engineer')
		return true;		
		
	return false;	
	*/
	// as Sarah pointed out, the method above is completely and utterly flawed. Seriously, who wrote this? :/

	return (Recipient.GetRxFamilyInfo().static.Cost(Rx_PRI(Recipient.PlayerReplicationInfo)) <= 0);
}

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	RecipientPRI.SetChar(
		(Recipient.GetTeamNum() == TEAM_GDI ?
		class'Rx_PurchaseSystem'.default.GDIInfantryClasses[RandRange(5,class'Rx_PurchaseSystem'.default.GDIInfantryClasses.Length-1)] : 
		class'Rx_PurchaseSystem'.default.NodInfantryClasses[RandRange(5,class'Rx_PurchaseSystem'.default.NodInfantryClasses.Length-1)]),
		Recipient);
}

DefaultProperties
{
	BroadcastMessageIndex = 5
	PickupSound = SoundCue'Rx_Pickups.Sounds.SC_Crate_CharacterChange'
}
