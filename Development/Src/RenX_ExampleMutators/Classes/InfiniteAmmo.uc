/**
 * This file is in the public domain, furnished "as is", without technical
 * support, and with no warranty, express or implied, as to its usefulness for
 * any purpose.
 *
 * Written by Jessica James <jessica.aj@outlook.com>
 */

class InfiniteAmmo extends UTMutator;

function bool CheckReplacement(Actor Other)
{
	if (Rx_Weapon(Other) != None && Rx_Weapon_Deployable(Other) == None && Rx_Weapon_Grenade(Other) == None)
		Rx_Weapon(Other).bHasInfiniteAmmo = true;
	return true;
}