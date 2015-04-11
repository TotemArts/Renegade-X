class Rx_Rcon_Command extends Object within Rx_Rcon_Commands_Container abstract;

var protected array<string> triggers;
var protected string Syntax;

function bool matches(string trigger)
{
	local int index;
	trigger = Locs(trigger);
	for (index = 0; index != triggers.Length; index++)
		if (trigger == triggers[index])
			return true;
	return false;
}

function addTrigger(string trigger)
{
	triggers.AddItem(Locs(trigger));
}

function string getTrigger(int index)
{
	return triggers[index];
}

function string getSyntax()
{
	return syntax;
}

function string trigger(string parameters);

// This should always be overridden by sub-classes.
function string getHelp(string parameters)
{
	return getSyntax();
}

DefaultProperties
{
}
