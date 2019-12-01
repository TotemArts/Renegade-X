class Rx_GFxPurchaseMenu_Coop extends Rx_GFxPurchaseMenu;

function TickHUD() 
{
	local Rx_TeamInfo rxTeamInfo;
	local byte i, j;
	local int data, NumNodVehicles, NumGDIVehicles;
	local Rx_Vehicle RxV;
	local bool bIsAircraft;

	if (!bMovieIsOpen) {
		return;
	}

	rxTeamInfo = Rx_TeamInfo(rxPRI.Team);

	if (PlayerCredits != rxPRI.GetCredits()){
		PlayerCredits = rxPRI.GetCredits();
		CreditsButton.SetString("label", "Credits: "$int(PlayerCredits));
	}

	if (VehicleCount != rxTeamInfo.GetVehicleCount()){
		VehicleCount = rxTeamInfo.GetVehicleCount();
		
		if (VehicleCount ==  Clamp(VehicleCount, 1, 10)) {
			VehicleInfoButton.GetObject("vehicleCount").SetVisible(true);
			VehicleInfoButton.GetObject("vehicleCount").GotoAndStopI(VehicleCount);

			i = 0;			
			foreach rxPC.WorldInfo.AllPawns(class'Rx_Vehicle', RxV) {
				if (RxV.GetTeamNum() != TeamID || i > VehicleCount) {
					continue;
				} 
				if (TeamID == TEAM_GDI){
					for (j=0; j < rxPurchaseSystem.GDIVehicleClasses.Length; j++) {
						if (RxV.Class != rxPurchaseSystem.GDIVehicleClasses[j]) {
							continue;
						}
						VehicleInfoButton.GetObject("vehicleCount").GetObject("icon"$i).GotoAndStopI(GDIVehicleMenuData[j].iconID);
						//the following is the test
						LoadTexture("img://" $ PathName(GDIVehicleMenuData[j].PTIconTexture), VehicleInfoButton.GetObject("vehicleCount").GetObject("icon"$i));
						//end test
					}
				} else if (TeamID == TEAM_NOD) {
					for (j=0; j < rxPurchaseSystem.NodVehicleClasses.Length; j++) {
						if (RxV.Class != rxPurchaseSystem.NodVehicleClasses[j]) {
							continue;
						}
						VehicleInfoButton.GetObject("vehicleCount").GetObject("icon"$i).GotoAndStopI(NodVehicleMenuData[j].iconID);
						//the following is the test
						LoadTexture("img://" $ PathName(NodVehicleMenuData[j].PTIconTexture), VehicleInfoButton.GetObject("vehicleCount").GetObject("icon"$i));
						//end test
					}
				}
				i++;
			}
		} else {
			VehicleInfoButton.GetObject("vehicleCount").SetVisible(false);
			if (VehicleCount > 10) {
				`log("<PT Log> WARNING: vehicle exceeding the game vehicle limit");
			}
		}

		VehicleInfoButton.SetString("label", "Vehicles: " $ VehicleCount $" / " $ rxTeamInfo.VehicleLimit);
		MainMenuButton[7].SetString("vehicleCountLabel", "( "$ VehicleCount $ " )");
		//vehicle button number update here
		
	}


	/** Disable for now
	if (!EquipSideArmButton.GetBool("selected")) {
		if (EquipSideArmList.GetBool("visible")) {
			if (TeamID == TEAM_GDI) {
				GetVariableObject("_root.equipmentDrawer.tween.equipsidearm.GDIListArrow").SetVisible(false);
			} else {
				GetVariableObject("_root.equipmentDrawer.tween.equipsidearm.NodListArrow").SetVisible(false);
			}
			EquipSideArmList.SetVisible(false);
		}
	}

	if (!EquipExplosivesButton.GetBool("selected")) {
		if (EquipExplosivesList.GetBool("visible")) {
			if (TeamID == TEAM_GDI) {
				GetVariableObject("_root.equipmentDrawer.tween.equipexplosives.GDIListArrow").SetVisible(false);
			} else {
				GetVariableObject("_root.equipmentDrawer.tween.equipexplosives.NodListArrow").SetVisible(false);
			}
			EquipExplosivesList.SetVisible(false);
		}
	}
*/
	//Pay Class Condition

	
	if (bClassDrawerOpen) 
	{
		for (i = 0; i < 10; i++) 
		{
			data = int(ClassMenuButton[i].GetString("data"));
			if(Rx_PurchaseSystem_Coop(rxPurchaseSystem).DoesClassExist(TeamID,i + 5))
 				ClassMenuButton[i].SetBool("enabled", TeamID == TEAM_GDI ? GDIClassMenuData[i].bEnable : NodClassMenuData[i].bEnable);
 			else
 			{
				ClassMenuButton[i].SetBool("selected", false);
				ClassMenuButton[i].SetBool("visible", false);
				ClassMenuButton[i].SetBool("enabled", false);
 			}
		}
	} 
	else if (bMainDrawerOpen) 
	{
		TickMainMenuButtons();	
	}

	//Vehicle Condition

	if (rxPurchaseSystem.AreVehiclesDisabled(TeamID, rxPC)) {
		if (bVehicleDrawerOpen) {
 			
			for(i=0; i < 10; i++) {
				if (!VehicleMenuButton[i].GetBool("enabled")) {
					continue;
				}
 				VehicleMenuButton[i].SetBool("selected", false);
 				VehicleMenuButton[i].SetBool("enabled", false);
 			}
			SelectBack();
			MainMenuButton[7].SetString("sublabel", rxPurchaseSystem.GetFactoryDescription(TeamID, (TeamID == TEAM_GDI ? GDIMainMenuData[7].title : NodMainMenuData[7].title), rxPC ));
			MainMenuButton[7].SetBool("selected", false);
			MainMenuButton[7].SetBool("enabled", false);
		} else if (bMainDrawerOpen) {
			MainMenuButton[7].SetString("sublabel", rxPurchaseSystem.GetFactoryDescription(TeamID, (TeamID == TEAM_GDI ? GDIMainMenuData[7].title : NodMainMenuData[7].title), rxPC));
			MainMenuButton[7].SetBool("selected", false);
			MainMenuButton[7].SetBool("enabled", false);
		}
	} else {
		if (bVehicleDrawerOpen) {
 			for(i=0; i < 10; i++) {
				
				
				if(!VehicleMenuButton[i].GetBool("visible")) continue;  
				data = int(VehicleMenuButton[i].GetString("data"));

				if (TeamID == TEAM_GDI) {
					if (GDIVehicleMenuData[data].bAircraft) {
 						bIsAircraft = true;
					}
				} else {
					if (NodVehicleMenuData[data].bAircraft) {
 						bIsAircraft = true;
					}
				}
				
				if((rxPurchaseSystem.AreHighTierVehiclesDisabled(TeamID) && i > 1 && !bIsAircraft)
				    || (rxPurchaseSystem.AreAirVehiclesDisabled(TeamID) && bIsAircraft)) //limit to buggies / APCs
				{
					if(!VehicleMenuButton[i].GetBool("enabled")) 
							continue; 

					VehicleMenuButton[i].SetBool("selected", false);
					VehicleMenuButton[i].SetBool("visible", false);
					VehicleMenuButton[i].SetBool("enabled", false);
				}

				if(TeamID == TEAM_GDI && GDIVehicleMenuData.Length > i)
 					VehicleMenuButton[i].SetBool("enabled", GDIVehicleMenuData[i].bEnable);
				else if(TeamID == TEAM_NOD && NodVehicleMenuData.Length > i)
					VehicleMenuButton[i].SetBool("enabled", NodVehicleMenuData[i].bEnable);


				if (rxBuildingOwner.AreAircraftDisabled()) {
					if (bIsAircraft) {
 						VehicleMenuButton[i].SetBool("selected", false);
 						VehicleMenuButton[i].SetBool("enabled", false);
					}
				}

 			}
		} else if (bMainDrawerOpen) {
			MainMenuButton[7].SetString("sublabel", rxPurchaseSystem.GetFactoryDescription(TeamID, (TeamID == TEAM_GDI ? GDIMainMenuData[7].title : NodMainMenuData[7].title), rxPC));
			MainMenuButton[7].SetBool("enabled", true);
		}
	}

	//silo condition
	/**if (!rxPurchaseSystem.AreSilosCaptured(TeamID)) {
		if (bWeaponDrawerOpen) {
			for (i=0; i < 7; i++) {
				data = int(WeaponMenuButton[i].GetString("data"));
				if (TeamID == TEAM_GDI) {
					if (GDIWeaponMenuData[data].bSilo){
						WeaponMenuButton[i].SetBool("selected", false);
						WeaponMenuButton[i].SetBool("enabled", false);
					}
				} else {
					if (NodWeaponMenuData[data].bSilo){
						WeaponMenuButton[i].SetBool("selected", false);
						WeaponMenuButton[i].SetBool("enabled", false);
					}
				}
			}
		}
	} else {
		if (bWeaponDrawerOpen) {
			for (i=0; i < 7; i++) {
				data = int(WeaponMenuButton[i].GetString("data"));
				if (TeamID == TEAM_GDI) {
					if (GDIWeaponMenuData[data].bSilo){
						WeaponMenuButton[i].SetBool("enabled", true);
					}
				} else {
					if (NodWeaponMenuData[i].bSilo){
						WeaponMenuButton[i].SetBool("enabled", true);
					}
				}
			}
		}
	}
	*/
	
	//payment conditions

		if (bClassDrawerOpen) {
			for (i = 0; i < 10; i++) {
				data = int(ClassMenuButton[i].GetString("data"));
				if (TeamID == TEAM_GDI) {
					if (!GDIClassMenuData[i].bEnable) {
						
						continue;
					}
				} else {
					if (!NodClassMenuData[i].bEnable) {
						continue;
					}
				}
				if (ClassMenuButton[i].GetBool("enabled") && PlayerCredits < rxPurchaseSystem.GetClassPrice(TeamID, IndexToClass(data, TeamID))){
					ClassMenuButton[i].SetBool("enabled", false);
				}
			}
		} else if (bVehicleDrawerOpen) 			
			{
				NumGDIVehicles = rxPurchaseSystem.GDIVehicleClasses.Length;
				NumNodVehicles = rxPurchaseSystem.NodVehicleClasses.Length; 
				for (i = 0; i < 10; i++) {

				data = int(VehicleMenuButton[i].GetString("data"));

				if (TeamID == TEAM_GDI) {
					if (GDIVehicleMenuData[data].bAircraft) {
 						bIsAircraft = true;
					}
				} else {
					if (NodVehicleMenuData[data].bAircraft) {
 						bIsAircraft = true;
					}
				}
					
				if((rxPurchaseSystem.AreHighTierVehiclesDisabled(TeamID) && i > 1 && !bIsAircraft)
				    || (rxPurchaseSystem.AreAirVehiclesDisabled(TeamID) && bIsAircraft)) //limit to buggies / APCs
				{
					if(VehicleMenuButton[i].GetBool("enabled")) 
						{
						VehicleMenuButton[i].SetBool("enabled",false); 					
						}
					continue; //No need to parse the info for everything else if it isn't enabled and visible.
					}
					data = int(VehicleMenuButton[i].GetString("data"));
					if (TeamID == TEAM_GDI && GDIVehicleMenuData.Length > i) {
						if (!GDIVehicleMenuData[i].bEnable) {
							continue;
						}
					} else if(TeamID == TEAM_NOD && NodVehicleMenuData.Length > i){
						if (!NodVehicleMenuData[i].bEnable) {
							continue;
						}
					}
					if (rxBuildingOwner.AreAircraftDisabled()) {
						if (bIsAircraft) {
							continue;
						}
					}
				
				
					if (TeamID == TEAM_GDI && NumGDIVehicles > i) {
						VehicleMenuButton[i].SetString("costLabel", "$" $ rxPurchaseSystem.GetVehiclePrices(TeamID, GDIVehicleMenuData[i].ID, rxPurchaseSystem.AirdropAvailable(rxPRI)));
					} else if (TeamID == TEAM_NOD && NumNodVehicles > i){
						VehicleMenuButton[i].SetString("costLabel", "$" $ rxPurchaseSystem.GetVehiclePrices(TeamID, NodVehicleMenuData[i].ID, rxPurchaseSystem.AirdropAvailable(rxPRI)));
					}				
				
					if (PlayerCredits > rxPurchaseSystem.GetVehiclePrices(TeamID, data, rxPurchaseSystem.AirdropAvailable(rxPRI)) ){
						VehicleMenuButton[i].SetBool("enabled", true);
					} else {
						VehicleMenuButton[i].SetBool("enabled", false);
					}
				}
		}	
		else if (bItemDrawerOpen) 
		{
			for (i = 0; i < 8; i++) {
//				data = int(ItemMenuButton[i].GetString("data"));
				data = i;
				if (TeamID == TEAM_GDI) 
				{
					if (i >= rxPurchaseSystem.GDIItemClasses.Length) 
					{
						continue;
					}
				} 
				else 
				{
					if (i >= rxPurchaseSystem.NodItemClasses.Length) 
					{
						continue;
					}
				}
				if (rxPurchaseSystem.IsItemBuyable(rxPC, TeamID, data) && PlayerCredits > rxPurchaseSystem.GetItemPrices(TeamID, data) && !rxPurchaseSystem.IsEquiped(rxPC, TeamID, data, CLASS_ITEM))
				{
					ItemMenuButton[i].SetBool("enabled", true);
				} 
				else 
				{
					ItemMenuButton[i].SetBool("enabled", false);
					if(ClassIsChildOf(rxPurchaseSystem.GetItemClass(TeamID,i),class'Rx_Weapon_Beacon') && !Rx_Gri(rxPC.WorldInfo.GRI).bEnableNuke)
					{
						ItemMenuButton[i].SetString("sublabel", Rx_Game(rxPC.WorldInfo.Game).MinPlayersForNukes $ " Players needed");
					}
				}
			}
		}

}

function SelectMenu(int selectedIndex)
{
	if (selectedIndex != Clamp(selectedIndex, 0, 9) || bIsInTransition) {
		return;
	}
`log("---------------" @ selectedIndex @ "---------------");

	switch (selectedIndex)
	{
		case 0: 
			if (bClassDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIClassMenuData[9].ID : NodClassMenuData[9].ID);
			} else if (bVehicleDrawerOpen) {
				ChangeDummyVehicleClass(TeamID == TEAM_GDI ? GDIVehicleMenuData[9].ID : NodVehicleMenuData[9].ID);
			}
			break;		
		case 1: 
			if (bMainDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIMainMenuData[selectedIndex-1].ID : NodMainMenuData[selectedIndex - 1].ID);
			} else if (bClassDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIClassMenuData[selectedIndex-1].ID : NodClassMenuData[selectedIndex - 1].ID);
			} else if (bVehicleDrawerOpen) {
				ChangeDummyVehicleClass(TeamID == TEAM_GDI ? GDIVehicleMenuData[selectedIndex-1].ID : NodVehicleMenuData[selectedIndex - 1].ID);
			}
			break;
		case 2: 
			if (bMainDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIMainMenuData[selectedIndex-1].ID : NodMainMenuData[selectedIndex - 1].ID);
			} else if (bClassDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIClassMenuData[selectedIndex-1].ID : NodClassMenuData[selectedIndex - 1].ID);
			} else if (bVehicleDrawerOpen) {
				ChangeDummyVehicleClass(TeamID == TEAM_GDI ? GDIVehicleMenuData[selectedIndex-1].ID : NodVehicleMenuData[selectedIndex - 1].ID);
			}
			break;
		case 3: 
			if (bMainDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIMainMenuData[selectedIndex-1].ID : NodMainMenuData[selectedIndex - 1].ID);
			} else if (bClassDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIClassMenuData[selectedIndex-1].ID : NodClassMenuData[selectedIndex - 1].ID);
			} else if (bVehicleDrawerOpen) {
				ChangeDummyVehicleClass(TeamID == TEAM_GDI ? GDIVehicleMenuData[selectedIndex-1].ID : NodVehicleMenuData[selectedIndex - 1].ID);
			}
			break;
		case 4: 
			if (bMainDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIMainMenuData[selectedIndex-1].ID : NodMainMenuData[selectedIndex - 1].ID);
			} else if (bClassDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIClassMenuData[selectedIndex-1].ID : NodClassMenuData[selectedIndex - 1].ID);
			} else if (bVehicleDrawerOpen) {
				ChangeDummyVehicleClass(TeamID == TEAM_GDI ? GDIVehicleMenuData[selectedIndex-1].ID : NodVehicleMenuData[selectedIndex - 1].ID);
			}
			break;
		case 5: 
			if (bMainDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIMainMenuData[selectedIndex-1].ID : NodMainMenuData[selectedIndex - 1].ID);
			} else if (bClassDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIClassMenuData[selectedIndex-1].ID : NodClassMenuData[selectedIndex - 1].ID);
			} else if (bVehicleDrawerOpen) {
				ChangeDummyVehicleClass(TeamID == TEAM_GDI ? GDIVehicleMenuData[selectedIndex-1].ID : NodVehicleMenuData[selectedIndex - 1].ID);
			}
			break;
		case 6: 
			if (bMainDrawerOpen) {
				rxPC.PlaySound(SoundCue'RenXPurchaseMenu.Sounds.RenXPTSoundRefill');
				
				//set the current weapon to defaults so we can force perform our loadouts
		
				if (rxPC.CurrentSidearmWeapon == none) {
					//rxPC.CurrentSidearmWeapon = class<Rx_InventoryManager>(rxPC.Pawn.InventoryManagerClass).default.SidearmWeapons[0];
					rxPC.CurrentSidearmWeapon = class'Rx_InventoryManager'.default.SidearmWeapons[0];
				}
				
				//`log("<PT Log> rxPC.CurrentExplosiveWeapon? " $ rxPC.CurrentExplosiveWeapon);
				if (rxPC.CurrentExplosiveWeapon == none) {
					if (rxPC.bJustBaughtEngineer 
					|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Hotwire' 
					|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Technician'){
						rxPC.RemoveAllExplosives();
						//class<Rx_InventoryManager>(rxPC.Pawn.InventoryManagerClass).default.ExplosiveWeapons[0]
						if (TeamID == TEAM_GDI) {
							rxPC.CurrentExplosiveWeapon = class'Rx_InventoryManager_GDI_Hotwire'.default.ExplosiveWeapons[0];
						} else {
							rxPC.CurrentExplosiveWeapon = class'Rx_InventoryManager_Nod_Technician'.default.ExplosiveWeapons[0];
						}
						//`log("<PT Log> new rxPC.CurrentExplosiveWeapon? " $ rxPC.CurrentExplosiveWeapon);
						rxPC.SetAdvEngineerExplosives(rxPC.CurrentExplosiveWeapon);
					} else if (rxPC.bJustBaughtHavocSakura 
					|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Havoc'
					|| Rx_Pawn(rxPC.Pawn).GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Sakura' ) {
						rxPC.RemoveAllExplosives();
						//rxPC.CurrentExplosiveWeapon = class'Rx_InventoryManager'.default.ExplosiveWeapons[0];
						if (TeamID == TEAM_GDI) {
							rxPC.CurrentExplosiveWeapon = class'Rx_InventoryManager_GDI_Havoc'.default.ExplosiveWeapons[0];
						} else {
							rxPC.CurrentExplosiveWeapon = class'Rx_InventoryManager_Nod_Sakura'.default.ExplosiveWeapons[0];
						}
						//`log("<PT Log> new rxPC.CurrentExplosiveWeapon? " $ rxPC.CurrentExplosiveWeapon);
						rxPC.AddExplosives(rxPC.CurrentExplosiveWeapon);
					}  else {
						rxPC.RemoveAllExplosives();
						rxPC.CurrentExplosiveWeapon = class'Rx_InventoryManager'.default.ExplosiveWeapons[0];
						//`log("<PT Log> new rxPC.CurrentExplosiveWeapon? " $ rxPC.CurrentExplosiveWeapon);
						rxPC.AddExplosives(rxPC.CurrentExplosiveWeapon);
					}
				}

				SetLoadout();
				rxPC.PerformRefill(rxPC);
				//rxPC.SwitchWeapon(0);
				ClosePTMenu(false);
			} else if (bClassDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIClassMenuData[selectedIndex-1].ID : NodClassMenuData[selectedIndex - 1].ID);
			} else if (bVehicleDrawerOpen) {
				if (TeamID == TEAM_NOD) {
					ChangeDummyVehicleClass(NodVehicleMenuData[selectedIndex - 1].ID);
				}
				else{
					ChangeDummyVehicleClass(GDIVehicleMenuData[selectedIndex - 1].ID);
				}
			}
			break;
		/**case 7: 
			if (bMainDrawerOpen) {
				if (GFxClikWidget(MainMenuGroup.GetObject("selectedButton", class'GFxClikWidget')) != none) {
					GFxClikWidget(MainMenuGroup.GetObject("selectedButton", class'GFxClikWidget')).SetBool("selected", false);
				}

				/check if there is something transitioning, fade out immidietly
				CancelCurrentAnimations();
				if (EquipmentDrawer.GetInt("currentFrame") != 20 && bEquipmentDrawerOpen) {
					EquipmentDrawer.GotoAndPlay("Fade Out");
				} 

				bIsInTransition = true;								
				MainDrawerFadeOut();
				EquipmentDrawerFadeOut();
				WeaponDrawerFadeIn();
				BottomWidgetFadeIn(BackTween);
				bIsInTransition = false;
			} else if (bClassDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIClassMenuData[selectedIndex-1].ID : NodClassMenuData[selectedIndex - 1].ID);
			} else if (bVehicleDrawerOpen) {
				if (!rxBuildingOwner.AreAircraftDisabled()) {
					ChangeDummyVehicleClass(TeamID == TEAM_GDI ? GDIVehicleMenuData[selectedIndex-2].ID : NodVehicleMenuData[selectedIndex - 1].ID);
				}
			}
			break;
		*/
		case 7: 
			if (bMainDrawerOpen) {
				if (GFxClikWidget(MainMenuGroup.GetObject("selectedButton", class'GFxClikWidget')) != none) {
					GFxClikWidget(MainMenuGroup.GetObject("selectedButton", class'GFxClikWidget')).SetBool("selected", false);
				}
				//check if there is something transitioning, fade out immidietly
				CancelCurrentAnimations();
				/**if (EquipmentDrawer.GetInt("currentFrame") != 20 && bEquipmentDrawerOpen) {
					EquipmentDrawer.GotoAndPlay("Fade Out");
				} */
				bIsInTransition = true;
				MainDrawerFadeOut();
				//EquipmentDrawerFadeOut();
				ItemDrawerFadeIn();
				BottomWidgetFadeIn(BackTween);
				bIsInTransition = false;
			} else if (bClassDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIClassMenuData[selectedIndex-1].ID : NodClassMenuData[selectedIndex - 1].ID);
			} else if (bVehicleDrawerOpen) {
				//if (!rxBuildingOwner.AreAircraftDisabled()) {
					ChangeDummyVehicleClass(TeamID == TEAM_GDI ? GDIVehicleMenuData[selectedIndex-1].ID : NodVehicleMenuData[selectedIndex - 1].ID);
				//}
			}
			break;
		case 8: 
			if (bMainDrawerOpen) 
			{ 
				if(Rx_PurchaseSystem_Coop(rxPurchaseSystem).AreClassOptionLimited(TeamID))
					return;

				if (GFxClikWidget(MainMenuGroup.GetObject("selectedButton", class'GFxClikWidget')) != none) {
					GFxClikWidget(MainMenuGroup.GetObject("selectedButton", class'GFxClikWidget')).SetBool("selected", false);
				}
				//check if there is something transitioning, fade out immidietly
				CancelCurrentAnimations();

				bIsInTransition = true;
				MainDrawerFadeOut();
				ClassDrawerFadeIn();
				BottomWidgetFadeIn(BackTween);
				bIsInTransition = false;
			}
			else if (bClassDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIClassMenuData[selectedIndex-1].ID : NodClassMenuData[selectedIndex - 1].ID);
			}
			else if (bVehicleDrawerOpen) {
				//if (!rxBuildingOwner.AreAircraftDisabled()) {
					ChangeDummyVehicleClass(TeamID == TEAM_GDI ? GDIVehicleMenuData[selectedIndex-1].ID : NodVehicleMenuData[selectedIndex - 1].ID);
				//}
			}
			break;
		case 9: 
			if (bMainDrawerOpen) 
			{
				if (!rxPurchaseSystem.AreVehiclesDisabled(TeamID, rxPC)) 
				{
					if (GFxClikWidget(MainMenuGroup.GetObject("selectedButton", class'GFxClikWidget')) != none) 
					{
						GFxClikWidget(MainMenuGroup.GetObject("selectedButton", class'GFxClikWidget')).SetBool("selected", false);
					}
					//check if there is something transitioning, fade out immidietly
					CancelCurrentAnimations();
				/**	if (EquipmentDrawer.GetInt("currentFrame") != 20 && bEquipmentDrawerOpen) {
						EquipmentDrawer.GotoAndPlay("Fade Out");
					} 
				*/
					bIsInTransition = true;
					rxPC.bIsInPurchaseTerminalVehicleSection = true;
					MainDrawerFadeOut();
					//EquipmentDrawerFadeOut();
					VehicleDrawerFadeIn();
					BottomWidgetFadeIn(BackTween);
					BottomWidgetFadeIn(VehicleInfoTween);
					bIsInTransition = false;
				}
			} 
			else if (bClassDrawerOpen){
				ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIClassMenuData[selectedIndex-1].ID : NodClassMenuData[selectedIndex - 1].ID); 
				//ChangeDummyPawnClass(TeamID == TEAM_GDI ? GDIClassMenuData[9].ID : NodClassMenuData[9].ID);
			}
			else if (bVehicleDrawerOpen) {
				//if (!rxBuildingOwner.AreAircraftDisabled()) {
					ChangeDummyVehicleClass(TeamID == TEAM_GDI ? GDIVehicleMenuData[selectedIndex-1].ID : NodVehicleMenuData[selectedIndex - 1].ID);
				//}
			}
			break;
	}
	
}

function TickMainMenuButtons()
{
	//local int i;
	
	MainMenuButton[6].SetString("sublabel", rxPurchaseSystem.GetFactoryDescription(TeamID, (TeamID == TEAM_GDI ? GDIMainMenuData[6].title : NodMainMenuData[6].title), rxPC));
	MainMenuButton[6].SetBool("enabled", !Rx_PurchaseSystem_Coop(rxPurchaseSystem).AreClassOptionLimited(TeamID));
	MainMenuButton[5].SetString("sublabel", rxPurchaseSystem.GetFactoryDescription(TeamID, "REFILL", rxPC));
	//MainMenuButton[5].SetBool("enabled", true);
	MainMenuButton[5].SetBool("enabled", rxPC.RefillCooldown() > 0 ? false : true);
	/**
	for (i = 0; i < 5; i++) {
 		MainMenuButton[i].SetBool("enabled", rxPC.RefillCooldown() > 0 ? false : true);
	}	*/
}