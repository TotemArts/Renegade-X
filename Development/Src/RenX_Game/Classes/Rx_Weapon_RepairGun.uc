class Rx_Weapon_RepairGun extends Rx_BeamWeapon;

var int HealAmount;
var int MinHealAmount;
var() AudioComponent BeamSound;
var SoundCue BeamSoundCue;

var SoundCue StartAltFireSound;
var SoundCue EndAltFireSound;

var UTLinkBeamLight BeamLight;
var UTEmitter BeamEndpointEffect; 

/** saved heal ammount (in case of high frame rate */
var float SavedHealAmmount;
var bool bHealing;
//var bool bKeepFiring;
var float MineDamageModifier; //Modifier for disarming mines, if any
var float EMPHealMultiplier;

/** cached cast of attachment class for calling coloring functions */
var class<Rx_Attachment_RepairGun> RepGunAttachmentClass;

var float TestNum; 

var Actor MyHitActor; 

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	WeaponFireSnd[0].VolumeMultiplier = 0.3;    
	RepGunAttachmentClass = class<Rx_Attachment_RepairGun>(AttachmentClass);
}

simulated state Active
{
	simulated function BeginState(name PreviousStateName)
	{	
	super.BeginState(PreviousStateName);	
	
	KillBeamEmitter();
	
	}
}

simulated function bool IsEnemy(actor actor)
{
	if (Instigator.GetTeamNum() == 0 && actor.GetTeamNum() == 1)
		return true;
	else if (Instigator.GetTeamNum() == 1 && actor.GetTeamNum() == 0)
		return true;
	else 
		return false;
}

simulated function RepairVehicle(Rx_Vehicle vehicle, float DeltaTime)
{
	vehicle.ResetTime = 0.0;
	if (!IsEnemy(vehicle) &&
		vehicle.Health > 0 &&
		vehicle.Health < vehicle.HealthMax)
	{
		if(!vehicle.bEMPd) Repair(vehicle,DeltaTime);
		else
		Repair(vehicle,DeltaTime,,EMPHealMultiplier);	
	}
	else
	{
		bHealing = false;
	}
}

simulated function RepairPawn(Rx_Pawn pawn, float DeltaTime)
{
	if (!IsEnemy(pawn) && pawn.Health > 0 && (pawn.Health < pawn.HealthMax || pawn.Armor < pawn.ArmorMax) )
	{
		
		Repair(pawn,DeltaTime);
	}
	else
	{
		bHealing = false;
	}
}

simulated function RepairBuilding(Rx_Building building, float DeltaTime)
{
	local int repairableHealth;
	local int maxRepairableHealth;
	
	
	if (Rx_Building_Techbuilding(building) == None && !building.isA('Rx_CapturableMCT'))
	{
		repairableHealth = building.GetArmor();
		maxRepairableHealth = building.GetMaxHealth() * Rx_GRI(WorldInfo.GRI).buildingArmorPercentage/100;
	}
	else
	{
		repairableHealth = building.GetHealth();
		maxRepairableHealth = building.GetMaxHealth();
	}
	
	if (!IsEnemy(building) &&
		!building.IsDestroyed() &&
		Rx_Building_Techbuilding(building) == none && // Do not repair tech building exteriors
		repairableHealth < maxRepairableHealth) 
	{
		Repair(building,DeltaTime);
	}
	else
	{
		if(building.isA('Rx_CapturableMCT')
				&& !(building.ScriptGetTeamNum() == Instigator.GetTeamNum() && building.GetHealth() >= building.GetMaxHealth()) )
			Repair(building,DeltaTime);
		else
			bHealing = false;
	}
}

simulated function RepairBuildingAttachment(Rx_BuildingAttachment buildingAttachment, float DeltaTime)
{
	local int repairableHealth;
	local int maxRepairableHealth;	
	
	if(Rx_Building_Techbuilding(buildingAttachment.OwnerBuilding.BuildingVisuals) == None && !buildingAttachment.OwnerBuilding.BuildingVisuals.isA('Rx_CapturableMCT'))
	{
		repairableHealth = buildingAttachment.OwnerBuilding.BuildingVisuals.GetArmor();
		maxRepairableHealth = buildingAttachment.OwnerBuilding.BuildingVisuals.GetMaxHealth() * Rx_GRI(WorldInfo.GRI).buildingArmorPercentage/100;
	}
	else
	{
		repairableHealth = buildingAttachment.OwnerBuilding.BuildingVisuals.GetHealth();
		maxRepairableHealth = buildingAttachment.OwnerBuilding.BuildingVisuals.GetMaxHealth();
	}	
	
	// Is a tech building MCT
	if (Rx_BuildingAttachment_MCT(buildingAttachment) != None && Rx_Building_TechBuilding_Internals(buildingAttachment.OwnerBuilding) != None &&
		!(Rx_BuildingAttachment_MCT(buildingAttachment).ScriptGetTeamNum() == Instigator.GetTeamNum() && buildingAttachment.OwnerBuilding.GetHealth() >= buildingAttachment.OwnerBuilding.GetMaxHealth() ) )
	{
		Repair(buildingAttachment,DeltaTime);
	}
	else if (!IsEnemy(buildingAttachment) && !buildingAttachment.OwnerBuilding.IsDestroyed() 
				&& repairableHealth < maxRepairableHealth) 
	{
		Repair(buildingAttachment,DeltaTime);
	}
	else
	{
		bHealing = false;
	}
}

