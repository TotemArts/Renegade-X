class Rx_Pawn_Scripted extends Rx_Pawn;

var Rx_ScriptedBotSpawner MySpawner;
var byte TeamNum;
var repnotify class<UTFamilyInfo> NextClassCharInfo;

replication
{
	if(bNetDirty)
		TeamNum, NextClassCharInfo;
}

simulated event ReplicatedEvent(Name VarName)
{
	if(VarName == 'NextClassCharInfo')
	{
		NotifyTeamChanged();
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

simulated function float GetSpeedModifier()
{
	return ((SpeedUpgradeMultiplier+GetRxFamilyInfo().default.Vet_SprintSpeedMod[VRank])+GetInventoryWeight()) * MySpawner.SpeedModifier;
}

function SetRadarVisibility(byte Visibility)
{
	RadarVisibility = Visibility;
}

simulated function NotifyTeamChanged() 
{
	local int i;

	// set mesh to the one in the PRI, or default for this team if not found
	SetCharacterClassFromInfo(NextClassCharInfo);

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		// refresh weapon attachment
		if (CurrentWeaponAttachmentClass != None)
		{
			// recreate weapon attachment in case the socket on the new mesh is in a different place
			if (CurrentWeaponAttachment != None)
			{
				CurrentWeaponAttachment.DetachFrom(Mesh);
				CurrentWeaponAttachment.Destroy();
				CurrentWeaponAttachment = None;
			}
			WeaponAttachmentChanged();
		}
			// refresh overlay
		if (OverlayMaterialInstance != None)
		{
			SetOverlayMaterial(OverlayMaterialInstance);
		}
	}

	// Make sure physics is in the correct state.
	// Rebuild array of bodies to not apply joint drive to.
	NoDriveBodies.length = 0;
	if(Mesh.PhysicsAsset != None)
	{
		for( i=0; i<Mesh.PhysicsAsset.BodySetup.Length; i++)
		{
			if(Mesh.PhysicsAsset.BodySetup[i].bAlwaysFullAnimWeight)
			{
				NoDriveBodies.AddItem(Mesh.PhysicsAsset.BodySetup[i].BoneName);
			}
		}
	}

	// Reset physics state.
	bIsHoverboardAnimPawn = FALSE;

	if(WorldInfo.NetMode != NM_DedicatedServer)
		ResetCharPhysState();


	if (!bReceivedValidTeam)
	{
		SetTeamColor();
		bReceivedValidTeam = (GetTeam() != None);
	}

	if (Rx_Controller(Controller) != None && `RxGameObject != None) {
		Rx_Controller(Controller).UpdateDiscordPresence(`RxGameObject.MaxPlayers);
	}
}

// PRI Replacement functions

simulated function SetChar(class<Rx_FamilyInfo> newFamily, optional bool isFreeClass)
{

	if (newFamily != none )
	{
		NextClassCharInfo = newFamily;
	} 
	else
	{
		return;
	}

	NotifyTeamChanged();
//		Rx_Pawn(pawn).ChangeCharacterClass();

//Temporarily disabling SBH stuff until Scripted SBH is possible

/*
	if(WorldInfo.GetGameClass() == Class'Rx_Game')
	{
		if( Rx_Game(WorldInfo.Game).GetPurchaseSystem().IsStealthBlackHand(self) )
		{
			if(Rx_Controller(Owner) != none)
				Rx_Controller(Owner).ChangeToSBH(true);
			else if(Rx_Bot(Owner) != none)
				Rx_Bot(Owner).ChangeToSBH(true);
		}
		else
		{
			if(Rx_Controller(Owner) != none)
				Rx_Controller(Owner).ChangeToSBH(false);
			else if(Rx_Bot(Owner) != none)
				Rx_Bot(Owner).ChangeToSBH(false);
		}
	}
*/
   
   equipStartWeapons(isFreeClass);
}

simulated function equipStartWeapons(optional bool FreeClass) 
{
    local class<Rx_FamilyInfo> rxCharInfo;   
	local float ArmourPCT; 
	local int	i; 

	rxCharInfo = class<Rx_FamilyInfo>(CurrCharClassInfo);

	/** one1: Set starting inventory. */
	Rx_InventoryManager(InvManager).SetWeaponsForPawn();
	
	if(FreeClass) 
	{
		/*Give the pawn the same percentage of armour if they switch classes. E.G, switching from a RifleSoldier with 100 health and armour, 
		to a Grenadier would still make the grenadier have full health/armour*/ 
		ArmourPCT=float(Armor)/float(ArmorMax); 
		
		if(ArmorMax != rxCharInfo.default.MaxArmor) 
		{
			ArmorMax  = rxCharInfo.default.MaxArmor;
		
			Armor     = rxCharInfo.default.MaxArmor; // Armor > rxCharInfo.default.MaxArmor ? rxCharInfo.default.MaxArmor : .Armor;	
		
			Armor*=ArmourPCT; 
		}
	 	
		setArmorType(rxCharInfo.default.Armor_Type);
	
		SpeedUpgradeMultiplier = rxCharInfo.default.SpeedMultiplier;	
		JumpHeightMultiplier = rxCharInfo.default.JumpMultiplier; 
		UpdateRunSpeedNode();
		SetGroundSpeed();
		// PromoteUnit(0); //Reset VRank
		SoundGroupClass = rxCharInfo.default.SoundGroupClass;
		Stamina = MaxStamina;
		ClientSetStamina( MaxStamina);
		PromoteUnit(VRank);
		
		
		//Clear and Set passive abilities
		ClearPassiveAbilities() ;
		
		for(i=0;i<3;i++){
			 GivePassiveAbility(i, rxCharInfo.default.PassiveAbilities[i]) ;
		}
	
		//Reapply buffs/nerfs
		if(Rx_Controller(Owner) != none)
			Rx_Controller(Owner).UpdateModifiedStats(); 
		else if(Rx_Bot(Owner) != none)
			Rx_Bot(Owner).UpdateModifiedStats(); 
	
 		bForceNetUpdate = true;
		return;
	}
	
	//Set Health
	HealthMax = rxCharInfo.default.MaxHealth;
	Health    = HealthMax;
	
	//Set armour and type
	ArmorMax  = rxCharInfo.default.MaxArmor;
	Armor     = ArmorMax;	 	 	
	setArmorType(rxCharInfo.default.Armor_Type);
	
	SpeedUpgradeMultiplier = rxCharInfo.default.SpeedMultiplier;	
	JumpHeightMultiplier = rxCharInfo.default.JumpMultiplier; 
	UpdateRunSpeedNode();
	SetGroundSpeed();
	PromoteUnit(VRank);
	SoundGroupClass = rxCharInfo.default.SoundGroupClass;
	Stamina = MaxStamina;
	ClientSetStamina(MaxStamina);
	
	//Clear and Set passive abilities
	ClearPassiveAbilities() ;
	
	for(i=0;i<3;i++)
	{
		 GivePassiveAbility(i, rxCharInfo.default.PassiveAbilities[i]) ;
	}
	
	//Reapply buffs/nerfs
	if(Rx_Controller(Controller) != none)
			Rx_Controller(Controller).UpdateModifiedStats(); 
	else if(Rx_Bot(Controller) != none)
		Rx_Bot(Controller).UpdateModifiedStats(); 
	
 	bForceNetUpdate = true;
}

simulated function byte GetTeamNum()
{
	return TeamNum;
}

DefaultProperties
{
	ControllerClass = None

}