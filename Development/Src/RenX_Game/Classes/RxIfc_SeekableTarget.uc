
interface RxIfc_SeekableTarget; 

function float GetAimAheadModifier();
function float GetAccelrateModifier();
simulated function vector GetAdjustedLocation(); //If we use an alternate location when being sought by weapons and the like