
class S_C130 extends SkeletalMeshActorSpawnable; 

var ParticleSystem RocketBooster;
var array<ParticleSystemComponent>	RocketEffects;
var const AudioComponent			EngineSound;

var vector TempLocation;
var rotator TempRotation;
var S_CamControl s_cc;

simulated event PostBeginPlay()
{
	local int i;
	super.PostBeginPlay();
	
	SetTimer(13.8, false, 'DeactivateMe');
	if (WorldInfo.NetMode != NM_Client && WorldInfo.NetMode != NM_StandAlone)
	{
		return;
	}
	
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		for (i=0; i<16; i++) {
			RocketEffects[i] = WorldInfo.MyEmitterPool.SpawnEmitterCustomLifetime(RocketBooster, true);
			RocketEffects[i].SetAbsolute(false, false, false);
			RocketEffects[i].bAutoActivate=false;
			RocketEffects[i].SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
	 	}
	}


	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		SkeletalMeshComponent.AttachComponentToSocket(RocketEffects[0], 'Jet_R_01');	
		SkeletalMeshComponent.AttachComponentToSocket(RocketEffects[1], 'Jet_L_01');	
		SkeletalMeshComponent.AttachComponentToSocket(RocketEffects[2], 'Jet_R_02');	
		SkeletalMeshComponent.AttachComponentToSocket(RocketEffects[3], 'Jet_L_02');
		SkeletalMeshComponent.AttachComponentToSocket(RocketEffects[4], 'Jet_R_03');
		SkeletalMeshComponent.AttachComponentToSocket(RocketEffects[5], 'Jet_L_03');
		SkeletalMeshComponent.AttachComponentToSocket(RocketEffects[6], 'Jet_R_04');
		SkeletalMeshComponent.AttachComponentToSocket(RocketEffects[7], 'Jet_L_04');
		SkeletalMeshComponent.AttachComponentToSocket(RocketEffects[8], 'Jet_R_05');
		SkeletalMeshComponent.AttachComponentToSocket(RocketEffects[9], 'Jet_L_05');
		SkeletalMeshComponent.AttachComponentToSocket(RocketEffects[10], 'Jet_R_06');
		SkeletalMeshComponent.AttachComponentToSocket(RocketEffects[11], 'Jet_L_06');
		SkeletalMeshComponent.AttachComponentToSocket(RocketEffects[12], 'Jet_R_07');
		SkeletalMeshComponent.AttachComponentToSocket(RocketEffects[13], 'Jet_L_07');
		SkeletalMeshComponent.AttachComponentToSocket(RocketEffects[14], 'Jet_R_08');
		SkeletalMeshComponent.AttachComponentToSocket(RocketEffects[15], 'Jet_L_08');
		
		SetTimer(0.1, false, 'Start');
		SetTimer(3.6, false, 'LandingRockets');	
		SetTimer(5.1, false, 'DeactivateLandingRockets');	
		SetTimer(6.1, false, 'TakeoffRockets');	
		SetTimer(7.1, false, 'DeactivateTakeoffRockets');	
	}	

}

simulated function Start() {
	SetHidden(false);
	s_cc = Spawn( class'S_CamControl' );
	s_cc.bForC130 = true;
	s_cc.drs = None;
	TempLocation = location - vector(Rotation) * 80000;;
	TempLocation.z += 8000;	
	
	s_cc.Flag_Locations[0] = TempLocation;
	TempLocation = location - vector(Rotation) * 10000;
	TempLocation.z += 4000;
	s_cc.Flag_Locations[1] = TempLocation;
	TempLocation = location - vector(Rotation) * 2000;
	TempLocation.z += 500;
	s_cc.Flag_Locations[2] = TempLocation;
	TempLocation = location - vector(Rotation) * 800;
	TempLocation.z += 300;
	s_cc.Flag_Locations[3] = TempLocation;	
	TempLocation = location + vector(Rotation) * 100;
	//TempLocation.y += 100;
	TempLocation.z += 300;
	s_cc.Flag_Locations[4] = TempLocation;
	TempLocation = location + vector(Rotation) * 1300;
	TempLocation.z += 350;
	s_cc.Flag_Locations[5] = TempLocation;
	TempLocation = location + vector(Rotation) * 7000;
	TempLocation.z += 2500;
	s_cc.Flag_Locations[6] = TempLocation;
	TempLocation = location + vector(Rotation) * 80000;
	TempLocation.z += 8000;
	s_cc.Flag_Locations[7] = TempLocation;
	TempLocation = location + vector(Rotation) * 140000;
	TempLocation.z += 10000;
	s_cc.Flag_Locations[8] = TempLocation;

	SetLocation(s_cc.Flag_Locations[0]);
	
	TempRotation = rotation;
	TempRotation.pitch -= 500;
	TempRotation.roll -= 0;
	s_cc.Rotation_At_Flags[0] = TempRotation;
	TempRotation = rotation;
	TempRotation.pitch -= 1000;
	TempRotation.roll -= 0;	
	s_cc.Rotation_At_Flags[1] = TempRotation;
	TempRotation = rotation;
	TempRotation.pitch += 0;
	TempRotation.roll += 100;	
	s_cc.Rotation_At_Flags[2] = TempRotation;
	TempRotation = rotation;
	TempRotation.pitch += 600;
	TempRotation.roll += 50;	
	s_cc.Rotation_At_Flags[3] = TempRotation;
	TempRotation = rotation;
	TempRotation.pitch += 1200;
	TempRotation.roll += -100;	
	s_cc.Rotation_At_Flags[4] = TempRotation;
	TempRotation = rotation;
	TempRotation.pitch += 1800;
	TempRotation.roll -= 50;	
	s_cc.Rotation_At_Flags[5] = TempRotation;
	TempRotation = rotation;
	TempRotation.pitch += 2200;
	TempRotation.roll -= 0;	
	s_cc.Rotation_At_Flags[6] = TempRotation;
	TempRotation = rotation;
	TempRotation.pitch += 2000;
	TempRotation.roll -= 0;	
	s_cc.Rotation_At_Flags[7] = TempRotation;
	s_cc.Rotation_At_Flags[8] = TempRotation;
	
	s_cc.Flag_Fovs[0] = 90;
	s_cc.Flag_Fovs[1] = 90;
	s_cc.Flag_Fovs[2] = 90;
	s_cc.Flag_Fovs[3] = 90;
	s_cc.Flag_Fovs[4] = 90;
	s_cc.Flag_Fovs[5] = 90;
	s_cc.Flag_Fovs[6] = 90;
	s_cc.Flag_Fovs[7] = 90;
	s_cc.Flag_Fovs[8] = 90;
	
	s_cc.Flag_Times[0] = 0.0;
	s_cc.Flag_Times[1] = 3.5;
	s_cc.Flag_Times[2] = 5.2;
	s_cc.Flag_Times[3] = 5.5;
	s_cc.Flag_Times[4] = 5.7;
	s_cc.Flag_Times[5] = 6.0;
	s_cc.Flag_Times[6] = 7.4;
	s_cc.Flag_Times[7] = 12.0;
	s_cc.Flag_Times[8] = 13.8;
	
	s_cc.conf = true;
	s_cc.z = 9;
	s_cc.init();
	s_cc.updateSplinef(false);
	
	s_cc.timesangleichen();
	s_cc.inittimespline();	
	s_cc.btimedpath = true;
	s_cc.startCam = true;
	
	s_cc.draw_Spline = false;
	SetTimer( 0.005, true );
	SetTimer(0.5, false, 'StartEngineSound');
	SkeletalMeshComponent.PlayAnim('VehicleDropoff');	
}

