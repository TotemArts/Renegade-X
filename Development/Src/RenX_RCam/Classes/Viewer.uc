class Viewer extends Actor;

var vector v;
var int viewing;
var int fov;

function PostBeginPlay()
{
	viewing = 0;
}

function changeView( int k, int n, bool inc, bool dec )
{
	local Knoten Other;
	local CamControl other2;
	local int z;

	if ( viewing != k ) {
		viewing = k;
	} else if ( inc ) {
		viewing = viewing + 1;
	}

	if ( dec ) {
		viewing = viewing - 1;
	}

	if ( viewing > n ) {
		viewing = 0;
	}

	if ( viewing < 0 ) {
		viewing = n;
	}

	z = 0;
	foreach AllActors( class'Knoten', Other ) {
		if(Other.bForC130) {
			continue;
		} 	
		if ( z == viewing ) {
			setLocation( Other.Location );
			setRotation( Other.Rotation );
			fov = Other.fov;
		}
		z++;
	}
	foreach AllActors( class'CamControl', Other2 ) {
		if(Other2.bForC130) {
			continue;
		} 	
		Other2.viewing = viewing;
		other2.fov = fov;
	}
}

defaultproperties
{
	bHidden = True
	bAlwaysTick = True
	bCollideActors = False
	bCollideWorld = False
}