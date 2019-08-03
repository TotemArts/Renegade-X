// Custom SeqAct in Kismet for spawning Projectiles in Ren X. Made by j0g32. www.renegade-x.com

class Rx_SeqAct_SpawnProjectile extends SeqAct_Latent; // extends SequenceAction

var() bool	bEnabled;

var() byte	TeamNum;		// Team: 0=GDI, 1=Nod

var() class<Rx_Projectile>  ProjectileClass;	// Type of Weapon that should be fired

var() float FireInterval;	// Fire interval ~ Rate of Fire

var() int	BurstMin;		// min number of shots fired in a burst
var() int	BurstMax;		// max number of shots fired in a burst
var   int	BurstSize;		// actual burst size
var   int	ShotNo;			// curnet shot of burst

var() float BurstDelayMin;	// min time between bursts
var() float BurstDelayMax;	// max time between bursts

var() float FakePercentage; // probability that a shot does not deal damage

var() Actor SpawnPoint;		// Actor to spawn projectiles at
var() Actor TargetPoint;	// Actor that projectiles target

var() float Spread;			// deviation from target

var UTBot DummyController;	// dummy controller who instigates the projectiles to deal damage.	// UTBot appears in Playerlist


event Activated()
{
	if(InputLinks[0].bHasImpulse)		// Start Firing
		Kismet_StartFiring();
	else if(InputLinks[1].bHasImpulse)	// Stop Firing
		Kismet_StopFiring();
	else if(InputLinks[2].bHasImpulse)	// Enable
		bEnabled=true;
	else /*if(InputLinks[2].bHasImpulse)*/	// Disable
		bEnabled=false;
}

/*
event bool Update(float DT)
{
	if(NumActiveSquads<MaxNumSquads)
	return true;
	
	OutputLinks[1].bHasImpulse = true;
	return false;
}
*/


function Kismet_StartFiring()
{
	if (DummyController==None)
		DummyController=GetWorldInfo().Game.Spawn(class'UTBot');
	
	DummyController.SetTeam(TeamNum);
	
	if(bEnabled==true)
		Burst();
	
	// while(bEnabled==true)
	// 	GetWorldInfo().Game.SetTimer(BurstDelayMin + Rand(BurstDelayMax-BurstDelayMin),false,'Burst',self); // iterate firing brusts as long as enabled
}

function Kismet_StopFiring()
{
	GetWorldInfo().Game.ClearTimer('Burst',self);
	GetWorldInfo().Game.ClearTimer('SpawnProjectile',self);
}

function Burst()
{
	
	ShotNo = 0;
	BurstSize = BurstMin + Rand(BurstMax-BurstMin);
	
	Kismet_SpawnProjectile();	// first shot
		
	if(bEnabled==true)	// next burst (must wait for this burst to have finished)
		GetWorldInfo().Game.SetTimer(BurstSize*FireInterval + BurstDelayMin + Rand(BurstDelayMax-BurstDelayMin),false,'Burst',self);	
}


function Kismet_SpawnProjectile()
{
		
	local vector SpawnLoc, TargetLoc;
	local Rx_Projectile Proj;
	
	if (!bEnabled)
		return;
	
	SpawnLoc = Actor(SeqVar_Object(VariableLinks[0].LinkedVariables[0]).GetObjectValue()).Location;
	TargetLoc = Actor(SeqVar_Object(VariableLinks[1].LinkedVariables[0]).GetObjectValue()).Location;
	
	Proj = GetWorldInfo().Game.Spawn(ProjectileClass,,, SpawnLoc);
	
	Proj.InstigatorController = DummyController;	// set the "shooter"
	
	if (FRand()<FakePercentage)
		Proj.Damage=0;
	
	Proj.Init(Normal( (TargetLoc+VRand()*Spread) - SpawnLoc));
	
	ShotNo++;
	
	if (ShotNo<BurstSize)
		GetWorldInfo().Game.SetTimer(FireInterval, false, 'Kismet_SpawnProjectile',self);	// iterated with timer for rate of fire
		
}
		

defaultproperties
{
	ObjName="Spawn Projectile"
	ObjCategory="Ren X"
	
	InputLinks(0)=(LinkDesc="Start Firing")
	InputLinks(1)=(LinkDesc="Stop Firing")
	InputLinks(2)=(LinkDesc="Enable")
	InputLinks(3)=(LinkDesc="Disable")
	
	OutputLinks(0)=(LinkDesc="Out")
	
	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Spawn Point",PropertyName=SpawnPoint,bWriteable=false)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Target Point",PropertyName=TargetPoint,bWriteable=false)
	
	bCallHandler=false
	bAutoActivateOutputLinks=false
	
	bEnabled=true

	FireInterval=0.1
	BurstMin=1
	BurstMax=10
	
	BurstDelayMin=1
	BurstDelayMax=10

	FakePercentage=0

	Spread=64

}
