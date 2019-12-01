class Rx_Hud_PlayerNames_Survival extends Rx_Hud_PlayerNames;

function Draw()
{
	DrawPlayerNames();
	DrawVehicleSeats();
	DrawTeamWaypoints(); 
	DrawCommanderSupportBeacons();
	DrawSupportPawns(); 

	DrawStragglers();

}

function DrawStragglers()
{
	local Pawn P;

	foreach RenxHUD.WorldInfo.AllPawns(class'Pawn', P)
	{
		if(P.GetTeamNum() == RenXHud.PlayerOwner.GetTeamNum() || P.Health <= 0 || Rx_ScriptedBotPRI_Survival(P.PlayerReplicationInfo) == None)
			continue;
		if(Rx_ScriptedBotPRI_Survival(P.PlayerReplicationInfo).IsSpotted() || (Rx_GRI_Survival(RenxHUD.WorldInfo.GRI) != None && Rx_GRI_Survival(RenxHUD.WorldInfo.GRI).bNearWaveEnd))
			DrawIconOnStragglers(P);
	}
}


simulated function DrawIconOnStragglers(Pawn P)
{
	local Rx_HUD HUD ;
	local Vector AttackVector, MidscreenVector;
	local bool bIsBehindMe; //Handy thing I didn't come up with for finding orientation. Yosh can't take credit for that math stuff in Rx_Utils
	local CanvasIcon MyIcon;
	local float IconScale, DistanceFade, MinFadeAlpha; //Distance from crosshair for drawing alpha, and how transparent are we willing to get.
	//local float Bar_Width; //Start time and end time for target
 

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

		IconScale=1.25;
	}	
	else if(Rx_Pawn(P) != none )
	{
		MinFadeAlpha=100;	
		SetIconBlendColor(Rx_Pawn(P).GetHealNecessity());

		IconScale=1.0;
	}


	//Bar_Width=MyIcon.UL/2*IconScale;

	HUD.Canvas.SetPos(MidscreenVector.X,MidscreenVector.Y);

	//Draw bullshit

	//HUD.Canvas.DrawText("CanCommandSpot: " @ PC.bCanCommandSpot @ "bCommandSpottingt: " @ PC.bCommandSpotting, true, 1,1); 


	HUD.Canvas.SetPos(0,0);
					
				bIsBehindMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(RenxHud.PlayerOwner.ViewTarget.Location,RenxHud.PlayerOwner.Rotation,P.location) < -0.5;
				if(!bIsBehindMe) 
				{
					AttackVector=HUD.Canvas.Project(P.location) ;
					DistanceFade = abs(round(Vsize(MidscreenVector-AttackVector)))/(MidscreenVector.X) ; //Distance from the center of the screen.. Divided by the horizontal length of the screen, as it is USUALLY more than the vertical length
					
					//Insert functionality for fading with distance/ Scrap, fade is based on proximity of crosshair to target.
					//Set our color for the box
					/**
					HUD.Canvas.DrawColor.R=255;
					HUD.Canvas.DrawColor.G=255;
					HUD.Canvas.DrawColor.B=255;*/
					//`log("Distance FAde: "  @ DistanceFade);
					HUD.Canvas.DrawColor.A=Fmax(MinFadeAlpha, Fmin(255*DistanceFade*5,255));
			
					HUD.Canvas.DrawIcon(MyIcon,AttackVector.X-((MyIcon.UL/2)*IconScale),AttackVector.Y-((MyIcon.VL/2)*IconScale),IconScale);
					
					HUD.Canvas.SetPos(AttackVector.x-((MyIcon.UL/6)*IconScale), AttackVector.y-MyIcon.VL/2*IconScale-8);
					HUD.Canvas.Font = Font'RenXHud.Font.ScoreBoard_Small';
					
					HUD.Canvas.SetDrawColor(255,255,255,255);
					HUD.Canvas.DrawText("-[ENEMY]-" ,true,IconScale*1.25,IconScale*1.25);
					
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