class Rx_Weapon_ProxyC4 extends Rx_Weapon_Beacon ;//Rx_Weapon_Deployable;

var StaticMeshComponent VisualizationMesh;
var bool ShowVisualization;
var Rx_Building TouchingFriendlyBuilding;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	if (Pawn(Owner) != None)
		Pawn(Owner).Mesh.AttachComponent(VisualizationMesh, 'b_R_Toe');

	SetTimer(0.5, true, nameof(CheckTouchBuildings));
}

simulated event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	if (Owner == None || Pawn(Owner) == None || Pawn(Owner).Mesh == None || Pawn(Owner).Weapon != self)
	{
		VisualizationMesh.SetHidden(true);
		VisualizationMesh.DetachFromAny();
		ShowVisualization = false;
		return;
	}

	if (VisualizationMesh != None && Pawn(Owner).Health > 0)
		VisualizationMesh.SetHidden(!ShowVisualization);

	if (!VisualizationMesh.bAttached)
		Pawn(Owner).Mesh.AttachComponent(VisualizationMesh, 'b_R_Toe');
}

auto simulated state Inactive
{
	simulated function BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		VisualizationMesh.SetHidden(true);
	}
}

simulated event Destroyed()
{
	if (VisualizationMesh != None)
		VisualizationMesh.DetachFromAny();
}

simulated function DrawCrosshair( Hud HUD )
{
	local float x,y;
	local UTHUDBase H;
	local Pawn MyPawnOwner;
	local actor TargetActor;
	local int targetTeam;
	local int MineNum, MaxMineNum;
	local color TempColor;
	local float MineTextL, MineTextH, MineEmphasisScale;
	local LinearColor LC; //nBab
	
	//set initial color based on settings (nBab)
	LC.A = 1.f;
	switch (Rx_HUD(Rx_Controller(Instigator.Controller).myHUD).SystemSettingsHandler.GetCrosshairColor())
	{
		//white
		case 0:
			LC.R = 1.f;
			LC.G = 1.f;
			LC.B = 1.f;
			break;
		//orange
		case 1:
			LC.R = 2.f;
			LC.G = 0.5f;
			LC.B = 0.f;
			break;
		//violet
		case 2:
			LC.R = 2.f;
			LC.G = 0.f;
			LC.B = 2.f;
			break;
		//blue
		case 3:
			LC.R = 0.f;
			LC.G = 0.f;
			LC.B = 2.f;
			break;
		//cyan
		case 4:
			LC.R = 0.f;
			LC.G = 2.f;
			LC.B = 2.f;
			break;	
	}	
	
	H = UTHUDBase(HUD);
	if ( H == None )
		return;
	
	MineNum=Rx_HUD(H).GIHudMovie.CurrentNumMines;
	MaxMineNum=Rx_HUD(H).GIHudMovie.CurrentMaxMines;
	
	CrosshairWidth = default.CrosshairWidth + RecoilSpread*RecoilSpreadCrosshairScaling;	
	CrosshairHeight = default.CrosshairHeight + RecoilSpread*RecoilSpreadCrosshairScaling;
		
	CrosshairLinesX = H.Canvas.ClipX * 0.5 - (CrosshairWidth * 0.5);
	CrosshairLinesY = H.Canvas.ClipY * 0.5 - (CrosshairHeight * 0.5);	
	
	MyPawnOwner = Pawn(Owner);

	//determines what we are looking at and what color we should use based on that.
	if (MyPawnOwner != None)
	{
		TargetActor = Rx_Hud(HUD).GetActorWeaponIsAimingAt();
		if (Pawn(TargetActor) == None && Rx_Weapon_DeployedActor(TargetActor) == None && 
			Rx_Building(TargetActor) == None && Rx_BuildingAttachment(TargetActor) == None)
		{
			TargetActor = (TargetActor == None) ? None : Pawn(TargetActor.Base);
		}
		
		if(TargetActor != None)
		{
			targetTeam = TargetActor.GetTeamNum();
			
			if (targetTeam == 0 || targetTeam == 1) //has to be gdi or nod player
			{
				if (targetTeam != MyPawnOwner.GetTeamNum())
				{
					if (!TargetActor.IsInState('Stealthed') && !TargetActor.IsInState('BeenShot'))
					{
						//enemy, go red, except if stealthed (else would be cheating ;] )
						//nBab
						LC.R = 10.f;
						LC.G = 0.f;
						LC.B = 0.f;
					}
				}
				else
				{
					//Friendly
					//nBab
					LC.R = 0.f;
					LC.G = 10.f;
					LC.B = 0.f;
				}
			}
		}
	}
	
	if (!HasAnyAmmo()) //no ammo, go yellow
	{
		//nBab
		LC.R = 10.f;
		LC.G = 8.f;
		LC.B = 0.f;
	}
	else
	{
		if (CurrentlyReloading || CurrentlyBoltReloading || BoltActionReload && HasAmmo(CurrentFireMode) && IsTimerActive('BoltActionReloadTimer')) //reloading, go yellow
		{
			//nBab
			LC.R = 10.f;
			LC.G = 8.f;
			LC.B = 0.f;
		}
	}

	//nBab
	CrosshairMIC2.SetVectorParameterValue('Reticle_Colour', LC);
	CrosshairDotMIC2.SetVectorParameterValue('Reticle_Colour', LC);
	
	H.Canvas.SetPos( CrosshairLinesX, CrosshairLinesY );
	if(bDisplayCrosshair) {
		H.Canvas.DrawMaterialTile(CrosshairMIC2, CrosshairWidth, CrosshairHeight);
	}

	CrosshairLinesX = H.Canvas.ClipX * 0.5 - (default.CrosshairWidth * 0.5);
	CrosshairLinesY = H.Canvas.ClipY * 0.5 - (default.CrosshairHeight * 0.5);
	GetCrosshairDotLoc(x, y, H);
	H.Canvas.SetPos( X, Y );
	if(bDisplayCrosshair) {
		H.Canvas.DrawMaterialTile(CrosshairDotMIC2, default.CrosshairWidth, default.CrosshairHeight);
		
		//Draw Mine Limit
		H.Canvas.Font=Font'RenXTargetSystem.T_TargetSystemPercentage';
		H.Canvas.StrLen("Mines: " $ MineNum $ "/" $ MaxMineNum, MineTextL,MineTextH)	; //I wasn't going to center it.. but baah, I'm going to center it. 
		
		TempColor=H.Canvas.DrawColor;
		if(float(MineNum)/float(MaxMineNum) < 0.5) 
		{
			H.Canvas.SetDrawColor(0,255,0,255); //Green
			MineEmphasisScale=1;
		}
		if(float(MineNum)/float(MaxMineNum) >= 0.5) 
		{
			H.Canvas.SetDrawColor(255,255,0,255); //Yeller
			MineEmphasisScale=1.2;
		}
		
		if(float(MineNum/MaxMineNum) >= 0.90)
		{
			H.Canvas.SetDrawColor(255,0,0,255); //Red
			MineEmphasisScale=1.4;
		}
		
		H.Canvas.SetPos(
		X+(default.CrosshairWidth/2)-(MineTextL*MineEmphasisScale)/2,
		Y+default.CrosshairHeight/5);
		
		H.Canvas.DrawText("Mines: " $ MineNum $ "/" $ MaxMineNum ,true,MineEmphasisScale,MineEmphasisScale);
		H.Canvas.DrawColor=TempColor;
	}

	DrawHitIndicator(H,x,y);
}

