class Rx_SupportVehicle_ReinforcementChinook extends Rx_SupportVehicle_DropOffChinook;

var int SpawnedTroops;
var Array<class<Rx_FamilyInfo> >  InfClasses;
var Vector DropLoc;
var Rotator DropRot;

simulated function DropPayload()
{ 
	//Mesh.GetSocketWorldLocationAndRotation(PayLoadSocketName, SocketLocation, SocketRotation);
	Mesh.GetSocketWorldLocationAndRotation(PayLoadSocketName, DropLoc, DropRot);	
	SetTimer(0.5,True,'SpawnTroops');	
	SetTimer(4.0, false, 'CancelSpawnTroops');
	/**if (WorldInfo.NetMode != NM_DedicatedServer)
		SetTimer(4.0,false,'MyAudioComponentFadeOut');*/
}

simulated function bool CheckSpace(vector CheckPos,out vector SpawnPos)
{	
	local Vector HitLocation,HitNormal, StartTrace;
	local Rotator DummyRot;


	Mesh.GetSocketWorldLocationAndRotation('CamView1P', StartTrace, DummyRot);	
	if(Trace(HitLocation,HitNormal,CheckPos,StartTrace) == None)
	{
		DropRot = Rotation;
		DropRot.yaw = Rotation.yaw + 16384.0;
		SpawnPos = CheckPos;
		return true;
	}
	else
	{
		SpawnPos = CheckPos;
		SpawnPos.X -= 384.0;
		DropRot = Rotation;
		DropRot.yaw = Rotation.yaw - 16384.0;

		if(Trace(HitLocation,HitNormal,SpawnPos,StartTrace) == None)
			return true;
	}
	
	return false;
}

simulated function SpawnTroops()
{
	local Rx_Bot_Scripted B;
	local Rx_Pawn_Scripted P;
	local Rx_TeamAI TeamAI;
	local int i;
	local Vector SpawnPoint;

	if(SpawnedTroops >= InfClasses.Length || InfClasses.Length <= 0)
	{
		ClearTimer('SpawnTroops');
		return;
	}

	if(Rx_Game(WorldInfo.Game) != none) 
		TeamAI = Rx_TeamAI(Rx_Game(WorldInfo.Game).Teams[ScriptGetTeamNum()].AI);

	else
	{
		ClearTimer('SpawnTroops');
		return;
	}

	if(CheckSpace(DropLoc,SpawnPoint))
		P = Spawn(class'Rx_Pawn_Scripted',,,SpawnPoint,DropRot);

	if(P == None)
		return;

	P.TeamNum = ScriptGetTeamNum();
	B = Spawn(class'Rx_Bot_Scripted');
	Rx_Game(WorldInfo.Game).SetTeam(B, Rx_Game(WorldInfo.Game).Teams[ScriptGetTeamNum()], false);
	B.Possess(P,false);

	i = SpawnedTroops;
	B.SetChar(InfClasses[i], InfClasses[i].default.BasePurchaseCost <= 0);


	if(TeamAI.ScriptedSquads == None || TeamAI.ScriptedSquads.Size > 8)
	{
		TeamAI.AddSquadWithLeader(B,None);
	}
	else
		TeamAI.ScriptedSquads.AddBot(B);

	B.UpdateModifiedStats();
	B.Skill = WorldInfo.Game.GameDifficulty;
	B.ResetSkill();
	B.Enemy = None;
	SpawnedTroops++;
	P.GoToState('RopeDownChinook');
}

simulated function CancelSpawnTroops()
{
	if(IsTimerActive('SpawnTroops'))
		ClearTimer('SpawnTroops');
}

simulated function InitialSetup()
{

	SetTimer(2.0,false,'InitMyAudioComponent');		
	Mesh.PlayAnim('AirDrop',,false,false,CurrentTime);	
	SetTimer(14.5,false,'DropPayload');	
	//if(ROLE == ROLE_Authority) SetTimer(5.0,true,'LocTest'); 
	if(WorldInfo.NetMode != NM_DedicatedServer)
		SetHidden(false);
	
	
	SetCollision(true,true);
	

}

simulated function Explosion(optional Controller EventInstigator)
{
	super(Rx_SupportVehicle_Air).Explosion(); 
	
}

simulated function ClientAttachPayload() //Also attach your mask locally
{
	local Actor 	CA; 
	local vector	SocketLocation, RootSocketLocation;
	local rotator	SocketRotation, RootSocketRotation;
	
	
	super(Rx_SupportVehicle_Air).ClientAttachPayload();
	
	if(WorldInfo.NetMode != NM_DedicatedServer)
	{	
	//Just use some logic here for clients
		Mesh.GetSocketWorldLocationAndRotation(PayLoadSocketName, SocketLocation, SocketRotation);
		Mesh.GetSocketWorldLocationAndRotation(RootSocketName, RootSocketLocation, RootSocketRotation);
		
	
			//Attach Mask
			foreach CollidingActors(class'Actor', CA, 100, RootSocketLocation, false)
			{
				//`log("-----Actor------: " @ CA @ VSize(CA.location-SocketLocation) $ "Units"); 
				if(CA == Self || Rx_SupportVehicle_DropOffChinook_Mask(CA) == none) 
				{
				//`log("Skipping :" @ CA);
				continue; 	
				}
				
				//`log("-----Actor Found------: " @ CA); 
				Mask=Rx_SupportVehicle_DropOffChinook_Mask(CA); 
				Mask.SetPhysics(PHYS_NONE);
				Mask.SetHidden(false); 
				Mask.SetBase(none); 
				Mask.SetHardAttach(true); 
				Mask.SetBase(self,,Mesh,RootSocketName); 
				Mask.bNetDirty = true; 
				break; 
			}
			
	}	
}

function CallForceDetach(bool bKillVehicle, Controller EventInstigator)
{
	super.CallForceDetach(bKillVehicle, EventInstigator);
	DropPayload(); 
}

//We're just a big animation. Attach our sound component to the root socket so it follows the animation
simulated function AttachSoundComponent()
{
	Mesh.AttachComponentToSocket(MyAudioComponent, RootSocketName);
}

simulated function vector GetAdjustedLocation()
{
	local vector	SocketLocation;
	local rotator	SocketRotation;
	
	Mesh.GetSocketWorldLocationAndRotation(RootSocketName, SocketLocation, SocketRotation);	
	
	return SocketLocation; 
}

function Initialize(Controller C, byte TI, vector V, Rx_CommanderSupportBeacon P, optional class<Actor> PayloadActorClass, optional int MaxRecoverableCP)
{
		ParentBeacon = P; 
		TargetVector = V;
		TeamIndex = TI;
		InstigatorController=C;
		
		if(class<Rx_CommanderSupport_ReinforcementContainer>(PayloadActorClass) != none) 
		{
			InfClasses = class<Rx_CommanderSupport_ReinforcementContainer>(PayloadActorClass).Static.GetInfClasses(TI);
		}
		SetCollision(true,true);
		
		if(bUseInitializationVector) 
			SetTimer(TimeToMoveToRelativeVector, false, 'MoveToRelativeInitVector') ; 
		
		if(EntrySound != none) PlaySound(EntrySound); 
		
		if(MaxRecoverableCP > 0) MaxEffectivenessCPRecoup = MaxRecoverableCP; 

}

DefaultProperties
{
	PayLoadSocketName = ScriptedBotSpawnPoint
}
