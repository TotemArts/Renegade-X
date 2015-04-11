/** Specialised use class for Rx_Vehicle */
class Rx_Speaker extends Actor;

simulated function PlaySoundAt(SoundCue SndCue, vector SndLocation)
{
	PlaySound(SndCue, true, ,,SndLocation);
}

DefaultProperties
{
}
