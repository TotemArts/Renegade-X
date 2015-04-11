interface RxIfc_EMPable;

simulated function bool IsEffectedByEMP();

function bool EMPHit(Controller InstigatedByController, Actor EMPCausingActor);

function EnteredEMPField(Rx_EMPField EMPField);

function LeftEMPField(Rx_EMPField EMPField);