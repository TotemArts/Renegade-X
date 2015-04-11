class Rx_CratePickup extends UTItemPickupFactory
   config(RenegadeX);


/*
 * 0 - DeathCrateProbability
 * 1 - MoneyCrateProbability
 * 2 - CharacterCrateProbability
 * 3 - VehicleCrateProbability
 * 4 - SpyCrateProbability
 * 5 - RefillCrateProbability
 * */
var config array<float>     CrateProbabilities;
var config float     		MoneyCrateProbabilityWhenPPorRefDestroyed;
var config float     		SpyCrateProbabilityGainPerSec;
var config float     		RandomCharCrateProbabilityWhenRacksDestoyed;
var config float     		RandomVehicleCrateProbabiliyWhenWFDestroyed;
var config float 			MaxSpyCrateProbability;
var localized array<string> PickupMessages;
var()   bool                bNoVehicleSpawn; // vehicles will not spawn at this crate (use for tunnels!)
var()   bool                bNoNukeDeath; // no nuke explosion (big death crate)
var     bool                bRespawn;
var     array<SoundCue>     PickupSounds;
var repnotify bool          bShowExplosion;
var bool                    bWillBeActive;

replication
{
   if (Role == ROLE_Authority && bNetDirty)
      bShowExplosion;
}

simulated event ReplicatedEvent(name VarName)
{
   if ( VarName == 'bShowExplosion' )
   {
      if (bShowExplosion)
         ShowExpolosion();
   }
   else
   {
      Super.ReplicatedEvent(VarName);
   }
}

simulated function string GetHumanReadableName()
{
	return "Mystery Crate";
}

