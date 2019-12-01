class Rx_MapInfo_Survival extends Rx_MapInfo_Cooperative;

struct InfantryWaveStruct
{
	var() class<Rx_FamilyInfo> InfantryClass;
	var() Int BaseNumber;
	var() float PerPlayerMultiplier;
	var() float DamageTakenMultiplier;
	var() float DamageDealtMultiplier;
	var() float PerPlayerDamageTakenMod;
	var() float PerPlayerDamageDealtMod;
	var() bool bIsBoss;


	structdefaultproperties
	{
		DamageTakenMultiplier=1.f
		DamageDealtMultiplier=1.f
		PerPlayerDamageTakenMod=1.f
		PerPlayerDamageDealtMod=1.f
	}
};

struct VehicleWaveStruct
{
	var() class<Rx_Vehicle> VehicleClass;
	var() Int BaseNumber;
	var() float PerPlayerMultiplier;
	var() float DamageTakenMultiplier;
	var() float DamageDealtMultiplier;
	var() float PerPlayerDamageTakenMod;
	var() float PerPlayerDamageDealtMod;
	var() bool bIsBoss;


	structdefaultproperties
	{
		DamageTakenMultiplier=1.f
		DamageDealtMultiplier=1.f
		PerPlayerDamageTakenMod=1.f
		PerPlayerDamageDealtMod=1.f
	}
};

// Yo dawg, I heard you like structs.

struct WaveStruct
{
	var() Array<InfantryWaveStruct> InfantryWaves;
	var() Array<VehicleWaveStruct> VehicleWaves;
};

var(Survival) Array<WaveStruct> Wave;