simulated function DeactivateMe() {
	ClearTimer();
	if(s_cc != None) {
		s_cc.ClearTimer();
		EngineSound.Stop();
		s_cc.Destroy();
		SkeletalMeshComponent.SetHidden(true);
	}
	SetTimer(2.0,false,'DestroyMe');
}

simulated function DestroyMe() {
	Destroy();
}

simulated function StartEngineSound() {
	EngineSound.Play();
}
 
simulated function Timer() 
{
	if(s_cc != None) {
		SetLocation(s_cc.location);
		//SetRotation(s_cc.rotation);
	}
}

simulated function LandingRockets() {
	RocketEffects[0].SetActive(true);
	RocketEffects[1].SetActive(true);
	RocketEffects[2].SetActive(true);
	RocketEffects[3].SetActive(true);
}

simulated function DeactivateLandingRockets() {
	RocketEffects[0].SetActive(false);
	RocketEffects[1].SetActive(false);
	RocketEffects[2].SetActive(false);
	RocketEffects[3].SetActive(false);	
}
	
simulated function TakeoffRockets() {
	RocketEffects[4].SetActive(true);
	RocketEffects[5].SetActive(true);
	RocketEffects[6].SetActive(true);
	RocketEffects[7].SetActive(true);	
	RocketEffects[8].SetActive(true);	
	RocketEffects[9].SetActive(true);	
	RocketEffects[10].SetActive(true);	
	RocketEffects[11].SetActive(true);	
	RocketEffects[12].SetActive(true);	
	RocketEffects[13].SetActive(true);	
	RocketEffects[14].SetActive(true);	
	RocketEffects[15].SetActive(true);	
}

simulated function DeactivateTakeoffRockets() {
	RocketEffects[4].SetActive(false);
	RocketEffects[5].SetActive(false);
	RocketEffects[6].SetActive(false);
	RocketEffects[7].SetActive(false);	
	RocketEffects[8].SetActive(false);	
	RocketEffects[9].SetActive(false);	
	RocketEffects[10].SetActive(false);	
	RocketEffects[11].SetActive(false);	
	RocketEffects[12].SetActive(false);	
	RocketEffects[13].SetActive(false);	
	RocketEffects[14].SetActive(false);	
	RocketEffects[15].SetActive(false);	
}


defaultproperties
{

	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'RX_VH_C-130.Mesh.SK_C-130'
		AnimSets(0)=AnimSet'RX_VH_C-130.Anim.AS_C130_VehicleDrop'
		//PhysicsAsset=PhysicsAsset'RX_VH_C-130.Mesh.SK_C-130_AirDrop_Physics'
	End Object
	
    Begin Object Class=AudioComponent Name=EngineSoundComponent
        SoundCue=SoundCue'RX_VH_C-130.Sounds.SC_C-130_Engine'
    End Object
    EngineSound=EngineSoundComponent
    Components.Add(EngineSoundComponent);	
	
	RocketBooster=ParticleSystem'RX_VH_C-130.Effects.P_C-130_Jet'
	
	bAlwaysRelevant=true
	RemoteRole=ROLE_SimulatedProxy
	bReplicateMovement=true	
	bUpdateSimulatedPosition=false
	bOnlyDirtyReplication=true
	bHidden=true
}

