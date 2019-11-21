class Rx_Building_Team_Internals extends Rx_Building_Internals;

`include(RenX_Game\RenXStats.uci);

var int                     Health;             // Current health of the building
var	bool					HealthLocked; 		//Can this building be damaged?
var int                     HealthMax;          // Maximum health of the building
var int 					BA_HealthMax;		//Changes to this as max health when building armour is enabled. 
var int						TrueHealthMax;		// Max Health minus Armor value
var int                     Armor;          	// Maximum health of the building
var int                     LowHPWarnLevel;     // under this health-lvl lowHP warnings will be send (critical)
var int                     RepairedHPLevel;    // Repaired message will not play if the building didn't fall below this level of health.
var int 					RepairedArmorLevel; //Same but for armour.  
var float                   SavedDmg;           // Since infantry weapons will do fractions of damage it is added here and once it is greater than 1 point of damage it is applied to health
var const float             HealPointsScale;    // How many points per healed HP
var const float             HDamagePointsScale; // How many points per damaged HP 
var const float				ADamagePointsScale; // How many points per damaged Armor
var float					Destroyed_Score	;	//Total points given when the building is destroyed. 1/2 is given to the player that destroyed it, whilst the other is just added to the team score. 
var float 					ArmorResetTime;
var bool 					bCanArmorBreak; 
struct Attacker
{
	var PlayerReplicationInfo PPRI; 
	var float DamageDone; 
};

var array<Attacker>	DamagingParties;	//Track who is doing building damage

var repnotify bool          bDestroyed;	        // true if Building is destroyed
var protected int           DestroyerID;        // PlayerID of the player destroyed this building
var PlayerReplicationInfo   Destroyer;          // PRI of the destroyer
var name                    DestructionAnimName;
var bool                    bNoPower;

var bool                    bBuildingRecoverable;

var float                   MessageWaitTime;
var float 					LastBuildingRepairedMessageTime;
var bool                    bCanPlayRepaired;
var repnotify int			DamageLodLevel;

var array<Rx_BuildingAttachment_DmgFx> DmgFx_Lvl0, DmgFx_Lvl1, DmgFx_Lvl2, DmgFx_Lvl3, DmgFx_Lvl4, DmgFx_OnlyLvl1, DmgFx_OnlyLvl2, DmgFx_OnlyLvl3;
var bool DmgFx_Lvl0On, DmgFx_Lvl1On, DmgFx_Lvl2On, DmgFx_Lvl3On, DmgFx_Lvl4On, DmgFx_OnlyLvl1On, DmgFx_OnlyLvl2On, DmgFx_OnlyLvl3On;
// Yeah its icky, but blame UScript for not supporting multi-dimension arrays.
var bool bInitialDamageLod;

enum BuildingAlarm
{
	BuildingDestroyed,
	BuildingUnderAttack,
	BuildingDestructionImminent,
	BuildingRepaired,
};

var const SoundNodeWave     FriendlyBuildingSounds[BuildingAlarm.BuildingAlarm_MAX];
var const SoundNodeWave     EnemyBuildingSounds[BuildingAlarm.BuildingAlarm_MAX];

replication
{
	if( bNetInitial && Role == ROLE_Authority )
		HealthMax, TrueHealthMax;
	if( bNetDirty && Role == ROLE_Authority )
		Health, Armor, bDestroyed, DamageLodLevel, bNoPower; 
}

simulated event ReplicatedEvent( name VarName )
{
	if( VarName == 'bDestroyed' )
	{
		PlayDestructionAnimation();
	}
	else if( VarName == 'DamageLodLevel' )
	{
		ChangeDamageLodLevel(DamageLodLevel);
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

simulated function Init( Rx_Building Visuals, bool isDebug )
{
	// Martin P. (JeepRubi): Bugfix: Only do this on the server, it will be replicated to clients.
	if (Role == ROLE_Authority)
	{
		
		if(Rx_Building_Techbuilding(Visuals) == None)
		{
			Visuals.HealthMax = BA_HealthMax; 
			
			Armor = BA_HealthMax * Rx_Game(WorldInfo.Game).buildingArmorPercentage/100;
			Health = BA_HealthMax - Armor;
			HealthMax = BA_HealthMax ;	
			TrueHealthMax = BA_HealthMax - Armor; //Factor in armor for the true max health. Everything that relies on the default Healthmax uses default.maxhealth to draw things accurately.
		} 
		else {		
			Health = Visuals.HealthMax;
			HealthMax = Visuals.HealthMax;	
			TrueHealthMax = Visuals.HealthMax;	
		}
	}
	
	if (TeamID == TEAM_UNOWNED)
	{
		loginternal(self.Class@"has team set to TEAM_UNOWNED");
		`Log(self.Class@"has team set to TEAM_UNOWNED",bBuildingDebug,'Buildings');
	}

	super.Init(Visuals,isDebug);
	ChangeDamageLodLevel(DamageLodLevel);
}

