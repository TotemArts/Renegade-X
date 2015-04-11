class Rx_GraphicAdapterCheck extends Actor
	DLLBind(Rx_GraphicAdapterCheck_Lib);


enum Vendor
{
	V_Nvidia,
	V_AMD,
	V_Intel
};

var Vendor EVendor;

dllimport final function string GetGPUAdapterName();

function CheckGraphicAdapter ()
{
	local array<string> stringParts;
	local string adapterName;
	local byte i;
	
	adapterName = GetGPUAdapterName();

	ParseStringIntoArray(adapterName , stringParts, " ", false);

	for (i=0; i < stringParts.Length; i++) {
		if (stringParts[i] == "NVIDIA" || stringParts[i] == "GeForce" || stringParts[i] == "Quadro"	|| stringParts[i] == "Quadro2" || stringParts[i] == "Quadro4") {
			EVendor = V_Nvidia;
			return;
		} else if (stringParts[i] == "ATI" || stringParts[i] == "AMD" || stringParts[i] == "Radeon") {
			EVendor = V_AMD;
			return;
		} else if (stringParts[i] == "Intel" || stringParts[i] == "Intel(R)" || stringParts[i] == "SandyBridge" || stringParts[i] == "IvyBridge" || stringParts[i] == "Haswell" || stringParts[i] == "Crystalwell") {
			EVendor = V_Intel;
			return;
		}
	}

}


DefaultProperties
{
}
