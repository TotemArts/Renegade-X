// A weapon to deploy stuff, 

Class Rx_Weapon_Blueprint extends Rx_Weapon_Reloadable
	implements(RxIfc_Blueprint);


// Build Status

var Rx_BlueprintModel ActiveModel;
var vector BuildLoc, BuildNormal;
var Rotator BuildRot;
var Actor BuildBase;
var bool bValidPlacement;

// Build Rotation modifier

var vector2D Build2DRotPlane;
var float BuildCurrentAngle;
var rotator ExtraRotation;

// Build Constants

var() vector BuildOffset;
var() float BuildScale;
var() class<Rx_BlueprintModel> ModelClass;
var() vector RotationMultiplier;
var() float BuildClearRadius;
var() float MinNormalZ, MaxNormalZ;
var() SkeletalMesh VisualMesh;
var() ParticleSystem DeploymentEffect;


simulated state Active
{
	simulated function BeginState(name PrevStateName)
	{
		super.BeginState(PrevStateName);

		// make sure this only gets executed on players ever
		if (WorldInfo.NetMode == NM_DedicatedServer ||
			(WorldInfo.NetMode == NM_ListenServer && !bNetOwner))
			return;

		if(ActiveModel == None)
		{
			ActiveModel = spawn(ModelClass,,,BuildLoc + BuildOffset,BuildRot);
			ActiveModel.BoundWeapon = RxIfc_Blueprint(Self);
			
			GetBlueprintLocation();

			SetupVisual();
		}
	}

	simulated event EndState( Name NextStateName )
	{
		super.EndState(NextStateName);

		if(ActiveModel != None)
		{
			ActiveModel.Destroy();
			ActiveModel = None;
		}

		if (WorldInfo.NetMode == NM_DedicatedServer ||
			(WorldInfo.NetMode == NM_ListenServer && !bNetOwner))
			return;

		if(Rx_Controller(Instigator.Controller) != None && Rx_PlayerInput(Rx_Controller(Instigator.Controller).PlayerInput).AirstrikeLock)
		{
			Rx_Controller(Instigator.Controller).AirstrikeUnlock();
		}

		ExtraRotation = rot(0,0,0);
		Build2DRotPlane = vect2d(0,0);
		BuildCurrentAngle = 0;
	}

	simulated event Tick( float DeltaTime ) 
	{
		super.Tick(DeltaTime);
	
		// make sure this only gets executed on players ever
		if (WorldInfo.NetMode == NM_DedicatedServer ||
			(WorldInfo.NetMode == NM_ListenServer && !bNetOwner))
			return;

		GetBlueprintLocation();

		if(ActiveModel == None)
			return;

		if(ActiveModel.Location != BuildLoc + BuildOffset)
			ActiveModel.SetLocation(GetBlueprintModelLocation());
		
		if(ActiveModel.Rotation != BuildRot)
			ActiveModel.SetRotation(BuildRot);
	}

	simulated function StartFire(byte FireModeNum)
	{
		if (Instigator == None || !Instigator.bNoWeaponFiring)
		{
			// make sure this only gets executed on players ever
			if (WorldInfo.NetMode == NM_DedicatedServer ||
				(WorldInfo.NetMode == NM_ListenServer && !bNetOwner))
				return;

				if(FireModeNum == 0)
				{
					if (!PlacementAllowed()) 
					{
						AnnounceDeployFailure();
						return; // if Can't place building here, do nothing
					}			
					DeployBlueprint(BuildLoc + BuildOffset,BuildRot);
					SpawnDeploymentEffect(BuildLoc + BuildOffset, BuildRot);
				}

				else if(FireModeNum == 1)
				{
					Rx_Controller(Instigator.Controller).AirstrikeLock();
				}
		}
	}

	simulated function StopFire(byte FireModeNum)
	{
		super.StopFire(FireModeNum);

		if(FireModeNum == 1)
		{
			Rx_Controller(Instigator.Controller).AirstrikeUnlock();
		}
	}
}

simulated function SetupVisual()
{
	ActiveModel.Visual.SetSkeletalMesh(VisualMesh);
	ActiveModel.SetDrawScale(BuildScale);
	ActiveModel.RevalidateMat();
}

simulated function GetBlueprintLocation()
{
	local Vector TempLoc, TempOri, TempDir;
	local Rotator TempRot;
	local vector HitLocation, HitNormal;


	Instigator.Controller.GetPlayerViewPoint(TempOri, TempRot); 
	TempDir = Vector(TempRot);
	TempLoc = TempOri + (TempDir * WeaponRange);

	BuildBase = Instigator.Trace(HitLocation,HitNormal, TempLoc, TempOri,,,, TRACEFLAG_Blocking);

	if(BuildBase == None)
		BuildBase = Instigator.Trace(HitLocation,HitNormal, TempLoc - (Vect(0,0,1) * 1000), TempLoc,,,, TRACEFLAG_Blocking);


	if(BuildBase == None)
	{
		BuildLoc = TempLoc;
		BuildNormal = Vect(0,0,1);
	}
	else
	{
		BuildLoc = HitLocation;
		BuildNormal = HitNormal;
		
	}

	BuildRot = GetBuildRotation();
	bValidPlacement = IsBuildCorrect();
}

