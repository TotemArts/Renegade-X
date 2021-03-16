class Rx_PassiveAbility_SprintPassiveBoost extends Rx_PassiveAbility;

var float SprintMultiplier;

// Ability was added to a pawn
simulated function Init(Pawn InitiatingPawn, byte SlotNum)
{
	super.Init(InitiatingPawn, SlotNum);

	Rx_Pawn(InitiatingPawn).SprintSpeed *= SprintMultiplier;
}

simulated function RemoveUser()
{
	Rx_Pawn(UsingPawn).SprintSpeed = Rx_Pawn(UsingPawn).default.SprintSpeed;

	super.RemoveUser();
}

DefaultProperties
{
	SprintMultiplier=1.20//1.5
}