simulated function RepairDeployedActor(Rx_Weapon_DeployedActor deployedActor, float DeltaTime)
{
	if (Rx_Weapon_DeployedProxyC4(deployedActor) != None
		&& CurrentFireMode == 1
		&& (Rx_Weapon_DeployedProxyC4(deployedActor).OwnerPRI == None || Rx_Weapon_DeployedProxyC4(deployedActor).OwnerPRI == Instigator.PlayerReplicationInfo 
			|| (Rx_PRI(Instigator.PlayerReplicationInfo) != None && Rx_PRI(Instigator.PlayerReplicationInfo).bIsCommander)	
			|| Rx_PRI(Rx_Weapon_DeployedProxyC4(deployedActor).OwnerPRI).GetMineStatus() == false )
		&& deployedActor.HP > 0
		&& deployedActor.HP <= deployedActor.MaxHP)
		Repair(deployedActor,DeltaTime,true);
	
	else if (!deployedActor.bCanNotBeDisarmedAnymore && IsEnemy(deployedActor))
	{
		Repair(deployedActor,DeltaTime,true);
	}
	else if (deployedActor.HP > 0 &&
			deployedActor.HP <= deployedActor.MaxHP)
	{
		Repair(deployedActor,DeltaTime,false);
	}
	else
	{
		bHealing = false;
	}
}

simulated function Repair(Actor actor, float DeltaTime, optional bool Disarm = false, optional float RateModifier = 1.0)
{
	local int ActualHealAmmount;
	
	if(Rx_Weapon_DeployedProxyC4(actor) != none  ) //For Proximity mines only 
		{
			if(actor.GetTeamNum() == Owner.GetTeamNum() ) 
				RateModifier=MineDamageModifier*5; //disarming mines should be quick. 
			else
				RateModifier=MineDamageModifier;
		}
	
	bHealing = true;
	
	SavedHealAmmount += HealAmount * GetDamageModifier() * RateModifier * DeltaTime;
	
	ActualHealAmmount = int(SavedHealAmmount);
	
	if(ActualHealAmmount < MinHealAmount) 
	{
		return;
	}

	SavedHealAmmount -= ActualHealAmmount;

	ConsumeRepairAmmo(ActualHealAmmount);
	
	if (Disarm)
	{
		actor.TakeDamage(ActualHealAmmount, Instigator.Controller,Instigator.FlashLocation,Vect(0,0,0), InstantHitDamageTypes[0],,self);
	}
	else
	{
		actor.HealDamage(ActualHealAmmount, Instigator.Controller, InstantHitDamageTypes[0]);
	}
}

simulated function ConsumeRepairAmmo(int ActualHealAmount)
{
	if (ShotCost[0] <= 0)
		return;
	CurrentAmmoInClip = Max(CurrentAmmoInClip-ActualHealAmount,0);
	AddAmmo(-ActualHealAmount);
}

simulated function UpdateAttachment()
{
	if (UTPawn(Instigator) != none && Rx_Attachment_RepairGun(UTPawn(Instigator).CurrentWeaponAttachment) != none)
	{
		 Rx_Attachment_RepairGun(UTPawn(Instigator).CurrentWeaponAttachment).bHealing = bHealing;
	}
	if (Rx_Pawn(Instigator) != none)
	{
		Rx_Pawn(Instigator).SetIsRepairing(bHealing);
	}
}

simulated function ProcessBeamHit(vector StartTrace, vector AimDir, out ImpactInfo Impact, float DeltaTime) 
{
	SetFlashLocation(Impact.HitLocation);

	MyHitActor=Impact.HitActor; 
	
	if (Rx_Vehicle(Impact.HitActor)!= none)
	{
		RepairVehicle(Rx_Vehicle(Impact.HitActor),DeltaTime);
	}
	else if (Rx_Pawn(Impact.HitActor) != none)
	{
		RepairPawn(Rx_Pawn(Impact.HitActor),DeltaTime);
	}
	else if (Rx_Building(Impact.HitActor) != none)
	{
		RepairBuilding(Rx_Building(Impact.HitActor),DeltaTime);
	}
	else if (Rx_BuildingAttachment(Impact.HitActor) != none)
	{
		RepairBuildingAttachment(Rx_BuildingAttachment(Impact.HitActor),DeltaTime);
	}
	else if (Rx_Weapon_DeployedActor(Impact.HitActor) != none)
	{
		RepairDeployedActor(Rx_Weapon_DeployedActor(Impact.HitActor),DeltaTime);
	}
	else if (Rx_DestroyableObstaclePlus(Impact.HitActor) != none)
	{
		Repair(Rx_DestroyableObstaclePlus(Impact.HitActor),DeltaTime);
	}
	else if (Rx_BasicPawn(Impact.HitActor) != none)
	{
		Repair(Rx_BasicPawn(Impact.HitActor),DeltaTime);
	}
	else// We haven't hit anything we can repair.
	{
		bHealing = false;
	}

	UpdateAttachment();
}

