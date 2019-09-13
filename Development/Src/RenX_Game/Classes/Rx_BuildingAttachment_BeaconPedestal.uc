class Rx_BuildingAttachment_BeaconPedestal extends Rx_BuildingAttachment implements (Rx_ObjectTooltipInterface)
	placeable;

var() byte TeamNum;
var StaticMeshComponent PedMesh;

event PostBeginPlay()
{
	if(!CheckPedestalSettings())
		Destroy();
}

simulated function Init( Rx_Building_Internals inBuilding, optional name SocketName )
{
	if(CheckPedestalSettings())
		super.Init(inBuilding,SocketName);

	else
		Destroy();
}

reliable server function bool CheckPedestalSettings()
{
	return Rx_Game(WorldInfo.Game).bUsePedestal;
}

reliable server function ServerDetonatePedestal(Rx_Weapon_DeployedBeacon B)
{
	if(!Rx_Game(WorldInfo.Game).bPedestalDetonated)
		Rx_Game(WorldInfo.Game).DetonatePedestal(B);
}

simulated function string GetTooltip(Rx_Controller PC)
{
	if (VSizeSq(PC.Pawn.Location - Location) <= 250000)
	{
		if(PC.GetTeamNum() != GetTeamNum())
			return "Activate a beacon here to destroy the entire base";
		else 
			return "Prevent the enemy team from detonating a superweapon beacon here";
	}

	return "";
}

simulated function byte ScriptGetTeamNum() 
{
	if(OwnerBuilding == None)
		return TeamNum; 
	else
		return Super.ScriptGetTeamNum();
}

simulated function byte GetTeamNum() 
{
	if(OwnerBuilding == None)
		return TeamNum; 
	else
		return Super.GetTeamNum();
}

simulated function String GetHumanReadableName()
{
	return "Beacon Pedestal";
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{

	local Rx_Building B;
//	`log(Self@" : HIT REGISTERED,@"@InstigatedBy.GetHumanReadableName()@"hits me with"@DamageCauser@"with"@DamageCauser.Base@"as a base");

	if(Rx_Weapon_DeployedBeacon(DamageCauser) != None && EventInstigator.GetTeamNum() != GetTeamNum() && DamageCauser.Base == Self)
	{

		ServerDetonatePedestal(Rx_Weapon_DeployedBeacon(DamageCauser));

	

		foreach AllActors(class'Rx_Building', B)
		{
			if(B.GetTeamNum() != GetTeamNum() || Rx_Building_Techbuilding(B) != None)
				continue;	

			B.TakeDamage(900000,EventInstigator,B.Location,Momentum,DamageType,HitInfo,DamageCauser);

		}	

	}
}

simulated function bool IsTouchingOnly()
{
	return false;
}

simulated function bool IsBasicOnly()
{
	return true;
}

// set to -1 since we don't need to see the health of the building it's attached on

simulated function float getBuildingHealthPct()
{
	return -1;
}

simulated function float getBuildingHealthMaxPct()
{
	return -1;
}

simulated function float getBuildingArmorPct()
{
	return -1;
}

defaultproperties
{

	SpawnName     = "_Pedestal"
	SocketPattern = "Pedestal"


	// VISUAL PROPERTIES
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=TRUE
	End Object
	Components.Add(MyLightEnvironment)

	Begin Object Class=StaticMeshComponent Name=PedMeshCmp
		StaticMesh=StaticMesh'RX_Deco_BuildingAssets.StaticMeshes.BuildingAssets_EndGamePedestal'
		CollideActors                = True
		BlockActors                  = True
		BlockRigidBody               = True
		BlockZeroExtent              = True
		BlockNonZeroExtent           = True
		bCastDynamicShadow           = False
		bAcceptsDynamicLights        = True
		bAcceptsLights               = True
		bAcceptsDecalsDuringGameplay = True
		bAcceptsDecals               = True
		RBCollideWithChannels	=(Default=TRUE,BlockingVolume=TRUE)
		LightEnvironment = MyLightEnvironment
		LightingChannels = (bInitialized=True,Dynamic=True,Static=True)
	End Object
	Components.Add(PedMeshCmp)
	PedMesh = PedMeshCmp

	RemoteRole          = ROLE_SimulatedProxy
	bCollideActors      = True
	bBlockActors        = True
	BlockRigidBody      = True
	bWorldGeometry = true
}