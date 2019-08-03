class Rx_GFxPauseMenu_Scoreboard extends Rx_GFxPauseMenu_View;

var Rx_GFxPauseMenu PauseMenu;
var GFxObject CurrentView;
var GFxObject GDITeamPoints, NodTeamPoints;

var GFxObject AGTIcon, ObeliskIcon;
var GFxObject BarracksIcon, HandOfNodIcon;
var GFxObject WarFactoryIcon, AirstripIcon;
var GFxObject GDIRefineryIcon, NodRefineryIcon;
var GFxObject GDIPowerPlantIcon, NodPowerPlantIcon;


var GFxClikWidget GDIPlayerList, NodPlayerList;

/** Configures the view when it is first loaded. */
function OnViewLoaded(Rx_GFxPauseMenu Menu)
{
	PauseMenu = Menu;
	CurrentView = GetObject("currentView");

	GDITeamPoints = CurrentView.GetObject("GDITeamPoints");
	NodTeamPoints = CurrentView.GetObject("NodTeamPoints");

	AGTIcon = CurrentView.GetObject("agt");
	ObeliskIcon = CurrentView.GetObject("obelisk");
	BarracksIcon = CurrentView.GetObject("barracks");
	HandOfNodIcon = CurrentView.GetObject("handOfNod");
	WarFactoryIcon = CurrentView.GetObject("warFactory");
	AirstripIcon = CurrentView.GetObject("airstrip");
	GDIRefineryIcon = CurrentView.GetObject("refineryGDI");
	NodRefineryIcon = CurrentView.GetObject("refineryNod");
	GDIPowerPlantIcon = CurrentView.GetObject("powerPlantGDI");
	NodPowerPlantIcon = CurrentView.GetObject("powerPlantNod");

	SetupBuildingIcons();

}
function SetupBuildingIcons() 
{
	local Rx_Building building;

	BarracksIcon.SetVisible(false);
	HandOfNodIcon.SetVisible(false);
	WarFactoryIcon.SetVisible(false);
	AirstripIcon.SetVisible(false);
	GDIRefineryIcon.SetVisible(false);
	NodRefineryIcon.SetVisible(false);
	GDIPowerPlantIcon.SetVisible(false);
	NodPowerPlantIcon.SetVisible(false);
	AGTIcon.SetVisible(false);
	ObeliskIcon.SetVisible(false);

	foreach GetPC().AllActors(class'Rx_Building', building) {
		if (Rx_Building_GDI_InfantryFactory(building) != none) {
			BarracksIcon.SetVisible(true);
			BarracksIcon.GetObject("icon").GotoAndStopI(3);
		} else if (Rx_Building_Nod_InfantryFactory(building) != none) {
			HandOfNodIcon.SetVisible(true);
			HandOfNodIcon.GetObject("icon").GotoAndStopI(5);
		} else if (Rx_Building_GDI_VehicleFactory(building) != none) {
			WarFactoryIcon.SetVisible(true);
			WarFactoryIcon.GetObject("icon").GotoAndStopI(2);
		} else if (Rx_Building_Nod_VehicleFactory(building) != none) {
			AirstripIcon.SetVisible(true);
			AirstripIcon.GetObject("icon").GotoAndStopI(6);
		} else if (Rx_Building_GDI_MoneyFactory(building) != none) {
			GDIRefineryIcon.SetVisible(true);
			GDIRefineryIcon.GetObject("icon").GotoAndStopI(7);
		} else if (Rx_Building_Nod_MoneyFactory(building) != none) {
			NodRefineryIcon.SetVisible(true);
			NodRefineryIcon.GetObject("icon").GotoAndStopI(7);
		} else if (Rx_Building_GDI_PowerFactory(building) != none) {
			GDIPowerPlantIcon.SetVisible(true);
			GDIPowerPlantIcon.GetObject("icon").GotoAndStopI(8);
		} else if (Rx_Building_Nod_PowerFactory(building) != none) {
			NodPowerPlantIcon.SetVisible(true);
			NodPowerPlantIcon.GetObject("icon").GotoAndStopI(8);
		} else if (Rx_Building_GDI_Defense(building) != none) {
			AGTIcon.SetVisible(true);
			AGTIcon.GetObject("icon").GotoAndStopI(1);
		} else if (Rx_Building_Nod_Defense(building) != none) {
			ObeliskIcon.SetVisible(true);
			ObeliskIcon.GetObject("icon").GotoAndStopI(4);
		}
	}
}
/**Called every update Tick*/
function TickHUD() 
{
	local Rx_Building building;

	if (!bMovieIsOpen) {
		return;
	}

	if(GetPC() == None || Rx_GRI(GetPC().WorldInfo.GRI) == None) {
		return; 
	}


	foreach GetPC().AllActors(class'Rx_Building', building) {
		UpdateBuildingIcon(Rx_Building_GDI_InfantryFactory(building), BarracksIcon);
		UpdateBuildingIcon(Rx_Building_Nod_InfantryFactory(building), HandOfNodIcon);
		UpdateBuildingIcon(Rx_Building_GDI_VehicleFactory(building), WarFactoryIcon);
		UpdateBuildingIcon(Rx_Building_Nod_VehicleFactory(building), AirstripIcon);
		UpdateBuildingIcon(Rx_Building_GDI_MoneyFactory(building), GDIRefineryIcon);
		UpdateBuildingIcon(Rx_Building_Nod_MoneyFactory(building), NodRefineryIcon);
		UpdateBuildingIcon(Rx_Building_GDI_PowerFactory(building), GDIPowerPlantIcon);
		UpdateBuildingIcon(Rx_Building_Nod_PowerFactory(building), NodPowerPlantIcon);
		UpdateBuildingIcon(Rx_Building_GDI_Defense(building), AGTIcon);
		UpdateBuildingIcon(Rx_Building_Nod_Defense(building), ObeliskIcon);
	}

	GDITeamPoints.SetText(Rx_TeamInfo(GetPC().WorldInfo.GRI.Teams[TEAM_GDI]).GetRenScore());
	NodTeamPoints.SetText(Rx_TeamInfo(GetPC().WorldInfo.GRI.Teams[TEAM_NOD]).GetRenScore());	
}

