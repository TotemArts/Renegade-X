class Rx_Airstrike_A10 extends Rx_Airstrike_Vehicle;

var array<ActorComponent>   SessionAComps;
var array<ActorComponent>   SessionBComps;
var array<ActorComponent>   SessionCComps;

simulated function InitialSetup()
{
	local int i;

	super.InitialSetup(); 

	// A plane
	CreateEvent(0.f, a_s0);
	CreateEvent(2.f, a_s2);
	CreateEvent(4.f, a_s4);
	CreateEvent(16.67f, a_end);

	// bombs A
	CreateEvent(5.7f, a_bomb_1);
	CreateEvent(5.8f, a_bomb_2);
	CreateEvent(5.9f, a_bomb_3);
	CreateEvent(6.0f, a_bomb_4);

	// gun fire A
	for (i = 0; i < 20; i++)
		CreateEvent(4.05f + i * 0.05f, a_gun);

	// B plane
	CreateEvent(3.f, b_s0);
	CreateEvent(5.f, b_s2);
	CreateEvent(7.f, b_s4);
	CreateEvent(19.67f, b_end);

	// bombs B
	CreateEvent(8.7f, b_bomb_1);
	CreateEvent(8.8f, b_bomb_2);
	CreateEvent(8.9f, b_bomb_3);
	CreateEvent(9.0f, b_bomb_4);

	// gun fire B
	for (i = 0; i < 20; i++)
		CreateEvent(7.05f + i * 0.05f, b_gun);

	// C plane
	CreateEvent(6.f, c_s0);
	CreateEvent(8.f, c_s2);
	CreateEvent(10.f, c_s4);
	CreateEvent(22.67f, c_end);

	// bombs B
	CreateEvent(11.7f, c_bomb_1);
	CreateEvent(11.8f, c_bomb_2);
	CreateEvent(11.9f, c_bomb_3);
	CreateEvent(12.0f, c_bomb_4);

	// gun fire B
	for (i = 0; i < 20; i++)
		CreateEvent(10.05f + i * 0.05f, c_gun);
}

// A plane
simulated function a_s0()
{
	AttachParticleEffect(ParticleSystem'RX_VH_A-10.Effects.P_A-10_Jet_Large', 'A_A10_Jet_1', true, SessionAComps);
	AttachParticleEffect(ParticleSystem'RX_VH_A-10.Effects.P_A-10_Jet_Large', 'A_A10_Jet_2', true, SessionAComps);
	AttachParticleEffect(ParticleSystem'RX_VH_A-10.Effects.P_A-10_WingTip_Large', 'A_A10_WingTip_1', true, SessionAComps);
	AttachParticleEffect(ParticleSystem'RX_VH_A-10.Effects.P_A-10_WingTip_Large', 'A_A10_WingTip_2', true, SessionAComps);
}

simulated function a_s2()
{
	AttachAudio(SoundCue'RX_VH_A-10.Sounds.SC_A-10_FlyOver', 'A_A10_Base', true, SessionAComps);
}

simulated function a_s4()
{
	AttachParticleEffect(ParticleSystem'RX_VH_A-10.Effects.P_MuzzleFlash_Gun_AirStrike', 'A_A10_Gun', true, SessionAComps);
	AttachAudio(SoundCue'RX_VH_A-10.Sounds.SC_A-10_Airstrike_Gun', 'A_A10_Gun', true, SessionAComps);
	
	a_gun();
//	a_bomb_1();
}

simulated function a_gun()
{
	InitiateProjectile(class'RenX_Game.Rx_Vehicle_A10_GattlingGun', 'A_A10_Gun', 'A_A10_HitLoc_Gun');
}

simulated function a_bomb_1()
{
	InitiateProjectile(class' RenX_Game.Rx_Vehicle_A10_Bombs', 'A_A10_Bomb_1', 'A_A10_HitLoc_Bomb_1');
}

simulated function a_bomb_2()
{
	InitiateProjectile(class' RenX_Game.Rx_Vehicle_A10_Bombs', 'A_A10_Bomb_2', 'A_A10_HitLoc_Bomb_2');
}

simulated function a_bomb_3()
{
	InitiateProjectile(class' RenX_Game.Rx_Vehicle_A10_Bombs', 'A_A10_Bomb_3', 'A_A10_HitLoc_Bomb_3');
}

simulated function a_bomb_4()
{
	InitiateProjectile(class' RenX_Game.Rx_Vehicle_A10_Bombs', 'A_A10_Bomb_4', 'A_A10_HitLoc_Bomb_4');
}

simulated event a_end()
{
	RemoveComponents(SessionAComps);
}


// B plane
simulated function b_s0()
{
	AttachParticleEffect(ParticleSystem'RX_VH_A-10.Effects.P_A-10_Jet_Large', 'B_A10_Jet_1', true, SessionBComps);
	AttachParticleEffect(ParticleSystem'RX_VH_A-10.Effects.P_A-10_Jet_Large', 'B_A10_Jet_2', true, SessionBComps);
	AttachParticleEffect(ParticleSystem'RX_VH_A-10.Effects.P_A-10_WingTip_Large', 'B_A10_WingTip_1', true, SessionBComps);
	AttachParticleEffect(ParticleSystem'RX_VH_A-10.Effects.P_A-10_WingTip_Large', 'B_A10_WingTip_2', true, SessionBComps);
}