simulated function UpdateBeamEmitter(vector FlashLocation, vector HitNormal, actor HitActor)
{
	
	Super.UpdateBeamEmitter(FlashLocation, HitNormal, HitActor);
		
	if(!bHealing) {
		KillEndpointEffect();
	}
	
	if ( BeamLight != None )
	{
		if ( HitNormal == vect(0,0,0) )
		{
			BeamLight.Beamlight.Radius = 48;
			if ( FastTrace(FlashLocation, FlashLocation-vect(0,0,32)) )
				BeamLight.SetLocation(FlashLocation - vect(0,0,32));
			else
				BeamLight.SetLocation(FlashLocation);
		}
		else
		{
			BeamLight.Beamlight.Radius = 32;
			BeamLight.SetLocation(FlashLocation + 16*HitNormal);
		}
		BeamLight.BeamLight.SetLightProperties(, RepGunAttachmentClass.default.BeamColor);
	}
	
	if (bHealing && WorldInfo.NetMode != NM_DedicatedServer && Instigator != None && Instigator.IsFirstPerson())
	{
		if (BeamEndpointEffect != None && !BeamEndpointEffect.bDeleteMe)
		{
			BeamEndpointEffect.SetLocation(FlashLocation);
			BeamEndpointEffect.SetRotation(rotator(HitNormal));
			if(BeamEndpointEFfect.LifeSpan > 0.0)
			{
				BeamEndpointEffect.ParticleSystemComponent.ActivateSystem();
				BeamEndpointEFfect.LifeSpan = 0.0;
			}
			if (BeamEndpointEffect.ParticleSystemComponent.Template != RepGunAttachmentClass.default.BeamEndpointTemplateWhenHealing)
			{
				BeamEndpointEffect.SetTemplate(RepGunAttachmentClass.default.BeamEndpointTemplateWhenHealing, true);
			}
		}
		else
		{
			BeamEndpointEffect = Spawn(class'UTEmitter', self,, FlashLocation, rotator(HitNormal));
			BeamEndpointEffect.SetTemplate(RepGunAttachmentClass.default.BeamEndpointTemplateWhenHealing, true);
			BeamEndpointEFfect.LifeSpan = 0.0;
		}
		if(BeamEndpointEffect != none)
		{
			if(HitActor != none && UTPawn(HitActor) == none)
			{
				BeamEndpointEffect.SetFloatParameter('Touch',1);
			}
			else
			{
				BeamEndpointEffect.SetFloatParameter('Touch',0);
			}
		}
	}    
	
}

simulated state WeaponBeamFiring
{

	simulated function BeginState(Name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

		if ( (PlayerController(Instigator.Controller) != None) && Instigator.IsLocallyControlled() && ((BeamLight == None) || BeamLight.bDeleteMe) )
		{
			BeamLight = spawn(class'UTLinkBeamLight');
		}
		
		/**if(CurrentFireMode == 1)
		{
			bKeepFiring = true;
			SetTimer(20,false,'ResetKeepFiring');
		} 
		else
		{
			bKeepFiring = false;
			//ClearPendingFire(1);		
		}*/

		WeaponPlaySound(StartAltFireSound);
	}
	
	simulated function EndState(Name NextStateName)
	{
		WeaponPlaySound(EndAltFireSound);
		bHealing = false;
		UpdateAttachment();
		
		Super.EndState(NextStateName);

		if ( BeamLight != None )
			BeamLight.Destroy();

	}    
	
	simulated function RefireCheckTimer()
	{
		//local UTPlayerController PC;

		// If weapon should keep on firing, then do not leave state and fire again.
		if( ShouldRefire() )
		{
			/**
			// trigger a view shake for the local player here, because effects are called every tick
			// but we don't want to shake that often
			PC = UTPlayerController(Instigator.Controller);
			if (PC != None && LocalPlayer(PC.Player) != None && CurrentFireMode < FireCameraAnim.length && FireCameraAnim[CurrentFireMode] != None)
			{
				PC.PlayCameraAnim(FireCameraAnim[CurrentFireMode], (GetZoomedState() > ZST_ZoomingOut) ? PC.GetFOVAngle() / PC.DefaultFOV : 1.0);
			}
			*/
			return;
		}

		// Otherwise we're done firing, so go back to active state.
		ClearPendingFire(0);
		ClearPendingFire(1);
		KillBeamEmitter();
		GotoState('Active');

		// if out of ammo, then call weapon empty notification
		if( !HasAnyAmmo() )
		{
			WeaponEmpty();
		}
	}    

}

