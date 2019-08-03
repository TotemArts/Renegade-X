interface RxIfc_EMPable;

simulated function bool IsEffectedByEMP();

/*Use modifier to send special calls for how long things are affected by EMPs, mostly just to tell Rx_Vehicle how long to stay EMP'd for. Not sending anything is fine */
function bool EMPHit(Controller InstigatedByController, Actor EMPCausingActor, optional int TimeModifier = 0); 

function EnteredEMPField(Rx_EMPField EMPField);

function LeftEMPField(Rx_EMPField EMPField);