class Rx_Building_RepairFacility_Internals extends Rx_Building_Team_Internals;

var repnotify bool bStartEmitter;
var private name ActiveAnimName, EmitterBoneName;
var private ParticleSystem RepairJetsTemplate;
var private array<UTParticleSystemComponent> RepairJets;
var private UTParticleSystemComponent RepairJet1, RepairJet2, RepairJet3, RepairJet4;
var private AudioComponent RepairStartAC, RepairOnAC, RepairStopAC;
var private bool bStopping, bStarting; // Vars to fix single player animations
var private SoundCue RepairStart, RepairOn, RepairStop;
var(RenX_Buildings) int RepairRate; // The amount of healing per 0.1 seconds. (RepairRate * 10 = repair per second)
var(RenX_Buildings) int RepairDistance; // How far the repair pad will repair from the center (don't change unless you scale it for some reason)
var private bool IgnoreHiddenCollidingActors;

replication
{
	if (bNetDirty && Role == Role_Authority)
		bStartEmitter;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bStartEmitter')
	{
		if (bStartEmitter)
			StartRepairPadVisuals();
		else
			StopRepairPadVisuals();
	}
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetupAttachments();

	// Start our repairpad tick
	SetTimer(0.1f, true, nameof(RepairPadTick));
}

function RepairPadTick()
{
	local UTVehicle thisVehicle;
	local int count;
	local vector thisLocation;

	// Is this repairpad dead?
	if (IsDestroyed())
	{
		ClearTimer(nameof(RepairPadTick)); // Stop the timer
		return;
	}
	
	thisLocation = BuildingVisuals.Location;
	thisLocation.Z += 50.0f;

	ForEach `WorldInfoObject.AllActors(class'UTVehicle', thisVehicle) //thisVehicle, RepairDistance, thisLocation, IgnoreHiddenCollidingActors)
	{
		if (!IsValidVehicle(thisVehicle) || VSize(thisVehicle.Location - thisLocation) > RepairDistance) continue;

		if (thisVehicle.Health < thisVehicle.HealthMax)
		{
			thisVehicle.HealDamage(RepairRate, thisVehicle.Controller, class'Rx_DmgType_RepairFacility');

			if(`WorldInfoObject.NetMode == NM_DedicatedServer)
				StartRepairPadVisualsServer();
			else if(!bStarting)
			{
				bStopping = false; 
				bStarting = true;
				StartRepairPadVisuals();
			}
			count++;
		}
	}

	if (count == 0)
	{
		if (`WorldInfoObject.NetMode == NM_DedicatedServer)
			StopRepairPadVisualsServer();
		else if (!bStopping)
		{
			StopRepairPadVisuals();
			bStopping = true;
			bStarting = false;
		}
	}
}

function bool IsValidVehicle(UTVehicle thisVehicle)
{
	if (thisVehicle.Driver != None)
		if (Rx_Pawn(thisVehicle.Driver) != None || Rx_PRI(thisVehicle.PlayerReplicationInfo) != None)
			if (thisVehicle.Driver.GetTeamNum() == TeamID)
				return true;

	// Invalid vehicle on pad
	return false;
}


function StartRepairPadVisualsServer()
{
	bStartEmitter = true;
}

function StopRepairPadVisualsServer()
{
	bStartEmitter = false;
}

simulated function StartRepairPadVisuals()
{
	PlaySpinup1();
	ClearTimer(nameof(PlaySpindown1));
	ClearTimer(nameof(PlaySpindown2));
	ClearTimer(nameof(PlaySpindown3));
	ClearTimer(nameof(PlaySpindown4));
	ClearTimer(nameof(PlaySpindown5));
	ClearTimer(nameof(PlaySpindown6));
	ClearTimer(nameof(PlaySpindown7));
	ClearTimer(nameof(HaltSpin));
}

simulated function StopRepairPadVisuals()
{
	PlaySpindown1();
	ClearTimer(nameof(PlaySpinup1));
	ClearTimer(nameof(PlaySpinup2));
	ClearTimer(nameof(PlaySpinup3));
	ClearTimer(nameof(PlaySpinup4));
}

simulated function PlayDestructionAnimation()
{
	local UTParticleSystemComponent PS;

	bStartEmitter = false;

	if (`WorldInfoObject.NetMode != NM_DedicatedServer)
		ForEach RepairJets(PS)
			PS.KillParticlesForced();
}

////////////////	Spin up		////////////////