/**simulated function ResetKeepFiring()
{
	bKeepFiring = false;
	ClearPendingFire(1);
}*/

simulated function bool ShouldRefire()
{
	/**if(bKeepFiring)
		return true;*/
	return super(Weapon).ShouldRefire();
}	

simulated function BeginFire(Byte FireModeNum)
{
	//ClearPendingFire(1); 
	/**if(FireModeNum == 1 && bKeepFiring && PendingFire(1))
	{
		bKeepFiring = false;
		return;
	}*/
	//bKeepFiring = false;			
	super.BeginFire(FireModeNum);
}

simulated function StopFire(byte FireModeNum)
{
	//ClearPendingFire(1);	
	super.StopFire(FireModeNum);
}


simulated event Destroyed()
{
	super.Destroyed();
	if (BeamLight != None)
	{
		BeamLight.Destroy();
	}

	KillEndpointEffect();
}

simulated function SetBeamEmitterHidden(bool bHide)
{
	if (BeamEmitter[CurrentFireMode] != None && bHide)
	{
		KillEndpointEffect();
	}
	Super.SetBeamEmitterHidden(bHide);
}

simulated function KillBeamEmitter()
{
	//`log("Killed Emitter");
	Super.KillBeamEmitter();

	KillEndpointEffect();
}

simulated function KillEndpointEffect()
{
	if (BeamEndpointEffect != None)
	{
		BeamEndpointEffect.ParticleSystemComponent.DeactivateSystem();
		BeamEndpointEffect.LifeSpan = 2.0;
	}
}

function bool CanHeal(Actor Other)
{
    return true;
}

function bool CanAttack(Actor Other)
{
	if(VSizeSq(Instigator.GetWeaponStartTraceLocation() - Other.Location) > Square(WeaponRange - 100))
		return false;
		
	if(Rx_Weapon_DeployedActor(Other) != None)
		return CanTraceTo(Other);

	if(Rx_BuildingAttachment_MCT(Other) != None && Rx_Building_Techbuilding_Internals(Rx_BuildingAttachment_MCT(Other).OwnerBuilding) != None)
		return CanTraceTo(Other);

	if(Other.GetTeamNum() != 255 && Other.GetTeamNum() != Owner.GetTeamNum()) 
	{
		return false;
	}
	return CanTraceTo(Other);
}

