class Rx_HUD_ObjectiveVisuals extends Rx_Hud_Component;

//Hopefully the last HUD thing I need to create

var int TextTimer_Caution, TextTimer_Warning, TextTimer_Update, TextTimer_Announcment;
var int SpamTime_Caution, SpamTime_Warning, SpamTime_Update, SpamTime_Announcment;
var color Warning_Color, Caution_Color, Update_Color, Announcment_Color			;

struct AgingTarget 
{
	var Actor T_Actor ;
	var float   T_Age;
	var float T_StartTime; 
	//var byte KillFlag;
	
};

struct AgingBTarget 
{
	var Rx_Building T_Building ;
	var float   T_Age;
	
};

struct Target_Array 
{
	var AgingTarget 		T_Attack[3]; //Need the actors, as we'll need to reference and update their location/stats
	var AgingTarget 		T_Defend[3];
	var vector 		T_Waypoint; //Waypoints don't move on their own, so they just need to be a location
	var vector		T_Waypoint2;
	
	structDefaultProperties
	{
		T_Attack(0)=(T_Actor=none, T_Age=2)  //Make sure 0 is the default oldest
		T_Defend(0)=(T_Actor=none, T_Age=2) //Same goes for Defence targets 
		//T_Repair(0)=(T_Actor=none, T_Age=2) //Same goes for Repair targets 
	}
};

var Target_Array GDI_Targets[3], NOD_Targets[3]							;

var byte GDI_AttackUpdated,GDI_DefendUpdated, GDI_RepairUpdated, GDI_WaypointUpdated; 
var byte NOD_AttackUpdated,NOD_DefendUpdated, NOD_RepairUpdated, NOD_WaypointUpdated;
var bool GDI_CommanderUpdated, GDI_CommanderLeft;
var bool NOD_CommanderUpdated, NOD_CommanderLeft;

//var int GDI_A_Cycler, NOD_A_Cycler ;
/////////////////////////////////////////////////////////////////
////////////////////////Visual Aspects///////////////////////////
/////////////////////////////////////////////////////////////////

var 	float		FadeDistance,MaxFullyVisibleTime, AttackT_DecayTime, DistanceFadeModifier, DecayBarSensitivity	; //Distance at which targets begin to start fading away, if any. /Time before Attack Targets disappear

//Icon pulsating movement
var float IconPulse, IconPulseRate, IconPulseMax, IconPulseMin 	;	 
var bool IconPulseFlipped										;	


var 	CanvasIcon	TI_Attack, TI_Defend, TI_Repair, TI_Waypoint		;

var		CanvasIcon	Marker_Attack, Marker_DWaypoint, Marker_Waypoint	;

var 	int 		BuildingTargetZOffset								;

var		string		MyTeam												;

var int Sync_Cycler														; //Used for syncing target age with the age from ORI 

var Rx_ORI			myORI 												;
var int GDICommanderID[3], NODCommanderID[3]							;
/*******************************************************************************************
********************************************************************************************
********************************************************************************************
********************************************************************************************
********************************************************************************************/




simulated function Update(float DeltaTime, Rx_HUD HUD) 
{
	local int T;
	local Rx_ORI ORI;
	
	
	super.Update(DeltaTime, HUD);
		
	//Get mah team
	T=RenxHud.PlayerOwner.GetTeamNum() ;
	
	if(myORI == none) //Find my ORI
	{
		foreach RenxHud.PlayerOwner.AllActors(class'Rx_ORI', ORI)
		{
			myORI = ORI ;
			
			break;
		
		}
		
		
	}
		
	ControlPulse();
		
		//YoshTAG - Optimize this 
		switch(T) 
	{
		case 0 : 
		MyTeam = "GDI";
		break;
		
		case 1 :
		MyTeam = "NOD" ;
		break;
	}
		
		
		SpamTimerHandler(); //Update our spam timers as well
		
		Sync_Cycler=0;
	
	
	
}
/***********************************************************
************************************************************
*Functions used to actually draw targets
*DrawAttackT(), DrawDefendT(), DrawRepairT(), DrawWaypoint()
************************************************************
************************************************************/

