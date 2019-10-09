class Rx_Hud_PlayerNames extends Rx_Hud_Component;

var float RenderDelta;

var const float EnemyDisplayNamesRadius;
var const float EnemyVehicleDisplayNamesRadius;
var const float EnemyTargetedDisplayNamesRadius;
var const float EnemyTargetedVehicleDisplayNamesRadius;

var const float FriendlyDisplayNamesRadius;
var const float FriendlyVehicleDisplayNamesRadius;
var const float FriendlyTargetedDisplayNamesRadius;
var const float FriendlyTargetedVehicleDisplayNamesRadius;

var protected const Font PlayerNameFont;
var protected CanvasIcon Interact, Cover, Repair, Misc;

var protected CanvasIcon TI_Attack;
var protected CanvasIcon TI_Defend;

//var float TestNum; 

function Update(float DeltaTime, Rx_HUD HUD)
{
	Canvas = HUD.Canvas;
	if (RenxHud == none)
	{
		RenxHud = HUD;
	}

	RenderDelta = DeltaTime;
}

function Draw()
{
	DrawPlayerNames();
	DrawVehicleSeats();
	DrawTeamWaypoints(); 
	DrawCommanderSupportBeacons(); 
	DrawSupportPawns(); 
}

function bool VehicleSeatOccupied(int Seat, int SeatMask)
{
	return bool(SeatMask & (1<<(seat)));
}

function bool JustUsInVehicle(Rx_Vehicle Vehicle)
{
	local int i;

	for (i = 0; i < Vehicle.Seats.Length; i++)
	{
		if (VehicleSeatOccupied(i,Vehicle.SeatMask) && Vehicle.GetSeatPRI(i) != none )
		{
			if (RenxHud.PlayerOwner.PlayerReplicationInfo.GetHumanReadableName() != Vehicle.GetSeatPRI(i).GetHumanReadableName())
				return false;
		}
	}
	return true;
}

function DrawVehicleSeats()
{
	local Rx_Vehicle OtherVehicle;
	local Rx_PRI OtherPRI;
	local Rx_DefencePRI OtherDPRI;   
	local Pawn OurPawn;
	local string ScreenName;
	local float NameAlpha;
	local float OtherPawnDistance;
	local int i;
	local byte AntiTeamByte;

	// No need to draw player names on dedicated
	if(RenxHud.WorldInfo.NetMode == NM_DedicatedServer)
		return;
	
	OurPawn = Pawn(RenxHud.PlayerOwner.ViewTarget);
	// Only draw if we have a pawn of some sort.
	if(OurPawn == None)
		return;

	if(Rx_Controller(RenxHud.PlayerOwner) != None && Rx_Controller(RenxHud.PlayerOwner).IsSpectating())	
		return;
		
	// For each Rx_Vehicle in the game
   	foreach RenxHud.WorldInfo.AllPawns(class'Rx_Vehicle', OtherVehicle)
	{
		if (OtherVehicle == None)
			continue;
		
		
		AntiTeamByte = GetAntiTeamByte(RenxHud.PlayerOwner.GetTeamNum());
		
		//Reset these per iteration
		OtherPRI = none; 
		OtherDPRI = none; 
		
		//Added this so there aren't 40 different casts looking ugly as hell throughout this function 
		if(Rx_PRI(OtherVehicle.PlayerReplicationInfo) != none ) 
			OtherPRI = Rx_PRI(OtherVehicle.PlayerReplicationInfo); 
		else
		if(Rx_DefencePRI(OtherVehicle.PlayerReplicationInfo) != none ) 
			OtherDPRI = Rx_DefencePRI(OtherVehicle.PlayerReplicationInfo);
		
		if ((Rx_Defence(OtherVehicle) != none && Rx_Defence(OtherVehicle).bAIControl) ||  Rx_Vehicle_Harvester(OtherVehicle) != none) // A defense that is controlled by AI. Or a harvester
		{
			if(OtherDPRI != none && OurPawn.GetTeamNum() != OtherVehicle.GetTeamNum()) 
			{
		
				if(OtherDPRI.IsFocused()) 
					DrawFocusedIcon(OtherVehicle); 
				
				if(OtherDPRI.Unit_TargetStatus[AntiTeamByte] != 0)  
					DrawAttackT(OtherVehicle, OtherDPRI.Unit_TargetNumber[AntiTeamByte], OtherDPRI.ClientTargetUpdatedTime ) ; 
			
			}
		
		continue;	
		}
		if (IsStealthedEnemyUnit(OtherVehicle) || OtherVehicle.Health <= 0)
				continue;

		if (!RenxHud.ShowOwnNameInVehicle && 
			(OtherVehicle == RenxHud.PlayerOwner.ViewTarget || (Rx_VehicleSeatPawn(RenxHud.PlayerOwner.ViewTarget) != none && OtherVehicle == Rx_VehicleSeatPawn(RenxHud.PlayerOwner.ViewTarget).MyVehicle))
			&& JustUsInVehicle(OtherVehicle))
				continue;
		
		/*Draw the commander icon, if applicable*/
		if(OtherPRI != none && GetStance(OtherVehicle) == STANCE_FRIENDLY && OtherPRI.bGetIsCommander()) 
				DrawCommanderIcon(OtherVehicle);
				
		if (OurPawn.DrivenVehicle != none) // If we are in a vehicle, check distancefrom the vehicle location
				OtherPawnDistance = VSize(OurPawn.DrivenVehicle.Location-OtherVehicle.location);
		else
				OtherPawnDistance = VSize(OurPawn.Location-OtherVehicle.location);

		
		//Draw as a target if you're a target
		
		if(OtherPRI != none && OtherPRI.Unit_TargetStatus[AntiTeamByte] != 0) 
			DrawAttackT(OtherVehicle, OtherPRI.Unit_TargetNumber[AntiTeamByte], OtherPRI.ClientTargetUpdatedTime ); 
		
		
		// Fade based on display radius.
		if (RenxHud.TargetingBox.TargetedActor == OtherVehicle)
		{
			if(GetStance(OtherVehicle) == STANCE_FRIENDLY)
				NameAlpha = GetAlphaForDistance(OtherPawnDistance,FriendlyTargetedVehicleDisplayNamesRadius);
			else
				NameAlpha = GetAlphaForDistance(OtherPawnDistance,EnemyTargetedVehicleDisplayNamesRadius);
		}
		else
		{
			if(GetStance(OtherVehicle) == STANCE_FRIENDLY)
				NameAlpha = GetAlphaForDistance(OtherPawnDistance,FriendlyVehicleDisplayNamesRadius);
			else
				NameAlpha = GetAlphaForDistance(OtherPawnDistance,EnemyVehicleDisplayNamesRadius);
		}
		
		if ( (!OtherVehicle.bSpotted && NameAlpha == 0) || !IsActorInView(OtherVehicle))
			continue;

		ScreenName = "";
		if (IsVehicleEmpty(otherVehicle))
		{
			DrawNameOnActor(OtherVehicle,"Empty",GetStance(OtherVehicle),NameAlpha);
		}
		else if(OurPawn.GetTeamNum() == OtherVehicle.GetTeamNum())
		{
			for (i = 0; i < OtherVehicle.Seats.Length; i++)
			{
				if (VehicleSeatOccupied(i,OtherVehicle.SeatMask) && OtherVehicle.GetSeatPRI(i) != none )
				{
					ScreenName = OtherVehicle.GetSeatPRI(i).GetHumanReadableName();
					DrawNameOnActor(OtherVehicle,ScreenName,GetStance(OtherVehicle),NameAlpha, i);
				}
			}
		}
		else if(Rx_PRI(OtherVehicle.PlayerReplicationInfo) != none && Rx_PRI(OtherVehicle.PlayerReplicationInfo).IsFocused() )
			{
			DrawFocusedIcon(OtherVehicle); 
			}
   	}
}