// super version of CanAttack, but edited
function bool CanTraceTo(Actor Other)
{
	local float Dist, CheckDist, OtherHeight;
	local vector HitLocation, HitNormal, projStart, TargetLoc;
	local Actor HitActor;
	local class<Projectile> ProjClass;
	local int i;
	local UTBot B;

	if (Instigator == None || Instigator.Controller == None)
	{
		return false;
	}

	// check that target is within range
	Dist = VSize(Instigator.Location - Other.Location);
	if (Dist > MaxRange())
	{
		return false;
	}

	projStart = bInstantHit ? InstantFireStartTrace() : GetPhysicalFireStartLoc();

	// check that can see target
	B = UTBot(Instigator.Controller);
	if (Instigator.Controller.LineOfSightTo(Other, projStart))
	{
		if (B != None && B.Focus == Other)
		{
			B.bTargetAlternateLoc = false;
		}
	}
	else
	{
		if (!Other.bHasAlternateTargetLocation || !Instigator.Controller.LineOfSightTo(Other, projStart, true))
		{
			return false;
		}

		if (B != None && B.Focus == Other)
		{
			B.bTargetAlternateLoc = true;
		}
	}

	if ( !bInstantHit )
	{
		ProjClass = GetProjectileClass();
		if ( ProjClass == None )
		{
			for (i = 0; i < WeaponProjectiles.length; i++)
			{
				ProjClass = WeaponProjectiles[i];
				if (ProjClass != None)
				{
					break;
				}
			}
		}
		if (ProjClass == None)
		{
			`warn("No projectile class for "$self);
			CheckDist = 300;
		}
		else
		{
			CheckDist = FMax(CheckDist, 0.5 * ProjClass.default.Speed);
			CheckDist = FMax(CheckDist, 300);
			CheckDist = FMin(CheckDist, VSize(Other.Location - Location));
		}
	}

	// check that would hit target, and not a friendly
	TargetLoc = Other.GetTargetLocation(Instigator);
	if ( Pawn(Other) != None )
	{
		OtherHeight = Pawn(Other).GetCollisionHeight();
		TargetLoc.Z += 0.9 * OtherHeight;
	}

	// perform the trace

	HitActor = GetTraceOwner().Trace(HitLocation, HitNormal, TargetLoc, projStart, true,,, TRACEFLAG_Bullet);
	

	if ( HitActor == Other )	// we need to be sure that we hit the actual target
	{
		return true;
	}

	return false;
}

simulated function bool UsesClientSideProjectiles(byte FireMode)
{
	return false;
}
/**
simulated function DrawCrosshair( Hud HUD )
{
	local vector2d CrosshairSize;
	local float x,y;	
	local UTHUDBase H;
	local Pawn MyPawnOwner;
	local actor TargetActor;
	local int targetTeam;
	local LinearColor LC; //nBab

	//set initial color based on settings (nBab)
	LC.A = 1.f;
	switch (Rx_HUD(Rx_Controller(Instigator.Controller).myHUD).SystemSettingsHandler.GetCrosshairColor())
	{
		//white
		case 0:
			LC.R = 1.f;
			LC.G = 1.f;
			LC.B = 1.f;
			break;
		//orange
		case 1:
			LC.R = 2.f;
			LC.G = 0.5f;
			LC.B = 0.f;
			break;
		//violet
		case 2:
			LC.R = 2.f;
			LC.G = 0.f;
			LC.B = 2.f;
			break;
		//blue
		case 3:
			LC.R = 0.f;
			LC.G = 0.f;
			LC.B = 2.f;
			break;
		//cyan
		case 4:
			LC.R = 0.f;
			LC.G = 2.f;
			LC.B = 2.f;
			break;	
	}	
	
	H = UTHUDBase(HUD);
	if ( H == None )
		return;

 	CrosshairSize.Y = CrosshairHeight;
	CrosshairSize.X = CrosshairWidth;

	X = H.Canvas.ClipX * 0.5 - (CrosshairSize.X * 0.5);
	Y = H.Canvas.ClipY * 0.5 - (CrosshairSize.Y * 0.5);

	
	MyPawnOwner = Pawn(Owner);

	//determines what we are looking at and what color we should use based on that.
	if (MyPawnOwner != None)
	{
		TargetActor = Rx_Hud(HUD).GetActorWeaponIsAimingAt();
		
		if(TargetActor != None)
		{
			targetTeam = TargetActor.GetTeamNum();
			
			if (targetTeam == 0 || targetTeam == 1) //has to be gdi or nod player
			{
				if (targetTeam != MyPawnOwner.GetTeamNum())
				{
					if (!TargetActor.IsInState('Stealthed') && !TargetActor.IsInState('BeenShot'))
					{
						//enemy, go red, except if stealthed (else would be cheating ;] )
						//nBab
						LC.R = 10.f;
						LC.G = 0.f;
						LC.B = 0.f;
					}
				}
				else
				{
					//Friendly
					//nBab
					LC.R = 0.f;
					LC.G = 10.f;
					LC.B = 0.f;
				}
			}
		}
	}
	
	if (!HasAnyAmmo()) //no ammo, go yellow
	{
		//nBab
		LC.R = 10.f;
		LC.G = 8.f;
		LC.B = 0.f;
	}

	//nBab
	CrosshairMIC2.SetVectorParameterValue('Reticle_Colour', LC);
	
	if ( CrosshairMIC2 != none )
	{
		//H.Canvas.SetPos( X+1, Y+1 );
		H.Canvas.SetPos( X, Y );
		H.Canvas.DrawMaterialTile(CrosshairMIC2,CrosshairSize.X, CrosshairSize.Y,0.0,0.0,1.0,1.0);
		DrawHitIndicator(H,x,y);
	}
	if(bDebugWeapon)
	{
	H.Canvas.DrawText("Hit Actor" @ MyHitActor,true,1,1);
	}
	
}
*/
//Edit to not use a zero point trace so hitting infantry is easier with the repair gun 
simulated function UpdateBeam(float DeltaTime)
{
	local Vector		StartTrace, EndTrace, AimDir;
	local ImpactInfo	RealImpact;
	local UTPlayerController PC;

	// define range to use for CalcWeaponFire()
	PC = UTPlayerController(Pawn(Owner).Controller);
	
	if(PC == None || !PC.bBehindView) 
	{
		StartTrace	= Instigator.GetWeaponStartTraceLocation();
	} 
	else 
	{
		StartTrace	= InstantFireStartTrace();
	}
	AimDir = Vector(GetAdjustedAim( StartTrace ));
	EndTrace	= StartTrace + AimDir * GetTraceRange();
	
	//DrawDebugLine(StartTrace,EndTrace,0,0,255,true);
	// Trace a shot
	RealImpact = CalcWeaponFire( StartTrace, EndTrace,,vect(2,2,2) );
	bUsingAimingHelp = false;
	
	if( Rx_Weapon_DeployedC4(RealImpact.HitActor) == None 
		&& Rx_Weapon_DeployedC4(PrevHitActor) != None)
	{
		//loginternal(VSize(RealImpact.HitLocation - PrevHitActor.Location));
		if(VSizeSq(RealImpact.HitLocation - PrevHitActor.Location) < 400)
		{
			RealImpact.HitActor = PrevHitActor;	
		}
	}	

	if(RealImpact.HitActor != None)
	{
		CurrHitLocation = RealImpact.HitLocation;
		// Allow children to process the hit
		ProcessBeamHit(StartTrace, AimDir, RealImpact, DeltaTime);
		UpdateBeamEmitter(RealImpact.HitLocation, RealImpact.HitNormal, RealImpact.HitActor);
		PrevHitActor = RealImpact.HitActor;
	}
	else 
	{
		CurrHitLocation = EndTrace;
		SetFlashLocation(EndTrace);
		UpdateBeamEmitter(EndTrace, vect(0,0,0), None);
	}
}

// Mk-I S.M.A.R.T Protocol.
// Beam will pass through things that doesn't necessarily need repairs. Manufactured by HQA - Handepsilon's Quirky Arsenal
//
// Due to Engineering group constantly getting in each others' way, a new system was proposed in order for the repair gun
// systems to proactively attempt to circumvent through small obstacles

simulated function ImpactInfo CalcWeaponFire(vector StartTrace, vector EndTrace, optional out array<ImpactInfo> ImpactList, optional vector Extent)
{
	local vector			HitLocation, HitNormal, Dir;
	local Actor				HitActor, HitActorTemp;
	local TraceHitInfo		HitInfo;
	local ImpactInfo		CurrentImpact;
	local PortalTeleporter	Portal;
	local float				HitDist;
	local bool				bOldBlockActors, bOldCollideActors;

	// Perform trace to retrieve hit info, ignore anything that doesn't necessarily need repair
	foreach GetTraceOwner().TraceActors(class'Actor', HitActorTemp, HitLocation, HitNormal, EndTrace, StartTrace, Extent, HitInfo, 1)
	{
		if(!HitInfo.HitComponent.BlockZeroExtent && Rx_Pawn(HitActorTemp) == None)
		{
			continue;
		}
		if(Pawn(HitActorTemp) != None && Pawn(HitActorTemp).Health <= 0) // don't let dead pawn block repair beam
		{
			continue;
		}
		if(!PassThroughRepair(HitActorTemp))
		{
			HitActor = HitActorTemp;
//			`log("Repair Gun hits" @ HitActor @ "at" @ HitLocation);
			break;
		}
	}

	//	HitActor = GetTraceOwner().Trace(HitLocation, HitNormal, EndTrace, StartTrace, TRUE, Extent, HitInfo, TRACEFLAG_Bullet);

	// If we didn't hit anything, then set the HitLocation as being the EndTrace location
	if( HitActor == None)
	{
		HitLocation	= EndTrace;
	}

	// Convert Trace Information to ImpactInfo type.
	CurrentImpact.HitActor		= HitActor;
	CurrentImpact.HitLocation	= HitLocation;
	CurrentImpact.HitNormal		= HitNormal;
	CurrentImpact.RayDir		= Normal(EndTrace-StartTrace);
	CurrentImpact.StartTrace	= StartTrace;
	CurrentImpact.HitInfo		= HitInfo;
	
	if(default.MaximumPiercingAbility > 0)
	{
		if(HitActor == None)
			CurrentPiercingPower = 0; //Blocked 
		else if(HitActor.IsA('Rx_Pawn') && CurrentPiercingPower > 0) 
			CurrentPiercingPower-=1;
		else if(HitActor.IsA('Rx_Vehicle') && CurrentPiercingPower >= 3)  
			CurrentPiercingPower-=3;
		else 
			CurrentPiercingPower = 0; //Blocked 
	}
	
	// Add this hit to the ImpactList
	ImpactList[ImpactList.Length] = CurrentImpact;
	// check to see if we've hit a trigger.
	// In this case, we want to add this actor to the list so we can give it damage, and then continue tracing through.
	if( HitActor != None )
	{		
		if (PassThroughDamage(HitActor) && CurrentPiercingPower > 0) 
		{
			// disable collision temporarily for the actor we can pass-through
			HitActor.bProjTarget = false;
			bOldCollideActors = HitActor.bCollideActors;
			bOldBlockActors = HitActor.bBlockActors;
			if (HitActor.IsA('Pawn'))
			{
				// For pawns, we need to disable bCollideActors as well
				HitActor.SetCollision(false, false);

				// recurse another trace
				CalcWeaponFire(HitLocation, EndTrace, ImpactList, Extent);
			}
			else
			{
				if( bOldBlockActors )
				{
					HitActor.SetCollision(bOldCollideActors, false);
				}
				// recurse another trace and override CurrentImpact
				CurrentImpact = CalcWeaponFire(HitLocation, EndTrace, ImpactList, Extent);
			}

			// and reenable collision for the trigger
			HitActor.bProjTarget = true;
			HitActor.SetCollision(bOldCollideActors, bOldBlockActors);
		}
		else
		{
			// if we hit a PortalTeleporter, recurse through
			Portal = PortalTeleporter(HitActor);
			if( Portal != None && Portal.SisterPortal != None )
			{
				Dir = EndTrace - StartTrace;
				HitDist = VSize(HitLocation - StartTrace);
				// calculate new start and end points on the other side of the portal
				StartTrace = Portal.TransformHitLocation(HitLocation);
				EndTrace = StartTrace + Portal.TransformVectorDir(Normal(Dir) * (VSize(Dir) - HitDist));
				//@note: intentionally ignoring return value so our hit of the portal is used for effects
				//@todo: need to figure out how to replicate that there should be effects on the other side as well
				CalcWeaponFire(StartTrace, EndTrace, ImpactList, Extent);
			}
		}
	}
	//Need the last impact info if it was piercing targets/First if it doesn't pierce 
	if(default.MaximumPiercingAbility == 0)
		return CurrentImpact;
	else
		return ImpactList[ImpactList.Length-1];

}

