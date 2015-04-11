/**
 * Copyright 1998-2015 Epic Games, Inc. All Rights Reserved.
 */

class CloudPC extends SimplePC;

/** Save data */
var CloudSaveData SaveData;

var int Slot1DocIndex;
var int Slot2DocIndex;

/** Cache some singletons */
var CloudStorageBase Cloud;
var FacebookIntegration Facebook;
var InGameAdManager AdManager;
var MicroTransactionBase MicroTrans;
var TwitterIntegrationBase Twitter;

/** Are we currently authenticating with facebook? */
var bool bIsFBAuthenticating;

/** Has an ingame ad been shown? */
var bool bAdHasBeenShown;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	Slot1DocIndex = -1;
	Slot2DocIndex = -1;

	// listen for cloud storage value changes
	Cloud = class'PlatformInterfaceBase'.static.GetCloudStorageInterface();
	Cloud.AddDelegate(CSD_ValueChanged, CloudValueChanged);
	Cloud.AddDelegate(CSD_DocumentReadComplete, CloudReadDocument);
	Cloud.AddDelegate(CSD_DocumentConflictDetected, CloudConflictDetected);

	AdManager = class'PlatformInterfaceBase'.static.GetInGameAdManager();
	AdManager.AddDelegate(AMD_ClickedBanner, OnUserClickedAdvertisement);
	AdManager.AddDelegate(AMD_UserClosedAd, OnUserClosedAdvertisement);

	Facebook = class'PlatformInterfaceBase'.static.GetFacebookIntegration();
	Facebook.AddDelegate(FID_AuthorizationComplete, OnFBAuthComplete);
	Facebook.AddDelegate(FID_FriendsListComplete, OnFBFriendsListComplete);
	Facebook.AddDelegate(FID_DialogComplete, OnFBDialogComplete);
	Facebook.AddDelegate(FID_FacebookRequestComplete, OnFBRequestComplete);

	MicroTrans = class'PlatformInterfaceBase'.static.GetMicroTransactionInterface();
// 	MicroTrans.AddDelegate(MTD_PurchaseQueryComplete, OnProductQueryComplete);
// 	MicroTrans.AddDelegate(MTD_PurchaseComplete, OnProductPurchaseComplete);

	Twitter = class'PlatformInterfaceBase'.static.GetTwitterIntegration();
	Twitter.AddDelegate(TID_TweetUIComplete, OnTweetComplete);
	Twitter.AddDelegate(TID_RequestComplete, OnTwitterRequestComplete);
	Twitter.AddDelegate(TID_AuthorizeComplete, OnTwitterAuthorizeComplete);
	Twitter.AuthorizeAccounts();

	// make a save data object
	SaveData = new class'CloudSaveData';

	// look for existing documents
	CloudGetDocs();
}

// Cleanup
event Destroyed()
{
	super.Destroyed();

	Cloud.ClearDelegate(CSD_ValueChanged, CloudValueChanged);
	Cloud.ClearDelegate(CSD_DocumentReadComplete, CloudReadDocument);
	Cloud.ClearDelegate(CSD_DocumentConflictDetected, CloudConflictDetected);

	AdManager.ClearDelegate(AMD_ClickedBanner, OnUserClickedAdvertisement);
	AdManager.ClearDelegate(AMD_UserClosedAd, OnUserClosedAdvertisement);

	Facebook.ClearDelegate(FID_AuthorizationComplete, OnFBAuthComplete);
	Facebook.ClearDelegate(FID_FacebookRequestComplete, OnFBRequestComplete);

// 	MicroTrans.ClearDelegate(MTD_PurchaseQueryComplete, OnProductQueryComplete);
// 	MicroTrans.ClearDelegate(MTD_PurchaseComplete, OnProductPurchaseComplete);
}




exec function CloudGameFight()
{
	SaveData.Exp += Rand(20);
	SaveData.Gold += Rand(10);
}

exec function CloudGameSave(int Slot)
{
	local int DocIndex;

	Cloud = class'PlatformInterfaceBase'.static.GetCloudStorageInterface();
	DocIndex = Slot == 1 ? Slot1DocIndex : Slot2DocIndex;

	if (DocIndex == -1)
	{
		`log("Creating new save slot");
		DocIndex = Cloud.CreateCloudDocument("" $ Slot $ "_Save.bin");
	
		if (Slot == 1)
		{
			Slot1DocIndex = DocIndex;
		}
		else
		{
			Slot2DocIndex = DocIndex;
		}
	}

	// save the document
	Cloud.SaveDocumentWithObject(DocIndex, SaveData, 0);
	Cloud.WriteCloudDocument(DocIndex);
}

exec function CloudGameLoad(int Slot)
{
	local int DocIndex;
	DocIndex = Slot == 1 ? Slot1DocIndex : Slot2DocIndex;

	if (DocIndex == -1)
	{
		`log("No save data in that slot");
		return;
	}

	// read the document
	Cloud.ReadCloudDocument(DocIndex);
}





