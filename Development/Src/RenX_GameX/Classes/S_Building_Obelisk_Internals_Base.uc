class S_Building_Obelisk_Internals_Base extends Rx_Building_Obelisk_Internals_Base;

/*function SetupLaser() 
{
	local vector v,v2;

	laserSentinel = Spawn(class'S_Sentinel_Obelisk_Laser_Base',,,,,,true);
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
}*/

DefaultProperties
{
	LaserSentinelClass = class'S_Sentinel_Obelisk_Laser_Base'
}
