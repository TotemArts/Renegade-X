/**
 * This file is in the public domain, furnished "as is", without technical
 * support, and with no warranty, express or implied, as to its usefulness for
 * any purpose.
 *
 * Written by Jessica James <jessica.aj@outlook.com>
 */

class ShaderHelper extends UTMutator;

function PostBeginPlay() {
	// Because servers don't accept fucking -EXEC as a parameter, I have to fucking wrap this in a fucking mutator instead because fuck you that's why
	// Also let's set a fucking timer because UDK doesn't fucking respect 'exit' for some fucking reason if the map is still fucking loading
	// holy fucking shit the hoops being jumped through
	// what the fuck
	SetTimer(0.1, True, nameof(PostBeginPlay));
	ConsoleCommand("saveshaders");
	ConsoleCommand("exit");
}
