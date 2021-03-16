class Rx_CratePickup extends Rx_Pickup
   config(RenegadeX)
   implements(RxIfc_Targetable);

`include(RenX_Game\RenXStats.uci);

var()   bool                bNoVehicleSpawn; // vehicles will not spawn at this crate (use for tunnels!)
var()   bool                bNoNukeDeath; // no nuke explosion (big death crate)
var     bool                bRespawn;
var bool                    bWillBeActive;

var array<class<Rx_CrateType> >   DefaultCrateTypes;
var array <Rx_CrateType> InstancedCrateTypes;

simulated function string GetHumanReadableName()
{
	return "Mystery Crate";
}

simulated function PostBeginPlay()
{
   super.PostBeginPlay();

   InstantiateDefaultCrateTypes();

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

function InstantiateDefaultCrateTypes()
{
	local int i;

	if (Role == ROLE_Authority)
	{
		for (i = 0; i < DefaultCrateTypes.Length; i++)
		{
			InstancedCrateTypes.AddItem(new DefaultCrateTypes[i]);
		}
	}
}

function Rx_CrateType DetermineCrateType(Rx_Pawn Recipient)
{
	local int i;
	local float probabilitySum, random;
	local array<float> probabilities;
	local Rx_Mutator RxMut;
	local Rx_CrateType crateType;
	
	// This allows a mutator to overwrite the returned crate type, if anything else is returned that is not
	// 	a child of this current class, it's ignored. -- Ax
	RxMut = Rx_Game(WorldInfo.Game).GetBaseRxMutator();
	if ( RxMut != None )
	{
		crateType = RxMut.OnDetermineCrateType(Recipient,self);
		if ( crateType != None && ClassIsChildOf(crateType.class, class'Rx_CrateType') )
			return crateType;
	}

	// Get sum of probabilities, and cache values
	for (i = 0; i < InstancedCrateTypes.Length; i++)
	{
		if (WorldInfo.GRI.ElapsedTime >= InstancedCrateTypes[i].StartSpawnTime)
		{
			probabilities.AddItem(InstancedCrateTypes[i].GetProbabilityWeight(Recipient,self));
			//`log(InstancedCrateTypes[i] @ "probability:" @ probabilities[i]);
			probabilitySum += probabilities[i];
		}
		else
			probabilities.AddItem(0.0f);
	}
	`log("Probability Sum:" @ probabilitySum);

	random = FRand() * probabilitySum;

	for (i = 0; i < InstancedCrateTypes.Length; i++)
	{
		if (random <= probabilities[i])
			return InstancedCrateTypes[i];
		else
			random -= probabilities[i];
	}

	return InstancedCrateTypes[InstancedCrateTypes.Length - 1]; // Should never happen
}

function ExecutePickup(Pawn Recipient)
{
	local Rx_PRI pri;
	local Rx_CrateType CrateType;

	if (Rx_Pawn(Recipient) == none) // Only allow Rx_Pawns to pickup crates
		return;

	pri = Rx_PRI(Recipient.PlayerReplicationInfo);
	CrateType = DetermineCrateType(Rx_Pawn(Recipient));
	CrateType.ExecuteCrateBehaviour(Rx_Pawn(Recipient),pri, self);
	if (CrateType.PickupSound != none)
		Recipient.PlaySound(CrateType.PickupSound);

	CrateType.BroadcastMessage(pri,self);
	
	if(Rx_Controller(Recipient.Controller) != None )
		CrateType.SendLocalMessage(Rx_Controller(Recipient.Controller));
	
	`LogRxPub(CrateType.GetGameLogMessage(pri,self));

	`RecordGamePositionStat(PICKUP_CRATE, location, 1);
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


/*-------------------------------------------*/
/*BEGIN TARGET INTERFACE [RxIfc_Targetable]*/
/*------------------------------------------*/
//Health
simulated function int GetTargetHealth() {return 0;} //Return the current health of this target
simulated function int GetTargetHealthMax() {return 0;} //Return the current health of this target

//Armour 
simulated function int GetTargetArmour() {return 0;} // Get the current Armour of the target
simulated function int GetTargetArmourMax() {return 0;} // Get the current Armour of the target 

// Veterancy

simulated function int GetVRank() {return 0;}


/*Get Health/Armour Percents*/
simulated function float GetTargetHealthPct() {return 0 ;}
simulated function float GetTargetArmourPct() {return 0;}
simulated function float GetTargetMaxHealthPct() {return 0;} //Everything together (Basically Health and armour)

/*Get what we're actually looking at*/
simulated function Actor GetActualTarget() {return self;} //Should return 'self' most of the time, save for things that should return something else (like building internals should return the actual building)

/*Booleans*/
simulated function bool GetUseBuildingArmour(){return false;} //Stupid legacy function to determine if we use building armour when drawing. 
simulated function bool GetShouldShowHealth(){return false;} //If we need to draw health on this 
simulated function bool AlwaysTargetable() {return false;} //Targetable no matter what range they're at
simulated function bool GetIsInteractable(PlayerController PC) {return false;} //Are we ever interactable?
simulated function bool GetCurrentlyInteractable(PlayerController RxPC) {return false;} //Are we interactable right now? 
simulated function bool GetIsValidLocalTarget(Controller PC) {return !bPickupHidden;} //Are we a valid target for our local playercontroller?  (Buildings are always valid to look at (maybe stealthed buildings aren't?))
simulated function bool HasDestroyedState() {return false;} //Do we have a destroyed state where we won't have health, but can't come back? (Buildings in particular have this)
simulated function bool UseDefaultBBox() {return false;} //We're big AF so don't use our bounding box 
simulated function bool IsStickyTarget() {return true;} //Does our target box 'stick' even after we're untargeted for awhile 
simulated function bool HasVeterancy() {return false;} 

//Spotting
simulated function bool IsSpottable() {return true;}
simulated function bool IsCommandSpottable() {return false;} 

simulated function bool IsSpyTarget(){return false;} //Do we use spy mechanics? IE: our bounding box will show up friendly to the enemy [.... There are no spy Refineries...... Or are there?]

/* Text related */

simulated function string GetTargetName() {return GetHumanReadableName();} //Get our targeted name 
simulated function string GetInteractText(Controller C, string BindKey) {return "";} //Get the text for our interaction 
simulated function string GetTargetedDescription(PlayerController PlayerPerspectiv) {return "";} //Get any special description we might have when targeted 

//Actions
simulated function SetTargeted(bool bTargeted) ; //Function to say what to do when you're targeted client-side 

/*----------------------------------------*/
/*END TARGET INTERFACE [RxIfc_Targetable]*/
/*---------------------------------------*/

DefaultProperties
{
   RespawnTime=2.0000f
   PickupSound=none // From base class, don't use it.
   MessageClass = class'Rx_Message_Crates'

   Begin Object Class=StaticMeshComponent Name=CrateMesh
		StaticMesh=StaticMesh'RX_Deco_Containers.Meshes.SM_Crate_Wooden'//StaticMesh'Rx_Pickups.Health.SM_Health_Large'
		Scale=0.5f
		CollideActors=false
		BlockActors = false
		BlockZeroExtent=false
		BlockNonZeroExtent=false
		BlockRigidBody=false
		LightEnvironment = PickupLightEnvironment
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

	DefaultCrateTypes.Add(class'Rx_CrateType_Money')
	DefaultCrateTypes.Add(class'Rx_CrateType_Spy')
	DefaultCrateTypes.Add(class'Rx_CrateType_Refill')
	DefaultCrateTypes.Add(class'Rx_CrateType_Vehicle')
	DefaultCrateTypes.Add(class'Rx_CrateType_Suicide')
	DefaultCrateTypes.Add(class'Rx_CrateType_Character')
	DefaultCrateTypes.Add(class'Rx_CrateType_TimeBomb')
	DefaultCrateTypes.Add(class'Rx_CrateType_Nuke')
	DefaultCrateTypes.Add(class'Rx_CrateType_Speed')
	DefaultCrateTypes.Add(class'Rx_CrateType_Abduction')
	DefaultCrateTypes.Add(class'Rx_CrateType_TSVehicle')
	DefaultCrateTypes.Add(class'Rx_CrateType_Veterancy')
	DefaultCrateTypes.Add(class'Rx_CrateType_DamageResistance')
	DefaultCrateTypes.Add(class'Rx_CrateType_ClassicVehicle')
	DefaultCrateTypes.Add(class'Rx_CrateType_EpicCharacter')
	DefaultCrateTypes.Add(class'Rx_CrateType_Teleport')
	DefaultCrateTypes.Add(class'Rx_CrateType_DMRandomWeapon')
	DefaultCrateTypes.Add(class'Rx_CrateType_RandomWeapon')
	DefaultCrateTypes.Add(class'Rx_CrateType_SuperMoney')
	DefaultCrateTypes.Add(class'Rx_CrateType_RadarSweep')
	DefaultCrateTypes.Add(class'Rx_CrateType_SlowDown')
}
