/*********************************************************
*
* File: RxVoice.uc
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

class Rx_Pawn_VoiceClass extends Object //UTVoice_Robot
	abstract;


var Array<SoundNodeWave> TauntSounds;
var Array<string> 		 TauntLines;
var Array<SoundNodeWave> KillConfirmSounds;
var Array<SoundNodeWave> DestroyVehicleSounds;
var Array<SoundNodeWave> DeathSounds;
var Array<SoundNodeWave> TakeDamageSounds;
var Array<SoundNodeWave> BuildingDestroyedSounds;
var Array<SoundNodeWave> AssistSounds;
var float				 PersonalVolumeModifier;
	
static function SoundNodeWave GetTauntSound(int Index)
{
	if(default.TauntSounds.Length == 0) return none;
	if(Index > default.TauntSounds.Length) Index = default.TauntSounds.Length-1; 
	return default.TauntSounds[max(Index,0)]; 
}

static function SoundNodeWave GetKillConfirmSound(int Index)
{
	if(default.KillConfirmSounds.Length == 0) return none;
	if(Index >= default.KillConfirmSounds.Length) Index = default.KillConfirmSounds.Length-1; 
	return default.KillConfirmSounds[max(Index,0)]; 
}
	
static function SoundNodeWave GetDestroyVehicleSound(int Index)
{
	if(default.DestroyVehicleSounds.Length == 0) return none;
	if(Index >= default.DestroyVehicleSounds.Length) Index = default.DestroyVehicleSounds.Length-1; 
	return default.DestroyVehicleSounds[max(Index,0)]; 
}

static function SoundNodeWave GetDeathSound(int Index)
{
	if(default.DeathSounds.Length == 0) return none;
	if(Index >= default.DeathSounds.Length) Index = default.DeathSounds.Length-1; 
	return default.DeathSounds[max(Index,0)]; 
}

static function SoundNodeWave GetTakeDamageSound(int Index)
{
	if(default.TakeDamageSounds.Length == 0) return none;
	if(Index >= default.TakeDamageSounds.Length) Index = default.TakeDamageSounds.Length-1; 
	return default.TakeDamageSounds[max(Index,0)]; 
}

static function SoundNodeWave GetBuildingDestroyedSound(int Index)
{
	if(default.BuildingDestroyedSounds.Length == 0) return none;
	if(Index >= default.BuildingDestroyedSounds.Length) Index = default.BuildingDestroyedSounds.Length-1; 
	return default.BuildingDestroyedSounds[max(Index,0)]; 
}

static function SoundNodeWave GetAssistSound(int Index)
{
	if(default.AssistSounds.Length == 0) return none; 
	if(Index >= default.AssistSounds.Length) Index = default.AssistSounds.Length-1; 
	return default.AssistSounds[max(Index,0)]; 
}
	
defaultproperties
{
TauntSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.S_Soldier_GDI_Affirmative_02'
TauntLines(0)="Affirmative."
KillConfirmSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.S_Soldier_GDI_Affirmative_02'
DestroyVehicleSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.S_Soldier_GDI_Affirmative_02'
DeathSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.S_Soldier_GDI_Affirmative_02'
TakeDamageSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.S_Soldier_GDI_Affirmative_02'
//BuildingDestroyedSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.S_Soldier_GDI_Affirmative_02'
//AssistSounds(0)=SoundNodeWave'RX_CharSnd_Generic.gdi_male.S_Soldier_GDI_Affirmative_02'

PersonalVolumeModifier=0.50
}





