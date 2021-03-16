class Rx_BuildingAttachment_PT extends Rx_BuildingAttachment implements (Rx_ObjectTooltipInterface)
	placeable;

var() TEAM                    TeamNum;
var CylinderComponent       CollisionCylinder;
var StaticMeshComponent PTMesh;
var() bool bAccessable;
var() string tooltip;
var() string ReadName;

replication
{
	if(bNetDirty && Role == ROLE_Authority)
		TeamNum, tooltip, bAccessable, ReadName;
}

simulated function string GetTooltip(Rx_Controller PC)
{
	if (Rx_Pawn(PC.Pawn) != None && PC.GetTeamNum() == GetTeamNum() && class'Rx_Utils'.static.OrientationToB(self, PC.Pawn) > 0.1)
		return Repl(tooltip, "{GBA_USE}", Caps(UDKPlayerInput(PC.PlayerInput).GetUDKBindNameFromCommand("GBA_Use")), true);
	return "";
}

simulated function bool ShouldSubstitute()
{
	return false;
}

simulated function bool IsTouchingOnly()
{
	return true;
}

simulated function bool IsBasicOnly()
{
	return false;
}

simulated function string GetHumanReadableName()
{
	return ReadName;
}

simulated event byte ScriptGetTeamNum()
{
	return TeamNum;
}

simulated function bool AreAircraftDisabled()
{
	local Rx_MapInfo mi;
	local Rx_Building b;

	mi = Rx_MapInfo(WorldInfo.GetMapInfo());

	ForEach WorldInfo.AllActors(class'Rx_Building', b)
	{
		if (b.GetTeamNum() != TeamNum)
			continue;

		if (Rx_Building_Helipad_GDI(b) != None)
			return b.IsDestroyed();

		if (Rx_Building_Helipad_Nod(b) != None)
			return b.IsDestroyed();
	}


	if (mi != none)
	{
		return mi.bAircraftDisabled;
	}

	return true;
}

simulated function StartCreditTick()
{
	SetTimer(0.5f,true,'CreditTick');
}

simulated function StopCreditTick()
{
	if (IsTimerActive('CreditTick'))
	{
		ClearTimer('CreditTick');
	}	
}


simulated function StartInsufCreditsTimeout()
{
	SetTimer(5.0f,false,'InsufCreditsTimeout');
}

simulated function StopInsufCreditsTimeout()
{
	if (IsTimerActive('InsufCreditsTimeout'))
	{
		ClearTimer();
	}	
}

//RxIFc_Targetable
simulated function bool GetUseBuildingArmour(){return false;} //Stupid legacy function to determine if we use building armour when drawing. 
simulated function Actor GetActualTarget() {return self;} //Should return 'self' most of the time, save for things that should return something else (like building internals should return the actual building)
simulated function bool GetShouldShowHealth(){return false;} //If we need to draw health on this 
simulated function bool HasDestroyedState() {return false;}
simulated function bool GetIsInteractable(PlayerController PC) {return PC.GetTeamNum() == GetTeamNum();} //Are we ever interactable?
simulated function bool GetCurrentlyInteractable(PlayerController RxPC) {return (Rx_Controller(RxPC).bCanAccessPT && RxPC.GetTeamNum() == GetTeamNum());} //Are we interactable right now? 
simulated function string GetInteractText(Controller C, string BindKey) {return "Press [ " $ bindKey $ " ] to enter Purchase Terminal";} //Get the text for our interaction 

defaultproperties
{
	SpawnName     = "_PT"
	SocketPattern = "Pt_"

	RemoteRole          = ROLE_SimulatedProxy
	CollisionType       = COLLIDE_TouchAllButWeapons
	bCollideActors      = True

	TeamNum = TEAM_UNOWNED;
	bAccessable = true;
	tooltip = "Press <font color='#ff0000' size='20'>[ {GBA_USE} ]</font> to access the PURCHASE TERMINAL";
	ReadName = "Purchase Terminal";

	Begin Object Class=StaticMeshComponent Name=PTMeshCmp
		StaticMesh                   = StaticMesh'rx_deco_terminal.Mesh.SM_BU_PT'
		CollideActors                = True
		BlockActors                  = True
		BlockRigidBody               = True
		BlockZeroExtent              = True
		BlockNonZeroExtent           = True
		bCastDynamicShadow           = True
		bAcceptsDynamicLights        = True
		bAcceptsLights               = True
		bAcceptsDecalsDuringGameplay = True
		bAcceptsDecals               = True
		RBChannel                    = RBCC_Pawn
		RBCollideWithChannels        = (Pawn=True)
	End Object
	Components.Add(PTMeshCmp)
	PTMesh = PTMeshCmp

	Begin Object Class=CylinderComponent Name=CollisioncMP
		CollisionRadius     = 75.0f
		CollisionHeight     = 50.0f
		BlockNonZeroExtent  = True
		BlockZeroExtent     = false
		bDrawNonColliding   = True
		bDrawBoundingBox    = False
		BlockActors         = False
		CollideActors       = True
	End Object
	CollisionComponent = CollisionCmp
	CollisionCylinder  = CollisionCmp
	Components.Add(CollisionCmp)
}