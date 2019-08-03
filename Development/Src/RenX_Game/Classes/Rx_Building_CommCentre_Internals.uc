class Rx_Building_CommCentre_Internals extends Rx_Building_TechBuilding_Internals
	notplaceable;

	
	
var private name IdleAnimName;
var Rx_Building_CommCentre_Internals CommCentreInternals;
var repnotify bool PlayIdleAnim;
	
	
	
`define GdiUnderAttackForGdiSound FriendlyBuildingSounds[BuildingUnderAttack]
`define GdiUnderAttackForNodSound FriendlyBuildingSounds[BuildingDestructionImminent]
`define NodUnderAttackForGdiSound EnemyBuildingSounds[BuildingUnderAttack]
`define NodUnderAttackForNodSound EnemyBuildingSounds[BuildingDestructionImminent]  



replication
{
	if (bNetDirty && Role == ROLE_Authority)
		PlayIdleAnim;
}

simulated event ReplicatedEvent( name VarName )
{
	if (VarName == 'PlayIdleAnim')
	{
		ToggleIdleAnimation();
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

// Initialize the building and set the visual section of the building
simulated function Init(Rx_Building Visuals, bool isDebug )
{
	super.Init(Visuals, isDebug);
	if(WorldInfo.Netmode != NM_Client) {
		PlayIdleAnim = True;
		ToggleIdleAnimation();
	}
}

simulated function ToggleIdleAnimation()
{
	if(PlayIdleAnim)
	{
		BuildingSkeleton.PlayAnim(IdleAnimName,,True);
	}
	else
	{
		BuildingSkeleton.StopAnim();
	}
}

function ChangeTeamReplicate(TEAM ToTeam, optional bool bChangeFlag=false)
{
	super.ChangeTeamReplicate(ToTeam,bChangeFlag); 
	SetTeamVisible(ToTeam);
}

function SetTeamVisible (TEAM ToTeam)
{
	local Controller PC;
	local Rx_Controller TRxPC; 
	local Rx_Bot TRxB; 
	
	
		//Went in too deep... shoulda' used PRI . May convert later
		foreach AllActors(class'Controller',PC)
		{
			//`log(PC); 
			if(PC.GetTeamNum() != 0 && PC.GetTeamNum() != 1) {
				;
				continue; 
			}
			//Handle Rx_Controllers
			if(Rx_Controller(PC) != none )
			{
				TRxPC = Rx_Controller(PC); 
					if(ToTeam != 0 && ToTeam != 1) 
				{
					TRxPC.SetRadarVisibility(1); 
					continue;
				}
				
				if(TRxPC.GetTeamNum() != ToTeam ) TRxPC.SetRadarVisibility(2); //Set Enemy team visible
				else
				if(TRxPC.GetTeamNum() == ToTeam ) TRxPC.SetRadarVisibility(1);  //Set Friendlies back to invisible on radar 
			}
			
			//Handle Bots
			if(Rx_Bot(PC) != none )
			{
				
				TRxB = Rx_Bot(PC); 
				//`log("SET BOT STATUS " @ TRxB.GetTeamNum() @ ToTeam );
					if(ToTeam != 0 && ToTeam != 1) 
				{
					TRxB.SetRadarVisibility(1); 
					continue;
				}
				
				if(TRxB.GetTeamNum() != ToTeam ) TRxB.SetRadarVisibility(2); //Set Enemy team visible
				else
				if(TRxB.GetTeamNum() == ToTeam ) TRxB.SetRadarVisibility(1);  //Set Friendlies back to invisible on radar 
			}
		}
	
	
	
}

DefaultProperties
{
	Begin Object Name=BuildingSkeletalMeshComponent
		SkeletalMesh        		= SkeletalMesh'RX_BU_CommCentre.Meshes.SK_BU_CommCentre'
		AnimSets(0)         		= AnimSet'RX_BU_CommCentre.Anims.AS_BU_CommCentre'
		AnimTreeTemplate    		= AnimTree'RX_BU_CommCentre.Anims.AT_BU_CommCentre'
		PhysicsAsset     			= PhysicsAsset'RX_BU_CommCentre.Meshes.SK_BU_CommCentre_Physics'
		bEnableClothSimulation 	 	= True
		bClothAwakeOnStartup   	 	= True
		ClothWind              	 	= (X=100.000000,Y=100.000000,Z=20.000000)
	End Object

	TeamID          = 255
	IdleAnimName    = "Radar_Spin"
}
