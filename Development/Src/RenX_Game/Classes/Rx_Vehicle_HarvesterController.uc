// virtual class

class Rx_Vehicle_HarvesterController extends AIController;

var transient Rx_Vehicle_Harvester harv_vehicle;
var byte TeamNum;
var bool                            bLogTripTimes;
var float							tripTimer;
var Rx_Building_Refinery refinery;

//Comm Centre
var byte RadarVisibility, LastRadarVisibility; //Set radar visibility. 0: Invisible to all 1: visible to your team 2: visible to enemy team 

//Buff/Debuff modifiers//

var float Misc_SpeedModifier; 

//Weapons
var float Misc_DamageBoostMod; 
var float Misc_RateOfFireMod;
var float Misc_ReloadSpeedMod;

//Survivablity
var float Misc_DamageResistanceMod;
var float Misc_RegenerationMod; 

//Stat Modifiers
struct ActiveModifier
{
	var class<Rx_StatModifierInfo> ModInfo; 
	var float				EndTime; 
	var bool				Permanent; 
};

var array<ActiveModifier> ActiveModifications; 

var Rx_Controller QueuedStopController; 
var bool bQueuedStop; //Is there a manual stop queued up? 

replication
{
	// Things the server should send to the client.
	if (bNetDirty)
		RadarVisibility;
}

event PostBeginPlay()
{
	super.PostBeginPlay();
	SetTimer(0.1,true,'CheckActiveModifiers');
}

state Harvesting
{


}

function GotoTib()
{
	harv_vehicle.Throttle = 1.0;
	SetTimer(1.0,false,'GotoTib2');

	if (bLogTripTimes)
	{
		//`log(((TeamNum == 0)? "GDI" : "Nod") @ " harvester took " @ tripTimer @ " to unload.");
		tripTimer = 0;
	}
}

function bool IsTurningToDock() {
	return harv_vehicle.bTurningToDock;
}

function OnEMPHit(Controller InstigatedByController, Actor EMPCausingActor, optional int TimeModifier = 0)
{
	//`logd("harvester EMPd");

	if(IsInState('Harvesting'))
	{
		harv_vehicle.bPlayHarvestingAnim = false;  
		Pawn.Mesh.stopanim();
		PauseTimer(true, 'finishHarvesting');
	}
	else if(refinery.DockedHarvester == self)
	{
		refinery.bHarvEMPd = true;
	}
}

function OnEMPBleed(bool finish=false)
{
	//`logd("OnEMPBleed start");
	if(IsInState('Harvesting') && finish)
	{
		harv_vehicle.bPlayHarvestingAnim = true;  
		Pawn.Mesh.PlayAnim('Harvesting',,true);
		PauseTimer(false, 'finishHarvesting');
	}
	else if(refinery.DockedHarvester == self && finish)
	{
		refinery.bHarvEMPd = false;
	}
}

function SetSpottedRadarVisibility()
{
	LastRadarVisibility = RadarVisibility; 
	
	SetRadarVisibility(2); //Set full visible from spotting
	
	SetTimer(8.0,false, 'ResetRadarVisibility' ); //8 seconds just seems fair
}

function SetRadarVisibility(byte Visibility)
{
	//`log("--------- BOT set Pawn Radar Visibility---------" @ RadarVisibility) ; 
	RadarVisibility = Visibility; 
	if(Rx_Pawn(Pawn) != none ) 
		Rx_Pawn(Pawn).SetRadarVisibility(Visibility); 
	else
	if(Rx_Vehicle(Pawn) != none ) 
		Rx_Vehicle(Pawn).SetRadarVisibility(Visibility); 
}

simulated function byte GetRadarVisibility()
{
	return RadarVisibility; 
}

function CheckRadarVisibility()
{
	local Actor CommTower;
	local Rx_GRI GRI; 
	
	GRI = Rx_GRI(WorldInfo.GRI); 
		//`log("controller check Radar Visibility") ; 
		foreach GRI.TechBuildingArray(CommTower)
		{
				//`log(CommTower.GetTeamNum()); 
			if(CommTower.isA('Rx_Building_CommCentre_Internals') == false || CommTower.GetTeamNum() < 0 || CommTower.GetTeamNum() > 1  ) return; 
			if(CommTower.GetTeamNum() == GetTeamNum() ) 
				SetRadarVisibility(1);
			else
			if(CommTower.GetTeamNum() != GetTeamNum() ) 
				SetRadarVisibility(2);
			break;
		
		}
}

