class Rx_HUD_CTextComponent extends Rx_HUD_Component ; 

struct TextLine
{

var float 	FlashTextIncrement, FlashTextCycler, MaxCyclerTime,FlashTextSize		;
var byte 	MaxFlashAlpha, MinFlashAlpha, FlashTextAlpha	;
var bool 	bFlashTextLooping, bCycler_Flipped						;			
var color 	FlashTextColor, ColorBlack	;
var string 	FlashTextStr											;
var int 	NumLoops													;




structdefaultproperties
{
FlashTextIncrement=29
NumLoops=0	
FlashTextCycler=0
MaxCyclerTime=1		
MaxFlashAlpha=0 
MinFlashAlpha=0 
FlashTextAlpha=0	
FlashTextSize=0		
bFlashTextLooping=false
bCycler_Flipped=false									
FlashTextColor=(R=255, G=255, B=255, A = 255)											
FlashTextStr="NULL"							
	
}
};
var float TestGlowX,TestGlowY ;
var Vector2D TestGlowRadius;
var font CText_Text;


var array<TextLine>	DisplayText						; 
var int		 		MaxMessageNum, TickCycler					; 

var color ColorBlack, ColorSkyBlue, ColorWarningRed 								;



var Texture TextBG									;
var Texture GDILogo									;
var Texture NodLogo 								;
var string MyTeam													;
var SoundCue UpdateBeepSnd							;

var float TestNum									; 

function Update(float DeltaTime, Rx_HUD HUD) 
{
	local int T, i;
	
	super.Update(DeltaTime, HUD);
		
	//Get mah team
	T=RenxHud.PlayerOwner.GetTeamNum() ;
	
	switch(T) 
	{
		case 0 : 
		MyTeam = "GDI";
		break;
		
		case 1 :
		MyTeam = "Nod" ;
		break;
	}
	
//set the timer to update flashing text
for(i=0;i<DisplayText.Length;i++)
	{
	if(DisplayText[i].FlashTextStr=="NULL") 
		{
		DisplayText.Remove(i,1);
		continue;
		}
	UpdateFlashVars(i, DeltaTime);
	}
	
}



simulated function UpdateFlashVars(int Line, float DeltaTime)
{

//Block of statements to make the text just flash back and forth

//If less than zero, make it 0
if(DisplayText[Line].FlashTextCycler < 0) DisplayText[Line].FlashTextCycler = 0													;			

//if Cycler is over 0 and not flipped, it should increment down
if(DisplayText[Line].FlashTextCycler > 0 && !DisplayText[Line].bCycler_Flipped) {
	//`log("Trying to Increment down") ; 
	DisplayText[Line].FlashTextCycler-=DisplayText[Line].FlashTextIncrement*DeltaTime 			; 
}
//If we are flipped and beneath the Max time for the current text, increment back up
if(DisplayText[Line].FlashTextCycler < DisplayText[Line].MaxCyclerTime && DisplayText[Line].bCycler_Flipped){

//`log("DeltaTime"@ DeltaTime) ; 
	DisplayText[Line].FlashTextCycler+=DisplayText[Line].FlashTextIncrement*DeltaTime	;
}
//If we go over the max time, flip us back around and beep
if(DisplayText[Line].FlashTextCycler >= DisplayText[Line].MaxCyclerTime) {
	DisplayText[Line].bCycler_Flipped = false ;
	//RenxHud.PlayerOwner.ClientPlaySound(UpdateBeepSnd) ;	3 messages beeping is too damn much.
}
//If we're looping, then run it back. If not, erase the string 
if(DisplayText[Line].FlashTextCycler <= 0 && DisplayText[Line].bFlashTextLooping && DisplayText[Line].Numloops > 0)
	{ 


	
	DisplayText[Line].bCycler_Flipped = true 	;
	DisplayText[Line].NumLoops -=1 			;
	}					

	if(DisplayText[Line].FlashTextCycler <= 0 && DisplayText[Line].bFlashTextLooping && DisplayText[Line].Numloops <= 0)
	{ 

	DisplayText[Line].FlashTextCycler=0					;
	DisplayText[Line].FlashTextStr="NULL"						;
	}					
	
if(DisplayText[Line].FlashTextCycler <= 0 && !DisplayText[Line].bFlashTextLooping)
	{
	DisplayText[Line].FlashTextCycler=0					;
	DisplayText[Line].FlashTextStr="NULL"					;
	}
	
if(Line >= MaxMessageNum) //I should be gotten rid of now
	{
	DisplayText[Line].FlashTextCycler=0					;
	DisplayText[Line].FlashTextStr="NULL"					;
	}

	
DisplayText[Line].FlashTextAlpha=Fmax(	(round(DisplayText[Line].MaxFlashAlpha/((DisplayText[Line].MaxCyclerTime-DisplayText[Line].FlashTextCycler+1)/4))), DisplayText[Line].MinFlashAlpha )					;
}