simulated function DrawAttackT()
{
local Rx_HUD HUD ;
local Vector AttackVector, MidscreenVector;
local int i,j;
local bool bIsBehindMe; //Handy thing I didn't come up with for finding orientation. Yosh can't take credit for that math stuff in Rx_Utils
local CanvasIcon MyIcon;
local float IconScale, DistanceFade, MinFadeAlpha; //Distance from crosshair for drawing alpha, and how transparent are we willing to get.
local Rx_Controller PC;
local float Target_Stime, Bar_Width; //Start time and end time for target
local int Secs; 

Secs=RenxHud.PlayerOwner.Worldinfo.TimeSeconds;

// ResScaleX, ResScaleY
HUD=RenxHud; 

PC=Rx_Controller(HUD.PlayerOwner) ; 
MyIcon = TI_Attack;
IconScale=1.0; //Special case for the Attack icon because it is wtfHUGE and bright as the sun.
MidscreenVector.X=HUD.Canvas.SizeX/2;
MidscreenVector.Y=HUD.Canvas.SizeY/2;

MinFadeAlpha=100; //Attack icon isn't quite as bright as most

Bar_Width=MyIcon.UL/2*IconScale;

HUD.Canvas.SetPos(MidscreenVector.X,MidscreenVector.Y);

//Draw bullshit

HUD.Canvas.DrawText("CanCommandSpot: " @ PC.bCanCommandSpot @ "bCommandSpottingt: " @ PC.bCommandSpotting, true, 1,1); 


HUD.Canvas.SetPos(0,0);
switch (MyTeam) //We're pretty self sufficient, so we can just use our own variables
	{
	case "GDI":
	//Draw Attack targets (Not including buildings)
	for (i=0; i<1; i++)
		{
			//if(myORI.Commander_GDI == "") continue; //Not even a commander... ignore this and don't waste time on it.
			
			for(j=0;j<3;j++)
			{
				
			if(GDI_Targets[i].T_Attack[j].T_Actor != none)
				
				//if(Rx_Pawn(GDI_Targets[i].T_Attack[j].T_Actor).Health > 0 || Rx_Vehicle(GDI_Targets[i].T_Attack[j].T_Actor)
				{
					
				bIsBehindMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(RenxHud.PlayerOwner.ViewTarget.Location,RenxHud.PlayerOwner.Rotation,GDI_Targets[i].T_Attack[j].T_Actor.location) < -0.5;
				if(!bIsBehindMe) 
					{
						
					Target_Stime=GDI_Targets[i].T_Attack[j].T_StartTime;
					
				AttackVector=HUD.Canvas.Project(GDI_Targets[i].T_Attack[j].T_Actor.location) ;
				DistanceFade = abs(round(Vsize(MidscreenVector-AttackVector)))/(MidscreenVector.X) ; //Distance from the center of the screen.. Divided by the horizontal length of the screen, as it is USUALLY more than the vertical length
				
				//Insert functionality for fading with distance/ Scrap, fade is based on proximity of crosshair to target.
				HUD.Canvas.DrawColor.A=Fmax(MinFadeAlpha, Fmin(255*DistanceFade*DistanceFadeModifier,255));
		
				HUD.Canvas.DrawIcon(MyIcon,AttackVector.X-((MyIcon.UL/2)*IconScale),AttackVector.Y-((MyIcon.VL/2)*IconScale),IconScale);
				
				HUD.Canvas.SetPos(AttackVector.x-((MyIcon.UL/6)*IconScale), AttackVector.y-MyIcon.VL/2*IconScale-8);
				HUD.Canvas.Font = Font'RenXHud.Font.ScoreBoard_Small';
				HUD.Canvas.DrawText( Bar_Width @ "/" @ Bar_Width/(AttackT_DecayTime/(Secs-Target_Stime)) ,true,IconScale,IconScale);
				
				//HUD.Canvas.DrawText("["$ j+1 $"]" ,true,IconScale,IconScale);
				
				//HUD.Canvas.DrawColor.A=Fmax(255-(GDI_Targets[i].T_Attack[j].T_Age*80)-50,0);
				
				//Draw the target's decay bar
				
				
				
			//Draw the target's decay bar
				
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
				//MyIcon.UL/2*IconScale
				HUD.Canvas.SetPos(AttackVector.x-((MyIcon.UL/4)*IconScale), AttackVector.y-(MyIcon.VL/4)*IconScale); //Set position to draw the bar 
				//HUD.Canvas.SetPos(AttackVector.x-((MyIcon.UL/2)*IconScale), AttackVector.y-(MyIcon.VL*IconScale)); //Set position to draw the bar 
				HUD.Canvas.DrawBox ( (Bar_Width-(Bar_Width/(AttackT_DecayTime/(Secs-Target_Stime)))) ,3*(HUD.Canvas.SizeY/1080)) ;//
				//BarWidth-(BarWidth/(ReloadTime[1]/AltWeaponTimeDifference)) 400/
				//Reset to non-blending white
				HUD.Canvas.SetDrawColor(255,255,255,255);
				
				//HUD.Canvas.DrawIcon(TI_Attack,AttackVector.X-32,AttackVector.Y-32); //Icon is 64x64; needs to be drawn at half of that to hit sit dead center of the target.
					}
				
				}		
			}
		
		}
		break;
	
	case "NOD":
	//Draw Attack targets (Not including buildings)
	for (i=0; i<3; i++)
		{
			if(myORI.Commander_Nod == "") continue; //Not even a commander... ignore this and don't waste time on it.
			for(j=0;j<3;j++)
			{
			if(NOD_Targets[i].T_Attack[j].T_Actor != none)
				
				//if(Rx_Pawn(NOD_Targets[i].T_Attack[j].T_Actor).Health > 0 || Rx_Vehicle(NOD_Targets[i].T_Attack[j].T_Actor)
				{
					
				bIsBehindMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(RenxHud.PlayerOwner.ViewTarget.Location,RenxHud.PlayerOwner.Rotation,NOD_Targets[i].T_Attack[j].T_Actor.location) < -0.5;
				if(!bIsBehindMe) 
					{
					
				AttackVector=HUD.Canvas.Project(NOD_Targets[i].T_Attack[j].T_Actor.location) ;
				DistanceFade = abs(round(Vsize(MidscreenVector-AttackVector)))/(MidscreenVector.X) ; //Distance from the center of the screen.. Divided by the horizontal length of the screen, as it is USUALLY more than the vertical length
				
				//Insert functionality for fading with distance/ Scrap, fade is based on proximity of crosshair to target.
				HUD.Canvas.DrawColor.A=Fmax(MinFadeAlpha, Fmin(255*DistanceFade*DistanceFadeModifier,255));
		
				HUD.Canvas.DrawIcon(MyIcon,AttackVector.X-((MyIcon.UL/2)*IconScale),AttackVector.Y-((MyIcon.VL/2)*IconScale),IconScale);
				
				HUD.Canvas.SetPos(AttackVector.x-((MyIcon.UL/6)*IconScale), AttackVector.y-MyIcon.VL/2*IconScale-8);
				HUD.Canvas.Font = Font'RenXHud.Font.ScoreBoard_Small';
				HUD.Canvas.DrawText("["$ j+1 $"]" ,true,IconScale,IconScale);
				//HUD.Canvas.DrawColor.A=Fmax(255-(NOD_Targets[i].T_Attack[j].T_Age*80)-50,0);
				
				//Draw the target's decay bar
				
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
				//MyIcon.UL/2*IconScale
				HUD.Canvas.SetPos(AttackVector.x-((MyIcon.UL/4)*IconScale), AttackVector.y-(MyIcon.VL/4)*IconScale); //Set position to draw the bar 
				//HUD.Canvas.SetPos(AttackVector.x-((MyIcon.UL/2)*IconScale), AttackVector.y-(MyIcon.VL*IconScale)); //Set position to draw the bar 
				HUD.Canvas.DrawBox( (MyIcon.UL/2-((NOD_Targets[i].T_Attack[j].T_Age/DecayBarSensitivity/AttackT_DecayTime)*(MyIcon.UL/2*IconScale))),3*(HUD.Canvas.SizeY/1080)) ;//
				
				
				//Reset to non-blending white
				HUD.Canvas.SetDrawColor(255,255,255,255);
				//HUD.Canvas.DrawIcon(TI_Attack,AttackVector.X-32,AttackVector.Y-32); //Icon is 64x64; needs to be drawn at half of that to hit sit dead center of the target.
					}
				}		
			}
		
		}
		break;
	
	}
}
	

	
simulated function DrawDefendT()
{
local Rx_HUD HUD ;
local Vector DefendVector, MidscreenVector;
local int i,j;
local bool bIsBehindMe; //Handy thing I didn't come up with for finding orientation. Yosh can't take credit for that math stuff in Rx_Utils
local CanvasIcon MyIcon;
local float IconScale, DistanceFade, MinFadeAlpha; //Distance from crosshair for drawing alpha
// ResScaleX, ResScaleY
HUD=RenxHud; 
MyIcon = TI_Defend;
IconScale=1.0; 
MidscreenVector.X=HUD.Canvas.SizeX/2;
MidscreenVector.Y=HUD.Canvas.SizeY/2;

MinFadeAlpha=100; 

switch (MyTeam) //We're pretty self sufficient, so we can just use our own variables
	{
	case "GDI":
	//Draw Defend targets (Not including buildings)
	for (i=0; i<1; i++) //just use one commander for now.
		{
			if(myORI.Commander_GDI == "" ) continue; //Not even a commander... ignore this and don't waste time on it.
			for(j=0;j<3;j++) 
			{
				
			if(GDI_Targets[i].T_Defend[j].T_Actor != none)
				
				//if(Rx_Pawn(GDI_Targets[i].T_Defend[j].T_Actor).Health > 0 || Rx_Vehicle(GDI_Targets[i].T_Defend[j].T_Actor)
				{
					
				bIsBehindMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(RenxHud.PlayerOwner.ViewTarget.Location,RenxHud.PlayerOwner.Rotation,GDI_Targets[i].T_Defend[j].T_Actor.location) < -0.5;
				if(!bIsBehindMe) 
					{
					
				DefendVector=HUD.Canvas.Project(GDI_Targets[i].T_Defend[j].T_Actor.location) ;
				DistanceFade = abs(round(Vsize(MidscreenVector-DefendVector)))/(MidscreenVector.X) ; //Distance from the center of the screen.. Divided by the horizontal length of the screen, as it is USUALLY more than the vertical length
				HUD.Canvas.SetPos(DefendVector.x, DefendVector.y);
				//Insert functionality for fading with distance/ Scrap, fade is based on proximity of crosshair to target.
				HUD.Canvas.DrawColor.A=Fmax(MinFadeAlpha, Fmin(255*DistanceFade*DistanceFadeModifier,255));
				//HUD.Canvas.DrawColor.A=Fmax(255-(GDI_Targets[i].T_Defend[j].T_Age*80)-50,0);
				HUD.Canvas.DrawIcon(MyIcon,DefendVector.X-((MyIcon.UL/2)*IconScale),DefendVector.Y-((MyIcon.UL/2)*IconScale),IconScale);
				//HUD.Canvas.DrawIcon(TI_Defend,DefendVector.X-32,DefendVector.Y-32); //Icon is 64x64; needs to be drawn at half of that to hit sit dead center of the target.
					}
				
				}		
			}
		
		}
		break;
	
	case "NOD":
	//Draw Defend targets (Not including buildings)
	for (i=0; i<3; i++) 
		{
			if(myORI.Commander_Nod == "") continue; //Not even a commander... ignore this and don't waste time on it.
			for(j=0;j<3;j++)
			{
				//don't bother if the target is behind us
				
				
			if(NOD_Targets[i].T_Defend[j].T_Actor != none)
				//if(Rx_Pawn(NOD_Targets[i].T_Defend[j].T_Actor).Health > 0 || Rx_Vehicle(NOD_Targets[i].T_Defend[j].T_Actor)
				{
				bIsBehindMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(RenxHud.PlayerOwner.ViewTarget.Location,RenxHud.PlayerOwner.Rotation,Nod_Targets[i].T_Defend[j].T_Actor.location) < -0.5;
				if(!bIsBehindMe) 
					{
				DefendVector=HUD.Canvas.Project(NOD_Targets[i].T_Defend[j].T_Actor.location) ;
				HUD.Canvas.SetPos(DefendVector.x, DefendVector.y);
				//Insert functionality for fading with distance
				DistanceFade = abs(round(Vsize(MidscreenVector-DefendVector)))/(MidscreenVector.X); 
				HUD.Canvas.DrawColor.A=Fmax(MinFadeAlpha, Fmin(255*DistanceFade*DistanceFadeModifier,255)); //Don't draw an alpha over 255, but decrease it the closer we get to the center of the screen.
				//`log("DistanceFade = "$DistanceFade);
				HUD.Canvas.DrawIcon(MyIcon,DefendVector.X-((MyIcon.UL/2)*IconScale),DefendVector.Y-((MyIcon.UL/2)*IconScale),IconScale);
				
				//HUD.Canvas.DrawIcon(TI_Defend,DefendVector.X-32,DefendVector.Y-32); //Icon is 64x64; needs to be drawn at half of that to hit sit dead center of the target.
					}
				}		
			}
		
		}
		break;
	
	}
}


