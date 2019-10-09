class Rx_HUD_CTextComponent extends Rx_HUD_Component ; 

struct TextLine
{

	var float 	FlashTextSize	;			
	var color 	FlashTextColor, ColorBlack	;
	var string 	FlashTextStr	;									
	var int 	NumLoops		;										
	var float 	FlashTextCycler; 
	var bool	bCommandMessage; 	


structdefaultproperties
{
	FlashTextSize=0									
	FlashTextColor=(R=255, G=255, B=255, A = 255)											
	FlashTextStr="NULL"							
	
}
};

var font CText_Text;

var array<TextLine>	DisplayText						; 
var int		 		MaxMessageNum, TickCycler					; 

var float			FlashTextIncrement; //Speed at which to count down to message deletion
var color ColorBlack, ColorSkyBlue, ColorWarningRed 								;



var Texture TextBG									;
var Texture GDILogo									;
var Texture NodLogo 								;

var SoundCue UpdateBeepSnd							;
var SoundCue WarningBeepSnd							;
var vector2d TestGlowRadius							;

function Update(float DeltaTime, Rx_HUD HUD) 
{
	local int i;
	
	super.Update(DeltaTime, HUD);
		
	
	
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
if(DisplayText[Line].FlashTextCycler <= 0) 
{
	DisplayText[Line].FlashTextCycler=0	;				;
	DisplayText[Line].FlashTextStr="NULL";
}	

//if Cycler is over 0 and not flipped, it should increment down
if(DisplayText[Line].FlashTextCycler > 0) {
	//`log("Trying to Increment down") ; 
	DisplayText[Line].FlashTextCycler-=FlashTextIncrement*DeltaTime 			; 
}

//If we're looping, then run it back. If not, erase the string 
	
if(Line >= MaxMessageNum) //I should be gotten rid of now
	{
		DisplayText[Line].FlashTextCycler=0					;
		DisplayText[Line].FlashTextStr="NULL"				;
	}
}

function DrawFlashText() //Still not certain why I kept Team around... but it's there. It takes "GDI" and "Nod"... but they don't really matter
{
	local color OldColor;
	local FontRenderInfo FontInfo;
	local font OldFont;
	local float OldX,OldY, OldClipX;
	local float TextL, TextH, CCenterX,CCenterY, TextScaleX, TextScaleY, DrawX, DrawY, ResScaleX, ResScaleY;
	local int i, NumCommandMessages ;
	
	NumCommandMessages = 1 ; 
			
	ResScaleX = Canvas.SizeX/1920.0				;
	ResScaleY = Canvas.SizeY/1080.0				;
	//ResMod=ResScaleY							;
	OldX=Canvas.CurX							;
	OldY=Canvas.CurY							;
	OldClipX=Canvas.ClipX						;
	OldColor = Canvas.DrawColor 				; 
	OldFont = Canvas.Font						;	
	
	Canvas.Font = CText_Text	;
	CCenterX = Canvas.SizeX/2.0					;
	CCenterY = Canvas.SizeY/2.0					;
	
	
	
	for(i=0;i<DisplayText.Length;i++)
	{

		if(DisplayText[i].FlashTextStr== "NULL") continue;

		
		TextScaleX = DisplayText[i].FlashTextSize*ResScaleX							;
		TextScaleY = DisplayText[i].FlashTextsize*ResScaleY							;
		
		
		Canvas.StrLen(DisplayText[i].FlashTextStr,TextL,TextH)		;
		
		DrawX = CCenterX - ((TextL/2.0)*TextScaleX)	;
		if(!DisplayText[i].bCommandMessage) DrawY = CCenterY - ((CCenterY/1.4)+(TextH*TextScaleY+2*ResScaleY)*i)			;
		else
		{
			if(NumCommandMessages > 2) continue; 
			DrawY = CCenterY - ((CCenterY/2.0)+(TextH*TextScaleY+2*ResScaleY)*NumCommandMessages) ;
			NumCommandMessages++; 
		}	
		
		//Draw Background
		Canvas.DrawColor=ColorBlack 	;
		Canvas.DrawColor.A=128			;
		Canvas.SetPos(DrawX-(100*ResScaleX),DrawY)		; //Draw off to the left edge of where the text will be.  

		Canvas.DrawRect((TextL*TextScaleX+(190*ResScaleX) ),TextH*TextScaleY+(2*ResScaleY), TextBG) ; //Rectangle should hang off of both sides.
		
		//Draw Text
		Canvas.SetPos(DrawX,DrawY)				;
		Canvas.DrawColor=DisplayText[i].FlashTextColor 		;
		Canvas.ClipX=Canvas.SizeX-400*ResScaleX		;
		
		FontInfo = Canvas.CreateFontRenderInfo(false);
		FontInfo.bClipText = false; //Why is this on twice? Screw it, I copied this over since I haven't messed with fontinfo in a long time.
		
		FontInfo.GlowInfo.GlowColor = MakeLinearColor(0.0, 0.0, 0.0, 1.0);
		TestGlowRadius.X=4.0;
		TestGlowRadius.Y=4.0;
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
function SetFlashText(string TEXT,color C,optional float TIME = 60, optional float Size = 1.0, optional bool bCommanderMessage, optional bool bWarning)
{
	local TextLine MSG;
	//Set this to false just to clear any other text that may be looping at the time	
	MSG.FlashTextColor=C ;						
	MSG.FlashTextStr=TEXT;	
	MSG.FlashTextSize=Size;	
	MSG.FlashTextCycler=TIME;				
	MSG.bCommandMessage = bCommanderMessage; 
	
	DisplayText.InsertItem(0,MSG) ;
	
	if(RenxHud == None) 
		return;
	
	if(bWarning)
		RenxHud.PlayerOwner.ClientPlaySound(WarningBeepSnd) ;
	else
		RenxHud.PlayerOwner.ClientPlaySound(UpdateBeepSnd) ;
}


function Draw() {

if(DisplayText.Length > 0) DrawFlashText() ;
//if(FlashTextStr !="" && FlashTextStr !=" " && FlashTextStr !="NULL") DrawFlashText(MyTeam) ;
}
//End of this flashing Text shit////////////////////////////////////////////////////////////////////////////

DefaultProperties
 {


	ColorBlack = (R=0, G=0, B = 0, A = 255)
	ColorSkyBlue = (R=175, G=255, B = 255, A = 255)
	ColorWarningRed = (R=255, G=80, B = 80, A = 255)

	TextBG = Texture2D'RenXPauseMenu.RenXPauseMenu_I14D'

	CText_Text=Font'RenxHud.Font.CTextFont24pt'; //CText_Text=Font'RenxHud.Font.CText_Agency32pt' ;

	TestGlowRadius = (X=2.0,Y=2.0)
	MaxMessageNum = 4

	GDILogo = Texture2D'RenXScoreboard.T_BGLogo_GDI'						

	NodLogo = Texture2D'RenXScoreboard.T_BGLogo_Nod'					

	UpdateBeepSnd = SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundTest1_Cue'	
	WarningBeepSnd = SoundCue'RX_WP_IonCannon.Sounds.SC_StrikImminent_Siren'
	
	FlashTextIncrement = 29
}