function CloudLogValue(const out PlatformInterfaceDelegateResult Result)
{
	`log("Retrieved key " $ Result.Data.DataName $ ", with value:");
	switch (Result.Data.Type)
	{
		case PIDT_Int: `log(Result.Data.IntValue); break;
		case PIDT_Float: `log(Result.Data.FloatValue); break;
		case PIDT_String: `log(Result.Data.StringValue); break;
		case PIDT_Object: `log(Result.Data.ObjectValue); break;
	}
	Cloud.ClearDelegate(CSD_KeyValueReadComplete, CloudLogValue);
}

function CloudValueChanged(const out PlatformInterfaceDelegateResult Result)
{
	local PlatformInterfaceDelegateResult ImmediateResult;
	`log("Value " $ Result.Data.StringValue $ " changed with tag " $ Result.Data.DataName $ ". Assuming Integer typewhen reading:");

	Cloud.AddDelegate(CSD_KeyValueReadComplete, CloudLogValue);
	Cloud.ReadKeyValue(Result.Data.StringValue, PIDT_Int, ImmediateResult);
}

function CloudIncrementValue(const out PlatformInterfaceDelegateResult Result)
{
	local PlatformInterfaceData WriteData;

	`log("Retrieved value " $ Result.Data.IntValue);

	WriteData = Result.Data;
	WriteData.IntValue++;
	Cloud.WriteKeyValue("CloudTestKey", WriteData);

	Cloud.ClearDelegate(CSD_KeyValueReadComplete, CloudIncrementValue);
}

exec function CloudGetAndIncrement()
{
	local PlatformInterfaceDelegateResult ImmediateResult;
	Cloud.AddDelegate(CSD_KeyValueReadComplete, CloudIncrementValue);
	Cloud.ReadKeyValue("CloudTestKey", PIDT_Int, ImmediateResult);
}

function CloudGotDocuments(const out PlatformInterfaceDelegateResult Result)
{
	local int NumDocs, i, SlotNum;

	NumDocs = Cloud.GetNumCloudDocuments();

	`log("We have found " $ NumDocs $ " documents in the cloud:");
	for (i = 0; i < NumDocs; i++)
	{
		`log("  - " $ Cloud.GetCloudDocumentName(i));
		SlotNum = int(Left(Cloud.GetCloudDocumentName(i), 1));
		if (SlotNum == 1)
		{
			Slot1DocIndex = i;
		}
		else if (SlotNum == 2)
		{
			Slot2DocIndex = i;
		}
	}
}

function CloudReadDocument(const out PlatformInterfaceDelegateResult Result)
{
	local int DocumentIndex;
	DocumentIndex = Result.Data.IntValue;
	
	if (Result.bSuccessful)
	{
		SaveData = CloudSaveData(Cloud.ParseDocumentAsObject(DocumentIndex, class'CloudSaveData', 0));
	}
	else
	{
		`log("Failed to read document index " $ DocumentIndex);
	}
}

function CloudConflictDetected(const out PlatformInterfaceDelegateResult Result)
{
	`log("Aww, there's a conflict in " $ Cloud.GetCloudDocumentName(Result.Data.IntValue) $ 
		" . There are " $ Cloud.GetNumCloudDocuments(true) $ " versions. Going to resolve to newest version");

	// this is the easy way to resolve differences - just pick the newest one
	// @todo: test reading all versions and picking largest XP version
	Cloud.ResolveConflictWithNewestDocument();
}

function CloudGetDocs()
{
	Cloud.AddDelegate(CSD_DocumentQueryComplete, CloudGotDocuments);
	Cloud.QueryForCloudDocuments();
}






exec function CloudGameToggleAd()
{
	if (bAdHasBeenShown)
	{
		AdManager.HideBanner();
	}
	else
	{
		AdManager.ShowBanner(true);
	}
	bAdHasBeenShown = !bAdHasBeenShown;
}

/**
 * Called on all player controllers when an in-game advertisement has been clicked
 * on by the user. Game will probably want to pause, etc, at this point
 */
function OnUserClickedAdvertisement(const out PlatformInterfaceDelegateResult Result)
{
	`log("CloudPC::OnUserClickedBanner");
}

/**
 * Called on all player controllers when an in-game advertisement has been closed 
 * down (usually when user clicks Done or similar). Game will want to unpause, etc here.
 */