function UpdateBuildingIcon(Rx_Building building, GFxObject icon)
{
	local float buildingHealth;
	local float buildingArmor;
	local GFxObject buildingIconHealth;
	local GFxObject buildingIconArmor;

	if (icon == none ) {
		return;
	}

	if (building == none) {
		//icon.SetVisible(false); //place this in Setup function
		return;
	}
	//icon.SetVisible(true); //place this in setup function
	buildingHealth = (float(building.GetHealth()) / float(building.GetTrueMaxHealth())) * 100.0;
	buildingArmor = (float(building.GetArmor()) / float(building.GetMaxArmor())) * 100.0; //If it's used for drawing, use MaxVisualArmor
	if (buildingHealth <= 0.0) {
		icon.GotoAndStopI(2);
	} else {
		icon.GotoAndStopI(1);
		buildingIconHealth = icon.GetObject("healthBar");
		if (int(buildingHealth) == 100) {
			buildingIconHealth.GotoAndStopI(18);
		} else if (int(buildingHealth) == 0) {
			buildingIconHealth.GotoAndStopI(1);
		} else {
			buildingIconHealth.GotoAndStopI(Clamp(int(buildingHealth/6.0), 1, 16) + 1);
		}
		
		buildingIconArmor = icon.GetObject("armorBar");
		if (int(buildingArmor) == 100) {
			buildingIconArmor.GotoAndStopI(18);
		} else if (int(buildingArmor) == 0) {
			buildingIconArmor.GotoAndStopI(1);
		} else {
			buildingIconArmor.GotoAndStopI(Clamp(int(buildingArmor/6.0), 1, 16) + 1);
		}

	}
}

function bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	/*
 * == RenXScrollingList example
			var dataArray:Array = new Array();
			for (var i=0; i<32; i++) {
				dataArray.push({playerNum:i+1, MVPStatus:"MVP *10", isMVP:true, playerScore:"1337", playerKill:"777", playerDeath:"7008", playerKDRatio:"1.00", playerPing:"10", playerName:"player " + (i+1)});
				//dataArray.push("player " + i);
			}

			GDIPayerList.rowCount = dataArray.length;
			NodPlayerList.rowCount = dataArray.length;
			//donateScrollingList.autoScrollBar = true;
			//donateScrollingList.wrapping = "stick";
			GDIPayerList.dataProvider = dataArray;
			NodPlayerList.dataProvider = dataArray;
			//donateScrollingList.rowCount = 9;
 * ==
 * */
	switch(WidgetName) 
	{
		case 'GDIPayerList':
			if (GDIPlayerList == none || GDIPlayerList != Widget) {
				GDIPlayerList = GFxClikWidget(Widget);
			}
			SetUpDataProvider(GDIPlayerList);
			GetLastSelection(GDIPlayerList);
			break;
		case 'NodPlayerList':
			if (NodPlayerList == none || NodPlayerList != Widget) {
				NodPlayerList = GFxClikWidget(Widget);
			}
			SetUpDataProvider(NodPlayerList);
			GetLastSelection(NodPlayerList);
			break;
		default:
			//GetPC().ClientMessage("" $ self $ "-> " $ WidgetName);
			break;
	}
	return true;
}

