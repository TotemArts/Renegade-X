class Rx_HUD_TargetingBox extends Rx_Hud_Component;

var private Font LabelFont;
var private Font PercentageFont;
var private Font DescriptionFont;

var private float ScreenEdgePadding;
var private float ScreenBottomPadding;
var private float MaxTargetBoxSizePctX;
var private float MaxTargetBoxSizePctY;

var private CanvasIcon BoundingBoxFriendlyTopLeft;
var private CanvasIcon BoundingBoxFriendlyTopRight;
var private CanvasIcon BoundingBoxFriendlyBottomLeft;
var private CanvasIcon BoundingBoxFriendlyBottomRight;
var private CanvasIcon BoundingBoxEnemyTopLeft;
var private CanvasIcon BoundingBoxEnemyTopRight;
var private CanvasIcon BoundingBoxEnemyBottomLeft;
var private CanvasIcon BoundingBoxEnemyBottomRight;
var private CanvasIcon BoundingBoxNeutralTopLeft;
var private CanvasIcon BoundingBoxNeutralTopRight;
var private CanvasIcon BoundingBoxNeutralBottomLeft;
var private CanvasIcon BoundingBoxNeutralBottomRight;

var private CanvasIcon InfoBackdropFriendly;
var private CanvasIcon InfoBackdropEnemy;
var private CanvasIcon InfoBackdropNeutral;
var private CanvasIcon BA_InfoBackdropFriendly;
var private CanvasIcon BA_InfoBackdropEnemy;

var CanvasIcon GDIEnemyIcon;
var CanvasIcon GDIFriendlyIcon;
var CanvasIcon NodEnemyIcon;
var CanvasIcon NodFriendlyIcon;
var CanvasIcon NeutralIcon;
var CanvasIcon BA_BuildingIcon_GDI_Friendly;
var CanvasIcon BA_BuildingIcon_Nod_Friendly;
var CanvasIcon BA_BuildingIcon_GDI_Enemy;
var CanvasIcon BA_BuildingIcon_Nod_Enemy;

var private CanvasIcon HealthCellGreen;
var private CanvasIcon HealthCellYellow;
var private CanvasIcon HealthCellRed;
var private CanvasIcon ArmorCellBlue;
var private CanvasIcon BA_HealthCellIcon; //Building Armour specific health bar.
var private CanvasIcon BA_ArmourCellIcon; //Building Armour specific Armour bar.
var private CanvasIcon BA_HealthIcon;
var private CanvasIcon BA_ArmourIcon;


var private CanvasIcon Interact;
var private float InteractIconBobAmplitude;
var private float InteractIconBobFrequency;

var Actor TargetedActor;
var Vector TargetActorHitLoc;
var Box ActualBoundingBox;
var String TargetName;
var String TargetDescription;
var float TargetHealthPercent;
var float TargetHealthMaxPercent;
var float TargetArmorPercent;
var bool bHasArmor;
var Vector2D TargetNameTextSize;
var Vector2D TargetDescriptionTextSize;

var private int TargetStance;

var private float BoundingBoxPadding;

var private bool AnchorInfoTop; // If true, anchor's the target info above the bounding box, false anchors it below.

var private float BackgroundYOffset;
var private float BackgroundXOffset;
var private float LogoXOffset;
var private float LogoYOffset;
var private float InteractXOffset;
var private float InteractYOffset;
var private float HealthBarXOffset;
var private float HealthBarYOffset;
var private float HealthBarCellSpacing;
var private float Armor_YOffset;
var private int HealthBarCells;
var private float HealthBarRedThreshold;
var private float HealthBarYellowThreshold;
var private float LabelXOffset;
var private float LabelYOffset;
var private float PercentXOffset;
var private float PercentYOffset;
var private float DescriptionXOffset;
var private float DescriptionYOffset;
var float DescriptionXScale;
var float DescriptionYScale;
var private float BA_ArmourIconYOffset;
var private float BA_HealthIconYOffset;

/*Building Armour specific setup for boxes. Will incorporate into code once I don't need to edit them in-game*/
var private float BA_HealthBarXOffset ;
var private float BA_HealthBarYOffset;
var private float BA_ArmourBarXOffset;
var private float BA_ArmourBarYOffset;
var private float BA_LabelXOffset ;
var private float BA_LabelYOffset;
var private float BA_IconsXOffset;
var private float BA_IconsYOffset;	
var private float BA_PercentXOffset;		// 55		// -15
var private float BA_PercentYOffset;		// -35		// -15
// Offset for target's description
var private float BA_DescriptionXOffset;
var private float BA_DescriptionYOffset;
var private float BA_BackgroundXOffset;
var private float BA_BackgroundYOffset;
// Offset of team logo
var private float BA_LogoXOffset;
var private float BA_LogoYOffset;
var private float BA_HealthBarCellSpacing;
var private float BA_IconToPercentSpacing;
var private float BA_ArmourPercentYOffset;




var private Box VisualBoundingBox;
var private float VisualBoundsCenterX;

var private font InteractFont;

var float TimeSinceNewTarget; // Starts countign when we sucessfully target a new actor
var float TimeSinceTargetLost; // Starts counting if the target is not being looked at

var const float TargetStickTime; // How long the target stays after we stop looking at it.
var const float TargetBoxAnimTime; // How long to scale the target box target animation to.


function Update(float DeltaTime, Rx_HUD HUD)
{
	super.Update(DeltaTime, HUD);

	TimeSinceNewTarget += DeltaTime;

	UpdateTargetedObject(DeltaTime);

	if (TargetedActor != none)
	{
		UpdateTargetName();
		UpdateTargetHealthPercent();
		UpdateTargetDescription();
		UpdateBoundingBox();
		UpdateTargetStance(TargetedActor);
	}
}

function UpdateTargetedObject (float DeltaTime)
{
	local Actor potentialTarget;

	// Our potential target is the actor we're looking at.
	potentialTarget = GetActorAtScreenCentre();
	// If that's a valid target, then it becomes our target.
	if (IsValidTarget(potentialTarget) && IsTargetInRange(potentialTarget)) {
		SetTarget(potentialTarget);
	}
	// If we're not looking at the targetted building anymore, automatically untarget it.
	else if (TargetedActor != none && IsBuildingComponent(TargetedActor) && !IsPTorMCT(TargetedActor)) {
		TargetedActor = none;
	}
	// If the targeted actor is out of view, or out of range we should untarget it.
	else if (TargetedActor != none && (!IsValidTarget(TargetedActor) || !IsActorInView(TargetedActor,true) || !IsTargetInRange(TargetedActor)) ) {
		if (Rx_Pawn(TargetedActor) != none) {
			Rx_Pawn(TargetedActor).bTargetted = false;
		} else if (Rx_Vehicle(TargetedActor) != none) {
			Rx_Vehicle(TargetedActor).bTargetted = false;
		}
		TargetedActor = none;
	}		
	// If we're here, that means we're not looking at it, but it's still on screen and in range, so start countdown to untarget it
	else {
		TimeSinceTargetLost += DeltaTime;
	}
		

	// If our target has expired, clear it.
	if (TimeSinceTargetLost > TargetStickTime){
		if (Rx_Pawn(TargetedActor) != none) {
			Rx_Pawn(TargetedActor).bTargetted = false;
		} else if (Rx_Vehicle(TargetedActor) != none) {
			Rx_Vehicle(TargetedActor).bTargetted = false;
		}
		TargetedActor = none;	
	}
}

