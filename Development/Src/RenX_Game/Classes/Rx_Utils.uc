
class Rx_Utils extends Object; 


simulated static function float OrientationToB(Actor A, Actor B) {

	return OrientationOfLocAndRotToB(A.Location, A.Rotation, B);
}

simulated static function float OrientationToBLocation(Actor A, Vector B_Location) {

	return OrientationOfLocAndRotToBLocation(A.Location, A.Rotation, B_Location);
}

simulated static function float OrientationOfLocAndRotToB(vector aLocation, rotator aRotation, Actor B) {
	 
	return OrientationOfLocAndRotToBLocation(aLocation,aRotation,B.Location);
}

/**
 * > 0.0  B is in front of A
 * = 0.0  B is exactly to the right/left of A 
 * < 0.0  B is behind A
 */
simulated static function float OrientationOfLocAndRotToBLocation(vector aLocation, rotator aRotation, Vector B_Location) {

	local vector aFacing,aToB;
	 
	// What direction is A facing in?
	aFacing=Normal(Vector(aRotation));
	// Get the vector from A to B
	aToB=B_Location-aLocation;
	 
	return aFacing dot aToB;
}

/**
 * > 0.0  A sits to the left of B
 * = 0.0  A is in front of/behind B (exactly 90° between A and B)
 * < 0.0  A sits to the right of B	
 */
simulated static function float LeftRightOrientationOfAtoB(Actor A, Actor B) {
	return LeftRightOrientationOfAtoB_2(A, B.location, B.rotation);	
}

simulated static function float LeftRightOrientationOfAtoB_2(Actor A, vector bLocation, rotator bRotation) {
	
	local vector lateral;
	
	// Get facing vector
	lateral=vector(bRotation);
	// Rotate 90 degrees in XZ, I'm going to assume (probably wrongly) that this lateral vector will point to the left of the facing, but it COULD be facing to the right
	// in which case the answers below are the wrong way round...
	lateral=lateral cross vect(0,0,1);
	 
	return lateral dot Normal(A.Location - bLocation);
}

