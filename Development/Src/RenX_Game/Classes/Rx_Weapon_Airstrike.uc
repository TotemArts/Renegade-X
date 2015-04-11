/** one1: Weapon class for airstrike. */
class Rx_Weapon_Airstrike extends Rx_Weapon_Scoped
	abstract;

/** Airstrike type vehicle (A10 for GDI or AC130 for NOD) */
var class<Rx_Airstrike_Vehicle> AirstrikeType;

/** Deployment time; how long player controls are locked and is able to control AS direction. */
var float DeploymentTime;

/** Maximal distance for AS to strike from current player position. */
var float MaxDistance;

/** Airstrike decal, which can be rotated to direct AS rotation. */
var DecalMaterial DecalM;

/** Beam. */
var ParticleSystem BeamEffect;

var class<Rx_AirStrikeTarget> TargetActorClass;

var float DecalHeight;
var float DecalWidth;
var float DecalThickness;

// private vars
var private vector AirstrikeLocation;
var private vector2D AS2DRotPlane;
var private DecalComponent ASDecal;
var private MaterialInstanceConstant mat;
var private float ASCurrentAngle;
var private int StartingYaw;
var private vector InstigatorLocation;
var private ParticleSystemComponent Beam;
var private DecalComponent TmpDecal;
var private Rx_AirstrikeTarget TargetActor;
var private bool TargetActorActive;

// visual
var private bool     bShowLoadPanel;
var private float    SecondsNeedLoad;           /** seconds need to load to place ION-Cannon*/
var private float    PanelWidth, PanelHeight;   /** width and height of the panel relative to screen size*/
var private int      CurrentProgress;
var() Color   PanelColor;
var int AirstrikeCooldown;

// stubbed out, so the weapon can work properly
simulated function bool HasAnyAmmo() { return true; }
simulated function bool HasAmmo( byte FireModeNum, optional int Amount ) { return true; }

// override this function to catch Moved event
simulated function Moved();

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	// make sure this only gets executed on players ever
	if (WorldInfo.NetMode == NM_DedicatedServer ||
		(WorldInfo.NetMode == NM_ListenServer && !bNetOwner))
		return;

	if (Instigator != None && Instigator.Location != InstigatorLocation) 
		Moved();
}

simulated function SpawnBeam()
{
	local vector start;

	// get starting point of beam
	if (!SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndRotation('MuzzleFlashSocket', start))
		start = Instigator.Location;

    Beam = WorldInfo.MyEmitterPool.SpawnEmitter(BeamEffect, start);
    Beam.SetVectorParameter('BeamEnd', AirstrikeLocation);
	Beam.SetDepthPriorityGroup(SDPG_Foreground);
}

simulated function ActivateTargetPS()
{
	if (TargetActorActive)
		return;
	TargetActor.ActivatePS();
	TargetActorActive = true;
}

simulated function DeactivateTargetPS()
{
	if (!TargetActorActive)
		return;
	TargetActor.DeactivatePS();
	TargetActorActive = false;
}

/** This function gets called on clients only when mouse position changes.
 *  It is used to adjust AS decal in proper rotation according to mouse input. */
simulated function AdjustRotation(float X, float Y)
{
	local rotator r;
	AS2DRotPlane.X += X * 0.001f;
	AS2DRotPlane.Y += Y * 0.001f;

	ASCurrentAngle = Atan2(AS2DRotPlane.Y, AS2DRotPlane.X);

	// push X and Y back on to circle
	AS2DRotPlane.X = Cos(ASCurrentAngle);
	AS2DRotPlane.Y = Sin(ASCurrentAngle);

	ASCurrentAngle *= RadToDeg;
	ASCurrentAngle -= 90.f;
	//`log("rot=" $ angle);

	/* Decal System
	if (mat != none)
		mat.SetScalarParameterValue('AS_DM_RotationAmount', ASCurrentAngle / 360.f);*/
	//r = vect(0,0,0);
	r.Yaw = StartingYaw - (ASCurrentAngle * DegToUnrRot);
	TargetActor.SetRotation(r);
}