function SetTarget(actor Target)
{
	if (Target != TargetedActor) // We don't already have this actor targeted
	{
		if (Rx_Pawn(TargetedActor) != none) {
			Rx_Pawn(TargetedActor).bTargetted = true;
		} else if (Rx_Vehicle(TargetedActor) != none) {
			Rx_Vehicle(TargetedActor).bTargetted = true;
		}
		TargetedActor = Target;
		TimeSinceNewTarget = 0;
	}
	TimeSinceTargetLost = 0;
}

function bool IsTargetInRange(actor a)
{
	if (IsBuildingComponent(a))
		return true;

	if (GetTargetDistance(a) >= GetWeaponTargetingRange())
			return false;
	else return true;
}

function float GetTargetDistance(actor a)
{
	if (a == none)
		return 0;

	if (IsBuildingComponent(TargetedActor) && !IsPTorMCT(TargetedActor)) // Biuldings are large so their centre is bad to judge range by, use the hit location instead.
		return VSize(RenxHud.PlayerOwner.ViewTarget.Location - TargetActorHitLoc);
	else
		return VSize(RenxHud.PlayerOwner.ViewTarget.Location - a.Location);
}



function bool IsValidTarget (actor potentialTarget)
{
	if (Rx_Building(potentialTarget) != none ||
		(Rx_BuildingAttachment(potentialTarget) != none && Rx_BuildingAttachment_Door(potentialTarget) == none) ||
		Rx_Building_Internals(potentialTarget) != none ||
		(Rx_Vehicle(potentialTarget) != none && Rx_Vehicle(potentialTarget).Health > 0) ||
		(Rx_Weapon_DeployedActor(potentialTarget) != none && Rx_Weapon_DeployedActor(potentialTarget).GetHealth() > 0) ||
		(Rx_Pawn(potentialTarget) != none && Rx_Pawn(potentialTarget).Health > 0)||
		(Rx_CratePickup(potentialTarget) != none && !Rx_CratePickup(potentialTarget).bPickupHidden)
		)
	{
		if (IsStealthedEnemyUnit(Pawn(potentialTarget)) ||
			potentialTarget == RenxHud.PlayerOwner.ViewTarget ||
			(Rx_VehicleSeatPawn(RenxHud.PlayerOwner.ViewTarget) != none && potentialTarget == Rx_VehicleSeatPawn(RenxHud.PlayerOwner.ViewTarget).MyVehicle))
		return false;
		else return true;
	}
		
	else return false;
}

function Actor GetActorAtScreenCentre()
{
	return RenxHud.ScreenCentreActor;
}

function UpdateTargetHealthPercent ()
{
	TargetArmorPercent = 0;
	bHasArmor = false;
	
	if (IsTechBuildingComponent(TargetedActor) && !IsPTorMCT(TargetedActor))
	{
		TargetHealthPercent = -1;
		return;
	}
	
	

	if (Rx_Pawn(TargetedActor) != none)
	{
		TargetHealthPercent =  (float(Rx_Pawn(TargetedActor).Health) + float(Rx_Pawn(TargetedActor).Armor)) / (float(Rx_Pawn(TargetedActor).HealthMax) + float(Rx_Pawn(TargetedActor).ArmorMax));
	}
	else if (Pawn(TargetedActor) != none)
	{
		TargetHealthPercent =  float(Pawn(TargetedActor).Health) / float(Pawn(TargetedActor).HealthMax);
	}
	else if (Rx_Weapon_DeployedActor(TargetedActor) != none && !Rx_Weapon_DeployedActor(TargetedActor).bCanNotBeDisarmedAnymore)
	{
		TargetHealthPercent = float(Rx_Weapon_DeployedActor(TargetedActor).GetHealth()) / float(Rx_Weapon_DeployedActor(TargetedActor).GetMaxHealth());
	}
	else if (Rx_BuildingAttachment(TargetedActor) != none && Rx_BuildingAttachment_PT(TargetedActor) == none)
	{
		TargetHealthPercent = Rx_BuildingAttachment(TargetedActor).getBuildingHealthPct();
		TargetHealthMaxPercent = Rx_BuildingAttachment(TargetedActor).getBuildingHealthMaxPct();		
		TargetArmorPercent = Rx_BuildingAttachment(TargetedActor).getBuildingArmorPct();
		bHasArmor = true;
	}
	else if (Rx_Building(TargetedActor) != none)
	{
		TargetArmorPercent = float(Rx_Building(TargetedActor).GetArmor()) / float(Rx_Building(TargetedActor).GetMaxArmor());
		TargetHealthPercent = float(Rx_Building(TargetedActor).GetHealth()) / float(Rx_Building(TargetedActor).GetTrueMaxHealth());		
		TargetHealthMaxPercent = 1.0f; //This may need to look at TrueMaxHealth somewhere.. we'll see after testing. 
		
		bHasArmor = true;
	}
	else
		TargetHealthPercent = -1;
		
	if(Rx_Building_Techbuilding(TargetedActor) != None || Rx_CapturableMCT(TargetedActor) != None
		|| (Rx_BuildingAttachment(TargetedActor) != none 
			&& (Rx_Building_Techbuilding(Rx_BuildingAttachment(TargetedActor).OwnerBuilding.BuildingVisuals) != None || Rx_CapturableMCT(Rx_BuildingAttachment(TargetedActor).OwnerBuilding.BuildingVisuals) != None)) )
	{
		bHasArmor = false;
	}	
		
}

function UpdateTargetName ()
{
	if (RxIfc_TargetedCustomName(TargetedActor) != none)
		TargetName = RxIfc_TargetedCustomName(TargetedActor).GetTargetedName(RenxHud.PlayerOwner);
	else
		TargetName = TargetedActor.GetHumanReadableName();
}

function UpdateTargetDescription ()
{
	if (RxIfc_TargetedDescription(TargetedActor) != none)
		TargetDescription = RxIfc_TargetedDescription(TargetedActor).GetTargetedDescription(RenxHud.PlayerOwner);
	else
		TargetDescription = "";
}

