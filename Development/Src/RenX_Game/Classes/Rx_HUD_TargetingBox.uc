class Rx_HUD_TargetingBox extends Rx_Hud_Component;

var protected Font LabelFont;
var protected Font PercentageFont;
var protected Font DescriptionFont;

var protected float ScreenEdgePadding;
var protected float ScreenBottomPadding;
var protected float MaxTargetBoxSizePctX;
var protected float MaxTargetBoxSizePctY;

var protected CanvasIcon BoundingBoxFriendlyTopLeft;
var protected CanvasIcon BoundingBoxFriendlyTopRight;
var protected CanvasIcon BoundingBoxFriendlyBottomLeft;
var protected CanvasIcon BoundingBoxFriendlyBottomRight;
var protected CanvasIcon BoundingBoxEnemyTopLeft;
var protected CanvasIcon BoundingBoxEnemyTopRight;
var protected CanvasIcon BoundingBoxEnemyBottomLeft;
var protected CanvasIcon BoundingBoxEnemyBottomRight;
var protected CanvasIcon BoundingBoxNeutralTopLeft;
var protected CanvasIcon BoundingBoxNeutralTopRight;
var protected CanvasIcon BoundingBoxNeutralBottomLeft;
var protected CanvasIcon BoundingBoxNeutralBottomRight;

var protected CanvasIcon InfoBackdropFriendly;
var protected CanvasIcon InfoBackdropEnemy;
var protected CanvasIcon InfoBackdropNeutral;
var protected CanvasIcon BA_InfoBackdropFriendly;
var protected CanvasIcon BA_InfoBackdropEnemy;

var CanvasIcon GDIEnemyIcon;
var CanvasIcon GDIFriendlyIcon;
var CanvasIcon NodEnemyIcon;
var CanvasIcon NodFriendlyIcon;
var CanvasIcon NeutralIcon;
var CanvasIcon BA_BuildingIcon_GDI_Friendly;
var CanvasIcon BA_BuildingIcon_Nod_Friendly;
var CanvasIcon BA_BuildingIcon_GDI_Enemy;
var CanvasIcon BA_BuildingIcon_Nod_Enemy;


//Veterancy icons 
var CanvasIcon Friendly_Recruit;
var CanvasIcon Friendly_Veteran;
var CanvasIcon Friendly_Elite;
var CanvasIcon Friendly_Heroic;
var CanvasIcon Enemy_Recruit;
var CanvasIcon Enemy_Veteran;
var CanvasIcon Enemy_Elite;
var CanvasIcon Enemy_Heroic;
var CanvasIcon Neutral_Recruit;
var CanvasIcon Neutral_Veteran;
var CanvasIcon Neutral_Elite;
var CanvasIcon Neutral_Heroic;


var float VetLogoXOffset ;
var float VetLogoYOffset ;

var float BA_VetLogoXOffset;
var float BA_VetLogoYOffset;

var protected CanvasIcon HealthCellGreen;
var protected CanvasIcon HealthCellYellow;
var protected CanvasIcon HealthCellRed;
var protected CanvasIcon ArmorCellBlue;
var protected CanvasIcon BA_HealthCellIcon; //Building Armour specific health bar.
var protected CanvasIcon BA_ArmourCellIcon; //Building Armour specific Armour bar.
var protected CanvasIcon BA_HealthIcon;
var protected CanvasIcon BA_ArmourIcon;


var protected CanvasIcon Interact;
var protected float InteractIconBobAmplitude;
var protected float InteractIconBobFrequency;

var RxIfc_Targetable TargetedActor;
var bool bLookingAtSubstitute;
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
var bool bDisplayTargetInfo;
var bool bDisplayBoundingBox;

var protected int TargetStance;

var protected float BoundingBoxPadding;

var protected bool AnchorInfoTop; // If true, anchor's the target info above the bounding box, false anchors it below.

var protected float BackgroundYOffset;
var protected float BackgroundXOffset;
var protected float LogoXOffset;
var protected float LogoYOffset;
var protected float InteractXOffset;
var protected float InteractYOffset;
var protected float HealthBarXOffset;
var protected float HealthBarYOffset;
var protected float HealthBarCellSpacing;
var protected float Armor_YOffset;
var protected int HealthBarCells;
var protected float HealthBarRedThreshold;
var protected float HealthBarYellowThreshold;
var protected float LabelXOffset;
var protected float LabelYOffset;
var protected float PercentXOffset;
var protected float PercentYOffset;
var protected float DescriptionXOffset;
var protected float DescriptionYOffset;
var float DescriptionXScale;
var float DescriptionYScale;
var protected float BA_ArmourIconYOffset;
var protected float BA_HealthIconYOffset;

/*Building Armour specific setup for boxes. Will incorporate into code once I don't need to edit them in-game*/
var protected float BA_HealthBarXOffset ;
var protected float BA_HealthBarYOffset;
var protected float BA_ArmourBarXOffset;
var protected float BA_ArmourBarYOffset;
var protected float BA_LabelXOffset ;
var protected float BA_LabelYOffset;
var protected float BA_IconsXOffset;
var protected float BA_IconsYOffset;	
var protected float BA_PercentXOffset;		// 55		// -15
var protected float BA_PercentYOffset;		// -35		// -15
// Offset for target's description
var protected float BA_DescriptionXOffset;
var protected float BA_DescriptionYOffset;
var protected float BA_BackgroundXOffset;
var protected float BA_BackgroundYOffset;
// Offset of team logo
var protected float BA_LogoXOffset;
var protected float BA_LogoYOffset;
var protected float BA_HealthBarCellSpacing;
var protected float BA_IconToPercentSpacing;
var protected float BA_ArmourPercentYOffset;