simulated function b_s2()
{
	AttachAudio(SoundCue'RX_VH_A-10.Sounds.SC_A-10_FlyOver', 'B_A10_Base', true, SessionBComps);
}

simulated function b_s4()
{
	AttachParticleEffect(ParticleSystem'RX_VH_A-10.Effects.P_MuzzleFlash_Gun_AirStrike', 'B_A10_Gun', true, SessionBComps);
	AttachAudio(SoundCue'RX_VH_A-10.Sounds.SC_A-10_Airstrike_Gun', 'B_A10_Gun', true, SessionBComps);
	
	b_gun();
//	b_bomb_1();
}

simulated function b_gun()
{
	InitiateProjectile(class'RenX_Game.Rx_Vehicle_A10_GattlingGun', 'B_A10_Gun', 'B_A10_HitLoc_Gun');
}

simulated function b_bomb_1()
{
	InitiateProjectile(class' RenX_Game.Rx_Vehicle_A10_Bombs', 'B_A10_Bomb_1', 'B_A10_HitLoc_Bomb_1');
}

simulated function b_bomb_2()
{
	InitiateProjectile(class' RenX_Game.Rx_Vehicle_A10_Bombs', 'B_A10_Bomb_2', 'B_A10_HitLoc_Bomb_2');
}

simulated function b_bomb_3()
{
	InitiateProjectile(class' RenX_Game.Rx_Vehicle_A10_Bombs', 'B_A10_Bomb_3', 'B_A10_HitLoc_Bomb_3');
}

simulated function b_bomb_4()
{
	InitiateProjectile(class' RenX_Game.Rx_Vehicle_A10_Bombs', 'B_A10_Bomb_4', 'B_A10_HitLoc_Bomb_4');
}

simulated event b_end()
{
	RemoveComponents(SessionBComps);
}


// C plane
simulated function c_s0()
{
	AttachParticleEffect(ParticleSystem'RX_VH_A-10.Effects.P_A-10_Jet_Large', 'C_A10_Jet_1', true, SessionCComps);
	AttachParticleEffect(ParticleSystem'RX_VH_A-10.Effects.P_A-10_Jet_Large', 'C_A10_Jet_2', true, SessionCComps);
	AttachParticleEffect(ParticleSystem'RX_VH_A-10.Effects.P_A-10_WingTip_Large', 'C_A10_WingTip_1', true, SessionCComps);
	AttachParticleEffect(ParticleSystem'RX_VH_A-10.Effects.P_A-10_WingTip_Large', 'C_A10_WingTip_2', true, SessionCComps);
}

simulated function c_s2()
{
	AttachAudio(SoundCue'RX_VH_A-10.Sounds.SC_A-10_FlyOver', 'C_A10_Base', true, SessionCComps);
}

simulated function c_s4()
{
	AttachParticleEffect(ParticleSystem'RX_VH_A-10.Effects.P_MuzzleFlash_Gun_AirStrike', 'C_A10_Gun', true, SessionCComps);
	AttachAudio(SoundCue'RX_VH_A-10.Sounds.SC_A-10_Airstrike_Gun', 'C_A10_Gun', true, SessionCComps);
	
	c_gun();
//	c_bomb_1();
}

simulated function c_gun()
{
	InitiateProjectile(class'RenX_Game.Rx_Vehicle_A10_GattlingGun', 'C_A10_Gun', 'C_A10_HitLoc_Gun');
}

simulated function c_bomb_1()
{
	InitiateProjectile(class' RenX_Game.Rx_Vehicle_A10_Bombs', 'C_A10_Bomb_1', 'C_A10_HitLoc_Bomb_1');
}

simulated function c_bomb_2()
{
	InitiateProjectile(class' RenX_Game.Rx_Vehicle_A10_Bombs', 'C_A10_Bomb_2', 'C_A10_HitLoc_Bomb_2');
}

simulated function c_bomb_3()
{
	InitiateProjectile(class' RenX_Game.Rx_Vehicle_A10_Bombs', 'C_A10_Bomb_3', 'C_A10_HitLoc_Bomb_3');
}

simulated function c_bomb_4()
{
	InitiateProjectile(class' RenX_Game.Rx_Vehicle_A10_Bombs', 'C_A10_Bomb_4', 'C_A10_HitLoc_Bomb_4');
}

simulated event c_end()
{
	RemoveComponents(SessionCComps);
}


DefaultProperties
{
	Begin Object Name=WSkeletalMesh
		SkeletalMesh=SkeletalMesh'RX_VH_A-10.Mesh.SK_VH_A-10_Airstrike'
		PhysicsAsset=PhysicsAsset'RX_VH_A-10.Mesh.SK_VH_A-10_Airstrike_Physics'
		AnimSets(0)=AnimSet'RX_VH_A-10.Anim.AS_A10_Airstrike'
		AnimTreeTemplate=AnimTree'RX_VH_A-10.Anim.AT_A10_Airstrike'
	End Object

	LifeSpan=23.f

	ProjectileDirectionSpreadMulti=100.f
	ApproachingSound=SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_AirStrikeEnRoute_Cue'
}
