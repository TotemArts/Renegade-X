//=============================================================================
// Sits on the floor and has fun taking pot-shots at things.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class Rx_Sentinel_AGT_MG_Base extends Rx_Sentinel;

var Pawn savedEnemy;
var Vector AgtLocation;
simulated function byte GetTeamNum()
{
	return Team;
}

//// overwrite Tick() from Sentinel so that Rotation and Rotationsound are not processed
//simulated function Tick(float DeltaTime)
//{
//	DoRotation();
//	AdjustRotationSounds(DeltaTime);
//}

function bool FireAt(Vector Spot)
{
	local Vector Origin;
	local bool bFired;
	local Rotator CurrentAimNoRoll;

	
	//Roll removed because RDiff counts it as a rotation difference, for which roll is not important here.
	//If weapon doesn't pitch, assume it can hit no matter what the pitch difference (Grenade Launcher, Multi-Mortar).
	CurrentAimNoRoll.Pitch = (MinPitch == MaxPitch) ? DesiredAim.Pitch : CurrentAim.Pitch;
	CurrentAimNoRoll.Yaw = CurrentAim.Yaw;
	if(RDiff(DesiredAim, CurrentAimNoRoll) <= SWeapon.GetMaxAimError())
	{
        Origin = GetPawnViewLocation();

		if(VSize(Spot - Origin) <= GetRange())
		{
			//loginternal("firing");
			if(SWeapon.FireAt(Origin, CurrentAim, Spot))
			{
				UpgradeManager.NotifyFired();
				bForceNetUpdate = true;
				bFired = true;
			} else {
				bFired = false;
			}
		}
	} 

	return bFired;
}

/**
 * Returns the minimal distance to owner that a target could possibly be attacked at.
 */
function bool IsOutsideMinimalDistToOwner(Pawn possibleTarget)
{
	if(VSize(possibleTarget.Location - location) > MinimumRange) {
		return true;
	} else if(possibleTarget == SController.Enemy && bTrackingCloseRange) {
		return true;
	} else if(possibleTarget == SController.Enemy) {
		bTrackingCloseRange = true;
		SetTimer(2.0f,false,'trackInCloseRangeTimer');
		return true;
	}

	return false;
}

function bool IsVisibleFromGuns(Pawn possibleTarget)
{
	return true;
}


function trackInCloseRangeTimer () {
	bTrackingCloseRange = false;
	SController.Enemy = none;
}

/**
 * Rotates various components to visually match actual aim.
 * Controller's view is somehow locked to pawn's rotation, so rotate whole pawn, and rotate components separately so they appears to stay still.
 */
simulated function DoRotation()
{
	//SetRelativeRotation(CurrentAim - Base.Rotation);
	//local Rotator rot;
	//rot = Owner.Rotation;

	if(Role == ROLE_Authority) {
		if(SController.Enemy != savedEnemy) {
			savedEnemy = SController.Enemy;
			ClearTimer('trackInCloseRangeTimer');
			bTrackingCloseRange = false;
		}
	}

	if(CurrentAim != rot(0.0,0.0,0.0)) {
		SetRelativeRotation(CurrentAim);
	} else {
		SetRelativeRotation(DesiredAim);
	}
	//WeaponComponent simply pointed in direction of CurrentAim.
	//WeaponComponent.SetRotation(CurrentAim);
//	WeaponComponent.SetTranslation(WeaponComponent.default.Translation >> R);
}

//reliable demorecording demoRotation() {
//	local Rotator rot;
//	rot = Owner.Rotation;
//	if(CurrentAim != rot(0.0,0.0,0.0)) {
//		SetRelativeRotation(CurrentAim);
//	} else {
//		SetRelativeRotation(DesiredAim);
//	}
//}

simulated function bool IsSameTeam(Pawn Other)
{
	local bool bSameTeam;
	bSameTeam = super.IsSameTeam(Other);

    if(!bSameTeam)
	{
         bSameTeam = (Other.GetTeamNum() == GetTeamNum());
    }

    //return false;
    return bSameTeam;
}