simulated function DrawWayPoints()
{
local Rx_HUD HUD ;
local Vector WayPointVector, MidscreenVector;
local int i;
local bool bIsBehindMe; //Handy thing I didn't come up with for finding orientation. Yosh can't take credit for that math stuff in Rx_Utils
local CanvasIcon MyIcon;
local float IconScale, DistanceFade, MinFadeAlpha; //Distance from crosshair for drawing alpha
// ResScaleX, ResScaleY
HUD=RenxHud; 
MyIcon = TI_Defend;
IconScale=1.0; 
MidscreenVector.X=HUD.Canvas.SizeX/2;
MidscreenVector.Y=HUD.Canvas.SizeY/2;

MinFadeAlpha=100; 

switch (MyTeam) //We're pretty self sufficient, so we can just use our own variables
	{
	case "GDI":
	
	for (i=0; i<3; i++)
		{
			if(myORI.Commander_GDI == "") continue; //Not even a commander... ignore this and don't waste time on it.
				//Draw Defence Waypoint first 			
				
			if(GDI_Targets[i].T_Waypoint.X != 0 && GDI_Targets[i].T_Waypoint.Y != 0 && GDI_Targets[i].T_Waypoint.Z != 0 )
				
				//if(Rx_Pawn(GDI_Targets[i].T_Defend[j].T_Actor).Health > 0 || Rx_Vehicle(GDI_Targets[i].T_Defend[j].T_Actor)
				{
					
				bIsBehindMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(RenxHud.PlayerOwner.ViewTarget.Location,RenxHud.PlayerOwner.Rotation,GDI_Targets[i].T_Waypoint) < -0.5;
				if(!bIsBehindMe) 
					{
					
				WayPointVector=HUD.Canvas.Project(GDI_Targets[i].T_Waypoint) ;
				DistanceFade = abs(round(Vsize(MidscreenVector-WayPointVector)))/(MidscreenVector.X) ; //Distance from the center of the screen.. Divided by the horizontal length of the screen, as it is USUALLY more than the vertical length
				HUD.Canvas.SetPos(WayPointVector.x, WayPointVector.y);
				//Insert functionality for fading with distance/ Scrap, fade is based on proximity of crosshair to target.
				HUD.Canvas.DrawColor.A=Fmax(MinFadeAlpha, Fmin(255*DistanceFade*DistanceFadeModifier,255));
				//HUD.Canvas.DrawColor.A=Fmax(255-(GDI_Targets[i].T_Defend[j].T_Age*80)-50,0);
				HUD.Canvas.DrawIcon(MyIcon,WayPointVector.X-((MyIcon.UL/2)*IconScale),WayPointVector.Y-((MyIcon.UL/2)*IconScale),IconScale);
				HUD.Canvas.SetPos(WayPointVector.x-MyIcon.UL/4*IconScale, WayPointVector.y-MyIcon.VL/4*IconScale-8);
				HUD.Canvas.Font = Font'RenXHud.Font.ScoreBoard_Small';
				HUD.Canvas.DrawText("Defend [" $ round(VSize(RenxHud.PlayerOwner.Pawn.location - GDI_Targets[i].T_Waypoint)/52.5)$"m]" ,true,IconScale,IconScale);
				//HUD.Canvas.DrawIcon(TI_Defend,WayPointVector.X-32,WayPointVector.Y-32); //Icon is 64x64; needs to be drawn at half of that to hit sit dead center of the target.
					}
				
				}		
				
					//Draw Waypoints second 			
				
			if(GDI_Targets[i].T_Waypoint2.X != 0 && GDI_Targets[i].T_Waypoint2.Y != 0 && GDI_Targets[i].T_Waypoint2.Z != 0 )
				
				//if(Rx_Pawn(GDI_Targets[i].T_Defend[j].T_Actor).Health > 0 || Rx_Vehicle(GDI_Targets[i].T_Defend[j].T_Actor)
				{
					
				bIsBehindMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(RenxHud.PlayerOwner.ViewTarget.Location,RenxHud.PlayerOwner.Rotation,GDI_Targets[i].T_Waypoint2) < -0.5;
				if(!bIsBehindMe) 
					{
					
				WayPointVector=HUD.Canvas.Project(GDI_Targets[i].T_Waypoint2) ;
				DistanceFade = abs(round(Vsize(MidscreenVector-WayPointVector)))/(MidscreenVector.X) ; //Distance from the center of the screen.. Divided by the horizontal length of the screen, as it is USUALLY more than the vertical length
				HUD.Canvas.SetPos(WayPointVector.x, WayPointVector.y);
				//Insert functionality for fading with distance/ Scrap, fade is based on proximity of crosshair to target.
				HUD.Canvas.DrawColor.A=Fmax(MinFadeAlpha, Fmin(255*DistanceFade*DistanceFadeModifier,255));
				//HUD.Canvas.DrawColor.A=Fmax(255-(GDI_Targets[i].T_Defend[j].T_Age*80)-50,0);
				HUD.Canvas.DrawIcon(MyIcon,WayPointVector.X-((MyIcon.UL/2)*IconScale),WayPointVector.Y-((MyIcon.UL/2)*IconScale),IconScale);
				HUD.Canvas.SetPos(WayPointVector.x-MyIcon.UL/4*IconScale, WayPointVector.y-MyIcon.VL/4*IconScale-8);
				HUD.Canvas.Font = Font'RenXHud.Font.ScoreBoard_Small';
				HUD.Canvas.DrawText("Take [" $ round(VSize(RenxHud.PlayerOwner.Pawn.location - GDI_Targets[i].T_Waypoint2)/52.5)$"m]" ,true,IconScale,IconScale);
				//HUD.Canvas.DrawIcon(TI_Defend,WayPointVector.X-32,WayPointVector.Y-32); //Icon is 64x64; needs to be drawn at half of that to hit sit dead center of the target.
					}
				
				}
				
			
			}
		
		
		break;
	
	case "NOD":
	for (i=0; i<3; i++)
		{
			if(myORI.Commander_Nod == "") continue; //Not even a commander... ignore this and don't waste time on it.
				//Draw Defence Waypoint first 			
				
			if(NOD_Targets[i].T_Waypoint.X != 0 && NOD_Targets[i].T_Waypoint.Y != 0 && NOD_Targets[i].T_Waypoint.Z != 0 )
				
				//if(Rx_Pawn(NOD_Targets[i].T_Defend[j].T_Actor).Health > 0 || Rx_Vehicle(NOD_Targets[i].T_Defend[j].T_Actor)
				{
					
				bIsBehindMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(RenxHud.PlayerOwner.ViewTarget.Location,RenxHud.PlayerOwner.Rotation,NOD_Targets[i].T_Waypoint) < -0.5;
				if(!bIsBehindMe) 
					{
					
				WayPointVector=HUD.Canvas.Project(NOD_Targets[i].T_Waypoint) ;
				DistanceFade = abs(round(Vsize(MidscreenVector-WayPointVector)))/(MidscreenVector.X) ; //Distance from the center of the screen.. Divided by the horizontal length of the screen, as it is USUALLY more than the vertical length
				HUD.Canvas.SetPos(WayPointVector.x, WayPointVector.y);
				//Insert functionality for fading with distance/ Scrap, fade is based on proximity of crosshair to target.
				HUD.Canvas.DrawColor.A=Fmax(MinFadeAlpha, Fmin(255*DistanceFade*DistanceFadeModifier,255));
				//HUD.Canvas.DrawColor.A=Fmax(255-(NOD_Targets[i].T_Defend[j].T_Age*80)-50,0);
				HUD.Canvas.DrawIcon(MyIcon,WayPointVector.X-((MyIcon.UL/2)*IconScale),WayPointVector.Y-((MyIcon.UL/2)*IconScale),IconScale);
				HUD.Canvas.SetPos(WayPointVector.x-MyIcon.UL/4*IconScale, WayPointVector.y-MyIcon.VL/4*IconScale-8);
				HUD.Canvas.Font = Font'RenXHud.Font.ScoreBoard_Small';
				HUD.Canvas.DrawText("Defend [" $ round(VSize(RenxHud.PlayerOwner.Pawn.location - NOD_Targets[i].T_Waypoint)/52.5)$"m]" ,true,IconScale,IconScale);
				//HUD.Canvas.DrawIcon(TI_Defend,WayPointVector.X-32,WayPointVector.Y-32); //Icon is 64x64; needs to be drawn at half of that to hit sit dead center of the target.
					}
				
				}		
				
					//Draw Waypoints second 			
				
			if(NOD_Targets[i].T_Waypoint2.X != 0 && NOD_Targets[i].T_Waypoint2.Y != 0 && NOD_Targets[i].T_Waypoint2.Z != 0 )
				
				//if(Rx_Pawn(NOD_Targets[i].T_Defend[j].T_Actor).Health > 0 || Rx_Vehicle(NOD_Targets[i].T_Defend[j].T_Actor)
				{
					
				bIsBehindMe = class'Rx_Utils'.static.OrientationOfLocAndRotToBLocation(RenxHud.PlayerOwner.ViewTarget.Location,RenxHud.PlayerOwner.Rotation,NOD_Targets[i].T_Waypoint2) < -0.5;
				if(!bIsBehindMe) 
					{
					
				WayPointVector=HUD.Canvas.Project(NOD_Targets[i].T_Waypoint2) ;
				DistanceFade = abs(round(Vsize(MidscreenVector-WayPointVector)))/(MidscreenVector.X) ; //Distance from the center of the screen.. Divided by the horizontal length of the screen, as it is USUALLY more than the vertical length
				HUD.Canvas.SetPos(WayPointVector.x, WayPointVector.y);
				//Insert functionality for fading with distance/ Scrap, fade is based on proximity of crosshair to target.
				HUD.Canvas.DrawColor.A=Fmax(MinFadeAlpha, Fmin(255*DistanceFade*DistanceFadeModifier,255));
				//HUD.Canvas.DrawColor.A=Fmax(255-(NOD_Targets[i].T_Defend[j].T_Age*80)-50,0);
				HUD.Canvas.DrawIcon(MyIcon,WayPointVector.X-((MyIcon.UL/2)*IconScale),WayPointVector.Y-((MyIcon.UL/2)*IconScale),IconScale);
				HUD.Canvas.SetPos(WayPointVector.x-MyIcon.UL/4*IconScale, WayPointVector.y-MyIcon.VL/4*IconScale-8);
				HUD.Canvas.Font = Font'RenXHud.Font.ScoreBoard_Small';
				HUD.Canvas.DrawText("Take [" $ round(VSize(RenxHud.PlayerOwner.Pawn.location - NOD_Targets[i].T_Waypoint2)/52.5)$"m]",true,IconScale,IconScale);
				//HUD.Canvas.DrawIcon(TI_Defend,WayPointVector.X-32,WayPointVector.Y-32); //Icon is 64x64; needs to be drawn at half of that to hit sit dead center of the target.
					}
				
				}
				
			
			}
			
		break;
	
	}
}