simulated function PlaySpinup1()
{
	local UTParticleSystemComponent PS;

	BuildingSkeleton.PlayAnim(ActiveAnimName, 5.0f, true, false);
	SetTimer(0.75f, false, 'PlaySpinup2');

	if (`WorldInfoObject.NetMode != NM_DedicatedServer)
		ForEach RepairJets(PS)
			PS.ActivateSystem();

	RepairStartAC.Play();
	RepairOnAC.Play();
}

simulated function PlaySpinup2()
{
	BuildingSkeleton.PlayAnim(ActiveAnimName, 4.2f, true, false);
	SetTimer(1.0f, false, 'PlaySpinup3');
}

simulated function PlaySpinup3()
{
	BuildingSkeleton.PlayAnim(ActiveAnimName, 3.4f, true, false);
	SetTimer(1.25f, false, 'PlaySpinup4');
}

simulated function PlaySpinup4()
{
	BuildingSkeleton.PlayAnim(ActiveAnimName, 2.3f, true, false);
	SetTimer(1.5f, false, 'PlaySpinup5');
}

simulated function PlaySpinup5()
{
	BuildingSkeleton.PlayAnim(ActiveAnimName,, true, false);
}

////////////////	Spin down	 ////////////////

simulated function PlaySpindown1()
{
	BuildingSkeleton.PlayAnim(ActiveAnimName,, true, false);
	SetTimer(1.5f, false, 'PlaySpindown2');

	RepairStopAC.Play();

	RepairStartAC.Stop();
	RepairOnAC.Stop();
}

simulated function PlaySpindown2()
{
	BuildingSkeleton.PlayAnim(ActiveAnimName, 2.3f, true, false);
	SetTimer(1.25f, false, 'PlaySpindown3');
}

simulated function PlaySpindown3()
{
	BuildingSkeleton.PlayAnim(ActiveAnimName, 3.4f, true, false);
	SetTimer(1.0f, false, 'PlaySpindown4');
}

simulated function PlaySpindown4()
{
	BuildingSkeleton.PlayAnim(ActiveAnimName, 4.2f, true, false);
	SetTimer(0.75f, false, 'PlaySpindown5');
}

simulated function PlaySpindown5()
{
	BuildingSkeleton.PlayAnim(ActiveAnimName, 5.0f, true, false);
	SetTimer(0.5f, false, 'PlaySpindown6');
}

simulated function PlaySpindown6()
{
	BuildingSkeleton.PlayAnim(ActiveAnimName, 10.0f, true, false);
	SetTimer(1.0f, false, 'PlaySpindown7');
}

simulated function PlaySpindown7()
{
	local UTParticleSystemComponent PS;

	if (`WorldInfoObject.NetMode != NM_DedicatedServer)
		ForEach RepairJets(PS)
			PS.DeactivateSystem();

	BuildingSkeleton.PlayAnim(ActiveAnimName, 15.0f, true, false);
	SetTimer(1.0f, false, 'PlaySpindown8');
}

simulated function PlaySpindown8()
{
	BuildingSkeleton.PlayAnim(ActiveAnimName, 20.0f, true, false);
	SetTimer(1.0f, false, 'PlaySpindown9');
}

simulated function PlaySpindown9()
{
	BuildingSkeleton.PlayAnim(ActiveAnimName, 100000.0f, true, false); // A really hacky way of making the repair pad animation not jumpy.
	//SetTimer(1.0f, false, 'HaltSpin');
}

simulated function HaltSpin()
{
	BuildingSkeleton.StopAnim();
}

simulated function SetupAttachments()
{
	local UTParticleSystemComponent PS;
	local SkeletalMeshSocket BeamTarget;

	if (`WorldInfoObject.NetMode == NM_DedicatedServer)
		return;

	RepairStartAC = CreateAudioComponent(RepairStart, false, true, true);
	RepairOnAC =  CreateAudioComponent(RepairOn, false, true, true);
	RepairStopAC =  CreateAudioComponent(RepairStop, false, true, true);

	if (BuildingSkeleton != none)
	{
		RepairJet1 = new(Outer) class'UTParticleSystemComponent';
		RepairJet1.bAutoActivate = false;
		BuildingSkeleton.AttachComponentToSocket(RepairJet1, 'RepairEmitterSocket1');
		RepairJets.AddItem(RepairJet1);

		RepairJet2 = new(Outer) class'UTParticleSystemComponent';
		RepairJet2.bAutoActivate = false;
		BuildingSkeleton.AttachComponentToSocket(RepairJet2, 'RepairEmitterSocket2');
		RepairJets.AddItem(RepairJet2);

		RepairJet3 = new(Outer) class'UTParticleSystemComponent';
		RepairJet3.bAutoActivate = false;
		BuildingSkeleton.AttachComponentToSocket(RepairJet3, 'RepairEmitterSocket3');
		RepairJets.AddItem(RepairJet3);

		RepairJet4 = new(Outer) class'UTParticleSystemComponent';
		RepairJet4.bAutoActivate = false;
		BuildingSkeleton.AttachComponentToSocket(RepairJet4, 'RepairEmitterSocket4');
		RepairJets.AddItem(RepairJet4);

		BeamTarget = BuildingSkeleton.GetSocketByName('RepairBeam');

		ForEach RepairJets(PS)
		{
			PS.SetTemplate(RepairJetsTemplate);
			if (BeamTarget != None)
			{
				PS.SetBeamEndPoint(0, BeamTarget.RelativeLocation);
				PS.SetBeamEndPoint(1, BeamTarget.RelativeLocation);
				PS.SetBeamEndPoint(2, BeamTarget.RelativeLocation);
			}
		}
	}
}

DefaultProperties
{
	Begin Object Name=BuildingSkeletalMeshComponent
    	SkeletalMesh = SkeletalMesh'RX_BU_RepairPad.Mesh.SK_RepairPad'
    	PhysicsAsset = PhysicsAsset'RX_BU_Refinery.Mesh.SK_BU_Refinery_Physics'
    	AnimSets(0)  = AnimSet'RX_BU_RepairPad.Anims.AS_BU_RepairPad'
    End Object

    RepairStart = none
	RepairOn = SoundCue'RX_BU_RepairPad.Sounds.SC_RepairPad_Idle'
	RepairStop = none
    
    ActiveAnimName     = "Active"
    EmitterBoneName    = "b_Emitters"
    RepairJetsTemplate = ParticleSystem'RX_BU_RepairPad.Effects.P_Repair_Beam'

    // The distance to check for applicable vehicles to be repaired on each pad
	RepairDistance = 300

	// How much HP to repair the vehicle per 0.1 second when power is online. RepairRate * 10 = Repair Per Second
	RepairRate = 50

	// Ignore this, do not change
	IgnoreHiddenCollidingActors = true
}