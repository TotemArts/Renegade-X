/*********************************************************
*
* File: Rx_Vehicle_Chinook.uc
* Author: RenegadeX-Team
* Poject: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/
class Rx_Vehicle_Chinook extends Rx_Vehicle_Air
      abstract;


/** Firing sounds */
var() AudioComponent FiringAmbient;
var() SoundCue FiringStopSound;

var GameSkelCtrl_Recoil    Recoil_R, Recoil_L;

	  
	  
// function InitializeSeats()
// {
// 	super(UTVehicle).InitializeSeats();
// }



simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    Super.PostInitAnimTree(SkelComp);

    if (SkelComp == Mesh)
    {
        Recoil_R = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_Right') );
        Recoil_L = GameSkelCtrl_Recoil( mesh.FindSkelControl('Recoil_Left') );
    }
}

simulated function VehicleWeaponFireEffects(vector HitLocation, int SeatIndex)
{
   //local Name FireTriggerTag;
   
   // Trigger any vehicle Firing Effects
    //VehicleEvent('ChainGun_Left');
	//VehicleEvent('ChainGun_Right');

   if (SeatIndex == 1)
   {
		VehicleEvent('ChainGun_Left');
		Recoil_L.bPlayRecoil=true;
   }
   else if (SeatIndex == 2)
   {
		VehicleEvent('ChainGun_Right');
		Recoil_R.bPlayRecoil=true;
   }
    
    if (!FiringAmbient.bWasPlaying)
    {
        FiringAmbient.Play();
    }

   Super.VehicleWeaponFireEffects(HitLocation, SeatIndex);


/*
   FireTriggerTag = Seats[SeatIndex].GunSocket[GetBarrelIndex(SeatIndex)];

   if(Weapon != None) 
   {
       if (Weapon.CurrentFireMode == 0)
       {
           switch(FireTriggerTag)
          {
          case 'ChainGun_Right':
             Recoil_L.bPlayRecoil = TRUE;
             VehicleEvent('ChainGun_Right');
             break;
    
          case 'ChainGun_Left':
             Recoil_R.bPlayRecoil = TRUE;
             VehicleEvent('ChainGun_Left');
             break;
          }
       }
       else
       {
          switch(FireTriggerTag)
          {
          case 'ChainGun_Right':
             Recoil_L.bPlayRecoil = TRUE;
             VehicleEvent('ChainGun_Right');
             break;
    
          case 'ChainGun_Left':
             Recoil_R.bPlayRecoil = TRUE;
             VehicleEvent('ChainGun_Left');
             break;
          }
       }
   }
   */
}


    
simulated function VehicleWeaponFired( bool bViaReplication, vector HitLocation, int SeatIndex )
{
    if(SeatIndex == 1 || SeatIndex == 2) 
        super.VehicleWeaponFired(bViaReplication,HitLocation,SeatIndex);
}

simulated function VehicleWeaponStoppedFiring( bool bViaReplication, int SeatIndex )
{
    if(SeatIndex == 1 || SeatIndex == 2) 
	{
        super.VehicleWeaponStoppedFiring(bViaReplication,SeatIndex);
    }
    
    // Trigger any vehicle Firing Effects
    if ( WorldInfo.NetMode != NM_DedicatedServer )
    {
        if (Role == ROLE_Authority || bViaReplication || WorldInfo.NetMode == NM_Client)
        {
			if (SeatIndex == 1)
				VehicleEvent('STOP_ChainGun_Left');
			else if (SeatIndex == 2)
				VehicleEvent('STOP_ChainGun_Right');
        }
    }

    PlaySound(FiringStopSound, TRUE, FALSE, FALSE, Location, FALSE);
    FiringAmbient.Stop();
}

