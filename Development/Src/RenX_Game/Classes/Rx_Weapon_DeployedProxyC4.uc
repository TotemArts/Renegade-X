/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class Rx_Weapon_DeployedProxyC4 extends Rx_Weapon_DeployedRemoteC4
	implements(RxIfc_EMPable)
	implements(RxIfc_TargetedDescription);

`include(RenX_Game\RenXStats.uci);

var float TriggerRadius;
var float VehicleTriggerRadius;
var Pawn Activator;
var float DirectLineOfSightDamage;
var float DetonateDelay;
var PlayerReplicationInfo OwnerPRI;

var StaticMeshComponent TriggerMesh;
var float MaxViewDistance;

var int EMPDisarmTime;	// time it takes for the EMP to disarm a full health mine. Note integer and not floating point.
var int EMPTicks, TestHeight;
var Controller EMPInstigator;
var Actor EMPActor, DebugActor, hitActor;
var bool bDebugWeapon;

var ParticleSystem EMPPSTemplate;
var UTParticleSystemComponent EMPParticleSystem;

var bool IsTeamProxyC4;

replication
{
	if (bNetInitial)
		OwnerPRI, IsTeamProxyC4;
}

simulated function PostBeginPlay()
{
	super(Rx_Weapon_DeployedActor).PostBeginPlay();

	if (InstigatorController != none)
	{
		OwnerPRI = InstigatorController.PlayerReplicationInfo;
		Planter = InstigatorController;
	}

	ClearTimer('Explosion'); 
	ClearTimer('CountDown'); 

	if (WorldInfo.NetMode == NM_DedicatedServer) return;

	SetTimer(1.0, true, nameof(CheckVis));
}

function KillCheck()
{
	if (Role == ROLE_Authority && !IsTeamProxyC4)
	{
		// Destroy when player dies
		if (Instigator == None || Instigator.Health <= 0)
			Destroy();
	}
}

simulated function Destroyed() 
{
	if (!bDestroyed) 
	{
		if (Role == ROLE_Authority && bUsesMineLimit && IsTeamProxyC4)
		{
			Rx_TeamInfo(Rx_Game(WorldInfo.Game).Teams[GetTeamNum()]).mineCount--;
			if (Rx_Building(Base) != None) Rx_Building(Base).RemoveMine(self);
		}

		super(Rx_Weapon_DeployedC4).Destroyed();

		bDestroyed = true;
	}
}

simulated function PerformDeploy()
{
	super.PerformDeploy();

    SetTimer(0.4, true, 'CheckProxy');
	`RecordGamePositionStat(WEAPON_MINE_DEPLOYED , location, 1);
}