simulated function float MaxofThree(float X, float Y, float Z)

{
if(X >= Fmax(Y,Z)) return X;
else
if(Y >= Fmax(X,Z)) return Y;
else
return Z;
	
}




simulated function PlayAttackUpdateMessage(string T_String, byte UByte)
{
	if(TextTimer_Warning == 0) 
			{
				
				switch(UByte)//1: Updated 2: Removed 3: Destroyed 4: Decayed 
				{
					case 1:
					RenxHud.CommandText.SetFlashText("Attack Targets Updated",Warning_Color)	; //Only sends the text once
					TextTimer_Warning = SpamTime_Warning ; //Stops being able to flood the flashing text in the middle of the screen with messages.
					break;
					
					case 2:
					RenxHud.CommandText.SetFlashText("Attack Target Removed",Warning_Color)	; //Only sends the text once
					TextTimer_Warning = SpamTime_Warning ; //Stops being able to flood the flashing text in the middle of the screen with messages.
					break;
					
					case 3:
					RenxHud.CommandText.SetFlashText("Attack Target Eliminated",Warning_Color)	; //Only sends the text once
					//Because what's better than a mega boink? A mega boink, and a mega beep. 
					break;
					
					case 4:
					RenxHud.CommandText.SetFlashText("Attack Target Decayed",Warning_Color)	; //Only sends the text once
					TextTimer_Warning = SpamTime_Warning/4 ; //Stops being able to flood the flashing text in the middle of the screen with messages.
					break;
				}
				
				
			}
}

