

class Rx_SoftLevelBoundaryVolume extends Volume placeable;

var float				fWaitToWarn;
var Soundcue			PlayerWarnSound;

var int					DamageWaitCounter;
var() int				DamageWait;

var() ArrowComponent 	Arrow;
var() rotator 			ArrowRotation;


event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local PlayerController PC;
	
	PC = GetPlayerController(Pawn(Other));
	if (PC != None)
	{
		if(Rx_Vehicle(Other) != None)
			return;
			//Other = Rx_Vehicle(Pawn(Other)).Driver;
	    
		ActivateDamagePlayerTimers(Rx_Pawn(Other));
	}
}


event UnTouch(Actor Other)
{
	
	if( EncompassesPoint(Other.location - vector(ArrowRotation) * 100) )
	{
		ClearOutOfAreaAnnouncement(Other);
		loginternal("Richtige Seite");
	} 
	else 
	{
		loginternal("Falsche Seite"); 
	}	

}

function ClearOutOfAreaAnnouncement(Actor Other)
{
	local PlayerController PC;
	local Rx_Hud RxHUD;
	
	PC = GetPlayerController(Pawn(Other));
	if (PC != None)
	{
		if(Rx_Vehicle(Other) != None)
			Other = Rx_Vehicle(Pawn(Other)).Driver;
		
		Rx_Pawn(Other).InPlayAreaVolumes = 1;
		RxHUD = Rx_Hud(PC.myHUD);
		if (WorldInfo.NetMode != NM_DedicatedServer && RxHUD != None)
			RxHUD.ClearPlayAreaAnnouncement();
		else
			Rx_Pawn(Other).ClearPlayAreaAnnouncementClient();		
			
	}
}

function ActivateDamagePlayerTimers(Rx_Pawn P)
{
	if(P.InPlayAreaVolumes > 0) {
		P.PlayAreaLeaveDamageWaitCounter = DamageWaitCounter;
		P.PlayAreaLeaveDamageWait = DamageWait;
		P.SetTimer(fWaitToWarn, false, 'PlayAreaTimerTick');
		P.InPlayAreaVolumes--;
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
	Begin Object Class=ArrowComponent Name=AC
		ArrowColor=(R=150,G=100,B=150)
		ArrowSize=5.0
		AbsoluteRotation=true
		bDisableAllRigidBody=false
	End Object
	Components.Add(AC)
	Arrow=AC
	
	
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