/** Verify whether AS can be performed according to distance and aiming target.
 *  If AS can be performed, AS location is saved, AS decal and beam
 *  is spawned. This is all done on client side only. */
simulated function bool CanSetAirstrike()
{
	local rotator aimdir;
	local vector hitloc, norm, loc;
	local Actor hit;
	local float sangle;
	local Rx_Weapon_DeployedBeacon beacon;

	// get aiming direction
	aimdir = Instigator.GetBaseAimRotation();

	loc = InstantFireStartTrace();
	hit = Trace(hitloc, norm, loc + vector(aimdir) * MaxDistance, loc, true);
	if (hit == none) return false; // hit empty air - too far

	if (norm.Z <= 0.f)
	{
		// hit something on top of us, can't spawn airstrike here
		return false;
	}
	
	if(Rx_TeamInfo(Rx_Pawn(Instigator).PlayerReplicationInfo.Team).LastAirstrikeTime > 0 
				&& (WorldInfo.Timeseconds - Rx_TeamInfo(Rx_Pawn(Instigator).PlayerReplicationInfo.Team).LastAirstrikeTime < default.AirstrikeCooldown)) 
	{
		Rx_Controller(Instigator.Controller).ClientMessage("Next Airstrike available in "$int(default.AirstrikeCooldown - (WorldInfo.Timeseconds - Rx_TeamInfo(Rx_Pawn(Instigator).PlayerReplicationInfo.Team).LastAirstrikeTime))$" seconds");
		return false; 
	}
	
	foreach DynamicActors(class'Rx_Weapon_DeployedBeacon', beacon) {
		if(VSize(beacon.location - hitloc) < 4000) {
			Rx_Controller(Instigator.Controller).ClientMessage("Area not safe: This location is too close to a beacon!");
			return false;   
		}
	} 

	// save location
	AirstrikeLocation = hitloc;

	// get rotation according to current aim
	StartingYaw = aimdir.Yaw;
	sangle = (rotator(-norm).Yaw - StartingYaw) * UnrRotToDeg;

	// normalize angle
	while (sangle > 360.f)
		sangle -= 360.f;
	while (sangle < 0.f)
		sangle += 360.f;

	// spawn decal
	/* Decal System
	ASDecal = WorldInfo.MyDecalManager.SpawnDecal(
		DecalM,
		AirstrikeLocation,
		rotator(-norm), DecalWidth, DecalHeight, DecalThickness, false, sangle, , , , , , , 100000000.f);

	// get material instance so we can adjust decals rotation later when mouse is moved
	mat = new(self) class'MaterialInstanceConstant';
	mat.SetParent(ASDecal.GetDecalMaterial());
	ASDecal.SetDecalMaterial(mat);*/
	TargetActor.SetLocation(hitloc);

	AS2DRotPlane.Y = 1.f;
	AS2DRotPlane.X = 0.f;
	AdjustRotation(0.f, 0.f);

	return true;
}

