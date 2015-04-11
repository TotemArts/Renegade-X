class Rx_Building_Refinery_Internals extends Rx_Building_Team_Internals;

var private name IdleAnimName;
var repnotify bool PlayIdleAnim;

replication
{
	if (bNetDirty && Role == ROLE_Authority)
		PlayIdleAnim;
}

simulated event ReplicatedEvent( name VarName )
{
	if (VarName == 'PlayIdleAnim')
	{
		ToggleIdleAnimation();
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated function Init(Rx_Building Visuals, bool isDebug )
{
	super.Init(Visuals, isDebug);
	if(WorldInfo.Netmode != NM_Client) {
		PlayIdleAnim = True;
		ToggleIdleAnimation();
	}
}

function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser) 
{
	local UTVehicle harv;
	
	super.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
	
	if(GetHealth() <= 0) 
	{
		ForEach DynamicActors(class'UTVehicle',harv)
		{
			if ( Rx_Vehicle_Harvester(harv) != None && harv.GetTeamNum() == GetTeamNum() )
			{
				harv.TakeDamage(10000,None,vect(0,0,0),vect(0,0,0),class'Rx_DmgType');
				break;
			}
		}
		if(GetTeamNum() == TEAM_GDI) {
			Rx_Game(WorldInfo.Game).GetVehicleManager().SetGDIRefDestroyed(true);
		} else {
			Rx_Game(WorldInfo.Game).GetVehicleManager().SetNodRefDestroyed(true);
		}		
	}
}

simulated function ToggleIdleAnimation()
{
	if(PlayIdleAnim)
	{
		BuildingSkeleton.PlayAnim(IdleAnimName,,True);
	}
	else
	{
		BuildingSkeleton.StopAnim();
	}
}


DefaultProperties
{
	Begin Object Name=BuildingSkeletalMeshComponent
		SkeletalMesh = SkeletalMesh'RX_BU_Refinery.Mesh.SK_BU_Refinery'
		AnimSets(0)  = AnimSet'RX_BU_Refinery.Anims.AS_BU_Refinery'
		PhysicsAsset = PhysicsAsset'RX_BU_Refinery.Mesh.SK_BU_Refinery_Physics'
	End Object
	
	IdleAnimName    = "PumpIdle"
	
	AttachmentClasses.Add(Rx_BuildingAttachment_RefGarageDoor)
	AttachmentClasses.Add(Rx_BuildingAttachment_RefDockingStation)
}