event OnUserClosedAdvertisement(const out PlatformInterfaceDelegateResult Result)
{
	`log("CloudPC::OnUserClosedAd");
}





function OnFBAuthComplete(const out PlatformInterfaceDelegateResult Result)
{
	`log("OnFBAuthComplete. Success? " $ Result.bSuccessful $ ". Result = " $ Result.Data.StringValue);
	bIsFBAuthenticating = false;
}

function OnFBRequestComplete(const out PlatformInterfaceDelegateResult Result)
{
	`log("OnFBRequestComplete. Success? " $ Result.bSuccessful $ ". Result = " $ Result.Data.StringValue);
}

function OnFBFriendsListComplete(const out PlatformInterfaceDelegateResult Result)
{
	`log("OnFBFriendsListComplete. Success? " $ Result.bSuccessful $ ". Result = " $ Result.Data.StringValue);
}

function OnFBDialogComplete(const out PlatformInterfaceDelegateResult Result)
{
	`log("OnFBDialogComplete. Success? " $ Result.bSuccessful $ ". Result = " $ Result.Data.StringValue);
}

exec function CloudGameFacebook()
{
//	local JsonObject PlayerStats, EquippedArray, InventoryArray, ItemData;
//	local string JsonString;

	local array<string>Params;
	local int i;

	if (!Facebook.IsAuthorized())
	{
		if (Facebook.Authorize() == true)
		{
			bIsFBAuthenticating = true;
		}
		return;
	}

/*

	PlayerStats = new class'JsonObject';
	PlayerStats.SetStringValue("accesstoken", Facebook.AccessToken);
	PlayerStats.SetIntValue("level", 5);
	PlayerStats.SetIntValue("currentXP", 123123);
	PlayerStats.SetIntValue("nextLevelXP", 125000);
	PlayerStats.SetIntValue("statHealth", 84);
	PlayerStats.SetIntValue("statShield", 15);
	PlayerStats.SetIntValue("statDamage", 18);
	PlayerStats.SetIntValue("statMagic", 60);
	PlayerStats.SetIntValue("avaiableStatPoints", 5);
	PlayerStats.SetIntValue("rebalanceStatsCount", 3);
	PlayerStats.SetIntValue("currentBloodline", 2);
	PlayerStats.SetIntValue("currentPlaythrough", 1);
	PlayerStats.SetIntValue("godKingLevel", 99);
	PlayerStats.SetIntValue("currentGold", 45000);

	EquippedArray = new class'JsonObject';
	EquippedArray.ValueArray[0] = "\\#0";
	EquippedArray.ValueArray[1] = "\\#2";
	PlayerStats.SetObject("EquippedItems", EquippedArray);

	InventoryArray = new class'JsonObject';
		ItemData = new class'JsonObject';
		ItemData.SetStringValue("itemName", "CrapSword");
		ItemData.SetIntValue("xpGainedFromItem", 200);
		ItemData.SetIntValue("count", 1);
		ItemData.SetIntValue("numTimesMastered", 0);
		InventoryArray.ObjectArray[InventoryArray.ObjectArray.length] = ItemData;

		ItemData = new class'JsonObject';
		ItemData.SetStringValue("itemName", "Potion");
		ItemData.SetIntValue("xpGainedFromItem", 0);
		ItemData.SetIntValue("count", 10);
		ItemData.SetIntValue("numTimesMastered", 0);
		InventoryArray.ObjectArray[InventoryArray.ObjectArray.length] = ItemData;

		ItemData = new class'JsonObject';
		ItemData.SetStringValue("itemName", "HornOfPlenty");
		ItemData.SetIntValue("xpGainedFromItem", 100);
		ItemData.SetIntValue("count", 2);
		ItemData.SetIntValue("numTimesMastered", 1);
		InventoryArray.ObjectArray[InventoryArray.ObjectArray.length] = ItemData;
	PlayerStats.SetObject("PlayerInventory", InventoryArray);

	PlayerStats.SetIntValue("maxBloodline", 4);
	PlayerStats.SetIntValue("maxPlaythrough", 2);
	PlayerStats.SetIntValue("maxGodKingLevelDefeated", 15);
	PlayerStats.SetIntValue("fightFinishCount", 100);
	PlayerStats.SetIntValue("totalGoldAcquired", 10002030);
	PlayerStats.SetIntValue("totalGoldBoughtMicro", 20000);
	PlayerStats.SetIntValue("totalDodges", 513);
	PlayerStats.SetIntValue("totalBlocks", 290);
	PlayerStats.SetIntValue("totalHits", 1459);
	PlayerStats.SetIntValue("totalCombos", 672);
	PlayerStats.SetIntValue("totalParries", 101);
	PlayerStats.SetIntValue("totalSuperMoves", 23);
	PlayerStats.SetIntValue("totalMagicCasts", 48);

	// encode it to a string
	JsonString = class'JsonObject'.static.EncodeJson(PlayerStats);
	
	`log("Json = " $ JsonString);

	// 	// upload fake stats
 	Facebook.WebRequest("https://ibstats.cloudapp.net/Upload/", JsonString);

 	Facebook.WebRequest("http://www.google.com", "get", "", 1, false, false);//true);
 	Facebook.WebRequest("https://www.google.com/logos/classicplus.png", "get", "", 2, true, false);
*/

	`log("Facebook friends:" @ Facebook.FriendsList.length);

	// print out friends
	for (i = 0; i < Facebook.FriendsList.length; i++)
	{
		`log(Facebook.FriendsList[i].Name @ Facebook.FriendsList[i].Id);
	}

	// post to wall
	Params.AddItem("message"); Params.AddItem("Shouldn't see this");
	Params.AddItem("link"); Params.AddItem("www.google.com");
	Params.AddItem("picture"); Params.AddItem("http://yourkidsartsucks.com/wp-content/uploads/2011/10/Funny_Art_223.jpg");
	Params.AddItem("name"); Params.AddItem("Yes, hotness");
	Params.AddItem("caption"); Params.AddItem("This is an post");
	Params.AddItem("description"); Params.AddItem("I'm playing with posting to wall from UE3. Enjoy this mightily.");

	Facebook.FacebookDialog("feed", Params);
}

