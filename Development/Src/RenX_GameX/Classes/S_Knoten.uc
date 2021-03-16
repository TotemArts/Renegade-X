class S_Knoten extends Actor;

//heil germany

var bool zeichner;
var bool hasSpawnedcc;
var bool b;
var bool b2;
var float fov;
var float time;
var int i;
var int z; // counts points / Knoten
var rotator rotat;
var S_CamControl cc;
var S_Knoten knoten2, other;
var bool bForC130 ;

function PostBeginPlay()
{
	local S_CamControl Other2;
	local Demorecspectator drs;
	hasSpawnedcc = false;

	z = 0;
	zeichner = false;
	rotat = rot( 0, 0, 0 );
	setRotation( rotat );
	b = false;
	b2 = false;
	
	if(CamControl(owner) != None) {
		bForC130 = CamControl(owner).bForC130;	
	}

	fov = 100;
	time = worldinfo.timeseconds;
	foreach AllActors( class'S_CamControl', Other2 ) {
		if(Other2.bForC130 != bForC130) {
			continue;
		}
		b = Other2.I_want_to_insert_a_Flag;
		b2 = other2.is_spawning;
		cc = Other2;
	}

	foreach AllActors( class'S_Knoten', Other ) {
		if(Other.bForC130 != bForC130) {
			continue;
		}
		z++;
	}

	if ( !b2 ) {
		if ( cc != none && cc.justspawn ) {
			return;
		}

		knoten2 = self;
		i = 0;
		foreach AllActors( class'S_Knoten', Other ) {
			if(Other.bForC130 != bForC130) {
				continue;
			}			
			i++;

			if ( i == z - 1 ) {
				knoten2 = Other;
			}
		}

		if(!bForC130) {
			foreach AllActors( class'Demorecspectator', drs ) {
				rotat.yaw = drs.viewtarget.rotation.yaw;
				rotat.pitch = drs.viewtarget.rotation.pitch;
	
				if ( abs( rotat.yaw - knoten2.rotation.yaw ) > 32768 ) {
					while ( abs( rotat.yaw - knoten2.rotation.yaw ) > 32768 ) {
						if ( rotat.yaw > knoten2.rotation.yaw ) {
							rotat.yaw = rotat.yaw - 65536;
						} else {
							rotat.yaw = rotat.yaw + 65536;
						}
					}
				} else {
					rotat.yaw = drs.viewtarget.Rotation.yaw;
				}
				if ( abs( rotat.pitch - knoten2.rotation.pitch ) > 32768 ) {
					while ( abs( rotat.pitch - knoten2.rotation.pitch ) > 32768 )
						if ( rotat.pitch > knoten2.rotation.pitch ) {
							rotat.pitch = rotat.pitch - 65536;
						} else {
							rotat.pitch = rotat.pitch + 65536;
						}
				} else {
					rotat.pitch = drs.viewtarget.Rotation.pitch;
				}
				setlocation( drs.viewtarget.Location );
				setRotation( rotat );
				break;
			}
		}
	}

	if ( !b ) {
		if ( z == 4 ) { // begin interpolation
			zeichner = true;    // this point will draw the interpolation
		}
	}

	if ( b ) {
		cc.FlagEinfuegen();
	}
}

function updateSpline()
{
	local S_CamControl OtherCC;
	foreach AllActors( class'S_CamControl', OtherCC ) {
		if(OtherCC.bForC130 != bForC130) {
			continue;
		}	
		hasSpawnedcc = true;   // CamControl config was already loaded from the ini
		cc = OtherCC;
	}

	if ( !hasSpawnedcc ) {
		cc = Spawn( class'S_CamControl' );
		if(!bForC130) {
			cc.init();
		}
		hasSpawnedcc = true;
	}

	cc.updateSplinef( true );
}

function float GetCurrentFrame() 
{
	local int CurrentFrame;
	worldinfo.GetDemoFrameInfo(CurrentFrame);
	return CurrentFrame;
}

defaultproperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EngineResources.Cursors.SplitterHorz'
	End Object
	Components.Add(Sprite)
	bAlwaysTick = True
}