//Dont stick to walls. 
event HitWall(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
{
   	Super(Actor).HitWall(HitNormal, Wall, WallComp);
}

function Landed(vector HitNormal, Actor FloorActor)
{
	local Rx_Buildings_DoorSensor V;
	local Rx_Buildings_DoorSensor ClosestDoorSensor;
		
	super(Rx_Weapon_DeployedC4).Landed(HitNormal, FloorActor);
	SetTimer(1.0, true, 'KillCheck');
	
	if (Rx_Building_WeaponsFactory(FloorActor) != None || Rx_Building_Barracks(FloorActor) != None || Rx_Building_AirTower(FloorActor) != None
			|| Rx_Building_AdvancedGuardTower(FloorActor) != None || Rx_Building_Obelisk(FloorActor) != None)
		return;	
	
	if (Rx_Building_HandOfNod(IsInBuilding()) != None)
	{
		if (Rx_Building_HandOfNod(FloorActor) == None)
			Move(HitNormal * 5); // prevents the mines from sinking into the bottom of the two gates near the HON MCT
		return;	
	}	
	
	if (IsInBuilding() == None)
		return;
	
	foreach AllActors(class'Rx_Buildings_DoorSensor', V)
	{
		if (closestDoorSensor == None)
			ClosestDoorSensor = V;
		else if (VSizeSq(location-V.Location) < VSizeSq(location-ClosestDoorSensor.Location))
			ClosestDoorSensor = V;		
	}	
	
	if (VSizeSq(location-ClosestDoorSensor.Location) <= 13225)
	{
		Move(HitNormal * 4.5); // if close to a door move up a bit to prevent sinking into the no collision geom that Ref and PP have at their doors		
		return;					
	}			
	
}

function Rx_Building IsInBuilding() 
{
	return Rx_Building(Base);
}

function CheckProxy()
{
	local Rx_Pawn P;
	local Rx_Vehicle V;
	local vector endL, normthing; 
	local vector ScanLoc;
	
	//Store our location, but scan from about 13 units above our location. 
	ScanLoc = location; 
	   
	ScanLoc.z += TestHeight;
	   
	ForEach VisibleCollidingActors(class'Rx_Pawn', P, TriggerRadius,ScanLoc, true)
	{
		if (P.GetTeamNum() == 0 || P.GetTeamNum() == 1)
		{
			if ((GetTeamNum() != P.GetTeamNum()) && (P.Health > 0) && bDeployed)
     		{
     			Activator = P;
				Detonate();
				ClearTimer('CheckProxy');
				break;
     		}
		}
   }

   if(bDebugWeapon) 
   {
	   hitActor=Trace(endL, normthing, DebugActor.location,ScanLoc, true) ;
		`log(hitActor); 
   }
   
	ForEach OverlappingActors(class'Rx_Vehicle', V, VehicleTriggerRadius,, true)
	{
      if ((GetTeamNum() != V.GetTeamNum()) && (V.Health > 0) && bDeployed && !(V.GetTeamNum() == 255)) 
      {
      	Detonate();
		ClearTimer('CheckProxy');
		break;
      }
   }
}

function Detonate()
{
	if (DetonateDelay > 0)
      	SetTimer(DetonateDelay,false,'Explosion');
	else
		Explosion();
}

function Explosion()
{
	local Vector ZOffsetLocation;
	
	ZOffsetLocation=location; 
	
	ZOffsetLocation.z+=TestHeight;
	
	if (WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer) // trigger client replication
		bExplode = true;
	if (WorldInfo.NetMode != NM_DedicatedServer)
		PlayExplosionEffect();

	if (Role == ROLE_Authority)
	{
	//	if(Activator != None && FastTrace(Activator.location,location))
		if(Activator != None && FastTrace(Activator.location,ZOffsetLocation))
		{
			Activator.TakeDamage(DirectLineOfSightDamage,InstigatorController,Location,vect(0,0,0),ChargeDamageType);
		}
			
		HurtRadius(Damage, DmgRadius, ChargeDamageType, DamageMomentum, ZOffsetLocation); /** Applies Radius Damage to all but ImpactedActor */
		SetTimer(0.1f, false, 'DestroyMe');
	}

	`RecordGamePositionStat(WEAPON_MINE_EXPLODED , location, 1);
}

simulated function bool CanDisarmMe(Actor A)
{
	if (Rx_Projectile_EMPGrenade(A) != None)
		return true;
	return super.CanDisarmMe(A);
}

simulated function bool IsEffectedByEMP()
{
	return true;
}

function bool EMPHit(Controller InstigatedByController, Actor EMPCausingActor, optional int TimeModifier = 0)
{
	//local Rx_Projectile VetActor;
	
	if (Rx_Projectile_EMPGrenade(EMPCausingActor) != EMPActor && InstigatedByController.GetTeamNum() != GetTeamNum())
	{
			//VetActor=Rx_Projectile(EMPCausingActor);
		TakeDamage(Rx_Projectile_EMPGrenade(EMPCausingActor).Init_MineDamage, InstigatedByController, Location, Vect(0,0,0), class'Rx_DmgType_EMP',,EMPCausingActor); //Check 1st if we've already taken this hit. Keeps the grenade from hitting mine it collides with twice. 
		if(EMPTicks > 0) EMPActor=EMPCausingActor; /*Prevent EMP Mine damage from doubling up when the mine is already suffering from EMP effect. */	
	}
	
	if (InstigatedByController.GetTeamNum() == GetTeamNum() || EMPTicks > 0)
		return false;

	EMPTicks = EMPDisarmTime+TimeModifier; //EMP mines are finicky... and they have a tendency to screw up decimal places apparently, so it was just easier to tell it to tick two extra times instead of possibly stopping at 2%
	EMPInstigator = InstigatedByController;
	EMPActor = EMPCausingActor;
	SetTimer(1.0, true, 'EMPDisarmTick');
	EMPDisarmTick();
	return true;
}

function EMPDisarmTick()
{
	//`log("DisarmTick");
	 TakeDamage(float(default.HP/EMPDisarmTime), EMPInstigator, Location, Vect(0,0,0), class'Rx_DmgType_EMP',,EMPActor);
	
		//TakeDamage(float(200/EMPDisarmTime), EMPInstigator, Location, Vect(0,0,0), class'Rx_DmgType_EMP');

	if (--EMPTicks <= 0)
	{
		ClearTimer('EMPDisarmTick');
	}
	
}

/**Take damage needs to account for the fact the EMP grenades EXPLODE.. and are destroyed. Sometimes mines won't update and will still have a reference to the grenade all the way through disarming.. other times EMPActor gets set to 'none' and 'none' can not disarm the mine.*/
function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if (!CanDisarmMe(DamageCauser) && DamageType != class'Rx_DmgType_EMP') //If it's EMP damage just roll with the punches.
	{
		return;
	}
	
	//Don't use the Rx_Weapon_DeployedActor TakeDamage(), as then HP gets subtracted twice. 
	super(Actor).TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);

	if (DamageAmount <= 0 || HP <= 0 || bDisarmed )
      return;

	HP -= DamageAmount;
//	`log("Damage=" @ DamageAmount);
	if (HP <= 0)
	{
		BroadcastDisarmed(EventInstigator);
		if (WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer) // trigger client replication
			bDisarmed = true;
		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			if ((EventInstigator.PlayerReplicationInfo != none && EventInstigator.PlayerReplicationInfo.GetTeamNum() != TeamNum) || EventInstigator.PlayerReplicationInfo == None)
				PlayDisarmedEffect();
			else
				PlayDisarmedEffectNoSound();
		}
			ClearTimer('Explosion');

		
		if (EventInstigator.PlayerReplicationInfo != none && EventInstigator.PlayerReplicationInfo.GetTeamNum() != TeamNum)
		{
			Rx_Controller(EventInstigator).DisseminateVPString( "[Mine Disarmed]&" $ class'Rx_VeterancyModifiers'.default.Ev_C4Disarmed $ "&");
			Rx_PRI(EventInstigator.PlayerReplicationInfo).AddMineDisarm();
			Rx_PRI(EventInstigator.PlayerReplicationInfo).AddScoreToPlayerAndTeam(DisarmScoreReward,true);
		}
		
		SetTimer(0.1, false, 'DestroyMe'); // delay it a bit so disappearing blends a littlebit better with the disarmed effects
	}
}

