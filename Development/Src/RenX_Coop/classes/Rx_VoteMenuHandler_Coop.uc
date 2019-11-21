class Rx_VoteMenuHandler_Coop extends Rx_VoteMenuHandler;

DefaultProperties
{
	VoteChoiceClasses.Empty

	VoteChoiceClasses(0) = class'Rx_VoteMenuChoice_RestartMap'
	VoteChoiceClasses(1) = class'Rx_VoteMenuChoice_ChangeMap'
	VoteChoiceClasses(2) = class'Rx_VoteMenuChoice_AddBots_Coop'
	VoteChoiceClasses(3) = class'Rx_VoteMenuChoice_RemoveBots_Coop'
	VoteChoiceClasses(4) = class'Rx_VoteMenuChoice_Kick'
	VoteChoiceClasses(5) = class'Rx_VoteMenuChoice_Survey'
	VoteChoiceClasses(6) = class'Rx_VoteMenuChoice_MineBan'
	VoteChoiceClasses(7) = class'Rx_VoteMenuChoice_Commander'
}