/** This is state in which AS weapon in when being just hold (zoomed or not). */
simulated state Active
{
	simulated event BeginState(name PreviousStateName)
	{
		if (TargetActor == None)
		{
			TargetActor = Spawn(TargetActorClass, self, , self.Location);
		}
	}

	/** When Fire is pressed, this is called (client side only). */
	simulated function StartFire(byte FireModeNum)
	{
		if (Instigator == None || !Instigator.bNoWeaponFiring)
		{
			if (FireModeNum != 0)
			{
				// if not Fire, call global
				global.StartFire(FireModeNum);
				return;
			}

			// make sure this only gets executed on players ever
			if (WorldInfo.NetMode == NM_DedicatedServer ||
				(WorldInfo.NetMode == NM_ListenServer && !bNetOwner))
				return;

			// fire was pressed, show decal
			// but only if we are zoomed
			if (GetZoomedState() != ZST_Zoomed)
				return;

			if (!CanSetAirstrike())
				return; // AS cannot be spawned here (too far, not correct slope etc.)

			ServerDeploymentStarted(AirstrikeLocation); // notify server
				
			// remember location, if we move, cancel procedure
			InstigatorLocation = Instigator.Location;
			GotoState('DecalState');
		}
	}

	// todo: fix this code! duplicate in CanSetAirstrike()!
	simulated function Tick(float DeltaTime)
	{
		local rotator aimdir, targetRotator;
		local vector hitloc, norm, loc;
		local Actor hit;

		super.Tick(DeltaTime);

		// make sure this only gets executed on players ever
		if (WorldInfo.NetMode == NM_DedicatedServer ||
			(WorldInfo.NetMode == NM_ListenServer && !bNetOwner))
			return;

		/* Decal System
		if (TmpDecal != none)
			TmpDecal.ResetToDefaults();*/

		if (GetZoomedState() == ZST_Zoomed)
		{
			// get aiming direction
			aimdir = Instigator.GetBaseAimRotation();

			loc = InstantFireStartTrace();
			hit = Trace(hitloc, norm, loc + vector(aimdir) * MaxDistance, loc, true);

			
			
			if (hit == none         // hit empty air - too far
				|| norm.Z <= 0.f)   // hit something on top of us, can't spawn airstrike here
			{
				DeactivateTargetPS();
				return;
			}

			targetRotator.Yaw = aimdir.Yaw;
			TargetActor.SetLocation(hitloc);
			TargetActor.SetRotation(targetRotator);
			ActivateTargetPS();
			/* Decal System
			TmpDecal = WorldInfo.MyDecalManager.SpawnDecal(
				DecalM,
				hitloc,
				rotator(-norm), DecalWidth, DecalHeight, DecalThickness, false, (rotator(-norm).Yaw - aimdir.Yaw) * UnrRotToDeg);*/
		}
		else
			DeactivateTargetPS();
	}

	simulated event EndState(name NextStateName)
	{
		super.EndState(NextStateName);

		// make sure this only gets executed on players ever
		if (WorldInfo.NetMode == NM_DedicatedServer ||
			(WorldInfo.NetMode == NM_ListenServer && !bNetOwner))
			return;

		/* Decal System
		if (TmpDecal != none)
			TmpDecal.ResetToDefaults();*/
		if (NextStateName != 'DecalState')
			DeactivateTargetPS();
	}
}

/** As long as player is holding Fire button, the object remains in this state. */
simulated state DecalState
{
	simulated event BeginState(name PreviousStateName)
	{
		if (Rx_Controller(Instigator.Controller) != none)
		{
			//EndZoom(Rx_Controller(Instigator.Controller));

			// lock controls of player
			Rx_Controller(Instigator.Controller).AirstrikeLock();
		}
	}

	simulated function StopFire(byte FireModeNum)
	{
		if (FireModeNum != 0)
		{
			global.StopFire(FireModeNum);
			return;
		}
		
		// fire was released, initiate deployment
		GotoState('Deployment');
	}

	simulated event EndState(name NextStateName)
	{
		if (NextStateName != 'Deployment')
		{
			// unlock players controls if next state is not deployment
			if (Rx_Controller(Instigator.Controller) != none)
				Rx_Controller(Instigator.Controller).AirstrikeUnlock();
		}

		// kill decal
		/* Decal System
		ASDecal.ResetToDefaults();*/
		DeactivateTargetPS();
	}

	simulated function Moved()
	{
		// we have moved, cancel procedure
		GotoState('Active');
		ServerCancelDeployment();
	}
}