exec function CloudGameFBFriendsRequest()
{
	Facebook.FacebookRequest("me/friends");
}

exec function CloudGameFBGroupsRequest()
{
	Facebook.FacebookRequest("me/groups");
}

function OnProductQueryComplete(const out PlatformInterfaceDelegateResult Result)
{
`if( `notdefined(FINAL_RELEASE) )
	local int i;
	local PurchaseInfo Info;
	for (i = 0; i < MicroTrans.AvailableProducts.length; i++)
	{
		Info = MicroTrans.AvailableProducts[i];
		`log("Purchase " $ i $ ":");
		`log("  " $ Info.Identifier $ " - " $ Info.DisplayName $ " / " $ Info.DisplayPrice $ " - " $ Info.DisplayDescription);
	}
`endif
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

exec function MicroQueryProducts()
{
	MicroTrans.QueryForAvailablePurchases();
}


exec function CloudGameBuyConsumable()
{
//	MicroTrans.BeginPurchase(1);
	MPI.OpenMenuScene(class'CloudMenuMicroTrans');
}



exec function CloudGameTwitter()
{
	`log("Twitter can show tweet ui? " $ Twitter.CanShowTweetUI());

	if (Twitter.CanShowTweetUI())
	{
		Twitter.ShowTweetUI("Default tweet!", "http://www.epicgames.com", "Icon");
	}
}

function OnTweetComplete(const out PlatformInterfaceDelegateResult Result)
{
	`log("Tweet completed: " $ Result.bSuccessful);
}

function OnTwitterRequestComplete(const out PlatformInterfaceDelegateResult Result)
{
	`log("Tweet request compelted: " $ Result.bSuccessful @ Result.Data.StringValue);
}

function OnTwitterAuthorizeComplete(const out PlatformInterfaceDelegateResult Result)
{
	local array<string> KeyValues;
	local int i;
	`log("Authorization complete, num accounts: " $ Twitter.GetNumAccounts());

	if (Twitter.GetNumAccounts() > 0)
	{
		for (i=0; i<Twitter.GetNumAccounts(); i++)
		{
			`log(Twitter.GetAccountName(i));
		}
		KeyValues.AddItem("status");
		KeyValues.AddItem("UE3 auto tweet. Ignore me.");
		Twitter.TwitterRequest("http://api.twitter.com/1/statuses/update.json", KeyValues, TRM_POST, 0);
	}
}


defaultproperties
{
	InputClass=class'GameFramework.MobilePlayerInput'

	AutoRotationAccelRate=10000.0
	AutoRotationBrakeDecelRate=10000.0
	MaxAutoRotationVelocity=300000
	
	BreathAutoRotationAccelRate=250.0
	BreathAutoRotationBrakeDecelRate=1.0
	MaxBreathAutoRotationVelocity=75

	TimeBetweenCameraBreathChanges = 2.0
	
	RangeBasedYawAccelStrength=8.0
	RangeBasedAccelMaxDistance=512.0

}