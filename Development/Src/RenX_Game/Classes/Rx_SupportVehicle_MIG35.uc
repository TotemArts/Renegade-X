class Rx_SupportVehicle_MIG35 extends Rx_SupportVehicle_A10; 

DefaultProperties
{

StartSoundWaypoint = 0

ActorName = "MIG-35" 


Begin Object Name=WSkeletalMesh	
		SkeletalMesh=SkeletalMesh'RX_VH_Mig35.Mesh.SK_VH_Mig35'
		AnimTreeTemplate=AnimTree'RX_VH_Mig35.Anim.AT_VH_Mig35'
		PhysicsAsset=PhysicsAsset'RX_VH_Mig35.Mesh.SK_VH_Mig35_Physics'
	End Object
	Mesh=WSkeletalMesh
	CollisionComponent=WSkeletalMesh
	Components.Add(WSkeletalMesh)
	
	//Audio
	   Begin Object Name=VehicleAudioComponent
        SoundCue=SoundCue'RX_VH_Mig35.Sounds.SC_Mig35_FlyOver'
    End Object
    MyAudioComponent=VehicleAudioComponent
    Components.Add(VehicleAudioComponent);		
	
	
}