simulated function CalculateRotation(float DeltaTime)
{
	local Rotator aimRotation;
//	local Vector DebugLineStart;

	// only server does rotation. Thats not optimal, cause clientside simulation could produce smoother results but it saves performance
	// and the difference is not that big. Though clientside simulation should be considered in the future.
	if(Role != ROLE_Authority) {
		return;
	}

	if(SWeapon == none || !SWeapon.bCanRotate)
	{
		DesiredAim = CurrentAim;
	}

	DesiredAim = Normalize(DesiredAim);
//	if(SController != none) {
		aimRotation = Rotator(SController.GetFocalPoint() - GetPawnViewLocation());
	//} else { // no Contoller means whe are on a Client
	//	foreach (DynamicActors Actor) {
			
	//	}
	//}
	aimRotation.Pitch = Clamp(aimRotation.Pitch, MinPitch, MaxPitch);


	//CurrentAim = OrthoRotation(SController.ViewX,SController.ViewY,SController.ViewZ);

	DesiredAim = aimRotation;
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
	WeaponComponent.SetTranslation(vect(0.0,0.0,20.0));
}

//simulated function CalculateRotation(float DeltaTime)
//{
//	local Vector WorldSpaceLocation, BoneSpaceLocation; //Dummy variables, don't use.
//	local Rotator BoneSpaceDesiredAim, BoneSpaceCurrentAim;
//	local Rotator BoneSpaceDelta;
//	local Vector X, Y, Z;
//	/*local Vector DebugLineStart;

//	DebugLineStart = GetPawnViewLocation();
//	DrawDebugLine(DebugLineStart, DebugLineStart + (Vector(Rotation) * 128), 0, 0, 255);
//	DebugLineStart += vect(0.0, 0.0, 2.0) >> Rotation;
//	DrawDebugLine(DebugLineStart, DebugLineStart + (Vector(CurrentAim) * 128), 255, 0, 0);
//	DebugLineStart += vect(0.0, 0.0, 2.0) >> Rotation;
//	DrawDebugLine(DebugLineStart, DebugLineStart + (Vector(DesiredAim) * 128), 0, 255, 0);*/

//	if(SWeapon == none || !SWeapon.bCanRotate)
//	{
//		DesiredAim = CurrentAim;
//	}
//	else if(!bTracking)
//	{
//		CalculateAutoRotateYaw(DeltaTime);
//		DesiredAim = class'Rx_Sentinel_Utils'.static.RotateRelative(BaseComponent.Rotation, 0, AutoRotateYaw, 0);
//	}

//	DesiredAim = Normalize(DesiredAim);

//	//Calculate actual change in rotation in Sentinel's local space, then convert back to world space rotation.
//	BaseComponent.TransformToBoneSpace(BaseComponent.RootBone, WorldSpaceLocation, DesiredAim, BoneSpaceLocation, BoneSpaceDesiredAim);
//	BoneSpaceDelta = Normalize(BoneSpaceDesiredAim - BoneSpaceLastAim); //Use rotation from last tick to account for any change in base rotation since then.
//	BoneSpaceDelta.Pitch = MaxRotationSpeed.Pitch * FClamp(BoneSpaceDelta.Pitch / RotationDampingThreshold, -1.0, 1.0) * DeltaTime;
//	BoneSpaceDelta.Yaw = MaxRotationSpeed.Yaw * FClamp(BoneSpaceDelta.Yaw / RotationDampingThreshold, -1.0, 1.0) * DeltaTime;
//	BoneSpaceCurrentAim = Normalize(BoneSpaceLastAim + BoneSpaceDelta);
//	BoneSpaceCurrentAim.Pitch = Clamp(BoneSpaceCurrentAim.Pitch, MinPitch, MaxPitch); //Limit pitch.
//	BaseComponent.TransformFromBoneSpace(BaseComponent.RootBone, BoneSpaceLocation, BoneSpaceCurrentAim, WorldSpaceLocation, CurrentAim);

//	//Make DeltaRotation be equal to the change in rotation in the Sentinel's local space (used for rotation sounds).
//	DeltaRotation = Normalize(BoneSpaceCurrentAim - BoneSpaceLastAim);

//	BoneSpaceLastAim = BoneSpaceCurrentAim;

//	//Add roll to current aim.
//	X = Vector(CurrentAim);
//	Z = vect(0.0, 0.0, 1.0) >> BaseComponent.Rotation;
//	Y = Z cross X;
//	CurrentAim = OrthoRotation(X, Y, Z);
//}




