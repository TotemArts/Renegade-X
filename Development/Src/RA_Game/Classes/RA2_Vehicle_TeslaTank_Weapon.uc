/*********************************************************
*
* File: RA2_Vehicle_TeslaTank_Weapon.uc
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
class RA2_Vehicle_TeslaTank_Weapon extends Rx_Vehicle_Weapon_Reloadable;

DefaultProperties
{

	Vet_DamageModifier(0)=1  //Normal
	Vet_DamageModifier(1)=1.10  //Veteran
	Vet_DamageModifier(2)=1.25  //Elite
	Vet_DamageModifier(3)=1.50  //Heroic
	
	//*X Reverse percentage (0.75 is 25% increase in speed)
	Vet_ReloadSpeedModifier(0)=1 //Normal (should be 1)
	Vet_ReloadSpeedModifier(1)=0.95 //Veteran 
	Vet_ReloadSpeedModifier(2)=0.9 //Elite
	Vet_ReloadSpeedModifier(3)=0.80 //Heroic

	//+X
	Vet_ClipSizeModifier(0)=0 //Normal (should be 1)
	Vet_ClipSizeModifier(1)=0 //Veteran 
	Vet_ClipSizeModifier(2)=1 //Elite
	Vet_ClipSizeModifier(3)=1 //Heroic
    
    InventoryGroup=14
    
    // reload config
    ClipSize(0) = 2
    InitalNumClips = 999
    MaxClips = 999
     
    ShotCost(0)=1
    ShotCost(1)=1

    ReloadAnimName(0) = "weaponreload"
    ReloadAnimName(1) = "weaponreload"
    ReloadArmAnimName(0) = "weaponreload"
    ReloadArmAnimName(1) = "weaponreload"
     
    ReloadTime(0) = 2.5
	ReloadTime(1) = 2.0
	
	CrosshairWidth = 180 	// 256
	CrosshairHeight = 180 	// 256
     
    // gun config
    FireTriggerTags(0)="Fire01"
    FireTriggerTags(1)="Fire02"
	AltFireTriggerTags(0)="Fire01"
    VehicleClass=Class'RA2_Vehicle_TeslaTank'

    FireInterval(0)=1
	FireInterval(1)=5
    bFastRepeater=true

    Spread(0)=0.02
	
	RecoilImpulse = -0.01f
  
	WeaponFireSnd(0)     = SoundCue'RA2_VH_TeslaTank.Sounds.Teslatank_FireCue'
    WeaponFireTypes(0)   = EWFT_InstantHit
	WeaponFireSnd(1)     = SoundCue'RA2_VH_TeslaTank.Sounds.Teslatank_FireCue'
	WeaponFireTypes(1)	 = EWFT_None

    bRecommendSplashDamage=False
	
	WeaponRange(0)=4000.0
	// WeaponRange(1)=4000.0

	InstantHitDamage(0)=200
	InstantHitDamage(1)=0
	InstantHitDamageRadius(0)=140
	
	HeadShotDamageMult=2.5

	InstantHitDamageTypes(0)=class'RA2_DmgType_TeslaTank_Coil'
	InstantHitDamageTypes(1)=class'RA2_DmgType_TeslaTank_Coil'

	InstantHitMomentum(0)=10000
	
	bInstantHit=true
	
	BeamTemplates[0]=ParticleSystem'RA2_VH_TeslaTank.Effects.P_Lightning'
	
	DefaultImpactEffect=(ParticleTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_Impact',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	
	ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_Impact',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_Impact',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_Impact',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_Impact',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_Impact',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_Impact',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
    ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_Impact',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_Impact',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_Impact',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_Impact',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_Impact',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_Impact',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_Impact',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_Impact',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_Impact',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_Impact',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_Impact',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_Impact',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(18)=(MaterialType=Snow, ParticleTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_Impact',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
	ImpactEffects(19)=(MaterialType=SnowStone, ParticleTemplate=ParticleSystem'APB_VH_SOV_TeslaTank.Effects.P_Impact',Sound=SoundCue'RX_WP_VoltAutoRifle.Sounds.SC_VoltBolt_Impact')
}