function bool IsVehicleEmpty( Rx_Vehicle otherVehicle)
{
	local int i;
	for (i = 0; i < OtherVehicle.Seats.Length; i++)
	{
		if (VehicleSeatOccupied(i,OtherVehicle.SeatMask))
			return false;
	}
	return true;
}

function DrawPlayerNames()
{
	local Rx_Pawn OtherPawn;
	local Pawn OurPawn;
	local string ScreenName;
	local float NameAlpha;
	local float OtherPawnDistance;
	local byte AntiTeamByte;
	local Rx_PRI aPRI;
	// No need to draw player names on dedicated
	if(RenxHud.WorldInfo.NetMode == NM_DedicatedServer)
		return;
	
	OurPawn = Pawn(RenxHud.PlayerOwner.ViewTarget);
	// Only draw if we have a pawn of some sort.
	if(OurPawn == None)
		return;
	
	AntiTeamByte = GetAntiTeamByte(RenxHud.PlayerOwner.GetTeamNum());
	
	// For each Rx_Pawn in the game
   	foreach RenxHud.WorldInfo.AllPawns(class'Rx_Pawn', OtherPawn)
	{
		if (OtherPawn == None || OtherPawn.PlayerReplicationInfo == None || OtherPawn.Health <= 0 || Rx_PRI(OtherPawn.PlayerReplicationInfo).bIsScripted)
			continue;
		if ((OtherPawn == ourPawn && !RenxHud.ShowOwnName) || OtherPawn.DrivenVehicle != None)
			continue;
		if (IsStealthedEnemyUnit(OtherPawn) || IsEnemySpy(OtherPawn))
			continue;

		aPRI = Rx_PRI(OtherPawn.PlayerReplicationInfo);
		
		//Check if it is a targeted unit
		if(AntiTeamByte != 255 && aPRI.Unit_TargetStatus[AntiTeamByte] != 0)
			DrawAttackT(OtherPawn, aPRI.Unit_TargetNumber[AntiTeamByte],  aPRI.ClientTargetUpdatedTime ); 
		
		//Draw out commander 
		if(GetStance(OtherPawn) == STANCE_FRIENDLY && aPRI.bGetIsCommander()) 
			DrawCommanderIcon(OtherPawn);
		
		if (OurPawn.DrivenVehicle != none) // If we are in a vehicle, check distance from the vehicle location
			OtherPawnDistance = VSize(OurPawn.DrivenVehicle.Location-OtherPawn.location);
		else
			OtherPawnDistance = VSize(OurPawn.Location-OtherPawn.location);

		// Fade based on display radius.
		if (RenxHud.TargetingBox.TargetedActor == OtherPawn)
		{
			if(GetStance(OtherPawn) == STANCE_FRIENDLY)
				NameAlpha = GetAlphaForDistance(OtherPawnDistance,FriendlyTargetedDisplayNamesRadius);
			else
				NameAlpha = GetAlphaForDistance(OtherPawnDistance,EnemyTargetedDisplayNamesRadius);
		}
		else
		{
			if(GetStance(OtherPawn) == STANCE_FRIENDLY)
				NameAlpha = GetAlphaForDistance(OtherPawnDistance,FriendlyDisplayNamesRadius);
			else
				NameAlpha = GetAlphaForDistance(OtherPawnDistance,EnemyDisplayNamesRadius);
		}

		if (NameAlpha == 0 || !IsActorInView(OtherPawn))
			continue;		

		ScreenName = aPRI.GetHumanReadableName();
		
		DrawNameOnActor(OtherPawn,ScreenName,GetStance(OtherPawn),NameAlpha);
   	}
}

