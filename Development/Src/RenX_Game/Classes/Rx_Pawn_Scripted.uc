class Rx_Pawn_Scripted extends Rx_Pawn;


var byte TeamNum;
var repnotify class<UTFamilyInfo> NextClassCharInfo;
var float ScriptedSpeedModifier;

replication
{
	if(bNetDirty)
		TeamNum, NextClassCharInfo, ScriptedSpeedModifier;
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
	return ((SpeedUpgradeMultiplier+GetRxFamilyInfo().default.Vet_SprintSpeedMod[VRank])+GetInventoryWeight()) * ScriptedSpeedModifier;
}

function SetRadarVisibility(byte Visibility)
{
	RadarVisibility = Visibility;
	if(Rx_ScriptedBotPRI(PlayerReplicationInfo) != None)
		Rx_ScriptedBotPRI(PlayerReplicationInfo).RadarVisibility = Visibility;
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

state RopeDownChinook
{
	ignores SetMovementPhysics, AddVelocity;

	simulated event Landed(vector HitNormal, actor FloorActor)
	{
		GoToState('Auto');
		global.Landed(HitNormal,FloorActor);
		if (Role == ROLE_Authority && Rx_Bot_Scripted(Controller) != None)
		{
			Rx_Bot_Scripted(Controller).MoveAfterDropOff();
		}
	}

	simulated event Bump( Actor Other, PrimitiveComponent OtherComp, Vector HitNormal )
	{
		GoToState('Auto');
		global.Bump(Other,OtherComp,HitNormal);
		if (Role == ROLE_Authority && Rx_Bot_Scripted(Controller) != None)
		{
			Rx_Bot_Scripted(Controller).MoveAfterDropOff();
		}
	}

	simulated function EndState(Name NextStateName)
	{
		global.SetMovementPhysics();
		FullBodyAnimSlot.StopCustomAnim(1.0);
	}


Begin:
	SetPhysics(PHYS_Flying);
	PlayRappelAnim();
	Sleep(1.25);
	PlayRappelLoopAnim();
	Velocity = Vect(0,0,-600);
	Sleep(5.0);
	GoToState('Auto');
}

simulated function PlayRappelAnim()
{
	FullBodyAnimSlot.PlayCustomAnim('HelicopterRappelIntro', 1.0, 0.0, 1.0, false, true );
}

simulated function PlayRappelLoopAnim()
{
	FullBodyAnimSlot.PlayCustomAnim('HelicopterRappel', 1.0, 1.0, 1.0, false, true);	
}

simulated function bool ForceVisible()
{
	return GetRadarVisibility() == 2 || PlayerReplicationInfo == none || Rx_ScriptedBotPRI(PlayerReplicationInfo).isSpotted();  
}

function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local Rx_Bot bot;
	local Rx_CapturePoint CP;
	local byte WasTeam;
	//local Rx_ORI ORI; 
	
	WasTeam = GetTeamNum();
	
	if(Rx_Controller(Controller) != None)
	{
		Rx_Controller(Controller).RemoveAllEffects();
	}
	else
	if(Rx_Bot(Controller) != None)
	{
		Rx_Bot(Controller).RemoveAllEffects();
	}
	//Notify ORI that this target was destroyed [Deprecated]
	//if(ORI != none && bIsTarget) ORI.NotifyTargetKilled(self);
	if(PlayerReplicationInfo != none)
	{
		Rx_ScriptedBotPRI(PlayerReplicationInfo).SetTargetEliminated(1); 
	}
 

	//Don't awkwardly continue regenerating health on your dead body.... 
	if(IsTimerActive('regenerateHealthTimer') ) ClearTimer('regenerateHealthTimer');
	
	foreach Worldinfo.AllControllers(class'Rx_Bot', bot) 
	{
		if(Rx_SquadAI(bot.squad).SquadLeader == controller && bot.GetOrders() == 'Follow') 
		{
			UTTeamInfo(bot.Squad.Team).AI.SetBotOrders(bot);   
		}
	}
	
	if (ParachuteDeployed)
	{
		ActualPackParachute();
		HideParachute();
	}
	
	if (super(UTPawn).Died(Killer, damageType, HitLocation))
	{
		foreach TouchingActors(class'Rx_CapturePoint', CP)
			CP.NotifyPawnDied(self, WasTeam);
		return true;
	}
	else
		return false;
}

simulated function byte GetRadarVisibility()
{
	if(Rx_ScriptedBotPRI(PlayerReplicationInfo) != None)
		return Rx_ScriptedBotPRI(PlayerReplicationInfo).GetRadarVisibility();

	return RadarVisibility; 
}


DefaultProperties
{
	ControllerClass = None
	ScriptedSpeedModifier = 1.f
}