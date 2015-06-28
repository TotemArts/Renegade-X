class Rx_Building_Refinery extends Rx_Building
   abstract;

var private repnotify bool bDocking;
var private Rx_Vehicle_HarvesterController DockedHarvester;
var private float CreditsToDump;
var private float CreditTickTimer;

var SoundCue 				CreditFlowSound;


var private SkeletalMeshComponent DockingMesh, GarageDoorMesh;
var AnimNode                      AnNodeDockStation, AnNodeDoor;

var(RenX_Refinery) float HarvesterUnloadTime;
var(RenX_Refinery) float HarvesterHarvestTime;
var(RenX_Refinery) float HarvesterCreditDump;
var(RenX_Refinery) float CreditTickRate;
var(RenX_Refinery) float CreditsPerTick;

replication
{
	if ( bNetDirty && Role == ROLE_Authority )
		bDocking, DockedHarvester;
}

simulated event ReplicatedEvent( name VarName )
{
	if ( VarName == 'bDocking' )
	{
		if (bDocking == true)
			StartHarvesterUnloading();
		else 
			HarvesterFinishedUnloading();
	}
	else
		super.ReplicatedEvent(VarName);
}


simulated function String GetHumanReadableName()
{
	return "Refinery";
}

simulated function TickBuilding(float DeltaTime)
{
	local float TickCreditsDump;

	super.TickBuilding(DeltaTime);


	// Credit dumping
	if (CreditsToDump > 0 && bDocking == true )
	{
		TickCreditsDump = fmin( (HarvesterCreditDump / HarvesterUnloadTime) * DeltaTime  , CreditsToDump);
		CreditsToDump -= TickCreditsDump;
		GiveTeamCredits(TickCreditsDump);
	}
	else if (CreditsToDump <= 0 && bDocking == true)
	{
		HarvesterFinishedUnloading();
	}

	// Credit ticking
	CreditTickTimer -= DeltaTime;

	if (CreditTickTimer <= 0)
	{
		if (IsDestroyed())
			GiveTeamCredits(CreditsPerTick/4);
		else
			GiveTeamCredits(CreditsPerTick);	
		CreditTickTimer = CreditTickRate;
	}
	
	if (IsDestroyed())
	{
		if (bDocking == true)
		{
			HarvesterFinishedUnloading();
		}
	}
}

simulated function HarvesterDocked(Rx_Vehicle_HarvesterController HarvesterController)
{
	if (bDocking == false)
	{
		bDocking = true;
		DockedHarvester = HarvesterController;
		StartHarvesterUnloading();
	}
}

simulated function StartHarvesterUnloading()
{
	CreditsToDump = HarvesterCreditDump;
	StartCreditsFlowSound();
}

simulated function HarvesterFinishedUnloading()
{
	bDocking = false;
	StopCreditsFlowSound();
	if (DockedHarvester != none)
		DockedHarvester.GotoTib();
	DockedHarvester = none;
}

simulated function GiveTeamCredits(float Credits) 
{
	local PlayerReplicationInfo pri;
	local int i;

	for (i=0;i<WorldInfo.GRI.PRIArray.Length;i++)
	{
		pri = WorldInfo.GRI.PRIArray[i];
		if(Rx_PRI(pri) != None && pri.GetTeamNum() == self.GetTeamNum())
		{
			Rx_PRI(pri).addCredits(Credits);
		}
	}
}

simulated function StartCreditsFlowSound()
{
    local PlayerController LocalPC;
    
    foreach LocalPlayerControllers(class'PlayerController', LocalPC) {
    	 if(LocalPC.GetTeamNum() == GetTeamNum())
    	 {
         	LocalPC.PlaySound(CreditFlowSound, TRUE, FALSE, FALSE);
    	 }
    }	
}

simulated function StopCreditsFlowSound()
{
	local AudioComponent AC, CheckAC;
	local PlayerController LocalPC;
	

    foreach LocalPlayerControllers(class'PlayerController', LocalPC) {
		foreach LocalPC.AllOwnedComponents(class'AudioComponent',CheckAC)
		{
			if (CheckAC.SoundCue == CreditFlowSound && (LocalPC.GetTeamNum() == GetTeamNum()))
			{
				AC = CheckAC;
				break;
			}
		}
		if (AC != None)
		{
			AC.Stop();
		}
	}
}