function SetUpDataProvider(GFxClikWidget Widget)
{
	local byte i;
	local GFxObject DataProvider;
	local GFxObject TempObj;

	local array<PlayerReplicationInfo> PRIArray;
	local PlayerReplicationInfo PRI;	

	DataProvider = CreateArray();

			//dataArray.push({
			//playerNum:i+1, 
			//MVPStatus:"MVP *10", 
			//isMVP:true, 
			//playerScore:"1337", 
			//playerKill:"777", 
			//playerDeath:"7008", 
			//playerKDRatio:"1.00", 
			//playerPing:"10", 
			//playerName:"player " + (i+1)});

	switch (Widget) 
	{
		case (GDIPlayerList):
			foreach GetPC().WorldInfo.GRI.PRIArray(PRI) {
				if (Rx_PRI(PRI) == none || PRI.GetTeamNum() != TEAM_GDI) {
					continue;
				}
				PRIArray.AddItem(PRI);
				//sort
			}
			PRIArray.Sort(SortPriDelegate);

			//assigning data to the list
			
			Widget.SetInt("rowCount", PRIArray.Length);

			for (i=0; i < PRIArray.Length; i++) {
				TempObj = CreateObject("Object");

				TempObj.SetInt("playerNum", i+1);
				TempObj.SetString("MVPStatus", ""); //TEMP
				TempObj.SetBool("isMVP", false);//TEMP
				TempObj.SetInt("playerScore", Rx_PRI(PRIArray[i]).GetRenScore());
				TempObj.SetInt("playerKill", Rx_PRI(PRIArray[i]).GetRenKills());
				TempObj.SetInt("playerDeath", Rx_PRI(PRIArray[i]).Deaths);
				TempObj.SetFloat("playerKDRatio", Rx_PRI(PRIArray[i]).GetKDRatio());
				TempObj.SetInt("playerPing", Rx_PRI(PRIArray[i]).Ping * 4);
				TempObj.SetString("playerName", "" $ Rx_PRI(PRIArray[i]).PlayerName);

				DataProvider.SetElementObject(i, TempObj);
			}

			break;
		case (NodPlayerList):
			foreach GetPC().WorldInfo.GRI.PRIArray(PRI) {
				if (Rx_PRI(PRI) == none || PRI.GetTeamNum() != TEAM_NOD) {
					continue;
				}
				PRIArray.AddItem(PRI);
				//sort
			}
			PRIArray.Sort(SortPriDelegate);

			//assigning data to the list
			
			Widget.SetInt("rowCount", PRIArray.Length);

			for (i=0; i < PRIArray.Length; i++) {
				TempObj = CreateObject("Object");

				TempObj.SetInt("playerNum", i+1);
				TempObj.SetString("MVPStatus", ""); //TEMP
				TempObj.SetBool("isMVP", false);//TEMP
				TempObj.SetInt("playerScore", Rx_PRI(PRIArray[i]).GetRenScore());
				TempObj.SetInt("playerKill", Rx_PRI(PRIArray[i]).GetRenKills());
				TempObj.SetInt("playerDeath", Rx_PRI(PRIArray[i]).Deaths);
				TempObj.SetFloat("playerKDRatio", Rx_PRI(PRIArray[i]).GetKDRatio());
				TempObj.SetInt("playerPing", Rx_PRI(PRIArray[i]).Ping * 4);
				TempObj.SetString("playerName", "" $ Rx_PRI(PRIArray[i]).PlayerName);

				DataProvider.SetElementObject(i, TempObj);
			}
			break;
		default:
			return;
	}
	Widget.SetObject("dataProvider", DataProvider);
}

function GetLastSelection(GFxClikWidget Widget)
{
	local byte i;
	local GFxObject dataProvider;
	if (Widget != none ) {
		switch (Widget) 
		{
		case (GDIPlayerList):
			dataProvider = Widget.GetObject("dataProvider");
			for (i=0; i < dataProvider.GetInt("length"); i++) {
				if (dataProvider.GetElementMemberString(i, "playerName") != GetPC().Pawn.PlayerReplicationInfo.PlayerName) {
					continue;
				}
				Widget.SetInt("selectedIndex", i);
			}
			break;
		case (NodPlayerList):
			dataProvider = Widget.GetObject("dataProvider");
			for (i=0; i < dataProvider.GetInt("length"); i++) {
				if (dataProvider.GetElementMemberString(i, "playerName") != GetPC().Pawn.PlayerReplicationInfo.PlayerName) {
					continue;
				}
				Widget.SetInt("selectedIndex", i);
			}
			break;
			default:
				return;
		}
	}
}
function int SortPriDelegate( coerce PlayerReplicationInfo pri1, coerce PlayerReplicationInfo pri2 )
{
	if (Rx_PRI(pri1) != none && Rx_PRI(pri2) != none) {
		if (Rx_PRI(pri1).GetRenScore() > Rx_PRI(pri2).GetRenScore()) {
			return 1;
		} else if (Rx_PRI(pri1).GetRenScore() == Rx_PRI(pri2).GetRenScore()) {
			return 0;
		} else {
			return -1;
		}
	}
	return 0;
}
DefaultProperties
{
	SubWidgetBindings.Add((WidgetName="GDIPayerList",WidgetClass=class'GFxClikWidget'))
	SubWidgetBindings.Add((WidgetName="NodPlayerList",WidgetClass=class'GFxClikWidget'))
}
