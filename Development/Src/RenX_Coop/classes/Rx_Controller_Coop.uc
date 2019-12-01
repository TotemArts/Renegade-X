class Rx_Controller_Coop extends Rx_Controller;

simulated function Array<Rx_CoopObjective> GetCoopObjectives()
{
	local array<Rx_CoopObjective> COList;
	local Rx_CoopObjective CO;


	foreach WorldInfo.AllActors(class'Rx_CoopObjective', CO)
	{
			COList.AddItem(CO);
	}

	return COList;
}

function bool ValidPTUse(Rx_BuildingAttachment_PT PT)	// we don't always have PT inside buildings, so validate if this PT is not owned by any buildings
{
	if ((PT.OwnerBuilding == None || IsInBuilding() == PT.OwnerBuilding.BuildingVisuals) && PT.GetTeamNum() == GetTeamNum())
		return true;
	else
		return false;
}

function EnableCommanderMenu()
{
	
	if(VoteHandler != none || Rx_GRI(WorldInfo.GRI).bEnableCommanders == false) return; 
	
	if(Com_Menu != none ) 
	{
		DestroyOldComMenu() ;
		return; 
	}

	if(!bPlayerIsCommander())
	{
		CTextMessage("You are NOT a commander", 'Red'); 
		return; 
	}
	
	Com_Menu = new (self) class'Rx_CommanderMenuHandler_Coop';
	Com_Menu.Enabled(self);
}

DefaultProperties
{
	PTMenuClass = class'Rx_GFxPurchaseMenu_Coop'
	VoteHandlerClass = class'Rx_VoteMenuHandler_Coop'
}