event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	super.TakeDamage(DamageAmount,EventInstigator,HitLocation,Momentum,DamageType,HitInfo,DamageCauser);
}

defaultproperties
{	
	bDocking = false
	CreditsToDump = 0
	CreditTickTimer = 0

	CreditTickRate = 1.0f
	CreditsPerTick = 2.0f
	HarvesterCreditDump = 300.0f
	HarvesterUnloadTime = 10.0f
	HarvesterHarvestTime = 15.0f
	CreditFlowSound=SoundCue'RX_SoundEffects.SFX.SC_Credit_Flow'

	
	//HarvUnloadTime             = 10.0f
   
	Begin Object Name=Static_Interior_Complex
		StaticMesh=StaticMesh'RX_BU_Refinery.Mesh.SM_Ref_Interior_Complex'
	End Object

	/***************************************************/
	/*             Point Light Components              */
	/***************************************************/
	Begin Object Name=PointLightComponent1
		Translation = (X=-87,Y=790,Z=40)
		Radius = 500.0
	End Object
	PointLightComponents.Add(PointLightComponent1)
	Components.Add(PointLightComponent1)

	Begin Object Name=PointLightComponent2
		Translation = (X=-87,Y=460,Z=40)
		Radius = 500.0
	End Object
	PointLightComponents.Add(PointLightComponent2)
	Components.Add(PointLightComponent2)

	Begin Object Name=PointLightComponent3
		Translation = (X=-87,Y=-87,Z=40)
		Radius = 500.0
	End Object
	PointLightComponents.Add(PointLightComponent3)
	Components.Add(PointLightComponent3)

	Begin Object Name=PointLightComponent4
		Translation = (X=350,Y=730,Z=0)
		Radius = 500.0
		FalloffExponent = 2.0
		Brightness = 200.0
		LightColor = (B=0,G=128,R=255,A=0)
	End Object
	PointLightComponents.Add(PointLightComponent4)
	Components.Add(PointLightComponent4)

	Begin Object Name=PointLightComponent5
		Translation = (X=175,Y=902,Z=-120)
		Radius = 50.0
		Brightness = 3.0
		LightColor = (B=0,G=255,R=0,A=0)
		LightmassSettings = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=8)
	End Object
	PointLightComponents.Add(PointLightComponent5)
	Components.Add(PointLightComponent5)

	Begin Object Name=PointLightComponent6
		Translation = (X=200,Y=950,Z=-120)
		Radius = 50.0
		Brightness = 3.0
		LightColor = (B=0,G=255,R=0,A=0)
		LightmassSettings = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=8)
	End Object
	PointLightComponents.Add(PointLightComponent6)
	Components.Add(PointLightComponent6)

	Begin Object Name=PointLightComponent7
		Translation = (X=200,Y=845,Z=-120)
		Radius = 50.0
		Brightness = 3.0
		LightColor = (B=0,G=255,R=0,A=0)
		LightmassSettings = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=8)
	End Object
	PointLightComponents.Add(PointLightComponent7)
	Components.Add(PointLightComponent7)

	Begin Object Name=PointLightComponent8
		Translation = (X=300,Y=845,Z=-120)
		Radius = 50.0
		Brightness = 3.0
		LightColor = (B=0,G=255,R=0,A=0)
		LightmassSettings = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=8)
	End Object
	PointLightComponents.Add(PointLightComponent8)
	Components.Add(PointLightComponent8)

	Begin Object Name=PointLightComponent9
		Translation = (X=300,Y=950,Z=-120)
		Radius = 50.0
		Brightness = 3.0
		LightColor = (B=0,G=255,R=0,A=0)
	End Object
	PointLightComponents.Add(PointLightComponent9)
	Components.Add(PointLightComponent9)

	Begin Object Name=PointLightComponent10
		Translation = (X=400,Y=950,Z=-120)
		Radius = 50.0
		Brightness = 3.0
		LightColor = (B=0,G=255,R=0,A=0)
	End Object
	PointLightComponents.Add(PointLightComponent10)
	Components.Add(PointLightComponent10)

	Begin Object Name=PointLightComponent11
		Translation = (X=400,Y=845,Z=-120)
		Radius = 50.0
		Brightness = 3.0
		LightColor = (B=0,G=255,R=0,A=0)
	End Object
	PointLightComponents.Add(PointLightComponent11)
	Components.Add(PointLightComponent11)
	
	Begin Object Name=PointLightComponent12
		Translation = (X=47,Y=40,Z=1450)
		Radius = 200.0
		FalloffExponent = 2.0
		Brightness = 5.0
		LightColor = (B=158,G=235,R=255,A=0)
	End Object
	PointLightComponents.Add(PointLightComponent12)
	Components.Add(PointLightComponent12)
	
	Begin Object Name=PointLightComponent13
		Translation = (X=47,Y=283,Z=1450)
		Radius = 200.0
		FalloffExponent = 2.0
		Brightness = 5.0
		LightColor = (B=158,G=235,R=255,A=0)
	End Object
	PointLightComponents.Add(PointLightComponent13)
	Components.Add(PointLightComponent13)
	
	Begin Object Name=PointLightComponent14
		Translation = (X=-370,Y=-675,Z=325)
		Radius = 400.0
		FalloffExponent = 2.0
		Brightness = 3.0
		LightColor = (B=0,G=255,R=0,A=0)
		LightmassSettings = (IndirectLightingScale=1,IndirectLightingSaturation=1,ShadowExponent=2,LightSourceRadius=128)
	End Object
	PointLightComponents.Add(PointLightComponent14)
	Components.Add(PointLightComponent14)

	/***************************************************/
	/*              Spot Light Components              */
	/***************************************************/
	Begin Object Name=SpotLightComponent1
		Translation = (X=-198.0,Y=958.0,Z=-69.0)
		Rotation    = (Pitch=0,Yaw=-16384,Roll=0)
	End Object

	Begin Object Name=SpotLightComponent2
		Translation = (X=31.0,Y=958.0,Z=-69.0)
		Rotation    = (Pitch=0,Yaw=-16384,Roll=0)
	End Object

	Begin Object Name=SpotLightComponent3
		Translation = (X=-63.00,Y=161.0,Z=-69.0)
		Rotation    = (Pitch=0,Yaw=0,Roll=0)
	End Object

	Begin Object Name=SpotLightComponent4
		Translation = (X=-207.0,Y=292.0,Z=-71.0)
		Rotation    = (Pitch=1638,Yaw=16384,Roll=0)
	End Object

	Begin Object Name=SpotLightComponent5
		Translation = (X=-403,Y=582,Z=25)
		Rotation    = (Pitch=-16384,Yaw=0,Roll=0)
		LightColor  = (B=242,G=250,R=255,A=0)
		Brightness = 6.0
		InnerConeAngle = 45.0
		OuterConeAngle = 60.0
	End Object
	Components.Add(SpotLightComponent5)
	SpotLightComponents.Add(SpotLightComponent5)

	/*Begin Object Class=SkeletalMeshComponent Name=DockingStation
		SkeletalMesh=SkeletalMesh'RX_BU_Refinery.Mesh.SK_BU_Ref_DockStation'
		AnimSets(0)=AnimSet'RX_BU_Refinery.Anims.AS_Ref_DockingStation'
	End Object

	Begin Object Class=SkeletalMeshComponent Name=GarageMesh
		SkeletalMesh=SkeletalMesh'RX_BU_Refinery.Mesh.SK_BU_Ref_GarageDoor'
		AnimSets(0)=AnimSet'RX_BU_Refinery.Anims.AS_Ref_GarageDoor' 
		//AnimTreeTemplate=AnimTree'BU_RenX_AirStrip.Anim.AT_BU_AirTrower'
	End Object

	DockingMesh = DockingStation
	GarageDoorMesh = GarageMesh

	*/
}