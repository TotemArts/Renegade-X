class Rx_AreaVolume extends Volume abstract;

// Used for identifing multiple play areas that should act together.
var() const int DamageWait;
var float fWaitToWarn;
var Soundcue PlayerWarnSound;

event UnTouch(Actor Other)
{
	`Log("Area Volume: UnTouch"@`ShowVar(Other),,'DevScript');
	Process(Other, true);
}

event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	`Log("Area Volume: Touch"@`ShowVar(Other),, 'DevScript');
	Process(Other, false, OtherComp, HitLocation, HitNormal) ;
}

function Process(Actor Other, bool leaving, optional PrimitiveComponent OtherComp, optional vector HitLocation, optional vector HitNormal)
{
	local array<Controller> controllers;
	local Controller PC;
	local bool outOfArea;
	
	//local PostProcessChain ppc;
	//local UberPostProcessEffect uppe;
	//local PostProcessEffect ppe;
	//local int i;

	 // we are ghost cheat flying, ignore
	if(pawn(other) != none && playercontroller(pawn(other).Controller) != none && playercontroller(pawn(other).Controller).bCheatFlying == true)
		return;

	outOfArea = false;
	
	if(leaving)
		outOfArea = true;

	controllers = BuildControllersList(Other);
	if(controllers.Length == 0) // no applicable controllers found.
		return;

	if (IsInValidAreaVolume(controllers[0].Pawn)) {
		outOfArea = false;
	}
	
	foreach controllers(PC)
	{
		if(outOfArea)
		{
			OutOfAreaActions(Other, PC);
		}
		else // not out of bounds
		{
			InAreaActions(Other, PC);
		}
	}
}

/**
 * Builds a list of relevant controllers attached to the actor.
 */
