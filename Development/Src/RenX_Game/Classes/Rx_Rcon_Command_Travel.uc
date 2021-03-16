class Rx_Rcon_Command_Travel extends Rx_Rcon_Command;

function string trigger(string parameters)
{
	local string TravelUrlConfigured;

	if (parameters == "")
		return "Error: Too few parameters." @ getSyntax();

	// Set travel URL for clients
	TravelUrlConfigured = `RxGameObject.TravelURL;
	`RxGameObject.TravelURL = parameters;

	// Travel
	`RxGameObject.ProcessServerTravel(parameters, true);

	// Reset travel URL to configured value
	`RxGameObject.TravelURL = TravelUrlConfigured;
}

function string getHelp(string parameters)
{
	return "Changes the map immediately." @ getSyntax();
}

DefaultProperties
{
	triggers.Add("travel");
	Syntax="Syntax: Travel URL[String]";
}