simulated function PlayDefenceUpdateMessage(string T_String, byte UByte)
{
	if(TextTimer_Caution == 0) 
			{
				switch(UByte)//1: Updated 2: Removed 3: Destroyed 4: Decayed 
				{
					case 1:
					RenxHud.CommandText.SetFlashText("Defensive Targets Updated",Caution_Color)	; //Only sends the text once
					break;
					
					case 2:
					RenxHud.CommandText.SetFlashText("Defensive Target Removed",Caution_Color)	; //Only sends the text once
					break;
					
					case 3:
					RenxHud.CommandText.SetFlashText("Defensive Target Destroyed",Caution_Color)	; //Only sends the text once
					break;
					
					case 4:
					RenxHud.CommandText.SetFlashText("Defensive Target Decayed",Caution_Color)	; //Only sends the text once
					break;
				}	

				TextTimer_Caution = SpamTime_Caution ; //Stops being able to flood the flashing text in the middle of the screen with messages.
			}
}


simulated function PlayWaypointUpdateMessage(string T_String, byte UByte)
{
	if(TextTimer_Update == 0) 
			{
				switch(Ubyte)
				
				{
				case 0: 
				RenxHud.CommandText.SetFlashText("Waypoint Removed",Update_Color)	; //Only sends the text once
				break;
				
				case 1: 
				RenxHud.CommandText.SetFlashText("Waypoint Updated",Update_Color)	; //Only sends the text once
				break;
					
				}
				TextTimer_Update = SpamTime_Update ; //Stops being able to flood the flashing text in the middle of the screen with messages.
			}
}