simulated function PlayWeaponEquip()
{
	super.PlayWeaponEquip();

	ShowVisualization = true;
}

simulated function PlayWeaponPutDown()
{
	super.PlayWeaponPutDown();

	ShowVisualization = false;
}

simulated function bool IsValidPosition() 
{
	return true;
}

simulated function CheckTouchBuildings()
{
	if (Instigator != None && Instigator.Weapon != self) return;

	TouchingFriendlyBuilding = Rx_Pawn(Instigator).GetTouchingFriendlyBuilding();
}

simulated function bool IsInTeamBuilding() 
{
	return Rx_Building(Instigator.Base) != None && Rx_Building_Techbuilding(Instigator.Base) == None && Instigator.Base.GetTeamNum() == Instigator.GetTeamNum();
}

function bool Deploy()
{
	local Rx_Controller IPC;
	local Rx_PRI PRI; 

	IPC = Rx_Controller(Instigator.Controller);

	PRI = Rx_PRI(IPC.PlayerReplicationInfo);

	if(!PRI.bCanMine)
	{
		/*Nobody likes you; you can't use these things that have been badly designed for 12+ years now.*/ // <- true
		IPC.CTextMessage("You are currently banned from Mining");
		return false;		
	}

	if (super.Deploy())
	{
		Rx_TeamInfo(Rx_Game(WorldInfo.Game).Teams[Instigator.GetTeamNum()]).mineCount++;
		Rx_Weapon_DeployedProxyC4(DeployedActor).IsTeamProxyC4 = true;
		destroyOldMinesIfMinelimitReached();

		return true;
	}

	return false;
}

