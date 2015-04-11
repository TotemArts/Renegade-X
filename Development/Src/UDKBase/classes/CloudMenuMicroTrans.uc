/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */
class CloudMenuMicroTrans extends MobileMenuScene;

var CloudPC PC;
var MicroTransactionBase MicroTrans;
var MobileMenuButton ProductButtons[2];

event InitMenuScene(MobilePlayerInput PlayerInput, int ScreenWidth, int ScreenHeight, bool bIsFirstInitialization)
{
	super.InitMenuScene(PlayerInput, ScreenWidth, ScreenHeight, bIsFirstInitialization);

	PC = CloudPC(InputOwner.Outer);

	MicroTrans = class'PlatformInterfaceBase'.static.GetMicroTransactionInterface();
	MicroTrans.AddDelegate(MTD_PurchaseQueryComplete, OnProductQueryComplete);
	MicroTrans.AddDelegate(MTD_PurchaseComplete, OnProductPurchaseComplete);

	ProductButtons[0] = MobileMenuButton(FindMenuObject("Product1"));
	ProductButtons[1] = MobileMenuButton(FindMenuObject("Product2"));
}

event OnTouch(MobileMenuObject Sender, ETouchType EventType, float TouchX, float TouchY)
{
	if (Sender.Tag == "Refresh")
	{
		MicroTrans.QueryForAvailablePurchases();
	}
	else if (Sender.Tag == "Close")
	{
		InputOwner.CloseMenuScene(self);
	}
	else if (Sender.Tag == "Product1")
	{
		MicroTrans.BeginPurchase(0);
	}
	else if (Sender.Tag == "Product2")
	{
		MicroTrans.BeginPurchase(1);
	}
}

function Closed() 
{
	MicroTrans.ClearDelegate(MTD_PurchaseQueryComplete, OnProductQueryComplete);
	MicroTrans.ClearDelegate(MTD_PurchaseComplete, OnProductPurchaseComplete);

	Super.Closed();
}


function OnProductQueryComplete(const out PlatformInterfaceDelegateResult Result)
{
	local int Index;
	local PurchaseInfo Info;
	for (Index = 0; Index < MicroTrans.AvailableProducts.length; Index++)
	{
		Info = MicroTrans.AvailableProducts[Index];
		if (Index < 2)
		{
			ProductButtons[Index].bIsHidden = false;
			ProductButtons[Index].Caption = Info.DisplayName;
		}

		`log("Purchase " $ Index $ ":");
		`log("  " $ Info.Identifier $ " - " $ Info.DisplayName $ " / " $ Info.DisplayPrice $ " - " $ Info.DisplayDescription);
	}
}

function OnProductPurchaseComplete(const out PlatformInterfaceDelegateResult Result)
{
	`log("Purchase complete:");
	`log("  Product = " $ Result.Data.StringValue);	
	`log("  bSuccess = " $ Result.bSuccessful);	
	`log("  Result = " $ Result.Data.IntValue);	

	if (Result.Data.IntValue == MTR_Failed)
	{
		`log("  Error: " $ MicroTrans.LastError);
		`log("  Solution: " $ MicroTrans.LastErrorSolution);
	}
}


defaultproperties
{

	Top=0
	Left=0
	Width=1.0
	Height=1.0
	bRelativeWidth=true
	bRelativeHeight=true

	Begin Object Class=MobileMenuButton Name=Refresh
		Tag="Refresh"
		Caption="Refresh Products"
		CaptionColor=(R=1,G=1,B=1,A=1)
		Left=0.25
		Top=0
		Width=0.5
		Height=0.15
		bRelativeLeft=true
		bRelativeTop=true
		bRelativeWidth=true
		bRelativeHeight=true
		// Note: These are referencing large button background textures that aren't really required.
//		Images[0]=Texture2D'KismetGame_Assets.Effects.T_EarBuzz_01_D'
//		Images[1]=Texture2D'KismetGame_Assets.Effects.T_EarBuzz_01_D'
		ImagesUVs[0]=(bCustomCoords=true,U=0,V=0,UL=512,VL=512)
		ImagesUVs[1]=(bCustomCoords=true,U=512,V=512,UL=512,VL=512)
	End Object
	MenuObjects.Add(Refresh)

	Begin Object Class=MobileMenuButton Name=Close
		Tag="Close"
		Caption="Back"
		CaptionColor=(R=1,G=1,B=1,A=1)
		Left=0.25
		Top=0.8
		Width=0.5
		Height=0.15
		bRelativeLeft=true
		bRelativeTop=true
		bRelativeWidth=true
		bRelativeHeight=true
		// Note: These are referencing large button background textures that aren't really required.
//		Images[0]=Texture2D'KismetGame_Assets.Effects.T_EarBuzz_01_D'
//		Images[1]=Texture2D'KismetGame_Assets.Effects.T_EarBuzz_01_D'
		ImagesUVs[0]=(bCustomCoords=true,U=0,V=0,UL=512,VL=512)
		ImagesUVs[1]=(bCustomCoords=true,U=512,V=512,UL=512,VL=512)
	End Object
	MenuObjects.Add(Close)

	Begin Object Class=MobileMenuButton Name=Product1
		Tag="Product1"
		CaptionColor=(R=1,G=1,B=1,A=1)
		bIsHidden=true
		Left=0.25
		Top=0.2
		Width=0.5
		Height=0.15
		bRelativeLeft=true
		bRelativeTop=true
		bRelativeWidth=true
		bRelativeHeight=true
		// Note: These are referencing large button background textures that aren't really required.
//		Images[0]=Texture2D'KismetGame_Assets.Effects.T_EarBuzz_01_D'
//		Images[1]=Texture2D'KismetGame_Assets.Effects.T_EarBuzz_01_D'
		ImagesUVs[0]=(bCustomCoords=true,U=0,V=0,UL=512,VL=512)
		ImagesUVs[1]=(bCustomCoords=true,U=512,V=512,UL=512,VL=512)
	End Object
	MenuObjects.Add(Product1)

	Begin Object Class=MobileMenuButton Name=Product2
		Tag="Product2"
		CaptionColor=(R=1,G=1,B=1,A=1)
		bIsHidden=true
		Left=0.25
		Top=0.4
		Width=0.5
		Height=0.15
		bRelativeLeft=true
		bRelativeTop=true
		bRelativeWidth=true
		bRelativeHeight=true
		// Note: These are referencing large button background textures that aren't really required.
//		Images[0]=Texture2D'KismetGame_Assets.Effects.T_EarBuzz_01_D'
//		Images[1]=Texture2D'KismetGame_Assets.Effects.T_EarBuzz_01_D'
		ImagesUVs[0]=(bCustomCoords=true,U=0,V=0,UL=512,VL=512)
		ImagesUVs[1]=(bCustomCoords=true,U=512,V=512,UL=512,VL=512)
	End Object
	MenuObjects.Add(Product2)
}
