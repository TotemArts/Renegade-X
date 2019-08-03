/***********************************************************************************************************************************************
 This document is written by nBab after banging his head against the wall many times trying to learn UnrealScript/Mutators by Trial and Error!
***********************************************************************************************************************************************/

class Fort extends RX_Mutator;

var Rx_CapturableMCT_MC MC;
var Rx_Building_WeaponsFactory WF;
var Rx_Vehicle_Harvester_GDI Harvester_GDI;


function InitMutator(string options, out string errorMessage)
{
		

		if (Rx_Game(WorldInfo.Game) != None)
		{
			Rx_Game(WorldInfo.Game).DefaultPawnClass = class'nBab_Pawn';
			Rx_Game(WorldInfo.Game).PlayerControllerClass = class'nBab_Controller';
		}
		Super.InitMutator(options, errorMessage);
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	foreach AllActors(class 'Rx_CapturableMCT_MC',MC)
		break;
	foreach AllActors(class 'Rx_Building_WeaponsFactory',WF)
		break;
		
	SetTimer(2, true);
}


simulated function Timer()
{
	local Rx_Pawn Player;

	foreach DynamicActors(class 'Rx_Pawn', Player)
	{
		if (Player.GetTeamNum() == MC.GetTeamNum())
		{
			if(Player.HealthMax <= 100)
				Player.HealthMax = Player.HealthMax + 50;
			if (Player.Health+1 <= Player.HealthMax)
				Player.Health++;
			if (Player.HealthMax > 150)
				Player.HealthMax = 150;
			if (Player.Health > Player.HealthMax)
				Player.Health = Player.HealthMax;
		}else if (Player.GetTeamNum() != MC.GetTeamNum() && Player.HealthMax>100)
		{
			Player.HealthMax = 100;
			if (Player.Health > Player.HealthMax)
				Player.Health = Player.HealthMax;
		}
	}
}

function bool CheckReplacement(Actor other)
{
	local Vector loc;
    local Rotator rot;
	local vector v;

	v.X = 700;
	v.Y = 300;
	v.Z = 0;

	if (other.isA('TS_Vehicle_Titan')) {
		WF.BuildingInternals.BuildingSkeleton.GetSocketWorldLocationAndRotation('Veh_Spawn', loc, rot);
		if(VSize(other.CollisionComponent.GetPosition() - loc) <10){
			other.CollisionComponent.SetRBPosition(other.CollisionComponent.GetPosition()-v);
		}
	}

	return true;
}
