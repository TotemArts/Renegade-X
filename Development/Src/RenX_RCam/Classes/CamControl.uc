//-----------------------------------------------------------
//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CamControl extends actor
		config( RypelCam );


struct TMultiArray
{
	var array<int> Y;
};
var TMultiArray M[2000];

var float dif_tpstart;
var float dif_tpstart_temp;
var bool dif_tpstart_add;
var bool dif_tpstart_subtract;
var bool bpcam;

var vector TargetLocation;
var rotator Targetrotation;
var int drawcount;
var bool startCam;
var config int Z; // counts points / Knoten
var config int drawdetail;
var config float basic_speed2;     // zwischnespeicher für basic_speed
var bool draw_Spline;
var bool I_want_to_insert_a_Flag;
var int insert_after_Flag;
var bool remove_the_specified_Flag;
var int remove_Flag;
var int viewing;
var config float kabstand;
var config float mabstand;
var config array<vector> Flag_Locations;
var config array<rotator> Rotation_At_Flags;
var config array<float> Flag_Fovs;
var array<float> Flag_Dist;
var config array<float> Flag_Times;
var bool combineLoc;
var vector v;
var vector v2;
var float t;
var float pathlenght;
var bool ssw;
var actor thisTarget;
var bool enable2;
var int flag_count;
var config array<float> X; // abscissa values, for timeline
var bool start;
var rotator rotat;
var rotator rotat2;
var Viewer viewer01;
var config bool conf;
var bool drawSplineWasFalse;
var bool justSpawn; // spawn points /Knoten without updating
var DemoRecSpectator drs;
var bool is_spawning;       // wenn true knoten nicht nach drs ausrichten
var bool rollplus, rollminus;
var float fov;
var bool fovplus, fovminus;
var float tfov;
var float dist;
var bool btimedpath;
var float carry;
var array<float> derivates;
var bool bisdrawing;
var config bool bxedited;
var int j;
var float d1;
var int n;
var Knoten OtherKnot;
var rotknoten Other2Rot;
var float tempdist;
var vector v3;
var rotator tr;
var bool bForC130;

var array<float> a_a;
var array<float> a_b;
var array<float> a_c;
var array<float> a_d;
var array<float> b_a;
var array<float> b_b;
var array<float> b_c;
var array<float> b_d;
var array<float> c_a;
var array<float> c_b;
var array<float> c_c;
var array<float> c_d;
var array<float> yaw_a;
var array<float> yaw_b;
var array<float> yaw_c;
var array<float> yaw_d;
var array<float> pitch_a;
var array<float> pitch_b;
var array<float> pitch_c;
var array<float> pitch_d;
var array<float> roll_a;
var array<float> roll_b;
var array<float> roll_c;
var array<float> roll_d;
var array<float> fov_a;
var array<float> fov_b;
var array<float> fov_c;
var array<float> fov_d;

var config array<int> Timedilationframe;
var config array<float> TimedilationframeTimedilation;
var int TimedilationFrameCount;

function PostBeginPlay()
{
	local Demorecspectator Other2;

	foreach DynamicActors( class'Demorecspectator', Other2 ) {
		drs = Other2;
		break;
	}

} //:::::::::::::: Ende PostBeginPlay ::::::::::::::::://///////


function init() {
	
	local int i;
	local Knoten Other;
	foreach DynamicActors( class'Knoten', Other ) {
		if(Other.bForC130 != bForC130) {
			continue;
		} 	
		conf = false;
		break;
	}

	if ( !conf ) {
		// you can set the basic speed here
		if ( basic_speed2 == 0 ) {
			basic_speed2 = 4;
		}

		z = 0;
		viewing = 0;
		drawDetail = 60;
		foreach DynamicActors( class'Knoten', Other ) {
			if(Other.bForC130 != bForC130) {
				continue;
			} 		
			SetLocation( Other.location );
			break;
		}
	} else {
		is_spawning = true;

		// you can set the basic speed here
		if ( basic_speed2 == 0 ) {
			basic_speed2 = 4;
		}

		for ( i = 0; i < z; i++ ) {
			Other = Spawn( class'Knoten', self, , Flag_Locations[i] );
			if(bForC130) {
				Other.bForC130 = true;	
			}
		}

		i = 0;
		foreach DynamicActors( class'Knoten', Other ) {
			if(Other.bForC130 != bForC130) {
				continue;
			} 		
			Other.setRotation( Rotation_At_Flags[i] );
			Other.fov = Flag_Fovs[i];
			Other.time = Flag_times[i];
			i++;
		}
		if(!bForC130)
			updateSplinef( true );
		else
			updateSplinef( false );
		SetLocation( Flag_Locations[0] );
	} //else

	if ( viewer01 == none ) {
		viewer01 = Spawn( class'Viewer' );
	}

	draw_Spline = true;
	drawSplineWasFalse = false;
	I_want_to_insert_a_Flag = false;
	conf = false; //nachdem geladen wurde soll die Klasse wie eine ohne config behandelt werden
	t = 0;
	is_spawning = false;
	enable2 = false;

	if(drs != None) {
		drs.RotationRate.pitch = 65536;
		self.Tag = drs.Tag;
	}
	fov = 100;

	if ( thisTarget == none ) {
		thisTarget = Spawn( class'scl' );
	}

	SetTimer( 0.005, true );

} //:::::::::::::: Ende PostBeginPlay ::::::::::::::::://///////

