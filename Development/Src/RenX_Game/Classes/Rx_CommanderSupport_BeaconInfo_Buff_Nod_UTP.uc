/****************************************************
* Holds the basic information for support beacons
*
* -Yosh
*****************************************************/

class Rx_CommanderSupport_BeaconInfo_Buff_Nod_UTP extends Rx_CommanderSupport_BeaconInfo_AOEBuff; 

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
				
				//Inject for defensive buff to clear EMP status on vehicles
				if(VehActor.bEMPd){
					VehActor.ClearEMP();
				}
				
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

DefaultProperties
{
	MaxCastRange = 0
	AOE_Radius = 2000
	FireSoundCue = SoundCue'RX_CharSnd_Generic.Ambient_Yelling.AmbientYell_Nod_NoMercy_Cue'
	bBroadcastToEnemy 	= false

	ModifierClass = class'Rx_StatModifierInfo_Nod_UTP'

	PowerName			= "Unity Through Peace"

	CPCost				= 1200 //800
}