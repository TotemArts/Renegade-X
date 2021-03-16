class S_GFxPurchaseMenu extends Rx_GFxPurchaseMenu;

var LinearColor NewColour;

/** one1: Modified; do not spawn new actor each roll-over, just replace skeletalmesh. */
function ChangeDummyVehicleClass (int classNum) 
{
	local class<Rx_Vehicle> vehicleClass;
		
	if (DummyVehicle == None) 
	{
		DummyVehicle = rxPC.Spawn(class'Rx_PT_Vehicle', rxPC, , VehicleShowcaseSpot.Location, VehicleShowcaseSpot.Rotation, , true);
	}
	
 	DummyVehicle.SetHidden(false);
	if(rxPC.GetTeamNum() == TEAM_GDI) {
	 	vehicleClass = rxPurchaseSystem.GDIVehicleClasses[classNum].default.VehicleClass;	
	} else {
		vehicleClass = rxPurchaseSystem.NodVehicleClasses[classNum].default.VehicleClass;	
	}	

	//Reset Camo texture for vehicles with no seperate PT mesh (e.g. M2 Bradley)
	MaterialInstanceConstant(DummyVehicle.Mesh.GetMaterial(0)).SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_Nod_Default');

	DummyVehicle.SetSkeletalMesh(vehicleClass.default.SkeletalMeshForPT);

	if(rxPC.GetTeamNum() == TEAM_GDI)
	{
		MaterialInstanceConstant(DummyVehicle.Mesh.GetMaterial(0)).SetTextureParameterValue('Camo', Texture2D'S_VehicleCamos.Vehicle.T_Camo_Nod_Default');
	}
}

function ClosePTMenu(bool unload)
{
	//Reset Camo texture for vehicles with no seperate PT mesh (e.g. M2 Bradley)
	if (DummyVehicle != none)
		MaterialInstanceConstant(DummyVehicle.Mesh.GetMaterial(0)).SetTextureParameterValue('Camo', Texture2D'RenX_AssetBase.Vehicle.T_Camo_Nod_Default');

	super.ClosePTMenu(unload);	
}