//-------------Start Get´er and Set´er
function get_x( int i, out float fl )
{
	fl = x[i];
}
function set__x( float fl, int i )
{
	x[i] = fl;
}
function get_Flag_Locations( int i, out vector fl )
{
	fl = Flag_Locations[i];
}
function set_Flag_Locations( vector fl, int i )
{
	Flag_Locations[i] = fl;
	update_flags();
}
function get_Flag_Rotations( int i, out rotator fr )
{
	fr = Rotation_At_Flags[i];
}
function set_Flag_Rotations( rotator fr, int i )
{
	local knoten other, knoten2;
	local int _j;
	Rotation_At_Flags[i] = fr;
	_j = 0;
	foreach DynamicActors( class'Knoten', Other ) {
		if(Other.bForC130 != bForC130) {
			continue;
		} 	
		if ( ( i == 0 ) && ( _j == 1 ) ) {
			knoten2 = Other;
			break;
		}

		if ( _j == i - 1 ) { 
			knoten2 = Other;
			break;
		}

		_j++;
	}

	if ( knoten2 != none ) {
		Rotation_At_Flags[i].yaw = fr.yaw;
		Rotation_At_Flags[i].pitch = fr.pitch;

		if ( abs( Rotation_At_Flags[i].yaw - knoten2.rotation.yaw ) > 32768 ) {
			while ( abs( Rotation_At_Flags[i].yaw - knoten2.rotation.yaw ) > 32768 ) {
				if ( Rotation_At_Flags[i].yaw > knoten2.rotation.yaw ) {
					Rotation_At_Flags[i].yaw = Rotation_At_Flags[i].yaw - 65536;
				} else {
					Rotation_At_Flags[i].yaw = Rotation_At_Flags[i].yaw + 65536;
				}
			}
		} else {
			Rotation_At_Flags[i].yaw = fr.yaw;
		}

		if ( abs( Rotation_At_Flags[i].pitch - knoten2.rotation.pitch ) > 32768 ) {
			while ( abs( Rotation_At_Flags[i].pitch - knoten2.rotation.pitch ) > 32768 )
				if ( Rotation_At_Flags[i].pitch > knoten2.rotation.pitch ) {
					Rotation_At_Flags[i].pitch = Rotation_At_Flags[i].pitch - 65536;
				} else {
					Rotation_At_Flags[i].pitch = Rotation_At_Flags[i].pitch + 65536;
				}
		} else {
			Rotation_At_Flags[i].pitch = fr.pitch;
		}
	}

	update_flags();
}
function set_Flag_Fovs( float tf, int i )
{
	Flag_Fovs[i] = tf;
	update_flags();
}
function get_Flag_Fovs( int i, out float tf )
{
	tf = Flag_Fovs[i];
}
function set_Flag_Times( float tf, int i )
{
	Flag_Times[i] = tf;
	update_flags();
}
function get_Flag_Times( int i, out float tf )
{
	tf = Flag_Times[i];
}

//-------------End Get´er and Set´er

function update_flags()
{
	local int z2, z3;
	local knoten other, other10;
	local bool negdisp;
	local float disp;
	local vector tv;
	z2 = 0;
	foreach DynamicActors( class'Knoten', Other ) {
		if(Other.bForC130 != bForC130) {
			continue;
		} 
		if ( Other.fov != Flag_Fovs[z2] ) {
			Other.fov = Flag_Fovs[z2];

			if ( ( viewing == z2 ) && ( drs.viewtarget == viewer01 ) ) {
				fov = Flag_Fovs[z2];
			}
		}

		if ( Other.time != Flag_times[z2] ) {
			Other.time = Flag_times[z2];
		}

		if ( Other.Location != Flag_Locations[z2] ) {
			if ( !combineLoc ) {
				Other.SetLocation( Flag_Locations[z2] );

				if ( viewing == z2 ) {
					viewer01.setLocation( Flag_Locations[z2] );
				}
			} else {
				tv = vect( 0, 0, 0 );

				if ( Other.Location.x != Flag_Locations[z2].x ) {
					negDisp = Other.Location.x < Flag_Locations[z2].x;
					disp = abs( Other.Location.X - Flag_Locations[z2].X );
				}

				if ( Other.Location.y != Flag_Locations[z2].y ) {
					negDisp = Other.Location.y < Flag_Locations[z2].y;
					disp = abs( Other.Location.y - Flag_Locations[z2].y );

				}

				if ( Other.Location.z != Flag_Locations[z2].z ) {
					negDisp = Other.Location.z < Flag_Locations[z2].z;
					disp = abs( Other.Location.z - Flag_Locations[z2].z );
				}

				z3 = 0;
				foreach DynamicActors( class'Knoten', Other10 ) {
					if(Other10.bForC130 != bForC130) {
						continue;
					} 				
					if ( Other10 != Other ) {
						tv = Other10.location;

						if ( Other.Location.x != Flag_Locations[z2].x )
							if ( negDisp ) {
								tv.x = Other10.location.X + disp;
							} else {
								tv.x = Other10.location.X - disp;
							}

						if ( Other.Location.y != Flag_Locations[z2].y )
							if ( negDisp ) {
								tv.y = Other10.location.y + disp;
							} else {
								tv.y = Other10.location.y - disp;
							}

						if ( Other.Location.z != Flag_Locations[z2].z )
							if ( negDisp ) {
								tv.z = Other10.location.z + disp;
							} else {
								tv.z = Other10.location.z - disp;
							}

						Flag_Locations[z3] = tv;
						Other10.SetLocation( tv );

						if ( viewing == z3 ) {
							viewer01.setLocation( Flag_Locations[z3] );
						}
					}
					z3++;
				}
				Other.SetLocation( Flag_Locations[z2] );

				if ( viewing == z2 ) {
					viewer01.setLocation( Flag_Locations[z2] );
				}
			}
			break;
		}

		if ( Other.Rotation != Rotation_At_Flags[z2] ) {
			Other.SetRotation( Rotation_At_Flags[z2] );

			if ( viewing == z2 ) {
				viewer01.setRotation( Rotation_At_Flags[z2] );
			}
			break;
		}
		z2++;
	}
}

