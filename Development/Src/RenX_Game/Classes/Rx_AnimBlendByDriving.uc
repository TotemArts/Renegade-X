/*********************************************************
*
* File: Rx_AnimBlendByDriving.uc
* Author: RenegadeX-Team
* Pojekt: Renegade-X UDK <www.renegade-x.com>
*
* Desc:
*
*
* ConfigFile:
*
*********************************************************
*
*********************************************************/

class Rx_AnimBlendByDriving extends UDKAnimBlendByDriving;


/** How fast show a given child blend in. */
var(Animation) float BlendTime;

/** Also allow for Blend Overrides */
var(Animation) array<float> ChildBlendTimes;

/** Whether this AnimBlend wants a script TickAnim event called (for script extensibility) */
var bool bTickAnimInScript;

function float GetBlendTime(int ChildIndex, optional bool bGetDefault);

/** If child is an AnimNodeSequence, find its duration at current play rate. */
function float GetAnimDuration(int ChildIndex);

/** Use to implement custom anim blend functionality in script */
event TickAnim(FLOAT DeltaSeconds);


defaultproperties
{
	BlendTime=0.25
}