function DrawNameOnActor(Actor inActor, string inName, optional STANCE inStance = STANCE_NEUTRAL,optional float Opacity = 1.0f, optional int listOffset = 0)
{
	local float XLen, YLen;
	local vector ScreenLoc;
	local FontRenderInfo FontInfo;
	local Rx_Pawn		RxP; 
	local Rx_Vehicle	RxV; 
	local byte			HealNeccesity; //Hold necessity of healing for this pawn

	ScreenLoc = Canvas.Project(inActor.Location);

	if(Pawn(inActor) != None)
	{
		Canvas.StrLen(inName, XLen, YLen);

		Canvas.SetPos(ScreenLoc.X-0.5*XLen,ScreenLoc.Y-1.2*YLen + (YLen * listOffset));
		FontInfo.bEnableShadow=true;

		Canvas.Font = PlayerNameFont;			

		if(Rx_Pawn(inActor) != none) 
			RxP = Rx_Pawn(inActor);
		else if(Rx_Vehicle(inActor) != none) 
			RxV = Rx_Vehicle(inActor);
	
		if (!RenxHud.SystemSettingsHandler.GetNicknamesUseTeamColors() || RenxHud.PlayerOwner.WorldInfo.IsPlayingDemo())
		{
			if (inStance == STANCE_ENEMY)
				Canvas.DrawColor = ColorRed;
			else if (inStance == STANCE_FRIENDLY)
				Canvas.DrawColor = ColorGreen;
			else 
				Canvas.DrawColor = ColorWhite;
		}
		else
		{
			if (RenxHud.PlayerOwner.PlayerReplicationInfo.Team.TeamIndex == TEAM_GDI && inStance == STANCE_FRIENDLY ||
				RenxHud.PlayerOwner.PlayerReplicationInfo.Team.TeamIndex == TEAM_NOD && inStance == STANCE_ENEMY)
				Canvas.DrawColor = ColorYellow;
			else if (RenxHud.PlayerOwner.PlayerReplicationInfo.Team.TeamIndex == TEAM_NOD && inStance == STANCE_FRIENDLY ||
				RenxHud.PlayerOwner.PlayerReplicationInfo.Team.TeamIndex == TEAM_GDI && inStance == STANCE_ENEMY)
				Canvas.DrawColor = ColorRed;
			else
				Canvas.DrawColor = ColorWhite;
		}
				
		Canvas.DrawColor.A *= Opacity;
		Canvas.DrawText(inName,,1.0,1.0,FontInfo);
	}
	if(RenxHud.PlayerOwner.GetTeamNum() == inActor.GetTeamNum())
	{
		if(RxP != None)
			{
			
				if(RxP.UISymbol > 0) DrawRadioCommandUsedIcon(inActor, Rx_Pawn(inActor).UISymbol);
				else
				if(Rx_Pawn(RenxHud.PlayerOwner.Pawn) != none && Rx_Pawn(RenxHud.PlayerOwner.Pawn).IsHealer())
				{
					HealNeccesity = RxP.GetHealNecessity();
					if(HealNeccesity != 0) 
					{
						SetIconBlendColor(HealNeccesity);
						DrawRadioCommandUsedIcon(inActor, 1, 0.5);
					}
				}
				
			
			}	
		else
		if(RxV != None)
			{
			
				if(RxV.UISymbol > 0) DrawRadioCommandUsedIcon(inActor, RxV.UISymbol);
				else
				if(Rx_Pawn(RenxHud.PlayerOwner.Pawn) != none && Rx_Pawn(RenxHud.PlayerOwner.Pawn).IsHealer())
				{
					HealNeccesity = RxV.GetHealNecessity();
					if(HealNeccesity != 0) 
					{
						SetIconBlendColor(HealNeccesity);
						DrawRadioCommandUsedIcon(inActor, 1, 0.5);
					}
				}
				
			
			}
			
		
	}
	else
	if(inStance == STANCE_ENEMY)
	{
		if(Rx_Pawn(inActor) != None && (Rx_PRI(Rx_Pawn(inActor).PlayerReplicationInfo) != none && Rx_PRI(Rx_Pawn(inActor).PlayerReplicationInfo).IsFocused()))
		{
			DrawFocusedIcon(inActor);
		}	
		
	}
}