// Similar to PassThroughDamage, but since said function was static, it's impossible to get the Owner
simulated function bool PassThroughRepair(Actor HitActor) 
{
	local Rx_Pawn RxP;
	local Rx_Vehicle RxV;
	local Rx_Weapon_DeployedActor RxD;

	if(Owner == None) // can't determine if owner doesn't exist
	{
		//blank, on purpose
	}
	else if(UTPickupFactory(HitActor) != None || Rx_SmokeScreen(HitActor) != None)
		return true;

	else if(HitActor.GetTeamNum() == Owner.GetTeamNum() || (HitActor.isA('Rx_Vehicle') && HitActor.GetTeamNum() == 255))
	{
		if(HitActor.isA('Rx_Pawn'))
		{
			RxP = Rx_Pawn(HitActor);

			return (RxP.Health <= 0 || (RxP.Health >= RxP.HealthMax && RxP.Armor >= RxP.ArmorMax));
		}
		else if(HitActor.isA('Rx_Vehicle'))
		{
			RxV = Rx_Vehicle(HitActor);

			return (RxV.Health <= 0 || (RxV.Health >= RxV.HealthMax));
		}
		else if(HitActor.IsA('Rx_Weapon_DeployedActor'))
		{
			RxD = Rx_Weapon_DeployedActor(HitActor);

			if(Rx_Weapon_DeployedProxyC4(HitActor) != None
				&& Rx_Weapon_DeployedProxyC4(HitActor).OwnerPRI != None
				&& CurrentFireMode == 1
				&& (Rx_Weapon_DeployedProxyC4(HitActor).OwnerPRI == Instigator.PlayerReplicationInfo || Rx_PRI(Rx_Weapon_DeployedProxyC4(HitActor).OwnerPRI).GetMineStatus() == false )
				&& RxD.HP > 0
				&& RxD.HP <= RxD.MaxHP)
				return false;

			else
			{
				return (RxD.HP <= 0 || RxD.HP >= RxD.MaxHP);
			}
		}
	}

	// Although smart, the targetting system is not smart enough to bypass enemies... because reasons
	//
	// O.O.C. - We try to give the responsibility back to the reliable super function that we used earlier, just in case.
	// This also will still allow enemies to bodyblock repair with their body or their deployable as a viable strategy, but team member will not be able to teamhamper.

	return false;
}