var protected Box VisualBoundingBox;
var protected float VisualBoundsCenterX;

var protected font InteractFont;

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
		UpdateTargetStance(TargetedActor.GetActualTarget());
	}
}

function UpdateTargetedObject (float DeltaTime)
{
	local Actor potentialTarget; //Used initially as a potential target... then to hold the TRUE Actor pointed to by TargetedActor for the rest of the function

	// Our potential target is the actor we're looking at.
	potentialTarget = GetActorAtScreenCentre();
	
	// If that's a valid target, then it becomes our target.
	if (IsValidTarget(potentialTarget) && IsTargetInRange(potentialTarget)) {
		SetTarget(potentialTarget);
		
		/* !!!!!IMPORTANT: Repurpose potential target to hold the ACTUAL actor!!!!!! */ 
		if(TargetedActor != none)
			potentialTarget = TargetedActor.GetActualTarget(); 
	}
	// If we're not looking at the targetted building anymore, automatically untarget it.(Sticky targets like vehic ignore this)
	//IsBuildingComponent(TargetedActor) && !IsPTorMCT(TargetedActor)) {
	else if (TargetedActor != none && !TargetedActor.IsStickyTarget() && TargetedActor.GetActualTarget() != potentialTarget ) {  
		TargetedActor = none;
	}
	// If the targeted actor is out of view, or out of range we should untarget it. 
	else if (TargetedActor != none)
	{
		potentialTarget = TargetedActor.GetActualTarget(); //Repurpose potentialtarget if it's 'none' (which it would be by the time it got to this else statement)
		
		//Now check for out of range
		if(!IsValidTarget(potentialTarget) || !IsActorInView(potentialTarget,true) || !IsTargetInRange(potentialTarget)) {
			TargetedActor.SetTargeted(false);
		
			TargetedActor = none;
		}
		// If we're here, that means we're not looking at it, but it's still on screen and in range, so start countdown to untarget it
		else {
			TimeSinceTargetLost += DeltaTime;
		}
		
	}		
	

	// If our target has expired, clear it.
	if (TimeSinceTargetLost > TargetStickTime && TargetedActor != none){
		TargetedActor.SetTargeted(false);
		TargetedActor = none;	
	}
}

function SetTarget(actor Target)
{
		//We're at least targeting something legitamate
		TimeSinceTargetLost = 0;
		
		Target = RxIfc_Targetable(Target).GetActualTarget();
		
		if(Target == Actor(TargetedActor)) //Already targeting this 
			return; 
		else //Commit to setting this to the target
		{
			TargetedActor = RxIfc_Targetable(Target);
			TimeSinceNewTarget = 0;
		}		
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
	if (TargetedActor == none || a == none)
		return 0;

	if (TargetedActor.AlwaysTargetable()) //(IsBuildingComponent(TargetedActor) && !IsPTorMCT(TargetedActor)) // Biuldings are large so their centre is bad to judge range by, use the hit location instead.
		return VSize(RenxHud.PlayerOwner.ViewTarget.Location - TargetActorHitLoc);
	else
		return VSize(RenxHud.PlayerOwner.ViewTarget.Location - a.Location);
}



function bool IsValidTarget (actor potentialTarget)
{
	if(potentialTarget == none)
		return false; 
	
	if(RxIfc_Targetable(potentialTarget) != none && RxIfc_Targetable(potentialTarget).GetIsValidLocalTarget(RenxHud.PlayerOwner))
	{
		return true;
	}	
	else 
		return false;
}

function Actor GetActorAtScreenCentre()
{
	return RenxHud.ScreenCentreActor;
}

function UpdateTargetHealthPercent ()
{
	TargetArmorPercent = 0;
	bHasArmor = false;
	
	/*Get interface armour/health pcts*/
	if(TargetedActor.GetShouldShowHealth())
	{
		TargetHealthPercent = TargetedActor.GetTargetHealthPct(); 
		TargetArmorPercent = TargetedActor.GetTargetArmourPct(); //float(Rx_Pawn(TargetedActor).Armor) / max(1,float(Rx_Pawn(TargetedActor).HealthMax + Rx_Pawn(TargetedActor).ArmorMax)); 
		TargetHealthMaxPercent = TargetedActor.GetTargetMaxHealthPct(); //float(Rx_Pawn(TargetedActor).HealthMax) / max(1,float(Rx_Pawn(TargetedActor).HealthMax + Rx_Pawn(TargetedActor).ArmorMax));
		
		bHasArmor = TargetedActor.GetUseBuildingArmour(); //Weird legacy variable for drawing. Only applies to BUILDING armour 
	}	
}

function UpdateTargetName()
{	
	TargetName = TargetedActor.GetTargetName();
}

function UpdateTargetDescription ()
{
	TargetDescription = TargetedActor.GetTargetedDescription(RenxHud.PlayerOwner);
}

