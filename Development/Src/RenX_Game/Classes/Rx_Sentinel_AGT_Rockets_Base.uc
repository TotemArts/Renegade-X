//=============================================================================
// Sits on the floor and has fun taking pot-shots at things.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_Sentinel_AGT_Rockets_Base extends Rx_Sentinel;

var Vector AgtLocation;

simulated function byte GetTeamNum()
{
	return Team;
}
simulated function Tick(float DeltaTime)
{
	if(Target != none) {
		CalculateRotation(DeltaTime);
		DoRotation();
	}
	//AdjustRotationSounds(DeltaTime);
}

/**
 * Returns the minimal distance to owner that a target could possibly be attacked at.
 */
function bool IsOutsideMinimalDistToOwner(Pawn possibleTarget)
{
	return (VSize(possibleTarget.Location - AgtLocation) > MinimumRange);
}

simulated function DoRotation()
{
	local Rotator rot;
	rot = CurrentAim;
	rot.Pitch = 0;
	SetRelativeRotation(rot);
}

simulated function bool IsSameTeam(Pawn Other)
{
	local bool bSameTeam;
	bSameTeam = super.IsSameTeam(Other);

    if(!bSameTeam)
	{
         bSameTeam = (Other.GetTeamNum() == GetTeamNum());
    }

    //return false;         // when it should shoot averything for tests
    return bSameTeam;
}


simulated function CalculateRotation(float DeltaTime)
{
	local Rotator aimRotation;
//	local Vector DebugLineStart; 

	if(SWeapon == none || !SWeapon.bCanRotate)
	{
		DesiredAim = CurrentAim;
	}
	else if(!bTracking)
	{
		CalculateAutoRotateYaw(DeltaTime);
		DesiredAim = class'Rx_Sentinel_Utils'.static.RotateRelative(BaseComponent.Rotation, 0, AutoRotateYaw, 0);
	}

	DesiredAim = Normalize(DesiredAim);
	aimRotation = Rotator(SController.GetFocalPoint() - GetPawnViewLocation());

	CurrentAim = aimRotation;	

	//DebugLineStart = GetPawnViewLocation();
	//DrawDebugLine(DebugLineStart, DebugLineStart + (Vector(Rotation) * 128), 0, 0, 255);
	//DebugLineStart += vect(0.0, 0.0, 2.0) >> Rotation;
	//DrawDebugLine(DebugLineStart, DebugLineStart + (Vector(CurrentAim) * 128), 255, 0, 0);
	//DebugLineStart += vect(0.0, 0.0, 2.0) >> Rotation;
	//DrawDebugLine(DebugLineStart, DebugLineStart + (Vector(DesiredAim) * 128), 0, 255, 0);

}


/**
 * Sets up WeaponComponent according to properties of NewWeapon.
 */
simulated function SetWeapon(Rx_SentinelWeapon NewWeapon)
{
	SWeapon = NewWeapon;

	SWeapon.InitializeWeaponComponent(WeaponComponent);
	SetTimer(0.2,false,'UpdateRange'); 
	UpdateDamageEffects();
	WeaponComponent.PlaySpawnEffect();
	WeaponComponent.SetTranslation(vect(0.0,0.0,-150.0));
}




defaultproperties
{
	Team = 0// GDI AGT Sentinel

	
    //MenuName="AGT Rocket"
	//ShortMenuName="AGT Rocket"

	DefaultWeaponClass=class'Rx_SentinelWeapon_AGT_RocketPod'

	bCollideWorld=false //So it can spawn where we want, not where the collision says it will fit (will fail to spawn in some locations otherwise).
	bCollideActors=false;

	MaxRotationSpeed=(Pitch=80000,Yaw=80000)
	RotationDampingThreshold=4096

    AutoRotateRate=3000     /** Speed that Sentinel will rotate when it has no target. */

	// ~ -85deg.
	ViewPitchMax=30000
	ViewPitchMin=-30000

	AimAhead=0.0       // wohl besser runter oder auf 0 setzen
	HearingThreshold=1500.0
	SightRadius=8000.0
	PeripheralVision=-1.0
	BaseEyeHeight=6.4
	EyeHeight=6.4

	TargetingSound=None
	WaitingSound=None
	
	MinimumRange = 1000
}