function destroyOldMinesIfMinelimitReached()
{
	local Rx_TeamInfo teamInfo;
	local Rx_Weapon_DeployedProxyC4 mine, oldestMine;
	local string OldMineLocationString;

	teamInfo = Rx_TeamInfo(Rx_Game(WorldInfo.Game).Teams[Instigator.GetTeamNum()]);
	if (teamInfo.MineLimit < teamInfo.mineCount)
	{
		foreach DynamicActors(class'Rx_Weapon_DeployedProxyC4', mine) 
		{
			if(!mine.IsTeamProxyC4 || !mine.bUsesMineLimit || mine.GetTeamNum() != teamInfo.GetTeamNum()) 
			{
				continue;
			}
			if(oldestMine == None) 
			{
				oldestMine = mine;
			} 
			else if(mine.CreationTime < oldestMine.CreationTime) 
			{
				oldestMine = mine;
			}
		}
		if(Rx_Controller(Instigator.Controller) != None)
			OldMineLocationString = Rx_Controller(Instigator.Controller).GetSpottargetLocationInfo(oldestMine);
		oldestMine.Destroy();
		OvermineBroadcast(OldMineLocationString);
	}
}

/**
 * Access to HUD and Canvas. Set bRenderOverlays=true to receive event.
 * Event called every frame when the item is in the InventoryManager
 *
 * @param   HUD H
 */
simulated function ActiveRenderOverlays(HUD H)
{
   local Canvas C;
   local float PanX, PanY, PosX, PosY;

   super(Rx_Weapon).ActiveRenderOverlays(H);
   C = H.Canvas;

   if (LastPos != Owner.Location || !bShowLoadPanel || C == none)
      return;

   // get the draw values
   PanX = C.SizeX * PanelWidth;
   PanY = C.SizeY * PanelHeight;
   // draw the loadpanel border
   //C.DrawColor = Rx_Hud(H).TeamColors[Owner.GetTeamNum()];
    C.SetDrawColor (0, 100, 255, 255); //(255,64,64,255);
   PosX = C.SizeX * 0.5f - PanX * 0.5f;
   PosY = C.SizeY/2 - PanY ;
   C.SetPos(PosX, PosY);
   C.DrawBox(PanX, PanY);
   // draw the text
   C.SetPos(PosX+3, PosY+3);
   
   //C.DrawText("Planting.....");
   // draw the loadpanel anim
   C.DrawColor.A = 128;
   C.SetPos(PosX + 1, PosY + 1);
   C.DrawRect(PanX * CurrentProgress - 2, PanY - 2);
}

simulated function PerformRefill()
{
	CurrentAmmoInClip=default.ClipSize;
	AmmoCount = MaxAmmoCount;
}

function bool CanAttack(Actor Other)
{
	return false; //temporarily don't let bots use this
}

simulated function string GetWeaponTips()
{
	local int CurMines, MaxMines;
	local Rx_PRI RxPRI;

	RxPRI = Rx_PRI(Pawn(Owner).PlayerReplicationInfo);

	if (RxPRI == None)
		return "";

	MaxMines = Rx_TeamInfo(RxPRI.Team).MineLimit;
	CurMines = Rx_TeamInfo(RxPRI.Team).MineCount;

	return "TEAM MINE COUNT: "$CurMines$"/"$MaxMines;
}

simulated function LinearColor GetTipsColor()
{
	local Rx_PRI RxPRI;
	local int CurMines, MaxMines;

	RxPRI = Rx_PRI(Pawn(Owner).PlayerReplicationInfo);

	if (RxPRI == None)
		return super.GetTipsColor();


	if (!RxPRI.bCanMine)
		return MakeLinearColor(1.0,0.0,0.0,1.0);

	MaxMines = Rx_TeamInfo(RxPRI.Team).MineLimit;
	CurMines = Rx_TeamInfo(RxPRI.Team).MineCount;

	if (MaxMines <= CurMines)
	{
		return MakeLinearColor(1.0,0.0,0.0,1.0);
	}
	else if (MaxMines - 3 <= CurMines)
	{
		return MakeLinearColor(1.0,1.0,0.0,1.0);
	}

	return MakeLinearColor(0.0,1.0,0.0,1.0);
}

simulated function string GetWeaponSecondaryTips()
{
	local int CurMines, MaxMines;
	local Rx_PRI RxPRI;
	local string extra;

	RxPRI = Rx_PRI(Pawn(Owner).PlayerReplicationInfo);

	if (RxPRI == None)
		return "";

	if (!RxPRI.bCanMine)
		return ">>BANNED FROM MINING IN BUILDINGS<<";

	MaxMines = Rx_TeamInfo(RxPRI.Team).MineLimit;
	CurMines = Rx_TeamInfo(RxPRI.Team).MineCount;

	extra = "TEAM";

	if (MaxMines <= CurMines)
		return ">>>>"$ extra @ "MINE LIMIT REACHED<<<<";

	return "";
}

