class Rx_CommanderSupport_EMPBomb extends Rx_BasicPawn
implements(RxIfc_Airlift)
implements(RxIfc_SeekableTarget) ; 

var StaticMeshComponent 				StatMesh;
var	Controller	InstigatingController; 
var DynamicLightEnvironmentComponent    LightEnvironment;
var	float								EMPVehicleTimeModifier, FuseTime, HomingSensitivity; 
var int									DetachThreshhold;
var	bool								bArmed; 
var vector								TargetVector;
var Rx_SupportVehicle					ParentVehicle; 

event Landed( vector HitNormal, actor FloorActor )
{
	
	if(bExplodeOnImpact) 
	{
		Explosion(InstigatingController);
		return; 
	}
	
	super.Landed(HitNormal, FloorActor);  
}



simulated function AirBurst()
{

	Explosion(InstigatingController);	
}


simulated event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local float CurDmg;
	local int TempDmg;
	local class<Rx_DmgType> RXDT; 
	
	if(EventInstigator != none && EventInstigator.GetTeamNum() == GetTeamNum()) return; 
	

	if (DamageAmount <= 0 || Health <= 0 || !bArmed)
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
	

simulated function Explosion(optional Controller EventInstigator) //Overrite for EMP so it doesn't have to re-iterate to EMP everything it already applied radius damage to
{
   local Actor A;  
   local Rx_EMPField EField; 
  
  if(bExploded) return; //Don't double dip on explosions
  
  if(!bArmed) 
  {
	SetHidden(true); 
	SetTimer(0.5f, false, 'ToDestroy');  
	return; 
  }
  
  bExploded = true; 
   if (WorldInfo.NetMode != NM_DedicatedServer) //This is literally the most worthless line ever for network play
      PlayExplosionEffect();

  if(bExplodes )
   foreach CollidingActors(class'Actor', A, ExplosionRadius, Location, true)
		{
         if(A != self)  A.TakeRadiusDamage(EventInstigator, ExplosionDamage, ExplosionRadius, DamageTypeClass != none ? DamageTypeClass : class'UTDmgType_Burning', DamageMomentum, location, bDoFullDamage, self);
			
				if ( RxIfc_EMPable(A) != None && RxIfc_EMPable(A).IsEffectedByEMP() && (A.bCanBeDamaged || A.bProjTarget) )
				{
					if (Rx_Building(A) != None)
						continue;
					RxIfc_EMPable(A).EMPHit(EventInstigator, self, EMPVehicleTimeModifier);
					if(ParentVehicle != none)
					{
						if(Rx_Vehicle(A) != none) 
							ParentVehicle.AddEffectiveness(A, 15);
						else
							ParentVehicle.AddEffectiveness(A, 5);
					}
						
				}
		}
   
   if (WorldInfo.NetMode != NM_Client)
	//	ReplicatePositionAfterLanded(); 
		EField = Spawn(class'Rx_EMPField',self,,location,,,);
		if(EField != none) 
		{
			EField.SetParticleScale((ExplosionRadius*1.0)/350.0); //((ExplosionRadius*1.0)/350.0);
			//`log(EField @ ((ExplosionRadius*1.0)/350.0));
		}
		
   SetHidden(true);
   
   SetTimer(0.5f, false, 'ToDestroy');
}	


event HitWall( vector HitNormal, actor Wall, PrimitiveComponent WallComp )
{
	
	Wall.TakeDamage(ExplosionDamage, InstigatingController, HitNormal, HitNormal, DamageTypeClass); 
	Explosion(InstigatingController);	
	
	super.HitWall(HitNormal, Wall, WallComp);
}


function UpdateTrajectory()
{
Acceleration = 16 * AccelRate * Normal(TargetVector - Location); 	
}

function ToDestroy()
{
	SetHidden(true); 
	super.ToDestroy(); 
}


simulated function Tick(float DeltaTime)
{
	SetRotation(rotator(Velocity));

	super.Tick(DeltaTime);
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
		ParentVehicle = Rx_SupportVehicle(Base);
		TeamIndex = ParentVehicle.GetTeamNum();
		InstigatingController = ParentVehicle.InstigatorController;
		TargetVector = ParentVehicle.TargetVector;
	}
}

simulated function DetachFromVehicle()
{ 
	SetPhysics(PHYS_FLYING);
	bArmed = true; 
	SetTimer(HomingSensitivity, true, 'UpdateTrajectory'); 	
	SetTimer(FuseTime, false, 'AirBurst'); 
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

	EMPVehicleTimeModifier = 6.0 //4.0

	HomingSensitivity = 0.2

	FuseTime = 3.75//5.0

	Physics = PHYS_Falling 

	DrawScale = 0.5

	bCanHeal = false 

	AirSpeed=2000
	AccelRate=800

	//Destroyable Actor 	
	Health=300
	HealthMax=300

	DetachThreshhold = 500

	ArmorType = ARM_Light

	ExplosionSound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_EMPGrenade'
	ExplosionEffect=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_EMPGrenade'


	bExplodes = true
	ExplosionDamage=0
	ExplosionRadius=1500
	bDamageAll=true 
	DamageMomentum=0
	bTakeRadiusDamage = true; 

	DamageTypeClass=class'Rx_DmgType_EMP'

	AntiAirAttentionPulseTime = 1.0
	bAttractAA = true

	ActorName = "Electromagnetic Pulse Bomb" 

	//Visuals

	  Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
			bEnabled=TRUE
		End Object
		LightEnvironment=MyLightEnvironment
		Components.Add(MyLightEnvironment)

	Begin Object Class=StaticMeshComponent Name=ObstacleMesh
			//HiddenGame=true
			StaticMesh						= StaticMesh'RX_VH_A-10.Mesh.SM_A-10_Missile_B'
			CastShadow                      = True
			CollideActors                   = True
			BlockActors                     = False
			BlockRigidBody                  = False
			BlockZeroExtent                 = True
			BlockNonZeroExtent              = True
			bCastDynamicShadow              = True
			AlwaysLoadOnServer=true
			AlwaysLoadOnClient=true
			LightingChannels                = (bInitialized=True,Static=false)
			LightEnvironment=MyLightEnvironment
			//Translation						= (X = 50.0, Y = -50.0, Z = -25.0)
		End Object
		StatMesh=ObstacleMesh
		//CollisionComponent=ObstacleMesh
		Components.Add(ObstacleMesh)
		
		
	  
	 bCollideActors=true
	 bCollideWorld=true 
	 bCollideComplex=true
	 bBlockActors=false
	 bProjTarget=true 
	 
	 
	 bShowHealth=true
	 
	 bAlwaysRelevant=false
	 bGameRelevant=true
	 
		
	Mass=+1500.000000 //Don't fly across the map
	
}