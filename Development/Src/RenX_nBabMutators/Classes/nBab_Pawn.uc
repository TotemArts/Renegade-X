class nBab_Pawn extends Rx_Pawn;

var Rx_CapturableMCT_MC MC;

simulated function PostBeginPlay()
{  
	super.PostBeginPlay();
	// Start the relax timer when the pawn spawns
	SetTimer( 0.5, false, 'RelaxTimer' );
	SetHandIKEnabled(false);
	ParachuteMesh.SetLightEnvironment(LightEnvironment);
	if(WorldInfo.NetMode == NM_DedicatedServer)
	{
		SetTimer( 1.0, true, 'CheckLoc' );
	}
	
	setTimer(0.1,false,'nBabHealth');

	foreach AllActors(class 'Rx_CapturableMCT_MC',MC)
		break;
}
function nBabHealth()
{
	if (self.GetTeamNum() == MC.GetTeamNum())
	{
		if(self.HealthMax <150)
			self.HealthMax = self.HealthMax+50;
		self.Health = self.HealthMax;
		if (self.HealthMax>150)
			self.HealthMax = 150;
		if (self.Health > self.HealthMax)
			self.Health = self.HealthMax;
	}
}

simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info) {

	local int i;
	local class<UTFamilyInfo> prev;
	local array<class<Rx_Weapon> > prevItems;
	local class<Rx_Weapon> weapClass;

	prev = CurrCharClassInfo;
	
	super.SetCharacterClassFromInfo(Info);
	
	if(Mesh.SkeletalMesh != None) {
		for (i = 0; i < Mesh.SkeletalMesh.Materials.length; i++) {
			Mesh.SetMaterial( i, None );
		} 
	}

	/** one1: Set inventory manager according to family info class. */
	if (Role == ROLE_Authority)
	{
		if (prev == Info)
			return; // no changes, skip

		if (InvManager != none)
		{
			prevItems = Rx_InventoryManager(InvManager).GetWeaponsOfClassification(CLASS_ITEM);
			InvManager.Destroy();
		}

		//InventoryManagerClass = class'nBab_InventoryManager';
		InventoryManagerClass = class<Rx_FamilyInfo>(Info).default.InvManagerClass;

		InvManager = Spawn(InventoryManagerClass, self);
		InvManager.SetupFor(self);
		foreach prevItems(weapClass)
		{
			Rx_InventoryManager(InvManager).AddWeaponOfClass(weapClass, CLASS_ITEM);
		}
	}
	setTimer(0.1,false,'nBabHealth');
}