function UpdateBoundingBox()
{
	local array<vector> Vertices;
	local box BBox, BBox2;
	local int i;
	local Actor TrueActor; 
	
	TrueActor = TargetedActor.GetActualTarget();
	if(TargetedActor.UseDefaultBBox())
	{
		BBox2.Min.X = Canvas.SizeX * 0.4;
		BBox2.Max.X = Canvas.SizeX * 0.6;
		BBox2.Min.Y = Canvas.SizeY * 0.4;
		BBox2.Max.Y = Canvas.SizeY * 0.6;
	}
	else
	{
		if (Rx_BuildingAttachment_PT(TrueActor) != none)
			BBox = GetPTBoundingBox(Rx_BuildingAttachment_PT(TrueActor));
		else
			TrueActor.GetComponentsBoundingBox(BBox);
	
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
	if (TargetedActor != none && TargetedActor.GetIsValidLocalTarget(RenxHud.PlayerOwner) && Canvas != None && Rx_PlayerInput(Renxhud.PlayerOwner.PlayerInput).bDrawTargettingBox)
	{
		Canvas.DrawColor = ColorWhite;

		if (bDisplayBoundingBox == true)
			DrawBoundingBoxCorners();

		if (bDisplayTargetInfo == true)
			DrawTargetInfo();
	}
}

protected function DrawBoundingBoxCorners()
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

protected function DrawTargetInfo()
{
		DrawInfoBackground();	
		DrawTeamLogo();
		
		if(TargetedActor.GetShouldShowHealth())
		{
			DrawHealthBar();
			DrawHealthPercent();
		}
		
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

	if(TargetedActor.GetIsInteractable(RenxHud.PlayerOwner))
		return true; 
	
	return false;
}

function bool Interactable()
{
	
	local PlayerController PO; 

	PO = RenxHud.PlayerOwner;
 	
	if (PO == none || PO.Pawn == none || PO.Pawn.DrivenVehicle != none)
		return false;
	
	return TargetedActor.GetCurrentlyInteractable(PO);
}

protected function DrawInteractText()
{
	local float X,Y, Xlen,Ylen;
	local string Text,bindKey;
	
	bindKey = Caps(UDKPlayerInput(RenxHud.PlayerOwner.PlayerInput).GetUDKBindNameFromCommand("GBA_Use"));
	
	Text = TargetedActor.GetInteractText(RenxHud.PlayerOwner, bindKey); 
	
	Canvas.Font = InteractFont;
	Canvas.TextSize(Text,Xlen,Ylen,GetResolutionModifier(),GetResolutionModifier());

	X = VisualBoundsCenterX + (InteractXOffset - (Xlen/2)) * (GetResolutionModifier());

	if (AnchorInfoTop)
		Y = VisualBoundingBox.Min.Y + (InteractYOffset - Ylen) * (GetResolutionModifier());
	else
		Y = VisualBoundingBox.Min.Y - (Interact.VL - Ylen) * (GetResolutionModifier());

	if (RenxHud.ShowInteractableIcon)
		Y -= Interact.VL * (GetResolutionModifier());
	else
		Y -= 10 * (GetResolutionModifier());

	Canvas.DrawColor = ColorGreen;
	Canvas.SetPos(X,Y,0);
	Canvas.DrawText(Text,,(GetResolutionModifier()),(GetResolutionModifier()));
}

protected function DrawInteractableIcon()
{
	local float X,Y;
	X = VisualBoundsCenterX + (InteractXOffset - (Interact.UL/2)) * (GetResolutionModifier());

	if (AnchorInfoTop)
		Y = VisualBoundingBox.Min.Y + (InteractYOffset - Interact.VL) * (GetResolutionModifier());
	else
		Y = VisualBoundingBox.Min.Y - (Interact.VL) * (GetResolutionModifier());

	Y += Sin(class'WorldInfo'.static.GetWorldInfo().TimeSeconds * InteractIconBobFrequency) * InteractIconBobAmplitude;

	Canvas.SetDrawColor(255,255,255,255);
	Canvas.DrawIcon(Interact,X,Y,(GetResolutionModifier()));
}

protected function DrawHealthBar()
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
			
				
					HealthBarsToDraw = FCeil(TargetHealthPercent * float(HealthBarCells) );
					ArmorBarsToDraw = FCeil(TargetArmorPercent * float(HealthBarCells) );//ArmorBarsToDraw = RoundUp(TargetArmorPercent*ArmorHealthPercentTemp * float(HealthBarCells) );
					HealthFillupBarsToDraw = FCeil(TargetHealthMaxPercent * float(HealthBarCells)) - HealthBarsToDraw; 
					 
			
				X = VisualBoundsCenterX + (BA_HealthBarXOffset + BA_IconsXOffset) * (GetResolutionModifier());
		
				if (AnchorInfoTop)
					Y = VisualBoundingBox.Min.Y + (BA_HealthBarYOffset * (GetResolutionModifier()));
				else
					Y = VisualBoundingBox.Max.Y + (BA_HealthBarYOffset * (GetResolutionModifier()));
			
			if (TargetHealthPercent > 0) //Don't bother drawing anything if it's already dead  
			{
				
			 
				//Draw Armour Over Health... maybe ? 
				
				
				
				Canvas.DrawColor = ColorBlue3 ;//ColorWhite;
				//Canvas.DrawColor.A=210; //Let health show through armour bar slightly so we can still see if it is red/green health
					HealthCell = BA_ArmourCellIcon;			
				for (i = 0; i < ArmorBarsToDraw; i++)
				{
					Canvas.DrawIcon(HealthCell,X,Y,(GetResolutionModifier())); 
					X += BA_HealthBarCellSpacing * (GetResolutionModifier());
				}
				
				Canvas.DrawColor = ColorGreyedOut;
				for (i = 0; i < HealthBarCells - (HealthBarsToDraw + HealthFillupBarsToDraw + ArmorBarsToDraw); i++)
				{
					Canvas.DrawIcon(HealthCell,X,Y,1.4 * (GetResolutionModifier()));
					X += BA_HealthBarCellSpacing * (GetResolutionModifier());
				}	
				
				//DRaw health under armour 
				//Again, Health Offsets are now used for Armour, and vice versa!!!!!!!!!
				
				X = VisualBoundsCenterX + (BA_HealthBarXOffset * (GetResolutionModifier()));
				Y+=(BA_ArmourBarYOffset * (GetResolutionModifier()));
				
				for (i = 0; i < HealthBarsToDraw; i++)
				{
					Canvas.DrawColor=HealthBlendColour;
					Canvas.DrawIcon(HealthCell,X,Y+BA_ArmourBarYOffset,(GetResolutionModifier()));
					X += BA_HealthBarCellSpacing * (GetResolutionModifier());
				}
				
				Canvas.DrawColor = ColorGreyedOut;
				for (i = 0; i < HealthFillupBarsToDraw; i++)
				{
					Canvas.DrawIcon(HealthCell,X,Y+BA_ArmourBarYOffset,(GetResolutionModifier()));
					X += BA_HealthBarCellSpacing * (GetResolutionModifier());
				}			
				
				
				
			}
		} 
		else
		{	
			//if(Rx_Pawn(TargetedActor) != None)
			if(TargetedActor.GetTargetArmourMax() > 0) //Infantry are about the only other thing using armour 
			{
				if (TargetHealthPercent < HealthBarRedThreshold * TargetHealthMaxPercent)			
					HealthCell = HealthCellRed;
				else if (TargetHealthPercent < HealthBarYellowThreshold * TargetHealthMaxPercent)
					HealthCell = HealthCellYellow;
				else 
					HealthCell = HealthCellGreen;
				ArmorBarsToDraw = FCeil(TargetArmorPercent * float(HealthBarCells)) ;
				HealthBarsToDraw = FCeil(TargetHealthPercent * float(HealthBarCells));
				BarsToDraw = ArmorBarsToDraw + HealthBarsToDraw;
			}
			else
			{
				if (TargetHealthPercent < HealthBarRedThreshold)			
					HealthCell = HealthCellRed;
				else if (TargetHealthPercent < HealthBarYellowThreshold)
					HealthCell = HealthCellYellow;
				else 
					HealthCell = HealthCellGreen;

				BarsToDraw = FCeil(TargetHealthPercent * float(HealthBarCells) );
			}
		
			X = VisualBoundsCenterX + (HealthBarXOffset * GetResolutionModifier());
	
	 		if (AnchorInfoTop)
				Y = VisualBoundingBox.Min.Y + (HealthBarYOffset * (GetResolutionModifier()));
			else
				Y = VisualBoundingBox.Max.Y + (HealthBarYOffset * (GetResolutionModifier()));

			if (TargetHealthPercent > 0) //Don't bother drawing anything if it's already dead  
			{
				if(ArmorBarsToDraw > 0)
				{
					for (i = 0; i < HealthBarsToDraw; i++)
					{
						Canvas.DrawIcon(HealthCell,X,Y,(GetResolutionModifier()));
						X += HealthBarCellSpacing * (GetResolutionModifier());
					}					
					for (i = HealthBarsToDraw; i < ArmorBarsToDraw + HealthBarsToDraw; i++)
					{
						Canvas.DrawIcon(ArmorCellBlue,X,Y,(GetResolutionModifier()));
						X += HealthBarCellSpacing * (GetResolutionModifier());
					}
				}
				else 
				{
					for (i = 0; i < BarsToDraw; i++)
					{
						Canvas.DrawIcon(HealthCell,X,Y,(GetResolutionModifier()));
						X += HealthBarCellSpacing * (GetResolutionModifier());
					}	
				}

				Canvas.DrawColor = ColorGreyedOut;
				for (i = 0; i < HealthBarCells - BarsToDraw; i++)
				{
					Canvas.DrawIcon(HealthCell,X,Y,(GetResolutionModifier()));
					X += HealthBarCellSpacing * (GetResolutionModifier());
				}
			}
		}

		if (TargetHealthPercent <= 0 && TargetedActor.HasDestroyedState())
		{
			Canvas.DrawColor = ColorGreen; 
			if(ArmorHealthPercentTemp > 0)	
				X = VisualBoundsCenterX + (BA_LabelXOffset * GetResolutionModifier());
			else
				X = VisualBoundsCenterX + (LabelXOffset * GetResolutionModifier());
			Canvas.Font = LabelFont;
			Canvas.SetPos(X,Y,0);
			Canvas.DrawText("(Destroyed)",,(GetResolutionModifier()),(GetResolutionModifier()));
		}	
		
	}

}