function UpdateBoundingBox()
{
	local array<vector> Vertices;
	local box BBox, BBox2;
	local int i;

	if (IsBuildingComponent(TargetedActor) && !IsPTorMCT(TargetedActor))
	{
		BBox2.Min.X = Canvas.SizeX * 0.4;
		BBox2.Max.X = Canvas.SizeX * 0.6;
		BBox2.Min.Y = Canvas.SizeY * 0.4;
		BBox2.Max.Y = Canvas.SizeY * 0.6;
	}
	else
	{
		if (Rx_BuildingAttachment_PT(TargetedActor) != none)
			BBox = GetPTBoundingBox(Rx_BuildingAttachment_PT(TargetedActor));
		else
			TargetedActor.GetComponentsBoundingBox(BBox);
	
		// Project all 8 corner points of the target onto our canvas
		Vertices.AddItem(Canvas.project(BBox.Min));
		Vertices.AddItem(Canvas.project(BBox.Max));
		Vertices.AddItem(Canvas.project(ReturnVector(BBox.Max.X, BBox.Max.Y, BBox.Min.Z)));
		Vertices.AddItem(Canvas.project(ReturnVector(BBox.Max.X, BBox.Min.Y, BBox.Min.Z)));
		Vertices.AddItem(Canvas.project(ReturnVector(BBox.Min.X, BBox.Min.Y, BBox.Max.Z)));
		Vertices.AddItem(Canvas.project(ReturnVector(BBox.Min.X, BBox.Max.Y, BBox.Max.Z)));
		Vertices.AddItem(Canvas.project(ReturnVector(BBox.Min.X, BBox.Max.Y, BBox.Min.Z)));
		Vertices.AddItem(Canvas.project(ReturnVector(BBox.Max.X, BBox.Min.Y, BBox.Max.Z)));
	
		BBox2.Min.X = 9001;
		BBox2.Min.Y = 9001;
	
		// Find extremes of bounding box
		for(i = 0; i < Vertices.Length; i++)
		{
			BBox2.Min.X = fmin(BBox2.Min.X, Vertices[i].X);
			BBox2.Min.Y = fmin(BBox2.Min.Y, Vertices[i].Y);
			BBox2.Max.X = fmax(BBox2.Max.X, Vertices[i].X);
			BBox2.Max.Y = fmax(BBox2.Max.Y, Vertices[i].Y);
		}
	}

	ActualBoundingBox = BBox2;

	VisualBoundingBox = ActualBoundingBox;
	VisualBoundingBox.Max.X = FClamp ( VisualBoundingBox.Max.X ,0 + ScreenEdgePadding, Canvas.SizeX - ScreenEdgePadding) + BoundingBoxPadding;
	VisualBoundingBox.Max.Y = FClamp ( VisualBoundingBox.Max.Y  ,0 + ScreenEdgePadding, Canvas.SizeY - ScreenBottomPadding) + BoundingBoxPadding;
	VisualBoundingBox.Min.X = FClamp ( VisualBoundingBox.Min.X ,0 + ScreenEdgePadding, Canvas.SizeX - ScreenEdgePadding)- BoundingBoxPadding ;
	VisualBoundingBox.Min.Y = FClamp ( VisualBoundingBox.Min.Y  ,0 + ScreenEdgePadding, Canvas.SizeY - ScreenBottomPadding) - BoundingBoxPadding;
	VisualBoundingBox = ClampBoundingBox(VisualBoundingBox);
	VisualBoundingBox = AnimateBoundingBox(VisualBoundingBox,(1/TargetBoxAnimTime) * TimeSinceNewTarget);
	VisualBoundsCenterX = VisualBoundingBox.Min.X + (VisualBoundingBox.Max.X - VisualBoundingBox.Min.X)/2;	
}

function Box AnimateBoundingBox (Box inBox, float Time)
{
	local vector boxCentre;
	boxCentre = inBox.Max - ((inBox.Max - inBox.Min)/2);

	if(Time < 1 && Time >= 0)
	{
		inBox.Min.X = inBox.Min.X - BoxCentre.X * (1 - Time) / 13;
		inBox.Max.X = inBox.Max.X + BoxCentre.X * (1 - Time) / 13;
		inBox.Min.Y = inBox.Min.Y - BoxCentre.Y * (1 - Time) / 13;
		inBox.Max.Y = inBox.Max.Y + BoxCentre.Y * (1 - Time) / 13;
	}
	return inBox;
}

function Box ClampBoundingBox(Box OriginalBox)
{
	local vector Size, AmmountToShrink;
	Size = OriginalBox.Max - OriginalBox.Min;
	AmmountToShrink.X = Max(Size.X - (MaxTargetBoxSizePctX * Canvas.SizeX),0);
	AmmountToShrink.Y = Max(Size.Y - (MaxTargetBoxSizePctY * Canvas.SizeY),0);
	OriginalBox.Max -= AmmountToShrink/2;
	OriginalBox.Min += AmmountToShrink/2;
	return OriginalBox;

}

function Box GetPTBoundingBox(Rx_BuildingAttachment_PT PT)
{
	local Box BBox;
	BBox.IsValid = 1;
	Bbox.Max = PT.Location + PT.PTMesh.Bounds.BoxExtent;
	Bbox.Min = PT.Location - PT.PTMesh.Bounds.BoxExtent;
	return BBox;
}

function vector ReturnVector(float X, float Y, float Z)
{
	local vector result;
	result.X = X;
	result.Y = Y;
	result.Z = Z;
	return result;
}

function float GetAttachmentBuildingHealth(Rx_BuildingAttachment BAttachment)
{
	if (BAttachment.OwnerBuilding != none)
	{
		return BAttachment.OwnerBuilding.GetHealth();
	}
}

function Draw()
{
	if (TargetedActor != none && Canvas != None)
	{
		Canvas.DrawColor = ColorWhite;

		DrawBoundingBoxCorners();
		DrawTargetInfo();
	}
}

