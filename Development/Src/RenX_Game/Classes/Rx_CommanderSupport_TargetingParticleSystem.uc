class Rx_CommanderSupport_TargetingParticleSystem extends Actor; 

var	ParticleSystemComponent	Line1, BaseDecal; 
var Rx_Controller				LinkedController ; 
var rotator					CurrentLineRotator; 
var int						CurrentLineLength; 
var vector					CurrentLineVector; 
var class<Rx_CommanderSupport_BeaconInfo> CurrentInfo; 
var	color					GoodColor,BadColor; 
var vector					CurrentEntryVector;
var int						MaxSpotRange; 
var float					TestNum; 

function ActivatePS()
{
	//Line1.SetColorParameter('BeamColor', BadColor);
	Line1.ActivateSystem();
	BaseDecal.ActivateSystem();
	SetTimer(0.1,true,'UpdateColour');
}

function DeactivatePS()
{
	Line1.DeactivateSystem();
	BaseDecal.DeactivateSystem();
}

function SetLine1(vector EndPoint)
{
	Line1.SetVectorParameter('BeamEnd', EndPoint);
	CurrentEntryVector = EndPoint;
}

function UpdateColour()
{
	local vector ZAdjustedLocation ; 
	
	if(CurrentInfo == none || (LinkedController.GetHUDAimingAtSomething() == false && MaxSpotRange > 0))
	{
		return; 	
	}
	
	ZAdjustedLocation = location;
	
	ZAdjustedLocation.Z = ZAdjustedLocation.Z+CurrentInfo.default.EntryAngleStartLocation.Z;
	
	//This is probably excessive... probably. 
	if(!FastTrace(ZAdjustedLocation, CurrentEntryVector) || !LinkedController.SufficientVerticalSpace(location, CurrentInfo.default.VerticalClearanceNeeded) )
	{
		DeactivatePS(); 
		Line1.ClearParameter('BeamColor');
		Line1.SetColorParameter('BeamColor', BadColor);
		ActivatePS();	
	}
	else
	{
		DeactivatePS(); 
		Line1.ClearParameter('BeamColor');
		Line1.SetColorParameter('BeamColor', GoodColor);
		ActivatePS();	
	}	
	
}

function Tick(float DeltaTime)
{
	local rotator Flat; //Keep me constantly flat so my trajectory judgement isn't off 
	local vector  UpdatedLocation; 
	
	super.Tick(DeltaTime);
	
	if(LinkedController == none)
		{
			Destroy();
			return; 
		}
	
	if(MaxSpotRange > 0)
	{
		if(LinkedController.GetHUDAimingAtSomething() == false) //Looking too far away to be of use 
		{
			DeactivatePS();
			return; 
		}
		
		UpdatedLocation = LinkedController.GetHUDAim();
		
		SetLocation(UpdatedLocation); 
	}
	else //Cast on top of the caster
	{
		UpdatedLocation = LinkedController.Pawn.location;
		
		SetLocation(UpdatedLocation); 
	}
	
		Flat = LinkedController.rotation;
		
		Flat.Pitch	= 0; 
		Flat.Roll	= 0;
		
		SetRotation(Flat); 
		
		if(CurrentInfo != none)
		{
			CurrentLineVector = CurrentInfo.static.GetEntryVector(location, rotation); 
			SetLine1(CurrentLineVector);	
		}
	
	
	
}

function InitLink(Rx_Controller MyController)
{
	local rotator Flat;
	LinkedController = MyController; 
	Flat.Yaw=rotation.Yaw; 
	SetRotation(Flat); 
	DeactivatePS();
	
}

function SetBeaconInfo(class<Rx_CommanderSupport_BeaconInfo> Info)
{
	CurrentInfo = Info ;
	BaseDecal.SetScale((CurrentInfo.default.AOE_Radius*1.0)/500.0); //1500 is the base radius of the particle system (May need to fine tune in game though) 
	MaxSpotRange = CurrentInfo.default.MaxCastRange;
	
	if(MaxSpotRange == 0)
	{
		BaseDecal.SetDepthPriorityGroup(SDPG_World);
		Line1.SetDepthPriorityGroup(SDPG_World);
	}
	else
	{
		BaseDecal.SetDepthPriorityGroup(SDPG_Foreground);
		Line1.SetDepthPriorityGroup(SDPG_Foreground);
	}
}

function ClearInfo()
{
	CurrentInfo = none; 
	DeactivatePS();
}

DefaultProperties
{

RemoteRole=ROLE_None


	
	Begin Object Class=ParticleSystemComponent Name=ParticleComp1
		Template=ParticleSystem'RX_WP_Binoculars.Beams.P_SupportPower_Beam'
		bAutoActivate=false
		DepthPriorityGroup=SDPG_Foreground
	End Object
	Components.Add(ParticleComp1)
	Line1=ParticleComp1
	
	
	Begin Object Class=ParticleSystemComponent Name=ParticleComp3
		Template=ParticleSystem'RX_WP_Binoculars.Beams.P_Airstrike_Target_Paint_Nod'
		bAutoActivate=false
		DepthPriorityGroup=SDPG_Foreground
	End Object
	Components.Add(ParticleComp3)
	BaseDecal=ParticleComp3
	
	GoodColor = (R=0, G=255, B=0, A= 255)
	
	BadColor = (R=255, G=0, B=0, A= 255)

	TestNum=1.0
}