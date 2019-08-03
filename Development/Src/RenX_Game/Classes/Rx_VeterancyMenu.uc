class Rx_VeterancyMenu extends Rx_HUD_Component ;

var float PeelFadeSpeed, PeelX, PeelIncrement; 
var int Primary_AnchorX,Primary_AnchorY, Number_AnchorX, Number_AnchorY, FadedTileAlpha, TileMaxAlpha; //Where we draw our 3 tiles and their numbers
var float	ResScaleX, ResScaleY, TextScale;
/******************/
//Our 3 tiles 
var int Tile_Spacing;  

struct VTile
{
var bool bEnabled; //Enabled draws fully. Setting to false leaves it greyed out. 
var int TileAlpha;
var bool bVisible; //Controls if the tile should even be drawn at all

structDefaultproperties 
	{
	bEnabled = true
	TileAlpha=255	
	bVisible= true 
	}
};

var CanvasIcon Veteran_Tile[3];

var VTile VPTiles[3];

var bool bPeeling, bDead;
var float TileScale;
/******************/
var class<Rx_FamilyInfo> InfantryInfo;  
var class<Rx_Vehicle> VehicleInfo;
var Rx_Controller Control;
var Rx_PRI PRI; 
var byte VRank; 

//Number cost 
var int VPCost[3];  

var SoundCue Success_Snd, Failed_Snd; 

function PeelOff()
{
	local int i; 
	bPeeling=true; 

for(i=0;i<3;i++)
	{
	VPTiles[i].bEnabled=false;
	}

}

function bool Init(Rx_Controller PC, bool PlayerInVehicle)
{

local int i;
 
Control=PC; 
PRI = Rx_PRI(Control.PlayerReplicationInfo) ; 

if(PlayerInVehicle) VRank = Rx_Vehicle(PC.Pawn).VRank;
else 
VRank = Rx_Pawn(PC.Pawn).VRank;


//set Icons 


	if(PlayerInVehicle) VehicleInfo = class<Rx_Vehicle>(Control.Pawn.class);
	else 
	{
	InfantryInfo = class<Rx_FamilyInfo>(PRI.CharClassInfo); 
	}
	
	if(VehicleInfo == none && InfantryInfo == none) return false; //failed 
	else
	{
		
		//Enable tiles 
		for(i=0;i<3;i++)
		{
		VPTiles[i].bEnabled=false;
		}

		
		//set the VP cost numbers
		if(PlayerInVehicle) 
			{
			for(i=0;i<3;i++)
				{
				switch(VRank)
					{
					case 0:
					VPCost[i] = Fmax(0,VehicleInfo.default.VPCost[i]); 
					
					break; 
					case 1:
					VPCost[i] = Fmax(0,VehicleInfo.default.VPCost[i]-VehicleInfo.default.VPCost[0]); 
					
					break; 
					case 2:
					VPCost[i] = Fmax(0,VehicleInfo.default.VPCost[i]-VehicleInfo.default.VPCost[1]) ;
					//VPCost[i] = Fmax(0,VehicleInfo.default.VPCost[i]-(VehicleInfo.default.VPCost[1]-VehicleInfo.default.VPCost[0])) ; 
					break;
					
					default:
					VPCost[i] = 0; 
					break;
					}
				} 
			}
			else
			{
			for(i=0;i<3;i++)
				{
					switch(VRank)
					{
					case 0:
					VPCost[i] = Fmax(0,InfantryInfo.default.VPCost[i]); 
					break; 
					case 1:
					VPCost[i] = Fmax(0,InfantryInfo.default.VPCost[i]-InfantryInfo.default.VPCost[0]); 
					break; 
					case 2:
					VPCost[i] = Fmax(0,InfantryInfo.default.VPCost[i]-InfantryInfo.default.VPCost[1]); 
					//VPCost[i] = Fmax(0,InfantryInfo.default.VPCost[i]-(InfantryInfo.default.VPCost[1]+InfantryInfo.default.VPCost[0])); 
					break;
					
					default:
					VPCost[i] = 0; 
					break;
					}
				} 
			}
		
		UpdateTileStatus();
		return true; 
	}
	
}

