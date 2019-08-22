//=============================================================================
// Controls the Obi Laser
//=============================================================================
class Rx_Sentinel_Obelisk_Laser_Base extends Rx_Sentinel;

var vector FireStartLoc; 

replication
{
	if ( bNetDirty && ROLE == ROLE_Authority)
		FireStartLoc;
}

simulated function byte GetTeamNum()
{
	return Team;
}

// overwrite Tick() from Sentinel so that Rotation and Rotationsound are not processed
simulated function Tick(float DeltaTime)
{
}

/**
 * Returns the minimal distance to owner that a target could possibly be attacked at.
 */
function bool IsOutsideMinimalDistToOwner(Pawn possibleTarget)
{
	return (VSizeSq(possibleTarget.Location - Owner.Location) > Square(MinimumRange) );//800);
}

function bool IsVisibleFromGuns(Pawn possibleTarget)
{
	return true;
}

function setFireStartLoc(Vector v)
{
	FireStartLoc = v;	 
}

function bool FireAt(Vector Spot)
{
	local Vector Origin;
	local bool bFired;

    Origin = GetPawnViewLocation();

	if(VSizeSq(Spot - Origin) <= Square(GetRange()))
	{
		if(SWeapon.FireAt(Origin, CurrentAim, Spot))
		{
			UpgradeManager.NotifyFired();
			bForceNetUpdate = true;
			bFired = true;
		} else {
			bFired = false;
		}
	}

	return bFired;
}

simulated function bool IsSameTeam(Pawn Other)
{
	local bool bSameTeam;
	bSameTeam = super.IsSameTeam(Other);

    if(!bSameTeam)
	{
         bSameTeam = (Other.GetTeamNum() == GetTeamNum());
    }

     //return false;           // zum Testen, wenn Obelisk auf alles feuern soll
    return bSameTeam;
}

simulated function Vector GetPawnViewLocation()
{
	local vector ViewLocation;
	ViewLocation = FireStartLoc;
	ViewLocation.Z -= 90;
	return ViewLocation;
}

defaultproperties
{
	Team = 1 // NOD Obelisk Laser

	MinimumRange = 1100
	
	//bNeverReplicateRotation=true

    //MenuName="Obelisk Laser"
	//ShortMenuName="Obelisk Laser"

	DefaultWeaponClass=class'Rx_SentinelWeapon_Obelisk'

	MaxRotationSpeed=(Pitch=50000,Yaw=50000)
	RotationDampingThreshold=4096

    AutoRotateRate=1000     /** Speed that Sentinel will rotate when it has no target. */

	// ~ -85deg.
	ViewPitchMax=30000
	ViewPitchMin=-30000

	AimAhead=0.0       // wohl besser runter oder auf 0 setzen
	HearingThreshold=1500.0
	SightRadius=11000.0
//	PeripheralVision=0.71 //90 degree FOV
	PeripheralVision=-1.0
	BaseEyeHeight=6.4
	EyeHeight=6.4

	Health=10000

	bHidden=false

	// Possibilitys for more custom sounds:
	TargetingSound=None
	WaitingSound=None

	bCollideWorld=false //So it can spawn where we want, not where the collision says it will fit (will fail to spawn in some locations otherwise).

    Begin Object Name=CollisionCylinder
		CollisionRadius=34.0
		CollisionHeight=32.0
	End Object

	Begin Object Name=BaseComponent0
		//SpawnMaterial=MaterialInstance'Sentinel_Resources.Materials.Sentinel.MI_Sentinel_Spawn'
		//DeadMaterial=MaterialInstance'Sentinel_Resources.Materials.Sentinel.MI_Sentinel_Dead'
		//SkeletalMesh=SkeletalMesh'Sentinel_Resources.Meshes.Sentinel.SK_Base_Floor'
		//Materials[0]=MaterialInstance'Sentinel_Resources.Materials.Sentinel.MI_Sentinel'
		//PhysicsAsset=PhysicsAsset'Sentinel_Resources.Physics.SK_Base_Floor_Physics'
		Scale=0.0
		Translation=(X=0.0,Y=0.0,Z=-32.0)
	End Object

	Begin Object Name=RotatorComponent0
		//SpawnMaterial=MaterialInstance'Sentinel_Resources.Materials.Sentinel.MI_Sentinel_Spawn'
		//DeadMaterial=MaterialInstance'Sentinel_Resources.Materials.Sentinel.MI_Sentinel_Dead'
		//SkeletalMesh=SkeletalMesh'Sentinel_Resources.Meshes.Sentinel.SK_Rotator'
		//Materials[0]=MaterialInstance'Sentinel_Resources.Materials.Sentinel.MI_Sentinel'
		//PhysicsAsset=PhysicsAsset'Sentinel_Resources.Physics.SK_Rotator_Physics'
		Scale=0.0
		Translation=(X=0.0,Y=0.0,Z=-32.0)
	End Object

	Begin Object Name=WeaponComponent0
		Translation=(X=0.0,Y=0.0,Z=-10.0)
	End Object

	Begin Object Class=Rx_SentinelComponent_ParticleSystem_Damage Name=DamageComponent0
		DamageThreshold=0.4
		Template=ParticleSystem'RX_FX_Vehicle.Damage.P_Fire_Large'
	End Object
	DamageParticleComponents.Add(DamageComponent0)
	Components.Add(DamageComponent0)

	Begin Object Class=Rx_SentinelComponent_ParticleSystem_Damage Name=DamageComponent1
		DamageThreshold=0.15
		Template=ParticleSystem'RX_FX_Vehicle.Damage.P_SteamSmoke'
	End Object
	DamageParticleComponents.Add(DamageComponent1)
	Components.Add(DamageComponent1)
}