private function DrawBoundingBoxCorners()
{

	if (TargetStance == STANCE_NEUTRAL)
	{
		Canvas.DrawIcon(BoundingBoxNeutralTopLeft,VisualBoundingBox.Min.X,VisualBoundingBox.Min.Y);
		Canvas.DrawIcon(BoundingBoxNeutralTopRight,VisualBoundingBox.Max.X+BoundingBoxNeutralTopRight.UL,VisualBoundingBox.Min.Y);
		Canvas.DrawIcon(BoundingBoxNeutralBottomLeft,VisualBoundingBox.Min.X,VisualBoundingBox.Max.Y+BoundingBoxNeutralBottomLeft.VL);
		Canvas.DrawIcon(BoundingBoxNeutralBottomRight,VisualBoundingBox.Max.X+BoundingBoxNeutralBottomRight.UL,VisualBoundingBox.Max.Y+BoundingBoxNeutralBottomRight.VL);
	}
	else if (TargetStance == STANCE_FRIENDLY)
	{
		Canvas.DrawIcon(BoundingBoxFriendlyTopLeft,VisualBoundingBox.Min.X,VisualBoundingBox.Min.Y);
		Canvas.DrawIcon(BoundingBoxFriendlyTopRight,VisualBoundingBox.Max.X+BoundingBoxFriendlyTopRight.UL,VisualBoundingBox.Min.Y);
		Canvas.DrawIcon(BoundingBoxFriendlyBottomLeft,VisualBoundingBox.Min.X,VisualBoundingBox.Max.Y+BoundingBoxFriendlyBottomLeft.VL);
		Canvas.DrawIcon(BoundingBoxFriendlyBottomRight,VisualBoundingBox.Max.X+BoundingBoxFriendlyBottomRight.UL,VisualBoundingBox.Max.Y+BoundingBoxFriendlyBottomRight.VL);
	} 
	else
	{
		Canvas.DrawIcon(BoundingBoxEnemyTopLeft,VisualBoundingBox.Min.X,VisualBoundingBox.Min.Y);
		Canvas.DrawIcon(BoundingBoxEnemyTopRight,VisualBoundingBox.Max.X+BoundingBoxEnemyTopRight.UL,VisualBoundingBox.Min.Y);
		Canvas.DrawIcon(BoundingBoxEnemyBottomLeft,VisualBoundingBox.Min.X,VisualBoundingBox.Max.Y+BoundingBoxEnemyBottomLeft.VL);
		Canvas.DrawIcon(BoundingBoxEnemyBottomRight,VisualBoundingBox.Max.X+BoundingBoxEnemyBottomRight.UL,VisualBoundingBox.Max.Y+BoundingBoxEnemyBottomRight.VL);
	}
}

private function DrawTargetInfo()
{
		DrawInfoBackground();	
		DrawTeamLogo();
		DrawHealthBar();
		DrawHealthPercent();
		DrawTargetName();
		if (TargetDescription != "")
			DrawTargetDescription();

		if ( RenxHud.ShowInteractMessage && CanInteract())
			DrawInteractText();
		if ( RenxHud.ShowInteractableIcon && Interactable())
			DrawInteractableIcon();
}

function bool CanInteract()
{
	if (RenxHud.PlayerOwner.Pawn == none || RenxHud.PlayerOwner.Pawn.DrivenVehicle != none)
		return false;

	if (Rx_Vehicle(TargetedActor) != none && Rx_Vehicle_Harvester(TargetedActor) == none)
		return Rx_Vehicle(TargetedActor).ShouldShowUseable(RenxHud.PlayerOwner,0);

	return false;
}

function bool Interactable()
{
	if (RenxHud.PlayerOwner.Pawn == none || RenxHud.PlayerOwner.Pawn.DrivenVehicle != none || UTPlayerController(RenxHud.PlayerOwner) == none)
		return false;

	if (Rx_Vehicle(TargetedActor) != none && Rx_Vehicle_Harvester(TargetedActor) == none)
		return Rx_Vehicle(TargetedActor).CanEnterVehicle(RenxHud.PlayerOwner.Pawn);

	else if (Rx_BuildingAttachment_PT_GDI(TargetedActor) != none && Rx_Controller(RenxHud.PlayerOwner).bCanAccessPT && RenxHud.PlayerOwner.Pawn.GetTeamNum() == TEAM_GDI)
		return true;

	else if (Rx_BuildingAttachment_PT_NOD(TargetedActor) != none && Rx_Controller(RenxHud.PlayerOwner).bCanAccessPT && RenxHud.PlayerOwner.Pawn.GetTeamNum() == TEAM_NOD)
		return true;

	else 
		return false;
}

private function DrawInteractText()
{
	local float X,Y, Xlen,Ylen;
	local string Text,bindKey;
	
	bindKey = Caps(UDKPlayerInput(RenxHud.PlayerOwner.PlayerInput).GetUDKBindNameFromCommand("GBA_Use"));
	
	if (Vehicle(TargetedActor) != none)
		Text = ("Press [ " $ bindKey $ " ] to enter " $ Vehicle(TargetedActor).GetHumanReadableName());
	else if (Rx_BuildingAttachment_PT(TargetedActor) != none)
		Text = ("Press [ " $ bindKey $ " ] to enter Purchase Terminal");

	Canvas.Font = InteractFont;
	Canvas.TextSize(Text,Xlen,Ylen);

	X = VisualBoundsCenterX + InteractXOffset - (Xlen/2);

	if (AnchorInfoTop)
		Y = VisualBoundingBox.Min.Y + InteractYOffset - Ylen;
	else
		Y = VisualBoundingBox.Min.Y - Interact.VL - Ylen;

	if (RenxHud.ShowInteractableIcon)
		Y -= Interact.VL;
	else
		Y -= 10;

	Canvas.DrawColor = ColorGreen;
	Canvas.SetPos(X,Y,0);
	Canvas.DrawText(Text);
}

private function DrawInteractableIcon()
{
	local float X,Y;
	X = VisualBoundsCenterX + InteractXOffset - (Interact.UL/2);

	if (AnchorInfoTop)
		Y = VisualBoundingBox.Min.Y + InteractYOffset - Interact.VL;
	else
		Y = VisualBoundingBox.Min.Y - Interact.VL;

	Y += Sin(class'WorldInfo'.static.GetWorldInfo().TimeSeconds * InteractIconBobFrequency) * InteractIconBobAmplitude;

	Canvas.SetDrawColor(255,255,255,255);
	Canvas.DrawIcon(Interact,X,Y);
}

