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

class Rx_PawnSoundGroup extends UTPawnSoundGroup;

static function PlayInstagibSound(Pawn P){ 
// play no sound 
} 

static function PlayCrushedSound(Pawn P){ 
// play no sound
}

static function PlayBodyExplosion(Pawn P){ 
// play no sound
}

static function PlayFallingDamageLandSound(Pawn P)
{
	// play no sound
}

static function PlayDyingSound(Pawn P)
{
	// play no sound
}

defaultproperties
{
	DodgeSound=SoundCue'RX_SoundEffects.FootSteps.Dirt.SC_Jump_Dirt'
	DoubleJumpSound=SoundCue'RX_SoundEffects.FootSteps.Dirt.SC_Jump_Dirt'
	LandSound=SoundCue'RX_SoundEffects.FootSteps.Dirt.SC_Land_Dirt'
	
	DyingSound=SoundCue'RX_CharacterSounds.Male.SC_Male_Death'
	HitSounds[0]=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Flesh' //SoundCue'RX_CharacterSounds.Male.SC_Male_Grunt_Small'
	HitSounds[1]=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Flesh' //SoundCue'RX_CharacterSounds.Male.SC_Male_Grunt_Medium'
	HitSounds[2]=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Flesh' //SoundCue'RX_CharacterSounds.Male.SC_Male_Grunt_Large'
	FallingDamageLandSound=SoundCue'RX_CharacterSounds.Male.SC_Male_Grunt_Small'
	GibSound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Flesh' //none //SoundCue'A_Character_CorruptEnigma_Cue.Mean_Efforts.A_Effort_EnigmaMean_DeathInstant_Cue'
	
	DefaultFootStepSound=SoundCue'RX_SoundEffects.FootSteps.Concrete.SC_FootStep_Concrete'
	FootstepSounds[0]=(MaterialType=Stone,Sound=SoundCue'RX_SoundEffects.FootSteps.Concrete.SC_FootStep_Concrete')
	FootstepSounds[1]=(MaterialType=Dirt,Sound=SoundCue'RX_SoundEffects.FootSteps.Dirt.SC_FootStep_Dirt')
	FootstepSounds[2]=(MaterialType=Mud,Sound=SoundCue'RX_SoundEffects.FootSteps.Mud.SC_FootStep_Mud')
	FootstepSounds[3]=(MaterialType=Foliage,Sound=SoundCue'RX_SoundEffects.FootSteps.Dirt.SC_FootStep_Dirt')
	FootstepSounds[4]=(MaterialType=Glass,Sound=SoundCue'RX_SoundEffects.FootSteps.Glass.SC_FootStep_Glass')
	FootstepSounds[5]=(MaterialType=Water,Sound=SoundCue'RX_SoundEffects.FootSteps.Water.SC_FootStep_Water')
	FootstepSounds[6]=(MaterialType=ShallowWater,Sound=SoundCue'RX_SoundEffects.FootSteps.Mud.SC_FootStep_Mud')
	FootstepSounds[7]=(MaterialType=Metal,Sound=SoundCue'RX_SoundEffects.FootSteps.Metal.SC_FootStep_Metal')
	FootstepSounds[8]=(MaterialType=Snow,Sound=SoundCue'RX_SoundEffects.FootSteps.Snow.SC_FootStep_Snow')
	FootstepSounds[9]=(MaterialType=Wood,Sound=SoundCue'RX_SoundEffects.FootSteps.Wood.SC_FootStep_Wood')
	FootstepSounds[10]=(MaterialType=Concrete,Sound=SoundCue'RX_SoundEffects.FootSteps.Concrete.SC_FootStep_Concrete')
	FootstepSounds[11]=(MaterialType=Grass,Sound=SoundCue'RX_SoundEffects.FootSteps.Dirt.SC_FootStep_Dirt')
	FootstepSounds[12]=(MaterialType=TiberiumGround,Sound=SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_FootStep_Tiberium')
	FootstepSounds[13]=(MaterialType=TiberiumGroundBlue,Sound=SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_FootStep_Tiberium')
	FootstepSounds[14]=(MaterialType=WhiteSand,Sound=SoundCue'RX_SoundEffects.FootSteps.Dirt.SC_FootStep_Dirt')
	FootstepSounds[15]=(MaterialType=YellowSand,Sound=SoundCue'RX_SoundEffects.FootSteps.Dirt.SC_FootStep_Dirt')
	FootstepSounds[16]=(MaterialType=TiberiumCrystal,Sound=SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_FootStep_TiberiumCrystal')
	FootstepSounds[17]=(MaterialType=TiberiumCrystalBlue,Sound=SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_FootStep_TiberiumCrystal')
	
	DefaultJumpingSound=SoundCue'RX_SoundEffects.FootSteps.Concrete.SC_Jump_Concrete'
	JumpingSounds[0]=(MaterialType=Stone,Sound=SoundCue'RX_SoundEffects.FootSteps.Concrete.SC_Jump_Concrete')
	JumpingSounds[1]=(MaterialType=Dirt,Sound=SoundCue'RX_SoundEffects.FootSteps.Dirt.SC_Jump_Dirt')
	JumpingSounds[2]=(MaterialType=Foliage,Sound=SoundCue'RX_SoundEffects.FootSteps.Dirt.SC_Jump_Dirt')
	JumpingSounds[3]=(MaterialType=Glass,Sound=SoundCue'RX_SoundEffects.FootSteps.Glass.SC_Jump_Glass')
	JumpingSounds[4]=(MaterialType=Grass,Sound=SoundCue'RX_SoundEffects.FootSteps.Dirt.SC_Jump_Dirt')
	JumpingSounds[5]=(MaterialType=Metal,Sound=SoundCue'RX_SoundEffects.FootSteps.Metal.SC_Jump_Metal')
	JumpingSounds[6]=(MaterialType=Mud,Sound=SoundCue'RX_SoundEffects.FootSteps.Mud.SC_Jump_Mud')
	JumpingSounds[7]=(MaterialType=Snow,Sound=SoundCue'RX_SoundEffects.FootSteps.Snow.SC_Jump_Snow')
	JumpingSounds[8]=(MaterialType=Water,Sound=SoundCue'RX_SoundEffects.FootSteps.Water.SC_Jump_Water')
	JumpingSounds[9]=(MaterialType=Wood,Sound=SoundCue'RX_SoundEffects.FootSteps.Wood.SC_Jump_Wood')
	JumpingSounds[10]=(MaterialType=Stone,Sound=SoundCue'RX_SoundEffects.FootSteps.Concrete.SC_Jump_Concrete')
	JumpingSounds[11]=(MaterialType=Concrete,Sound=SoundCue'RX_SoundEffects.FootSteps.Concrete.SC_Jump_Concrete')
	JumpingSounds[12]=(MaterialType=TiberiumGround,Sound=SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_Jump_Tiberium')
	JumpingSounds[13]=(MaterialType=TiberiumGroundBlue,Sound=SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_Jump_Tiberium')
	JumpingSounds[14]=(MaterialType=WhiteSand,Sound=SoundCue'RX_SoundEffects.FootSteps.Dirt.SC_Jump_Dirt')
	JumpingSounds[15]=(MaterialType=YellowSand,Sound=SoundCue'RX_SoundEffects.FootSteps.Dirt.SC_Jump_Dirt')
	JumpingSounds[16]=(MaterialType=TiberiumCrystal,Sound=SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_Jump_TiberiumCrystal')
	JumpingSounds[17]=(MaterialType=TiberiumCrystalBlue,Sound=SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_Jump_TiberiumCrystal')


	DefaultLandingSound=SoundCue'RX_SoundEffects.FootSteps.Concrete.SC_Land_Concrete'
	LandingSounds[0]=(MaterialType=Stone,Sound=SoundCue'RX_SoundEffects.FootSteps.Concrete.SC_Land_Concrete')
	LandingSounds[1]=(MaterialType=Dirt,Sound=SoundCue'RX_SoundEffects.FootSteps.Dirt.SC_Land_Dirt')
	LandingSounds[2]=(MaterialType=Foliage,Sound=SoundCue'RX_SoundEffects.FootSteps.Dirt.SC_Land_Dirt')
	LandingSounds[3]=(MaterialType=Glass,Sound=SoundCue'RX_SoundEffects.FootSteps.Glass.SC_Land_Glass')
	LandingSounds[4]=(MaterialType=Grass,Sound=SoundCue'RX_SoundEffects.FootSteps.Dirt.SC_Land_Dirt')
	LandingSounds[5]=(MaterialType=Metal,Sound=SoundCue'RX_SoundEffects.FootSteps.Metal.SC_Land_Metal')
	LandingSounds[6]=(MaterialType=Mud,Sound=SoundCue'RX_SoundEffects.FootSteps.Mud.SC_Land_Mud')
	LandingSounds[7]=(MaterialType=Snow,Sound=SoundCue'RX_SoundEffects.FootSteps.Snow.SC_Land_Snow')
	LandingSounds[8]=(MaterialType=Water,Sound=SoundCue'RX_SoundEffects.FootSteps.Water.SC_Land_Water')
	LandingSounds[9]=(MaterialType=Wood,Sound=SoundCue'RX_SoundEffects.FootSteps.Wood.SC_Land_Wood')
	LandingSounds[10]=(MaterialType=Concrete,Sound=SoundCue'RX_SoundEffects.FootSteps.Concrete.SC_Land_Concrete')
	LandingSounds[11]=(MaterialType=TiberiumGround,Sound=SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_Land_Tiberium')
	LandingSounds[12]=(MaterialType=TiberiumGroundBlue,Sound=SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_Land_Tiberium')
	LandingSounds[13]=(MaterialType=WhiteSand,Sound=SoundCue'RX_SoundEffects.FootSteps.Dirt.SC_Land_Dirt')
	LandingSounds[14]=(MaterialType=YellowSand,Sound=SoundCue'RX_SoundEffects.FootSteps.Dirt.SC_Land_Dirt')
	LandingSounds[15]=(MaterialType=TiberiumCrystal,Sound=SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_Land_TiberiumCrystal')
	LandingSounds[16]=(MaterialType=TiberiumCrystalBlue,Sound=SoundCue'RX_SoundEffects.FootSteps.Tiberium.SC_Land_TiberiumCrystal')
	
	BulletImpactSound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Flesh'

	CrushedSound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Flesh' //none //SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_RobotImpact_BodyExplosion_Cue'
	BodyExplosionSound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Flesh' //none //SoundCue'A_Character_BodyImpacts.BodyImpacts.A_Character_RobotImpact_BodyExplosion_Cue'
	InstaGibSound=SoundCue'RX_SoundEffects.Bullet_Impact.SC_BulletImpact_Flesh' //none //SoundCue'A_Character_CorruptEnigma_Cue.Mean_Efforts.A_Effort_EnigmaMean_DeathInstant_Cue'
}