function timesangleichen()
{
	local float dif;
	local int i;
	local Knoten Other;
	dif = worldinfo.TimeSeconds - Flag_Times[0] + dif_tpstart;

	for ( i = 0; i < z; i++ ) {
		Flag_Times[i] = Flag_Times[i] + dif;
	}

	i = 0;
	foreach DynamicActors( class'Knoten', Other ) {
		if(Other.bForC130 != bForC130) {
			continue;
		} 	
		Other.time = other.time + dif;
	}
}


function updateViewer( bool dec )
{
	if ( drs.ViewTarget != viewer01 ) {
		drs.setViewTarget( viewer01 );
		viewer01.changeView( viewing, z - 1, false, false );
	} else {
		viewer01.changeView( viewing, z - 1, !dec, dec );
	}
}

function removeFlag()
{
	local Knoten Other;
	local int i;
	i = 0;
	foreach DynamicActors( class'Knoten', Other ) {
		if(Other.bForC130 != bForC130) {
			continue;
		} 	
		if ( i == remove_Flag ) {
			Other.destroy();
		}

		i++;
	}

	for ( i = remove_Flag; i < z; i++ ) {
		Flag_Locations[i] = Flag_Locations[i + 1];
		Rotation_At_Flags[i] = Rotation_At_Flags[i + 1];
	}

	z = z - 1;
	updateSplinef( true );
}

function FlagEinfuegen()
{
	local Knoten Other;
	local vector v10;
	local int i;
	I_want_to_insert_a_Flag = false;
	i = 0;
	SetTimer( 0, false );
	foreach DynamicActors( class'Knoten', Other ) {
		if(Other.bForC130 != bForC130) {
			continue;
		} 	
		if ( i == z ) {
			v10 = Other.Location;
		}

		i++;
	}

	for ( i = z - 1; i > insert_after_Flag; i-- ) {
		Flag_Locations[i + 1] = Flag_Locations[i];
		Rotation_At_Flags[i + 1] = Rotation_At_Flags[i];
	}

	Flag_Locations[insert_after_Flag + 1] = v10;
	foreach DynamicActors( class'Knoten', Other ) {
		if(Other.bForC130 != bForC130) {
			continue;
		} 		
		Other.destroy();
	}
	z = z + 1;
	justSpawn = true;

	for ( i = 0; i < z; i++ ) {
		Other = Spawn( class'Knoten', self, , Flag_Locations[i] );
		if(bForC130) {
			Other.bForC130 = true;
		}
	}

	justSpawn = false;
	i = 0;
	foreach DynamicActors( class'Knoten', Other ) {
		if(Other.bForC130 != bForC130) {
			continue;
		}
		Other.setRotation( Rotation_At_Flags[i] );
		i++;
	}
	updateSplinef( true );
	I_want_to_insert_a_Flag = true;
}  //:::::::::: Ende FlagEinfuegen ::::::::::::://///

function updateSplinef( bool draw )
{
	local Knoten Other;
	local rotknoten Other2;

	z = 0;
	foreach DynamicActors( class'Knoten', Other ) {
		if(Other.bForC130 != bForC130) {
			continue;
		}
		Flag_Locations[z] = Other.Location;
		Rotation_At_Flags[z] = Other.Rotation;
		Flag_Fovs[z] = Other.fov;
		Flag_times[z] = Other.time;
		z++;
	}

	foreach DynamicActors( class'rotknoten', Other2 ) {
		if(Other2.bForC130 != bForC130) {
			continue;
		}
		Other2.Destroy(); // destroy old path before drawing a new one
	}
	set_x();
	KubSplineKoeffNat();

	if ( draw ) {
		drawPath();
		drawcount = 0;
	} else {
		drawcount = 2;
	}

	dist = 0;
	flag_dist[0] = 0;
} //:::::::::: Ende updateSplinef ::::::::::::::////

