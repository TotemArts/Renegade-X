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

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	local string RelaxName;
	local int  RelaxNodeCount;
	local AnimNodeBlendList RelaxNodeTemp;

	RelaxNodeCount = 0;
	
	//super.PostInitAnimTree(SkelComp);

	if (SkelComp == ParachuteMesh)
	{
		
		ParachuteClosedWeight = MorphNodeWeight(ParachuteMesh.FindMorphNode('Parachute_OpeningStart'));		
		ParachuteCurveWeight = MorphNodeWeight(ParachuteMesh.FindMorphNode('Parachute_Curved'));		
		ParachuteLeftTurnWeight = MorphNodeWeight(ParachuteMesh.FindMorphNode('Parachute_LeftTurn'));		
		ParachuteRightTurnWeight = MorphNodeWeight(ParachuteMesh.FindMorphNode('Parachute_RightTurn'));
	}

	if (SkelComp == Mesh)
	{
		RunSpeedAnimNode = AnimNodeBlendBySpeed(Mesh.FindAnimNode('RunSpeedNode'));
		UpdateRunSpeedNode();

		LeftLegControl = SkelControlFootPlacement(Mesh.FindSkelControl(LeftFootControlName));
		RightLegControl = SkelControlFootPlacement(Mesh.FindSkelControl(RightFootControlName));
		FeignDeathBlend = AnimNodeBlend(Mesh.FindAnimNode('FeignDeathBlend'));
		FullBodyAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('FullBodySlot'));
		TopHalfAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('TopHalfSlot'));

		LeftHandAnimName = AnimNodeSequence( mesh.FindAnimNode('LeftHandAnimSeq') );
		LeftHandOverride = AnimNodeBlendPerBone(SkelComp.FindAnimNode('LeftHandOverride'));
		LeftHandIK = SkelControlLimb( mesh.FindSkelControl('LeftHandIK') );		
		RightHandIK = SkelControlLimb( mesh.FindSkelControl('RightHandIK') );
		
		LeftHandIK_SB = SkelControlSingleBone( mesh.FindSkelControl('LeftHandIK_Offset') );
		LeftHandIK_SBR = SkelControlSingleBone( mesh.FindSkelControl('LeftHandIK_Rotation') );
		RightHandIK_SB = SkelControlSingleBone( mesh.FindSkelControl('RightHandIK_Offset') );
		RightHandIK_SBR = SkelControlSingleBone( mesh.FindSkelControl('RightHandIK_Rotation') );

		RootRotControl = SkelControlSingleBone( mesh.FindSkelControl('RootRot') );
		AimNode = AnimNodeAimOffset( mesh.FindAnimNode('AimNode') );
		GunRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('GunRecoilNode') );
		LeftRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('LeftRecoilNode') );
		RightRecoilNode = GameSkelCtrl_Recoil( mesh.FindSkelControl('RightRecoilNode') );

		DrivingNode = UTAnimBlendByDriving( mesh.FindAnimNode('DrivingNode') );
		VehicleNode = UTAnimBlendByVehicle( mesh.FindAnimNode('VehicleNode') );
		HoverboardingNode = UTAnimBlendByHoverboarding( mesh.FindAnimNode('Hoverboarding') );

		FlyingDirOffset = AnimNodeAimOffset( mesh.FindAnimNode('FlyingDirOffset') );
		
		//Dodge (Dive) Blend node 
		DodgeNode = AnimNodeBlendList(Mesh.FindAnimNode(name(DodgeNodeName)));

		if (DodgeNode != None)
			DodgeNode.SetActiveChild(0,1.0);
		
		DodgeGroupNode = AnimNodeSequence( mesh.FindAnimNode('DodgeAnimNode') );//Only need Fwd.. The rest are linked to it
		//`log(DodgeGroupNode);
	
		// IF the Aimnode doesnt exist in the tree dont set WeaponAimNode equal to it
		if (AimNode != none )
			WeaponAimNode = AimNode;

		// Get Relaxed Aim Node
		RelaxedAimNode = AnimNodeAimOffset( mesh.FindAnimNode('AimRelaxed') );
		if( RelaxedAimNode == none )
		{
			`warn("Relaxed Aim Node Not Found In AnimTree");
		}

		// Find all the relax nodes in the tree and cache them
		do
		{
			RelaxNodeCount++;
			// Set name of next Relax Node
			RelaxName = RelaxBaseName$RelaxNodeCount;
			// Get First RelaxNode
			RelaxNodeTemp = AnimNodeBlendList(Mesh.FindAnimNode(name(RelaxName)));
			//if it doesnt find a node dont add it to the list
			if( RelaxNodeTemp != none )
			{
				RelaxedBlendLists.AddItem(RelaxNodeTemp);		
			}
		} 
		until( RelaxNodeTemp == none );
	}
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
