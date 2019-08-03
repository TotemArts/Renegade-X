class Rx_Building_Obelisk_Internals_Base extends Rx_Building_Team_Internals;

var Rx_Sentinel_Obelisk_Laser_Base laserSentinel;
var MaterialInstanceConstant CrystalGlowMIC;

simulated function Init(Rx_Building Visuals, bool isDebug )
{
	Super.Init(Visuals,isDebug);
	if(WorldInfo.NEtmode != NM_Client && !Rx_Building_Defense(Visuals).bDisabled) 
	{
		SetupLaser();
	}	
}

function SetupLaser() 
{
	local vector v,v2;

	laserSentinel = Spawn(class'Rx_Sentinel_Obelisk_Laser_Base',,,,,,true);
	laserSentinel.SetOwner(self);
	laserSentinel.Team = self.TeamID;

	if(laserSentinel != none)
	{
		laserSentinel.bCollideWorld = true; //Turn off collision and translate, because collision may move the Sentinel away from the ceiling when it's spawned.
		v = BuildingSkeleton.GetBoneLocation(BuildingSkeleton.GetSocketBoneName('Ob_Fire'));
		v.z += 100;
		laserSentinel.setFireStartLoc(v);
		v2 = BuildingVisuals.location;
		v2.z = v.z;
		v2 = v2 + Normal(v-v2)*100;
		laserSentinel.setlocation(v2);
		Rx_Building_Nod_Defense(BuildingVisuals).SentinelLocation = laserSentinel.location;

		laserSentinel.Initialize();
		CrystalGlowMIC = BuildingSkeleton.CreateAndSetMaterialInstanceConstant(0);

		Rx_SentinelWeapon_Obelisk(laserSentinel.SWeapon).CrystalGlowMIC = CrystalGlowMIC;
		laserSentinel.SController.TargetWaitTime = 6.0;
		laserSentinel.SController.bSeeFriendly=false;
		laserSentinel.SController.TargetWaitTime=3.0;
		laserSentinel.SController.SightCounterInterval=0.15;
		laserSentinel.MyBuilding=BuildingVisuals;
		
		Rx_SentinelWeapon_Obelisk(laserSentinel.SWeapon).InitAndAttachMuzzleFlashes(BuildingSkeleton, 'Ob_Fire');
	}
}

function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser) 
{
	super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	if(laserSentinel != None) 
	{
		laserSentinel.SController.NotifyTakeHit(EventInstigator,HitLocation,DamageAmount,DamageType,Momentum);
	}
	
	if(bDestroyed) 
	{
		OnBuildingDestroyed();
	}
}

simulated function OnBuildingDestroyed()
{
	if(laserSentinel != None) {
		Rx_SentinelWeapon_Obelisk(laserSentinel.SWeapon).ClearTimer('crystalChargingGlow');
		Rx_SentinelWeapon_Obelisk(laserSentinel.SWeapon).CrystalGlowMIC.SetScalarParameterValue('Obelisk_Glow', 0.0); 
		Rx_SentinelWeapon_Obelisk(laserSentinel.SWeapon).FiringState=0;
		laserSentinel.SController.Cannon.Destroy();
		laserSentinel.Destroy();
	}
}

function bool PowerLost(optional bool bFromKismet)
{
	if((bFromKismet || super.PowerLost()) && laserSentinel != none) 
	{
		laserSentinel.SController.Cannon.Destroy();
		laserSentinel.Destroy();

		return true;
	}

	return false;
}

//PowerRestore function
function bool PowerRestore()
{
	if(super.PowerRestore())
	{
		SetupLaser();
		return true;
	}
	else{
		return false;
	}
}
