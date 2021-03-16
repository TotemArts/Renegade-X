class Rx_CrateType_DMRandomWeapon extends Rx_CrateType 
    transient
    config(XSettings);

var config float ProbabilityIncreaseWhenInfantryProductionDestroyed;
var class<Rx_Weapon> WeaponClass;
var array< class<Rx_Weapon> > WeaponList;

function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	local string wepName;

		wepName = WeaponClass.default.PickupMessage;

    return "GAME" `s "Crate;" `s wepName `s "by" `s `PlayerLog(RecipientPRI);
}


function string GetPickupMessage()
{
	local string wepName;

		wepName = WeaponClass.default.PickupMessage;

    return "You were given a " $ wepName $ "!";
}

function float GetProbabilityWeight(Rx_Pawn Recipient, Rx_CratePickup CratePickup)
{
    local Rx_Building building;
    local float Probability;
    Probability = Super.GetProbabilityWeight(Recipient,CratePickup);

		ForEach CratePickup.AllActors(class'Rx_Building',building)
		{
		  if((Recipient.GetTeamNum() == TEAM_GDI && Rx_Building_GDI_InfantryFactory(building) != none  && Rx_Building_GDI_InfantryFactory(building).IsDestroyed()) ||
			(Recipient.GetTeamNum() == TEAM_NOD && Rx_Building_Nod_InfantryFactory(building) != none  && Rx_Building_Nod_InfantryFactory(building).IsDestroyed()))
		  {
			Probability += ProbabilityIncreaseWhenInfantryProductionDestroyed;
		  }
		}

        return Probability;
    }

/*
  function bool isSBH(Rx_Pawn Recipient)
    {
        if (class<Rx_FamilyInfo_Nod_DoNotUse>(Recipient.GetRxFamilyInfo()) != none)
            return true;

        return false;
    }
*/

function ExecuteCrateBehaviour(Rx_Pawn Recipient, Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
    local Rx_InventoryManager InvManager;
    local class<Rx_Weapon> TempWep;
    local int i;

    WeaponClass = WeaponList[Rand(WeaponList.Length)];

    InvManager = Rx_InventoryManager(Recipient.InvManager);

    if (InvManager.PrimaryWeapons.Find(TempWep) != INDEX_NONE)
        ForEach WeaponList(TempWep, i)
        {
            if (i == 0)
            {
                WeaponClass = WeaponList[Rand(WeaponList.Length)];
            }
            else break;
        }

    InvManager.PrimaryWeapons.AddItem(WeaponClass);

    if(InvManager.FindInventoryType(WeaponClass) != none)
    {
        InvManager.SetCurrentWeapon(Rx_Weapon(InvManager.FindInventoryType(WeaponClass)));
    }
    else
    {
        InvManager.SetCurrentWeapon(Rx_Weapon(InvManager.CreateInventory(WeaponClass, false)));
    }

    InvManager.PromoteAllWeapons(RecipientPRI.VRank);
}

defaultproperties
{
    WeaponList(0)=class'Rx_Weapon_SMG_GDI'
    WeaponList(1)=class'Rx_Weapon_Carbine'
    WeaponList(2)=class'Rx_Weapon_Chaingun_GDI'
    WeaponList(3)=class'Rx_Weapon_ChemicalThrower'
    WeaponList(4)=class'Rx_Weapon_FlakCannon'
    WeaponList(5)=class'Rx_Weapon_FlameThrower'
    WeaponList(6)=class'Rx_Weapon_Grenade_Rechargeable'
    WeaponList(7)=class'Rx_Weapon_GrenadeLauncher'
    WeaponList(8)=class'Rx_Weapon_HeavyPistol'
	WeaponList(9)=class'Rx_Weapon_LaserChainGun'
	WeaponList(10)=class'Rx_Weapon_LaserRifle'
	WeaponList(11)=class'Rx_Weapon_MarksmanRifle_GDI'
	WeaponList(12)=class'Rx_Weapon_MissileLauncher'
	WeaponList(13)=class'Rx_Weapon_PersonalIonCannon'
	WeaponList(14)=class'Rx_Weapon_Railgun'
	WeaponList(15)=class'Rx_Weapon_RamjetRifle'
	WeaponList(16)=class'Rx_Weapon_RemoteC4'
	WeaponList(17)=class'Rx_Weapon_Shotgun'
	WeaponList(18)=class'Rx_Weapon_SniperRifle_GDI'
	WeaponList(19)=class'Rx_Weapon_TacticalRifle'
	WeaponList(20)=class'Rx_Weapon_TiberiumAutoRifle'
	WeaponList(21)=class'Rx_Weapon_TiberiumAutoRifle_Blue'
	WeaponList(22)=class'Rx_Weapon_VoltAutoRifle_Nod'
    BroadcastMessageIndex=21 
	PickupSound=SoundCue'Rx_Pickups.Sounds.SC_Crate_RandomWeapon'
}
