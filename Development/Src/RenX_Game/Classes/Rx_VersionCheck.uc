class Rx_VersionCheck extends Actor
	DLLBind(Rx_VersionCheck_Lib);

// ping from native (SYNC)
dllimport final function string PingIp(string IpString);
// start async pings from native
dllimport final function StartPingAll(string ServersString);
// get ping status (count) for finished pings
dllimport final function int GetPingStatus();
// get ping from async finished list for ip, returns -1 when failed or not arrived
dllimport final function int GetPingFor(string Ip);
// returns pinged ids list
dllimport final function string GetPingedIDs();

/* Allows this class to call functions in another class when out of version is flagged.
 * The function bound to this delegate must have no parameters or return types.
 * If parameters or return types are needed, they must be wrapped in the function
 * that is called.
 */
delegate NotifyDelegate();

/**
 * Ping
 * given IP and returns ping (>=500 means usually fail)
 * 
 * @param - ip to ping
 * @return - ping for given ip
 */
public function string Ping(String Ip)
{
	return PingIp(Ip);
}
