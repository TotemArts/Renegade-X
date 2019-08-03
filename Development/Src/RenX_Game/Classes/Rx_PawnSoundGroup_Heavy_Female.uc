/*********************************************************
*
* File: RxPawnSoundGroup.uc
* Author: RenegadeX-Team
* Project: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/

class Rx_PawnSoundGroup_Heavy_Female extends Rx_PawnSoundGroup;

defaultproperties
{
	DodgeSound=SoundCue'RX_SoundEffects.FootSteps.Dirt.SC_Jump_Dirt'
	DoubleJumpSound=SoundCue'RX_SoundEffects.FootSteps.Dirt.SC_Jump_Dirt'
	LandSound=SoundCue'RX_SoundEffects.FootSteps.Dirt.SC_Land_Dirt'
	
	DyingSound=SoundCue'RX_CharacterSounds.Female.SC_Female_Death'
	HitSounds[0]=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Metal' //SoundCue'RX_CharacterSounds.Male.SC_Male_Grunt_Small'
	HitSounds[1]=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Metal' //SoundCue'RX_CharacterSounds.Male.SC_Male_Grunt_Medium'
	HitSounds[2]=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Metal' //SoundCue'RX_CharacterSounds.Male.SC_Male_Grunt_Large'
	FallingDamageLandSound=SoundCue'RX_CharacterSounds.Female.SC_Female_Grunt_Small'
	GibSound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Flesh' //none //SoundCue'A_Character_CorruptEnigma_Cue.Mean_Efforts.A_Effort_EnigmaMean_DeathInstant_Cue'
	
	DefaultFootStepSound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneCue'
	FootstepSounds[0]=(MaterialType=Stone,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneCue')
	FootstepSounds[1]=(MaterialType=Dirt,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtCue')
	FootstepSounds[2]=(MaterialType=Mud,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterShallowCue')   //SoundCue'RX_SoundEffects.FootSteps.Mud.SC_FootStep_Mud')
	FootstepSounds[3]=(MaterialType=Foliage,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_FoliageCue')
	FootstepSounds[4]=(MaterialType=Glass,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassPlateCue')
	FootstepSounds[5]=(MaterialType=Water,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterDeepCue')
	FootstepSounds[6]=(MaterialType=ShallowWater,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterShallowCue')
	FootstepSounds[7]=(MaterialType=Metal,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MetalCue')
	FootstepSounds[8]=(MaterialType=Snow,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_SnowCue')
	FootstepSounds[9]=(MaterialType=Wood,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WoodCue')
	FootstepSounds[10]=(MaterialType=Concrete,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneCue')
	FootstepSounds[11]=(MaterialType=Grass,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtCue')
	FootstepSounds[12]=(MaterialType=TiberiumGround,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtCue') //SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_FootStep_Tiberium')
	FootstepSounds[13]=(MaterialType=TiberiumGroundBlue,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtCue')	//SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_FootStep_Tiberium')
	FootstepSounds[14]=(MaterialType=WhiteSand,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtCue')
	FootstepSounds[15]=(MaterialType=YellowSand,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtCue')
	FootstepSounds[16]=(MaterialType=TiberiumCrystal,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtCue') //SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_FootStep_TiberiumCrystal')
	FootstepSounds[17]=(MaterialType=TiberiumCrystalBlue,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtCue') //SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_FootStep_TiberiumCrystal')
	
	DefaultJumpingSound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneJumpCue'
	JumpingSounds[0]=(MaterialType=Stone,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneJumpCue')
	JumpingSounds[1]=(MaterialType=Dirt,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtJumpCue')
	JumpingSounds[2]=(MaterialType=Foliage,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_FoliageJumpCue')
	JumpingSounds[3]=(MaterialType=Glass,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassPlateJumpCue')
	JumpingSounds[4]=(MaterialType=Grass,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GrassJumpCue')
	JumpingSounds[5]=(MaterialType=Metal,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MetalJumpCue')
	JumpingSounds[6]=(MaterialType=Mud,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MudJumpCue')
	JumpingSounds[7]=(MaterialType=Snow,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_SnowJumpCue')
	JumpingSounds[8]=(MaterialType=Water,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterDeepJumpCue')
	JumpingSounds[9]=(MaterialType=Wood,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WoodJumpCue')
	JumpingSounds[10]=(MaterialType=Stone,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneJumpCue')
	JumpingSounds[11]=(MaterialType=Concrete,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneJumpCue')
	JumpingSounds[12]=(MaterialType=TiberiumGround,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassPlateJumpCue') //SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_Jump_Tiberium')
	JumpingSounds[13]=(MaterialType=TiberiumGroundBlue,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassPlateJumpCue')  //SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_Jump_Tiberium')
	JumpingSounds[14]=(MaterialType=WhiteSand,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtJumpCue')
	JumpingSounds[15]=(MaterialType=YellowSand,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtJumpCue')
	JumpingSounds[16]=(MaterialType=TiberiumCrystal,Sound= SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassPlateJumpCue') //SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_Jump_TiberiumCrystal')
	JumpingSounds[17]=(MaterialType=TiberiumCrystalBlue,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassPlateJumpCue') //SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_Jump_TiberiumCrystal')


	DefaultLandingSound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtLandCue'
	LandingSounds[0]=(MaterialType=Stone,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneLandCue')
	LandingSounds[1]=(MaterialType=Dirt,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtLandCue')
	LandingSounds[2]=(MaterialType=Foliage,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_FoliageLandCue')
	LandingSounds[3]=(MaterialType=Glass,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassPlateLandCue')
	LandingSounds[4]=(MaterialType=Grass,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GrassLandCue')
	LandingSounds[5]=(MaterialType=Metal,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MetalLandCue')
	LandingSounds[6]=(MaterialType=Mud,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_MudLandCue')
	LandingSounds[7]=(MaterialType=Snow,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_SnowLandCue')
	LandingSounds[8]=(MaterialType=Water,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterDeepLandCue')
	LandingSounds[9]=(MaterialType=Wood,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WoodLandCue')
	LandingSounds[10]=(MaterialType=Concrete,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneLandCue')
	LandingSounds[11]=(MaterialType=TiberiumGround,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassPlateLandCue')   //SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_Land_Tiberium')
	LandingSounds[12]=(MaterialType=TiberiumGroundBlue,Sound= SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassPlateLandCue')  //SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_Land_Tiberium')
	LandingSounds[13]=(MaterialType=WhiteSand,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtLandCue')
	LandingSounds[14]=(MaterialType=YellowSand,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtLandCue')
	LandingSounds[15]=(MaterialType=TiberiumCrystal,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassPlateLandCue')  //SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_Land_TiberiumCrystal')
	LandingSounds[16]=(MaterialType=TiberiumCrystalBlue,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_GlassPlateLandCue')  //SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_Land_TiberiumCrystal')
	
		BulletImpactSound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Metal'
	
	//BulletImpactSound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Flesh'

	CrushedSound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Flesh' //none //SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_RobotImpact_BodyExplosion_Cue'
	BodyExplosionSound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Flesh' //none //SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_RobotImpact_BodyExplosion_Cue'
	InstaGibSound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Flesh' //none //SoundCue'A_Character_CorruptEnigma_Cue.Mean_Efforts.A_Effort_EnigmaMean_DeathInstant_Cue'
}