class Rx_CratePickup extends Rx_Pickup
   config(RenegadeX);

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

	DefaultCrateTypes[0] = class'Rx_CrateType_Money'
	DefaultCrateTypes[1] = class'Rx_CrateType_Spy'
	DefaultCrateTypes[2] = class'Rx_CrateType_Refill'
	DefaultCrateTypes[3] = class'Rx_CrateType_Vehicle'
	DefaultCrateTypes[4] = class'Rx_CrateType_Suicide'
	DefaultCrateTypes[5] = class'Rx_CrateType_Character'
	DefaultCrateTypes[6] = class'Rx_CrateType_TimeBomb'
	DefaultCrateTypes[7] = class'Rx_CrateType_Nuke'
	DefaultCrateTypes[8] = class'Rx_CrateType_Speed'
	DefaultCrateTypes[9] = class'Rx_CrateType_Abduction'
	DefaultCrateTypes[10] = class'Rx_CrateType_TSVehicle'
	DefaultCrateTypes[11] = class'Rx_CrateType_Veterancy'
	DefaultCrateTypes[12] = class'Rx_CrateType_DamageResistance'
	DefaultCrateTypes[13] = class'Rx_CrateType_ClassicVehicle'
	DefaultCrateTypes[14] = class'Rx_CrateType_EpicCharacter'
	DefaultCrateTypes[15] = class'Rx_CrateType_Kamikaze'
}
