/** one1: Added. This is light-weight Pawn actor used for PT display. */
class Rx_PT_Pawn extends Rx_Pawn;

var class<Rx_WeaponAttachment> PrimaryWeaponAttachmentClass;
var SkeletalMeshComponent PrimaryAttachedWeapon;

simulated event PostBeginPlay()
{
	// stub out
	SetPhysics(PHYS_Walking);
}

simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
	local int i;
	//local int TeamNum;
	local MaterialInterface TeamMaterialHead, TeamMaterialBody;

	if (Info != CurrCharClassInfo)
	{
		// Set Family Info
		CurrCharClassInfo = Info;

		// AnimSets
		Mesh.AnimSets = Info.default.AnimSets;

		Info.static.GetTeamMaterials(0, TeamMaterialHead, TeamMaterialBody);

		// 3P Mesh and materials
		SetCharacterMeshInfo(Info.default.CharacterMesh, TeamMaterialHead, TeamMaterialBody);

		// PhysicsAsset
		// Force it to re-initialise if the skeletal mesh has changed (might be flappy bones etc).
		Mesh.SetPhysicsAsset(Info.default.PhysAsset, true);

		// Make sure bEnableFullAnimWeightBodies is only TRUE if it needs to be (PhysicsAsset has flappy bits)
		Mesh.bEnableFullAnimWeightBodies = FALSE;
		for(i=0; i<Mesh.PhysicsAsset.BodySetup.length && !Mesh.bEnableFullAnimWeightBodies; i++)
		{
			// See if a bone has bAlwaysFullAnimWeight set and also
			if( Mesh.PhysicsAsset.BodySetup[i].bAlwaysFullAnimWeight &&
				Mesh.MatchRefBone(Mesh.PhysicsAsset.BodySetup[i].BoneName) != INDEX_NONE)
			{
				Mesh.bEnableFullAnimWeightBodies = TRUE;
			}
		}

		DefaultMeshScale = Info.Default.DefaultMeshScale;
		Mesh.SetScale(DefaultMeshScale);
		BaseTranslationOffset = CurrCharClassInfo.Default.BaseTranslationOffset;
	}

	if (Mesh.SkeletalMesh != None) 
	{
		for (i = 0; i < Mesh.SkeletalMesh.Materials.length; i++) 
		{
			Mesh.SetMaterial(i, None);
		} 
	}
}

/** one1: Here comes visible weapon attachment magic. It should be called only after
 *  refresh of character, due to creation of objects and de/re/attachments. */
function RefreshAttachedWeapons()
{
	local class<Rx_FamilyInfo> finfo;
	
	finfo = class<Rx_FamilyInfo>(CurrCharClassInfo);
	
	RefreshPrimaryAttachedWeapon(finfo.default.InvManagerClass);

	// get back weapons
	finfo.default.InvManagerClass.static.GetStartingHiddenWeaponAttachmentClasses(finfo.default.InvManagerClass, 
		CurrentBackWeapons);

	RefreshBackWeaponComponents();
}

function RefreshPrimaryAttachedWeapon(class<Rx_InventoryManager> imclass)
{
	local class<Rx_Weapon> wclass;
	local class<Rx_WeaponAttachment> wattclass;

	wclass = imclass.default.PrimaryWeapons[0];
	wattclass = class<Rx_WeaponAttachment>(wclass.default.AttachmentClass);

	if (PrimaryWeaponAttachmentClass != none)
	{
		// check if it is same
		if (PrimaryWeaponAttachmentClass == wattclass)
			return; // skip

		// else detach first
		Mesh.DetachComponent(PrimaryAttachedWeapon);
		DetachComponent(PrimaryAttachedWeapon);
	}

	PrimaryWeaponAttachmentClass = wattclass;
	PrimaryAttachedWeapon = new(self) class'SkeletalMeshComponent'(wattclass.default.Mesh);

	PrimaryAttachedWeapon.SetShadowParent(Mesh);
	PrimaryAttachedWeapon.SetLightEnvironment(LightEnvironment);
	AttachComponent(PrimaryAttachedWeapon);
	Mesh.AttachComponentToSocket(PrimaryAttachedWeapon, WeaponSocket);

	SetAnimSet(wattclass.default.WeaponAnimSet, wattclass.default.AimProfileName);
}

simulated function SetAnimSet( AnimSet NewAnimSet, name ProfileName )
{
	Mesh.AnimSets[0] = NewAnimSet;
	Mesh.UpdateAnimations();
	//WeaponAimNode.SetActiveProfileByName(ProfileName);
}

simulated event Destroyed()
{
	if (PrimaryAttachedWeapon != none)
	{
		Mesh.DetachComponent(PrimaryAttachedWeapon);
		DetachComponent(PrimaryAttachedWeapon);
	}

	super.Destroyed();
}

simulated function UpdateRunSpeedNode() ;

DefaultProperties
{
	Begin Object Name=WPawnSkeletalMeshComponent
		AnimTreeTemplate=AnimTree'RX_CH_Animations.Anims.AT_Character_PTScene'
	End Object

	bIsPtPawn=true

	RemoteRole=ROLE_None
}