event Tick( float deltatime )
{
	if ( ssw == true ) {
		if ( !start ) {
			start = true;
		}

		if ( btimedpath && ( worldinfo.timeseconds > flag_times[z - 1] ) ) {
			ssw = false;
		}

		if ( t >= x[z - 1] ) {
			ssw = false;
		}

		if ( ( t < x[z - 1] ) && start ) {
			if ( btimedpath ) {
				spline_pchip_val( z, Flag_Times, x, derivates, 1, worldinfo.TimeSeconds, t );
			}

			for ( j = 0; j < n - 1; j++ ) {
				if ( t >= x[j] )
					if ( t < x[j + 1] ) {
						KubSplineWertX( t, j );
						KubSplineWertY( t, j );
						KubSplineWertZ( t, j );
						v3 = v2 - v;
						norm( d1, v3 );
						tempdist = 0;

						if ( carry != 0 ) {
							tempdist = tempdist + carry;
						}

						if ( btimedpath && ( t >= x[flag_count] ) && ( flag_count < z ) ) {

						} else {
							while ( !btimedpath && !bpcam && ( tempdist < basic_speed2 ) && ( t < x[j + 1] ) ) {
								KubSplineWertX( t, j );
								KubSplineWertY( t, j );
								KubSplineWertZ( t, j );
								v3 = v2 - v;
								norm( d1, v3 );
								t = t + 0.0005;
								dist = dist + d1;
								tempdist = tempdist + d1;
								v = v2;

								if ( ( t >= x[flag_count] ) && ( flag_count < z ) ) {
									//log("-----------------");
									//log("Flag "@flag_count@" reached at "@worldinfo.TimeSeconds);
									//log("Expected time: "@flag_times[flag_count]);
									//log("Timeerror: "@abs(worldinfo.TimeSeconds-flag_times[flag_count]));
									//log("Distance: "@dist-flag_dist[flag_count-1]);
									//log("Expected distance: "@flag_dist[flag_count]-flag_dist[flag_count-1]);
									//log("Distancerror: "@abs(dist-flag_dist[flag_count-1]-(flag_dist[flag_count]-flag_dist[flag_count-1])));
									flag_count++;
								}
							} //while
						} //else

						if ( btimedpath || ( tempdist >= basic_speed2 ) && ( t < x[j + 1] ) ) {
							v = v2;
							setLocation( v );
							fov = tfov;
							KubSplineWertYaw( t, j );
							KubSplineWertPitch( t, j );
							KubSplineWertRoll( t, j );
							KubSplineWertFov( t, j );
							carry = 0;

							if ( !enable2 ) { // wenn enable dann Sicht auf Target
								setRotation( rotat );
							}
						} else {
							//log("tempdist: "@tempdist@" basic_speed2: "@basic_speed2);
							//log("worldinfoTimeseconds: "@worldinfo.timeseconds);
							//spline_pchip_val ( z, Flag_Times, Flag_Dist, derivates, 1, worldinfo.TimeSeconds, carry );
							//log("dist: "@dist@" soll-dist: "@carry);
							carry = tempdist;
						}
					}

				if ( j == n - 2 )
					if ( t == x[j + 1] ) {
						KubSplineWertX( t, j );
						KubSplineWertY( t, j );
						KubSplineWertZ( t, j );
						KubSplineWertYaw( t, j );
						KubSplineWertPitch( t, j );
						KubSplineWertRoll( t, j );
						KubSplineWertFov( t, j );
						v3 = v2 - v;
						norm( d1, v3 );
						dist = dist + d1;
						t = t + 0.0005;
						v = v2;
						setLocation( v );
						fov = tfov;

						if ( !enable2 ) { // wenn enable dann Sicht auf Target
							setRotation( rotat );
						}
					}
			}
		}
	}

	if ( fovplus ) {
		if ( Flag_Fovs[viewing] < 150 ) {
			Flag_Fovs[viewing] += 0.2;
			update_flags();
		} else {
			fovplus = false;
			updateSplinef( true );
		}
	}

	if ( fovminus ) {
		if ( Flag_Fovs[viewing] > 2 ) {
			Flag_Fovs[viewing] -= 0.2;
			update_flags();
		} else {
			fovminus = false;
			updateSplinef( true );
		}
	}

	if ( rollplus ) {
		rotation_at_flags[viewing].roll -= 70;
		update_flags();
	}

	if ( rollminus ) {
		rotation_at_flags[viewing].roll += 70;
		update_flags();
	}

	if ( enable2 ) {
		tr = rotator( thisTarget.Location - Location );
		tr.roll = rotat.roll;
		setRotation( tr );
	}
}

function Timer()
{
	local int _i;
	local int _j;
	local RotKnoten rotKnot;

	if ( drs != None && drs.ViewTarget != None ) {
		targetLocation = drs.viewtarget.Location;
		targetRotation = drs.viewtarget.Rotation;
	}

	if ( remove_the_specified_Flag == true ) {
		setTimer( 0.004, false );
		removeFlag();
		remove_the_specified_Flag = false;
	}

	if ( ( draw_Spline == false ) && ( !drawSplineWasFalse ) ) {
		foreach DynamicActors( class'Knoten', OtherKnot ) {
			if(OtherKnot.bForC130 != bForC130) {
				continue;
			} 			
			OtherKnot.setHidden( true );
		}
		foreach DynamicActors( class'rotknoten', Other2Rot ) {
			if(Other2Rot.bForC130 != bForC130) {
				continue;
			}		
			Other2Rot.setHidden( true );
		}
		drawSplineWasFalse = true;
		drawcount = 1;
	}

	if ( ( drawSplineWasFalse == true ) && ( draw_Spline == true ) ) {
		foreach DynamicActors( class'Knoten', OtherKnot ) {
			if(OtherKnot.bForC130 != bForC130) {
				continue;
			} 		
			OtherKnot.setHidden( false );
		}
		foreach DynamicActors( class'rotknoten', Other2Rot ) {
			if(Other2Rot.bForC130 != bForC130) {
				continue;
			}			
			Other2Rot.setHidden( false );
		}
		drawSplineWasFalse = false;
		drawcount = 0;
	}

	// draw path
	if ( bisdrawing ) {
		_i = 0;
		for ( _i = 0; _i < 30; _i++ ) {
			if ( t < x[z - 1] ) {
				for ( _j = 0; _j < z - 1; _j++ ) {
					if ( t >= x[_j] ) {
						if ( t < x[_j + 1] ) {
							KubSplineWertX( t, _j );
							KubSplineWertY( t, _j );
							KubSplineWertZ( t, _j );
							v3 = v2 - v;
							norm( d1, v3 );
							tempdist = 0;

							if ( carry != 0 ) {
								tempdist = carry;
							}

							while ( ( tempdist < drawDetail ) && ( t < x[_j + 1] ) ) {
								KubSplineWertX( t, _j );
								KubSplineWertY( t, _j );
								KubSplineWertZ( t, _j );
								v3 = v2 - v;
								norm( d1, v3 );
								t = t + 0.35;
								tempdist = tempdist + d1;
								dist = dist + d1;
								v = v2;
								flag_dist[_j + 1] = dist;
							}

							if ( ( tempdist >= drawDetail ) && ( t < x[_j + 1] ) ) {
								v = v2;
								rotKnot = Spawn( class'rotknoten', , , v );
								rotKnot.bForC130 = bForC130;
								flag_dist[_j + 1] = dist;
								carry = 0;
							} else {
								carry = tempdist;
							}
						}
					}

					if ( _j == z - 2 ) {
						if ( t == x[_j + 1] ) {
							KubSplineWertX( t, _j );
							KubSplineWertY( t, _j );
							KubSplineWertZ( t, _j );
							v3 = v2 - v;
							norm( d1, v3 );
							dist = dist + d1;
							flag_dist[_j + 1] = dist;
							t = t + 0.35;
							v = v2;
							rotKnot = Spawn( class'rotknoten', , , v );
							rotKnot.bForC130 = bForC130;
						}
					}
				}
			}
			else
			{
				pathlenght = flag_dist[z - 1];
				bisdrawing = false;
				break;
			}
		}
		SetTimer( 0.005, false ); // repeat timer until path is drawn
	}

	if ( startCam == true ) {
		ssw = true;
		startCam = false;
		v2 = vect( 0, 0, 0 );
		v = Flag_Locations[0];
		rotat = Rotation_At_Flags[0];;
		t = 0;
		setLocation( v );
		setRotation( rotat );
		flag_count = 1;
		dist = 0;
		setTimer( 0.004, true );
	}

	n = z;

	if ( ( t >= x[z - 1] ) && !enable2 ) {
		SetTimer( 0.05, true );
	}
} ///::::::::::::::: Timer end ::::::::::::::::////////////