simulated function PlayDisarmedEffectNoSound()
{
   local vector SpawnLocation;
   local rotator SpawnRotation;

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		SpawnLocation = Location;
		SpawnRotation = Rotation;
		SpawnDisarmedEmitter(SpawnLocation, SpawnRotation);
	}
}

function EnteredEMPField(Rx_EMPField EMPField) // Figured this would be where I'd start for burst damage.. but guess not. 
{
	if (EMPParticleSystem == None)
	{
		EMPParticleSystem = new(Outer) class'UTParticleSystemComponent';
		EMPParticleSystem.bAutoActivate = false;
		EMPParticleSystem.SetTemplate(EMPPSTemplate);
		EMPParticleSystem.SetScale(0.1);
		SkeletalMeshComponent(Mesh).AttachComponentToSocket(EMPParticleSystem, 'EMPEffect');
	}

	if (EMPParticleSystem != None)
	{
		EMPParticleSystem.ActivateSystem();
	}
}

function LeftEMPField(Rx_EMPField EMPField)
{
	if (EMPParticleSystem != None)
	{
		EMPParticleSystem.DeactivateSystem();
	}
}

simulated function CheckVis()
{
	local PlayerController C;

	C = GetALocalPlayerController();

	if (C == None || Rx_Pawn(C.Pawn) == None || C.Pawn.Weapon == None || C.GetTeamNum() != GetTeamNum()) return;

	if (Rx_Weapon_ProxyC4(C.Pawn.Weapon) == None || !IsInRange(C))
		TriggerMesh.SetHidden(true);
	else
		TriggerMesh.SetHidden(false);
}

