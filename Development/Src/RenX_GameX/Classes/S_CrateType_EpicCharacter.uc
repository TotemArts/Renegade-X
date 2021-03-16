class S_CrateType_EpicCharacter extends Rx_CrateType_EpicCharacter;

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	RecipientPRI.SetChar(
		(Recipient.GetTeamNum() == TEAM_GDI ?
		class'Rx_FamilyInfo_Nod_Raveshaw_Mutant' : 
		class'Rx_FamilyInfo_Nod_Raveshaw_Mutant'),
		Recipient);
}