function ResetRadarVisibility()
{
	SetRadarVisibility(LastRadarVisibility); 
}

function ToggleSelfDestructTimer(Rx_Controller InstigatingController)
{
	if(IsTimerActive('SelfDestructHarvester')) 
	{
		InstigatingController.CTextMessage("Harvester Destruction Cancelled",'Pink');
		ClearTimer('SelfDestructHarvester');
	}
	else
	{
		SetTimer(10.0,false,'SelfDestructHarvester');
		InstigatingController.CTextMessage("Destroying Harvester in 10 seconds!",'Pink');
	}
	
}

function SelfDestructHarvester()
{
	harv_vehicle.BlowUpVehicle(); 
} 

function bool ToggleHaltHarv(Rx_Controller InstigatingController, optional bool bForce) ; 

function UpdateHaltedHarvWaypoint(bool bNeedsPush);

//Rx_Controller rollover

/**Set modifiers**/

function AddActiveModifier(class<Rx_StatModifierInfo> Info)//class<Rx_StatModifierInfo> Info) 
{
	local int FindI; 
	local ActiveModifier TempModifier; 
	//local class<Rx_StatModifierInfo> Info; 
	
	//Info = class'Rx_StatModifierInfo_Nod_PTP';
	
	FindI = ActiveModifications.Find('ModInfo', Info);
	
	//Do not allow stacking of the same modification. Instead, reset the end time of said modification
	if(FindI != -1) 
	{
		//`log("Found in array");
		ActiveModifications[FindI].EndTime = WorldInfo.TimeSeconds+Info.default.Mod_Length; 
		//return; 	
	}
	else //New modifier, so add it in and re-update modification numbers
	{
		//`log("Adding to array"); 
		TempModifier.ModInfo = Info; 
		if(Info.default.Mod_Length > 0) TempModifier.EndTime = WorldInfo.TimeSeconds+Info.default.Mod_Length;
		else
		TempModifier.Permanent = true; 
		ActiveModifications.AddItem(TempModifier);	
	}
	
	UpdateModifiedStats(); 
}


function UpdateModifiedStats()
{
	local ActiveModifier TempMod;
	local byte			 HighestPriority; 
	//local LinearColor	 PriorityColor; 
	local bool			 bAffectsWeapon;
	local class<Rx_StatModifierInfo> PriorityModClass; /*Highest priority modifier class (For deciding what overlay to use)*/
	
	ClearAllModifications(); //start from scratch
	HighestPriority = 255 ; // 255 for none
	
	if(ActiveModifications.Length < 1) 
	{
		if(Rx_Pawn(Pawn) != none) 
		{
			//In case speed was modified. Update animation info
			Rx_Pawn(Pawn).SetSpeedUpgradeMod(0.0);
			Rx_Pawn(Pawn).UpdateRunSpeedNode(); 
			Rx_Pawn(Pawn).SetGroundSpeed();
			Rx_Pawn(Pawn).ClearOverlay();
		}
		else if(Rx_Vehicle(Pawn) != none)
		{
			Rx_Vehicle(Pawn).ClearOverlay();
		}
		//TODO: Insert code to handle vehicles 
		return; 	
	}
	
	foreach ActiveModifications(TempMod) //Build all buffs
	{
		Misc_SpeedModifier+=TempMod.ModInfo.default.SpeedModifier;	
		Misc_DamageBoostMod+=TempMod.ModInfo.default.DamageBoostMod;	
		Misc_RateOfFireMod-=TempMod.ModInfo.default.RateOfFireMod;
		Misc_ReloadSpeedMod-=TempMod.ModInfo.default.ReloadSpeedMod;
		Misc_DamageResistanceMod-=TempMod.ModInfo.default.DamageResistanceMod;
		Misc_RegenerationMod+=TempMod.ModInfo.default.RegenerationMod;
		bAffectsWeapon=TempMod.ModInfo.static.bAffectsWeapons();
		if(TempMod.ModInfo.default.EffectPriority < HighestPriority || TempMod.ModInfo.default.EffectPriority == 0) 
		{
			HighestPriority = TempMod.ModInfo.default.EffectPriority;
			//PriorityColor = TempMod.ModInfo.default.EffectColor;
			PriorityModClass = TempMod.ModInfo;
		}
	}
	
	
	if(Rx_Pawn(Pawn) != none) 
	{
		//In case speed was modified. Update animation info
		Rx_Pawn(Pawn).SetSpeedUpgradeMod(Misc_SpeedModifier);
		Rx_Pawn(Pawn).UpdateRunSpeedNode();
		Rx_Pawn(Pawn).SetGroundSpeed();
		Rx_Pawn(Pawn).SetOverlay(PriorityModClass, bAffectsWeapon) ; 
		
		if(Rx_Weapon(Pawn.Weapon) != none) Rx_Weapon(Pawn.Weapon).SetROFChanged(true);	
	}
	else if(Rx_Vehicle(Pawn) != none) 
	{
		//Misc_SpeedModifier+=1.0; //Add one to account for vehicles not operating like Rx_Pawn 
		Rx_Vehicle(Pawn).UpdateThrottleAndTorqueVars();
		Rx_Vehicle(Pawn).SetOverlay(PriorityModClass.default.EffectColor) ; 
		
		if(Rx_Vehicle_Weapon(Pawn.Weapon) != none) Rx_Vehicle_Weapon(Pawn.Weapon).SetROFChanged(true);	
	}
}