defaultproperties
{
	Team = 0 // GDI AGT Sentinel

	MinimumRange = 925
	
    // MenuName="AGT cannon"
	// ShortMenuName="AGT cannon"

	DefaultWeaponClass=class'Rx_SentinelWeapon_AGT_MG'

	bCollideWorld=false 	// So it can spawn where we want, not where the collision says it will fit (will fail to spawn in some locations otherwise).

	MaxRotationSpeed=(Pitch=80000,Yaw=80000)
	RotationDampingThreshold=4096

    AutoRotateRate=3000     /** Speed that Sentinel will rotate when it has no target. */

	MaxPitch = 30000
	// MinPitch = -6000
	MinPitch = -10000
	// ~ -85deg.
	ViewPitchMax=10000
	ViewPitchMin=-10000

	AimAhead=0.0       // wohl besser runter oder auf 0 setzen
	HearingThreshold=1500.0
	SightRadius=8000.0
//	PeripheralVision=0.71 //90 degree FOV
	PeripheralVision=-1.0
	BaseEyeHeight=6.4
	EyeHeight=6.4

	// TargetingSound=None
	WaitingSound=None

	Health=10000

	Begin Object Name=CollisionCylinder
		CollisionRadius=34.0
		CollisionHeight=32.0
	End Object

	Begin Object Name=BaseComponent0
		// SpawnMaterial=MaterialInstance'Sentinel_Resources.Materials.Sentinel.MI_Sentinel_Spawn'
		// DeadMaterial=MaterialInstance'Sentinel_Resources.Materials.Sentinel.MI_Sentinel_Dead'
		// SkeletalMesh=SkeletalMesh'Sentinel_Resources.Meshes.Sentinel.SK_Base_Floor'
		// SkeletalMesh=SkeletalMesh'BU_RenX_CeilingTurrets.Mesh.SK_Turret_MG'

		// SkeletalMesh=None
		// Materials[0]=MaterialInstance'Sentinel_Resources.Materials.Sentinel.MI_Sentinel'
		// PhysicsAsset=PhysicsAsset'Sentinel_Resources.Physics.SK_Base_Floor_Physics'
		Scale=0.0
		Translation=(X=0.0,Y=0.0,Z=-32.0)
	End Object
	BaseComponent=BaseComponent0

	Begin Object Name=RotatorComponent0
		// SpawnMaterial=MaterialInstance'Sentinel_Resources.Materials.Sentinel.MI_Sentinel_Spawn'
		// DeadMaterial=MaterialInstance'Sentinel_Resources.Materials.Sentinel.MI_Sentinel_Dead'
		// SkeletalMesh=SkeletalMesh'Sentinel_Resources.Meshes.Sentinel.SK_Rotator'

		// SkeletalMesh=None
        // Materials[0]=MaterialInstance'Sentinel_Resources.Materials.Sentinel.MI_Sentinel'
		// PhysicsAsset=PhysicsAsset'Sentinel_Resources.Physics.SK_Rotator_Physics'
		Scale=0.0
		Translation=(X=0.0,Y=0.0,Z=-32.0)
	End Object

	// Begin Object Name=WeaponComponent0
	//	SkeletalMesh=SkeletalMesh'BU_RenX_CeilingTurrets.Mesh.SK_Turret_MG'
	//	AnimTreeTemplate=AnimTree'BU_RenX_CeilingTurrets.Anims.AT_Turret_MG'
	//	AnimSets.Add(AnimSet'BU_RenX_CeilingTurrets.Anims.AnimTurret_MG')
	//	Translation=(X=0.0,Y=0.0,Z=-32.0)
	// End Object
	// WeaponComponent=WeaponComponent0

	Begin Object Class=Rx_SentinelComponent_ParticleSystem_Damage Name=DamageComponent0
		DamageThreshold=0.4
		//Template=ParticleSystem'Sentinel_Resources.Effects.Sentinel.P_DamageEffect_01'
	End Object
	DamageParticleComponents.Add(DamageComponent0)
	Components.Add(DamageComponent0)

	Begin Object Class=Rx_SentinelComponent_ParticleSystem_Damage Name=DamageComponent1
		DamageThreshold=0.15
		//Template=ParticleSystem'Sentinel_Resources.Effects.Sentinel.P_DamageEffect_02'
	End Object
	DamageParticleComponents.Add(DamageComponent1)
	Components.Add(DamageComponent1)
}