simulated function PlayDWaypointUpdateMessage(string T_String, byte UByte)
{
	if(TextTimer_Update == 0) 
			{
				switch(Ubyte)
				
				{
				case 0: 
				RenxHud.CommandText.SetFlashText("Defensive Waypoint Removed",Update_Color)	; //Only sends the text once
				break;
				
				case 1: 
				RenxHud.CommandText.SetFlashText("Defensive Waypoint Updated",Update_Color)	; //Only sends the text once
				break;
					
				}
				TextTimer_Update = SpamTime_Update ; //Stops being able to flood the flashing text in the middle of the screen with messages.
			}
}

simulated function PlayCommanderLeftMessage(string T_String)
{
	if(TextTimer_Update == 0) 
			{
				RenxHud.CommandText.SetFlashText("!!!A" @T_String@ "commander has left the game!!!",Warning_Color,120)	; //Only sends the text once
				TextTimer_Update = SpamTime_Update ; //Stops being able to flood the flashing text in the middle of the screen with messages.
			}
}

simulated function PlayCommanderUpdateMessage(string T_String, int rank)
{
	if(T_String == "GDI")
	{
	
	if(TextTimer_Update == 0) 
			{
					switch(rank)
					{
					case 0:
					RenxHud.CommandText.SetFlashText(myORI.Commander_GDI $" is now" @T_String$ "'s COMMANDER",Update_Color,120, 1.5)	;
					break;
		
					case 1:
					RenxHud.CommandText.SetFlashText(myORI.Commander_GDI $" is now " @T_String$ "'s CO-COMMANDER",Update_Color,120,1.5)	;
					break;
			
					case 2:
					RenxHud.CommandText.SetFlashText(myORI.Commander_GDI $" is now " @T_String$ "'s SUPPORT commander",Update_Color,120, 1.5)	;
					break;
					}
				TextTimer_Update = SpamTime_Update ; //Stops being able to flood the flashing text in the middle of the screen with messages.
			}
	}
	
	if(T_String == "NOD")
	
	if(TextTimer_Update == 0) 
			{
					switch(rank)
					{
					case 0:
					RenxHud.CommandText.SetFlashText(myORI.Commander_Nod$" is now" @T_String$ "'s COMMANDER",Update_Color,120, 1.5)	;
					break;
		
					case 1:
					RenxHud.CommandText.SetFlashText(myORI.Commander_Nod$" is now " @T_String$ "'s CO-COMMANDER",Update_Color,120, 1.5)	;
					break;
			
					case 2:
					RenxHud.CommandText.SetFlashText(myORI.Commander_Nod$" is now " @T_String$ "'s SUPPORT commander",Update_Color,120, 1.5)	;
					break;
					}
				TextTimer_Update = SpamTime_Update ; //Stops being able to flood the flashing text in the middle of the screen with messages.
			}
	
}