DefaultProperties
{
	NewColour = (R=0,G=0,B=1,A=1)

	GDIMainMenuData(0) 				= (BlockType=EPBT_CLASS, id=0,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_Autorifle', iconID=27, hotkey="1", title="SOLDIER",	 	 desc="Armour: Kevlar\nSpeed: 100\nSide: Silenced Pistol\n+Anti-Infantry",	cost="FREE", type=2, damage=1, range=3, rateOfFire=5, magCap=4 )
	GDIMainMenuData(1) 				= (BlockType=EPBT_CLASS, id=1,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_Shotgun', iconID=52, hotkey="2", title="SHOTGUNNER",	 desc="Armour: Kevlar\nSpeed: 100\nSide: Silenced Pistol\n+Anti-Infantry",	cost="FREE", type=2, damage=3, range=1, rateOfFire=2, magCap=2 )
	GDIMainMenuData(2) 				= (BlockType=EPBT_CLASS, id=2,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_FlameThrower', iconID=32, hotkey="3", title="FLAMETHROWER", desc="Armour: Flak\nSpeed: 105\nSide: Silenced Pistol\n+Anti-Everything",						cost="FREE", type=2, damage=2, range=1, rateOfFire=4, magCap=4 )
	GDIMainMenuData(3) 				= (BlockType=EPBT_CLASS, id=3,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_MarksmanRifle', iconID=41, hotkey="4", title="MARKSMAN",	 desc="Armour: Kevlar\nSpeed: 100\nSide: Silenced Pistol\n+Anti-Infantry",			cost="FREE", type=2, damage=3, range=5, rateOfFire=3, magCap=2 )
	GDIMainMenuData(4) 				= (BlockType=EPBT_CLASS, id=4,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_RepairGun', iconID=50, hotkey="5", title="ENGINEER",	 desc="Armour: Flak\nSpeed: 95\nSide: Silenced Pistol\nRemote C4\n+Anti-Building\n+Repair/Support",	cost="FREE", type=2, damage=3, range=1, rateOfFire=6, magCap=6 )
	GDIMainMenuData(5) 				= (BlockType=EPBT_MENU,  id=-1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Refill', iconID=05, hotkey="R", title="REFILL",	 	 desc="\nRefill Health\nRefill Armour\nRefill Ammo\nRefill Stamina",									cost="MENU", type=1 )
	GDIMainMenuData(6) 				= (BlockType=EPBT_MENU,  id=-1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Characters', iconID=02, hotkey="C", title="CHARACTERS",	 desc="",																								cost="MENU", type=1 )
	GDIMainMenuData(7) 				= (BlockType=EPBT_MENU,  id=-1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Vehicles_Nod', iconID=61, hotkey="V", title="VEHICLES",	 desc="",																								cost="MENU", type=1 )
	GDIMainMenuData(8) 				= (BlockType=EPBT_MENU,  id=-1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_ItemsNod', iconID=04, hotkey="Q", title="ITEM",		 desc="\n\nSuperweapons\nEquipment\nDeployables",														cost="MENU", type=1 )
	
	GDIClassMenuData(0)				= (BlockType=EPBT_CLASS, id=5,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_Chaingun', iconID=28, hotkey="1", title="OFFICER",				desc="Armour: Kevlar\nSpeed: 110\nSide: Silenced Pistol\nSmoke Grenade\n+Anti-Infantry",	cost="175",  type=2, damage=1, range=3, rateOfFire=6, magCap=6)
	GDIClassMenuData(1)				= (BlockType=EPBT_CLASS, id=6,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_MissileLauncher', iconID=42, hotkey="2", title="ROCKET SOLDIER",		desc="Armour: Flak\nSpeed: 105\nSide: Machine Pistol\nAnti-Tank Mines\n+Anti-Armour\n+Anti-Aircraft",						cost="225",  type=2, damage=4, range=5, rateOfFire=1, magCap=1)
	GDIClassMenuData(2)				= (BlockType=EPBT_CLASS, id=7,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_ChemicalThrower', iconID=29, hotkey="3", title="CHEMICAL TROOPER",	desc="Armour: Flak\nSpeed: 100\nSide: Silenced Pistol\nFrag Grenades\n+Anti-Everything",						cost="150",  type=2, damage=3, range=1, rateOfFire=4, magCap=4)
	GDIClassMenuData(3)				= (BlockType=EPBT_CLASS, id=8,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_SniperRifle', iconID=54, hotkey="4", title="BLACK HAND SNIPER",	desc="Armour: None\nSpeed: 90\nSide: Heavy Pistol\nSmoke Grenade\n+Anti-Infantry",						cost="500",  type=2, damage=4, range=6, rateOfFire=1, magCap=2)
	GDIClassMenuData(4)				= (BlockType=EPBT_CLASS, id=9,  PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_LaserRifle', iconID=39, hotkey="5", title="STEALTH BLACK HAND",	desc="Armour: Lazarus\nSpeed: 110\nSide: S. M. Pistol\nActive Camouflage\n+Anti-Everything",						cost="400",  type=2, damage=3, range=4, rateOfFire=4, magCap=3)
	GDIClassMenuData(5)				= (BlockType=EPBT_CLASS, id=10, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_LaserChaingun', iconID=38, hotkey="6", title="LASER CHAINGUNNER",	desc="Armour: Flak\nSpeed: 85\nEMP Grenade\nAnti-Tank Mines\n+Anti-Everything\n+Heavy Infantry",						cost="450",  type=2, damage=3, range=3, rateOfFire=5, magCap=5)
	GDIClassMenuData(6)				= (BlockType=EPBT_CLASS, id=11, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_RamjetRifle', iconID=48, hotkey="7", title="SAKURA",				desc="Armour: None\nSpeed: 90\nSide: S. Carbine\nSmoke Grenade\n+Anti-Infantry",						cost="1000", type=2, damage=5, range=6, rateOfFire=2, magCap=2)
	GDIClassMenuData(7)				= (BlockType=EPBT_CLASS, id=12, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_Railgun', iconID=47, hotkey="8", title="RAVESHAW",			desc="Armour: Flak\nSpeed: 100\nSide: Tiberium Flechette Rifle\nEMP Grenade\nAnti-Tank Mines\n+Anti-Armour",						cost="1000", type=2, damage=6, range=4, rateOfFire=1, magCap=2)
	GDIClassMenuData(8)				= (BlockType=EPBT_CLASS, id=13, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_TibAutoRifle', iconID=59, hotkey="9", title="MENDOZA",				desc="Armour: Kevlar\nSpeed: 110\nSide: Heavy Pistol\n+Anti-Everything",						cost="1000", type=2, damage=3, range=3, rateOfFire=6, magCap=4)
	GDIClassMenuData(9)				= (BlockType=EPBT_CLASS, id=14, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_RepairGun', iconID=50, hotkey="0", title="TECHNICIAN",			desc="Armour: Flak\nSpeed: 100\nSide: Silenced Pistol\nRemote C4\nProximity Mines\n+Anti-Building\n+Repair/Support",	cost="350",  type=2, damage=6, range=1, rateOfFire=6, magCap=6)
	
	GDIItemMenuData(0)				= (BlockType=EPBT_ITEM, id=0, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_NukeBeacon', iconID=71, hotkey="1", title="NUKE STRIKE BEACON", desc="<font size='8'>Pros:\n-Instant Building Destruction\nCons:\n-60 Seconds for impact\n-USES ITEM SLOT</font>", cost="1000", type=1)
	GDIItemMenuData(1)				= (BlockType=EPBT_ITEM, id=1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_Airstrike_AC130', iconID=63, hotkey="2", title="AC-130 AIRSTRIKE",	 desc="<font size='8'>Pros:\n-5 seconds to impact\n-Quick bombardment\n-Anti-Infrantry/Vehicle\nCons:\n-Weak Vs. Buildings\n-USES ITEM SLOT</font>", 												cost="800" , type=1)
	GDIItemMenuData(2)				= (BlockType=EPBT_ITEM, id=2, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_RepairTool', iconID=73, hotkey="3", title="REPAIR TOOL",      desc="<font size='8'>Pros:\n-Repairs Units/Buildings\n-Disarms Mines\n\nCons:\n-Must Recharge\n-USES ITEM SLOT </font>", cost="200")
	GDIItemMenuData(3)				= (BlockType=EPBT_ITEM, id=3, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_AmmoKit', iconID=64, hotkey="4", title="AMMUNITION KIT",	 desc="<font size='8'>Pros:\n-Rearms near by infrantry\n-30 seconds before depletion\n\nCons:\n-Rearms near by enemies as well\n-Cannot refill</font>", 							cost="150" , type=1, bEnable = false)
	GDIItemMenuData(4)				= (BlockType=EPBT_ITEM, id=4, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_MechanicalKit', iconID=65, hotkey="5", title="MECHANICAL KIT",	 desc="<font size='8'>Pros:\n-Repairs near by vehicles\n-30 seconds before depletion\n\nCons:\n-Repairs near by enemies as well\n-Cannot refill</font>", 							cost="150" , type=1, bEnable = false)
	GDIItemMenuData(5)				= (BlockType=EPBT_ITEM, id=5, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_MotionSensor', iconID=67, hotkey="6", title="MOTION SENSOR",	 	 desc="<font size='8'>Pros:\n-Relays enemy position in a radius\n-Detects mines and beacons\n\nCons:\n-Emits an audible sound\n-Cannot refill</font>", 								cost="200" , type=1, bEnable = false)
	GDIItemMenuData(6)				= (BlockType=EPBT_ITEM, id=6, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_Sentry_MG', iconID=68, hotkey="7", title="MG SENTRY",	 		 desc="<font size='8'>Requires Armory\n\n-Automated Sentry Turret\n-Anti-Infrantry\n-Limited Ammo\n-Can be picked up\n-Cannot refill</font>", 										cost="300" , type=1, bEnable = false)
	GDIItemMenuData(7)				= (BlockType=EPBT_ITEM, id=7, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_Sentry_AT', iconID=69, hotkey="8", title="AT SENTRY",	 		 desc="<font size='8'>Requires Armory\n\n-Automated Sentry Turret\n-Anti-Vehicle\n-Limited Ammo\n-Can be picked up\n-Cannot refill</font>", 										cost="300" , type=1, bEnable = false)
	
	GDIWeaponMenuData(0)			= (BlockType=EPBT_WEAPON, id=0, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_HeavyPistol', iconID=36, hotkey="1", title="HEAVY PISTOL",	 		  desc="Good Vs:\n-Infrantry\n-Light Armour Vehicles\n\nWeak Vs:\n-Buildings\n-Light Armour Vehicles", 									 cost="100", type=2, damage=4,range=2,rateOfFire=3,magCap=2)
	GDIWeaponMenuData(1)			= (BlockType=EPBT_WEAPON, id=1, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_Carbine', iconID=72, hotkey="2", title="CARBINE",	 			      desc="Good Vs:\n-Infantry\n-Light Armour\n\nWeak Vs:\n-Heavy Armour\n-Buildings",	 													 cost="250", type=2, damage=3,range=3,rateOfFire=4,magCap=2)
	GDIWeaponMenuData(2)			= (BlockType=EPBT_WEAPON, id=2, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_TibFlechetteRifle', iconID=57, hotkey="3", title="TIBERIUM FLECHETTE RIFLE",  desc="<font size='8'>[Requires Silo] \nGood Vs: \n-Infrantry\n-Light Armour\nWeak Vs:\n-Heavy Armour\n-Buildings</font>",				 cost="400", type=2, damage=2,range=3,rateOfFire=5,magCap=3, bSilo = true)
	GDIWeaponMenuData(3)			= (BlockType=EPBT_WEAPON, id=3, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_TibAutoRifle', iconID=56, hotkey="4", title="TIBERIUM AUTO-RIFLE",	 	  desc="<font size='8'>[Requires Silo] \nGood Vs: \n-Infrantry\n-Light Armour\nWeak Vs:\n-Heavy Armour\n-Buildings</font>",				 cost="400", type=2, damage=4,range=3,rateOfFire=2,magCap=3, bSilo = true)
	GDIWeaponMenuData(4)			= (BlockType=EPBT_WEAPON, id=4, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_EMPGrenade', iconID=30, hotkey="5", title="EMP GRENADE",	 			  desc="<font size='8'>\nPros:\n-Disables vehicles\n-Disarm mines\n\nCons:\n-Weapons remain active</font>", 					 		 cost="300", type=1)
	GDIWeaponMenuData(5)			= (BlockType=EPBT_WEAPON, id=5, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_ATMine', iconID=26, hotkey="6", title="ANTI-TANK MINE",	 		  desc="<font size='8'>\nPros:\n-Heavy vehicle damage\n\nCons:\n-Can be destroyed\n-Limit 2 per person</font>", 						 cost="250", type=1)
	GDIWeaponMenuData(6) 			= (BlockType=EPBT_WEAPON, id=6, PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Weapon_SmokeGrenade', iconID=74, hotkey="7", title="SMOKE GRENADE",	 	      desc="<font size='8'>\nPros:\n-Reduces Visibility\n-Disables Target Info\n\nCons:\n-Weapons remain active</font>", 					 cost="100", type=1)
	
	
	GDIVehicleMenuData(0)			= (BlockType=EPBT_VEHICLE, id=0, hotkey="1")
	GDIVehicleMenuData(1)			= (BlockType=EPBT_VEHICLE, id=1, hotkey="2")
	GDIVehicleMenuData(2)			= (BlockType=EPBT_VEHICLE, id=2, hotkey="3")
	GDIVehicleMenuData(3)			= (BlockType=EPBT_VEHICLE, id=3, hotkey="4")
	GDIVehicleMenuData(4)			= (BlockType=EPBT_VEHICLE, id=4, hotkey="5")
	GDIVehicleMenuData(5)			= (BlockType=EPBT_VEHICLE, id=5, hotkey="6")
	GDIVehicleMenuData(6)			= (BlockType=EPBT_VEHICLE, id=6, hotkey="7")
	GDIVehicleMenuData(7)			= (BlockType=EPBT_VEHICLE, id=7, hotkey="8", bEnable = false)
	GDIVehicleMenuData(8)			= (BlockType=EPBT_VEHICLE, id=8, hotkey="9", bEnable = false)
	GDIVehicleMenuData(9)			= (BlockType=EPBT_VEHICLE, id=9, hotkey="0", bEnable = false)

	MovieInfo = SwfMovie'SPurchaseMenu.RenXPurchaseMenu'
}