private function DrawRadioCommandUsedIcon(Actor inActor, byte Symbol, optional float ScaleMod = 1.0)
{
	local float X,Y, scale;
	local vector ScreenLoc;
	local CanvasIcon Icon;  
	
	
	switch (Symbol) //The only super small sized one
	{
		case 1: //Repair
		scale = 1.0; 
		Icon = Repair;
		if(Rx_Pawn(inActor) != none) SetIconBlendColor(Rx_Pawn(inActor).GetHealNecessity());			
		else
		if(Rx_Vehicle(inActor) != none) SetIconBlendColor(Rx_Vehicle(inActor).GetHealNecessity());				
		//Canvas.SetDrawColor(50,255,50,255);
		break;
		case 2:
		scale = 1.3; 
		Icon = Interact;
		Canvas.SetDrawColor(255,255,255,255);
		break; 
		case 3:
		scale = 0.5; 
		Icon = Cover;
		Canvas.SetDrawColor(50,255,50,255);
		break;
		case 4: 
		scale = 1.0 ;  
		Icon = Misc; 
		Canvas.SetDrawColor(50,255,50,255);
	}
	
	scale *= ScaleMod;
	
	ScreenLoc = inActor.Location;
	ScreenLoc.z += 60;	
	
	
	ScreenLoc = Canvas.Project(ScreenLoc);
	X = ScreenLoc.X - ((Icon.UL/2) * scale);

	Y = ScreenLoc.Y - (Icon.VL * scale);
	
	Y += Sin(class'WorldInfo'.static.GetWorldInfo().TimeSeconds * 7.0f) * 6.0f;


	Canvas.DrawIcon(Icon,X,Y,scale);
}

private function SetIconBlendColor(byte Severity)
{
	switch(Severity)
	{
		
		case 1:
		Canvas.DrawColor.R=0;
		Canvas.DrawColor.G=255;
		Canvas.DrawColor.B=0;
		break;
		
		case 2:
		Canvas.DrawColor.R=255;
		Canvas.DrawColor.G=255;
		Canvas.DrawColor.B=0;
		break;
		
		case 3:
		Canvas.DrawColor.R=255;
		Canvas.DrawColor.G=0;
		Canvas.DrawColor.B=0;
		break;
		
		default:
		Canvas.DrawColor.R=0;
		Canvas.DrawColor.G=255;
		Canvas.DrawColor.B=0;
		break;
	}
}

private function DrawFocusedIcon(Actor inActor)
{
	local float X,Y, scale, iconZAdjust;
	local vector ScreenLoc;
	local CanvasIcon Icon;  
	local float FullScale; 
	local float distanceAway;
	
	if(!IsActorInView(inActor)) return; //Behind us, don't bother
	
	if(Rx_Pawn(inActor) != none) 
	{
		Fullscale=0.25;
		iconZAdjust=80;
	} 
	else
	if(Rx_Vehicle(inActor) != none)
	{
		Fullscale = 0.40;
		iconZAdjust = 150;	
	}
	else
		return; 
	
	
	distanceAway = Fmin(3000.0, abs(VSize(inActor.location - RenxHud.PlayerOwner.Pawn.location)));
	if(distanceAway  <= 1) 
		distanceAway=1;
		
		//`log((FullScale/(3001.0/(distanceAway*TestNum))) @ distanceAway @ 3000/distanceAway) ; 
		
		scale = Fmin( FMax(0.15,(FullScale - (FullScale/(2000.0/(distanceAway)))*0.33) ) , FullScale);
		Icon = Cover;
		Canvas.SetDrawColor(255,0,0,255);
	
	ScreenLoc = inActor.Location;
	ScreenLoc.z += iconZAdjust;	
	
	
	ScreenLoc = Canvas.Project(ScreenLoc);
	X = ScreenLoc.X - ((Icon.UL/2) * scale);

	Y = ScreenLoc.Y - ((Icon.VL/2) * scale);
	
	//Y += Sin(class'WorldInfo'.static.GetWorldInfo().TimeSeconds * 7.0f) * 6.0f;


	Canvas.DrawIcon(Icon,X,Y,scale);
}

function float GetAlphaForDistance(float distance, float maxDistance)
{
	local float Alpha;

	if (distance <maxDistance)
	{
		if(distance >= maxDistance * 4/5)
		{
			Alpha = distance - 4.0/5.0*maxDistance;
			Alpha = Alpha/(maxDistance/5.0/100.0);
			Alpha = FMin(1.0,1.0-(1.0*Alpha/100.0));
			return Alpha;
		}
		else return 1;
	}
	else return 0;
}