private function DrawHealthBar()
{
	local int i;
	local CanvasIcon HealthCell;
	local color HealthBlendColour;
	local int HealthBarsToDraw;
	local int HealthFillupBarsToDraw;
	local int ArmorBarsToDraw;
	local int BarsToDraw;
	local float X, Y;
	local float ArmorHealthPercentTemp;
	
	if (TargetHealthPercent != -1)
	{
		
		if(bHasArmor)
			ArmorHealthPercentTemp = Rx_GRI(RenxHud.WorldInfo.Gri).buildingArmorPercentage / 100.0;		
		
		if(ArmorHealthPercentTemp > 0) //We have armour enabled
		{
			HealthCell = BA_HealthCellIcon;
			if (TargetHealthPercent < HealthBarRedThreshold*TargetHealthMaxPercent)
				HealthBlendColour = ColorRed; //Go full red...tard. 
		//HealthCell = HealthCellRed;
			else if (TargetHealthPercent < HealthBarYellowThreshold*TargetHealthMaxPercent)
					HealthBlendColour = ColorYellow; //Go yeller
			//HealthCell = HealthCellYellow;
			else 
			HealthBlendColour = ColorGreen; //Go environmentally friendly. 	
			//HealthCell = HealthCellGreen;
			
				
					HealthBarsToDraw = RoundUp(TargetHealthPercent * float(HealthBarCells) );
					ArmorBarsToDraw = RoundUp(TargetArmorPercent * float(HealthBarCells) );//ArmorBarsToDraw = RoundUp(TargetArmorPercent*ArmorHealthPercentTemp * float(HealthBarCells) );
					HealthFillupBarsToDraw = RoundUp(TargetHealthMaxPercent * float(HealthBarCells)) - HealthBarsToDraw; 
					 
			
				X = VisualBoundsCenterX + BA_HealthBarXOffset + BA_IconsXOffset;
		
				if (AnchorInfoTop)
					Y = VisualBoundingBox.Min.Y + BA_HealthBarYOffset;
				else
					Y = VisualBoundingBox.Max.Y + BA_HealthBarYOffset;
			
			if (TargetHealthPercent > 0) //Don't bother drawing anything if it's already dead  
			{
				
			 
				//Draw Armour Over Health... maybe ? 
				
				
				
				Canvas.DrawColor = ColorBlue3 ;//ColorWhite;
				//Canvas.DrawColor.A=210; //Let health show through armour bar slightly so we can still see if it is red/green health
					HealthCell = BA_ArmourCellIcon;			
				for (i = 0; i < ArmorBarsToDraw; i++)
				{
					Canvas.DrawIcon(HealthCell,X,Y); 
					X += BA_HealthBarCellSpacing;
				}
				
				Canvas.DrawColor = ColorGreyedOut;
				for (i = 0; i < HealthBarCells - (HealthBarsToDraw + HealthFillupBarsToDraw + ArmorBarsToDraw); i++)
				{
					Canvas.DrawIcon(HealthCell,X,Y,1.4);
					X += BA_HealthBarCellSpacing;
				}	
				
				//DRaw health under armour 
				//Again, Health Offsets are now used for Armour, and vice versa!!!!!!!!!
				
				X = VisualBoundsCenterX + BA_HealthBarXOffset;
				Y+=BA_ArmourBarYOffset;
				
				for (i = 0; i < HealthBarsToDraw; i++)
				{
					Canvas.DrawColor=HealthBlendColour;
					Canvas.DrawIcon(HealthCell,X,Y+BA_ArmourBarYOffset);
					X += BA_HealthBarCellSpacing;
				}
				
				Canvas.DrawColor = ColorGreyedOut;
				for (i = 0; i < HealthFillupBarsToDraw; i++)
				{
					Canvas.DrawIcon(HealthCell,X,Y+BA_ArmourBarYOffset);
					X += BA_HealthBarCellSpacing;
				}			
				
				
				
			}
		} else
		{
			if (TargetHealthPercent < HealthBarRedThreshold)			
				HealthCell = HealthCellRed;
			else if (TargetHealthPercent < HealthBarYellowThreshold)
				HealthCell = HealthCellYellow;
			else 
				HealthCell = HealthCellGreen;
	
			
				BarsToDraw = RoundUp(TargetHealthPercent * float(HealthBarCells) );
		
			X = VisualBoundsCenterX + HealthBarXOffset;
	
	 		if (AnchorInfoTop)
				Y = VisualBoundingBox.Min.Y + HealthBarYOffset;
			else
				Y = VisualBoundingBox.Max.Y + HealthBarYOffset;
	if (TargetHealthPercent > 0) //Don't bother drawing anything if it's already dead  
			{
				for (i = 0; i < BarsToDraw; i++)
				{
					Canvas.DrawIcon(HealthCell,X,Y);
					X += HealthBarCellSpacing;
				}
		
				Canvas.DrawColor = ColorGreyedOut;
				for (i = 0; i < HealthBarCells - BarsToDraw; i++)
				{
					Canvas.DrawIcon(HealthCell,X,Y);
					X += HealthBarCellSpacing;
				}
			}
		}

		if (TargetHealthPercent <= 0)
		{
			Canvas.DrawColor = ColorGreen; 
		if(ArmorHealthPercentTemp > 0)	X = VisualBoundsCenterX + BA_LabelXOffset;
		else
		X = VisualBoundsCenterX + LabelXOffset;
			Canvas.Font = LabelFont;
			Canvas.SetPos(X,Y,0);
			Canvas.DrawText("(Destroyed)");
		}	
		
	}

}