simulated function bool IsBuildCorrect()
{
	return (BuildBase != None && BuildNormal.Z >= MinNormalZ && BuildNormal.Z <= MaxNormalZ
		&& BuildBase.bStatic && Rx_Building(BuildBase) == None
		&& RadiusIsClear());	
}

simulated function bool RadiusIsClear()
{
	local Actor A;

	if(BuildClearRadius <= 0)
		return true;

	foreach VisibleCollidingActors( class'Actor', A, BuildClearRadius, BuildLoc + BuildOffset)
	{
		if(Rx_Building(A) != None || Pawn(A) != None || Rx_Weapon_DeployedActor(A) != None)
			return false;
	}

	return true;
}

simulated function rotator GetBuildRotation()
{
	local Rotator RotationResult;

	RotationResult = Instigator.Rotation;
	RotationResult.Pitch *= RotationMultiplier.x;
	RotationResult.Roll *= RotationMultiplier.y;
	RotationResult.Yaw *= RotationMultiplier.z;
	
	RotationResult.Yaw += ExtraRotation.Yaw;

	return  RotationResult; 
}

/** Airstrike-esque rotation here. */
simulated function AdjustRotation(float X, float Y)
{
	local rotator r;
	Build2DRotPlane.X += X * 0.001f;
	Build2DRotPlane.Y += Y * 0.001f;

	BuildCurrentAngle = Atan2(Build2DRotPlane.Y, Build2DRotPlane.X);

	// push X and Y back on to circle
	Build2DRotPlane.X = Cos(BuildCurrentAngle);
	Build2DRotPlane.Y = Sin(BuildCurrentAngle);

	BuildCurrentAngle *= RadToDeg;
	BuildCurrentAngle -= 90.f;
	//`log("rot=" $ angle);

	/* Decal System
	if (mat != none)
		mat.SetScalarParameterValue('AS_DM_RotationAmount', ASCurrentAngle / 360.f);*/
	//r = vect(0,0,0);
	r.Yaw = (BuildCurrentAngle * DegToUnrRot);
	ExtraRotation = r;
}


reliable server function DeployBlueprint(vector DeployLoc, rotator DeployRot)
{	
	if(ActiveModel != None)
	{
		ActiveModel.Destroy();
		ActiveModel = None;
	}	

	Rx_InventoryManager(Instigator.InvManager).RemoveWeaponOfClass(self.Class);	
}

simulated function bool PlacementAllowed()
{
	return bValidPlacement;
}

simulated function AnnounceDeployFailure()
{
	if(Rx_Controller(Instigator.Controller) != None)
		Rx_Controller(Instigator.Controller).CTextMessage("Cannot deploy here",'Red',120);
}

simulated function SpawnDeploymentEffect(vector DeployLoc, rotator DeployRot)
{
	if(WorldInfo.NetMode != NM_DedicatedServer)
		WorldInfo.MyEmitterPool.SpawnEmitter(DeploymentEffect, DeployLoc,DeployRot);
}

simulated function Vector GetBlueprintModelLocation()
{
	return BuildLoc + BuildOffset;
}

DefaultProperties
{
	ShotCost(0)=1
	ShotCost(1)=0
	FireInterval(0)=+1.0
	FireInterval(1)=+0.0
	ReloadTime(0)=1.0
	ReloadTime(1)=0.0

	MaxDesireability=0.0
	AIRating=+0.6
	CurrentRating=0.0
	RespawnTime=1.0
	InventoryGroup=6
	InventoryMovieGroup=17

	bUseClientAmmo = false 
	bMeleeWeapon = true

	GroupWeight=1
	
	AmmoCount=1
	MaxAmmoCount=1
	ClipSize=1
	InitalNumClips=1

	EquipTime=1.75f

	WeaponFireTypes(0)=EWFT_Custom
	WeaponFireTypes(1)=EWFT_Custom	

	WeaponRange=700
	BuildScale=1.f

	RotationMultiplier= (X=0,Y=0,Z=1)
	MinNormalZ = 0.8;
	MaxNormalZ = 1;

	ModelClass = class'Rx_BlueprintModel'

	ArmsAnimSet=AnimSet'RX_WP_Blueprint.Anims.AS_Blueprint_Arms'

	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object
	
	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_Blueprint.SkeletalMesh.SK_WP_Blueprint'
		AnimSets(0)=AnimSet'RX_WP_Blueprint.Anims.AS_Blueprint_1P'
		Animations=MeshSequenceA
		Scale=2.0
		FOV=50.0
	End Object	

	DeploymentEffect = ParticleSystem'RX_WP_Blueprint.Particles.P_DeploymentDust'
}