simulated function LinearColor GetSecondTipsColor()
{
	return MakeLinearColor(1.0,0.0,0.0,1.0);
}

DefaultProperties
{
	DeployedActorClass=class'Rx_Weapon_DeployedProxyC4'
	
	PanelWidth  = 0.15f
    PanelHeight = 0.033f
	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'rx_wp_proxyc4.Mesh.SK_WP_ProxyC4_1P'
		AnimSets(0)=AnimSet'rx_wp_proxyc4.Anims.AS_WP_ProxyC4_1P'
		Animations=MeshSequenceA
		Scale=2.0
		FOV=50.0
	End Object

	Begin Object Class=StaticMeshComponent Name=TMesh
		StaticMesh=StaticMesh'RenX_AssetBase.Mesh.SM_Sphere_Rad100'
		Scale=1.45
		Materials[0]=MaterialInstanceConstant'RenX_AssetBase.Materials.MI_Proximity_Radius'
		CollideActors=False
		BlockActors=False
		BlockZeroExtent=False
		BlockNonZeroExtent=False
		BlockRigidBody=False
		bOnlyOwnerSee=true
		HiddenGame=true
	End Object
	VisualizationMesh=TMesh

	ShowVisualization = false
	
	ArmsAnimSet = AnimSet'rx_wp_proxyc4.Anims.AS_WP_ProxyC4_Arms'

	AttachmentClass = class'Rx_Attachment_ProxyC4'
	
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_ProxyC4'
	
	PlayerViewOffset=(X=10.0,Y=0.0,Z=-2.5)
	FireOffset=(X=25,Y=0,Z=-5)
	SecondsNeedLoad=1.0
	
	bRemoveWhenDepleted = false
	bBlockDeployCloseToOwnBase=false
	bAffectedByNoDeployVolume=false
	bAllowDropDeploy = true
	
	//-------------- Recoil
	RecoilDelay = 0.07
	RecoilSpreadDecreaseDelay = 0.1
	MinRecoil = -100.0
	MaxRecoil = -50.0
	MaxTotalRecoil = 1000.0
	RecoilYawModifier = 0.5 // will be a random value between 0 and this value for every shot
	RecoilInterpSpeed = 10.0
	RecoilDeclinePct = 0.5
	RecoilDeclineSpeed = 2.0
	RecoilSpread = 0.0
	MaxSpread = 0.0
	RecoilSpreadIncreasePerShot = 0.015
	RecoilSpreadDeclineSpeed = 0.25

	ShotCost(0)=1
	ShotCost(1)=0
	FireInterval(0)=+1.0
	FireInterval(1)=+0.0
	ReloadTime(0)=1.0
	ReloadTime(1)=0.0
	
	EquipTime=1.0
//	PutDownTime=0.5

	WeaponFireTypes(0)=EWFT_Custom
	WeaponFireTypes(1)=EWFT_None

    Spread(0)=0.0
	Spread(1)=0.0
	
	bDisplayCrosshair=false
	
	ClipSize = 3
	InitalNumClips = 1
	MaxClips = 1
	
	ThirdPersonWeaponPutDownAnim="H_M_C4_PutDown"
	ThirdPersonWeaponEquipAnim="H_M_C4_Equip"

	ReloadAnimName(0) = "weaponequip"
	ReloadAnimName(1) = "weaponequip"
	ReloadAnim3PName(0) = "H_M_C4_Equip"
	ReloadAnim3PName(1) = "H_M_C4_Equip"
	ReloadArmAnimName(0) = "weaponequip"
	ReloadArmAnimName(1) = "weaponequip"

	WeaponFireSnd[0]=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_Fire'
	WeaponFireSnd[1]=None

	WeaponPutDownSnd=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_PutDown'
	WeaponEquipSnd=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_Equip'
	ReloadSound(0)=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_Equip'
	ReloadSound(1)=SoundCue'RX_WP_TimedC4.Sounds.SC_TimedC4_Equip'

	PickupSound=SoundCue'RX_WP_Shotgun.Sounds.SC_Shotgun_Equip'
 
	MuzzleFlashSocket=MuzzleFlashSocket
	FireSocket=MuzzleFlashSocket

	CrosshairMIC = MaterialInstanceConstant'RenXHud.MI_Reticle_AutoRifle'

	InventoryGroup=5
	GroupWeight=1
	InventoryMovieGroup=25

	WeaponIconTexture=Texture2D'rx_wp_proxyc4.UI.T_WeaponIcon_ProximityC4'
	
	// AI Hints:
	//MaxDesireability=0.7
	AIRating=+0.3
	CurrentRating=+0.3
	bFastRepeater=false
	bInstantHit=false
	bSplashJump=false
	bRecommendSplashDamage=true
	bSniping=false
}
