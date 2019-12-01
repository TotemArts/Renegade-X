/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class Rx_Weapon_DeployedBeacon extends Rx_Weapon_DeployedActor
	abstract
	implements (RxIfc_TargetedDescription)
	implements(RxIfc_RadarMarker);

`include(RenX_Game\RenXStats.uci);

var int 					  	count;
var array<SoundCue>           	GdiCountdownSounds;
var array<SoundCue>           	NodCountdownSounds;
var SoundCue   				  	GdiDeployedSound;
var SoundCue   				  	NodDeployedSound;
var SoundCue   				  	GdiDisarmSound;
var SoundCue   				  	NodDisarmSound;
var SoundCue                  	BeepCue;
var SoundCue                  	GdiCountDownInitiatedSound;
var SoundCue                  	NodCountDownInitiatedSound;
var SoundCue                  	BuildUpAndExplosionSound;
var SoundCue                  	GdiApproachingSound;
var SoundCue                  	NodApproachingSound;
var SoundCue                  	GdiImminentSound;
var SoundCue                  	NodImminentSound;
var class<UDKExplosionLight>  	ExplosionLightClass;
var rotator					  	emitterRotation;
var ParticleSystemComponent   	BlinkingLightComponent;
var float		     	    	DeployTime;
var float						Damage_Taken;
var Texture					  	MinimapIconTexture;
var bool					  	bOnPedestal, bExplosionPointValid;
var Vector 						PedestalExplosionPoint;

/*Track who does damage to me so I can distribute points correctly on disarming*/
struct Attacker
{
	var PlayerReplicationInfo PPRI; 
	var float DamageDone; 
};

var array<Attacker>	DamagingParties;	//Track who is doing damage to me to evenly distribute points

function Explosion()
{
	local Rx_Building B, tracedB;
	local Pawn P;
	local vector HitLoc,HitNorm, BuildingLocation, FlatLocation, ExplosionLocation;
 	local bool bDamagePawn, bBuildingHit;   


	if (InstigatorController != None && InstigatorController.PlayerReplicationInfo != None)
		`LogRx("GAME" `s "Exploded;" `s self.Class `s "near" `s GetSpotMarkerName() `s "at" `s self.Location `s "by" `s `PlayerLog(InstigatorController.PlayerReplicationInfo));
   	else
		`LogRx("GAME" `s "Exploded;" `s self.Class `s "near" `s GetSpotMarkerName() `s "at" `s self.Location);
   	bExplode = true; // trigger client replication
   	if (WorldInfo.NetMode != NM_DedicatedServer)
    	PlayExplosionEffect();

	if(bOnPedestal)   	
   		ExplosionLocation = GetPedestalExplosionPoint();

   	else
   		ExplosionLocation = Location;

	// damage Buildings
	if(bOnPedestal)
	{
		if(WorldInfo.Game != None)
			WorldInfo.Game.SetGameSpeed(1.0);

		Base.TakeDamage(Damage*Vet_DamageModifier[VRank], InstigatorController, ExplosionLocation, vect(0,0,0), DamageTypeClass != none ? DamageTypeClass : class'UTDmgType_Burning',, self);
	}
	else
	{
		FlatLocation = Location;
		foreach OverlappingActors(class'Rx_Building', B, BuildingDmgRadius, Location, false)
		{
			bBuildingHit = false;

			if (VSizeSq(B.Location-Location) <= Square(BuildingDmgRadius))
				bBuildingHit=true;
			else if (B.BuildingInternals.Trace2dTargets.Length > 0)
			{
				foreach B.BuildingInternals.Trace2dTargets(BuildingLocation)
				{
					FlatLocation.Z = BuildingLocation.Z;
					if (VSizeSq(BuildingLocation-FlatLocation) <= Square(BuildingDmgRadius))
						bBuildingHit=true;
					else
					{
						foreach TraceActors(class'Rx_Building', tracedB, HitLoc, HitNorm, BuildingLocation, FlatLocation)
						{  
							if (tracedB == B)
							{
								if (VSizeSq(HitLoc-FlatLocation) <= Square(BuildingDmgRadius))
									bBuildingHit = true;
								break;
							}
						}
					}
					if (bBuildingHit)
						break;
				}
			}
			else
			{
			// Fallback method in the event the building does not have any Trace2d targets.
				BuildingLocation = B.Location;
				foreach TraceActors(class'Rx_Building', tracedB, HitLoc, HitNorm, BuildingLocation, Location)
				{  
					if (tracedB == B && VSizeSq(HitLoc-Location) <= Square(BuildingDmgRadius))
						bBuildingHit = true;
					break;
				}
			}

			if (bBuildingHit)
			{
				if (GetTeamNum() != B.GetTeamNum() || bDamageAll)
					B.TakeRadiusDamage(InstigatorController, Damage*Vet_DamageModifier[VRank], DmgRadius, DamageTypeClass != none ? DamageTypeClass : class'UTDmgType_Burning', DamageMomentum, VectorHurtOrigin, true, self);
			}
		}
	}
   
   	// damage Pawns
   	foreach CollidingActors(class'Pawn', P, DmgRadius * (bOnPedestal ? 10 : 1), ExplosionLocation, false)
   	{
      	bDamagePawn = true;

      	if(!bOnPedestal)
      	{
	      	foreach TraceActors(class'Rx_Building',B,HitLoc,HitNorm,location,P.location)
	      	{
   		      	bDamagePawn = false;
        	 	break;		
	     	}
	    }
	    else
	    {
	    	if(Rx_Pawn(P) != None)
	    		Rx_Pawn(P).bStopDeathCamera = true;
	    }

      	if(bDamagePawn) 
      	{ 
         	if ((GetTeamNum() != P.GetTeamNum()) 
             || (P.Controller == InstigatorController && !bOnPedestal) || bDamageAll)
            	P.TakeRadiusDamage(InstigatorController, Damage*Vet_DamageModifier[VRank], DmgRadius, DamageTypeClass != none ? DamageTypeClass : class'UTDmgType_Burning', DamageMomentum, ExplosionLocation, bFullDamage, self);
      	}
   	}

   	SetTimer(0.5f, false, 'ToDestroy'); 

	`RecordGamePositionStat(WEAPON_BEACON_EXPLODED, Location, 1);
}

simulated function Vector GetPedestalExplosionPoint()
{
	local Rx_Building B;
	local int i;
	local Vector TotalLocation, HitLocation, HitNormal;

	if(bExplosionPointValid)
		return PedestalExplosionPoint;

	foreach AllActors(class'Rx_Building',B)
	{
		if(GetTeamNum() == B.GetTeamNum() || Rx_Building_TechBuilding(B) != None)
			continue;

		TotalLocation += B.Location;
		i++;
	}

	if(i > 0)
	{
		TotalLocation = TotalLocation / i;

		if (Trace(HitLocation, HitNormal, TotalLocation - Vect(0,0,10000), TotalLocation, true) != None)
			return HitLocation;
		else
			return TotalLocation;
	}
	else
		return Location;
}


simulated function PostBeginPlay()
{
	local PlayerController LPC; 
	
   Super.PostBeginPlay();
   emitterRotation = rotation;
   emitterRotation.pitch = 0;
   
   
   if(WorldInfo.NetMode == NM_Client || WorldInfo.NetMode == NM_Standalone) 
   {
	   
	   foreach LocalPlayerControllers(class'PlayerController', LPC)
			
		if(Rx_HUD(LPC.myHUD).SystemSettingsHandler.GetBeaconIcon() == 1)
			{
				MinimapIconTexture = Texture2D'RenxHud.T_Beacon_Star';
			} 				
	}

}

simulated event HitWall( vector HitNormal, actor Wall, PrimitiveComponent WallComp )
{
	super.HitWall(HitNormal, Wall, WallComp);
	Landed(HitNormal, wall);
}

function Landed(vector HitNormal, Actor FloorActor)
{
    super(Actor).Landed(HitNormal, FloorActor);
   
   	if (WorldInfo.NetMode != NM_Client)
      	bDeployed = true;

    if (FloorActor != None)
    {
      	if(Rx_Weapon_DeployedActor(FloorActor) == none) 
      	{
            SetBase(FloorActor, HitNormal);
			Mesh.SetTraceBlocking (true,true); //Enable collision with zero-extent traces for repair guns
			
	  	}

	  	if(Rx_BuildingAttachment_BeaconPedestal(Base) != None)
    	{
        	bOnPedestal = true;
        	PedestalExplosionPoint = GetPedestalExplosionPoint();
        	bExplosionPointValid = true;
    	}
    }  

   	PerformDeploy();
      

   	if(WorldInfo.NetMode != NM_DedicatedServer)
   	{
      	if(LandEffects != none && !LandEffects.bIsActive)
      	{
         	LandEffects.SetActive(true);
      	}
   	} 
   	else 
   	{    
		SetTimer(0.5,false,'ReplicatePositionAfterLanded');
   	}
   
}

simulated function PerformDeploy()
{
   local vector BlinkinglightSpawnLocation;
   local rotator BlinkinglightSpawnRotation;
   local AudioComponent TempAudio;

   super.PerformDeploy();


   	// Do a double check here
   	if(!bOnPedestal && Rx_BuildingAttachment_BeaconPedestal(Base) != None)
    {
    	bOnPedestal = true;
      	PedestalExplosionPoint = GetPedestalExplosionPoint();
       	bExplosionPointValid = true;
    }

   if (!bImminentExplode)
   {
	  DeployTime = Worldinfo.Timeseconds;

	  	if(WorldInfo.NetMode != NM_Client) 
      	{
			if (TimeUntilExplosion > GdiApproachingSound.Duration && TimeUntilExplosion > NodApproachingSound.Duration)
				SetTimer(3.0, false, 'playApproachingSound');
			if (TimeUntilExplosion - 31.0f > 0)
				SetTimer(TimeUntilExplosion - 31.0f, false, 'playCountInitiatedDownSound');
			if (TimeUntilExplosion - 14.0f > 0)
				SetTimer(TimeUntilExplosion - 14.0f, false, 'PlayImminentSound');
			if (TimeUntilExplosion - 11.0f > 0)
				SetTimer(TimeUntilExplosion - 11.0f, false, 'DeactivateHealingAbility');
			if (bOnPedestal && TimeUntilExplosion - 0.5f > 0)
				SetTimer(TimeUntilExplosion - 0.5f, false, 'DramaticSlomo');
    	}
    	if(WorldInfo.NetMode != NM_DedicatedServer)
      	{
			TempAudio = CreateAudioComponent(BeepCue,true,true,true,,true); 
		 
		 	if(TempAudio == none) SetTimer(1.0, true, 'CheckBeepSound');		
		 	else //Stop the engine from removing beacon beep sounds 
		 	{
				TempAudio.bShouldRemainActiveIfDropped=true;
				TempAudio.bIgnoreForFlushing=true;
		 	}		 
		 
		 	if (TimeUntilExplosion - 10.5f > 0)
				SetTimer(TimeUntilExplosion - 10.5f, false, 'CreateBuildUpAndExplosionSound');
			else
				PlayExplosionSound = true; // If there's not enough time to play the whole build up + explosion, play the explosion sound.

         	SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndRotation( 'BlinkingLightSocket', BlinkinglightSpawnLocation, BlinkinglightSpawnRotation );
         	BlinkingLightComponent = WorldInfo.MyEmitterPool.SpawnEmitter(BlinkingLight, BlinkinglightSpawnLocation, BlinkinglightSpawnRotation,self);		
      	}
   }
}

simulated function PlayApproachingSound() 
{
   local PlayerController PC; 
   
      foreach WorldInfo.AllControllers(class'PlayerController', PC)
      {
         if (PC.GetTeamNum() == TEAM_GDI)
      {
         PC.ClientPlaySound(GdiApproachingSound);
       } else 
       {
         PC.ClientPlaySound(NodApproachingSound);
       }
      }
}

simulated function PlayImminentSound()
{
	local PlayerController PC; 
   
      foreach WorldInfo.AllControllers(class'PlayerController', PC)
      {
         if (PC.GetTeamNum() == TEAM_GDI)
      {
         PC.ClientPlaySound(GdiImminentSound);
       } else 
       {
         PC.ClientPlaySound(NodImminentSound);
       }
      }
}

function BroadcastPlaced()
{
	local Rx_Controller PC, IPC;
	local string SpotLocation; 
	
	IPC=Rx_Controller(InstigatorController);
	SpotLocation = IPC.GetSpottargetLocationInfo(self);
	
	if(Rx_Pawn(IPC.Pawn).PawninEnemyBase(SpotLocation, IPC.Pawn) ) IPC.DisseminateVPString("[Assault Beacon Placed] &" $ class'Rx_Veterancymodifiers'.default.Ev_GoodBeaconLaid $ "&");   
	
	`LogRx("GAME"`s "Deployed;" `s self.Class `s "by" `s `PlayerLog(InstigatorController.PlayerReplicationInfo) `s "near" `s GetSpotMarkerName() `s "at" `s Location);
	BroadcastLocalizedMessage(class'Rx_Message_Deployed',-1,InstigatorController.PlayerReplicationInfo,,self.Class);
	
	foreach WorldInfo.AllControllers(class'Rx_Controller', PC)
	{
		if (PC.GetTeamNum() == IPC.GetTeamNum())
		{
			if(bOnPedestal)
				PC.CTextMessage("Friendly" @ DeployableName @ " placed on the >> PEDESTAL <<",'Green', 150);
			else
				PC.CTextMessage("Friendly" @ DeployableName @ " placed " @ "[" $ SpotLocation $ "]" @ "!",'Green', 150);
		}
		else
			PC.CTextMessage("Enemy" @ DeployableName @ "placed!",'Red',150,,,true);
	}	
}



simulated function playCountInitiatedDownSound()
{
   local PlayerController PC; 
   
   SetTimer(5.0f, true, 'playCountDownSound');
   foreach WorldInfo.AllControllers(class'PlayerController', PC)
   {
      if (PC.GetTeamNum() == TEAM_GDI)
      {
         PC.ClientPlaySound(GdiCountDownInitiatedSound);
      } 
      else 
      {
         PC.ClientPlaySound(NodCountDownInitiatedSound);
      }
   }
}

simulated function CreateBuildUpAndExplosionSound()
{
   PlaySound(BuildupAndExplosionSound,true,false,false);
}


simulated function PlayDisarmedEffect()
{
	if ( BlinkingLightComponent != none )
	{
		 BlinkingLightComponent.DeactivateSystem();
	}

	super.PlayDisarmedEffect();

}

simulated function Destroyed()
{
	super.Destroyed();

	if(WorldInfo.Game != None && bOnPedestal && WorldInfo.TimeDilation <= 0.5)
		WorldInfo.Game.SetGameSpeed(1.0);

	if ( BlinkingLightComponent != none )
	{
		 BlinkingLightComponent.DeactivateSystem();
	}
}

function BroadcastDisarmed(Controller Disarmer)
{
	local Rx_Controller PC, IPC ;
//  local string SpotLocation;
	
	IPC=Rx_Controller(InstigatorController);

//	SpotLocation = GetSpotMarkerName();
	
	if (InstigatorController != None && InstigatorController.PlayerReplicationInfo != None)
		`LogRx("GAME" `s "Disarmed;" `s self.Class `s "by" `s `PlayerLog(Disarmer.PlayerReplicationInfo) `s "owned by" `s `PlayerLog(InstigatorController.PlayerReplicationInfo));
	else
		`LogRx("GAME" `s "Disarmed;" `s self.Class `s "by" `s `PlayerLog(Disarmer.PlayerReplicationInfo));
	BroadcastLocalizedMessage(class'Rx_Message_Deployed',GetTeamNum(),Disarmer.PlayerReplicationInfo,,self.Class);

	foreach WorldInfo.AllControllers(class'Rx_Controller', PC)
   {
      if(PC.GetTeamNum() == IPC.GetTeamNum()) 
      {
//      	if
//    	  	PC.CTextMessage(DeployableName@"[" $ SpotLocation $ "]"@"disarmed!",'Red',130);
//     	else
//	      	PC.CTextMessage(DeployableName@" on the >>PEDESTAL<< disarmed!",'Red',130);
		PC.CTextMessage(DeployableName@"disarmed!",'Red',130);

      }
	  else
		PC.CTextMessage(DeployableName@"disarmed!",'Green',130);

   }
}