simulated function bool IsInRange(PlayerController C)
{
	if (C == None) return false;

	return VSizeSq(Location - C.Pawn.Location) < Square(MaxViewDistance);
}


//RxIfc_Targetable
simulated function string GetTargetedDescription(PlayerController PlayerPerspective)
{
	if (OwnerPRI != None && PlayerPerspective.GetTeamNum() == GetTeamNum())
	{
		if (PlayerPerspective.PlayerReplicationInfo == OwnerPRI)
			return "Your Mine";
		else 
			return "Placed by "$OwnerPRI.PlayerName;
	}

	return "";
}

DefaultProperties
{
    DeployableName="Proximity Mine"
    HP=200
    Damage=80//50
    DirectLineOfSightDamage=60//30
	DmgRadius=360
	DamageMomentum=8000.0
	TriggerRadius=130//130	 
	VehicleTriggerRadius=5
	DetonateDelay=0.0f
	bUsesMineLimit=true
	bIsRemoteC4=false
	WeaponClass=class'Rx_Weapon_ProxyC4'

	EMPPSTemplate=ParticleSystem'rx_wp_proxyc4.Particles.P_EMPEffect'
	MaxViewDistance=300

	Begin Object Class=StaticMeshComponent Name=TMesh
		StaticMesh=StaticMesh'RenX_AssetBase.Mesh.SM_Sphere_Rad100'
		HiddenGame=true
		Scale=1.45
		Materials[0]=MaterialInstanceConstant'RenX_AssetBase.Materials.MI_Proximity_Radius'
		CollideActors=False
		BlockActors=False
		BlockZeroExtent=False
		BlockNonZeroExtent=False
		BlockRigidBody=False
	End Object
	TriggerMesh=TMesh
	Components.Add(TMesh)

	TestHeight=13  //This keeps mines able to see over most things, even when they're placed in the vent of the powerplant. 
	
	ExplosionLightClass=Class'RenX_Game.Rx_Light_Tank_Explosion'
	ExplosionTemplate=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Small'
	ExplosionSound=SoundCue'RX_SoundEffects.Explosions.SC_Explosion_ProxyC4'
	ImpactSound=SoundCue'rx_wp_proxyc4.Sounds.SC_ProxyC4_Impact'
	ChargeDamageType=class'Rx_DmgType_ProxyC4'
	
	ExplosionShake=CameraAnim'Envy_Effects.Camera_Shakes.C_VH_Death_Shake'
	InnerExplosionShakeRadius=50.0
	OuterExplosionShakeRadius=400.0	

	DisarmScoreReward=20
	EMPDisarmTime=13.33 //Counteracts 25% burst damage from initial mine explosion. Keeps disarm time roughly the same

	Begin Object Name=DeployableMesh
		CastShadow=false
		SkeletalMesh=SkeletalMesh'rx_wp_proxyc4.Mesh.SK_WP_Proxy_Deployed'
		PhysicsAsset=PhysicsAsset'rx_wp_proxyc4.Mesh.SK_WP_Proxy_3P_Physics'
		Scale=1.0
	End Object	
}