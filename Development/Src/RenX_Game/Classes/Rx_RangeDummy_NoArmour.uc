/**
* Simple Dummies used for shooting targets 
* [Should likely be attached to a factory]
*/

class Rx_RangeDummy_NoArmour extends Rx_BasicPawn
placeable; 

/*If true, it will only use its actual armour type till it runs out of armour. Then it uses NONE to simulate an infantry unit*/
var bool bUseInfantryArmour;
var int	 Armour, ArmourMax;  
var DynamicLightEnvironmentComponent    LightEnvironment;

struct DamageInstance
{
	var float DamageAmount;
	var class<DamageType> DmgType;
	var float WorldTime;
};

var float TotalDamageTaken;
var int TotalHitsTaken;
var float DPS;
var float PeakDPS;

var array<DamageInstance> DamageInstances;

//Comment
function float ParseArmor(float AdjustedDamage, class<Rx_DmgType> RXDT)
{
	if(bUseInfantryArmour && Armour <=0)
	{
		AdjustedDamage*=RXDT.static.NoArmourDamageScalingFor();
		return AdjustedDamage; 
	}

	switch(ArmorType)
		{
			//Heavy Vehicle Armour 
			case ARM_Heavy: 
			AdjustedDamage*=RXDT.static.VehicleDamageScalingFor(none);
			break; 
			//Light Vehicle Armour
			case ARM_Light: 
			AdjustedDamage*=RXDT.static.LightVehicleDamageScalingFor();
			break; 
			
			//Building armour 
			case ARM_Building: 
			AdjustedDamage*=RXDT.static.BuildingDamageScalingFor();
			break; 
			
			//Armourless infantry damage
			case ARM_Infantry: 
			AdjustedDamage*=RXDT.static.NoArmourDamageScalingFor();
			break; 
			
			case ARM_Aircraft: 
			AdjustedDamage*=RXDT.static.AircraftDamageScalingFor();
			break; 
			
			//Kevlar infantry armour 
			case ARM_KEVLAR: 
			AdjustedDamage*=RXDT.static.KevlarDamageScalingFor();
			break; 
			
			//Flak Infantry Armour 
			case ARM_FLAK: 
			AdjustedDamage*=RXDT.static.FLAKDamageScalingFor();
			break; 
		
		}	
		return AdjustedDamage; 
}

simulated event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local float CurDmg;
	local int TempDmg;
	local class<Rx_DmgType> RXDT;
	local string KillersName;
	local int	 ArmourTemp; 
	local DamageInstance DmgInstance;
	
	if(EventInstigator.GetTeamNum() == GetTeamNum()) return; 
	

	if (DamageAmount <= 0 || Health <= 0)
      return;
		
	RXDT=class<Rx_DmgType>(DamageType);
	
	if(RXDT == none) return; 
	
	`log("Range Dummy Hit by Damage Type:" @ RXDT); 
	
	if ( DamageType != None )
	{
		
		CurDmg = ParseArmor(DamageAmount, RXDT);
		
		DamageAmount = int(ParseArmor(DamageAmount, RXDT));
		
		//`log(DamageAmount @ CurDmg);
		
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
		
		super(Actor).TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);

		DmgInstance.DamageAmount = DamageAmount;
		DmgInstance.DmgType = DamageType;
		DmgInstance.WorldTime = WorldInfo.TimeSeconds;
		DamageInstances.AddItem(DmgInstance);

		TotalDamageTaken += DamageAmount;
		TotalHitsTaken++;
		
	//`log(DamageAmount @ SavedDmg @ RXDT); 
	}
	
		ArmourTemp = Armour - DamageAmount;
		if( ArmourTemp < 0 )
		{
			Armour = 0;
			ArmourTemp *= -1;
			Health -= ArmourTemp;
		}
		else
		{
			Armour = ArmourTemp;
		}
	
	//Health-=DamageAmount;

	//KISS
	if (Health <= 0)
	{	
		//`log(EventInstigator); 
		
		if(Rx_Controller(EventInstigator) != None && GetTeamNum() != EventInstigator.GetTeamNum()) Rx_Controller(EventInstigator).DisseminateVPString("["$ ActorName @ "Destroyed]&"$VPReward$"&"); 
		else
		if(Rx_Bot(EventInstigator) != None && GetTeamNum() != EventInstigator.GetTeamNum()) Rx_Bot(EventInstigator).DisseminateVPString("["$ ActorName @ "Destroyed]&"$VPReward$"&"); 
		else
		if(Rx_Defence_Controller(EventInstigator) != none) //Just give defences VP, nothing else
		{
			Rx_Defence_Controller(EventInstigator).GiveVeterancy(default.VPReward);	
		}
		
		Explosion(EventInstigator);
		
		if(EventInstigator.PlayerReplicationInfo != none )
		{
			KillersName = EventInstigator.PlayerReplicationInfo.PlayerName ;
		}
		
		BasicPawnKilled(KillersName);
	}
}

