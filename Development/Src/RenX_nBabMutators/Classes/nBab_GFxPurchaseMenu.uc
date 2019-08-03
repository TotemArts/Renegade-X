class nBab_GFxPurchaseMenu extends Rx_GFxPurchaseMenu;

var protected class<Rx_FamilyInfo> Nbab_OwnedFamilyInfo;
var protected class<Rx_Weapon> Nbab_OwnedSidearm, Nbab_OwnedExplosive, Nbab_OwnedItem;
var Rx_CapturableMCT_Fort Fort;//nbab
var nBab_PT_Vehicle DummyVehicle2;
var nBab_PT_Pawn DummyPawn2;


function Initialize(LocalPlayer player, Rx_BuildingAttachment_PT PTOwner)
{	
	super.Initialize(player,PTOwner); 

//Override small stuff	
	ForEach class'WorldInfo'.static.GetWorldInfo().AllActors (class'Rx_CapturableMCT_Fort', Fort)
		break;//nbab
		
	rxPC						=	nBab_Controller(GetPC());

}

function TickHUD() 
{
	local Rx_TeamInfo rxTeamInfo;
	local byte i, j;
	local int data;
	local Rx_Vehicle RxV;

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
						//nbabtest
						//VehicleInfoButton.GetObject("vehicleCount").GetObject("icon"$i).GotoAndStopI(GDIVehicleMenuData[j].iconID);
						//the following is the test
						LoadTexture("img://" $ PathName(GDIVehicleMenuData[j].PTIconTexture), VehicleInfoButton.GetObject("vehicleCount").GetObject("icon"$i));
						//`log("FIRST = "$PathName(GDIVehicleMenuData[j].PTIconTexture));
						//`log("Second = "$VehicleInfoButton.GetObject("vehicleCount").GetObject("icon"$i));
						//end test

						//nbab
						//"btnVehicle"$i.GDIButton.icon
						

					}
				} else if (TeamID == TEAM_NOD) {
					for (j=0; j < rxPurchaseSystem.NodVehicleClasses.Length; j++) {
						if (RxV.Class != rxPurchaseSystem.NodVehicleClasses[j]) {
							continue;
						}
						//nbabtest
						//VehicleInfoButton.GetObject("vehicleCount").GetObject("icon"$i).GotoAndStopI(NodVehicleMenuData[j].iconID);
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

	if (rxPurchaseSystem.AreHighTierPayClassesDisabled(TeamID)) {
		if (bClassDrawerOpen) {
			//enabled deadeye/BHS when bar/hon is dead (nBab)
			for (i = 9; i > 3; i--) {
				if (!ClassMenuButton[i].GetBool("enabled")) {
					continue;
				}
				ClassMenuButton[i].SetBool("selected", false);
				ClassMenuButton[i].SetBool("visible", false);
				ClassMenuButton[i].SetBool("enabled", false);
			}
			//enabled deadeye/BHS when bar/hon is dead (nBab)
			for (i = 0; i < 4; i++) {
				data = int(ClassMenuButton[i].GetString("data"));
 				ClassMenuButton[i].SetBool("enabled", TeamID == TEAM_GDI ? GDIClassMenuData[i].bEnable : NodClassMenuData[i].bEnable);
			}			
		} else if (bMainDrawerOpen) {
			MainMenuButton[7].SetString("sublabel", rxPurchaseSystem.GetFactoryDescription(TeamID, (TeamID == TEAM_GDI ? GDIMainMenuData[6].title : NodMainMenuData[6].title), rxPC));
			MainMenuButton[7].SetBool("enabled", true);
		}
	} else {
		if (bClassDrawerOpen) {
			for (i = 0; i < 10; i++) {
				data = int(ClassMenuButton[i].GetString("data"));
 				ClassMenuButton[i].SetBool("enabled", TeamID == TEAM_GDI ? GDIClassMenuData[i].bEnable : NodClassMenuData[i].bEnable);
			}
		} else if (bMainDrawerOpen) {
			MainMenuButton[7].SetString("sublabel", rxPurchaseSystem.GetFactoryDescription(TeamID, (TeamID == TEAM_GDI ? GDIMainMenuData[6].title : NodMainMenuData[6].title), rxPC));
			MainMenuButton[7].SetBool("enabled", true);
		}
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
 			for(i=0; i < 9; i++) {
				
				//`log("Team ID = " @ TeamID);
				if(rxPurchaseSystem.AreHighTierVehiclesDisabled(TeamID) && i > 1) //limit to buggies / APCs
				{
					if(!VehicleMenuButton[i].GetBool("enabled")) 
							continue; 
					//enable bike and wolverine with airdrop (nBab)
					if (i==6) 
					{
						VehicleMenuButton[i].SetBool("visible", true);
						VehicleMenuButton[i].SetBool("enabled", true);
						continue;
					}

						//`log("Parsed through vehicles");
				VehicleMenuButton[i].SetBool("selected", false);
				VehicleMenuButton[i].SetBool("visible", false);
				VehicleMenuButton[i].SetBool("enabled", false);
						
					
				}
				
				data = int(VehicleMenuButton[i].GetString("data"));
 				VehicleMenuButton[i].SetBool("enabled", TeamID == TEAM_GDI ? GDIVehicleMenuData[i].bEnable : NodVehicleMenuData[i].bEnable);


 				//nBab
 				//`log("nbabGFXPURCHASE");
 				//`log("Fort.GetTeamNum() = "$Fort.GetTeamNum());
 				if (TeamID == TEAM_GDI && TeamID != Fort.GetTeamNum())
 				{
 					if (i>4 && i<9)
 					{
 						VehicleMenuButton[i].SetBool("selected", false);
 						VehicleMenuButton[i].SetBool("enabled", false);
 						//`log("in 4-8: "$i);
 					}	
 				}
 				/*if (TeamID == TEAM_GDI && i==8)
 					{
 						VehicleMenuButton[i].SetBool("selected", false);
						VehicleMenuButton[i].SetBool("visible", false);
						VehicleMenuButton[i].SetBool("enabled", false);
 					}*/
 				if (TeamID != TEAM_GDI && TeamID != Fort.GetTeamNum())
 				{
 					if (i>5 && i<9)
 					{
 						VehicleMenuButton[i].SetBool("selected", false);
 						VehicleMenuButton[i].SetBool("enabled", false);
 					}
 				}

				if (rxBuildingOwner.AreAircraftDisabled()) {
					if (TeamID == TEAM_GDI) {
						if (GDIVehicleMenuData[data].bAircraft) {
 							VehicleMenuButton[i].SetBool("selected", false);
 							VehicleMenuButton[i].SetBool("enabled", false);
						}
					} else {
						if (NodVehicleMenuData[data].bAircraft) {
 							VehicleMenuButton[i].SetBool("selected", false);
 							VehicleMenuButton[i].SetBool("enabled", false);
						}
					}
				}

 			}
		} else if (bMainDrawerOpen) {
			MainMenuButton[7].SetString("sublabel", rxPurchaseSystem.GetFactoryDescription(TeamID, (TeamID == TEAM_GDI ? GDIMainMenuData[7].title : NodMainMenuData[7].title), rxPC));
			MainMenuButton[7].SetBool("enabled", true);
		}
	}

	//silo condition
	//nbabweapon
	/*if (!rxPurchaseSystem.AreSilosCaptured(TeamID)) {
		if (bWeaponDrawerOpen) {
			for (i=0; i < 9; i++) {
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
			for (i=0; i < 9; i++) {
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
	}*/
	
	
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
				for (i = 0; i < 9; i++) {
					
					if(rxPurchaseSystem.AreHighTierVehiclesDisabled(TeamID) && i > 1 && i!=6)
					{
					if(VehicleMenuButton[i].GetBool("enabled")) 
						{
						VehicleMenuButton[i].SetBool("enabled",false); 					
						}
					continue; //No need to parse the info for everything else if it isn't enabled and visible.
					}
					data = int(VehicleMenuButton[i].GetString("data"));
					if (TeamID == TEAM_GDI) {
						if (!GDIVehicleMenuData[i].bEnable) {
							continue;
						}
					} else {
						if (!NodVehicleMenuData[i].bEnable) {
							continue;
						}
					}
					if (rxBuildingOwner.AreAircraftDisabled()) {
						if (TeamID == TEAM_GDI) {
							if (GDIVehicleMenuData[i].bAircraft) {
								continue;
							}
						} else {
							if (NodVehicleMenuData[i].bAircraft) {
								continue;
							}
						}
					}
				
				
					if (TeamID == TEAM_GDI) {
						VehicleMenuButton[i].SetString("costLabel", "$" $ rxPurchaseSystem.GetVehiclePrices(TeamID, GDIVehicleMenuData[i].ID, rxPurchaseSystem.AirdropAvailable(rxPRI)));
					} else {
						VehicleMenuButton[i].SetString("costLabel", "$" $ rxPurchaseSystem.GetVehiclePrices(TeamID, NodVehicleMenuData[i].ID, rxPurchaseSystem.AirdropAvailable(rxPRI)));
					}				
				
					if (PlayerCredits > rxPurchaseSystem.GetVehiclePrices(TeamID, data, rxPurchaseSystem.AirdropAvailable(rxPRI)) ){
						//nBab
		 				if (TeamID == TEAM_GDI)
		 				{
		 					if (TeamID != Fort.GetTeamNum() && i>4 && i<9)
		 					{
		 						VehicleMenuButton[i].SetBool("selected", false);
		 						VehicleMenuButton[i].SetBool("enabled", false);
		 					}else
		 						VehicleMenuButton[i].SetBool("enabled", true);
		 				}
		 				else if (TeamID == TEAM_Nod)
		 				{
		 					if (TeamID != Fort.GetTeamNum() && i>5 && i<9)
		 					{
		 						VehicleMenuButton[i].SetBool("selected", false);
		 						VehicleMenuButton[i].SetBool("enabled", false);
		 					}else
		 						VehicleMenuButton[i].SetBool("enabled", true);
		 				}
		 				/*if (TeamID == TEAM_GDI && i ==8)
		 				{
		 					VehicleMenuButton[i].SetBool("selected", false);
		 					VehicleMenuButton[i].SetBool("enabled", false);
		 					VehicleMenuButton[i].SetBool("visible", false);
		 				}*/
						
					} else {
						VehicleMenuButton[i].SetBool("enabled", false);
					}
				}
		}	else if (bItemDrawerOpen) {
			for (i = 0; i < 8; i++) {
				data = int(ItemMenuButton[i].GetString("data"));
				if (TeamID == TEAM_GDI) {
					if (!GDIItemMenuData[i].bEnable) {
						continue;
					}
				} else {
					if (!NodItemMenuData[i].bEnable) {
						continue;
					}
				}
				if (PlayerCredits > rxPurchaseSystem.GetItemPrices(TeamID, data)){
					ItemMenuButton[i].SetBool("enabled", true);
				} else {
					ItemMenuButton[i].SetBool("enabled", false);
				}
			}
		}

}


DefaultProperties
{
	//MovieInfo                       =   SwfMovie'FortPurchaseMenu.RenxPurchaseMenu'
}
