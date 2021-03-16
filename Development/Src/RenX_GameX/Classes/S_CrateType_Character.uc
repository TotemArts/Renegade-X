class S_CrateType_Character extends Rx_CrateType_Character;

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	RecipientPRI.SetChar(
		(Recipient.GetTeamNum() == TEAM_GDI ?
		class'S_PurchaseSystem'.default.GDIInfantryClasses[RandRange(5,class'S_PurchaseSystem'.default.GDIInfantryClasses.Length-1)] : 
		class'S_PurchaseSystem'.default.NodInfantryClasses[RandRange(5,class'S_PurchaseSystem'.default.NodInfantryClasses.Length-1)]),
		Recipient);
}
