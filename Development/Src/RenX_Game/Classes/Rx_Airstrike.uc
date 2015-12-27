/** Serverside only actor.
 *  It is used to:
 *  - count AS attack time
 *  - play sound on players;
 *      playing sound is done by simple class var
 *      change ASType to minimize network load
 *      (if you would like to add count down sounds too,
 *      I recommend implementing client-side timers
 *      inside PlayASSound function
 *  
 *  Additional AS related stuff should go in here, like:
 *  - static function to check if any AS is currently in progress already */
class Rx_Airstrike extends Info;

var float ASDelay;
var repnotify class<Rx_Airstrike_Vehicle> ASType;

replication
{
	if (bNetDirty)
		ASType;
}

function Init(class<Rx_Airstrike_Vehicle> type)
{
	ASType = type;
	SetTimer(ASDelay, false, 'StartAS');
	PlayASSound();
}

event StartAS()
{
	if (ASType != none) Spawn(ASType, Owner, , Location, Rotation, , false);
	Destroy();
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'ASType') PlayASSound();
	else Super.ReplicatedEvent(VarName);
}

simulated function PlayASSound()
{
	local PlayerController pc;
	local Rx_Controller IPC; 
	local color CGreen, CRed; //colours to use for air strike messages
	
	CGreen=MakeColor(10,255,0,255); 
	CRed=MakeColor(255,0,10,255); 
	
	if (WorldInfo.NetMode == NM_DedicatedServer) return; // quit here if we are dedicated server

	foreach WorldInfo.AllControllers(class'PlayerController', pc)
	{
		IPC = Rx_Controller(pc);
		
	if (pc.IsLocalController()) // play on local players only
									// in case we are NM_ListenServer,
									// without this check, it would replicate
									// sound playing two times
			pc.PlaySound(ASType.default.ApproachingSound);
			
	if(IPC.GetTeamNum() == 0)
	{	
	if(ASType==class'Rx_Airstrike_A10')	IPC.CTextMessage("GDI",90, "!!!Friendly Airstrike Inbound!!!",CGreen,255, 255, false, 1);
	else
	IPC.CTextMessage("GDI",90, "!!!Enemy Airstrike Inbound!!!",CRed,255, 255, false, 0.6);
	}
	else	
	{	
	if(ASType==class'Rx_Airstrike_AC130')	IPC.CTextMessage("GDI",90, "!!!Friendly Airstrike Inbound!!!",CGreen,255, 255, false, 1);
	else
	IPC.CTextMessage("GDI",90, "!!!Enemy Airstrike Inbound!!!",CRed,255, 255, false);
	}
		
			
	}
}

DefaultProperties
{
	ASDelay=5.f
	RemoteRole=ROLE_SimulatedProxy

	// so all players on the map get to hear the sound
	bAlwaysRelevant=true
}
