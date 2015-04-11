class Rx_Jukebox extends Object;

struct RxJukeBoxStruct
{
	/** The soundCue to play */
	var() SoundCue TheSoundCue;

	/** The Track Name*/
	var() string TrackName;

	/** Whether this track is selected to be play*/
	var() bool bSelected;
	
	/** Time taken for sound to fade in when action is activated. */
	var() float FadeInTime;

	/** Volume the sound to should fade in to */
	var() float FadeInVolumeLevel;

	/** Time take for sound to fade out when Stop input is fired. */
	var() float FadeOutTime;

	/** Volume the sound to should fade out to */
	var() float FadeOutVolumeLevel;
	
	structdefaultproperties
	{
		bSelected=true;
		FadeInTime=5.0f
		FadeInVolumeLevel=1.0f
		FadeOutTime=5.0f
		FadeOutVolumeLevel=0.0f
	}
};

var array<RxJukeBoxStruct> JukeBoxList;
var RxJukeBoxStruct CurrentTrack;

var AudioComponent MusicComp;

var() bool bShuffled;
var() bool bStopped;

function Init() 
{
	local int i;

	MusicComp = class'WorldInfo'.static.GetWorldInfo().MusicComp;
	
	if (MusicComp == none) {
		MusicComp = class'WorldInfo'.static.GetWorldInfo().CreateAudioComponent(JukeBoxList[0].TheSoundCue, false);
	}
	//MusicComp.AdjustVolume(1,0.75f);
	`log("MusicComp.CurrentVolume? " $ MusicComp.CurrentVolume);
	MusicComp.bAutoDestroy = false;
	//MusicComp.AdjustVolume(1,0.75f);

	//if we're playing a music
	if (MusicComp.IsPlaying()) {
		//check if we're playing map song or our track
		i = JukeBoxList.Find('TheSoundCue', MusicComp.SoundCue);
		if (i >= 0) {
			CurrentTrack = JukeBoxList[i];
		}
	}
}


function Play(int index) 
{
	local byte i;
	if (!JukeBoxList[index].bSelected) {

		if (index + 1 < JukeBoxList.Length) {
			index++;
		} else {
			index = 0;
		}

		for (i = index; i < JukeBoxList.Length; i++) {
			if (JukeBoxList[i].bSelected){
				CurrentTrack = JukeBoxList[i];
				break;
			}
			CurrentTrack.TheSoundCue = none;
		}

		if (CurrentTrack.TheSoundCue == none) {
			return;
		}
	} else {
		CurrentTrack = JukeBoxList[index];
	}
	bStopped = false;
	MusicComp.SoundCue = CurrentTrack.TheSoundCue;
	MusicComp.Play();
}

function Stop()
{
	bStopped = true;
	MusicComp.Stop();
}

DefaultProperties
{
	bShuffled = true;
	bStopped = false;

	//Use this for test
	//JukeBoxList(6) = (TrackName="Test", TheSoundCue=SoundCue'RX_EVA_VoiceClips.gdi_eva.S_EVA_GDI_Beacon_NuclearStrikeImminent_Cue')

	JukeBoxList(0) = (TrackName="Full Stop", TheSoundCue=SoundCue'RX_jukebox_03.Cue.Full_Stop')
	JukeBoxList(1) = (TrackName="Just do it up", TheSoundCue=SoundCue'RX_jukebox_03.Cue.Just_do_it_up')
	JukeBoxList(2) = (TrackName="Rampage", TheSoundCue=SoundCue'RX_jukebox_03.Cue.Rampage')
	JukeBoxList(3) = (TrackName="Serenity", TheSoundCue=SoundCue'RX_jukebox_03.Cue.Serenity')
	JukeBoxList(4) = (TrackName="Stomp", TheSoundCue=SoundCue'RX_jukebox_03.Cue.Stomp')
	JukeBoxList(5) = (TrackName="The Dead Six", TheSoundCue=SoundCue'RX_jukebox_03.Cue.The_Dead_Six')
	JukeBoxList(6) = (TrackName="Valiant", TheSoundCue=SoundCue'RX_jukebox_03.Cue.Valiant')

	JukeBoxList(7) = (TrackName="Got a Present For Ya", TheSoundCue=SoundCue'RX_jukebox_02.Cue.Got_a_Present_For_Ya')
	JukeBoxList(8) = (TrackName="In the Line of Fire", TheSoundCue=SoundCue'RX_jukebox_02.Cue.In_the_Line_of_Fire')
	JukeBoxList(9) = (TrackName="Industrial", TheSoundCue=SoundCue'RX_jukebox_02.Cue.Industrial')
	JukeBoxList(10) = (TrackName="March to Doom", TheSoundCue=SoundCue'RX_jukebox_02.Cue.March_to_Doom')
	JukeBoxList(11) = (TrackName="Move It", TheSoundCue=SoundCue'RX_jukebox_02.Cue.Move_It')
	JukeBoxList(12) = (TrackName="No Mercy", TheSoundCue=SoundCue'RX_jukebox_02.Cue.No_Mercy')

	JukeBoxList(13) = (TrackName="Act on Instinct", TheSoundCue=SoundCue'RX_jukebox_01.Cue.Act_on_Instinct')
	JukeBoxList(14) = (TrackName="Another Present For Ya", TheSoundCue=SoundCue'RX_jukebox_01.Cue.Another_Present_For_Ya')
	JukeBoxList(15) = (TrackName="Blinded", TheSoundCue=SoundCue'RX_jukebox_01.Cue.Blinded')
	JukeBoxList(16) = (TrackName="On The Prowl", TheSoundCue=SoundCue'RX_jukebox_01.Cue.CNC_OnTheProwl')
	JukeBoxList(17) = (TrackName="Command and Conquer", TheSoundCue=SoundCue'RX_jukebox_01.Cue.Command_and_Conquer')
	JukeBoxList(18) = (TrackName="Death Awaits", TheSoundCue=SoundCue'RX_jukebox_01.Cue.Death_Awaits')
}
