class Rx_Jukebox extends Object
config(XSettings);

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

var config array<RxJukeBoxStruct> JukeBoxList;
var RxJukeBoxStruct CurrentTrack;

var AudioComponent MusicComp;

var() bool bShuffled;
var() bool bStopped;

function Init() 
{
	local int i;
	local bool initTracks;

	//set initial values (nBab)
	JukeBoxList.length = 19;

	initTracks = false;
	for (i=0;i<JukeBoxList.length;i++)
		if (JukeBoxList[i].TrackName == "")
			initTracks = true;
	if (initTracks)
	{
		JukeBoxList[0].TrackName="Full Stop"; JukeBoxList[0].TheSoundCue=SoundCue'RX_jukebox_03.Cue.Full_Stop';
		JukeBoxList[1].TrackName="Just do it up"; JukeBoxList[1].TheSoundCue=SoundCue'RX_jukebox_03.Cue.Just_do_it_up';
		JukeBoxList[2].TrackName="Rampage"; JukeBoxList[2].TheSoundCue=SoundCue'RX_jukebox_03.Cue.Rampage';
		JukeBoxList[3].TrackName="Serenity"; JukeBoxList[3].TheSoundCue=SoundCue'RX_jukebox_03.Cue.Serenity';
		JukeBoxList[4].TrackName="Stomp"; JukeBoxList[4].TheSoundCue=SoundCue'RX_jukebox_03.Cue.Stomp';
		JukeBoxList[5].TrackName="The Dead Six"; JukeBoxList[5].TheSoundCue=SoundCue'RX_jukebox_03.Cue.The_Dead_Six';
		JukeBoxList[6].TrackName="Valiant"; JukeBoxList[6].TheSoundCue=SoundCue'RX_jukebox_03.Cue.Valiant';
		JukeBoxList[7].TrackName="Got a Present For Ya"; JukeBoxList[7].TheSoundCue=SoundCue'RX_jukebox_02.Cue.Got_a_Present_For_Ya';
		JukeBoxList[8].TrackName="In the Line of Fire"; JukeBoxList[8].TheSoundCue=SoundCue'RX_jukebox_02.Cue.In_the_Line_of_Fire';
		JukeBoxList[9].TrackName="Industrial"; JukeBoxList[9].TheSoundCue=SoundCue'RX_jukebox_02.Cue.Industrial';
		JukeBoxList[10].TrackName="March to Doom"; JukeBoxList[10].TheSoundCue=SoundCue'RX_jukebox_02.Cue.March_to_Doom';
		JukeBoxList[11].TrackName="Move It"; JukeBoxList[11].TheSoundCue=SoundCue'RX_jukebox_02.Cue.Move_It';
		JukeBoxList[12].TrackName="No Mercy"; JukeBoxList[12].TheSoundCue=SoundCue'RX_jukebox_02.Cue.No_Mercy';
		JukeBoxList[13].TrackName="Act on Instinct"; JukeBoxList[13].TheSoundCue=SoundCue'RX_jukebox_01.Cue.Act_on_Instinct';
		JukeBoxList[14].TrackName="Another Present For Ya"; JukeBoxList[14].TheSoundCue=SoundCue'RX_jukebox_01.Cue.Another_Present_For_Ya';
		JukeBoxList[15].TrackName="Blinded"; JukeBoxList[15].TheSoundCue=SoundCue'RX_jukebox_01.Cue.Blinded';
		JukeBoxList[16].TrackName="On The Prowl"; JukeBoxList[16].TheSoundCue=SoundCue'RX_jukebox_01.Cue.CNC_OnTheProwl';
		JukeBoxList[17].TrackName="Command and Conquer"; JukeBoxList[17].TheSoundCue=SoundCue'RX_jukebox_01.Cue.Command_and_Conquer';
		JukeBoxList[18].TrackName="Death Awaits"; JukeBoxList[18].TheSoundCue=SoundCue'RX_jukebox_01.Cue.Death_Awaits';
		saveconfig();
	}

	MusicComp = class'WorldInfo'.static.GetWorldInfo().MusicComp;
	
	if (MusicComp == none) {
		MusicComp = class'WorldInfo'.static.GetWorldInfo().CreateAudioComponent(JukeBoxList[0].TheSoundCue, false);
	}
	
	//MusicComp.AdjustVolume(1,0.75f);
	`log("MusicComp.CurrentVolume? " $ MusicComp.CurrentVolume);
	MusicComp.bAutoDestroy = false;
	//MusicComp.AdjustVolume(1,0.75f);

	//if we're playing a music
	if (MusicComp.IsPlaying())
	{
		//check if we're playing map song or our track
		i = JukeBoxList.Find('TheSoundCue', MusicComp.SoundCue);
		if (i >= 0)
			CurrentTrack = JukeBoxList[i];
	}
}


function Play(int index) 
{
	local byte i;

	if (!JukeBoxList[index].bSelected)
	{
		//old code (nBab)
		/*if (index + 1 < JukeBoxList.Length)
			index++;
		else
			index = 0;

		for (i = index; i < JukeBoxList.Length; i++)
		{
			if (JukeBoxList[i].bSelected)
			{
				CurrentTrack = JukeBoxList[i];
				break;
			}
			CurrentTrack.TheSoundCue = none;
		}*/

		//select the next song that is bSelected (nBab)
		CurrentTrack.TheSoundCue = none;
		for (i = 0; i < JukeBoxList.Length; i++)
		{
			if (JukeBoxList[index].bSelected)
			{
				CurrentTrack = JukeBoxList[index];
				break;
			}

			if (index + 1 < JukeBoxList.Length)
				index++;
			else
				index = 0;
		}


		if (CurrentTrack.TheSoundCue == none)
			return;
	}
	else
		CurrentTrack = JukeBoxList[index];

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

	//commented because these are config now (nBab)
	/*JukeBoxList(0) = (TrackName="Full Stop", TheSoundCue=SoundCue'RX_jukebox_03.Cue.Full_Stop')
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
	JukeBoxList(18) = (TrackName="Death Awaits", TheSoundCue=SoundCue'RX_jukebox_01.Cue.Death_Awaits')*/
}