function norm( out float f2, vector _v3 )
{
	f2 = sqrt( ( _v3.X ) * ( _v3.X ) + ( _v3.Y ) * ( _v3.Y ) + ( _v3.Z ) * ( _v3.Z ) );
}
function KubSplineWertX( float _t, int _j )
{
	v2.X = a_a[_j] + a_b[_j] * ( _t - x[_j] ) + a_c[_j] * ( _t - x[_j] ) * ( _t - x[_j] ) + a_d[_j] * ( _t - x[_j] ) * ( _t - x[_j] ) * ( _t - x[_j] );
}
function KubSplineWertY( float _t, int _j )
{
	v2.Y = b_a[_j] + b_b[_j] * ( _t - x[_j] ) + b_c[_j] * ( _t - x[_j] ) * ( _t - x[_j] ) + b_d[_j] * ( _t - x[_j] ) * ( _t - x[_j] ) * ( _t - x[_j] );
}
function KubSplineWertZ( float _t, int _j )
{
	v2.Z = c_a[_j] + c_b[_j] * ( _t - x[_j] ) + c_c[_j] * ( _t - x[_j] ) * ( _t - x[_j] ) + c_d[_j] * ( _t - x[_j] ) * ( _t - x[_j] ) * ( _t - x[_j] );
}
function KubSplineWertYaw( float _t, int _j )
{
	rotat.yaw = yaw_a[_j] + yaw_b[_j] * ( _t - x[_j] ) + yaw_c[_j] * ( _t - x[_j] ) * ( _t - x[_j] ) + yaw_d[_j] * ( _t - x[_j] ) * ( _t - x[_j] ) * ( _t - x[_j] );
}
function KubSplineWertPitch( float _t, int _j )
{
	rotat.pitch = pitch_a[_j] + pitch_b[_j] * ( _t - x[_j] ) + pitch_c[_j] * ( _t - x[_j] ) * ( _t - x[_j] ) + pitch_d[_j] * ( _t - x[_j] ) * ( _t - x[_j] ) * ( _t - x[_j] );
}
function KubSplineWertRoll( float _t, int _j )
{
	rotat.roll = roll_a[_j] + roll_b[_j] * ( _t - x[_j] ) + roll_c[_j] * ( _t - x[_j] ) * ( _t - x[_j] ) + roll_d[_j] * ( _t - x[_j] ) * ( _t - x[_j] ) * ( _t - x[_j] );
}
function KubSplineWertFov( float _t, int _j )
{
	tfov = fov_a[_j] + fov_b[_j] * ( _t - x[_j] ) + fov_c[_j] * ( _t - x[_j] ) * ( _t - x[_j] ) + fov_d[_j] * ( _t - x[_j] ) * ( _t - x[_j] ) * ( _t - x[_j] );
}

function equalArray( array<float> a1, out array<float> b1 )
{
	local int i;

	for ( i = 0; i < z; i++ ) {
		b1[i] = a1[i];
	}
}

//	Cholesky decomposition of a Hermitian matrix into the product
//	of a lower triangular matrix and its conjugate transpose.
function Cholesky( array<float> k, out array<float> erg )
{
	local int _n;
	local int i;
	local array<float> d;
	local array<float> g;
	local array<float> z1;
	local array<float> e;
	_n = z - 3;

	for ( i = 0; i <= _n; i++ ) {
		d[i] = 0;
		g[i] = 0;
		e[i] = 0;
		z1[i] = 0;
		erg[i] = 0;
	}

	d[0] = M[0].Y[0];

	for ( i = 1; i <= _n; i++ ) {
		g[i - 1] = M[i].Y[i - 1] / d[i - 1];
		d[i] = M[i].Y[i] - g[i - 1] * M[i].Y[i - 1];
	}

	d[_n] = M[_n].Y[_n] - M[_n].Y[_n - 1] * g[_n - 1];
	z1[0] = k[0];

	for ( i = 1; i <= _n; i++ ) {
		z1[i] = k[i] - g[i - 1] * z1[i - 1];
	}

	for ( i = 0; i <= _n; i++ ) {
		e[i] = z1[i] / d[i];
	}

	erg[_n] = e[_n];

	for ( i = _n - 1; i >= 0; i-- ) {
		erg[i] = e[i] - g[i] * erg[i + 1];
	}
}