/** This state gets activated when weapon is zoomed and fire button is pressed. */
simulated state Deployment
{
	simulated event BeginState(name PreviousStateName)
	{
		SetTimer(DeploymentTime, false, 'DeployFin');

		// show beam
		SpawnBeam();

		// show visual stuff and set timer to update visual stuff
		bShowLoadPanel = true;
		CurrentProgress = 0;
		SetTimer(0.025f, true, 'ChargeProgress');
	   	if(Rx_Pawn_SBH(Instigator) != None)
   	  		Rx_Pawn_SBH(Instigator).ChangeState('WaitForSt');
		
	}

	simulated event DeployFin()
	{
		local rotator rot;

		// calculate Unr rotator according to angle
		rot.Yaw = StartingYaw - (ASCurrentAngle * DegToUnrRot);

		// fall back to previous state
		GotoState('Active');

		// if this is MP game, we need to make sure to execute following function
		// on server side only
		ServerDeploy(rot);
		Rx_Pawn(GetALocalPlayerController().Pawn).StopWalking();
	}

	simulated event EndState(name PreviousStateName)
	{
		super.EndState(PreviousStateName);

		// clear timers
		ClearTimer('ChargeProgress');
		ClearTimer('DeployFin');

		// unlock players controls
		if (Rx_Controller(Instigator.Controller) != none)
			Rx_Controller(Instigator.Controller).AirstrikeUnlock();

		// hide visual stuff
		bShowLoadPanel = false;
		if(bNightVisionEnabled)
			ToggleNightVision(true);
	}

	// for updating visual panel
	simulated function ChargeProgress()
	{
		CurrentProgress++;
	}

	simulated function Moved()
	{
		// we have moved, cancel procedure
		GotoState('Active');
		ServerCancelDeployment();
		if (Beam != none)
			Beam.ResetToDefaults();
	}
}

/** Called when AS deployment is starting. At that point, we already know location
 *  of airstrike. Rotation will be reported once deployment is complete. */
reliable server function ServerDeploymentStarted(vector loc)
{
	AirstrikeLocation = loc;

	// update Pawn's AirstrikeLocation so other players
	// can draw beam correctly
	Rx_Pawn(Instigator).AirstrikeLocation = AirstrikeLocation;
}

/** Called on server side to spawn AS actor which takes care of spawning real AS vehicle
 *  after certain period of time. */