function ParseInput(byte T)
{
//`log("MAde it to PArseInput"); 
if(bPeeling || (T > 3 || T <= 0) ) return; 
//`log("Respond Input") ;
updateTileStatus(); //Update tile transparencies. 
//Check

//We already at or above this rank?
if(VRank >= T) 
	{
	`log("Return due to equality of VRank and T ");
	Control.ClientPlaySound(Failed_Snd);
	return;
	}
//Do we have enough VP ? 
T-=1; //Convert for everything else's sake
//`log("Buy " @ VPCost[T] @ "With" @ PRI.Veterancy_Points); 


 
if(VPCost[T] <= PRI.Veterancy_Points) TryToBuy(T,VPCost[T]); 

}

function UpdateTileStatus()
{
	local int i; 
	
	if(InfantryInfo != none) VRank = Rx_Pawn(Control.Pawn).VRank;
	else
	if(VehicleInfo != none) VRank = Rx_Vehicle(Control.Pawn).VRank;
	
	for(i=0;i<3;i++)
	{
		//`log("VP enabled :" @ i @ VPTiles[i].bEnabled);
	if(VPCost[i] > PRI.Veterancy_Points || VRank >= i+1) 
		{
		VPTiles[i].bEnabled=false; 
		VPTiles[i].TileAlpha=FadedTileAlpha;
		}
	else
		{
		VPTiles[i].TileAlpha=TileMaxAlpha; 
		VPTiles[i].bEnabled=true; 
		}
	}
}

function TryToBuy(byte Iterator,int Cost ) 
{
	Control.BuyRank(Iterator, Cost);  
}

function UpdateTiles(float DeltaTime, Rx_HUD HUD)
{
	local int i;
	
	
if(bDead) return;
 
ResScaleX = HUD.Canvas.SizeX/1280.0;
ResScaleY = HUD.Canvas.SizeY/720.0;
	
	
	
	for(i=0;i<3;i++)
	
	{
	
		if(bPeeling && VPTiles[i].bVisible) 
			{
				PeelX+=PeelIncrement+DeltaTime; // 
				VPTiles[i].TileAlpha -= PeelFadeSpeed+DeltaTime;//*DeltaTime;
				if(VPTiles[i].TileAlpha <= 5) //Zeroize
				{
					VPTiles[i].bVisible=false; 
					//bDead=true; 
					//Control = none;
					PRI = none; 
				}
				continue; //Stop there... we're fading away.
			}
		
	}
	
}

function DrawTiles(Rx_HUD HUD)
{
	local int i, TempAlpha, TilesDrawn;
	local float x, y, XL, YL;
	local CanvasIcon TempIcon; 
//Fade out and such
	if(bDead) return; 
	
	x = Primary_AnchorX*ResScaleX;
	y = Primary_AnchorY*ResScaleY; 
	
	
	
		
	
	for(i=0;i<3;i++)
	{
	if(!VPTiles[i].bVisible) continue; 
	x = (Primary_AnchorX - PeelX)*ResScaleX;
	y = Primary_AnchorY*ResScaleY; 
			
		HUD.Canvas.SetPos(x, y) ;
		
		HUD.Canvas.SetDrawColor(255,255,255,255) ; 		
		TempIcon = Veteran_Tile[i];
		TempAlpha = VPTiles[i].TileAlpha; 
		
		HUD.Canvas.DrawColor.A=TempAlpha; 
		if(VRank >= i+1) HUD.Canvas.SetDrawColor(0,255,50,TempAlpha) ; 	//We have this already
		HUD.Canvas.DrawIcon(TempIcon,X+(Tile_Spacing*i),Y,TileScale*ResScaleX) 	;
		x+=Number_AnchorX+(Tile_Spacing*i);
		y+=Number_AnchorY;
		
		HUD.Canvas.Font=Font'RenxHud.Font.CTextFont24pt'; 
		
		HUD.Canvas.StrLen(VPCost[i], XL,YL)					;
		XL*=TextScale*TileScale*ResScaleX				;
		YL*=TextScale*TileScale*ResScaleY 				; 
		x-=XL*0.5 										;	
		HUD.Canvas.SetPos(x, y) ;
		//HUD.Canvas.DrawText(VPTiles[i].TileAlpha, false,(TileScale*TextScale*ResScaleX), (TileScale*TextScale*ResScaleY)) ;
		HUD.Canvas.DrawText(VPCost[i], false,(TileScale*TextScale*ResScaleX), (TileScale*TextScale*ResScaleY)) ;
		
		TilesDrawn++ ; //We obviously drew this tile
		
	}
	
	if(TilesDrawn == 0)
	{
	bDead=true; //We're no longer drawing anything 
	Control.DestroyOldVetMenu();
	Control = none; 
	}		
	
	
}

DefaultProperties 
{
	//Tile vars
	//Position
	Primary_AnchorX = 420
	Primary_AnchorY = 520
	Number_AnchorX = 62
	Number_AnchorY = 88
	
	Tile_Spacing = 150
	
	PeelFadeSpeed=15.0
	PeelX=0.0f
	PeelIncrement=5
	
	TileMaxAlpha=220
	FadedTileAlpha=100 
	TileScale = 0.5
	TextScale = 1 
	//Tile Icons 
	 Veteran_Tile(0) = (Texture = Texture2D'RenxHud.Images.Veteran_Tile', U= 0, V = 0, UL = 256, VL = 256)
	 Veteran_Tile(1) = (Texture = Texture2D'RenxHud.Images.Elite_Tile', U= 0, V = 0, UL = 256, VL = 256)
	 Veteran_Tile(2) = (Texture = Texture2D'RenxHud.Images.Heroic_Tile', U= 0, V = 0, UL = 256, VL = 256)
	bPeeling=false
	
	Success_Snd = SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundPurchase' //SoundCue'Rx_Pickups.Sounds.SC_Pickup_Keycard'
	Failed_Snd = SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundTest2_Cue'
}