function KubSplineKoeffNat()
{
	local int _n;
	local array<float> k;
	local array<float> y;
	local array<float> h1;
	local array<float> ska;
	local array<float> skb;
	local array<float> skc;
	local array<float> skd;
	local int i, h, o, _j;
	_n = z - 1; // !!!!!!!!!!!!!!

// Matrix M mit 0 vorinitialisieren
	for ( i = 0; i < z; i++ )
		for ( _j = 0; _j < z; _j++ ) {
			M[i].Y[_j] = 0;
		}

	for ( i = 0; i <= _n; i++ ) {
		ska[i] = 0;
		skb[i] = 0;
		skc[i] = 0;
		skd[i] = 0;
	}

	h = 7;
	o = 0;

//if(roteingetragen) h=6;
//else h=3;
	for ( o = 0; o < h; o++ ) {
		if ( o == 0 )
			for ( i = 0; i < z; i++ ) {
				y[i] = Flag_Locations[i].X;
			}

		if ( o == 1 )
			for ( i = 0; i < z; i++ ) {
				y[i] = Flag_Locations[i].Y;
			}

		if ( o == 2 )
			for ( i = 0; i < z; i++ ) {
				y[i] = Flag_Locations[i].Z;
			}

		if ( o == 3 )
			for ( i = 0; i < z; i++ ) {
				y[i] = Rotation_At_Flags[i].Yaw;
			}

		if ( o == 4 )
			for ( i = 0; i < z; i++ ) {
				y[i] = Rotation_At_Flags[i].Pitch;
			}

		if ( o == 5 )
			for ( i = 0; i < z; i++ ) {
				y[i] = Rotation_At_Flags[i].Roll;
			}

		if ( o == 6 )
			for ( i = 0; i < z; i++ ) {
				y[i] = Flag_Fovs[i];
			}

//erster und letzter Koeffizient, sowie b(1) und b(n) werden gleich auf 0
//die anderen ci´s werden durch aufstellen der Matrix und anschließende
//Anwendung der Cholesky-Zerlegung berechnet
		skc[0] = 0;
		skc[_n] = 0;
		skb[0] = 0;
		skb[_n] = 0;

		for ( _j = 1; _j <= _n - 1; _j++ ) {
			skb[_j] = 3 * ( ( y[_j + 1] - y[_j] ) / ( x[_j + 1] - x[_j] ) - ( y[_j] - y[_j - 1] ) / ( x[_j] - x[_j - 1] ) );
		}

		M[0].Y[0] = 2 * ( x[2] - x[0] );
		M[0].Y[1] = x[2] - x[1];

		for ( i = 0; i <= _n - 4; i++ ) {
			M[i + 1].Y[i] = 1 * ( x[i + 2] - x[i + 1] );
			M[i + 1].Y[i + 1] = 2 * ( x[i + 3] - x[i + 1] );
			M[i + 1].Y[i + 2] = 1 * ( x[i + 3] - x[i + 2] );
		}

		M[_n - 2].Y[_n - 3] = 1 * ( x[_n - 1] - x[_n - 2] );
		M[_n - 2].Y[_n - 2] = 2 * ( x[_n] - x[_n - 2] );

		for ( i = 1; i <= _n - 1; i++ ) {
			k[i - 1] = skb[i];
		}

		Cholesky( k, h1 );

//da h c(1) bis c(n) enthält braucht es diese kleine for schleife um nicht
//c(0) zu überschreiben:
		for ( i = 1; i <= _n - 1; i++ ) {
			skc[i] = h1[i - 1];
		}

//Berechnung der di´s und bi´s aus den ci´s,den xi´s und den yi´s
		for ( i = 0; i <= _n - 1; i++ ) {
			skd[i] = ( skc[i + 1] - skc[i] ) / ( 3 * ( x[i + 1] - x[i] ) );
			skb[i] = ( y[i + 1] - y[i] ) / ( x[i + 1] - x[i] ) - ( ( x[i + 1] - x[i] ) * ( skc[i + 1] + 2 * skc[i] ) ) / 3;
		}

		equalArray( y, ska );

		for ( i = 0; i < _n; i++ ) {
			k[i] = 0;
		}

		if ( o == 0 ) {
			equalArray( ska, a_a );
			equalArray( skb, a_b );
			equalArray( skc, a_c );
			equalArray( skd, a_d );
		}

		if ( o == 1 ) {
			equalArray( ska, b_a );
			equalArray( skb, b_b );
			equalArray( skc, b_c );
			equalArray( skd, b_d );
		}

		if ( o == 2 ) {
			equalArray( ska, c_a );
			equalArray( skb, c_b );
			equalArray( skc, c_c );
			equalArray( skd, c_d );
		}

		if ( o == 3 ) {
			equalArray( ska, yaw_a );
			equalArray( skb, yaw_b );
			equalArray( skc, yaw_c );
			equalArray( skd, yaw_d );
		}

		if ( o == 4 ) {
			equalArray( ska, pitch_a );
			equalArray( skb, pitch_b );
			equalArray( skc, pitch_c );
			equalArray( skd, pitch_d );
		}

		if ( o == 5 ) {
			equalArray( ska, roll_a );
			equalArray( skb, roll_b );
			equalArray( skc, roll_c );
			equalArray( skd, roll_d );
		}

		if ( o == 6 ) {
			equalArray( ska, fov_a );
			equalArray( skb, fov_b );
			equalArray( skc, fov_c );
			equalArray( skd, fov_d );
		}
	} // for o
}

function edit_x( int i, bool bminus )
{
	local rotknoten other2;
	local int _i;
	local float tempdiff;
	bxedited = true;

	if ( i == 0 ) {
		return;
	}

	tempdiff = ( x[i] - x[i - 1] ) / 7;

	if ( bminus ) {
		if ( ( x[i] - tempdiff ) > x[i - 1] )
			for ( _i = i; _i < z; _i++ ) {
				x[_i] = x[_i] - tempdiff;
			}
	} else {
		for ( _i = i; _i < z; _i++ ) {
			x[_i] = x[_i] + tempdiff;
		}
	}

	KubSplineKoeffNat();

	foreach DynamicActors( class'rotknoten', Other2 ) {  // um doppeltes Anzeigen zu verhindern
		if(Other2.bForC130 != bForC130) {
			continue;
		}		
		Other2.Destroy();
	}
	drawPath();
	drawcount = 0;
}