private function DrawHealthPercent()
{
	local float X,Y; //,f1,f2;
	local int iHealthPercent;
	
	//Also draws the health / armour icon if building armour is enabled.
	
	if(TargetHealthPercent <= 0)
		return;
	
	
		if (TargetNameTextSize.X - 5 < PercentXOffset)
		{
			X = VisualBoundsCenterX + LabelXOffset + PercentXOffset;
		}
		else
		{
			X = VisualBoundsCenterX + LabelXOffset + TargetNameTextSize.X + 5;
		}
		
		if(TargetNameTextSize.X > 85) 
		{
			X += 10;
		}
	


	if (TargetHealthPercent != -1)
	{

		if (AnchorInfoTop)
			Y = VisualBoundingBox.Min.Y + PercentYOffset;
		else
			Y = VisualBoundingBox.Max.Y + PercentYOffset;
	
			
		if(bHasArmor)
		{	
	
		//Begin Align for building with armour 
		
			X = VisualBoundsCenterX + BA_PercentXOffset; //Screw what you were doing... we are here. 
		
		if (AnchorInfoTop)
			Y = VisualBoundingBox.Min.Y + BA_PercentYOffset;
		else
			Y = VisualBoundingBox.Max.Y + BA_PercentYOffset;
		
		//End align for building with armour
		
			
			Canvas.DrawColor = ColorBlue;	 
			Canvas.Font = PercentageFont;
			Canvas.SetPos(X-12,Y,0);
			
			Canvas.DrawColor = ColorWhite;	 //don't blend
			Canvas.DrawIcon(BA_ArmourIcon,X,Y+BA_HealthIconYOffset); //Draw armour icon, remember all Armour/Health Offsets are swapped
	
			X+=BA_IconToPercentSpacing; 
			
			Canvas.SetPos(X,Y,0);
			
					
			Canvas.DrawText(int(TargetArmorPercent*100) );// $ "%");
			
			//Canvas.StrLen(int((TargetHealthPercent/TargetHealthMaxPercent)*100) $ "%",f1,f2);
			//Canvas.SetPos(Canvas.CurX + f1,Y,0);
			
			/**if(int(TargetArmorPercent*10) <= 2)
				Canvas.DrawColor = ColorRed;
			else if(int(TargetArmorPercent*10) <= 5)
				Canvas.DrawColor = ColorYellow;	
			else */
			
			
			//Health under armour
			
			if (TargetHealthPercent < HealthBarRedThreshold*TargetHealthMaxPercent)
				Canvas.DrawColor = ColorRed;
			else if (TargetHealthPercent < HealthBarYellowThreshold*TargetHealthMaxPercent)
				Canvas.DrawColor = ColorYellow;
			else 
				Canvas.DrawColor = ColorGreen;
			
			Canvas.DrawIcon(BA_HealthIcon,X-BA_IconToPercentSpacing,Y+BA_ArmourIconYOffset);
			
			
			if(int((TargetHealthPercent/TargetHealthMaxPercent)*10) <= 2)
				Canvas.DrawColor = ColorRed;
			else if(int((TargetHealthPercent/TargetHealthMaxPercent)*10) <= 5)
				Canvas.DrawColor = ColorYellow;	
			else 
				Canvas.DrawColor = ColorGreen;		
			
			Canvas.SetPos(X,Y+BA_ArmourBarYOffset+BA_ArmourPercentYOffset,0);
			
			
			Canvas.DrawText(int((TargetHealthPercent/TargetHealthMaxPercent)*100)); //$ "%");
			
			
		} 
		else
		{
			if (TargetHealthPercent < HealthBarRedThreshold)
				Canvas.DrawColor = ColorRed;
			else if (TargetHealthPercent < HealthBarYellowThreshold)
				Canvas.DrawColor = ColorYellow;
			else 
				Canvas.DrawColor = ColorGreen;
	
			iHealthPercent = int(TargetHealthPercent * 100);
	
			Canvas.Font = PercentageFont;
			Canvas.SetPos(X,Y,0);
			Canvas.DrawText(iHealthPercent $ "%");
		}	
		
		/** Debug Info:
		Canvas.SetPos(X,Y+20,0);
		Canvas.DrawText(Rx_GRI(RenxHud.WorldInfo.Gri).buildingArmorPercentage $ "%");
		Canvas.DrawText(TargetHealthPercent $ "%");
		Canvas.DrawText(TargetHealthMaxPercent $ "%");
		Canvas.DrawText(TargetArmorPercent $ "%");
		Canvas.DrawText(ArmorHealthPercentTemp $ "%");
		Canvas.DrawText(Rx_Building(TargetedActor).GetHealth());
		Canvas.DrawText(Rx_Building(TargetedActor).GetMaxHealth());
		Canvas.DrawText(Rx_Building(TargetedActor).GetArmor());
		Canvas.DrawText(Rx_Building(TargetedActor).GetMaxArmor());
		*/
		
	}
}

private function int RoundUp(float f)
{
	local float Result;

	Result = int(f);

	if(f - Result > 0.0)
		Result += 1.0;

	return Result;
}

private function DrawTargetName()
{
	local float X,Y;
	if(!bHasArmor)
	{
		X = VisualBoundsCenterX + LabelXOffset;
	
	
	if (AnchorInfoTop)
		Y = VisualBoundingBox.Min.Y + LabelYOffset;
		else
		Y = VisualBoundingBox.Max.Y + LabelYOffset;
	
	}
	else if(bHasArmor)
		{
			X = VisualBoundsCenterX + BA_LabelXOffset;
			
			if (AnchorInfoTop)
		Y = VisualBoundingBox.Min.Y + BA_LabelYOffset;
		else
		Y = VisualBoundingBox.Max.Y + BA_LabelYOffset;
		}
		
	if (TargetStance == STANCE_NEUTRAL)
		Canvas.DrawColor = ColorBlue;
	else if (TargetStance == STANCE_FRIENDLY)
		Canvas.DrawColor = ColorGreen;
	else
		Canvas.DrawColor = ColorRed;
	Canvas.Font = LabelFont;
	Canvas.SetPos(X,Y,0);
	Canvas.DrawText(TargetName);
	Canvas.TextSize(TargetName,TargetNameTextSize.X,TargetNameTextSize.Y);
}

private function DrawTargetDescription()
{
	local float X,Y;
	//X = VisualBoundsCenterX + DescriptionXOffset;

	if(!bHasArmor)
	{
	if (AnchorInfoTop)
		Y = VisualBoundingBox.Min.Y + DescriptionYOffset;
	else
		Y = VisualBoundingBox.Max.Y + DescriptionYOffset;
	}
	else if(bHasArmor)
	{
	if (AnchorInfoTop)
		Y = VisualBoundingBox.Min.Y + BA_DescriptionYOffset;
	else
		Y = VisualBoundingBox.Max.Y + BA_DescriptionYOffset;	
		
	}
	
	
	
	if (TargetStance == STANCE_NEUTRAL)
		Canvas.DrawColor = ColorBlue;
	else if (TargetStance == STANCE_FRIENDLY)
		Canvas.DrawColor = ColorGreen;
	else
		Canvas.DrawColor = ColorRed;
	Canvas.Font = DescriptionFont;
	Canvas.TextSize(TargetDescription, TargetDescriptionTextSize.X, TargetDescriptionTextSize.Y, DescriptionXScale, DescriptionYScale);
	X = VisualBoundsCenterX - TargetDescriptionTextSize.X/2;
	Canvas.SetPos(X,Y,0);
	Canvas.DrawText(TargetDescription,,DescriptionXScale,DescriptionYScale);
}