defaultproperties
{

//========================================================\\
//************** Vehicle Physics Properties **************\\
//========================================================\\

    Begin Object Class=UDKVehicleSimChopper Name=SimObject
        MaxThrustForce=700.0
        MaxReverseForce=500.0
        LongDamping=0.6
        MaxStrafeForce=400.0
        LatDamping=0.7
        MaxRiseForce=300.0
        UpDamping=0.7
        TurnTorqueFactor=8500.0
        TurnTorqueMax=10000.0
        TurnDamping=1.2
        MaxYawRate=0.75
        PitchTorqueFactor=450.0
        PitchTorqueMax=300.0
        PitchDamping=0.3
        RollTorqueTurnFactor=2000.0
        RollTorqueStrafeFactor=1000.0
        RollTorqueMax=500.0
        RollDamping=1.0
        MaxRandForce=30.0
        RandForceInterval=0.5
        StopThreshold=10
        bShouldCutThrustMaxOnImpact=true
    End Object
    SimObj=SimObject
    Components.Add(SimObject)

    Health=500
    bLightArmor=false
	bisAirCraft=true
    
	MaxDesireability = 0.0 // todo: reactivate when flying AI is fixed     

    COMOffset=(X=0,Z=0.0)

    BaseEyeheight=30
    Eyeheight=30
    bRotateCameraUnderVehicle=false
    CameraLag=0.28 //0.4
    LookForwardDist=0
    bLimitCameraZLookingUp=true

    AirSpeed=800.0
    GroundSpeed=1600.0
    MaxSpeed=700.000000

    UprightLiftStrength=30.0
    UprightTorqueStrength=30.0

    bStayUpright=true
    StayUprightRollResistAngle=5.0
    StayUprightPitchResistAngle=5.0
    StayUprightStiffness=1200
    StayUprightDamping=20
	
	bIsConsoleTurning=False
	bJostleWhileDriving=True


//========================================================\\
//*************** Vehicle Visual Properties **************\\
//========================================================\\

    Begin Object Name=CollisionCylinder
        CollisionHeight=+70.0
        CollisionRadius=+240.0
        Translation=(X=-40.0,Y=0.0,Z=40.0)
    End Object

    Begin Object name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'RX_VH_Chinook.Mesh.SK_VH_Chinook'
        AnimTreeTemplate=AnimTree'RX_VH_Chinook.Anims.AT_VH_Chinook'
		AnimSets.Add(AnimSet'RX_VH_Chinook.Anims.AS_VH_Chinook')
        PhysicsAsset=PhysicsAsset'RX_VH_Chinook.Mesh.SK_VH_Chinook_Physics'
		MorphSets[0]=MorphTargetSet'RX_VH_Chinook.Mesh.MT_VH_Chinook'
    End Object

    DrawScale=1.0

	VehicleIconTexture=Texture2D'RX_VH_Chinook.UI.T_VehicleIcon_Chinook'
	MinimapIconTexture=Texture2D'RX_VH_Chinook.UI.T_MinimapIcon_Chinook'

//========================================================\\
//********* Vehicle Material & Effect Properties *********\\
//========================================================\\


    DrivingPhysicalMaterial=PhysicalMaterial'RX_VH_Chinook.Materials.PhysMat_Chinook_Driving'
    DefaultPhysicalMaterial=PhysicalMaterial'RX_VH_Chinook.Materials.PhysMat_Chinook'

	RecoilTriggerTag = "ChainGun_Left", "ChainGun_Right"
	VehicleEffects(0)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire_Thick',EffectSocket=DamageSmoke_01)
    VehicleEffects(1)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineFire_Thick',EffectSocket=DamageSmoke_02)
    VehicleEffects(2)=(EffectStartTag=DamageSmoke,EffectEndTag=NoDamageSmoke,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_EngineSmoke',EffectSocket=DamageSmoke_03)

    VehicleEffects(3)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Exhaust',EffectSocket=Exhaust_01)
    VehicleEffects(4)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,bRestartRunning=false,EffectTemplate=ParticleSystem'RX_FX_Vehicle.Damage.P_Exhaust',EffectSocket=Exhaust_02)

//    VehicleEffects(5)=(EffectStartTag="ChainGun_Left",EffectTemplate=ParticleSystem'RX_VH_APC_GDI.Effects.P_MuzzleFlash_Single',EffectSocket="Fire_Left")
//    VehicleEffects(6)=(EffectStartTag="ChainGun_Right",EffectTemplate=ParticleSystem'RX_VH_APC_GDI.Effects.P_MuzzleFlash_Single',EffectSocket="Fire_Right")
	
	VehicleEffects(5)=(EffectStartTag="ChainGun_Left",EffectEndTag="STOP_ChainGun_Left",bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_APC_GDI.Effects.P_MuzzleFlash_50Cal_Looping',EffectSocket="Fire_Left")
	VehicleEffects(6)=(EffectStartTag="ChainGun_Right",EffectEndTag="STOP_ChainGun_Right",bRestartRunning=false,EffectTemplate=ParticleSystem'RX_VH_APC_GDI.Effects.P_MuzzleFlash_50Cal_Looping',EffectSocket="Fire_Right")

    VehicleEffects(7)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_GroundEffect',EffectSocket=GroundEffectBase_Front)
    VehicleEffects(8)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Apache.Effects.P_GroundEffect',EffectSocket=GroundEffectBase_Rear)

    VehicleEffects(9)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Chinook.Effects.P_Chinook_Blades_Blurred_Front',EffectSocket=Propeller_Front)
    VehicleEffects(10)=(EffectStartTag=EngineStart,EffectEndTag=EngineStop,EffectTemplate=ParticleSystem'RX_VH_Chinook.Effects.P_Chinook_Blades_Blurred_Rear',EffectSocket=Propeller_Rear)

	VehicleAnims(0)=(AnimTag=EngineStart,AnimSeqs=(BladesRise),AnimRate=0.33,bAnimLoopLastSeq=false,AnimPlayerName=ChinookPlayer)
	VehicleAnims(1)=(AnimTag=EngineStop,AnimSeqs=(BladesDrop),AnimRate=0.33,bAnimLoopLastSeq=false,AnimPlayerName=ChinookPlayer)

	BigExplosionTemplates[0]=(Template=ParticleSystem'RX_FX_Munitions2.Particles.Explosions.P_Explosion_Vehicle_Air')
    BigExplosionSocket=VH_Death
	
	DamageMorphTargets(0)=(InfluenceBone=MT_F,MorphNodeName=MorphNodeW_F,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage1))
    DamageMorphTargets(1)=(InfluenceBone=MT_R,MorphNodeName=MorphNodeW_R,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage2))
    DamageMorphTargets(2)=(InfluenceBone=MT_L,MorphNodeName=MorphNodeW_L,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage3))
    DamageMorphTargets(3)=(InfluenceBone=MT_B,MorphNodeName=MorphNodeW_B,LinkedMorphNodeName=none,Health=80,DamagePropNames=(Damage4))
	
    DamageParamScaleLevels(0)=(DamageParamName=Damage1,Scale=2.0)
    DamageParamScaleLevels(1)=(DamageParamName=Damage2,Scale=2.0)
    DamageParamScaleLevels(2)=(DamageParamName=Damage3,Scale=2.0)
    DamageParamScaleLevels(3)=(DamageParamName=Damage4,Scale=0.2)