//	X, abscissa values for the data points and timeline
function set_x()
{
	local int i;
	local float t2;
	x[0] = 0;

	if ( !bxedited ) {
		kabstand = VSize( Flag_Locations[1] - Flag_Locations[0] );
		mabstand = kabstand;

		for ( i = 1; i < z; i++ ) {
			t2 = VSize( Flag_Locations[i] - Flag_Locations[i - 1] );

			if ( t2 < kabstand ) {
				kabstand = t2;
			} else if ( t2 > mabstand ) {
				mabstand = t2;
			}
		}

		for ( i = 1; i < z; i++ ) {
			x[i] = x[i - 1] + 2 * ( VSize( Flag_Locations[i] - Flag_Locations[i - 1] ) / kabstand );
		}
	} else {
		x[z - 1] = x[z - 2] + 2 * ( VSize( Flag_Locations[z - 1] - Flag_Locations[z - 2] ) / kabstand );
	}
}


function drawpath() // path is drawn in timer function
{
	flag_dist[0] = 0;
	v = vect( 0, 0, 0 );
	v2 = vect( 0, 0, 0 );
	v = Flag_Locations[0];
	dist = 0;
	t = 0;
	bisdrawing = true;
	SetTimer( 0.004, false );
}

//------------------------------ timespline functions --------------------------//////////
//
//
//--------- PCHIP:  Piecewise Cubic Hermite Interpolation Package --------------//////////
//
//		PCHIP is used for piecewise cubic Hermite interpolation of data
//		and produces a monotone and "visually pleasing" interpolant to
//		monotone data.
//		such an interpolant may be more reasonable than a cubic spline if
//		the data contains both "steep" and "flat" sections.
//
//		All piecewise cubic functions in PCHIP are represented in
//		cubic Hermite form; that is, f(x) is determined by its values
//		F(I) and derivatives D(I) at the breakpoints X(I), I=1(1)N.
//
//		Variables:
//		N     - number of data points;
//		X     - abscissa values for the data points;
//		F     - ordinates (function values) for the data points;
//		D     - slopes (derivative values) at the data points;
//
//
//------------------------------------- chfev ----------------------------------//////////
//
//		Evaluate a cubic polynomial given in Hermite form at an
//		array of points.  While designed for use by PCHFE, it may
//		be useful directly as an evaluator for a piecewise cubic
//		Hermite function in applications, such as graphing, where
//		the interval is known in advance.
//
//		The cubic polynomial is determined by function values
//		F1, F2 and derivatives D1, D2 on the interval [X1,X2].
//
//		Parameters:
//
//		Input, real X1, X2, the endpoints of the interval of
//		definition of the cubic.  X1 and X2 must be distinct.
//
//		Input, real F1, F2, the values of the function at X1 and
//		X2, respectively.
//
//		Input, real D1, D2, the derivative values at X1 and
//		X2, respectively.
//
//		Input, integer NE, the number of evaluation points.
//
//		Input, real XE(NE), the points at which the function is to
//		be evaluated.  If any of the XE are outside the interval
//		[X1,X2], a warning error is returned in NEXT.
//
//		Output, real FE(NE), the value of the cubic function
//		at the points XE.
//
//		Output, integer NEXT(2), indicates the number of extrapolation points:
//		NEXT(1) = number of evaluation points to the left of interval.
//		NEXT(2) = number of evaluation points to the right of interval.
//
//		function [ fe, next, ierr ] = chfev ( x1, x2, f1, f2, d1, d2, ne, xe )
function chfev( float x1, float x2, float f1, float f2, float _d1, float d2, int ne, float xe,
                out float fe, int next[2] )
{
	local float h, xmi, xma, delta, del1, del2, c2, c3, lx;
	h = x2 - x1;

	if ( h < 0.0 ) {
		xmi = h;
	} else {
		xmi = 0.0;
	}

	//xmi = min ( 0.0, h );
	if ( h > 0.0 ) {
		xma = h;
	} else {
		xma = 0.0;
	}

	//xma = max ( 0.0, h );
	delta = ( f2 - f1 ) / h;
	del1 = ( _d1 - delta ) / h;
	del2 = ( d2 - delta ) / h;
	c2 = - ( del1 + del1 + del2 );
	c3 = ( del1 + del2 ) / h;
	lx = xe - x1;
	fe = f1 + lx * ( _d1 + lx * ( c2 + lx * c3 ) );

	if ( lx < xmi ) {
		next[0] = next[0] + 1;
	}

	if ( xma < lx ) {
		next[1] = next[1] + 1;
	}

}

//------------------------------------- PCHST ----------------------------------//////////
//
//		PCHIP Sign-Testing Routine.
//
//		Returns:
//		-1. if ARG1 and ARG2 are of opposite sign.
//		 0. if either argument is zero.
//		+1. if ARG1 and ARG2 are of the same sign.
//
//		function value = pchst ( arg1, arg2 )
function pchst( float arg1, float arg2, out float value )
{
	if ( arg1 == 0.0 ) {
		value = 0.0;
	} else if ( arg1 < 0.0 ) {
		if ( arg2 < 0.0 ) {
			value = 1.0;
		} else if ( arg2 == 0.0 ) {
			value = 0.0;
		} else if ( 0.0 < arg2 ) {
			value = -1.0;
		}
	} else if ( 0.0 < arg1 ) {
		if ( arg2 < 0.0 ) {
			value = -1.0;
		} else if ( arg2 == 0.0 ) {
			value = 0.0;
		} else if ( 0.0 < arg2 ) {
			value = 1.0;
		}
	}
}