reliable server function ServerDeploy(rotator rot)
{
	local Rx_Airstrike as;


	if(Rx_TeamInfo(Rx_Pawn(Instigator).PlayerReplicationInfo.Team).LastAirstrikeTime > 0 
				&& (WorldInfo.Timeseconds - Rx_TeamInfo(Rx_Pawn(Instigator).PlayerReplicationInfo.Team).LastAirstrikeTime < default.AirstrikeCooldown)) 
	{
		Rx_Controller(Instigator.Controller).ClientMessage("Next Airstrike available in "$int(default.AirstrikeCooldown - (WorldInfo.Timeseconds - Rx_TeamInfo(Rx_Pawn(Instigator).PlayerReplicationInfo.Team).LastAirstrikeTime))$" seconds");
		return; 
	}	

	`log("Deploying AS at=" $ AirstrikeLocation $ " rot=" $ rot);
	as = Spawn(class'Rx_Airstrike', Instigator, , AirstrikeLocation, rot, , false);
	as.Init(AirstrikeType);

	// remove this weapon from inventory
	Rx_InventoryManager(Instigator.InvManager).RemoveWeaponOfClass(self.Class);	
	Rx_TeamInfo(Rx_Pawn(Instigator).PlayerReplicationInfo.Team).LastAirstrikeTime = WorldInfo.TimeSeconds;
}

/** Called in case deployment has been cancelled (player has moved). */
reliable server function ServerCancelDeployment()
{
	// just reset beam for other players to NOT render it
	Rx_Pawn(Instigator).AirstrikeLocation = vect(0.f, 0.f, 0.f);
	Rx_TeamInfo(Rx_Pawn(Instigator).PlayerReplicationInfo.Team).LastAirstrikeTime = 0;
}

/** onscreen rendering */
simulated function ActiveRenderOverlays( HUD H )
{
   local Canvas C;
   local float PanX, PanY, PosX, PosY;

   super.ActiveRenderOverlays(H);
   C = H.Canvas;

   if (!bShowLoadPanel || C == none)
      return;

   // get the draw values
   PanX = C.SizeX * PanelWidth;
   PanY = C.SizeY * PanelHeight;

   C.SetDrawColor(255,64,64,255);
   PosX = C.SizeX * 0.5f - PanX * 0.5f;
   PosY = C.SizeY - PanY - 200;
   C.SetPos(PosX, PosY);
   C.DrawBox(PanX, PanY);
   // draw the text
   C.SetPos(PosX+3, PosY+3);

   C.DrawText("Airstrike in progress ...");

   // draw the loadpanel anim
   C.DrawColor.A = 50;
   C.SetPos(PosX + 1, PosY + 1);
   C.DrawRect(PanX * (CurrentProgress / DeploymentTime * 0.025f), PanY - 2);
}

simulated function float GetWeaponRating()
{
	return -1;
}

simulated event Destroyed()
{
	if (TargetActor != none)
		TargetActor.Destroy();
	super.Destroyed();
}

DefaultProperties
{
	DecalWidth=1000.f
	DecalHeight=1000.f
	DecalThickness=600.f
	
	AirstrikeCooldown=30

	MaxDistance=10000.f
	
	DeploymentTime=3.5f

   	PanelWidth  = 0.25f
   	PanelHeight = 0.033f
   	PanelColor  = (B=128, G=255, R=0, A=255)

	FadeTime=0.3
	
	CrosshairMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_None'
	CrosshairDotMIC = MaterialInstanceConstant'RenX_AssetBase.UI.MI_Reticle_None'
	HudMaterial=Material'RX_WP_Binoculars.Materials.M_BinocularScope'

	CrossHairCoordinates=(U=256,V=64,UL=64,VL=64)
	IconCoordinates=(U=726,V=532,UL=165,VL=51)

	bDisplaycrosshair = true;

	bZoomedFireMode(0)=0
	bZoomedFireMode(1)=1

	FiringStatesArray(0)=Deployment
	FiringStatesArray(1)=Active

	FireInterval(0)=+1.0
	FireInterval(1)=+0.0

	MaxDesireability=0.0
	AIRating=+0.6
	CurrentRating=0.0
	RespawnTime=1.0
	InventoryGroup=6
	InventoryMovieGroup=17
	GroupWeight=1
	
	AmmoCount=1
	MaxAmmoCount=1
	ClipSize=1
	InitalNumClips=1

	EquipTime=0.5
//	PutDownTime=0.7

	WeaponFireTypes(0)=EWFT_Custom
	//WeaponFireTypes(1)=EWFT_Custom
	ShotCost(0)=1
	ShotCost(1)=1
	
	ThirdPersonWeaponPutDownAnim="H_M_Beacon_PutDown"
	ThirdPersonWeaponEquipAnim="H_M_Beacon_Equip"
	
	ReloadAnimName(0) = "weaponreload"
	ReloadAnimName(1) = "weaponreload"
	ReloadAnim3PName(0) = "H_M_Beacon_Equip"
	ReloadAnim3PName(1) = "H_M_Beacon_Equip"
	ReloadArmAnimName(0) = "weaponreload"
	ReloadArmAnimName(1) = "weaponreload"

	
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_Airstrike'

	PlayerViewOffset=(X=20.0,Y=0.0,Z=-4.0)

   	ArmsAnimSet=AnimSet'RX_WP_Binoculars.Anims.AS_Binoculars_Arms'

	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object
	
	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_Binoculars.Mesh.SK_Binoculars_1P'
		AnimSets(0)=AnimSet'RX_WP_Binoculars.Anims.AS_Binoculars_1P'
		Animations=MeshSequenceA
		Scale=2.0
		FOV=50.0
	End Object
	
	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_Binoculars.Mesh.SK_Binoculars_Back'
		Scale=1.0
	End Object
}