//========================================================\\
//*************** Vehicle Audio Properties ***************\\
//========================================================\\

    Begin Object Class=AudioComponent Name=ScorpionEngineSound
        SoundCue=SoundCue'RX_VH_Chinook.Sounds.SC_Chinook_Idle'
    End Object
    EngineSound=ScorpionEngineSound
    Components.Add(ScorpionEngineSound);
	
	Begin Object Class=AudioComponent name=FiringmbientSoundComponent
        bShouldRemainActiveIfDropped=true
        bStopWhenOwnerDestroyed=true
        SoundCue=SoundCue'RX_VH_APC_GDI.Sounds.SC_APC_Fire_Loop'
    End Object
    FiringAmbient=FiringmbientSoundComponent
    Components.Add(FiringmbientSoundComponent)
    
    FiringStopSound=SoundCue'RX_VH_APC_GDI.Sounds.SC_APC_Fire_Stop'

    EnterVehicleSound=SoundCue'RX_VH_Chinook.Sounds.SC_Chinook_Start'
    ExitVehicleSound=SoundCue'RX_VH_Chinook.Sounds.SC_Chinook_Stop'

    // Scrape sound.
    Begin Object Class=AudioComponent Name=BaseScrapeSound
        SoundCue=SoundCue'A_Gameplay.A_Gameplay_Onslaught_MetalScrape01Cue'
    End Object
    ScrapeSound=BaseScrapeSound
    Components.Add(BaseScrapeSound);

    // Initialize sound parameters.
    EngineStartOffsetSecs=2.74
    EngineStopOffsetSecs=0.0

}