simulated function int GetHealth() 
{
	return Health; 
}

simulated function int GetMaxHealth() 
{
	return HealthMax; 
}

simulated function int GetTrueMaxHealth() 
{
	return TrueHealthMax; 
}


simulated function int GetArmor() 
{
	return Armor; 
}

simulated function int GetMaxArmor() 
{
	return float(HealthMax) * float(Rx_GRI(WorldInfo.Gri).buildingArmorPercentage)/100.0f;
}


simulated function bool IsDestroyed()
{
	return bDestroyed;
}

function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser) 
{
	local float CurDmg;
	local int TempDmg;
	local float Scr;
	local int dmgLodLevel;
	local Rx_Controller StarPC; //Let's rub it in their faces, gents!
	local int InstigatorIndex;
	local Attacker TempAttacker;
	local Attacker PRII;
	local float StartHealth, StartArmor; //Keep Track of what we're currently at for health and armor

	
	if(HealthLocked) return; //Health is currently locked
	
	StarPC=Rx_Controller(EventInstigator); 
	
	if ( EventInstigator == none || GetTeamNum() == EventInstigator.GetTeamNum() || bDestroyed || Role < ROLE_Authority || Health <= 0 || DamageAmount <= 0 )
		return;

	StartHealth = GetHealth();
	StartArmor = GetArmor(); 
	
	// handle non-dmg
	if (DamageType == None) 
	{
		DamageType = class'DamageType';
	}

	if (EventInstigator != None)
	{
		CurDmg = Float(DamageAmount);
		if (class<Rx_DmgType>(DamageType) != None)
		{
			//Make an exception for weapons that have been 
			if(EventInstigator != none && EventInstigator.Pawn != none && Rx_Weapon(EventInstigator.Pawn.Weapon) != none && Rx_Weapon(EventInstigator.Pawn.Weapon).VRank >=2) DamageAmount*=Rx_Weapon(EventInstigator.Pawn.Weapon).Elite_Building_DamageMod;
			
			// calculate saved damg and save it
			CurDmg = Float(DamageAmount) * class<Rx_DmgType>(DamageType).static.BuildingDamageScalingFor();
		 
			DamageAmount *= class<Rx_DmgType>(DamageType).static.BuildingDamageScalingFor();
			
		    if(DamageAmount < CurDmg)
		    {
		    	SavedDmg += CurDmg - Float(DamageAmount);	
		    }
		    
		    if (SavedDmg >= 1)
		    {
		    	DamageAmount += SavedDmg; 
		    	TempDmg = SavedDmg;
		    	SavedDmg -= Float(TempDmg);		   
		    }			
			
		}

		/*if(CurDmg > float(Health+Armor))
			Scr = float(Health+Armor)*DamagePointsScale; //Don't give ridiculously high points for putting an ion on a building. 
		else
			Scr = CurDmg * DamagePointsScale;*/
	}


	DamageAmount = Max(DamageAmount, 0);
	//bForceNetUpdate = True;

	if(Armor > 0)
	{
		if(DamageAmount - Armor >= 0 && bCanArmorBreak) 
		{
			ArmorBreak(EventInstigator); //Armour broken bonus	
		}
		
		if(DamageAmount - Armor > 0)
		{
			
			//Track health damage and who dun it (When breaking armour)

			InstigatorIndex=DamagingParties.Find('PPRI',EventInstigator.PlayerReplicationInfo);
		
			if(InstigatorIndex == -1)  //New damager
			{
				TempAttacker.PPRI=EventInstigator.PlayerReplicationInfo;
				TempAttacker.DamageDone = Min(DamageAmount - Armor, Health);

				if(Rx_PRI(EventInstigator.PlayerReplicationInfo) != None)
				{
				
					//Give the remaining Armour in Armour damage 
					Rx_PRI(EventInstigator.PlayerReplicationInfo).AddBuildingArmourDamage(Armor);
					//Give Health damage points where they are due 
					Rx_PRI(EventInstigator.PlayerReplicationInfo).AddBuildingDamage(FMin(DamageAmount - Armor, Health));
				}
				
				DamagingParties.AddItem(TempAttacker);
			}
			else
			{
				if(CurDmg <= float(Health+Armor))
				{
					DamagingParties[InstigatorIndex].DamageDone+=Min(DamageAmount-Armor, GetMaxArmor()+GetMaxHealth()+10);	
			
					if(Rx_PRI(EventInstigator.PlayerReplicationInfo) != None)
					{					
						Rx_PRI(EventInstigator.PlayerReplicationInfo).AddBuildingArmourDamage(FMin(DamageAmount-Armor, GetMaxArmor()));
					
						Rx_PRI(EventInstigator.PlayerReplicationInfo).AddBuildingDamage(FMin(DamageAmount-Armor, GetMaxHealth()+10));
					}
				}
				else
				{
					DamagingParties[InstigatorIndex].DamageDone+=Health+Armor;

					if(Rx_PRI(EventInstigator.PlayerReplicationInfo) != None)
					{					
						Rx_PRI(EventInstigator.PlayerReplicationInfo).AddBuildingArmourDamage(Armor);
						Rx_PRI(EventInstigator.PlayerReplicationInfo).AddBuildingDamage(float(Health));
					}
				}
				
			}
		
			//End tracking health damage

			/** Set score based on damage */
			if (DamageAmount > float(Health+Armor)) // Building insta-kill
				Scr = float(Health) * HDamagePointsScale + float(Armor) * ADamagePointsScale;
			else
				Scr = Armor * ADamagePointsScale + (DamageAmount - Armor) * HDamagePointsScale;
			
			Health = Max(Health - (DamageAmount - Armor), 0);

			BuildingVisuals.TriggerEventClass(Class'Rx_SeqEvent_BuildingEvent',EventInstigator,3); 
		}	
		else // Damaging only armor
		{
			if(Rx_PRI(EventInstigator.PlayerReplicationInfo) != None)
				Rx_PRI(EventInstigator.PlayerReplicationInfo).AddBuildingArmourDamage(DamageAmount);
		
			Scr = float(DamageAmount) * ADamagePointsScale;
		}
			

		Armor = Max(Armor - DamageAmount, 0);	
	}
	else
	{	
		//Track health damage and who dun it
		InstigatorIndex=DamagingParties.Find('PPRI',EventInstigator.PlayerReplicationInfo);
		
		if(InstigatorIndex == -1)  //New damager
		{
			TempAttacker.PPRI=EventInstigator.PlayerReplicationInfo;
			TempAttacker.DamageDone = FMin(DamageAmount, Health);

			if(Rx_PRI(EventInstigator.PlayerReplicationInfo) != None)
				Rx_PRI(EventInstigator.PlayerReplicationInfo).AddBuildingDamage(FMin(DamageAmount, Health)); 
			
			DamagingParties.AddItem(TempAttacker) ;
		}
		else
		{
			if(CurDmg <= float(Health+Armor))
				{
					DamagingParties[InstigatorIndex].DamageDone+=DamageAmount;

					if(Rx_PRI(EventInstigator.PlayerReplicationInfo) != None)
						Rx_PRI(EventInstigator.PlayerReplicationInfo).AddBuildingDamage(DamageAmount); 
				}				
			else
				{
					DamagingParties[InstigatorIndex].DamageDone+=Health;

					if(Rx_PRI(EventInstigator.PlayerReplicationInfo) != None)
						Rx_PRI(EventInstigator.PlayerReplicationInfo).AddBuildingDamage(float(Health)); 
				}
				
		}
			
		//End tracking health damage

		/** Set score based on damage */
		if (DamageAmount > float(Health)) // Building kill
			Scr = float(Health) * HDamagePointsScale;
		else
			Scr = float(DamageAmount) * HDamagePointsScale;
		
		Health = Max(Health - DamageAmount, 0);
	}

	// Add score
	if (GetTeamNum() != EventInstigator.GetTeamNum() && Rx_PRI(EventInstigator.PlayerReplicationInfo) != None)
	{
		Rx_PRI(EventInstigator.PlayerReplicationInfo).AddScoreToPlayerAndTeam(Scr);
		Rx_PRI(EventInstigator.PlayerReplicationInfo).AddBuildingDamagePoints(Min(DamageAmount, StartHealth+StartArmor ));
	}

	BuildingVisuals.TriggerEventClass(Class'Rx_SeqEvent_BuildingEvent',EventInstigator,2); 
		
	if (Health <= 0) 
	{
		bDestroyed = True;
		Destroyer = EventInstigator.PlayerReplicationInfo;
		if(Rx_Game(WorldInfo.Game) != None && !Rx_Game(WorldInfo.Game).bPedestalDetonated)
			BroadcastLocalizedMessage(MessageClass,BuildingDestroyed,EventInstigator.PlayerReplicationInfo,,self);

		`RecordTeamStringStat(BUILDING_DESTROYED,`RxGameObject.teams[self.TeamID],"Building "@BuildingName@"Destroyed");
		
		//Rx_PRI(Destroyer).AddScoreToPlayerAndTeam(Destroyed_Score/2); //875 to the destroyer of buildings. 
		//Rx_TeamInfo(Destroyer.Team).AddRenScore(Destroyed_Score/2); //And another 875 to the team score

		foreach DamagingParties(PRII)
		{
			if (PRII.PPRI != none)
			{


				if(Rx_PRI(PRII.PPRI) != None)
					Rx_PRI(PRII.PPRI).AddScoreToPlayerAndTeam( default.Destroyed_Score*(PRII.DamageDone/TrueHealthMax)) ;
				else
					Rx_TeamInfo(PRII.PPRI.Team).AddRenScore(default.Destroyed_Score*(PRII.DamageDone/TrueHealthMax));


				if(Rx_Controller(PRII.PPRI.Owner) != none && Rx_Pawn( Rx_Controller(PRII.PPRI.Owner).Pawn) != none) Rx_Pawn( Rx_Controller(PRII.PPRI.Owner).Pawn).
					SetTimer(2.0,false,'PlayBuildingKillTimer');
					
				Destroyed_Score -= default.Destroyed_Score*(PRII.DamageDone/TrueHealthMax);
			}
		}
		if(Destroyed_Score > 0) //If there's leftover score, just add it to the team
		{
			Rx_TeamInfo(Destroyer.Team).AddRenScore(Destroyed_Score);
			Destroyed_Score=0; 
		}
			
		//Handepsilon : Moved the building destruction broadcast to Rx_Game. 
		//  	Seriously, why does the building handle the announcement itself?? This is a gameplay thing!

		Rx_Game(WorldInfo.Game).LogBuildingDestroyed(Destroyer, self, BuildingVisuals, DamageType);

		PlayDestructionAnimation();
		Rx_Game(WorldInfo.Game).CheckBuildingsDestroyed(BuildingVisuals, StarPC);

		BuildingVisuals.TriggerEventClass(Class'Rx_SeqEvent_BuildingEvent',EventInstigator,0); 
	}
	else if (DamageAmount > 0) 
	{
		TriggerBuildingUnderAttackMessage(EventInstigator);
	}

	if (!bCanPlayRepaired && Armor <= RepairedArmorLevel)
		bCanPlayRepaired = true;


	dmgLodLevel = GetBuildingHealthLod();
	if(dmgLodLevel != DamageLodLevel) {
		DamageLodLevel = dmgLodLevel;
		ChangeDamageLodLevel(dmgLodLevel);
	}

	super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	//`log(self.Class@ "taking" @DamageAmount@ "damage."@SavedDmg@"damage saved -" @Health@ "remaining",bBuildingDebug,'Buildings');
	
	`RecordGamePositionStat(BUILDING_DAMAGE_ATTACKER_LOCATION, EventInstigator.Pawn.Location, 1);
	`RecordGamePositionStat(BUILDING_DAMAGE_AMOUNT, HitLocation, DamageAmount);
	`RecordGamePositionStat(BUILDING_DAMAGE_LOCATION, HitLocation, 1);
}

//

function TriggerBuildingUnderAttackMessage(Controller EventInstigator)
{
	if(BuildingVisuals.bSignificant && Rx_Game(WorldInfo.Game).CanPlayBuildingUnderAttackMessage(GetTeamNum()) )
	{
		/**if (Health <= LowHPWarnLevel) 
			BroadcastLocalizedTeamMessage(GetTeamNum(),MessageClass,BuildingDestructionImminent,EventInstigator.PlayerReplicationInfo,,self);
		else*/
			BroadcastLocalizedMessage(MessageClass,BuildingUnderAttack,EventInstigator.PlayerReplicationInfo,,self);
			Rx_Game(WorldInfo.Game).ResetBuildingUnderAttackEvaTimer(GetTeamNum());
	}	
}

function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
	local int RealAmount;
	local float Scr;
	local int dmgLodLevel;
	local int repairableHealth;
	local int repairableMaxHealth;
	local bool bRepairArmor;
	
	if(Rx_Building_TechBuilding_Internals(self) == None)
	{
		bRepairArmor = true;
		repairableHealth = Armor;
		repairableMaxHealth = HealthMax * Rx_Game(WorldInfo.Game).buildingArmorPercentage/100;
	}
	else
	{
		repairableHealth = Health;
		repairableMaxHealth = HealthMax;
	}
	

	Amount = Amount*2;
	if ((bRepairArmor || repairableHealth > 0) && repairableHealth < repairableMaxHealth && Amount > 0 && Healer != None && Healer.GetTeamNum() == GetTeamNum() )
	{
		RealAmount = Min(Amount, repairableMaxHealth - repairableHealth);

		if (RealAmount > 0)
		{

			if (repairableHealth >= repairableMaxHealth && SavedDmg > 0.0f)
			{
				SavedDmg = FMax(0.0f, SavedDmg - Amount);
				Scr = SavedDmg * HealPointsScale;
				Rx_PRI(Healer.PlayerReplicationInfo).AddScoreToPlayerAndTeam(Scr);
				Rx_PRI(Healer.PlayerReplicationInfo).AddRepairPoints_B(RealAmount); //Add to amount of Pawn repair points this 
			}

			
			Scr = RealAmount * HealPointsScale;
			Rx_PRI(Healer.PlayerReplicationInfo).AddScoreToPlayerAndTeam(Scr);
			Rx_PRI(Healer.PlayerReplicationInfo).AddRepairPoints_B(RealAmount); //Add to amount of Pawn repair points this 
			
		}

		if(bRepairArmor)
		{
			Armor = Min(repairableMaxHealth, Armor + Amount);
			repairableHealth = Armor;
		}
		else
		{
			Health = Min(repairableMaxHealth, Health + Amount);
			repairableHealth = Health;
		}
		
		if ( repairableHealth >= repairableMaxHealth )
		{
			if (RealAmount > 0 && (WorldInfo.TimeSeconds - LastBuildingRepairedMessageTime > 10) && bCanPlayRepaired )
			{
				BroadcastLocalizedTeamMessage(GetTeamNum(),MessageClass,BuildingRepaired,Healer.PlayerReplicationInfo,,self);
				LastBuildingRepairedMessageTime = WorldInfo.TimeSeconds;
			}
			bCanPlayRepaired = false;
			BuildingVisuals.TriggerEventClass(Class'Rx_SeqEvent_BuildingEvent',Healer,4); 
		}

		dmgLodLevel = GetBuildingHealthLod();
		if(dmgLodLevel != DamageLodLevel) {
			DamageLodLevel = dmgLodLevel;
			ChangeDamageLodLevel(dmgLodLevel);
		}
		//bForceNetUpdate = True;

		BuildingVisuals.TriggerEventClass(Class'Rx_SeqEvent_BuildingEvent',Healer,1); 

		return True;
	}

	return False;
}

function int GetBuildingHealthLod() {
	
	local int perc;
	if((Health+Armor) <= 0) {
		return 4;
	} else if((health+Armor) == GetMaxHealth()) {
		return 1;	
	}
	perc = (health+Armor)/(GetMaxHealth()/100);
	if(perc > 66) {
		if(DamageLodLevel == 2) {
			if(perc >= 80) 
				return 1;
			else
				return 2;
		} 
		return 1;
	} else if(perc > 33) {
		if(DamageLodLevel == 3) {
			if(perc >= 50) 
				return 2;
			else
				return 3;
		} 	
		return 2;		
	} else if(perc >= 0) {
		return 3;		
	}
	return (health+Armor)/400;						
}

simulated function ChangeDamageLodLevel(int newDmgLodLevel) 
{
	local int i;
	
	if(WorldInfo.NetMode != NM_DedicatedServer) 
	{
		for(i = 0; i < BuildingVisuals.StaticMeshPieces.length; i++) 
		{
			BuildingVisuals.StaticMeshPieces[i].ForcedLodModel = newDmgLodLevel; 
			BuildingVisuals.StaticMeshPieces[i].ForceUpdate(true);
		}

		if (newDmgLodLevel >= 1)
			DmgFxEnableLevel(1, true);
		else
			DmgFxEnableLevel(1, false);

		if (newDmgLodLevel >= 2)
			DmgFxEnableLevel(2, true);
		else
			DmgFxEnableLevel(2, false);

		if (newDmgLodLevel >= 3)
			DmgFxEnableLevel(3, true);
		else
			DmgFxEnableLevel(3, false);

		if (newDmgLodLevel >= 4)
		{
			DmgFxEnableLevel(4, true);
			DmgFxEnableLevel(0, false);
		}
		else
		{
			DmgFxEnableLevel(4, false);
			DmgFxEnableLevel(0, true);
		}

		DmgFxEnableLevel(-1, newDmgLodLevel==1);
		DmgFxEnableLevel(-2, newDmgLodLevel==2);
		DmgFxEnableLevel(-3, newDmgLodLevel==3);

		if (bInitialDamageLod)
			bInitialDamageLod = false;
	}
}

simulated function DmgFxEnableLevel(int lvl, bool on)
{
	// More icky
	local Rx_BuildingAttachment_DmgFx fx;
	switch (lvl)
	{
	case 0:
		if (DmgFx_Lvl0On == on)
			return;
		if (on)
			foreach DmgFx_Lvl0(fx)
				fx.TurnOn(bInitialDamageLod);
		else
			foreach DmgFx_Lvl0(fx)
				fx.TurnOff();
		DmgFx_Lvl0On = on;
		break;
	case 1:
		if (DmgFx_Lvl1On == on)
			return;
		if (on)
			foreach DmgFx_Lvl1(fx)
				fx.TurnOn(bInitialDamageLod);
		else
			foreach DmgFx_Lvl1(fx)
				fx.TurnOff();
		DmgFx_Lvl1On = on;
		break;
	case 2:
		if (DmgFx_Lvl2On == on)
			return;
		if (on)
			foreach DmgFx_Lvl2(fx)
				fx.TurnOn(bInitialDamageLod);
		else
			foreach DmgFx_Lvl2(fx)
				fx.TurnOff();
		DmgFx_Lvl2On = on;
		break;
	case 3:
		if (DmgFx_Lvl3On == on)
			return;
		if (on)
			foreach DmgFx_Lvl3(fx)
				fx.TurnOn(bInitialDamageLod);
		else
			foreach DmgFx_Lvl3(fx)
				fx.TurnOff();
		DmgFx_Lvl3On = on;
		break;
	case 4:
		if (DmgFx_Lvl4On == on)
			return;
		if (on)
			foreach DmgFx_Lvl4(fx)
				fx.TurnOn(bInitialDamageLod);
		else
			foreach DmgFx_Lvl4(fx)
				fx.TurnOff();
		DmgFx_Lvl4On = on;
		break;
	case -1:
		if (DmgFx_OnlyLvl1On == on)
			return;
		if (on)
			foreach DmgFx_OnlyLvl1(fx)
				fx.TurnOn(bInitialDamageLod);
		else
			foreach DmgFx_OnlyLvl1(fx)
				fx.TurnOff();
		DmgFx_OnlyLvl1On = on;
		break;
	case -2:
		if (DmgFx_OnlyLvl2On == on)
			return;
		if (on)
			foreach DmgFx_OnlyLvl2(fx)
				fx.TurnOn(bInitialDamageLod);
		else
			foreach DmgFx_OnlyLvl2(fx)
				fx.TurnOff();
		DmgFx_OnlyLvl2On = on;
		break;
	case -3:
		if (DmgFx_OnlyLvl3On == on)
			return;
		if (on)
			foreach DmgFx_OnlyLvl3(fx)
				fx.TurnOn(bInitialDamageLod);
		else
			foreach DmgFx_OnlyLvl3(fx)
				fx.TurnOff();
		DmgFx_OnlyLvl3On = on;
		break;
	}
}

simulated function AddDmgFx(Rx_BuildingAttachment_DmgFx fx, int level)
{
	switch (level)
	{
	case 0:
		DmgFx_Lvl0.AddItem(fx);
		break;
	case 1:
		DmgFx_Lvl1.AddItem(fx);
		break;
	case 2:
		DmgFx_Lvl2.AddItem(fx);
		break;
	case 3:
		DmgFx_Lvl3.AddItem(fx);
		break;
	case 4:
	case -4:
		DmgFx_Lvl4.AddItem(fx);
		break;
	case -1:
		DmgFx_OnlyLvl1.AddItem(fx);
		break;
	case -2:
		DmgFx_OnlyLvl2.AddItem(fx);
		break;
	case -3:
		DmgFx_OnlyLvl3.AddItem(fx);
		break;
	default:
		`log("DMGFX ERROR -"@fx@"("$fx.SocketPattern$") was not added to a DmgFx array in"@self);
		break;
	}
}

