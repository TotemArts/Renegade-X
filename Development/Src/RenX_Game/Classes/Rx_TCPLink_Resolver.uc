class Rx_TCPLink_Resolver extends InternetLink;

var Rx_TCPLink link;

function Rx_Resolve(Rx_TCPLink in_TCPlink, string address)
{
	link = in_TCPlink;
	Resolve(address);
}

event Resolved(IpAddr Addr)
{
	if (link != None)
	{
		link.ResolveFinished();
		link.Resolved(Addr);
	}
}

event ResolveFailed()
{
	if (link != None)
	{
		link.ResolveFinished();
		link.ResolveFailed(false);
	}
}
