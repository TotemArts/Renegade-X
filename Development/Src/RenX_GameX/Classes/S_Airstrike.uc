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
class S_Airstrike extends Rx_Airstrike;


simulated function PlayASSound()
{
	local PlayerController pc;
	local Rx_Controller IPC; 

	
	if (WorldInfo.NetMode == NM_DedicatedServer) return; // quit here if we are dedicated server

	foreach WorldInfo.AllControllers(class'PlayerController', pc)
	{
		IPC = Rx_Controller(pc);
		
				
		if(IPC.GetTeamNum() == 0)
		{	
			if(ASType==class'Rx_Airstrike_AC130')
			{
			IPC.CTextMessage("!!!Friendly Airstrike Inbound ["@IPC.GetSpottargetLocationInfo(self)@"] !!!",'Green',90,1.0);
			if (pc.IsLocalController())
					pc.PlaySound(SoundCue'S_EVA_VoiceClips.S_CABAL_FriendlyAirStrikeCue');
			}
			else
			{
			IPC.CTextMessage("!!!Enemy Airstrike Inbound!!!",'Red',90,1.0);

			if (pc.IsLocalController())
					pc.PlaySound(SoundCue'S_EVA_VoiceClips.S_CABAL_EnemyAirStrikeCue');
			}
		}


		else	
		{	
			if(ASType==class'S_Airstrike_AC130_Nod')
			{
			IPC.CTextMessage("!!!Friendly Airstrike Inbound ["@IPC.GetSpottargetLocationInfo(self)@"] !!!",'Green',90,1.0);
			if (pc.IsLocalController())
					pc.PlaySound(SoundCue'S_EVA_VoiceClips.S_CABAL_FriendlyAirStrikeCue');
			}
			else
			{
			IPC.CTextMessage("!!!Enemy Airstrike Inbound!!!",'Red',90,1.0);

			if (pc.IsLocalController())
					pc.PlaySound(SoundCue'S_EVA_VoiceClips.S_CABAL_EnemyAirStrikeCue');
			}
		}
		
			
	}
}