simulated function ShowExpolosion()
{
   if (WorldInfo.NetMode != NM_DedicatedServer)
   {
      PlaySound(SoundCue'RX_SoundEffects.Explosions.SC_Explosion_C4', true,,false);
      WorldInfo.MyEmitterPool.SpawnEmitter(ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Medium', Location, Rotation);
    }
}

simulated function PostBeginPlay()
{
   super.PostBeginPlay();
   // add self to global crates array
   if (Rx_Game(WorldInfo.Game) != none)
      Rx_Game(WorldInfo.Game).AddCrateAndActivateRnd(self);
}

function SpawnCopyFor(Pawn Recipient)
{
   DeactivateCrate();
   ExecutePickup(Recipient);
   Rx_Game(WorldInfo.Game).ActivateRandomCrate();
}

function bool isScheduledToBeActive()
{
   return bWillBeActive;
}

function setActiveIn(float inSeconds)
{
   bWillBeActive = true;
   setTimer(inSeconds, false, 'ActivateCrate');
}

function bool getIsActive()
{
   return !IsInState('Disabled') || bWillBeActive;
}

simulated function ActivateCrate()
{
   bShowExplosion = false;
   SetPickupVisible();
   SetCollision(true,false);
   bRespawn = true;
   bWillBeActive = false;
   GotoState('Sleeping');
}

simulated function DeactivateCrate()
{
   SetPickupHidden();
   SetCollision(false,false);
   bRespawn = false;
   GotoState('Disabled');
}

function int GetWeightedRandomIndex(Pawn Recipient)
{
   local int i;
   local float rnd,tempFloat;
   local bool fiveMinsPassed;
   
   ModifyProbabilitiesBasedOnBuildingStatus(Recipient);   
   
   rnd = FRand();
   
   // if no vehs allowed don't count it in
   if (bNoVehicleSpawn)
   {
      rnd -= CrateProbabilities[3];
   }
   
   fiveMinsPassed = WorldInfo.GRI.ElapsedTime > 300;  	
   
   if(!fiveMinsPassed)
   {					
		if(rnd <= 0.5 || !CanUseRefill(Recipient))
 			return 1; // Money Crate
		else
			return 5; // Refill Crate	
   }
   else
   {
   	  tempFloat = default.CrateProbabilities[4] + SpyCrateProbabilityGainPerSec*(WorldInfo.GRI.ElapsedTime - 300);
   	  if(tempFloat < MaxSpyCrateProbability)
   	  	 modifyCratePropability(4,tempFloat);
   	  	 
   	  if(!CanUseRefill(Recipient))
   	   	 modifyCratePropability(5,0.0f); 
   	   	 
   	  if(!HasFreeUnit(Recipient)) // then dont swap it out
   	  	 modifyCratePropability(2,0.0f);	 
   }
   
   for (i=0; i<=5;i++)
   {
      if ((bNoVehicleSpawn && i==3)) // if no vehs allowed don't count it in
         continue;

      if ((rnd < CrateProbabilities[i]) && (CrateProbabilities[i] != 0.0f))
         return i;

      rnd -= CrateProbabilities[i];
   }

   // should not happen 
   return 6;
}

function bool HasFreeUnit(Pawn Recipient)
{
	if(Rx_Pawn(Recipient).GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Soldier')
		return true;
	if(Rx_Pawn(Recipient).GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Shotgunner')
		return true;
	if(Rx_Pawn(Recipient).GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Grenadier')
		return true;
	if(Rx_Pawn(Recipient).GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Marksman')
		return true;
	if(Rx_Pawn(Recipient).GetRxFamilyInfo() == class'Rx_FamilyInfo_GDI_Engineer')
		return true;
		
	if(Rx_Pawn(Recipient).GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Soldier')
	 	return true;
	if(Rx_Pawn(Recipient).GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Shotgunner')
		return true;
	if(Rx_Pawn(Recipient).GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_FlameTrooper')
		return true;
	if(Rx_Pawn(Recipient).GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Marksman')
		return true;
	if(Rx_Pawn(Recipient).GetRxFamilyInfo() == class'Rx_FamilyInfo_Nod_Engineer')
		return true;		
		
	return false;	
}

function bool CanUseRefill(Pawn Recipient)
{
	local float MaxAmmoCount;
	local float AmmoCount;
	
	MaxAmmoCount = Rx_Weapon(Recipient.weapon).MaxAmmoCount;
	AmmoCount = Rx_Weapon(Recipient.weapon).AmmoCount;
	
	loginternal(AmmoCount/(MaxAmmoCount/100.0));		
	
	if(AmmoCount/(MaxAmmoCount/100.0) < 75.0)
	{
		loginternal(AmmoCount/(MaxAmmoCount/100.0));
		return true;	
	}
	
	if(Recipient.Health/(Recipient.HealthMax/100.0) < 75.0)
	{
		return true;	
	}
	return false;
}

function ModifyProbabilitiesBasedOnBuildingStatus(Pawn Recipient)
{
	local Rx_Building building;

	ForEach AllActors(class'Rx_Building',building)
	{
		if(Recipient.GetTeamNum() == TEAM_GDI && Rx_Building_WeaponsFactory(building) != None && Rx_Building_WeaponsFactory(building).IsDestroyed())
			modifyCratePropability(3,RandomVehicleCrateProbabiliyWhenWFDestroyed);
		else if(Recipient.GetTeamNum() == TEAM_Nod && Rx_Building_Airstrip(building) != None && Rx_Building_Airstrip(building).IsDestroyed())
			modifyCratePropability(3,RandomVehicleCrateProbabiliyWhenWFDestroyed);
		else if(Recipient.GetTeamNum() == TEAM_GDI && Rx_Building_Barracks(building) != None && Rx_Building_Barracks(building).IsDestroyed())
			modifyCratePropability(2,RandomCharCrateProbabilityWhenRacksDestoyed);
		else if(Recipient.GetTeamNum() == TEAM_Nod && Rx_Building_HandOfNod(building) != None && Rx_Building_HandOfNod(building).IsDestroyed())
			modifyCratePropability(2,RandomCharCrateProbabilityWhenRacksDestoyed);
		else if(Recipient.GetTeamNum() == TEAM_GDI && Rx_Building_PowerPlant_GDI(building) != None && Rx_Building_PowerPlant_GDI(building).IsDestroyed())
			modifyCratePropability(1,MoneyCrateProbabilityWhenPPorRefDestroyed);
		else if(Recipient.GetTeamNum() == TEAM_Nod && Rx_Building_PowerPlant_Nod(building) != None && Rx_Building_PowerPlant_Nod(building).IsDestroyed())
			modifyCratePropability(1,MoneyCrateProbabilityWhenPPorRefDestroyed);
	}
}

function modifyCratePropability(int crateNumber, float newProbability)
{
	local int i;
	local int CratesWithZeroProb;
	local float ProbabilityDiff;
	
	ProbabilityDiff = newProbability - CrateProbabilities[crateNumber];
	CrateProbabilities[crateNumber] = newProbability;
	for(i = 0; i<CrateProbabilities.length; i++)
	{
		if(CrateProbabilities[i] == 0.0f)	
			CratesWithZeroProb++;
	}	
	for(i = 0; i<CrateProbabilities.length; i++)
	{
		if(i != crateNumber && CrateProbabilities[i] != 0.0f)
			CrateProbabilities[i] = CrateProbabilities[i] - ProbabilityDiff/(CrateProbabilities.length - 1.0f - Float(CratesWithZeroProb));	
	}
}


function ExecutePickup(Pawn Recipient)
{
   local Rx_Vehicle Veh;
   local int tmpInt, tmpInt2;
   local Rx_Pawn p;
   local Vector tmpSpawnPoint;
   local bool fiveMinsPassed;
   local Rx_PRI pri;

   pri = Rx_PRI(Recipient.PlayerReplicationInfo);
   // rnd the pick and execute the appropriate step
   tmpInt = GetWeightedRandomIndex(Recipient);
   Recipient.PlaySound(PickupSounds[tmpInt]);
   switch(tmpInt)
   {
      case 0: // 0 - DeathCrate
		`LogRxPub("GAME" `s "Crate;" `s "death" `s "by" `s `PlayerLog(pri));
         SetTimer(0.1,false,'KillRecipient',Recipient);        
         break;
      case 1: // 1 - MoneyCrate
         // 100 to 500 credits in 50 interval
         fiveMinsPassed = WorldInfo.GRI.ElapsedTime > 300;  
         BroadcastLocalizedMessage(MessageClass, 3, pri);
         if(!fiveMinsPassed)
         	tmpInt = 150;
         else	
         	tmpInt = ((Rand(2)+1) * 100) + (Rand(2) * 50) + (Rand(2) * 50);
		 `LogRxPub("GAME" `s "Crate;" `s "money" `s tmpInt `s "by" `s `PlayerLog(pri));
         pri.AddCredits(tmpInt);
         Rx_Controller(Recipient.Controller).clientmessage(Repl(PickupMessages[3], "`credsum`", tmpInt, false));
         break;
      case 2: // 2 - CharacterCrate
         BroadcastLocalizedMessage(MessageClass, 4, pri);
         pri.SetChar(
            (Recipient.GetTeamNum() == TEAM_GDI ?
            class'Rx_PurchaseSystem'.default.GDIInfantryClasses[RandRange(5,class'Rx_PurchaseSystem'.default.GDIInfantryClasses.Length-1)] : 
            class'Rx_PurchaseSystem'.default.NodInfantryClasses[RandRange(5,class'Rx_PurchaseSystem'.default.NodInfantryClasses.Length-1)]),
            Recipient);
		`LogRxPub("GAME" `s "Crate;" `s "character" `s pri.CharClassInfo.name `s "by" `s `PlayerLog(pri));
         Rx_Controller(Recipient.Controller).clientmessage(PickupMessages[4]);
         break;
      case 3: // 3 - VehicleCrate
         tmpSpawnPoint = self.Location + vector(self.Rotation)*450;
         tmpSpawnPoint.Z += 200;
         tmpInt = Rand(2);

         // if not flying map, make sure no flying vehicles are given
         if (Rx_MapInfo(WorldInfo.GetMapInfo()).bAircraftDisabled)
            tmpInt2 = (tmpInt == TEAM_GDI ? Rand(class'Rx_PurchaseSystem'.default.GDIVehicleClasses.Length - 2) : Rand(class'Rx_PurchaseSystem'.default.NodVehicleClasses.Length - 2));
         else
            tmpInt2 = (tmpInt == TEAM_GDI ? Rand(class'Rx_PurchaseSystem'.default.GDIVehicleClasses.Length) : Rand(class'Rx_PurchaseSystem'.default.NodVehicleClasses.Length));
         
         BroadcastLocalizedMessage(MessageClass, 5, pri);
         
         Veh = Spawn((tmpInt == TEAM_GDI ?
            class'Rx_PurchaseSystem'.default.GDIVehicleClasses[tmpInt2] : 
            class'Rx_PurchaseSystem'.default.NodVehicleClasses[tmpInt2]),,, tmpSpawnPoint, self.Rotation,,true);
		`LogRxPub("GAME" `s "Crate;" `s "vehicle" `s Veh.class.name `s "by" `s `PlayerLog(pri));
         Rx_Controller(Recipient.Controller).clientmessage(Repl(PickupMessages[5], "`vehname`", veh.GetHumanReadableName(), false));
         Veh.DropToGround();
         if (Veh.Mesh != none)
            Veh.Mesh.WakeRigidBody();
         break;
      case 4: // 4 - SpyCrate
         tmpInt = Rand(14);
         Rx_Controller(Recipient.Controller).clientmessage(PickupMessages[6]);
         pri.SetChar(
            (Recipient.GetTeamNum() == TEAM_NOD ?
            class'Rx_PurchaseSystem'.default.GDIInfantryClasses[tmpInt] : 
            class'Rx_PurchaseSystem'.default.NodInfantryClasses[tmpInt]),
            Recipient);
         pri.SetIsSpy(true);
		 `LogRxPub("GAME" `s "Crate;" `s "spy" `s pri.CharClassInfo.name `s "by" `s `PlayerLog(pri));
         if (Recipient.GetTeamNum() == TEAM_NOD)
         {
            BroadcastLocalizedTeamMessage(TEAM_GDI, MessageClass, 6, pri);
            BroadcastLocalizedTeamMessage(TEAM_NOD, MessageClass, 7, pri);
         }
         else
         {
            BroadcastLocalizedTeamMessage(TEAM_NOD, MessageClass, 6, pri);
            BroadcastLocalizedTeamMessage(TEAM_GDI, MessageClass, 7, pri);
         }
         break;
      case 5: // 5 - RefillCrate
         Rx_Controller(Recipient.Controller).clientmessage(PickupMessages[7]);
         // default is refill
      default:
		`LogRxPub("GAME" `s "Crate;" `s "refill" `s "by" `s `PlayerLog(pri));
         p = Rx_Pawn(Recipient);
         BroadcastLocalizedMessage(MessageClass, 8, pri);
         if ( p != none )
         {
            p.Health = p.HealthMax;
            p.Armor  = p.ArmorMax;
			p.ClientSetStamina(p.MaxStamina);
         }
         if(Rx_InventoryManager(p.InvManager) != none )
         {
            Rx_InventoryManager(p.InvManager).PerformWeaponRefill();
         }
         break;
   }
}

auto state Pickup
{
   function float DetourWeight(Pawn Other,float PathWeight)
   {
      return 1.0; // TODO: add some weight logic for bots
   }

   function bool ValidTouch( Pawn Other )
   {
      return Other.IsA('Rx_Pawn') && Other.Health > 0;
   }
}

simulated function SetPickupMesh()
{
   AttachComponent(PickupMesh);

   if (bPickupHidden)
      SetPickupHidden();
   else
      SetPickupVisible();
}

/** @return whether the respawning process for this pickup is currently halted */
function bool DelayRespawn()
{
   return !bRespawn;
}

DefaultProperties
{
   RespawnTime=2.0000f
   RespawnSound=SoundCue'A_Pickups.Health.Cue.A_Pickups_Health_Respawn_Cue'
   PickupSound=none
   YawRotationRate=16000
   bRotatingPickup=true
   bFloatingPickup=true
   bRandomStart=true
   BobSpeed=4.0f
   BobOffset=5.0f
   MessageClass = class'Rx_Message_Crates'

   PickupSounds[0]=SoundCue'Rx_Pickups.Sounds.SC_Crate_CharacterChange'
   PickupSounds[1]=SoundCue'Rx_Pickups.Sounds.SC_Crate_Money'
   PickupSounds[2]=SoundCue'Rx_Pickups.Sounds.SC_Crate_CharacterChange'
   PickupSounds[3]=SoundCue'Rx_Pickups.Sounds.SC_Crate_VehicleDrop'
   PickupSounds[4]=SoundCue'Rx_Pickups.Sounds.SC_Crate_Spy'
   PickupSounds[5]=SoundCue'Rx_Pickups.Sounds.SC_Crate_Refill'

   Begin Object Class=StaticMeshComponent Name=CrateMesh
      StaticMesh=StaticMesh'RX_Deco_Containers.Meshes.SM_Crate_Wooden'//StaticMesh'Rx_Pickups.Health.SM_Health_Large'
      Scale=0.5f
      CollideActors=false
      BlockActors = false
      BlockZeroExtent=false
      BlockNonZeroExtent=false
      BlockRigidBody=false
   End Object
   PickupMesh=CrateMesh
   Components.Add(CrateMesh)

   Begin Object NAME=CollisionCylinder
      CollisionRadius=+00030.000000
      CollisionHeight=+00020.000000
      CollideActors=true
   End Object

   bHasLocationSpeech=true
   LocationSpeech(0)=SoundNodeWave'A_Character_IGMale.BotStatus.A_BotStatus_IGMale_HeadingForTheSuperHealth'
}
