class Rx_Building_EMPCannon_Internals extends Rx_Building_TechBuilding_Internals
	notplaceable;

/*TODO: ALL OF THIS*/	
	
//Cannon Properties 
var int 	ChargeUpTime; //Seconds  
var float	TurretRotationSpeed;
var float	IncrementChargeTime; 
var int		MaxChargeableIncrements;
var int		Charges;  
var SoundCue SC_Fire;
var UTSkelControl_TurretConstrained Skel_TurretYaw, Skel_TurretPitch;

var name T_Yaw, T_Pitch; 

var bool bran; 
//Team Changing and Usage Properties 
var bool bFiring; 
var byte FiringState; //0 Static //1 Pointing to fire //1 Returning to original position 



`define GdiUnderAttackForGdiSound FriendlyBuildingSounds[BuildingUnderAttack]
`define GdiUnderAttackForNodSound FriendlyBuildingSounds[BuildingDestructionImminent]
`define NodUnderAttackForGdiSound EnemyBuildingSounds[BuildingUnderAttack]
`define NodUnderAttackForNodSound EnemyBuildingSounds[BuildingDestructionImminent]  

simulated function Init(Rx_Building Visuals, bool isDebug )
{
	super.Init(Visuals, isDebug);
Skel_TurretYaw = UTSkelControl_TurretConstrained(BuildingSkeleton.FindSkelControl(T_Yaw));
		Skel_TurretPitch = UTSkelControl_TurretConstrained(BuildingSkeleton.FindSkelControl(T_Pitch));
	SetTimer(2.0, true, 'FireChargeIncrementTimer') ;
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp){
	`log("Q#RFEWDFSDFSDFSSASGDS" @ SkelComp); 
	
	if(SkelComp == BuildingSkeleton)
	{
		bran = true; 
		Skel_TurretYaw = UTSkelControl_TurretConstrained(BuildingSkeleton.FindSkelControl(T_Yaw));
		Skel_TurretPitch = UTSkelControl_TurretConstrained(BuildingSkeleton.FindSkelControl(T_Pitch));
		`log(Skel_TurretYaw);
	}
	
}

function FireChargeIncrementTimer()
{
	//local rotator RandRo;
	
	Skel_TurretYaw = UTSkelControl_TurretConstrained(BuildingSkeleton.FindSkelControl('TurretYaw'));
	Skel_TurretPitch = UTSkelControl_TurretConstrained(BuildingSkeleton.FindSkelControl('TurretPitch'));
	
	`log(BuildingSkeleton @ BuildingSkeleton.FindSkelControl(T_Pitch) @ BuildingSkeleton.FindSkelControl(T_Yaw));
	
	/**RandRo.Pitch = rand(60000);
	RandRo.Yaw = rand(60000); 
	RandRo.roll = rand(60000); 	
	*/
	
	//Skel_TurretYaw.DesiredBoneRotation.Yaw = RandRo.Yaw; 
}

//No flag 
simulated function FlagChanged() 
{
 	return; 
}

function ChangeFlag(TEAM ToTeam)
{
	return; 
}



DefaultProperties
{
	Begin Object Name=BuildingSkeletalMeshComponent
		SkeletalMesh        		= SkeletalMesh'RX_BU_EMPCannon.Mesh.EMPCannon2'
		//AnimSets(0)         		= AnimSet'RX_BU_Silo.Anims.AS_BU_Silo'
		AnimTreeTemplate    		= AnimTree'RX_BU_EMPCannon.Anims.EMP_AnimTree'
		PhysicsAsset     			= PhysicsAsset'RX_BU_EMPCannon.Anims.EMPCannon2_Physics'
		bUpdateSkelWhenNotRendered  = true
		/**bEnableClothSimulation 	 	= True
		bClothAwakeOnStartup   	 	= True
		ClothWind              	 	= (X=100.000000,Y=-100.000000,Z=20.000000)*/
	End Object

	`GdiUnderAttackForGdiSound = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_GDISilo_UnderAttack'
	`GdiUnderAttackForNodSound = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_GDISilo_UnderAttack'

	`NodUnderAttackForGdiSound = SoundNodeWave'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_NodSilo_UnderAttack'
	`NodUnderAttackForNodSound = SoundNodeWave'RX_EVA_VoiceClips.Nod_EVA.S_EVA_Nod_NodSilo_UnderAttack'
	
	TeamID          = 255
	
	TurretRotationSpeed = 50 //might just be handled in the skeletal controller 
	
	
	IncrementChargeTime = 60.0
	MaxChargeableIncrements = 5
	
	T_Pitch = TurretPitch
	T_Yaw = TurretYaw
}
