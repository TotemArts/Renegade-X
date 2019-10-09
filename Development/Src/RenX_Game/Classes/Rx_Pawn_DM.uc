class Rx_Pawn_DM extends Rx_Pawn;

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp) {
	
	Super.PostInitAnimTree(SkelComp) ;
	SetTimer(0.2, false, 'NormalizeHealth' ) ;
}


//Weirdly add weapon drops. I have to go around the normal DropFrom function to get around the automatic 'false' given to Rx_Weapons

/**function RemoteDropFrom(vector StartLocation, vector StartVelocity, Rx_Weapon Weap)
{
	local DroppedPickup P;

	if(InvManager != None )
	{
		InvManager.RemoveFromInventory(Weap);
	}

	// if cannot spawn a pickup, then destroy and quit
	if( Weap.DroppedPickupClass == None || Weap.DroppedPickupMesh == None )
	{
		Weap.Destroy();
		return;
	}

	//From UTWeapon DropFrom
	
	// Become inactive
	Weap.GotoState('Inactive');

	// Stop Firing
	Weap.ForceEndFire();
	// Detach weapon components from instigator
	Weap.DetachWeapon();
	
	//The rest of the super function
	
	P = Spawn(Weap.DroppedPickupClass,,, StartLocation);
	if( P == None )
	{
		Weap.Destroy();
		return;
	}

	P.SetPhysics(PHYS_Falling);
	P.Inventory	= Weap;
	P.InventoryClass = Weap.class;
	P.Velocity = StartVelocity;
	P.Instigator = self;
	P.SetPickupMesh(Weap.DroppedPickupMesh);
	P.SetPickupParticles(Weap.DroppedPickupParticles);

	GotoState('');
}	


function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation) {
	if (Weapon != none) RemoteDropFrom(Location, Velocity, Rx_Weapon(Weapon)) ;


	super.Died(Killer, damageType, HitLocation) ;

	return true;
}*/

//Obviously the function to normalize health to 200 across the board
simulated function bool NormalizeHealth () {
	
	Armormax = 100 ;
	Armor = 100 ; 
	setArmorType(A_NONE);
		
	return true; 
}

function PromoteUnit(byte rank) //Promotion depends mostly on the unit. All units gain health however
{	
	return; 
}

DefaultProperties
{
	/**
	WalkingPct=1.0 
	CrouchedPct=+0.3
	GroundSpeed=310
	AirSpeed=25 //100
	WaterSpeed=150.0
	DodgeSpeed=500 //420
	DodgeSpeedZ=300.0
	DodgeDuration=0.75	// 1.0
	bDodgeCapable= false //  Not this patch yet... till we figure something out. Yosh
	AccelRate=550 //1000 //1400
	MaxLeanRoll=2500
	JumpZ=325.0
	VehicleCheckRadius=120
	bForceMaxAccel = false//true
	
	CustomGravityScaling=1.0 //0.85

	WalkingSpeed=90
	RunningSpeed=310	// 290
	SprintSpeed=410 //480//400.0	// 440.0 
	LadderSpeed=85
	SpeedUpgradeMultiplier=1.0 
	JumpHeightMultiplier=1.0

	RegenerationRate = 1
	HeroicRegenerationRate = 3 
	MaxDR = 0.1 //Maximumum of 90% damage resistance
	
	Begin Object Name=WPawnSkeletalMeshComponent
		AnimTreeTemplate=AnimTree'RX_CH_Animations.Anims.AT_Character_Modular_Grounded'
	End Object
	Mesh=WPawnSkeletalMeshComponent
	Components.Add(WPawnSkeletalMeshComponent)*/

}