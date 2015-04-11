class drawkey extends Actor;

var float speed;

function PostBeginPlay()
{
	local CamControl Cam;
	local rotknoten other2;
	local knoten other3;

	foreach AllActors( class'CamControl', Cam ) {
		if(cam.bForC130) {
			continue;
		} 	
		if ( Cam.drawcount == 0 ) {
			Cam.draw_Spline = false;
		}

		if ( Cam.drawcount == 1 ) {
			foreach AllActors( class'Knoten', other3 ) {
				if(other3.bForC130) {
					continue;
				} 				
				other3.setHidden( false );
			}
			foreach AllActors( class'rotknoten', other2 ) {
				if(other2.bForC130) {
					continue;
				} 				
				other2.setHidden( true );
			}
		}

		if ( Cam.drawcount == 2 ) {
			Cam.draw_Spline = true;
		}

		Cam.drawcount++;

		if ( Cam.drawcount == 3 ) {
			Cam.drawcount = 0;
		}

		break;
	}
	other2.destroy();
}

defaultproperties
{
	bHidden = True
	bAlwaysTick = True
}