function bool PowerLost(optional bool bFromKismet)
{
	local Rx_Building_PowerPlant PP;

	if(!bFromKismet)
	{
		foreach AllActors(class'Rx_Building_PowerPlant', PP) 
		{
			if(TeamID == PP.TeamID && !PP.IsDestroyed())
			{	
				return false;
			}
		}
	}

	bNoPower = true;
	return true;
}

//PowerRestore function
// Modified by AX:
//	CNC-Field does not have a PP, but does have Obelisk/AGT, the old code would never re-enable the power as the map has no PP
function bool PowerRestore()
{
	local Rx_Building_PowerFactory building;
	local bool foundPowerPlant;
	local bool bPPAvailable;

	if(IsDestroyed())  // if this building is already destroyed, skip ahead and make it false
		return false;
	
	//Check for Powerplants
	foreach AllActors(class'Rx_Building_PowerFactory', building) 
	{
		if(TeamID == building.TeamID)
		{	
			if(!foundPowerPlant)
				foundPowerPlant = true;
			if(!building.IsDestroyed())
			{
				bPPAvailable = true;
				break;
			}
		}
	}
	
	// If the map has a power plant...
	if ( foundPowerPlant )
	{
		//If the found Powerplant is not destroyed and the building isn't destroyed
		if(bPPAvailable && !bDestroyed)
		{
			//Turn the power back on
			bNoPower = false;
			return true;
		}
	} 
	else 
	{
		if ( !bDestroyed )
		{
			//Turn the power back on
			bNoPower = false;
			return true;
		}
	}
	
	// We have a failure.
	return false;
}