function Tick(float DeltaTime)
{
	local DamageInstance DmgInstance;
	super.Tick(DeltaTime);

	DPS = 0;

	ForEach DamageInstances(DmgInstance)
	{
		if (DmgInstance.WorldTime - WorldInfo.TimeSeconds < -1)
		{
			DamageInstances.RemoveItem(DmgInstance);
			continue;
		}

		DPS += DmgInstance.DamageAmount;

		if (DPS > PeakDPS)
			PeakDPS = DPS;
	}
}

simulated function int GetHealth() {
   return Health+Armour;
}

simulated function int GetMaxHealth() {
   return HealthMax+ArmourMax;
}

DefaultProperties
{
	Health=100
	HealthMax=100
	Armour = 100
	ArmourMax = 100 
	
	HealPointMod=0.0;
	VPReward =+0

	ActorName = "Dummy[No Armour]" 
	ArmorType = ARM_INFANTRY
	bUseInfantryArmour = true 
	bTakeRadiusDamage = true
	
	ExplosionSound=none
	ExplosionEffect=none
	ExplosionShake=CameraAnim'Envy_Effects.Camera_Shakes.C_VH_Death_Shake'
	InnerExplosionShakeRadius=1
	OuterExplosionShakeRadius=2
	ExplosionShakeScale=0.1
	
	/*Default Visual stuff*/


	//Default Lights 
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
			bEnabled            = True
			bDynamic            = True
			bSynthesizeSHLight  = True
			TickGroup           = TG_DuringAsyncWork
		End Object
		Components.Add(MyLightEnvironment)
		LightEnvironment = MyLightEnvironment
		
		/** Simulated proxy, so players can execute simulated functions to
		 *  spawn visual and sound effects. */
		RemoteRole=ROLE_SimulatedProxy
		bAlwaysRelevant = true; //Their location needs to be known
		
	
	Begin Object Class=SkeletalMeshComponent Name=WSkeletalMesh	
		SkeletalMesh=SkeletalMesh'rx_ch_gdi_soldier.Mesh.SK_CH_GDI_Soldier'
	AnimSets(0)=AnimSet'RX_CH_Animations.Anims.AS_WeapProfile_Unarmed'
	AnimTreeTemplate=AnimTree'RX_CH_Animations.Anims.AT_Character_Modular'
	BlockZeroExtent=True				// Uncomment to enable accurate hitboxes (1/3)
	CollideActors=true;					// Uncomment to enable accurate hitboxes (2/3)
	BlockNonZeroExtent   = true  
	BlockActors=true
	End Object
	Mesh=WSkeletalMesh
	Components.Add(WSkeletalMesh)
	
	
	Begin Object Name=CollisionCylinder
		CollisionRadius=16
		CollisionHeight=50 //60		
			BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true //false
		BlockRigidBody = false
		CollideActors=true
	End Object
		CollisionComponent=CollisionCylinder
		
		bCollideActors = true
		bCollideWorld = true; 
		bCollideComplex = true;

}	