private function DrawTeamLogo()
{
	local float X,Y;
	
	
	
	if(bHasArmor)
	{
			
			X = VisualBoundsCenterX + LogoXOffset - BA_BuildingIcon_GDI_Friendly.UL;
			
		if (AnchorInfoTop)
			Y = VisualBoundingBox.Min.Y + BA_LogoYOffset;
		else
			Y = VisualBoundingBox.Max.Y + BA_LogoYOffset;
Canvas.DrawColor.A=200;
		if (TargetStance == STANCE_ENEMY && TargetedActor.GetTeamNum() == TEAM_NOD)
			Canvas.DrawIcon(BA_BuildingIcon_Nod_Enemy,X,Y);
		else if (TargetStance == STANCE_ENEMY && TargetedActor.GetTeamNum() == TEAM_GDI)
			Canvas.DrawIcon(BA_BuildingIcon_GDI_Enemy,X,Y);
		else if (TargetStance == STANCE_FRIENDLY && TargetedActor.GetTeamNum() == TEAM_NOD)
		{
			// spy addition, spy should have same boundingbox+icon
			if (Rx_Pawn(TargetedActor) != none && Rx_Pawn(TargetedActor).isSpy())
			{
				if(TargetedActor.GetTeamNum() == RenxHud.PlayerOwner.GetTeamNum())
					Canvas.DrawIcon(BA_BuildingIcon_Nod_Friendly,X,Y);
				else
					Canvas.DrawIcon(BA_BuildingIcon_GDI_Friendly,X,Y);
			}
			else
				Canvas.DrawIcon(BA_BuildingIcon_Nod_Friendly,X,Y);
		}
		
		else if (TargetStance == STANCE_FRIENDLY && TargetedActor.GetTeamNum() == TEAM_GDI)
		
		{
			// spy addition, spy should have same boundingbox+icon
			if (Rx_Pawn(TargetedActor) != none && Rx_Pawn(TargetedActor).isSpy())
			{
				if(TargetedActor.GetTeamNum() == RenxHud.PlayerOwner.GetTeamNum())
					Canvas.DrawIcon(GDIFriendlyIcon,X,Y);
				else
					Canvas.DrawIcon(NodFriendlyIcon,X,Y);
			}
			else
				Canvas.DrawIcon(BA_BuildingIcon_GDI_Friendly,X,Y);	
		}
	}
	else if(!bHasArmor)
	{
		X = VisualBoundsCenterX + LogoXOffset - NeutralIcon.UL;
		if (AnchorInfoTop)
			Y = VisualBoundingBox.Min.Y + LogoYOffset;
		else
			Y = VisualBoundingBox.Max.Y + LogoYOffset;

		if (TargetStance == STANCE_ENEMY && TargetedActor.GetTeamNum() == TEAM_NOD)
			Canvas.DrawIcon(NodEnemyIcon,X,Y);
		else if (TargetStance == STANCE_ENEMY && TargetedActor.GetTeamNum() == TEAM_GDI)
			Canvas.DrawIcon(GDIEnemyIcon,X,Y);
		else if (TargetStance == STANCE_FRIENDLY && TargetedActor.GetTeamNum() == TEAM_NOD)
		{
			// spy addition, spy should have same boundingbox+icon
			if (Rx_Pawn(TargetedActor) != none && Rx_Pawn(TargetedActor).isSpy())
			{
				if(TargetedActor.GetTeamNum() == RenxHud.PlayerOwner.GetTeamNum())
					Canvas.DrawIcon(NodFriendlyIcon,X,Y);
				else
					Canvas.DrawIcon(GDIFriendlyIcon,X,Y);
			}
			else
				Canvas.DrawIcon(NodFriendlyIcon,X,Y);
		}
		else if (TargetStance == STANCE_FRIENDLY && TargetedActor.GetTeamNum() == TEAM_GDI)
		{
			// spy addition, spy should have same boundingbox+icon
			if (Rx_Pawn(TargetedActor) != none && Rx_Pawn(TargetedActor).isSpy())
			{
				if(TargetedActor.GetTeamNum() == RenxHud.PlayerOwner.GetTeamNum())
					Canvas.DrawIcon(GDIFriendlyIcon,X,Y);
				else
					Canvas.DrawIcon(NodFriendlyIcon,X,Y);
			}
			else
				Canvas.DrawIcon(GDIFriendlyIcon,X,Y);
		}
		else
			Canvas.DrawIcon(NeutralIcon,X,Y);
		
		//Building Armour enabled, and building targeted. 
	}	
}
private function DrawInfoBackground()
{
	local float X,Y;
	local CanvasIcon Icon;

	X = VisualBoundsCenterX - InfoBackdropNeutral.UL/2 + BackgroundXOffset;

	if (AnchorInfoTop)
		Y = VisualBoundingBox.Min.Y + BackgroundYOffset;
	else
		Y = VisualBoundingBox.Max.Y + BackgroundYOffset;

	if(!bHasArmor)
	{
	if (TargetStance == STANCE_NEUTRAL)
		Icon = InfoBackdropNeutral;
	else if (TargetStance == STANCE_FRIENDLY)
		Icon = InfoBackdropFriendly;
	else
		Icon = InfoBackdropEnemy;
	}
	
	else if(bHasArmor)
	
	{
		
	if (TargetStance == STANCE_NEUTRAL)
		Icon = BA_InfoBackdropFriendly;
	else if (TargetStance == STANCE_FRIENDLY)
		Icon = BA_InfoBackdropFriendly;
	else
		Icon = BA_InfoBackdropEnemy;
		
	}
	
	if (TargetDescription == "")
		Canvas.DrawIcon(Icon,X,Y);
	else
	{
		Canvas.SetPos(X,Y);
		Canvas.DrawTileStretched(Icon.Texture, Abs(Icon.UL), Abs(Icon.VL) * 1.25, Icon.U, Icon.V, Icon.UL, Icon.VL,, true, true);
	}
}

private function UpdateTargetStance(Actor inActor)
{
	if (Rx_Pawn(inActor) != none && Rx_Pawn(inActor).isSpy()) // spies always show friendly
		TargetStance = STANCE_FRIENDLY;
	else
		TargetStance = GetStance(inActor);
}