protected function DrawHealthPercent()
{
	local float X,Y; //,f1,f2;
	local int iHealthPercent;
	local float TargetHealthTotalPercent;
	
	//Also draws the health / armour icon if building armour is enabled.
	
	if(TargetHealthPercent <= 0)
		return;
	
	
		if (TargetNameTextSize.X - 4 < PercentXOffset)
		{
			X = VisualBoundsCenterX + (LabelXOffset + PercentXOffset) * (GetResolutionModifier());
		}
		else
		{
			X = VisualBoundsCenterX + (LabelXOffset + TargetNameTextSize.X) * (GetResolutionModifier());
		}
		
		if(TargetNameTextSize.X > 85) 
		{
			X += (18 * GetResolutionModifier());
		}
	


	if (TargetHealthPercent != -1)
	{

		if (AnchorInfoTop)
			Y = VisualBoundingBox.Min.Y + (PercentYOffset * (GetResolutionModifier()));
		else
			Y = VisualBoundingBox.Max.Y + (PercentYOffset * (GetResolutionModifier()));
	
			
		if(bHasArmor) //Still kind of legacy. Indicates BUILDING armour 
		{	
	
		//Begin Align for building with armour 
		
			X = VisualBoundsCenterX + (BA_PercentXOffset * (GetResolutionModifier())); //Screw what you were doing... we are here. 
		
		if (AnchorInfoTop)
			Y = VisualBoundingBox.Min.Y + (BA_PercentYOffset * (GetResolutionModifier()));
		else
			Y = VisualBoundingBox.Max.Y + (BA_PercentYOffset * (GetResolutionModifier()));
		
		//End align for building with armour
		
			
			Canvas.DrawColor = ColorBlue;	 
			Canvas.Font = PercentageFont;
			Canvas.SetPos(X - (12 * GetResolutionModifier()),Y,0);
			
			Canvas.DrawColor = ColorWhite;	 //don't blend
			Canvas.DrawIcon(BA_ArmourIcon,X,Y+(BA_HealthIconYOffset * GetResolutionModifier()),(GetResolutionModifier())); //Draw armour icon, remember all Armour/Health Offsets are swapped
	
			X+=(BA_IconToPercentSpacing) * GetResolutionModifier(); 
			
			Canvas.SetPos(X,Y,0);
			
					
			Canvas.DrawText(int(TargetArmorPercent*100) ,,(GetResolutionModifier()),(GetResolutionModifier()));// $ "%");
			
			//Health under armour
			
			if (TargetHealthPercent < HealthBarRedThreshold*TargetHealthMaxPercent)
				Canvas.DrawColor = ColorRed;
			else if (TargetHealthPercent < HealthBarYellowThreshold*TargetHealthMaxPercent)
				Canvas.DrawColor = ColorYellow;
			else 
				Canvas.DrawColor = ColorGreen;
			
			Canvas.DrawIcon(BA_HealthIcon,X - (BA_IconToPercentSpacing * GetResolutionModifier()),Y + (BA_ArmourIconYOffset * GetResolutionModifier()),(GetResolutionModifier()));
			
			
			if(int((TargetHealthPercent/TargetHealthMaxPercent)*10) <= 2)
				Canvas.DrawColor = ColorRed;
			else if(int((TargetHealthPercent/TargetHealthMaxPercent)*10) <= 5)
				Canvas.DrawColor = ColorYellow;	
			else 
				Canvas.DrawColor = ColorGreen;		
			
			Canvas.SetPos(X,Y + (BA_ArmourBarYOffset+BA_ArmourPercentYOffset) * GetResolutionModifier(),0);
			
			
			Canvas.DrawText(int((TargetHealthPercent/TargetHealthMaxPercent)*100),,(GetResolutionModifier()),(GetResolutionModifier())); //$ "%");
			
			
		} 
		else if(TargetedActor.GetTargetArmourMax() > 0 )//if(Rx_Pawn(TargetedActor) != None) //probably pawn
		{
			TargetHealthTotalPercent = FMin((TargetHealthPercent + TargetArmorPercent),1);

			if (TargetHealthTotalPercent < HealthBarRedThreshold)
				Canvas.DrawColor = ColorRed;
			else if (TargetHealthTotalPercent < HealthBarYellowThreshold)
				Canvas.DrawColor = ColorYellow;
			else 
				Canvas.DrawColor = ColorGreen;
	
			iHealthPercent = int(TargetHealthTotalPercent * 100);
	
			Canvas.Font = PercentageFont;
			Canvas.SetPos(X,Y,0);
			Canvas.DrawText(iHealthPercent $ "%",,(GetResolutionModifier()),(GetResolutionModifier()));			
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
			Canvas.DrawText(iHealthPercent $ "%",,(GetResolutionModifier()),(GetResolutionModifier()));
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

protected function DrawTargetName()
{
	local float X,Y;
	local Rx_PRI TargetPRI;

	if(!bHasArmor)
	{
		X = VisualBoundsCenterX + LabelXOffset * GetResolutionModifier();
	
	
	if (AnchorInfoTop)
		Y = VisualBoundingBox.Min.Y + (LabelYOffset  * GetResolutionModifier());
		else
		Y = VisualBoundingBox.Max.Y + (LabelYOffset * GetResolutionModifier());
	
	}
	else if(bHasArmor)
		{
			X = VisualBoundsCenterX + BA_LabelXOffset * GetResolutionModifier();
			
			if (AnchorInfoTop)
		Y = VisualBoundingBox.Min.Y + BA_LabelYOffset * GetResolutionModifier();
		else
		Y = VisualBoundingBox.Max.Y + BA_LabelYOffset * GetResolutionModifier();
		}
		
	if (TargetStance == STANCE_NEUTRAL)
		Canvas.DrawColor = ColorBlue;
	else if (TargetStance == STANCE_FRIENDLY)
		Canvas.DrawColor = ColorGreen;
	else
		Canvas.DrawColor = ColorRed;
	Canvas.Font = LabelFont;

	if(Pawn(TargetedActor) != None && Rx_PRI(Pawn(TargetedActor).PlayerReplicationInfo) != None)
	{
		TargetPRI = Rx_PRI(Pawn(TargetedActor).PlayerReplicationInfo);
	}

	Canvas.SetPos(X,Y,0);
	Canvas.DrawText(TargetName,,(GetResolutionModifier()),(GetResolutionModifier()));
	Canvas.TextSize(TargetName,TargetNameTextSize.X,TargetNameTextSize.Y,GetResolutionModifier(),GetResolutionModifier());

	if(TargetPRI != None && TargetPRI.BountyCredits > 0.f)
	{
		Y -= (12.f * GetResolutionModifier());

		Canvas.DrawColor = ColorYellow;
		Canvas.SetPos(X,Y,0);
		Canvas.DrawText("Reward : $"$Round(TargetPRI.BountyCredits),,(GetResolutionModifier()),(GetResolutionModifier()));
	}
}

protected function DrawTargetDescription()
{
	local float X,Y;
	//X = VisualBoundsCenterX + DescriptionXOffset;

	if(!bHasArmor)
	{
	if (AnchorInfoTop)
		Y = VisualBoundingBox.Min.Y + (DescriptionYOffset * (GetResolutionModifier()));
	else
		Y = VisualBoundingBox.Max.Y + (DescriptionYOffset * (GetResolutionModifier()));
	}
	else if(bHasArmor)
	{
	if (AnchorInfoTop)
		Y = VisualBoundingBox.Min.Y + (BA_DescriptionYOffset * (GetResolutionModifier()));
	else
		Y = VisualBoundingBox.Max.Y + (BA_DescriptionYOffset * (GetResolutionModifier()));	
		
	}
	
	
	
	if (TargetStance == STANCE_NEUTRAL)
		Canvas.DrawColor = ColorBlue;
	else if (TargetStance == STANCE_FRIENDLY)
		Canvas.DrawColor = ColorGreen;
	else
		Canvas.DrawColor = ColorRed;
	Canvas.Font = DescriptionFont;
	Canvas.TextSize(TargetDescription, TargetDescriptionTextSize.X, TargetDescriptionTextSize.Y, DescriptionXScale * GetResolutionModifier(), DescriptionYScale * GetResolutionModifier());
	X = VisualBoundsCenterX - TargetDescriptionTextSize.X/2;
	Canvas.SetPos(X,Y,0);
	Canvas.DrawText(TargetDescription,,DescriptionXScale * (GetResolutionModifier()),DescriptionYScale * (GetResolutionModifier()));
}

function bool TargetedHasVeterancy()
{
	return TargetedActor != None && TargetedActor.HasVeterancy();
}

protected function DrawTeamLogo()
{
	local float X,Y;
	local byte VRank, StanceToDraw; //0:FRIENDLY, 1: ENEMY, 2: NEUTRAL
	local byte MyTeamNum;
	local Rx_CapturePoint CP;
 	local Actor ActualActor;
	local byte ActualActorTeam;
	
	ActualActor = TargetedActor.GetActualTarget();
	ActualActorTeam = ActualActor.GetTeamNum();
	
	if(TargetedHasVeterancy())
	{
		VRank = TargetedActor.GetVRank();
	}

	if(bHasArmor)
	{			
		X = VisualBoundsCenterX + (BA_LogoXOffset - BA_BuildingIcon_GDI_Friendly.UL) * GetResolutionModifier();
			
		if (AnchorInfoTop)
			Y = VisualBoundingBox.Min.Y + (BA_LogoYOffset * (GetResolutionModifier()));
		else
			Y = VisualBoundingBox.Max.Y + (BA_LogoYOffset * (GetResolutionModifier()));
		Canvas.DrawColor.A=200;
		if (TargetStance == STANCE_ENEMY && ActualActorTeam == TEAM_NOD)
		{
			StanceToDraw=1;
			Canvas.DrawIcon(BA_BuildingIcon_Nod_Enemy,X,Y,(GetResolutionModifier()));
		}
		else if (TargetStance == STANCE_ENEMY && ActualActorTeam == TEAM_GDI)
		{
			StanceToDraw=1;
			Canvas.DrawIcon(BA_BuildingIcon_GDI_Enemy,X,Y,(GetResolutionModifier()));
		}
		else if (TargetStance == STANCE_FRIENDLY && ActualActorTeam == TEAM_NOD)
		{
			// spy addition, spy should have same boundingbox+icon
			if (TargetedActor.IsSpyTarget())
			{
				if(ActualActorTeam == RenxHud.PlayerOwner.GetTeamNum())
					Canvas.DrawIcon(BA_BuildingIcon_Nod_Friendly,X,Y,(GetResolutionModifier()));
				else
					Canvas.DrawIcon(BA_BuildingIcon_GDI_Friendly,X,Y,(GetResolutionModifier()));
			}
			else
				Canvas.DrawIcon(BA_BuildingIcon_Nod_Friendly,X,Y,(GetResolutionModifier()));
		}
		
		else if (TargetStance == STANCE_FRIENDLY && ActualActorTeam == TEAM_GDI)
		
		{
			// spy addition, spy should have same boundingbox+icon
			if (TargetedActor.IsSpyTarget())
			{
				if(ActualActorTeam == RenxHud.PlayerOwner.GetTeamNum())
					Canvas.DrawIcon(GDIFriendlyIcon,X,Y,(GetResolutionModifier()));
				else
					Canvas.DrawIcon(NodFriendlyIcon,X,Y,(GetResolutionModifier()));
			}
			else
				Canvas.DrawIcon(BA_BuildingIcon_GDI_Friendly,X,Y,(GetResolutionModifier()));	
		
			StanceToDraw=0;
		}
		else
			StanceToDraw=2;
	}
	else
	{
		X = VisualBoundsCenterX + (LogoXOffset - NeutralIcon.UL) * GetResolutionModifier();
		if (AnchorInfoTop)
			Y = VisualBoundingBox.Min.Y + (LogoYOffset * (GetResolutionModifier()));
		else
			Y = VisualBoundingBox.Max.Y + (LogoYOffset * (GetResolutionModifier()));
		
		if (TargetStance == STANCE_ENEMY && ActualActorTeam == TEAM_NOD)
		{
			Canvas.DrawIcon(NodEnemyIcon,X,Y,(GetResolutionModifier()));	
			StanceToDraw=1;
		}
			
		else if (TargetStance == STANCE_ENEMY && ActualActorTeam == TEAM_GDI)
		{
			Canvas.DrawIcon(GDIEnemyIcon,X,Y,(GetResolutionModifier()));
			StanceToDraw=1;
		}
			
		else if (TargetStance == STANCE_FRIENDLY && ActualActorTeam == TEAM_NOD)
		{
			// spy addition, spy should have same boundingbox+icon
			if (TargetedActor.IsSpyTarget())
			{
				if(ActualActorTeam == RenxHud.PlayerOwner.GetTeamNum())
				{
					Canvas.DrawIcon(NodFriendlyIcon,X,Y,(GetResolutionModifier()));
					StanceToDraw=0;
				}
					
				else
				{
					Canvas.DrawIcon(GDIFriendlyIcon,X,Y,(GetResolutionModifier()));
					StanceToDraw=0;
				}
					
			}
			else
			{
				Canvas.DrawIcon(NodFriendlyIcon,X,Y,(GetResolutionModifier()));
				StanceToDraw=0;
			}
			
		}
		else if (TargetStance == STANCE_FRIENDLY && ActualActorTeam == TEAM_GDI)
		{
			// spy addition, spy should have same boundingbox+icon
			if (TargetedActor.IsSpyTarget())
			{
				if(ActualActorTeam == ActualActorTeam)
				{
					Canvas.DrawIcon(GDIFriendlyIcon,X,Y,(GetResolutionModifier()));
					StanceToDraw=0;
				}
				else
				{
					Canvas.DrawIcon(NodFriendlyIcon,X,Y,(GetResolutionModifier()));
					StanceToDraw=0;
				}
					
			}
			else
			{
				Canvas.DrawIcon(GDIFriendlyIcon,X,Y,(GetResolutionModifier()));
				StanceToDraw=0;
			}			
		}
		else
		{
			if(Rx_Building_TechbuildingPoint(ActualActor) != None)
			{
				MyTeamNum = RenxHud.PlayerOwner.GetTeamNum();
				if(Rx_Building_TechbuildingPoint(ActualActor) != None)
					CP = Rx_Building_TechbuildingPoint_Internals(Rx_Building_TechbuildingPoint(ActualActor).BuildingInternals).CP;
			}
			if(CP == None || CP.CapturingTeam == 255)
			{
				Canvas.DrawIcon(NeutralIcon,X,Y,(GetResolutionModifier()));
			}
			else
			{
				if(MyTeamNum != CP.CapturingTeam)
				{
					if(CP.CapturingTeam == TEAM_GDI)
					{
						Canvas.DrawIcon(GDIEnemyIcon,X,Y,(GetResolutionModifier()));	
					}
					else
					{
						Canvas.DrawIcon(NodEnemyIcon,X,Y,(GetResolutionModifier()));	
					}
				}
				else
				{
					if(CP.CapturingTeam == TEAM_GDI)
					{
						Canvas.DrawIcon(GDIFriendlyIcon,X,Y,(GetResolutionModifier()));	
					}
					else
					{
						Canvas.DrawIcon(NodFriendlyIcon,X,Y,(GetResolutionModifier()));	
					}
				}

			}

			StanceToDraw=2;
		}
		//Building Armour enabled, and building targeted. 
	}	
	
	//Draw veteran icon placeholder 
	if(TargetedHasVeterancy())
	{
		if(bHasArmor)
			Y+=(BA_VetLogoYOffset * (GetResolutionModifier()));

		else
			Y+=(VetLogoYOffset * (GetResolutionModifier()));

		if (TargetNameTextSize.X - 4 < VetLogoXOffset)
		{
			X = VisualBoundsCenterX + (LabelXOffset + PercentXOffset - 42) * (GetResolutionModifier()) ;
			//X+=VetLogoXOffset; 
		}
		else
		{
			X = VisualBoundsCenterX + (LabelXOffset + TargetNameTextSize.X - 42) * (GetResolutionModifier());
			//X+= TargetNameTextSize.X + 14;
		}

		if(bHasArmor)
			X+= (BA_VetLogoXOffset * (GetResolutionModifier()));
		
		if(TargetNameTextSize.X > 85) 
		{
			X += (18 * (GetResolutionModifier()));
		}
		
		if(StanceToDraw == 0) 
		{
			switch (VRank)
			{
				case 0: 
					Canvas.DrawIcon(Friendly_Recruit, X, Y, (GetResolutionModifier()));
					break;
				case 1: 
					Canvas.DrawIcon(Friendly_Veteran, X, Y, (GetResolutionModifier()));
					break;
				case 2: 
					Canvas.DrawIcon(Friendly_Elite, X, Y, (GetResolutionModifier()));
					break;
				case 3: 
					Canvas.DrawIcon(Friendly_Heroic, X, Y, (GetResolutionModifier()));
					break;
			}
		}
		else 
		if(StanceToDraw == 1) 
		{
			switch (VRank)
			{
				case 0: 
					Canvas.DrawIcon(Enemy_Recruit, X, Y, (GetResolutionModifier()));
					break;
				case 1: 
					Canvas.DrawIcon(Enemy_Veteran, X, Y, (GetResolutionModifier()));
					break;
				case 2: 
					Canvas.DrawIcon(Enemy_Elite, X, Y, (GetResolutionModifier()));
					break;
				case 3: 
					Canvas.DrawIcon(Enemy_Heroic, X, Y, (GetResolutionModifier()));
					break;
			}
		}
		else 
		{
			switch (VRank)
			{
				case 0: 
					Canvas.DrawIcon(Neutral_Recruit, X, Y, (GetResolutionModifier()));
					break;
				case 1: 
					Canvas.DrawIcon(Neutral_Veteran, X, Y, (GetResolutionModifier()));
					break;
				case 2: 
					Canvas.DrawIcon(Neutral_Elite, X, Y, (GetResolutionModifier()));
					break;
				case 3: 
					Canvas.DrawIcon(Neutral_Heroic, X, Y, (GetResolutionModifier()));
					break;
			}
		}
	}	
}



protected function DrawInfoBackground()
{
	local float X,Y;
	local CanvasIcon Icon;
	local Rx_PRI TargetPRI;

	X = VisualBoundsCenterX - ((InfoBackdropNeutral.UL/2 + BackgroundXOffset) * GetResolutionModifier());

	if (AnchorInfoTop)
		Y = VisualBoundingBox.Min.Y + (BackgroundYOffset * (GetResolutionModifier()));
	else
		Y = VisualBoundingBox.Max.Y + (BackgroundYOffset * (GetResolutionModifier()));

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

	if(Pawn(TargetedActor) != None && Rx_PRI(Pawn(TargetedActor).PlayerReplicationInfo) != None)
		TargetPRI = Rx_PRI(Pawn(TargetedActor).PlayerReplicationInfo);
	
	if (TargetDescription == "")
	{
		if(TargetPRI != None && TargetPRI.BountyCredits > 0.f)
		{
			Y -= 12.0 * GetResolutionModifier();
			Canvas.SetPos(X,Y);
			Canvas.DrawTileStretched(Icon.Texture, (GetResolutionModifier()) * Abs(Icon.UL), 12 + ((GetResolutionModifier()) * Abs(Icon.VL)), Icon.U, Icon.V, Icon.UL, Icon.VL,, true, true);
		}

		else
			Canvas.DrawIcon(Icon,X,Y,(GetResolutionModifier()));
	}
	else
	{
		Canvas.SetPos(X,Y);
		if (TargetedHasVeterancy())
		{
			if(TargetPRI != None && TargetPRI.BountyCredits > 0.f)
			{
				Y -= 12.0 * GetResolutionModifier();
				Canvas.SetPos(X,Y);
				Canvas.DrawTileStretched(Icon.Texture, (GetResolutionModifier()) * (Abs(Icon.UL) + Friendly_Veteran.UL + 10),((GetResolutionModifier()) *  Abs(Icon.VL) * 1.25) + 12, Icon.U, Icon.V, Icon.UL, Icon.VL,, true, true);
			}				
			else
				Canvas.DrawTileStretched(Icon.Texture, (GetResolutionModifier()) * (Abs(Icon.UL) + Friendly_Veteran.UL + 10),(GetResolutionModifier()) *  Abs(Icon.VL) * 1.25, Icon.U, Icon.V, Icon.UL, Icon.VL,, true, true);
		}
		else
		{
			if(TargetPRI != None && TargetPRI.BountyCredits > 0.f)
			{
				Y -= 12.0 * GetResolutionModifier();
				Canvas.SetPos(X,Y);
				Canvas.DrawTileStretched(Icon.Texture, (GetResolutionModifier()) * Abs(Icon.UL), ((GetResolutionModifier()) * Abs(Icon.VL) * 1.25) + 12, Icon.U, Icon.V, Icon.UL, Icon.VL,, true, true);

			}
			else
				Canvas.DrawTileStretched(Icon.Texture, (GetResolutionModifier()) * Abs(Icon.UL), (GetResolutionModifier()) * Abs(Icon.VL) * 1.25, Icon.U, Icon.V, Icon.UL, Icon.VL,, true, true);
		}
	}
}

protected function UpdateTargetStance(Actor inActor)
{
	if (TargetedActor.IsSpyTarget()) // spies always show friendly
		TargetStance = STANCE_FRIENDLY;
	else
		TargetStance = GetStance(inActor);
}

DefaultProperties
{
	bDisplayBoundingBox = true
	bDisplayTargetInfo = true

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
	
	Friendly_Recruit = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Friendly_Recruit', U= 0, V = 0, UL = 64, VL = 64)
	Friendly_Veteran = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Friendly_Veteran', U= 0, V = 0, UL = 64, VL = 64)
	Friendly_Elite = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Friendly_Elite', U= 0, V = 0, UL = 64, VL = 64)
	Friendly_Heroic = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Friendly_Heroic', U= 0, V = 0, UL = 64, VL = 64)
	
	Enemy_Recruit = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Enemy_Recruit', U= 0, V = 0, UL = 64, VL = 64)
	Enemy_Veteran = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Enemy_Veteran', U= 0, V = 0, UL = 64, VL = 64)
	Enemy_Elite = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Enemy_Elite', U= 0, V = 0, UL = 64, VL = 64)
	Enemy_Heroic = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Enemy_Heroic', U= 0, V = 0, UL = 64, VL = 64)
	
	Neutral_Recruit = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Neutral_Recruit', U= 0, V = 0, UL = 64, VL = 64)
	Neutral_Veteran = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Neutral_Veteran', U= 0, V = 0, UL = 64, VL = 64)
	Neutral_Elite = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Neutral_Elite', U= 0, V = 0, UL = 64, VL = 64)
	Neutral_Heroic = (Texture = Texture2D'RenXTargetSystem.T_TargetSystem_Neutral_Heroic', U= 0, V = 0, UL = 64, VL = 64)
	
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

	VetLogoXOffset = 100
	VetLogoYOffset = -4

	BA_VetLogoXOffset = 30
	BA_VetLogoYOffset = -14
	

}
