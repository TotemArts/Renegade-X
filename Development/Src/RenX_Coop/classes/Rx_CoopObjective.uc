class Rx_CoopObjective extends Rx_GameObjective
	placeable
	ClassGroup(Cooperative);
	
var(Coop) bool bOptional;	// Whether or not this objective is not necessary for mission completion
var(Coop) bool bFinalGoal;
var(Coop) int ObjectiveIndex;
var(Coop) bool bAnnounceFinish;
var(Coop) bool bAnnounceCompletingPlayer;
var(Coop) string CompletionMessage;
var(Coop) bool bFailCompletion;
var(Coop) int BonusVP;
Var(Coop) int TeamBonusVP;

simulated function PostBeginPlay()
{
	SetDefenderTeam();

	if(bOptional && bFinalGoal)		//Make up your mind! You can't be an optional objective AND final goal at once!
		bFinalGoal = false;

	super.PostBeginPlay();
}

function SetDefenderTeam()
{
	local byte PlayerIndex;

	if(Rx_MapInfo_Cooperative(WorldInfo.GetMapInfo()) != None)
		PlayerIndex = Rx_MapInfo_Cooperative(WorldInfo.GetMapInfo()).PlayerTeam;

	else
		PlayerIndex = 0;

	DefenderTeamIndex = PlayerIndex;
}

function OnCompleteObjective(Rx_SeqAct_CompleteObjective Action)
{
	local SeqVar_Object ObjVar;
	local Controller InstigatingPlayer;

	foreach Action.LinkedVariables(class'SeqVar_Object', ObjVar, "Instigator")
	{
		InstigatingPlayer = Controller(ObjVar.GetObjectValue());

		if(InstigatingPlayer != None)
		{
			FinishObjective(InstigatingPlayer);
			break;
		}
	}

	FinishObjective(None);
}

function OnModifyObjective(Rx_SeqAct_ModifyObjective Action)
{

	if(!Action.bOptional || !Action.bFinalGoal)
	{
		bOptional = Action.bOptional;
		bFinalGoal = Action.bFinalGoal;
	}


	bAnnounceFinish = Action.bAnnounceFinish;
	bAnnounceCompletingPlayer = Action.bAnnounceCompletingPlayer;
	CompletionMessage = Action.CompletionMessage;
	bFailCompletion = Action.bFailCompletion;
	BonusVP =  Action.BonusVP;
	TeamBonusVP = Action.TeamBonusVP;
}

function FinishObjective(Controller InstigatingPlayer)
{
	local Rx_Controller PC;

	if(bIsDisabled)
		return;

	bIsDisabled = true;

	foreach WorldInfo.AllControllers(class'Rx_Controller', PC)
	{		
		if(TeamBonusVP > 0)
			PC.DisseminateVPString("[Team Objective Completion]&" $ TeamBonusVP $ "&");
		if(PC == InstigatingPlayer && BonusVP > 0)
			PC.DisseminateVPString("[Objective Completion]&" $ BonusVP $ "&");
	}

	if(bAnnounceFinish)
	{
		Rx_Game_Cooperative(WorldInfo.Game).AnnounceObjectiveCompletion(InstigatingPlayer,Self);
	}

	if(!bOptional)
	{
		Rx_Game_Cooperative(WorldInfo.Game).CheckObjectives();		
	}
}

function bool IsDisabled()
{
	return bIsDisabled;
}

DefaultProperties
{
	CompletionMessage = "Objective has been completed!"
}