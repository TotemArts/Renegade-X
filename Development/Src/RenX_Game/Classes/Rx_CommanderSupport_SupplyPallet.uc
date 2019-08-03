class Rx_CommanderSupport_SupplyPallet extends Rx_BasicPawn
implements(RxIfc_Airlift)
implements(RxIfc_TargetedDescription)
implements(RxIfc_SeekableTarget) ; 

var StaticMeshComponent 				StatMesh;
var float	SupplyDelay; //Time between supplying 
var	int		VehicleRepairAmount, InfantryHealAmount; 
var int		Supply, MaxSupply, SupplyRadius; 
var	Controller	InstigatingController; 
var DynamicLightEnvironmentComponent    LightEnvironment;
var	SoundCue							Snd_SupplySound;						

var int 								DetachThreshhold; 

replication 
{
	if( ROLE == ROLE_AUTHORITY && (bNetDirty || bNetInitial)) 
		Supply; 
}

function SupplyTimer()
{
local Pawn P; 

//`log("Supplytimer");
	foreach CollidingActors(class'Pawn',P,SupplyRadius)
	{
		if(P.GetTeamNum() != GetTeamNum()) continue; 
		
		if(Rx_Vehicle(P) != none && Rx_vehicle(P).bCanAcceptSupportHealing() && Rx_Vehicle(P).HealDamage(VehicleRepairAmount,InstigatingController, none)) 
		{
		Rx_Vehicle(P).SetLastSupportHealTime();
		Supply-=VehicleRepairAmount;	
		}
		else
		if(Rx_Pawn(P) != none) 
		{
			HealAndReArmInfantry(Rx_Pawn(P)); 	
		}
	}	
}

function HealAndReArmInfantry(Rx_Pawn MyPawn)
{
	local Rx_Weapon Weap;
	local Rx_Weapon_Reloadable RWeap;
	local int AddAmount;
	//if(Rx_InventoryManager(Recipient.InvManager) != none)
		//Rx_InventoryManager(Recipient.InvManager).PerformWeaponRefill();
	
	//`log("Healing"); 

	if(!MyPawn.bCanAcceptSupportHealing()) return; 
	

		
	if( MyPawn.HealDamage(InfantryHealAmount, InstigatingController, none)) 
	{
		MyPawn.SetLastSupportHealTime();
		Supply-=InfantryHealAmount;
	}


	
	ForEach Rx_InventoryManager(MyPawn.InvManager).InventoryActors(class'Rx_Weapon', Weap)
	{
		if (Rx_Weapon_Deployable(Weap) == None)
		{
			if(Rx_Weapon_Reloadable(Weap) != none && Rx_Weapon_Reloadable(Weap).AmmoCount <= Rx_Weapon_Reloadable(Weap).MaxAmmoCount-Rx_Weapon_Reloadable(Weap).ClipSize) //As long as it's missing at least an entire clip
			{
				RWeap = Rx_Weapon_Reloadable(Weap); 
				AddAmount = fmin(RWeap.AmmoCount+RWeap.ClipSize, RWeap.MaxAmmoCount);
				RWeap.AmmoCount = AddAmount; 
				if(WorldInfo.NetMode == NM_DedicatedServer) RWeap.ClientUpdateAmmoCount(AddAmount);
				Supply-=5; 
			}				
			else
			if(Rx_Weapon_Reloadable(Weap) == none) Weap.PerformRefill(); 
			
			Weap.bForceHidden = false;
		}
		
	}
}

simulated function int GetMaxSupply()
{
	return default.MaxSupply;
}

simulated function int GetSupply()
{
	return Supply;
}

event Landed( vector HitNormal, actor FloorActor )
{
	super.Landed(HitNormal, FloorActor);  
	ClearTimer('AttractAA');
	
	if(bExplodeOnImpact) 
	{
	InstaKill();
	return; 
	}
	
	//SetPhysics(Phys_None); 
	//SetHardAttach(true);
	//Mass=2000;
	//SetTimer(SupplyDelay, true, 'SupplyTimer'); 
	
}

simulated event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local float CurDmg;
	local int TempDmg;
	local class<Rx_DmgType> RXDT; 
	
	if(EventInstigator != none && EventInstigator.GetTeamNum() == GetTeamNum()) return; 
	

	if (DamageAmount <= 0 || Health <= 0)
      return;
		
	RXDT=class<Rx_DmgType>(DamageType);
	
	if(RXDT == none) return; 
	
	if ( DamageType != None )
	{
		
		CurDmg = ParseArmor(DamageAmount, RXDT);
		
		DamageAmount = int(ParseArmor(DamageAmount, RXDT));
		
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
			super.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
		
		if(DamageAmount >= DetachThreshhold && Rx_SupportVehicle(Base) != none) 
		{
		Rx_SupportVehicle(Base).CallForceDetach(true, EventInstigator);  ; //Detach from your base, cuz you got FU**ED UP	
		bExplodeOnImpact=true ; //Turn volatile 
		}
	}

	//KISS
	if (Health <= 0)
	{	
		Explosion(EventInstigator);
	}
}
	

