//=============================================================================
// Fires high-momentum projectiles.
// http://mrevil.pwp.blueyonder.co.uk/unreal/
//=============================================================================
class S_SentinelWeapon_Obelisk extends Rx_SentinelWeapon_Obelisk;

/**
 * Called when Cannon is replicated, to allow client-side alterations to be made.
 */
simulated function ClientInitializeFor()
{
	local Rx_Building_GDI_Defense Ob;
	if(CrystalGlowMIC == None) {
		super.ClientInitializeFor();
		ForEach AllActors(class'Rx_Building_GDI_Defense',Ob)
		{
			CrystalGlowMIC = Ob.BuildingInternals.BuildingSkeleton.CreateAndSetMaterialInstanceConstant(0);
			InitAndAttachMuzzleFlashes(Ob.BuildingInternals.BuildingSkeleton, 'Ob_Fire');
			break;
		}	
	}
}

defaultproperties
{
    BeamTemplate=ParticleSystem's_BU_Oblisk.Effects.P_Obelisk_LaserBeam'
    ImpactLightClass=Class'RenX_GameX.S_Light_ObeliskImpact'
    
    Begin Object Name=MuzzleFlash0
        bIgnoreOwnerHidden=true
        Template=ParticleSystem'S_BU_Oblisk.Effects.P_Obelisk_Fire'
        MuzzleFlashDuration=2.25
        //MuzzleFlashOffset=(X=-100.0,Y=0.0,Z=-90.0)        
        bConstantFlash=false
    End Object
    MuzzleFlash=MuzzleFlash0

    Begin Object Name=MuzzleFlash1
        Template=ParticleSystem'S_BU_Oblisk.Effects.P_Obelisk_ChargeUp'
        bIgnoreOwnerHidden=true
        MuzzleFlashDuration=4
        //MuzzleFlashOffset=(X=-100.0,Y=0.0,Z=-90.0)        
        bConstantFlash=false
    End Object
    ChargeUpMuzzleFlash=MuzzleFlash1

    Begin Object Name=MuzzleFlashLightComponent0
        LightOffset=(X=-100.0,Y=0.0,Z=-90.0)
        TimeShift=((StartTime=0.0,Radius=200,Brightness=5,LightColor=(R=10,G=10,B=255,A=255)),(StartTime=0.8,Radius=64,Brightness=0,LightColor=(R=10,G=10,B=255,A=255)))
    End Object
    MuzzleFlashLight=MuzzleFlashLightComponent0

    Begin Object Name=HitEffectsComp
	
	ImpactEffects(0)=(MaterialType=Dirt, ParticleTemplate=ParticleSystem'S_BU_Oblisk.Effects.P_Obelisk_Impact', Sound=SoundCue'RX_BU_Oblisk.Sounds.SC_Obelisk_Impact')
    ImpactEffects(1)=(MaterialType=Stone, ParticleTemplate=ParticleSystem'S_BU_Oblisk.Effects.P_Obelisk_Impact', Sound=SoundCue'RX_BU_Oblisk.Sounds.SC_Obelisk_Impact')
	ImpactEffects(2)=(MaterialType=Concrete, ParticleTemplate=ParticleSystem'S_BU_Oblisk.Effects.P_Obelisk_Impact', Sound=SoundCue'RX_BU_Oblisk.Sounds.SC_Obelisk_Impact')
    ImpactEffects(3)=(MaterialType=Metal, ParticleTemplate=ParticleSystem'S_BU_Oblisk.Effects.P_Obelisk_Impact', Sound=SoundCue'RX_BU_Oblisk.Sounds.SC_Obelisk_Impact')
    ImpactEffects(4)=(MaterialType=Glass, ParticleTemplate=ParticleSystem'S_BU_Oblisk.Effects.P_Obelisk_Impact', Sound=SoundCue'RX_BU_Oblisk.Sounds.SC_Obelisk_Impact')
    ImpactEffects(5)=(MaterialType=Wood, ParticleTemplate=ParticleSystem'S_BU_Oblisk.Effects.P_Obelisk_Impact', Sound=SoundCue'RX_BU_Oblisk.Sounds.SC_Obelisk_Impact') 
	ImpactEffects(6)=(MaterialType=Water, ParticleTemplate=ParticleSystem'S_BU_Oblisk.Effects.P_Obelisk_Impact', Sound=SoundCue'RX_BU_Oblisk.Sounds.SC_Obelisk_Impact')
    ImpactEffects(7)=(MaterialType=Liquid, ParticleTemplate=ParticleSystem'S_BU_Oblisk.Effects.P_Obelisk_Impact', Sound=SoundCue'RX_BU_Oblisk.Sounds.SC_Obelisk_Impact')
	ImpactEffects(8)=(MaterialType=Flesh, ParticleTemplate=ParticleSystem'S_BU_Oblisk.Effects.P_Obelisk_Impact', Sound=SoundCue'RX_BU_Oblisk.Sounds.SC_Obelisk_Impact')
	ImpactEffects(9)=(MaterialType=TiberiumGround, ParticleTemplate=ParticleSystem'S_BU_Oblisk.Effects.P_Obelisk_Impact', Sound=SoundCue'RX_BU_Oblisk.Sounds.SC_Obelisk_Impact')
	ImpactEffects(10)=(MaterialType=TiberiumCrystal, ParticleTemplate=ParticleSystem'S_BU_Oblisk.Effects.P_Obelisk_Impact', Sound=SoundCue'RX_BU_Oblisk.Sounds.SC_Obelisk_Impact')
	ImpactEffects(11)=(MaterialType=TiberiumGroundBlue, ParticleTemplate=ParticleSystem'S_BU_Oblisk.Effects.P_Obelisk_Impact', Sound=SoundCue'RX_BU_Oblisk.Sounds.SC_Obelisk_Impact')
	ImpactEffects(12)=(MaterialType=TiberiumCrystalBlue, ParticleTemplate=ParticleSystem'S_BU_Oblisk.Effects.P_Obelisk_Impact', Sound=SoundCue'RX_BU_Oblisk.Sounds.SC_Obelisk_Impact')
	ImpactEffects(13)=(MaterialType=Mud, ParticleTemplate=ParticleSystem'S_BU_Oblisk.Effects.P_Obelisk_Impact', Sound=SoundCue'RX_BU_Oblisk.Sounds.SC_Obelisk_Impact')
	ImpactEffects(14)=(MaterialType=WhiteSand, ParticleTemplate=ParticleSystem'S_BU_Oblisk.Effects.P_Obelisk_Impact', Sound=SoundCue'RX_BU_Oblisk.Sounds.SC_Obelisk_Impact')
	ImpactEffects(15)=(MaterialType=YellowSand, ParticleTemplate=ParticleSystem'S_BU_Oblisk.Effects.P_Obelisk_Impact', Sound=SoundCue'RX_BU_Oblisk.Sounds.SC_Obelisk_Impact')
	ImpactEffects(16)=(MaterialType=Grass, ParticleTemplate=ParticleSystem'S_BU_Oblisk.Effects.P_Obelisk_Impact', Sound=SoundCue'RX_BU_Oblisk.Sounds.SC_Obelisk_Impact')
	ImpactEffects(17)=(MaterialType=YellowStone, ParticleTemplate=ParticleSystem'S_BU_Oblisk.Effects.P_Obelisk_Impact', Sound=SoundCue'RX_BU_Oblisk.Sounds.SC_Obelisk_Impact')
	DefaultImpactEffect=(ParticleTemplate=ParticleSystem'S_BU_Oblisk.Effects.P_Obelisk_Impact', Sound=SoundCue'RX_BU_Oblisk.Sounds.SC_Obelisk_Impact')

    End Object
    HitEffects=HitEffectsComp

    Begin Object Name=WindUpSound0
        SoundCue=SoundCue'S_BU_Oblisk.Sounds.SC_Obelisk_ChargeUp'
        bStopWhenOwnerDestroyed=true
    End Object
}
