/****************************************************
* Holds the basic information for support beacons
*
* -Yosh
*****************************************************/

class Rx_CommanderSupport_BeaconInfo_AOEBuff extends Rx_CommanderSupport_BeaconInfo; 

var class<Rx_StatModifierInfo> ModifierClass; 

//Do some beacon specific area affect
static function DoAreaEffect(Actor CallingActor, vector L, byte T)
{
	local Actor TargetActor;
	local Pawn	ActorPawn; 
	local Rx_Vehicle VehActor; 
	local PlayerReplicationInfo SeatPRI; 
	local int i; 
	
	super.DoAreaEffect(CallingActor, L,T);
	
	foreach CallingActor.CollidingActors(class'Actor',TargetActor, default.AOE_Radius, CallingActor.location)
	{
		if(TargetActor.GetTeamNum() == CallingActor.GetTeamNum()) 
		{
			ActorPawn = Pawn(TargetActor); 
			if(ActorPawn == none) continue; 
			else
			if(Rx_Controller(ActorPawn.Controller) != none) Rx_Controller(ActorPawn.Controller).AddActiveModifier(default.ModifierClass); 
			else
			if(Rx_Bot(ActorPawn.Controller) != none) Rx_Bot(ActorPawn.Controller).AddActiveModifier(default.ModifierClass);
			else
			if(Rx_Defence_Controller(ActorPawn.Controller) != none) Rx_Defence_Controller(ActorPawn.Controller).AddActiveModifier(default.ModifierClass); 
			else
			if(Rx_Vehicle_HarvesterController(ActorPawn.Controller) != none) Rx_Vehicle_HarvesterController(ActorPawn.Controller).AddActiveModifier(default.ModifierClass); 
			
			if(Rx_Vehicle(ActorPawn) != none) 
			{
				VehActor = Rx_Vehicle(ActorPawn); 
				for(i=0;i<VehActor.Seats.Length;i++)
				{
					SeatPRI = VehActor.GetSeatPRI(i);
					
					if(SeatPRI == none) continue; 
					
					if( Rx_Controller(SeatPRI.Owner) != none) 
					{
						Rx_Controller(SeatPRI.Owner).AddActiveModifier(default.ModifierClass);
					}
					else
					if( Rx_Bot(SeatPRI.Owner) != none) 
					{
						Rx_Bot(SeatPRI.Owner).AddActiveModifier(default.ModifierClass);
					}
					else
					if( Rx_Defence_Controller(SeatPRI.Owner) != none) 
					{
						Rx_Defence_Controller(SeatPRI.Owner).AddActiveModifier(default.ModifierClass);
					}
					if( Rx_Vehicle_HarvesterController(SeatPRI.Owner) != none) 
					{
						Rx_Vehicle_HarvesterController(SeatPRI.Owner).AddActiveModifier(default.ModifierClass);
					}
					
				}
			} 
		}
	}
}

static function bool IsEntryVectorClear(vector BeaconVector, rotator BeaconRotation, Actor TraceActor)
{

	return true; 

}

DefaultProperties
{
SpawnedVehicle(0) = none

SupportPayload = none
SupportSpawnLocation = (X=0, Y=0, Z=0)

bAffectArea = true
AOE_Radius = 1500
FireSoundCue = SoundCue'RX_SoundEffects.SFX.S_RadarBuzz_Cue'

VerticalClearanceNeeded = 0 //Unnecessary

EntryAngleLengthRequirment 	= 0 
EntryAngleRotation 			= (Pitch=0, Roll=0, Yaw=32768) //Most support powers come from behind their rotation
EntryAngleStartLocation 	= (X=0, Y=0, Z=0)

AbilityCallTime 	= 0.1
LingerTime			= 0.01
bPlayWarningSiren 	= false
bBroadcastToEnemy 	= false
bBroadcastToTeam	= false

PowerName			= "PEACE THROUGH POWER"
ModifierClass			= class'Rx_StatModifierInfo'
}