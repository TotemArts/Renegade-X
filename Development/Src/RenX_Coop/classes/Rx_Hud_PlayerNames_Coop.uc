class Rx_Hud_PlayerNames_Coop extends Rx_Hud_PlayerNames;

var Array<Rx_CoopObjective> CoopObjectives;

function Draw()
{
	DrawPlayerNames();
	DrawVehicleSeats();
	DrawTeamWaypoints(); 
	DrawCommanderSupportBeacons();
	DrawObjectiveMarkers(); 
	DrawSupportPawns(); 
}

function UpdateObjectives()
{
	if(RenxHUD.PlayerOwner != None)
		CoopObjectives = Rx_Controller_Coop(RenxHUD.PlayerOwner).GetCoopObjectives();
}

function DrawObjectiveMarkers()
{
	local Rx_CoopObjective O;
	local Rx_HUD HUD ;
	local Vector WayPointVector, MidscreenVector;
	local bool bIsBehindMe; //Handy thing I didn't come up with for finding orientation. Yosh can't take credit for that math stuff in Rx_Utils
	local CanvasIcon MyIcon;
	local float IconScale, DistanceFade, MinFadeAlpha; //Distance from crosshair for drawing alpha
	local string FullWayPointStr; 
	local float XLen, YLen ; 
	local byte FinalAlpha; 
	local color BackgroundColor; 
	local Actor ActualActor;
	// ResScaleX, ResScaleY

	if(CoopObjectives.Length <= 0)
		UpdateObjectives();

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


	foreach CoopObjectives(O)
	{
		if(RenxHud.PlayerOwner.Pawn == none) 
			return; 

		if(!O.bShowObjective || O.bIsDisabled || O.VisualIndicatedActor == None)
			continue;
		if(Controller(O.VisualIndicatedActor) != None)
			ActualActor = Controller(O.VisualIndicatedActor).Pawn;
		else
			ActualActor = O.VisualIndicatedActor;
					
		bIsBehindMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(RenxHud.PlayerOwner.ViewTarget.Location,RenxHud.PlayerOwner.Rotation,ActualActor.location) < -0.5;
		
		if(bIsBehindMe) 
			continue;
				
		WayPointVector=HUD.Canvas.Project(ActualActor.Location) ;
		DistanceFade = abs(round(Vsize(MidscreenVector-WayPointVector)))/(MidscreenVector.X) ; //Distance from the center of the screen.. Divided by the horizontal length of the screen, as it is USUALLY more than the vertical length
		HUD.Canvas.SetPos(WayPointVector.x, WayPointVector.y);
		//Insert functionality for fading with distance/ Scrap, fade is based on proximity of crosshair to target.
				
		FullWayPointStr = O.VisualText @ "[" $ round(VSize(RenxHud.PlayerOwner.Pawn.location - O.location)/52.5)$"m]%"  ; 
				
		FinalAlpha = Fmax(MinFadeAlpha, Fmin(255*DistanceFade*5,255));
				
		//Set our color for the box
		HUD.Canvas.DrawColor = O.GetIndicatorColor();
		HUD.Canvas.DrawColor.A = FinalAlpha;
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