simulated function ControlPulse()
{
	if(!IconPulseFlipped) IconPulse+=IconPulseRate;
	if(IconPulseFlipped) IconPulse-=IconPulseRate;

	if(IconPulse >= IconPulseMax) IconPulseFlipped = true ;
	if(IconPulse <= IconPulseMin) IconPulseFlipped = false; 
	
	
}


//My actual Draw Call
function Draw()
{
RenxHud.Canvas.SetDrawColor(255,255,255,255); //We don't blend around these parts (Alpha blending may occur in functions)
DrawAttackT();
DrawDefendT();
//DrawRepairT();
DrawWayPoints();
//DrawBuildingAttackTargets();
//DrawBuildingDefendTargets();
//DrawBuildingRepairTargets();
}

simulated function SpamTimerHandler ()
{
if(TextTimer_Caution > 0) TextTimer_Caution-- ;
if(TextTimer_Warning > 0 ) TextTimer_Warning-- ;
if(TextTimer_Update > 0 ) TextTimer_Update-- ;
if(TextTimer_Announcment > 0 ) TextTimer_Announcment-- ;	

if(TextTimer_Caution < 0) TextTimer_Caution=0 ;
if(TextTimer_Warning < 0 ) TextTimer_Warning=0 ;
if(TextTimer_Update < 0 ) TextTimer_Update=0 ;
if(TextTimer_Announcment < 0 ) TextTimer_Announcment=0 ;	
	
}




simulated function UpdateTargets(Actor Act, int Team, int Target_Type, int TargetNum, optional int rank = 0)
{
	local int Secs; 
	
	Secs=RenxHud.PlayerOwner.WorldInfo.TimeSeconds;
	
	if(Team == 0) 
	{
		switch (Target_Type)
		{
		case 0: //attack
		GDI_Targets[rank].T_Attack[TargetNum].T_Actor=Act; 
		GDI_Targets[rank].T_Attack[TargetNum].T_StartTime=Secs; 
		break;
		
		case 1: //defend
		GDI_Targets[rank].T_Defend[TargetNum].T_Actor=Act; 
		default: 
		break;
		}
	}
	
	if(Team == 1) 
	{
		switch (Target_Type)
		{
		case 0: //attack
		Nod_Targets[rank].T_Attack[TargetNum].T_Actor=Act; 
		Nod_Targets[rank].T_Attack[TargetNum].T_StartTime=Secs; //Init time to be used for decay 
		break;
		
		case 1: //defend
		Nod_Targets[rank].T_Defend[TargetNum].T_Actor=Act; 
		default: 
		break;
		}
	}
	
}

