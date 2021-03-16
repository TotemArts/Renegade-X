class Rx_CrateType_RandomWeapon extends Rx_CrateType 
    transient
    config(XSettings);

var config float ProbabilityIncreaseWhenInfantryProductionDestroyed;
var class<Rx_Weapon> WeaponClass;
var array< class<Rx_Weapon> > WeaponList;
var int BroadcastMessageAltIndex;

function string GetPickupMessage()
{
	local string wepName;

		wepName = WeaponClass.default.PickupMessage;

    return "You were given a " $ wepName $ "!";
}

function string GetGameLogMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	local string wepName;

		wepName = WeaponClass.default.PickupMessage;

    return "GAME" `s "Crate;" `s wepName `s "by" `s `PlayerLog(RecipientPRI);
}

function BroadcastMessage(Rx_PRI RecipientPRI, Rx_CratePickup CratePickup)
{
	if (RecipientPRI.GetTeamNum() == TEAM_NOD)
	{
		CratePickup.BroadcastLocalizedTeamMessage(TEAM_GDI, CratePickup.MessageClass, BroadcastMessageAltIndex, RecipientPRI);
		CratePickup.BroadcastLocalizedTeamMessage(TEAM_NOD, CratePickup.MessageClass, BroadcastMessageIndex, RecipientPRI);
	}
	else
	{
		CratePickup.BroadcastLocalizedTeamMessage(TEAM_NOD, CratePickup.MessageClass, BroadcastMessageAltIndex, RecipientPRI);
		CratePickup.BroadcastLocalizedTeamMessage(TEAM_GDI, CratePickup.MessageClass, BroadcastMessageIndex, RecipientPRI);
	}
}

function float GetProbabilityWeight(Rx_Pawn Recipient, Rx_CratePickup CratePickup)
{
    local Rx_Building building;
    local float Probability;
    Probability = Super.GetProbabilityWeight(Recipient,CratePickup);

    if (isSBH(Recipient)) // Don't give if it's an SBH.
          return 0;

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

  function bool isSBH(Rx_Pawn Recipient)
    {
        if (class<Rx_FamilyInfo_Nod_StealthBlackHand>(Recipient.GetRxFamilyInfo()) != none)
            return true;

        return false;
    }

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
    Rx_Weapon(InvManager.FindInventoryType(WeaponClass, false)).bIsCrateWeapon=true;
    Rx_Weapon(InvManager.FindInventoryType(WeaponClass, false)).bCanGetAmmo=false;

}

defaultproperties
{
    WeaponList(0)=class'Rx_Weapon_Grenade'
    WeaponList(1)=class'Rx_Weapon_EMPGrenade'
    WeaponList(2)=class'Rx_Weapon_SmokeGrenade'
    WeaponList(3)=class'Rx_Weapon_HeavyPistol'
	WeaponList(4)=class'Rx_Weapon_RepairTool'
    WeaponList(5)=class'Rx_Weapon_SMG'
	
    BroadcastMessageIndex=21
	BroadcastMessageAltIndex=22
    PickupSound=SoundCue'Rx_Pickups.Sounds.SC_Crate_RandomWeapon'
}