simulated function PlayDestructionAnimation() 
{
	// refuse on server
	if (WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer)
		return;

	if( BuildingSkeleton.FindAnimSequence(DestructionAnimName) == none ) 
	{
		`Log("CLIENT - PlayDestructionAnimation() refused - no animation found!");
		return;
	}
	
	`log("Playing Destruction Animation ("$DestructionAnimName$")",bBuildingDebug,'Buildings');
	BuildingSkeleton.PlayAnim(DestructionAnimName);

	bBuildingRecoverable ? GotoState('IsDestroyedRecoverable') : GotoState('IsDestroyedIgnoreAll');
}

// TODO: for later game modes:
simulated state IsDestroyedIgnoreAll 
{
	ignores Touch, UnTouch, TakeDamage, HealDamage;

	simulated event BeginState(Name PreviousStateName) 
	{
		//`Log ("SERVER - Building was destroyed!!");
	}
}

// TODO: for later game modes:
simulated state IsDestroyedRecoverable 
{
	ignores Touch, UnTouch;

	simulated event BeginState(Name PreviousStateName) 
	{
		//`Log ("SERVER - Building was destroyed and is recoverable!!");
	}
}

simulated function SoundNodeWave GetAnnouncment(int alarm, int teamNum )
{
	if ( teamNum == GetTeamNum() )
	{
		return FriendlyBuildingSounds[alarm];
	} 
	else
	{
		return EnemyBuildingSounds[alarm];
	}

}

static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	local string str;
	 
	if(Switch == 0)
	{
		if(FRand() < 0.5)
		{
			str = Repl(class'Rx_Message_Buildings'.default.BuildingBroadcastMessages[0], "`PlayerName`", RelatedPRI_1.PlayerName);
			return Repl(str, "`BuildingName`", default.BuildingName);
		}
		else
		{
			str = Repl(class'Rx_Message_Buildings'.default.BuildingBroadcastMessages[1], "`PlayerName`", RelatedPRI_1.PlayerName);
			return Repl(str, "`BuildingName`", default.BuildingName);
		}
	}
	return "";
}