function DrawFlashText(string Team) //Still not certain why I kept Team around... but it's there. It takes "GDI" and "Nod"... but they don't really matter
{
	local color OldColor;
	local FontRenderInfo FontInfo;
	local font OldFont;
	local float OldX,OldY, OldClipX;
	local float ResMod;
	local float TextL, TextH, CCenterX,CCenterY, TextScaleX, TextScaleY, DrawX, DrawY, ResScaleX, ResScaleY;
	local int i ;

		//Support for crap resolutions, so the message isn't OMGWTF WHOLE SCREEN
	
	
	if(Canvas.SizeY <= 610) ResMod=0.60; //Fuck you for making me need to even consider this, Hande..
	else
	if(Canvas.SizeY <= 810) ResMod=0.80;
	else
	ResMod=1						; //Our resolution modifier for text scaling. 
	

	
	
	
	ResScaleX = Canvas.SizeX/1920.0				;
	ResScaleY = Canvas.SizeY/1080.0				;
	//ResMod=ResScaleY							;
	OldX=Canvas.CurX							;
	OldY=Canvas.CurY							;
	OldClipX=Canvas.ClipX						;
	OldColor = Canvas.DrawColor 				; 
	OldFont = Canvas.Font						;	
	
	Canvas.Font = CText_Text	;
	CCenterX = Canvas.SizeX/2					;
	CCenterY = Canvas.SizeY/2					;
	
	
	
	for(i=0;i<DisplayText.Length;i++)
	{

	if(DisplayText[i].FlashTextStr== "NULL") continue;

	
	TextScaleX = DisplayText[i].FlashTextSize*ResMod							;
	TextScaleY = DisplayText[i].FlashTextsize*ResMod							;
	
	
	Canvas.StrLen(DisplayText[i].FlashTextStr,TextL,TextH)		;
	
	DrawX = CCenterX - ((TextL/2)*TextScaleX)	;
	DrawY = CCenterY - ((CCenterY/1.4)+(TextH*TextScaleY+2*ResScaleY)*i)			;
	//Don't blend the textured rectangle with any color
		//`log("DrawX: " @ DrawX @ "DrawY: " @ DrawY @ "ResScaleX: " @ ResScaleX @ "ResScaleY: " @ ResScaleY );
	
	//Canvas.DrawTile(Texture2D'RenXScoreboard.T_BGLogo_GDI', 64*ResScaleX, 64*ResScaleY, 200, 200,600, 600)	;
	//Canvas.DrawRect((32*ResScaleX*TextScaleX),(32*ResScaleY*TextScaleY)) ;
	
	//Draw Background
	Canvas.DrawColor=ColorBlack 	;
	Canvas.DrawColor.A=128			;
	Canvas.SetPos(DrawX-(100*ResScaleX),DrawY)		; //Draw off to the left edge of where the text will be.  

	Canvas.DrawRect((TextL*TextScaleX+(190*ResScaleX) ),TextH*TextScaleY+(2*ResScaleY), TextBG) ; //Rectangle should hang off of both sides.
	//Canvas.DrawRect(TextL*TextScaleX+(200*ResScaleX),TextH*TextScaleY+(5*ResScaleY), TextBG) ;
	//Canvas.SetPos(DrawX -(100*ResScaleX),DrawY-(5*ResScaleY))	;
	//Canvas.DrawRect(TextL*TextScaleX,TextH*TextScaleY, TextBG) ;
	
	
	//Draw Flashing text
	Canvas.SetPos(DrawX,DrawY)				;
	Canvas.DrawColor=DisplayText[i].FlashTextColor 		;
	Canvas.DrawColor.A=DisplayText[i].FlashTextAlpha		;
	Canvas.ClipX=Canvas.SizeX-400*ResScaleX		;
	
	FontInfo = Canvas.CreateFontRenderInfo(false);
    FontInfo.bClipText = false; //Why is this on twice? Screw it, I copied this over since I haven't messed with fontinfo in a long time.
	
	FontInfo.GlowInfo.GlowColor = MakeLinearColor(0.0, 0.0, 0.0, 1.0);
    TestGlowRadius.X=TestGlowX;
    TestGlowRadius.Y=TestGlowY;
    FontInfo.GlowInfo.bEnableGlow = true;
    FontInfo.GlowInfo.GlowOuterRadius = TestGlowRadius;	

	Canvas.DrawText(DisplayText[i].FlashTextStr,false,TextScaleX,TextScaleY, FontInfo)			;
	
	Canvas.SetPos(DrawX,DrawY)				; //draw glow mask
	Canvas.DrawColor=MakeColor(255,255,255,255)		;
	Canvas.DrawColor.A=128		;
	Canvas.DrawText(DisplayText[i].FlashTextStr,false,TextScaleX,TextScaleY, FontInfo)			;
	
	}
Canvas.DrawColor = OldColor		;
Canvas.Font 	 = OldFont		;	
Canvas.ClipX 	= OldClipX		;
Canvas.SetPos(OldX,OldY)		;
}