DefaultProperties
{
	// Doesn't let the targeting box get closer than this from the top, or sides of the screen.
	ScreenEdgePadding = 50
	// Doesn't let the targeting box get closer than this from the bottom of the screen.
	ScreenBottomPadding = 200
	// How many pixels larger than the actual bounding box to make the drawn bounding box.
	BoundingBoxPadding = 15


	TargetStickTime = 3.0f
	TargetBoxAnimTime = 0.1f

	// Max screen size (percentage) that the target box is allowed to be.
	MaxTargetBoxSizePctX =0.5
	MaxTargetBoxSizePctY =0.5

	// If true, anchor's the target info above the bounding box, false anchors it below.
	AnchorInfoTop = true
	// Y offset of background image
	BackgroundXOffset = -3
	BackgroundYOffset = -55

	// Offset of team logo
	LogoXOffset = -41
	LogoYOffset = -55
	// Offset of the interaction symbol
	InteractXOffset = 0
	InteractYOffset = -30
	// Offset of healthbar
	HealthBarXOffset = -64
	HealthBarYOffset = -24
	// Spacing how far over to draw each health bar cell
	HealthBarCellSpacing = 6;
	// How many cells to draw at full health
	HealthBarCells = 20
	// When the health is below this (out of 1) does it draw red.
	HealthBarRedThreshold = 0.2
	// When the health is below this (out of 1) does it draw yellow.
	HealthBarYellowThreshold = 0.5

	// Offset for target's name
	LabelXOffset = -58
	LabelYOffset = -35

	// Offset for the health percentage display
	PercentXOffset = 96		// 55		// -15
	PercentYOffset = -35		// -35		// -15

	// Offset for target's description
	DescriptionXOffset = -58
	DescriptionYOffset = -12

	DescriptionXScale=1
	DescriptionYScale=0.9

	LabelFont = Font'RenXTargetSystem.T_TargetSystemLabel'
	PercentageFont = Font'RenXTargetSystem.T_TargetSystemPercentage'
	DescriptionFont = Font'RenXTargetSystem.T_TargetSystemLabel'

	BoundingBoxNeutralTopLeft =    (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Neutral_BoundingCorner', U= 0, V = 0, UL = 32, VL=32)
	BoundingBoxNeutralTopRight=    (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Neutral_BoundingCorner', U= 32, V = 0, UL = -32, VL=0)
	BoundingBoxNeutralBottomLeft=  (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Neutral_BoundingCorner', U= 0, V = 32, UL = 0, VL=-32)
	BoundingBoxNeutralBottomRight= (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Neutral_BoundingCorner', U= -32, V = -32, UL = -32, VL=-32)

	BoundingBoxFriendlyTopLeft =    (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Friendly_BoundingCorner', U= 0, V = 0, UL = 32, VL=32)
	BoundingBoxFriendlyTopRight=    (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Friendly_BoundingCorner', U= 32, V = 0, UL = -32, VL=0)
	BoundingBoxFriendlyBottomLeft=  (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Friendly_BoundingCorner', U= 0, V = 32, UL = 0, VL=-32)
	BoundingBoxFriendlyBottomRight= (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Friendly_BoundingCorner', U= -32, V = -32, UL = -32, VL=-32)

	BoundingBoxEnemyTopLeft =    (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Enemy_BoundingCorner', U= 0, V = 0, UL = 32, VL=32)
	BoundingBoxEnemyTopRight=    (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Enemy_BoundingCorner', U= 32, V = 0, UL = -32, VL=0)
	BoundingBoxEnemyBottomLeft=  (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Enemy_BoundingCorner', U= 0, V = 32, UL = 0, VL=-32)
	BoundingBoxEnemyBottomRight= (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Enemy_BoundingCorner', U= -32, V = -32, UL = -32, VL=-32)

	InfoBackdropFriendly = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Friendly_BackDrop', U= 0, V = 0, UL = 256, VL = 64)
	InfoBackdropEnemy    = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Enemy_BackDrop', U= 0, V = 0, UL = 256, VL = 64)
	InfoBackdropNeutral  = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Neutral_BackDrop', U= 0, V = 0, UL = 256, VL = 64)

	GDIEnemyIcon = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Enemy_GDI', U= 0, V = 0, UL = 64, VL = 64)
	GDIFriendlyIcon= (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Friendly_GDI', U= 0, V = 0, UL = 64, VL = 64)
	NodEnemyIcon = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Enemy_Nod', U= 0, V = 0, UL = 64, VL = 64)
	NodFriendlyIcon = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Friendly_Nod', U= 0, V = 0, UL = 64, VL = 64)
	NeutralIcon = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Neutral_Empty', U= 0, V = 0, UL = 64, VL = 64)
	
	HealthCellGreen = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_HealthBar_Single_Green', U= 0, V = 0, UL = 16, VL = 16)
	HealthCellYellow = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_HealthBar_Single_Yellow', U= 0, V = 0, UL = 16, VL = 16)
	HealthCellRed = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_HealthBar_Single_Red', U= 0, V = 0, UL = 16, VL = 16)
	ArmorCellBlue = (Texture = Texture2D'renxtargetsystem.T_TargetSystem_ArmorBar_Single_Blue', U= 0, V = 0, UL = 16, VL = 16)
	Interact = (Texture = Texture2D'renxtargetsystem.T_TargetSystem_Interact', U= 0, V = 0, UL = 32, VL = 64)
	
//Building Armour specific Icons (If it really doesn't look right with the larger health cells.)
BA_HealthCellIcon = (Texture = Texture2D'RenXTargetSystem.T_HUD_Targetting_Building_Bar_Health', U= 0, V = 0, UL = 16, VL = 16)
BA_ArmourCellIcon = (Texture = Texture2D'RenXTargetSystem.T_HUD_Targetting_Building_Bar_Armour', U= 0, V = 0, UL = 16, VL = 16)
BA_HealthIcon = (Texture = Texture2D'RenXTargetSystem.T_HUD_Targetting_Building_Icon_Health', U= 0, V = 0, UL = 32, VL = 32)
BA_ArmourIcon = (Texture = Texture2D'RenXTargetSystem.T_HUD_Targetting_Building_Icon_Armour', U= 0, V = 0, UL = 32, VL = 32)	

BA_BuildingIcon_GDI_Friendly = (Texture = Texture2D'RenXTargetSystem.T_HUD_Targetting_Building_Logo_GDI_Friendly', U= 0, V = 0, UL = 64, VL = 64)	
BA_BuildingIcon_Nod_Friendly = (Texture = Texture2D'RenXTargetSystem.T_HUD_Targetting_Building_Logo_Nod_Friendly', U= 0, V = 0, UL = 64, VL = 64)	

BA_BuildingIcon_GDI_Enemy = (Texture = Texture2D'RenXTargetSystem.T_HUD_Targetting_Building_Logo_GDI_Enemy', U= 0, V = 0, UL = 64, VL = 64)	
BA_BuildingIcon_Nod_Enemy = (Texture = Texture2D'RenXTargetSystem.T_HUD_Targetting_Building_Logo_Nod_Enemy', U= 0, V = 0, UL = 64, VL = 64)	

BA_InfoBackdropFriendly = (Texture = Texture2D'RenXTargetSystem.T_HUD_Targetting_Building_Backdrop_Friendly', U= 0, V = 0, UL = 256, VL = 64)
BA_InfoBackdropEnemy    = (Texture = Texture2D'RenXTargetSystem.T_HUD_Targetting_Building_Backdrop_Enemy', U= 0, V = 0, UL = 256, VL = 64)


//IMPORTANT!!! SWAP ALL "HEALTH" AND "ARMOUR" OFFSETS. Armour was originally drawn beneath health. 

BA_HealthBarXOffset = -32
BA_HealthBarYOffset = -32

BA_ArmourBarXOffset= -64
BA_ArmourBarYOffset = 5

BA_LabelXOffset = -50
BA_LabelYOffset = -46
BA_IconsXOffset = 0
BA_IconsYOffset = 0 	
BA_PercentXOffset = -64		// 55		// -15
BA_PercentYOffset = -34		// -35		// -15
// Offset for target's description
BA_DescriptionXOffset = -58
BA_DescriptionYOffset = -12

BA_BackgroundXOffset = -3
BA_BackgroundYOffset = -55
// Offset of team logo
BA_LogoXOffset = -41
BA_LogoYOffset = -55
BA_HealthBarCellSpacing = 4
BA_IconToPercentSpacing = 20
BA_ArmourIconYOffset = 4
BA_HealthIconYOffset = -7 
BA_ArmourPercentYOffset = 8
//End Building armour specific variables. Will likely undo these once it is confirmed that nothing needs to be moved around anymore
	InteractFont = Font'RenXHud.Font.PlayerName'

	InteractIconBobAmplitude = 5.0f;
	InteractIconBobFrequency = 4.0f;
	

}
