/**
 * Downloads a game package using HTTP
 * 
 * Written by Jessica James <jessica.aj@outlook.com>
 */

class Rx_PackageDownloadClient extends Rx_HTTPClient;

var Rx_PackageDownloader PackageDownloader;

function Connect(string ServerHost, string Resource, Rx_PackageDownloader In_PackageDownloader)
{
	PackageDownloader = In_PackageDownloader;
	RequestResource = Resource;
	Resolve(ServerHost);
}

event Resolved(IpAddr Addr)
{
	Addr.Port = 80;
	Super.Resolved(Addr);
}

event ReceivedResponse()
{
	if (ResponseCode == 200) // 200 OK
		PackageDownloader.ReceivedResponse(self);
	else
		RequestFailed();
}

event RequestFailed()
{
	PackageDownloader.FailedDownload(self);
}

DefaultProperties
{
}