function ClearAllModifications()
{
	//Buff/Debuff modifiers
	Misc_SpeedModifier 			= default.Misc_SpeedModifier;

	//Weapons
	Misc_DamageBoostMod 		= default.Misc_DamageBoostMod; 
	Misc_RateOfFireMod 			= default.Misc_RateOfFireMod; 
	Misc_ReloadSpeedMod 		= default.Misc_ReloadSpeedMod; 

	//Survivablity
	Misc_DamageResistanceMod 	= default.Misc_DamageResistanceMod;
	Misc_RegenerationMod 		= default.Misc_RegenerationMod; 	
}

function RemoveAllEffects()
{
	ActiveModifications.Length = 0; 
	
	UpdateModifiedStats(); 
}

function CheckActiveModifiers()
{
	local ActiveModifier TempMod;
	local float			 TimeS; 
	
	if(ActiveModifications.Length < 1) return; 
	
	TimeS=WorldInfo.TimeSeconds; 
	
	//Should never be more than 1 or 2 of these at any given time, so shouldn't affect tick, though can be moved to a timer if necessary. 
	foreach ActiveModifications(TempMod) 
	{
		if(!TempMod.Permanent && TimeS >= TempMod.EndTime) 
		{
			ActiveModifications.RemoveItem(TempMod);
			
			UpdateModifiedStats(); 
		}
	}
}

function PawnDied(Pawn inPawn)
{
	super.PawnDied(inPawn);
	if(refinery.DockedHarvester == self)
	{
		refinery.bHarvEMPd = false;
	}	
}

/****End Modifier Functions*****/

function ClearQueuedStop()
{
	bQueuedStop = false; 
	QueuedStopController = none; 
}

function SetQueuedStop(Rx_Controller StopController)
{
	bQueuedStop = true; 
	QueuedStopController = StopController; 
	Rx_Game(WorldInfo.Game).CTextBroadCast(GetTeamNum(),"Harvester Stop Queued",'LightBlue');
}

function ReassignRefinery(Rx_Building_Refinery Ref)
{
	refinery = Ref;
}

DefaultProperties
{
	RadarVisibility = 1 
	bIsPlayer = false
	bLogTripTimes = false
	
	//Buff/Debuff modifiers//

	Misc_SpeedModifier 			= 0.0 

	//Weapons
	Misc_DamageBoostMod 		= 0.0  
	Misc_RateOfFireMod 			= 0.0f //1.0 
	Misc_ReloadSpeedMod 		= 0.0f //1.0 

	//Survivablity
	Misc_DamageResistanceMod 	= 1.0 
	Misc_RegenerationMod 		= 1.0  
}
