interface RxIfc_Capturable;

function NotifyBeginCaptureBy(byte TeamIndex);

function NotifyCapturedBy(byte TeamIndex);

function NotifyBeginNeutralizeBy(byte TeamIndex);

function NotifyNeutralizedBy(byte TeamIndex, byte PreviousOwner);

function NotifyRestoredNeutral();

function NotifyRestoredCaptured();

function NotifyUnderAttack(byte TeamIndex);

function NotifyContested(bool bContested);

simulated function bool IsCapturableBy(byte TeamIndex);