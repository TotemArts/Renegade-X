

class Rx_PlayAreaVolume extends Volume placeable;

var float				fWaitToWarn;
var Soundcue			PlayerWarnSound;

var int					DamageWaitCounter;
var() int				DamageWait;

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local PlayerController PC;
	local Rx_Hud RxHUD;
	
	PC = GetPlayerController(Pawn(Other));
	if (PC != None)
	{
		if(Rx_Vehicle(Other) != None)
			Other = Rx_Vehicle(Pawn(Other)).Driver;
		
		//todo: also for passengers
		
		Rx_Pawn(Other).InPlayAreaVolumes++;
		RxHUD = Rx_Hud(PC.myHUD);
		if (WorldInfo.NetMode != NM_DedicatedServer && RxHUD != None)
			RxHUD.ClearPlayAreaAnnouncement();
		else
			Rx_Pawn(Other).ClearPlayAreaAnnouncementClient();		
		
		
	}
}

event UnTouch(Actor Other)
{
	local PlayerController PC;

	if(Rx_Pawn(Other) != none && Rx_Pawn(Other).drivenVehicle != none)
	{
		if(Touching.find(Rx_Pawn(Other).drivenVehicle) != INDEX_NONE)
			return;
	}
	
	//player itself, or player driving verhicle
	PC = GetPlayerController(Pawn(Other));
	if (PC != None)
	{
		if(Rx_Vehicle(Other) != None)
			Other = Rx_Vehicle(Pawn(Other)).Driver;
	    
		ActivateDamagePlayerTimers(Rx_Pawn(Other));
		/**
		if(Rx_Vehicle(Other) != None)
		{
			for (i = 1; i < Rx_Vehicle(Other).Seats.length; i++)
			{
				ActivateDamagePlayerTimers(Rx_Pawn(Rx_Vehicle(Other).Seats[i].StoragePawn));
			}
		}
		*/
	}
}

function ActivateDamagePlayerTimers(Rx_Pawn P)
{
	P.InPlayAreaVolumes--;
	if(P.InPlayAreaVolumes <= 0) {
		P.PlayAreaLeaveDamageWaitCounter = DamageWaitCounter;
		P.PlayAreaLeaveDamageWait = DamageWait;
		P.SetTimer(fWaitToWarn, false, 'PlayAreaTimerTick');
	}
}

function PlayerController GetPlayerController(Pawn P)
{
	local UDKVehicleBase V;
	
	if (P.Controller != None)
		return PlayerController(P.Controller);
	else
	{
		if (P.DrivenVehicle != None)
		{
			V = UDKVehicleBase(P.DrivenVehicle);
			
			if (V.Controller != None)
				return PlayerController(V.Controller);
		}
	}
	
	return None;
}



DefaultProperties
{
	/**	
	//Apparently these two variables are needed to cause it not to error.
	bStatic					= false
	bNoDelete				= true
	*/
	
	//how long before PlayerWarnSound is played and damage countdown starts.
	fWaitToWarn				= 1.0f 
	
	//sounds
	PlayerWarnSound			= SoundCue'RX_Dialogue.Generic.S_BackToObjective_Cue'
	//BeepSound				= SoundCue'RX_WP_Timed.Sounds.SC_Beep_Single'
	
	//how much damage to apply every second outside volume.
	//DamageToCause			= 20
	
	//how long before start applying damage.
	DamageWait				= 10
	
	//internal
	DamageWaitCounter		= 0
	bPawnsOnly 			    = true
}