function ArmorBreak(Controller Con)
{
	local Rx_Controller PC; 
	
		foreach WorldInfo.AllControllers(class'Rx_Controller', PC)
		{
				if (PC.GetTeamNum() == Con.GetTeamNum() )
				{
				PC.DisseminateVPString("[Armour Break Bonus]&" $ class'Rx_VeterancyModifiers'.default.Ev_BuildingArmorBreak $ "&");
				}
		}
		bCanArmorBreak = false; 
		SetTimer(ArmorResetTime,false,'ResetArmorBreakEventTimer'); 
}

function ResetArmorBreakEventTimer()
{
	bCanArmorBreak = true; 
}

DefaultProperties
{
	/***************************************************/
	/*               Building Variables                */
	/***************************************************/	
	HDamagePointsScale		= 0.50f
	ADamagePointsScale		= 0.05f

	HealPointsScale         = 0.04f
	Destroyed_Score			= 1000 // Total number of points divided out when  
	
	HealthMax               = 4000
	BA_HealthMax			= 4800 //Slightly more health for building armour, but obviously with half of it being unrepairable. 
	DestructionAnimName     = "BuildingDeath"
	LowHPWarnLevel          = 200 // critical Health level
	RepairedHPLevel         = 3400 // 85%
	RepairedArmorLevel		= 1200 
	bBuildingRecoverable    = false
	TeamID                  = 255
	MessageClass            = class'Rx_Message_Buildings'
	MessageWaitTime         = 15.0f

	DamageLodLevel          = 1
	bInitialDamageLod       = true
	
	ArmorResetTime			= 300 //5 Minute time between being able to be rewarded for breaking armor (Seconds)
	bCanArmorBreak 			= true
	HealthLocked			= false 
}
