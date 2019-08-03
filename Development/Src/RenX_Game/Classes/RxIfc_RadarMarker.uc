interface RxIfc_RadarMarker; //Should really only be applicable to Pawns/PRIs 

simulated function byte GetRadarVisibility(); //General Radar visibility 
simulated function Texture GetMinimapIconTexture();

simulated function vector GetRadarActorLocation(); 
simulated function rotator GetRadarActorRotation(); 

simulated function bool ForceVisible(); //Overrides standard radar visibility when true 

//0:Infantry 1: Vehicle 2:Miscellaneous  
simulated function int		GetRadarIconType(); 