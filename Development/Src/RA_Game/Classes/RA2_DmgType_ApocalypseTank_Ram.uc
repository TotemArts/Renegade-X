/*********************************************************
*
* File: RA2_DmgType_ApocalypseTank_Ram.uc
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
class RA2_DmgType_ApocalypseTank_Ram extends Rx_DmgType
	abstract;

static function int IncrementKills(UTPlayerReplicationInfo KillerPRI)
{
	local int KillCount;
	KillCount = KillerPRI.IncrementKillStat(static.GetStatsName('KILLS'));
	return KillCount;
}

static function SpawnHitEffect(Pawn P, float Damage, vector Momentum, name BoneName, vector HitLocation)
{
	Super.SpawnHitEffect(P,Damage,Momentum,BoneName,HitLocation);
	if(UTPawn(P) != none)
	{
		UTPawn(P).SoundGroupClass.Static.PlayCrushedSound(P);
	}
}

defaultproperties
{
	MCTDamageScaling=2.0 // stacks with BuildingDamageScaling
	MineDamageScaling=0.5
	BuildingDamageScaling=0.1
    lightArmorDmgScaling=0.1
    VehicleDamageScaling=0.1
	AircraftDamageScaling=0.5 //This is only used by a damage type if the value is greater than 0, otherwise it treats an aircraft like Light armour.
	
	////Infantry Armour Types//////
	Inf_FLAKDamageScaling = 5.0     //FLAK infantry armour (Standard rule is splash damage does  30% less, while gun damage does 30% more)
	Inf_KevlarDamageScaling = 5.0	//Kevlar (General rule is 15% less damage from direct hits/bullets, but no penalties) - EDIT: 20%
	Inf_LazarusDamageScaling = 5.0  // Lazarus SBH armour, standard rule is +40% to Electrical damage but likely no other damage modifiers.
	Inf_NoArmourDamageScaling = 5.0 //Damage modifier for no armour

	KDamageImpulse=3000
	KDeathUpKick=200

	KillStatsName=EVENT_RANOVERKILLS
	DeathStatsName=EVENT_RANOVERDEATHS
	SuicideStatsName=SUICIDES_ENVIRONMENT
	GibPerterbation=0.5
	bLocationalHit=false
	bNeverGibs=true
	bUseTearOffMomentum=true
	bExtraMomentumZ=false
	bVehicleHit=true
	AlwaysGibDamageThreshold=0
	RewardAnnouncementSwitch=0
	bThrowRagdoll=true
    bBulletHit=false
    bCausesBloodSplatterDecals=true
    bCausesBlood=true
	GibTrail=ParticleSystem'RX_CH_Gibs.Effects.P_BloodTrail'

	IconTextureName="T_VehicleIcon_ApocalypseTank"
	IconTexture=Texture2D'RA2_VH_ApocalypseTank.Textures.T_DeathIcon_ApocalypseTank'
}