simulated function NotifyTargetDecayed(Actor SentActor)
{
	local int i, j;
	
	i=0; 
	
	//Iterate GDI targets to find the target
		for(j=0;j<3;j++)
				{
				if(GDI_Targets[i].T_Attack[j].T_Actor == SentActor) 
					{
					//Found; reset this target
					`log("--YL-- Target Decayed " @ SentActor);
					GDI_Targets[i].T_Attack[j].T_Actor = none;
					GDI_Targets[i].T_Attack[j].T_Age=0;
					 //0: Updated 1: Removed 2: Destroyed 3: Decayed 
					GDI_Targets[i].T_Attack[j].T_StartTime = 0;
					if(RenxHud.PlayerOwner.GetTeamNum() == 0) PlayAttackUpdateMessage("GDI", 4);
					break; 
					}	
				else
				if(GDI_Targets[i].T_Defend[j].T_Actor == SentActor) 
					{
					//Found; reset this target
					GDI_Targets[i].T_Defend[j].T_Actor = none;
					GDI_Targets[i].T_Defend[j].T_StartTime = 0;
					 //0: Updated 1: Removed 2: Destroyed 3: Decayed 
					if(RenxHud.PlayerOwner.GetTeamNum() == 0) PlayDefenceUpdateMessage("GDI", 4);
					
					break; 
					}	
					else
					continue;
				}
			//Iterate Nod Targets to find the target if it exists there
				
			for(i=0;i<3;i++)
				{
				if(Nod_Targets[i].T_Attack[j].T_Actor == SentActor) 
					{
					//Found; reset this target
					Nod_Targets[i].T_Attack[j].T_Actor = none;
					
					 //0: Updated 1: Removed 2: Destroyed 3: Decayed 
					 if(RenxHud.PlayerOwner.GetTeamNum() == 1) PlayAttackUpdateMessage("Nod", 4);
					 
					Nod_Targets[i].T_Attack[j].T_StartTime = 0;
					break; 
					}	
				else
					if(Nod_Targets[i].T_Defend[j].T_Actor == SentActor) 
					{
					//Found; reset this target
					Nod_Targets[i].T_Defend[j].T_Actor = none;
					Nod_Targets[i].T_Defend[j].T_StartTime = 0;
					
					 //0: Updated 1: Removed 2: Destroyed 3: Decayed 
					 if(RenxHud.PlayerOwner.GetTeamNum() == 1) PlayDefenceUpdateMessage("Nod", 4);
					 
					
					break; 
					}
				else
				continue;
				}		
}

simulated function NotifyTargetKilled(Actor SentActor)
{
	local int i, j;
	
	i=0; 
	
	//Iterate GDI targets to find the target
		for(j=0;j<3;j++)
				{
				if(GDI_Targets[i].T_Attack[j].T_Actor == SentActor) 
					{
					//Found; reset this target
					`log("--YL-- Target Decayed " @ SentActor);
					GDI_Targets[i].T_Attack[j].T_Actor = none;
					 //0: Updated 1: Removed 2: Destroyed 3: Decayed 
					GDI_Targets[i].T_Attack[j].T_StartTime = 0;
					if(RenxHud.PlayerOwner.GetTeamNum() == 0) PlayAttackUpdateMessage("GDI", 3);
					break; 
					}	
				else
				if(GDI_Targets[i].T_Defend[j].T_Actor == SentActor) 
					{
					//Found; reset this target
					GDI_Targets[i].T_Defend[j].T_Actor = none;
					GDI_Targets[i].T_Defend[j].T_Age=0;
					GDI_Targets[i].T_Defend[j].T_StartTime = 0;
					 //0: Updated 1: Removed 2: Destroyed 3: Decayed 
					if(RenxHud.PlayerOwner.GetTeamNum() == 0) PlayDefenceUpdateMessage("GDI", 3);
					
					break; 
					}	
					else
					continue;
				}
			//Iterate Nod Targets to find the target if it exists there
				
			for(i=0;i<3;i++)
				{
				if(Nod_Targets[i].T_Attack[j].T_Actor == SentActor) 
					{
					//Found; reset this target
					Nod_Targets[i].T_Attack[j].T_Actor = none;
					Nod_Targets[i].T_Attack[j].T_Age=0;
					
					 //0: Updated 1: Removed 2: Destroyed 3: Decayed 
					 if(RenxHud.PlayerOwner.GetTeamNum() == 1) PlayAttackUpdateMessage("Nod", 3);
					 
					Nod_Targets[i].T_Attack[j].T_StartTime = 0;
					break; 
					}	
				else
					if(Nod_Targets[i].T_Defend[j].T_Actor == SentActor) 
					{
					//Found; reset this target
					Nod_Targets[i].T_Defend[j].T_Actor = none;
					Nod_Targets[i].T_Defend[j].T_Age=0;
					Nod_Targets[i].T_Defend[j].T_StartTime = 0;
					
					 //0: Updated 1: Removed 2: Destroyed 3: Decayed 
					 if(RenxHud.PlayerOwner.GetTeamNum() == 1) PlayDefenceUpdateMessage("Nod", 3);
					 
					
					break; 
					}
				else
				continue;
				}		
}
simulated function UpdateGDICommander() ;
simulated function UpdateNodCommander() ;
	


DefaultProperties 
{
	//MinFadeAlpha=50
	
	AttackT_DecayTime = 25 // ORI Attack Target Decay time * 20 (ticks)
	DecayBarSensitivity=1.1
	DistanceFadeModifier = 3 //Higher numbers make targets fade less depending on distance to the middle of the screen.
	BuildingTargetZOffset = 250
	
	
	TI_Attack=(Texture = Texture2D'RenXTargetSystem.T_NavMarker_Max_Red', U= 0, V = 0, UL = 64, VL = 64) 	
	TI_Defend= (Texture = Texture2D'RenXTargetSystem.T_NavMarker_Mini_Green', U= 0, V = 0, UL = 64, VL = 64)// 24x24
	TI_Repair=(Texture = Texture2D'RenXPurchaseMenu.T_Icon_Item_MechanicalKit', U= 96, V = 32, UL = 64, VL = 64) //Texture is 256x128	
	TI_Waypoint=(Texture = Texture2D'RenXTargetSystem.T_NavMarker_Mini_Blue', U= 0, V = 0, UL = 32, VL = 64) 	//Texture is 32x64	
	
	
	//////Variables to make icons pulse//////////
	IconPulse=1
	IconPulseRate=0.015
	IconPulseFlipped=false
	IconPulseMin = 0.90
	IconPulseMax = 1.10 
	/////////////////Anti-spam timers///////////////////////

SpamTime_Announcment = 60 
SpamTime_Caution = 30
SpamTime_Update = 30
SpamTime_Warning = 30

TextTimer_Caution = 0
TextTimer_Warning = 0
TextTimer_Update = 0
TextTimer_Announcment = 0

//////////////////COLORS///////////////////////////

Warning_Color=(R = 255, G = 0, B = 50, A = 255) //Red with a bit of blue

Caution_Color=(R= 255, G=255, B=50, A=255) //Yellow

Update_Color=(R= 0, G=255, B=50, A=255) //Green with a bit of blue

Announcment_Color =  (R=90 , G=255, B=250, A=255) //sky blue
	
	
	
}