function DestroyMe()
{
	SetHidden(true); 
	super.DestroyMe(); 
}

//RxIfc_Airlift
simulated function bool bReadyToLift() 
{
	
	return true ; //Pretty much impossible to end up in the line of fire of getting picked up by another Chinook
} 

simulated function OnAttachToVehicle()
{
	if(Rx_SupportVehicle(Base) != none) 
	{
	TeamIndex = Rx_SupportVehicle(Base).GetTeamNum();
	InstigatingController = Rx_SupportVehicle(Base).InstigatorController;	
	}
}

simulated function DetachFromVehicle()
{ 
	SetPhysics(PHYS_FALLING); 
	SetTimer(SupplyDelay, true, 'SupplyTimer'); 
}
//End RxIfc_Airlift

//RxIfc_TargetedDescription

simulated function string GetTargetedDescription(PlayerController PlayerPerspective)
{
	return "Supplies:" @ Supply @ "/" @ MaxSupply; 
}

//RxIfc_SeekableTarget - VERY susceptable to being shot down by AntiAir



/*********RxIfc_SeekableTarget**********/
function float GetAimAheadModifier()
{
	return 50.0;
}
function float GetAccelrateModifier()
{
	return 100.0;
}


simulated function vector GetAdjustedLocation()
{
	return location; 
}

/*********RxIfc_SeekableTarget**********/

DefaultProperties
{

Physics = PHYS_None

//DrawScale = 1.5

InfantryHealAmount 	= 4
VehicleRepairAmount = 5
Snd_SupplySound		= SoundCue'rx_interfacesound.Wave.SC_Click4'


bCanHeal = true 

Supply				= 300
MaxSupply			= 300
SupplyRadius		= 700

SupplyDelay			= 1.0

//Destroyable Actor 	
Health=200
HealthMax=200
bDrawLocation = true;

DetachThreshhold = 30

ArmorType = ARM_Light

ExplosionSound=SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_Explode'

bExplodes = true
ExplosionDamage=255
ExplosionRadius=600
bDamageAll=true 
DamageMomentum=10000
bTakeRadiusDamage = true; 

DamageTypeClass=class'Rx_DmgType_Explosive'

AntiAirAttentionPulseTime = 2.0
bAttractAA = false

ActorName = "Supply Crate" 

WalkingPhysics=PHYS_Falling
	LandMovementState=PlayerWalking
	WaterMovementState=PlayerSwimming

//Visuals

  Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=TRUE
	End Object
	LightEnvironment=MyLightEnvironment
	Components.Add(MyLightEnvironment)

Begin Object Class=StaticMeshComponent Name=ObstacleMesh
		//HiddenGame=true
		StaticMesh						= StaticMesh'RX_Deco_BuildingAssets.StaticMeshes.BuildingAssets_Crate_3_Closed'
		//PhysicalMaterial				= PhysicalMaterial'PhysicalMaterials.Default.Metal.PM_Metal'
		CastShadow                      = True
		CollideActors                   = True
		BlockActors                     = True
		BlockRigidBody                  = false //True
		BlockZeroExtent                 = True
		BlockNonZeroExtent              = True
		bCastDynamicShadow              = True
		AlwaysLoadOnServer=true
		AlwaysLoadOnClient=true
		LightingChannels                = (bInitialized=True,Static=false)
		LightEnvironment=MyLightEnvironment
		Translation						= (X = 50.0, Y = -50.0, Z = -25.0)
	End Object
	StatMesh=ObstacleMesh
	//CollisionComponent=ObstacleMesh
	Components.Add(ObstacleMesh)
	
	Begin Object Name=CollisionCylinder
		CollisionRadius=+050.000000
		CollisionHeight=+015.0000000
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true //false
		BlockRigidBody = false
		CollideActors=true
   End Object
   CollisionComponent=CollisionCylinder
   Components.Add(CollisionCylinder)
  
 bCollideActors=true
 bCollideWorld=true 
 bCollideComplex=true
 bBlockActors=true
 bProjTarget=true 
 bOrientonSlope=true;
 bCanStepUpOn = True 
 bPushedByEncroachers = false 
 
 bShowHealth=true
 
 bAlwaysRelevant=false
 bGameRelevant=true
	RemoteRole=ROLE_SimulatedProxy
	bPathColliding=true
	
Mass=+10.000000 //Don't fly across the map
	
}