//Function that flashes text in the middle-top of the screen for a certain amount of time.
//Team, the first argument literally does not matter right now (Leaving it around on the off chance it becomes a necessity).
function SetFlashText(string Team, float TIME, string TEXT,color C,byte Alpha_MIN, byte Alpha_MAX, bool LOOP, optional int LOOPNUM = 1, optional float Size = 0.75)
{
local TextLine MSG;
//Set this to false just to clear any other text that may be looping at the time	
MSG.FlashTextColor=C ;					
MSG.FlashTextAlpha=Alpha_Max;			
MSG.MinFlashAlpha=Alpha_MIN;				
MSG.MaxFlashAlpha = Alpha_Max;			
MSG.FlashTextStr=TEXT;	
MSG.FlashTextSize=Size;	
MSG.FlashTextCycler=TIME;				
MSG.MaxCyclerTime=TIME;				
MSG.bFlashTextLooping=LOOP;			
MSG.NumLoops=LOOPNUM;			


DisplayText.InsertItem(0,MSG) ;

RenxHud.PlayerOwner.ClientPlaySound(UpdateBeepSnd) ;

}

function Draw() {

if(DisplayText.Length > 0) DrawFlashText(MyTeam) ;
//if(FlashTextStr !="" && FlashTextStr !=" " && FlashTextStr !="NULL") DrawFlashText(MyTeam) ;
}
//End of this flashing Text shit////////////////////////////////////////////////////////////////////////////

DefaultProperties
 {
	
MyTeam = ""

ColorBlack = (R=0, G=0, B = 0, A = 255)
ColorSkyBlue = (R=175, G=255, B = 255, A = 255)
ColorWarningRed = (R=255, G=80, B = 80, A = 255)



TextBG = Texture2D'RenXPauseMenu.RenXPauseMenu_I14D'

CText_Text=Font'RenxHud.Font.CTextFont24pt'; //CText_Text=Font'RenxHud.Font.CText_Agency32pt' ;

TestGlowX = 4.0
TestGlowY = 4.0
TestGlowRadius = (X=2.0,Y=2.0)
MaxMessageNum = 4

GDILogo = Texture2D'RenXScoreboard.T_BGLogo_GDI'						

NodLogo = Texture2D'RenXScoreboard.T_BGLogo_Nod'					

UpdateBeepSnd = SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundTest1_Cue'	

TestNum = 150
}