function array<Controller> BuildControllersList(Actor Other, optional PrimitiveComponent OtherComp, optional vector HitLocation, optional vector HitNormal)
{
	local array<Controller> controllers;
	local int index;

	if (UDKVehicle(Other) != None) // A vehicle - Add all occupants
	{
		for (index = 0; index != UDKVehicle(Other).Seats.Length; ++index)
			if (UDKVehicle(Other).Seats[index].SeatPawn != none && UDKVehicle(Other).Seats[index].SeatPawn.Controller != None && Rx_Controller(UDKVehicle(Other).Seats[index].SeatPawn.Controller) != None)
				controllers.AddItem(Rx_Controller(UDKVehicle(Other).Seats[index].SeatPawn.Controller));
	}
	else if(pawn(Other) != None && pawn(other).DrivenVehicle != none)
	{
		touch(pawn(other).DrivenVehicle,OtherComp, HitLocation, HitNormal);
	}
	else if (pawn(Other) != None && pawn(Other).Controller != None)
		controllers.AddItem((Pawn(Other).Controller));
	else if(pawn(other.Owner) != none && pawn(other.Owner).Controller != none)
		controllers.AddItem(pawn(other.Owner).Controller);
	else
		`Logd("Actor is not a vehicle, and doesnt have a controller, meaning not a human or bot, so ignoring",, 'DevScript');

	return controllers;
}

function OutOfAreaActions(Actor Other, Controller PC);

function InAreaActions(Actor Other, Controller PC);

//TODO Bots
function AreaWarningEffects(Bool enable, Controller PC)
{
	local PostProcessSettings pps;

	`Logd("Area Volume: AreaWarningEffects"@`ShowVar(enable),, 'DevScript');

	if(enable)
	{
		if(pc.PlayerReplicationInfo != none)
			`LogRx("Player"@pc.PlayerReplicationInfo.PlayerName@"is out of allowed area");

		Rx_Controller(PC).PlayAreaLeaveDamageWaitCounter = 0;
		Rx_Controller(PC).PlayAreaLeaveDamageWait = DamageWait;
		Rx_Controller(PC).SetTimer(fWaitToWarn, false, 'PlayAreaTimerTick');
		Rx_Controller(PC).IsInPlayArea = false;
				
		if(WorldInfo.NetMode != NM_DedicatedServer && Rx_MapInfo(WorldInfo.GetMapInfo()).EnablePostProcessing)
		{
			pps.Scene_Desaturation = Rx_MapInfo(WorldInfo.GetMapInfo()).SceneDesaturation;
			pps.Scene_TonemapperScale = Rx_MapInfo(WorldInfo.GetMapInfo()).SceneTonemapperScale;
			pps.Scene_InterpolationDuration = Rx_MapInfo(WorldInfo.GetMapInfo()).SceneInterpolationDuration;

			LocalPlayer(GetALocalPlayerController().Player).OverridePostProcessSettings(pps); //bug with setting fade in time. if not 0, it will fade in,,, then immediately fade out again :S.

			//**********************
			//leaving in my code spam as it may give hints on trying to solve the fade in bug.
			//**********************

			//pps.bOverride_Scene_InterpolationDuration = true;
			//pps.bOverride_Scene_TonemapperScale = true;
			//pps.bOverride_Scene_Desaturation = true;

			//ppc = LocalPlayer(GetALocalPlayerController().Player).GetPostProcessChain(0);
			//ppc = new class'PostProcessChain';

			//LocalPlayer(GetALocalPlayerController().Player).InsertPostProcessingChain(PostProcessChain'RenX_AssetBase.PostProcess.PP_outOfArea',INDEX_NONE, true);

			/*foreach ppc.Effects(ppe)
			{
				uppe = UberPostProcessEffect(ppe);
				if(uppe != none)
				{
					uppe.SceneDesaturation = Rx_MapInfo(WorldInfo.GetMapInfo()).SceneDesaturation;
					uppe.TonemapperScale = Rx_MapInfo(WorldInfo.GetMapInfo()).SceneTonemapperScale;
				}
			}*/

			//LocalPlayer(GetALocalPlayerController().Player).TouchPlayerPostProcessChain();
				
				
			//uppe = UberPostProcessEffect(ppc.FindPostProcessEffect('Desaturation'));
			//uppe = new class'UberPostProcessEffect';
			//uppe.EffectName = 'outOfArea';
			//uppe.SceneDesaturation = Rx_MapInfo(WorldInfo.GetMapInfo()).SceneDesaturation;

			//uppe = UberPostProcessEffect(ppc.FindPostProcessEffect('TonemapperScale'));
			//uppe.SceneDesaturation = Rx_MapInfo(WorldInfo.GetMapInfo()).SceneDesaturation;
			//ppc.Effects.AddItem(uppe);

			//LocalPlayer(GetALocalPlayerController().Player).InsertPostProcessingChain(ppc, INDEX_NONE, true);

			//uppe = ppc.FindPostProcessEffect("InterpolationDuration");
			//uppe.sc = Rx_MapInfo(WorldInfo.GetMapInfo()).SceneInterpolationDuration;
		}
	
	}
	else
	{
		if(pc.PlayerReplicationInfo != none && Rx_Controller(PC) != none && Rx_Controller(PC).IsInPlayArea == false)
			`LogRx("Player"@pc.PlayerReplicationInfo.PlayerName@"is now inside the allowed area");

		Rx_Controller(PC).IsInPlayArea = true;
		if (WorldInfo.NetMode != NM_DedicatedServer && Rx_Hud(Rx_Controller(PC).myHUD) != None)
			Rx_Hud(Rx_Controller(PC).myHUD).ClearPlayAreaAnnouncement();
		else
			Rx_Controller(PC).ClearPlayAreaAnnouncementClient();

		/*for (i = 0; i < LocalPlayer(GetALocalPlayerController().Player).PlayerPostProcessChains.length; i++)
		{
			if (LocalPlayer(GetALocalPlayerController().Player).PlayerPostProcessChains[i].FindPostProcessEffect('outOfArea') != None)
			{
				LocalPlayer(GetALocalPlayerController().Player).RemovePostProcessingChain(i);
				i--;                              
			}
		}*/
		if(WorldInfo.NetMode != NM_DedicatedServer)
			LocalPlayer(GetALocalPlayerController().Player).ClearPostProcessSettingsOverride();

		//LocalPlayer(GetALocalPlayerController().Player).RemovePostProcessingChain(0);		
	}
}

function bool IsAcceptableAreaVolume(Rx_AreaVolume V, Pawn P)
{
	return true;
}

/**
 * This function is structured to handle situations with overlapping volumes, if 2 or more volumes overlap, and an actor is walking from out of one and into another.
*/
function bool IsInValidAreaVolume(Pawn P)
{
	local Rx_AreaVolume V;

	foreach P.TouchingActors( class'Rx_AreaVolume', V ) //if more then one controller, its a vehicle, but we only need to check one controller to see if its out-of-bounds.
	{
		if (IsAcceptableAreaVolume(V, P))
		{
			return true;
		}
	}

	return false;
}

DefaultProperties
{
	//how long before PlayerWarnSound is played and damage countdown starts.
	fWaitToWarn				= 1.0f 
	
	//sounds
	PlayerWarnSound			= SoundCue'RX_Dialogue.Generic.S_BackToObjective_Cue'
	
	//the damage countdown. How long to give the player/actor before applying damage.
	DamageWait				= 10
	
	//internal
	bPawnsOnly 			    = true
}
