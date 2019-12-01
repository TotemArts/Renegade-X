class Rx_Weapon_Blueprint_Defense_CeilingTurret extends Rx_Weapon_Blueprint_Defense;

simulated function bool IsBuildCorrect()
{
	return (BuildBase != None && BuildNormal.Z >= MinNormalZ && BuildNormal.Z <= MaxNormalZ
		&& BuildBase.bStatic && Rx_Building(BuildBase) != None
		&& RadiusIsClear());	
}

simulated function bool RadiusIsClear()
{
	local Actor A;

	if(BuildClearRadius <= 0)
		return true;

	foreach VisibleCollidingActors( class'Actor', A, BuildClearRadius, BuildLoc + BuildOffset)
	{
		if(Pawn(A) != None || Rx_Weapon_DeployedActor(A) != None)
			return false;
	}

	return true;
}

simulated function Vector GetBlueprintModelLocation()
{
	return BuildLoc + BuildOffset;
}

// needs special treatment cuz you're placing it on the ceiling instead

simulated function GetBlueprintLocation()
{
	local Vector TempLoc, TempOri, TempDir;
	local Rotator TempRot;
	local vector HitLocation, HitNormal;


	Instigator.Controller.GetPlayerViewPoint(TempOri, TempRot); 
	TempDir = Vector(TempRot);
	TempLoc = TempOri + (TempDir * WeaponRange);

	BuildBase = Instigator.Trace(HitLocation,HitNormal, TempLoc, TempOri,,,, TRACEFLAG_Blocking);

	if(BuildBase == None)
		BuildBase = Instigator.Trace(HitLocation,HitNormal, TempLoc + (Vect(0,0,1) * 1000), TempLoc,,,, TRACEFLAG_Blocking);


	if(BuildBase == None)
	{
		BuildLoc = TempLoc;
		BuildNormal = Vect(0,0,1);
	}
	else
	{
		BuildLoc = HitLocation;
		BuildNormal = HitNormal;
		
	}

	BuildRot = GetBuildRotation();
	bValidPlacement = IsBuildCorrect();
}

DefaultProperties
{
	DefenseClass = class'RenX_Game.Rx_Defence_CeilingTurret'
	BuildOffset = (X=0.0,Y=0.0,Z=-35)
	BuildClearRadius = 90
	BuildScale = 0.5
	VisualMesh = SkeletalMesh'RX_DEF_CeilingTurret.Mesh.SK_Turret_MG'
	WeaponIconTexture=Texture2D'RX_DEF_GuardTower.UI.T_WeaponIcon_GuardTower'
	PTIconTexture=Texture2D'RenXPurchaseMenu.T_Icon_Item_Sentry_MG'

	MinNormalZ = -1;
	MaxNormalZ = -0.8;
	Price = 300
}