//------------------------------- SPLINE_PCHIP_SET -----------------------------//////////
//
//		Sets derivatives for a piecewise cubic Hermite interpolant.
//
//		This routine computes what would normally be called a Hermite 
//		interpolant.  However, the user is only required to supply function
//		values, not derivative values as well.  This routine computes
//		"suitable" derivative values, so that the resulting Hermite interpolant
//		has desirable shape and monotonicity properties.
//
//		Parameters:
//
//		N, the number of data points.  N must be at least 2.
//
//		X(N), the strictly increasing independent variable values.
//
//		F(N), dependent variable values to be interpolated.  This
//		routine is designed for monotonic data, but it will work for any F-array.
//		It will force extrema at points where monotonicity switches direction.
//
//		D(N), the derivative values at the data points.  For monotonic data,
//		these values will determine a monotone cubic Hermite function.
//
//		function d = spline_pchip_set ( n, x, f )
function spline_pchip_set( int _n, array<float> _x, array<float> f, out array<float> d )
{
	local int nless1, i;
	local float h1, h2, hsum, hsumt3, dmax, dmin, drat1, drat2, w1, w2, del1, del2, value1, value2, temp;
	nless1 = _n - 1;
	h1 = _x[1] - _x[0];
	del1 = ( f[1] - f[0] ) / h1;

	if ( _n == 2 ) {
		d[0] = del1;
		d[_n - 1] = del1;
		return;
	}

	h2 = _x[2] - _x[1];
	del2 = ( f[2] - f[1] ) / h2;
	hsum = h1 + h2;
	w1 = ( h1 + hsum ) / hsum;
	w2 = -h1 / hsum;
	d[0] = w1 * del1 + w2 * del2;

	pchst( d[0], del1, value1 );
	pchst( del1, del2, value2 );

	if ( value1 <= 0.0 ) {
		d[0] = 0.0;
	} else if ( value2 < 0.0 ) {
		dmax = 3.0 * del1;

		if ( abs( dmax ) < abs( d[0] ) ) {
			d[0] = dmax;
		}
	}

	for ( i = 2; i <= nless1; i++ ) {
		if ( 2 < i ) {
			h1 = h2;
			h2 = _x[i] - _x[i - 1];
			hsum = h1 + h2;
			del1 = del2;
			del2 = ( f[i] - f[i - 1] ) / h2;
		}

		d[i - 1] = 0.0;
		pchst( del1, del2, temp );

		if ( temp > 0.0 ) {
			hsumt3 = 3.0 * hsum;
			w1 = ( hsum + h1 ) / hsumt3;
			w2 = ( hsum + h2 ) / hsumt3;
			dmax = fmax( abs( del1 ), abs( del2 ) );
			dmin = fmin( abs( del1 ), abs( del2 ) );
			drat1 = del1 / dmax;
			drat2 = del2 / dmax;
			d[i - 1] = dmin / ( w1 * drat1 + w2 * drat2 );
		}
	}


	w1 = -h2 / hsum;
	w2 = ( h2 + hsum ) / hsum;
	d[_n - 1] = w1 * del1 + w2 * del2;

	pchst( d[_n - 1], del2, value1 );
	pchst( del1, del2, value2 );

	if ( value1 <= 0.0 ) {
		d[_n - 1] = 0.0;
	} else if ( value2 < 0.0 ) {
		dmax = 3.0 * del2;

		if ( abs( dmax ) < abs( d[_n - 1] ) ) {
			d[_n - 1] = dmax;
		}
	}
}

//------------------------------- SPLINE_PCHIP_VAL -----------------------------//////////
//
//		Evaluates a piecewise cubic Hermite function for SPLINE_PCHIP_SET.
//
//		Parameters:
//
//		N, the number of data points.  N must be at least 2.
//
//		X(N), the strictly increasing independent variable values.
//
//		F(N), the function values.
//
//		D(N), the derivative values.
//
//		NE, the number of evaluation points.
//
//		XE(NE), points at which the function is to be evaluated.
//
//		Output, FE, the values of the cubic Hermite function at XE.
//
//		function fe = spline_pchip_val ( n, x, f, d, ne, xe )
function spline_pchip_val( int _n, array<float> _x, array<float> f, array<float> d, int ne, float xe, out float fe )
{
	local int j_first, j_save, ir, _i, i, j_new;
	local int next[2];
	local float nj;

	j_first = 1;
	ir = 2;
	next[0] = 0;
	next[1] = 0;
	
	while ( true ) {
		if ( ne < j_first ) {
			break;
		}
		j_save = ne + 1;
		for ( _i = j_first; _i <= ne; _i++ )
			if ( _x[ir - 1] <= xe ) {
				j_save = _i;
				if ( ir == _n ) {
					j_save = ne + 1;
				}
				break;
			}
		_i = j_save;
		nj = _i - j_first;
		if ( nj != 0 ) {
			chfev( _x[ir - 2], _x[ir - 1], f[ir - 2], f[ir - 1], d[ir - 2], d[ir - 1],  nj, xe, fe, next );
			if ( next[0] != 0 ) {
				if ( ir > 2 ) {
					j_new = -1;
					if ( xe < _x[ir - 2] ) {
						j_new = 1;
						break;
					}
					_i = j_new;
					for ( i = 1; i <= ir - 1; i++ )
						if ( xe < _x[i - 1] ) {
							break;
						}
					ir = 1;
				}
			}
			j_first = _i;
		}
		ir = ir + 1;
		if ( _n < ir ) {
			break;
		}
	}
}

function inittimespline()
{
	spline_pchip_set( z, Flag_Times, x, derivates );
}

defaultproperties
{
	dif_tpstart = 0
	dif_tpstart_temp = 0
	bHidden = True
	bAlwaysTick = True
	bCollideActors = False
	bCollideWorld = False
}