simulated function playCountDownSound() 
{
   local PlayerController PC; 
   
   if(count > GdiCountdownSounds.Length || count > NodCountdownSounds.Length)
   {
      return;
   }
      foreach WorldInfo.AllControllers(class'PlayerController', PC)
      {
         if (PC.GetTeamNum() == TEAM_GDI)
      {
         PC.ClientPlaySound(default.GdiCountdownSounds[count]);
       } else 
       {
         PC.ClientPlaySound(default.NodCountdownSounds[count]);
       }	
      }
      count++;
      if(count == 4) 
      {
         SetTimer(1.0f, true, 'playCountDownSound');
      }
}

function DeactivateHealingAbility()
{
   bCanNotBeDisarmedAnymore = true;	
}

function DramaticSlomo()
{
	if(InstigatorController == None || InstigatorController.GetTeamNum() == Rx_BuildingAttachment_BeaconPedestal(Base).GetTeamNum())
		return;

	if(WorldInfo.Game != None)
		WorldInfo.Game.SetGameSpeed(0.2);
}

function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
   if(!bCanNotBeDisarmedAnymore) {
      return super.HealDamage(Amount,Healer,DamageType);
   }
   return false;
}

function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local int InstigatorIndex;
	local Attacker TempAttacker;
	local Attacker PRII;
	
	if (!CanDisarmMe(DamageCauser))
	{
		return;
	}
	
	if(!bCanNotBeDisarmedAnymore)
	{
	super(Actor).TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	
	//Most of the super call to Rx_Weapon_DeployedActor
	if (DamageAmount <= 0 || HP <= 0 || bDisarmed )
      return;

  
  
  /*Now track who's doing the damage*/
	InstigatorIndex=DamagingParties.Find('PPRI',EventInstigator.PlayerReplicationInfo);
		
			if(InstigatorIndex == -1)  //New damager
			{
				TempAttacker.PPRI=EventInstigator.PlayerReplicationInfo;
				
				TempAttacker.DamageDone = Min(DamageAmount,HP);
				
				Damage_Taken+=TempAttacker.DamageDone; //Add this damage to the total damage taken.
				
				Rx_PRI(TempAttacker.PPRI).AddBeaconDisarmPoints(Min(DamageAmount,HP));
				
				DamagingParties.AddItem(TempAttacker) ;
			
			}
			else
			{
				if(DamageAmount <= float(HP))
				{
					DamagingParties[InstigatorIndex].DamageDone+=DamageAmount;
					Damage_Taken+=DamageAmount; //Add this damage to the total damage taken.
					Rx_PRI(DamagingParties[InstigatorIndex].PPRI).AddBeaconDisarmPoints(DamageAmount);
				}
				else
				{
					DamagingParties[InstigatorIndex].DamageDone+=HP;	
					Damage_Taken+=HP; //Add this damage to the total damage taken.
					Rx_PRI(DamagingParties[InstigatorIndex].PPRI).AddBeaconDisarmPoints(HP);
				}
				
				
			}
  
  
  
	HP -= DamageAmount;

	if (HP <= 0)
	{
		BroadcastDisarmed(EventInstigator);
		if (WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer) // trigger client replication
			bDisarmed = true;
		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			PlayDisarmedEffect();      
			ClearTimer('Explosion');
			`RecordGamePositionStat(WEAPON_BEACON_DISARMED, Location, 1);
		}

		foreach DamagingParties(PRII)
		{
		if(PRII.PPRI != none)
			{
				Rx_PRI(PRII.PPRI).AddScoreToPlayerAndTeam(default.DisarmScoreReward*(PRII.DamageDone/Damage_Taken)) ; 
				DisarmScoreReward-=default.DisarmScoreReward*(PRII.DamageDone/Damage_Taken);
			}
		}
		
		if(DisarmScoreReward > 0) //If there's leftover score, just add it to the team
		{
			Rx_TeamInfo(EventInstigator.PlayerReplicationInfo.Team).AddRenScore(DisarmScoreReward);
			DisarmScoreReward=0; 
		}
		
		
		if (EventInstigator.PlayerReplicationInfo != none && EventInstigator.PlayerReplicationInfo.GetTeamNum() != TeamNum)
		{
			Rx_Controller(EventInstigator).DisseminateVPString( "[Beacon Disarmed]&" $ class'Rx_VeterancyModifiers'.default.Ev_BeaconDisarmed $ "&");
		}
		
		SetTimer(0.1, false, 'DestroyMe'); // delay it a bit so disappearing blends a little bit better with the disarmed effects
	}
					
	
	}
	
	
}

simulated function string GetTargetedDescription(PlayerController PlayerPerspective)
{
	local int DisarmTime;
	DisarmTime = int((TimeUntilExplosion - 10) - (WorldInfo.TimeSeconds - DeployTime));
	if(DisarmTime <= 0)
		return "";
	else
		return string(DisarmTime);
}

simulated function CheckBeepSound()
{
	if(CreateAudioComponent(BeepCue,true,true,true,,true) != none) ClearTimer('CheckBeepSound') ;
}

/******************
*RxIfc_RadarMarker*
*******************/

//0:Infantry 1: Vehicle 2:Miscellaneous  
simulated function int GetRadarIconType()
{
	return 1; //Vehicle
} 

simulated function bool ForceVisible()
{
	return false;  
}

simulated function vector GetRadarActorLocation() 
{
	return location; 
} 
simulated function rotator GetRadarActorRotation()
{
	return rotation; 
}

simulated function byte GetRadarVisibility()
{
	return 1; 
} 
simulated function Texture GetMinimapIconTexture()
{
	return MinimapIconTexture; 
}

/******************
*END RadarMarker***
*******************/

/******************
HANDEPSILON - Bot Handler
*******************/

function bool TellBotToRepair(Rx_Bot B)
{
	if(bCanNotBeDisarmedAnymore)
		return false;

	if(B.IsHealing(false) && B.Focus == Self 
		&& ((B.GetTeamNum() == TeamNum && HP < MaxHP) || (B.GetTeamNum() != TeamNum && HP > 0)))
		return true;

	if(B.HasRepairGun() && ((B.GetTeamNum() == TeamNum && HP < MaxHP) || (B.GetTeamNum() != TeamNum && HP > 0)))
	{
		B.Focus=Self;
		B.DoRangedAttackOn(Self);
		return true;
	}

	return false;

}

function bool IsPotentiallyDangerous()
{
	local Rx_Building NearbyBuilding;

	foreach OverlappingActors(class'Rx_Building', NearbyBuilding, BuildingDmgRadius*75)
	{
		if(NearbyBuilding.GetHealth() > 0 && Rx_Building_TechBuilding(NearbyBuilding) == None
			&& ((TeamNum==0 && NearbyBuilding.TeamID == TEAM_NOD) || (TeamNum==1 && NearbyBuilding.TeamID == TEAM_GDI)))
			return true;
	}

	return false;
}

function bool TooCloseToBuilding(Rx_Building Building)
{
	return VSizeSq(Building.Location - Location) <= Square(BuildingDmgRadius*75);
}





DefaultProperties
{
	PlayExplosionSound = false;
	bBroadcastPlaced = true;
	bBroadcastDisarmed = true;
	bFullDamage = true; // do radius damage on pawns
	TimeUntilExplosion = 60.0f;
	DisarmScoreReward = 200;
	VectorHurtOrigin=(X=0,Y=0,Z=1);
	DamageMomentum = 500000.0f
	DmgRadius = 1500.0f
	BuildingDmgRadius = 500.0f
	Damage = 5000;
	HP = 400;
	Damage_Taken = 0 //Tracks all of the damage that has been taken from disarming. 
	
	MinimapIconTexture = Texture2D'RenxHud.T_Beacon_Star'

}