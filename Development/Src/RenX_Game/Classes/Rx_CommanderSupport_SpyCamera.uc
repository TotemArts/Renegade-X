class Rx_CommanderSupport_SpyCamera extends Rx_BasicPawn
implements(RxIfc_Airlift)
implements(RxIfc_SeekableTarget) ; 

var StaticMeshComponent 				StatMesh;
var	Controller	InstigatingController; 
var DynamicLightEnvironmentComponent    LightEnvironment;					

var int 								DetachThreshhold; 
var int									ScanRadius;
var float								TargetSpotTime;
var float								ScanInterval;
var int									SpottingEffectivenessAddend; 

simulated function PreBeginPlay()
{
	super.PreBeginPlay();
	
	SetHidden(true); 
}

function ScanTimer()
{
	local Pawn EnemyPawn; 
	local vector ScanVector; 

	ScanVector+=location; 

	ScanVector.Z-=100;

	//`log("Supplytimer");
		foreach VisibleActors(class'Pawn',EnemyPawn,ScanRadius, ScanVector)
		{
			
			if(EnemyPawn.GetTeamNum() == GetTeamNum()) continue; 
			//`log("Visible pawn" @ EnemyPawn);
			if(Rx_PRI(EnemyPawn.PlayerReplicationInfo) == none && Rx_DefencePri(EnemyPawn.PlayerReplicationInfo) == none) continue; 
		
			if(Rx_Vehicle(EnemyPawn) != none) Rx_Vehicle(EnemyPawn).SetSpotted(TargetSpotTime); 
			else
			if(Rx_Pawn(EnemyPawn) != none && Rx_Pawn(EnemyPawn).PlayerReplicationInfo != none ) Rx_PRI(Rx_Pawn(EnemyPawn).PlayerReplicationInfo).SetSpotted(TargetSpotTime);
			
			SetPlayerCommandSpotted(EnemyPawn.PlayerReplicationInfo.playerID); //Rx_Vehicle(EnemyPawn).SetSpotted(60.0); 
			
			if(Rx_SupportVehicle(Base) != none)
			{
				Rx_SupportVehicle(Base).AddEffectiveness(EnemyPawn, SpottingEffectivenessAddend); 
			}
			
		}	
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
	
function SetPlayerCommandSpotted(int playerID) //Use Defence_ID for RX_Defences, since they don't have player IDs
{
	local int i;

	//loginternal("server Command spotted"$playerID);
	
	for (i = 0; i < WorldInfo.GRI.PRIArray.Length; i++)
	{
		if(Rx_Pri(WorldInfo.GRI.PRIArray[i]) != None)
		{
			if (WorldInfo.GRI.PRIArray[i].PlayerID == playerID)
			{
				Rx_Pri(WorldInfo.GRI.PRIArray[i]).SetAsTarget(1);
				return;
			}
		}
		else
		if(Rx_DefencePri(WorldInfo.GRI.PRIArray[i]) != None)
		{
			if (Rx_DefencePri(WorldInfo.GRI.PRIArray[i]).Defence_ID == playerID)
			{
				Rx_DefencePri(WorldInfo.GRI.PRIArray[i]).SetAsTarget(1);
				return;
			}
		}
		else
		continue; 
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
		 Rx_SupportVehicle(Base).SetbDropPayload(false);
		 Rx_SupportVehicle(Base).SetInvincible(false);
		 
		
		if(ROLE == ROLE_AUTHORITY) 
			SetTimer(ScanInterval,true,'ScanTimer');
	}
}

simulated function DetachFromVehicle()
{ 
	DestroyMe(); 
}
//End RxIfc_Airlift

//RxIfc_TargetedDescription

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

/******************************/

DefaultProperties
{

/**Camera Details***/
ScanInterval	=0.5  //1.0
ScanRadius		= 6500 //5500 //10000
TargetSpotTime	=45.0
SpottingEffectivenessAddend = 10 

Physics = PHYS_None

//Destroyable Actor 	
Health=200
HealthMax=200
bDrawLocation = false;

DetachThreshhold = 500

ArmorType = ARM_Light

ExplosionSound=SoundCue'RX_SoundEffects.Vehicle.SC_Vehicle_Explode'

bExplodes = true
ExplosionDamage=0
ExplosionRadius=0
bDamageAll=false 
DamageMomentum=0
bTakeRadiusDamage = true; 

DamageTypeClass=class'Rx_DmgType_Explosive'

AntiAirAttentionPulseTime = 2.0
bAttractAA = true

ActorName = "Camera" 

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
  
 bCollideActors=false
 bCollideWorld=false 
 bCollideComplex=false
 bBlockActors=true
 bProjTarget=true 
 bOrientonSlope=true;
 bCanStepUpOn = True 
 bPushedByEncroachers = false 
 
 bShowHealth=false
 
 bAlwaysRelevant=false
 bGameRelevant=true
	RemoteRole=ROLE_SimulatedProxy
	bPathColliding=true
	
Mass=+10.000000 //Don't fly across the map
	
}