simulated function DrawAttackT(Pawn P, byte TNumber, float InitialTime)
{
	local Rx_HUD HUD ;
	local Vector AttackVector, MidscreenVector;
	local bool bIsBehindMe; //Handy thing I didn't come up with for finding orientation. Yosh can't take credit for that math stuff in Rx_Utils
	local CanvasIcon MyIcon;
	local float IconScale, DistanceFade, MinFadeAlpha; //Distance from crosshair for drawing alpha, and how transparent are we willing to get.
	//local float Bar_Width; //Start time and end time for target
	local int Secs; 

	Secs=RenxHud.PlayerOwner.Worldinfo.TimeSeconds;

	if(InitialTime < 1) InitialTime = 1; 

	// ResScaleX, ResScaleY
	HUD=RenxHud; 

	MyIcon = TI_Attack;
	 //Special case for the Attack icon because it is wtfHUGE and bright as the sun.
	MidscreenVector.X=HUD.Canvas.SizeX*0.5;
	MidscreenVector.Y=HUD.Canvas.SizeY*0.5;

	IconScale=HUD.Canvas.SizeY/720.0; 
	
	if(Rx_Vehicle(P) != none )
	{
		MinFadeAlpha=230 ; //180; //Attack icon isn't quite as bright as most	
		SetIconBlendColor(Rx_Vehicle(P).GetHealNecessity());
		if((Secs-(InitialTime+15)) > 0) 
			IconScale = fmax(0.1, 1.25-(0.20*(Secs-(InitialTime+15)) ));
		else
			IconScale=1.25;
	}	
	else if(Rx_Pawn(P) != none )
	{
		MinFadeAlpha=100;	
		SetIconBlendColor(Rx_Pawn(P).GetHealNecessity());
		if((Secs-(InitialTime+15)) > 0) 
			IconScale = fmax(0.1, 1.0-(0.20*(Secs-(InitialTime+15)))) ;
		else
			IconScale=1.0;
	}


	//Bar_Width=MyIcon.UL/2*IconScale;

	HUD.Canvas.SetPos(MidscreenVector.X,MidscreenVector.Y);

	//Draw bullshit

	//HUD.Canvas.DrawText("CanCommandSpot: " @ PC.bCanCommandSpot @ "bCommandSpottingt: " @ PC.bCommandSpotting, true, 1,1); 


	HUD.Canvas.SetPos(0,0);
					
				bIsBehindMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(RenxHud.PlayerOwner.ViewTarget.Location,RenxHud.PlayerOwner.Rotation,P.location) < -0.5;
				if(!bIsBehindMe) {
					AttackVector=HUD.Canvas.Project(P.location) ;
					DistanceFade = abs(round(Vsize(MidscreenVector-AttackVector)))/(MidscreenVector.X) ; //Distance from the center of the screen.. Divided by the horizontal length of the screen, as it is USUALLY more than the vertical length
					
					//Insert functionality for fading with distance/ Scrap, fade is based on proximity of crosshair to target.
					//Set our color for the box
					/**
					HUD.Canvas.DrawColor.R=255;
					HUD.Canvas.DrawColor.G=255;
					HUD.Canvas.DrawColor.B=255;*/
					`log("Distance FAde: "  @ DistanceFade);
					HUD.Canvas.DrawColor.A=Fmax(MinFadeAlpha, Fmin(255*DistanceFade*5,255));
			
					HUD.Canvas.DrawIcon(MyIcon,AttackVector.X-((MyIcon.UL/2)*IconScale),AttackVector.Y-((MyIcon.VL/2)*IconScale),IconScale);
					
					HUD.Canvas.SetPos(AttackVector.x-((MyIcon.UL/6)*IconScale), AttackVector.y-MyIcon.VL/2*IconScale-8);
					HUD.Canvas.Font = Font'RenXHud.Font.ScoreBoard_Small';
					
					HUD.Canvas.SetDrawColor(255,255,255,255);
					HUD.Canvas.DrawText("-["$ TNumber $"]-" ,true,IconScale*1.25,IconScale*1.25);
					
					//Draw Target Number 
					
					
				//Draw the target's decay bar
					/**
					//Set our color for the box
					HUD.Canvas.DrawColor.R=0;
					HUD.Canvas.DrawColor.G=0;
					HUD.Canvas.DrawColor.B=0;
					
					HUD.Canvas.SetPos(AttackVector.x-((MyIcon.UL/4)*IconScale), AttackVector.y-(MyIcon.VL/4)*IconScale); //Set position to draw the bar 
					//HUD.Canvas.SetPos(AttackVector.x-((MyIcon.UL/2)*IconScale), AttackVector.y-(MyIcon.VL*IconScale)); //Set position back to draw the box that will contain it. 
					HUD.Canvas.DrawBox(MyIcon.UL/2*IconScale,3*(HUD.Canvas.SizeY/1080)) ;
					
					
					//Set our color for the bar
					HUD.Canvas.DrawColor.R=255;
					HUD.Canvas.DrawColor.G=64;
					HUD.Canvas.DrawColor.B=64;
					
					HUD.Canvas.SetPos(AttackVector.x-((MyIcon.UL/4)*IconScale), AttackVector.y-(MyIcon.VL/4)*IconScale); //Set position to draw the bar 
					//HUD.Canvas.SetPos(AttackVector.x-((MyIcon.UL/2)*IconScale), AttackVector.y-(MyIcon.VL*IconScale)); //Set position to draw the bar 
					HUD.Canvas.DrawBox ( (Bar_Width-(Bar_Width/(20.0/(Secs-InitialTime)))) ,3*(HUD.Canvas.SizeY/1080)) ;//
				*/
				
					//Reset to non-blending white
				
					
					//HUD.Canvas.DrawIcon(TI_Attack,AttackVector.X-32,AttackVector.Y-32); //Icon is 64x64; needs to be drawn at half of that to hit sit dead center of the target.
				}
				
}		
			
function DrawSupportPawns()
{
	
	local Rx_HUD HUD ;
	local Vector WayPointVector, MidscreenVector;
	local bool bIsBehindMe; //Handy thing I didn't come up with for finding orientation. Yosh can't take credit for that math stuff in Rx_Utils
	local CanvasIcon MyIcon;
	local float IconScale, DistanceFade, MinFadeAlpha; //Distance from crosshair for drawing alpha
	local Rx_BasicPawn Waypoint; 
	local string FullWayPointStr; 
	local float XLen, YLen ; 
	// ResScaleX, ResScaleY
	HUD=RenxHud; 
	IconScale=HUD.Canvas.SizeY/720.0; 
	MidscreenVector.X=HUD.Canvas.SizeX/2;
	MidscreenVector.Y=HUD.Canvas.SizeY/2;


	MinFadeAlpha=210; 
	
	//foreach Renxhud.WorldInfo.AllActors(class'Rx_CommanderWaypoint', Waypoint)
	foreach Renxhud.WorldInfo.AllActors(class'Rx_BasicPawn', Waypoint)
	{
		if(!Waypoint.bDrawLocation || WayPoint.Health <= 0 || RenxHud.PlayerOwner.Pawn == None) 
			continue; 
		
		if(Waypoint.GetTeamNum() == HUD.PlayerOwner.GetTeamNum()) MyIcon = TI_Defend;
		else
		MyIcon = TI_Attack ; 
					
		bIsBehindMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(RenxHud.PlayerOwner.ViewTarget.Location,RenxHud.PlayerOwner.Rotation,Waypoint.location) < -0.5;
		if(!bIsBehindMe) 
		{
					
			WayPointVector=HUD.Canvas.Project(Waypoint.location) ;
			DistanceFade = abs(round(Vsize(MidscreenVector-WayPointVector)))/(MidscreenVector.X) ; //Distance from the center of the screen.. Divided by the horizontal length of the screen, as it is USUALLY more than the vertical length
			HUD.Canvas.SetPos(WayPointVector.x, WayPointVector.y);
			//Insert functionality for fading with distance/ Scrap, fade is based on proximity of crosshair to target.
						
			FullWayPointStr = WayPoint.ActorName @ "[" $ round(VSize(RenxHud.PlayerOwner.Pawn.location - Waypoint.location)/52.5)$"m]" ; 
						
			//Set our color for the box
			HUD.Canvas.DrawColor.R=255;
			HUD.Canvas.DrawColor.G=255;
			HUD.Canvas.DrawColor.B=255;
			HUD.Canvas.DrawColor.A=Fmax(MinFadeAlpha, Fmin(255*DistanceFade*5,255));
			//HUD.Canvas.DrawColor.A=Fmax(255-(GDI_Targets[i].T_Defend[j].T_Age*80)-50,0);
			HUD.Canvas.DrawIcon(MyIcon,WayPointVector.X-((MyIcon.UL/2)*IconScale),WayPointVector.Y-((MyIcon.UL/2)*IconScale),IconScale);
						
			HUD.Canvas.Font = Font'RenXHud.Font.ScoreBoard_Small';
			HUD.Canvas.StrLen(FullWayPointStr, XLen, YLen);
			HUD.Canvas.SetPos((WayPointVector.x-MyIcon.UL/4*IconScale)-(XLen*0.25), WayPointVector.y-MyIcon.VL/4*IconScale-12);
					
			HUD.Canvas.DrawText( FullWayPointStr ,true,IconScale,IconScale);
			//HUD.Canvas.DrawIcon(TI_Defend,WayPointVector.X-32,WayPointVector.Y-32); //Icon is 64x64; needs to be drawn at half of that to hit sit dead center of the target.
		}
				
	}		
			
			
}
	
function DrawCommanderSupportBeacons()
{
	
local Rx_HUD HUD ;
local Vector WayPointVector, MidscreenVector;
local bool bIsBehindMe; //Handy thing I didn't come up with for finding orientation. Yosh can't take credit for that math stuff in Rx_Utils
local CanvasIcon MyIcon;
local float IconScale, DistanceFade, MinFadeAlpha; //Distance from crosshair for drawing alpha
local Rx_CommanderSupportBeacon Waypoint; 
local string FullWayPointStr; 
local float XLen, YLen ; 
local float ResScaleX, ResScaleY; 
// ResScaleX, ResScaleY
HUD=RenxHud; 
MyIcon = TI_Defend;
IconScale=HUD.Canvas.SizeY/720.0; 
MidscreenVector.X=HUD.Canvas.SizeX/2;
MidscreenVector.Y=HUD.Canvas.SizeY/2;

ResScaleX = HUD.Canvas.SizeX/1280.0;
ResScaleY = HUD.Canvas.SizeY/720.0;

MinFadeAlpha=180; 
	
	foreach Renxhud.WorldInfo.AllActors(class'Rx_CommanderSupportBeacon', Waypoint)
	{
		if(Waypoint.GetTeamNum() != HUD.PlayerOwner.GetTeamNum()) return; //TODO : Edit this to draw either red or green depending on team
					
				bIsBehindMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(RenxHud.PlayerOwner.ViewTarget.Location,RenxHud.PlayerOwner.Rotation,Waypoint.location) < -0.5;
				if(!bIsBehindMe) 
					{
					
				WayPointVector=HUD.Canvas.Project(Waypoint.location) ;
				DistanceFade = abs(round(Vsize(MidscreenVector-WayPointVector)))/(MidscreenVector.X) ; //Distance from the center of the screen.. Divided by the horizontal length of the screen, as it is USUALLY more than the vertical length
				WayPointVector.y+=24*ResScaleY; 
				HUD.Canvas.SetPos(WayPointVector.x, WayPointVector.y);
				//Insert functionality for fading with distance/ Scrap, fade is based on proximity of crosshair to target.
				
				
				
				FullWayPointStr = WayPoint.GetName();  // @ "[" $ Waypoint.GetTimeLeft() $ "s]" ; 
				
				
				
				//Set our color for everything
				HUD.Canvas.DrawColor.R=255;
				HUD.Canvas.DrawColor.G=255;
				HUD.Canvas.DrawColor.B=255;
				HUD.Canvas.DrawColor.A=Fmax(MinFadeAlpha, Fmin(255*DistanceFade*5,255));				
				HUD.Canvas.Font = Font'RenXHud.Font.ScoreBoard_Small';
				HUD.Canvas.StrLen(FullWayPointStr, XLen, YLen);
				//End Setup
				
				//Draw visibility box behind text
				HUD.Canvas.DrawColor.R=0;
				HUD.Canvas.DrawColor.G=0;
				HUD.Canvas.DrawColor.B=0;
				HUD.Canvas.DrawColor.A=96			;
				
				HUD.Canvas.SetPos(((WayPointVector.x)-(XLen*0.5))-8*ResScaleX,WayPointVector.y-MyIcon.VL/4*IconScale)		; //Draw off to the left edge of where the text will be.  

				Canvas.DrawRect((XLen*IconScale+(16*ResScaleX) ),YLen*IconScale+(2*ResScaleY)) ; //Rectangle should hang off of both sides.
				
				HUD.Canvas.SetPos((WayPointVector.x)-(XLen*0.5), WayPointVector.y-MyIcon.VL/4*IconScale);
				
				//Reset colour
				HUD.Canvas.DrawColor.R=255;
				HUD.Canvas.DrawColor.G=255;
				HUD.Canvas.DrawColor.B=255;
				HUD.Canvas.DrawColor.A=Fmax(MinFadeAlpha, Fmin(255*DistanceFade*5,255));	
			
				HUD.Canvas.DrawText( FullWayPointStr ,true,IconScale,IconScale);
				//HUD.Canvas.DrawIcon(TI_Defend,WayPointVector.X-32,WayPointVector.Y-32); //Icon is 64x64; needs to be drawn at half of that to hit sit dead center of the target.
					}
		}		
			
			
	}

function DrawTeamWaypoints()
{
	
	local Rx_HUD HUD ;
	local Vector WayPointVector, MidscreenVector;
	local bool bIsBehindMe; //Handy thing I didn't come up with for finding orientation. Yosh can't take credit for that math stuff in Rx_Utils
	local CanvasIcon MyIcon;
	local float IconScale, DistanceFade, MinFadeAlpha; //Distance from crosshair for drawing alpha
	local Rx_CommanderWaypoint Waypoint; 
	local string FullWayPointStr; 
	local float XLen, YLen ; 
	local byte FinalAlpha; 
	local color BackgroundColor; 
	// ResScaleX, ResScaleY
	HUD=RenxHud; 
	MyIcon = TI_Defend;
	IconScale=HUD.Canvas.SizeY/720.0; 
	MidscreenVector.X=HUD.Canvas.SizeX/2;
	MidscreenVector.Y=HUD.Canvas.SizeY/2;

	BackGroundColor.R=0; 
	BackGroundColor.G=0;
	BackGroundColor.B=0; 
	BackGroundColor.A=100;

	MinFadeAlpha=140; 
	
	foreach Renxhud.WorldInfo.AllActors(class'Rx_CommanderWaypoint', Waypoint)
	{
		if(Waypoint.GetTeamNum() != HUD.PlayerOwner.GetTeamNum() || RenxHud.PlayerOwner.Pawn == none) continue; 
					
				bIsBehindMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(RenxHud.PlayerOwner.ViewTarget.Location,RenxHud.PlayerOwner.Rotation,Waypoint.location) < -0.5;
				if(!bIsBehindMe) 
					{
					
				WayPointVector=HUD.Canvas.Project(Waypoint.location) ;
				DistanceFade = abs(round(Vsize(MidscreenVector-WayPointVector)))/(MidscreenVector.X) ; //Distance from the center of the screen.. Divided by the horizontal length of the screen, as it is USUALLY more than the vertical length
				HUD.Canvas.SetPos(WayPointVector.x, WayPointVector.y);
				//Insert functionality for fading with distance/ Scrap, fade is based on proximity of crosshair to target.
				
				FullWayPointStr = WayPoint.GetName() @ "[" $ round(VSize(RenxHud.PlayerOwner.Pawn.location - Waypoint.location)/52.5)$"m]%"  ; 
				
				FinalAlpha = Fmax(MinFadeAlpha, Fmin(255*DistanceFade*5,255));
				
				//Set our color for the box
				HUD.Canvas.DrawColor.R=255;
				HUD.Canvas.DrawColor.G=255;
				HUD.Canvas.DrawColor.B=255;
				HUD.Canvas.DrawColor.A=FinalAlpha; 
				//HUD.Canvas.DrawColor.A=Fmax(255-(GDI_Targets[i].T_Defend[j].T_Age*80)-50,0);
				HUD.Canvas.DrawIcon(MyIcon,WayPointVector.X-((MyIcon.UL/2)*IconScale),WayPointVector.Y-((MyIcon.UL/2)*IconScale),IconScale);
				
				HUD.Canvas.Font = Font'RenXHud.Font.ScoreBoard_Small';
				HUD.Canvas.StrLen(FullWayPointStr, XLen, YLen);
				HUD.Canvas.SetPos((WayPointVector.x-MyIcon.UL/4*IconScale)-(XLen*0.25), WayPointVector.y-MyIcon.VL/4*IconScale-12);
				HUD.DrawDelimitedText(FullWayPointStr,"%", (WayPointVector.x-MyIcon.UL/4*IconScale)-(XLen*0.25) , WayPointVector.y-MyIcon.VL/4*IconScale-12, true, BackgroundColor,,0.6);
				
				//HUD.Canvas.DrawCenteredText(FullWayPointStr, (WayPointVector.x-MyIcon.UL/4*IconScale), WayPointVector.y-MyIcon.VL/4*IconScale) ;
				
				//HUD.Canvas.DrawText( FullWayPointStr ,true,IconScale,IconScale);
				//HUD.Canvas.DrawIcon(TI_Defend,WayPointVector.X-32,WayPointVector.Y-32); //Icon is 64x64; needs to be drawn at half of that to hit sit dead center of the target.
					}
				
		}		
			
			
	}	
	

function DrawCommanderIcon(Pawn CommanderPawn)
{
	local Rx_HUD HUD ;
	local Vector CommanderPawnVector, MidscreenVector;
	local bool bIsBehindMe; //Handy thing I didn't come up with for finding orientation. Yosh can't take credit for that math stuff in Rx_Utils
	local CanvasIcon MyIcon;
	local float IconScale, DistanceFade, MinFadeAlpha; //Distance from crosshair for drawing alpha
	local string FullCommanderPawnStr; 
	local float XLen, YLen ; 
	local byte FinalAlpha; 
	local color BackgroundColor; 
	// ResScaleX, ResScaleY
	HUD=RenxHud; 
	MyIcon = TI_Defend;
	IconScale=HUD.Canvas.SizeY/720.0; 
	MidscreenVector.X=HUD.Canvas.SizeX/2;
	MidscreenVector.Y=HUD.Canvas.SizeY/2;

	BackGroundColor.R=0; 
	BackGroundColor.G=0;
	BackGroundColor.B=0; 
	BackGroundColor.A=100;

	MinFadeAlpha=200; 
	
	
	if((CommanderPawn != None  && CommanderPawn.GetTeamNum() != HUD.PlayerOwner.GetTeamNum()) || RenxHud.PlayerOwner.Pawn == None) return; 
					
		bIsBehindMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(RenxHud.PlayerOwner.ViewTarget.Location,RenxHud.PlayerOwner.Rotation,CommanderPawn.location) < -0.5;
		if(!bIsBehindMe) 
		{				
			CommanderPawnVector=HUD.Canvas.Project(CommanderPawn.location) ;
			DistanceFade = abs(round(Vsize(MidscreenVector-CommanderPawnVector)))/(MidscreenVector.X) ; //Distance from the center of the screen.. Divided by the horizontal length of the screen, as it is USUALLY more than the vertical length
			HUD.Canvas.SetPos(CommanderPawnVector.x, CommanderPawnVector.y);
			//Insert functionality for fading with distance/ Scrap, fade is based on proximity of crosshair to target.
				
			FullCommanderPawnStr = "Commander" @ "[" $ round(VSize(RenxHud.PlayerOwner.Pawn.location - CommanderPawn.location)/52.5)$"m]%"  ; 
				
			FinalAlpha = Fmax(MinFadeAlpha, Fmin(255*DistanceFade*5,255));
				
			//Set our color for the box
			HUD.Canvas.DrawColor.R=255;
			HUD.Canvas.DrawColor.G=255;
			HUD.Canvas.DrawColor.B=255;
			HUD.Canvas.DrawColor.A=FinalAlpha; 
			//HUD.Canvas.DrawColor.A=Fmax(255-(GDI_Targets[i].T_Defend[j].T_Age*80)-50,0);
			HUD.Canvas.DrawIcon(MyIcon,CommanderPawnVector.X-((MyIcon.UL/2)*IconScale),CommanderPawnVector.Y-((MyIcon.UL/2)*IconScale),IconScale);
				
			HUD.Canvas.Font = Font'RenXHud.Font.ScoreBoard_Small';
			HUD.Canvas.StrLen(FullCommanderPawnStr, XLen, YLen);
			HUD.Canvas.SetPos((CommanderPawnVector.x-MyIcon.UL/4*IconScale)-(XLen*0.25), CommanderPawnVector.y-MyIcon.VL/4*IconScale-12);
			HUD.DrawDelimitedText(FullCommanderPawnStr,"%", (CommanderPawnVector.x-MyIcon.UL/4*IconScale)-(XLen*0.25) , CommanderPawnVector.y-MyIcon.VL/4*IconScale-12, true, BackgroundColor,,0.6);
		}			
}	


function byte GetAntiTeamByte(byte ForTeam)
{
	 if(ForTeam == 0) return 1 ;
	 else 
	 if(ForTeam == 1) return 0 ;
	 else
	 return 255; 
}
	
DefaultProperties
{
	PlayerNameFont = Font'RenXHud.Font.PlayerName'

	EnemyDisplayNamesRadius = 1000.0f
	EnemyTargetedDisplayNamesRadius = 1500.0f
	EnemyVehicleDisplayNamesRadius = 2500.0f
	EnemyTargetedVehicleDisplayNamesRadius = 3000.0f
	
	FriendlyDisplayNamesRadius = 2000.0f
	FriendlyTargetedDisplayNamesRadius = 8000.0f
	FriendlyVehicleDisplayNamesRadius = 3500.0f
	FriendlyTargetedVehicleDisplayNamesRadius = 10000.0f
	
	Interact = (Texture = Texture2D'renxtargetsystem.T_TargetSystem_Interact', U= 0, V = 0, UL = 32, VL = 64)
	Repair = (Texture = Texture2D'RenXPurchaseMenu.T_Icon_Item_MechanicalKit', U= 0, V = 0, UL = 256, VL = 128)
	Cover = (Texture = Texture2D'RenXPurchaseMenu.T_Icon_Weapons', U= 0, V = 0, UL = 256, VL = 128)
	Misc = (Texture = Texture2D'RenXPurchaseMenu.T_Icon_Item_MotionSensor', U= 0, V = 0, UL = 256, VL = 128)
	
	TI_Attack=(Texture = Texture2D'RenXTargetSystem.T_NavMarker_Max_White', U= 0, V = 0, UL = 64, VL = 64) 
	TI_Defend=(Texture = Texture2D'RenXTargetSystem.T_NavMarker_Max_Green', U= 0, V = 0, UL = 64, VL = 64) 
	
}