function PromoteWeapon(byte rank) /*Covers most of what needs to be done(Damage,ROF,ClipSize,etc.) Special things obviously need to be added for special weapons*/
{
VRank = rank; 
}

DefaultProperties
{
	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RX_WP_RepairGun.Mesh.SK_WP_RepairGun_1P_Alternative'
		AnimSets(0)=AnimSet'RX_WP_RepairGun.Anims.AS_RepairGun_1P'
		Animations=MeshSequenceA
		FOV=55.0
		Scale=1.5
	End Object
	
	ArmsAnimSet = AnimSet'RX_WP_RepairGun.Anims.AS_RepairGun_Arms'

	// Weapon SkeletalMesh
	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'RX_WP_RepairGun.Mesh.SK_WP_RepairGun_Back'
		Scale=1.0
	End Object

	AttachmentClass = class'Rx_Attachment_RepairGun'
	
	LeftHandIK_Offset=(X=0,Y=0,Z=0)
	LeftHandIK_Rotation = (Pitch=3458,Yaw=-546,Roll=9466)
	RightHandIK_Offset=(X=0,Y=0,Z=0)
	
	LeftHandIK_Relaxed_Offset = (X=0.85,Y=1.75,Z=1.37)
	RightHandIK_Relaxed_Offset = (X=-4.0,Y=0.0,Z=0.0)
	RightHandIK_Relaxed_Rotation = (Pitch=-910,Yaw=3640,Roll=0)

	
	bOverrideLeftHandAnim=true
	LeftHandAnim=H_M_Hands_Closed

	ShotCost(0)=0
	ShotCost(1)=0
	FireInterval(0)=+0.3
	FireInterval(1)=+0.3
	
	EquipTime=0.5
//	PutDownTime=0.4
	
	WeaponRange=600.0

	PlayerViewOffset=(X=5,Y=-3,Z=-2.5)

	LockerRotation=(pitch=0,yaw=0,roll=-16384)

	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponFireTypes(1)=EWFT_InstantHit
	//WeaponFireTypes(1)=EWFT_None

	InstantHitDamage(0)=0
	InstantHitDamage(1)=0

	InstantHitDamageTypes(0) = class'Rx_DmgType_RepairGun'
	InstantHitDamageTypes(1) = class'Rx_DmgType_RepairGun'
	
	InstantHitMomentum(0)=0
	InstantHitMomentum(1)=0

	Spread(0)=0.0
	Spread(1)=0.0

	HealAmount = 30 //20
	MinHealAmount = 1
	MineDamageModifier  = 2 //3
	EMPHealMultiplier = 0.15 //0.25
	
	ClipSize = 999
	InitalNumClips = 1
	MaxClips = 1
	bHasInfiniteAmmo = true
	bCanGetAmmo=false

	WeaponFireSnd[0]=SoundCue'RX_WP_RepairGun.Sounds.RepairGun_FireCue'
	WeaponFireSnd[1]=SoundCue'RX_WP_RepairGun.Sounds.RepairGun_FireCue'
	WeaponFireAnim[0]="WeaponFireLoop"
	WeaponFireAnim[1]="WeaponFireLoop"
	ArmFireAnim[0]="WeaponFireLoop"	
	ArmFireAnim[1]="WeaponFireLoop"	

	WeaponPutDownSnd=SoundCue'RX_WP_Pistol.Sounds.SC_Pistol_PutDown'
	WeaponEquipSnd=SoundCue'RX_WP_Pistol.Sounds.SC_Pistol_Equip'

	PickupSound=SoundCue'RX_WP_Pistol.Sounds.SC_Pistol_Equip'

	FireSocket="MuzzleFlashSocket"

	MuzzleFlashSocket="MuzzleFlashSocket"
	MuzzleFlashPSCTemplate=ParticleSystem'RX_WP_RepairGun.Effects.P_RepairGun_MuzzleFlash_1P'
	MuzzleFlashDuration=3.3667
	MuzzleFlashLightClass=class'Rx_Light_RepairBeam'

	InventoryGroup=2
	InventoryMovieGroup=19

	WeaponIconTexture=Texture2D'RX_WP_RepairGun.UI.T_WeaponIcon_RepairGun'
	
	// AI Hints:
	MaxDesireability=0.05
	AIRating=+0.05
	CurrentRating=+0.05    
	bFastRepeater=true
	bInstantHit=true
	
	BeamTemplate[0]=ParticleSystem'RX_WP_RepairGun.Effects.P_RepairGun_Beam'
	BeamSockets[0]=MuzzleFlashSocket    
	BeamTemplate[1]=ParticleSystem'RX_WP_RepairGun.Effects.P_RepairGun_Beam'
	BeamSockets[1]=MuzzleFlashSocket    
	
	FiringStatesArray(0)=WeaponBeamFiring
	FiringStatesArray(1)=WeaponBeamFiring
	
	EndPointParamName=BeamEnd
	
	StartAltFireSound=SoundCue'RX_WP_RepairGun.Sounds.SC_RepairGun_Fire_Start'
	EndAltFireSound=SoundCue'RX_WP_RepairGun.Sounds.SC_RepairGun_Fire_Stop'

	/** one1: Added. */
	BackWeaponAttachmentClass = class'Rx_BackWeaponAttachment_RepairGun'
	
	/*******************/
	/*Veterancy*/
	/******************/
	
	Vet_DamageModifier(0)=1  //Applied to instant-hits only
	Vet_DamageModifier(1)=1.0 //1.10 //22
	Vet_DamageModifier(2)=1.0 //1.20 //24
	Vet_DamageModifier(3)=1.0 //1.30 //26
	
	Vet_RangeModifier(0) = 1.0 //Also applied to instant hits only
	Vet_RangeModifier(1) = 1.1  
	Vet_RangeModifier(2) = 1.25  
	Vet_RangeModifier(3) = 1.50  
	
	/**********************/
	
	TestNum = 5

}
