class Rx_Building_Emp_Internals extends Rx_Building_TechBuilding_Internals
	notplaceable;

var int CountdownTime;

var MaterialInstanceConstant MICMainCannon;
var MaterialInstanceConstant MICCannonYawHoses;
var MaterialInstanceConstant MICCannonBase;  
  
`define GdiUnderAttackForGdiSound FriendlyBuildingSounds[BuildingUnderAttack]
`define GdiUnderAttackForNodSound FriendlyBuildingSounds[BuildingDestructionImminent]
`define NodUnderAttackForGdiSound EnemyBuildingSounds[BuildingUnderAttack]
`define NodUnderAttackForNodSound EnemyBuildingSounds[BuildingDestructionImminent]  

var() LinearColor NodColor;
var()	 LinearColor GdiColor;
var() LinearColor NeutralColor;
  
simulated function Init(Rx_Building Visuals, bool isDebug )
{
	super.Init(Visuals, isDebug);
	//init Colors
	NodColor.R = 1.0;
	NodColor.A = 1.0;
	
	GdiColor.R = 1.0;
	GdiColor.G = 1.0;
	GdiColor.A = 1.0;

	//End init Colors
		
	//super.SetupCapturePoint(); //LOL, capture in front of MCT
	MICMainCannon = BuildingSkeleton.CreateAndSetMaterialInstanceConstant(0);
	MICCannonYawHoses = BuildingSkeleton.CreateAndSetMaterialInstanceConstant(1);
	MICCannonBase = BuildingVisuals.StaticExterior.CreateAndSetMaterialInstanceConstant(0);
	Colorchange();
	Armor=0;
}

simulated event ReplicatedEvent(name VName)
{
	if ( VName == 'FlagTeam' ) 
		Colorchange();
	else
		super.ReplicatedEvent(VName);
}

/*Only here to grab some stuff from

function AddCreditsToOwningTeamTimer()
{
	local PlayerReplicationInfo PRI;
	
	if(GetTeamNum() == TEAM_UNOWNED) {
		return;
	}
	
	foreach WorldInfo.GRI.PRIArray(pri)
	{
		if(Rx_PRI(pri) != None && pri.GetTeamNum() == GetTeamNum()) {
			Rx_PRI(pri).AddCredits(CreditsGain);
		}
	}
}*/

simulated function Colorchange() 
{
	if(FlagTeam == TEAM_NOD)
	{
 		MICMainCannon.SetVectorParameterValue('Paint Color', NodColor); //1,0,0,1);
		MICCannonYawHoses.SetVectorParameterValue('Paint Color', NodColor);// 1,0,0,1);
		MICCannonBase.SetVectorParameterValue('Paint Color', NodColor);//1,0,0,1);
	}
 	else if(FlagTeam == TEAM_GDI)
	{
 		MICMainCannon.SetVectorParameterValue('Paint Color', GdiColor);//1,1,0,1);
		MICCannonYawHoses.SetVectorParameterValue('Paint Color', GdiColor);//1,1,0,1);
		MICCannonBase.SetVectorParameterValue('Paint Color', GdiColor); //1,1,0,1);
	}
 	else
	{
 		MICMainCannon.SetVectorParameterValue('Paint Color', NeutralColor);//1,1,1,1);
		MICCannonYawHoses.SetVectorParameterValue('Paint Color', NeutralColor);//1,1,1,1);	
		MICCannonBase.SetVectorParameterValue('Paint Color', NeutralColor); //1,1,1,1);	
	}
}

DefaultProperties
{
	Begin Object Name=BuildingSkeletalMeshComponent
		SkeletalMesh        			= SkeletalMesh'RX_BU_EMPCannon.Mesh.EMPCannon2'
		//AnimSets(0)         			= none//AnimSet'RX_BU_Silo.Anims.AS_BU_Silo'
		AnimTreeTemplate    			= AnimTree'RX_BU_EMPCannon.Anims.EMP_AnimTree'
		//PhysicsAsset     			= PhysicsAsset'RX_BU_EMPCannon.Anims.EMPCannon2_Physics'
	End Object

	`GdiUnderAttackForGdiSound = SoundNodeWave'RX_BU_EMPCannon.Sounds.EVA_DEF_OFF'
	`GdiUnderAttackForNodSound = SoundNodeWave'RX_BU_EMPCannon.Sounds.EVA_DEF_ON'

	`NodUnderAttackForGdiSound = SoundNodeWave'RX_BU_EMPCannon.Sounds.CABAL_DEF_OFF'
	`NodUnderAttackForNodSound = SoundNodeWave'RX_BU_EMPCannon.Sounds.CABAL_DEF_ON'
	
	TeamID          = 255
	FlagTeam = TEAM_GDI
	CountdownTime = 300 //Depends on the format
	
	
	
	
	
}
