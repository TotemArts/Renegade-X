class Rx_Vehicle_PTInfo extends Object
abstract;

/*Base class to hold a vehicle's PT info*/

	//var int 									id;
	var Texture                                 PTIconTexture;
	var PurchaseBlockType                       BlockType;
	var string 									hotkey;
	var string 									title;
	var string 									cost;
	var int 									iconID;
	var string 									desc;
	var bool                                    bAircraft;
	var string									PTString;
	
	var class<Rx_Vehicle>						VehicleClass; 
	var SoundNodeWave							GDIVehicleAnnouncment, NodVehicleAnnouncment;

static function string BotPTString()
{
	return default.PTString;
}

static function int GetCost(Rx_PRI Context)
{
	return default.VehicleClass.static.Cost(Context);
}
DefaultProperties
{
		title	    	=	""
		cost	    	=	""
		iconID	    	=	0
		desc	    	=	""
		bAircraft   	=   false
		VehicleClass 	= class'Rx_vehicle_Humvee'
		GDIVehicleAnnouncment = None 
		NodVehicleAnnouncment = None 
}