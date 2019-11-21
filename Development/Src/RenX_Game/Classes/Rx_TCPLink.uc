/**
 * This class provides direct access to sockets, without incorporating them into an Actor
 * 
 * Written by Jessica James <jessica.aj@outlook.com>
 */

class Rx_TCPLink extends Object;

enum ESocketState
{
	STATE_Uninitialized,
	STATE_Initialized,
	STATE_Connecting,
	STATE_Connected,
	STATE_Listening
};

struct Socket {
	var int sock_hi;
	var int sock_lo;
};

var ELinkMode LinkMode;
var ELineMode InLineMode, OutLineMode;
var EReceiveMode ReceiveMode;
var Rx_TCPLink Parent;
var class<Rx_TCPLink> AcceptClass;
var array<Rx_TCPLink> Children;
var bool TickChildren;

var privatewrite ESocketState SocketState;

/** Internals */

var private Rx_TCPLink_Resolver m_resolver;

var private Socket m_socket;
var private IpAddr m_socket_info;

var private array<byte> m_buffer;
var private byte m_internal_read_buffer[255];
var private byte m_internal_write_buffer[255];

var const byte ASC_NL, ASC_CR;

struct AcceptedSocket
{
	var int sock_hi;
	var int sock_lo;
	var int Addr;
	var int Port;
};



/********************************
 * DNS Resolution
 */

/** Resolves a string hostname/address to an IPv4 address */
function Resolve(string in_address)
{
	m_resolver = class'Engine'.static.GetCurrentWorldInfo().Spawn(class'Rx_TCPLink_Resolver');
	m_resolver.Rx_Resolve(self, in_address);
}

/** Immediately halts any active Resolve process */
final function HaltResolve()
{
	if (m_resolver != None)
	{
		ResolveFinished();
		ResolveFailed(true);
	}
}

/** Called when Resolve() succeeds */
event Resolved(IpAddr Addr)
{
}

/**
 * @brief Called when Resolve() fails
 * 
 * @param forced True if resolution failure was a result of HaltResolve(), false otherwise.
 */
event ResolveFailed(bool forced)
{
}

/** Checks if there is a Resolve in process */
function bool IsResolving()
{
	return m_resolver != None;
}

/** Called when Resolve() finishes */
final function ResolveFinished()
{
	m_resolver.Destroy();
	m_resolver = None;
}



/********************************
 * Socket Initialization
 */

/** Binds to a port */
function int BindPort(optional int PortNum, optional bool bUseNextAvailable)
{
	if (InitSock() == false)
		return 0;

	if (PortNum == 0)
		return `RxEngineObject.DllCore.c_bind_any(m_socket);
	
	if (bUseNextAvailable)
		return `RxEngineObject.DllCore.c_bind_next(m_socket, PortNum);
	
	return `RxEngineObject.DllCore.c_bind(m_socket, PortNum);
}

/** Puts socket in a listening state. Must call BindPort() first. */
function bool Listen()
{
	local bool result;
	
	result = `RxEngineObject.DllCore.c_listen(m_socket) == 0;
	if (result)
		SocketState = STATE_Listening;

	return result;
}

/** Opens a connection */
function bool Open(IpAddr Addr)
{
	if (InitSock() == false)
		return false;

	// Close Socket (if applicable)
	if (SocketState == STATE_Connected || SocketState == STATE_Connecting || SocketState == STATE_Listening)
		Close();

	// Connect Socket
	if (`RxEngineObject.DllCore.c_connect(m_socket, Addr.Addr, Addr.Port) != 0)
	{
		if (IsLastErrorSerious())
			return false;
		
		m_socket_info = Addr;
		SocketState = STATE_Connecting;
	}
	else
	{
		m_socket_info = Addr;
		SocketState = STATE_Connected;
		Opened();
	}

	return true;
}

/** Closes the Socket */
function Close()
{
	SocketState = STATE_Uninitialized;

	`RxEngineObject.DllCore.c_close(m_socket);
	Destroy();
	Closed();
}

/** Called when the connection is closed for any reason */
event Closed();

/** Called when a successful connect has been made */
event Opened();

/** Marks the TCPLink object to be destroyed (dereferenced) */
final function Destroy()
{
	if (Parent != None)
		Parent.KillChild(self);
}



/********************************
 * Socket Usage
 */

/** True if there is an active connection, false otherwise */
function bool IsConnected()
{
	return SocketState == STATE_Connected;
}

/**
 * @brief Sends a text string over the Socket
 * 
 * @param Str String to send over the Socket
 * @return Number of bytes sent
 */
function int SendText(coerce string Str)
{
	local int buffer_index, str_index, str_length, result;
	
	if (LinkMode == MODE_Line)
	{
		switch (OutLineMode)
		{
		case LMODE_auto:
		case LMODE_DOS:
			Str $= "\r\n";
			break;
		case LMODE_UNIX:
			Str $= "\n";
			break;
		case LMODE_MAC:
			Str $= "\n\r";
			break;
		}
	}

	str_index = 0;
	str_length = Len(str);

	while (str_index != str_length)
	{
		m_internal_write_buffer[buffer_index] = byte(Asc(Mid(Str, str_index, 1)));
		++str_index;
		++buffer_index;

		if (buffer_index == ArrayCount(m_internal_write_buffer)) // We're full -- send & reset buffer
		{
			result += SendBinary(buffer_index, m_internal_write_buffer);
			buffer_index = 0;
		}
	}

	if (buffer_index != 0)
		result += SendBinary(buffer_index, m_internal_write_buffer);

	return result;
}

/**
 * @brief Sends binary data over the Socket
 * 
 * @param Count Maximum number of bytes to send
 * @param B Array containing the bytes to send
 * @return Number of bytes sent
 */
function int SendBinary(int Count, byte B[255])
{
	local int result;
	
	if (Count == 0 || SocketState != STATE_Connected)
		return 0;

	result = `RxEngineObject.DllCore.c_send(m_socket, B, Count);
	if (result <= 0)
	{
		if (IsLastErrorSerious())
			Close();
		return 0;
	}

	return result;
}

/**
 * @brief Reads a text string from the Socket
 * 
 * @param Str Reads text from the Socket
 * @return Number of bytes written to Str
 */
function int ReadText(out string Str)
{
	local int index, count;
	
	count = ReadBinary(ArrayCount(m_internal_read_buffer), m_internal_read_buffer);

	for (index = 0; index != count; ++index)
		Str $= Chr(m_internal_read_buffer[index]);

	return count;
}

/**
 * @brief Reads binary data from the Socket
 * 
 * @param Count Number of bytes to read
 * @param B Array containing the byte buffer to use
 * @return Number of bytes read
 */
function int ReadBinary(int Count, out byte B[255])
{
	local int result;
	
	if (Count == 0)
		return 0;

	result = `RxEngineObject.DllCore.c_recv(m_socket, B, Count);
	if (result <= 0)
	{
		if (IsLastErrorSerious())
			Close();
		return 0;
	}

	return result;
}

final function int GetLastError()
{
	return `RxEngineObject.DllCore.c_get_last_error();
}

final function bool IsLastErrorSerious()
{
	return IsSeriousError(GetLastError());
}

function bool IsSeriousError(int error)
{
	switch (error)
	{
	case 0:
	case 10035: // WSAEWOULDBLOCK -- Operation would block
		return false;
	default:
		return true;
	}
}

// Accepted: Called during STATE_Listening when a new connection is accepted.
event Accepted();

// ReceivedText: Called when data is received and connection mode is MODE_Text.
event ReceivedText(string Text);

// ReceivedLine: Called when data is received and connection mode is MODE_Line.
// \r\n is stripped from the line
event ReceivedLine(string Line);

// ReceivedBinary: Called when data is received and connection mode is MODE_Binary.
event ReceivedBinary(int Count, byte B[255]);

event OnTick(float DeltaTime);

/** Called when a child connection is accepted */
event GainedChild(Rx_TCPLink Child);

/** Called when a child connection is destroyed */
event LostChild(Rx_TCPLink Child);

/********************************
 * Internal functions
 */

private final function ProcessBufferAsLine()
{
	local int index;
	local string text;
	local byte data;

	while (index != m_buffer.Length)
	{
		data = m_buffer[index];
		text $= Chr(data);
		++index;
	}
	m_buffer.Length = 0;

	ReceivedLine(text);
}

private final function bool InitSock()
{
	// Initialize Rx_TCPLink_DLLBind
	if (`RxEngineObject.DllCore == None)
		`RxEngineObject.DllCore = new class'Rx_TCPLink_DLLBind';

	// Initialize Socket
	if (SocketState == STATE_Uninitialized)
	{
		m_socket = `RxEngineObject.DllCore.c_socket();
		if (m_socket.sock_hi == -1 && m_socket.sock_lo == -1)
		{
			`log("Error: Unable to create socket");
			return false;
		}
		`RxEngineObject.DllCore.c_set_blocking(m_socket, 0);
		SocketState = STATE_Initialized;
	}
	
	return true;
}

private final function KillChild(Rx_TCPLink Child)
{
	Children.RemoveItem(Child);
	LostChild(Child);
}

private final function TickListening()
{
	local AcceptedSocket accepted;
	local Rx_TCPLink link;

	accepted = `RxEngineObject.DllCore.c_accept(m_socket);
	
	if (accepted.sock_hi != -1 && accepted.sock_lo != -1)
	{
		link = new AcceptClass;
		link.m_socket.sock_hi = accepted.sock_hi;
		link.m_socket.sock_lo = accepted.sock_lo;
		link.m_socket_info.Addr = accepted.Addr;
		link.m_socket_info.Port = accepted.Port;
		link.SocketState = STATE_Connected;

		link.Parent = self;
		Children.AddItem(link);
		link.Accepted();

		GainedChild(link);
	}
}

/** Processes any pending data. */
final function Tick(float DeltaTime)
{
	local int index, count;
	local byte data;
	local string text;

	if (SocketState == STATE_Listening) // Check for incoming connections
		TickListening();
	else
	{
		if (SocketState == STATE_Connecting) // Check socket status
		{
			// repurpose index
			index = `RxEngineObject.DllCore.c_check_status(m_socket);

			if (index == 1) // Success
			{
				SocketState = STATE_Connected;
				Opened();
			}
			else if (index == -1) // Failure
				Close();
			// else // Nothing changed
		}

		if (SocketState == STATE_Connected) // Check incoming data
		{
			count = ReadBinary(ArrayCount(m_internal_read_buffer), m_internal_read_buffer);
			if (count == 0) {
				// No data to process; do nothing
			}
			else if (LinkMode == MODE_Binary)
				ReceivedBinary(count, m_internal_read_buffer);
			else if (LinkMode == MODE_Text)
			{
				for (index = 0; index != count; ++index)
					text $= Chr(m_internal_read_buffer[index]);
				ReceivedText(text);
			}
			else if (LinkMode == MODE_Line)
			{
				switch (InLinemode)
				{
				case LMODE_auto: // \r OR \n, ignore blanks
					for (index = 0; index != count; ++index)
					{
						data = m_internal_read_buffer[index];
						if (data == ASC_NL || data == ASC_CR)
						{
							if (m_buffer.Length != 0)
								ProcessBufferAsLine();
						}
						else
							m_buffer.AddItem(data);
					}
					break;

				case LMODE_DOS: // \r\n
					if (m_buffer.Length != 0 && m_buffer[m_buffer.Length - 1] == ASC_CR) // There's pending data; check if a newline was in progress
					{
						if (m_internal_read_buffer[index] == ASC_NL) // Newline reached; remove \r from buffer and process
						{
							m_buffer.Remove(m_buffer.Length - 1, 1);
							ProcessBufferAsLine();
							++index;
						}
					}

					while (index != count)
					{
						data = m_internal_read_buffer[index];
						if (data == ASC_CR)
						{
							if (++index == count) // no more data after \r
								m_buffer.AddItem(data);
							else if (m_internal_read_buffer[index] == ASC_NL) // Newline sequence
								ProcessBufferAsLine();
							else // just a \r; add it /and/ the character after it since we incremented index
							{
								m_buffer.AddItem(data);
								m_buffer.AddItem(m_internal_read_buffer[index]);
							}
						}
						else
							m_buffer.AddItem(data);
						++index;
					}
					break;

				case LMODE_UNIX: // \n
					for (index = 0; index != count; ++index)
					{
						data = m_internal_read_buffer[index];
						if (data == ASC_NL)
							ProcessBufferAsLine();
						else
							m_buffer.AddItem(data);
					}
					break;

				case LMODE_MAC: // \n\r, because Apple likes being special
					if (m_buffer.Length != 0 && m_buffer[m_buffer.Length - 1] == ASC_NL) // There's pending data; check if a newline was in progress
					{
						if (m_internal_read_buffer[index] == ASC_CR) // Newline reached; remove \n from buffer and process
						{
							m_buffer.Remove(m_buffer.Length - 1, 1);
							ProcessBufferAsLine();
							++index;
						}
					}

					while (index != count)
					{
						data = m_internal_read_buffer[index];
						if (data == ASC_NL)
						{
							if (++index == count) // no more data after \n
								m_buffer.AddItem(data);
							else if (m_internal_read_buffer[index] == ASC_CR) // Newline sequence
								ProcessBufferAsLine();
							else // just a \n; add it /and/ the character after it since we incremented index
							{
								m_buffer.AddItem(data);
								m_buffer.AddItem(m_internal_read_buffer[index]);
							}
						}
						else
							m_buffer.AddItem(data);
						++index;
					}
					break;
				default:
					`log("Rx_TCPLink/Error: No such LinkMode");
					break;
				}
			}
		}
	}

	if (TickChildren)
	{
		index = 0;
		count = Children.Length;
		while (index < Children.Length)
		{
			Children[index].Tick(DeltaTime);

			if (count == Children.Length) // A child did not die
				++index;
			else // A child died; don't increment (as the object in 'index' shouldn't be the same as it just was)
				count = Children.Length;
		}
	}

	OnTick(DeltaTime);
}



/********************************
 * DefaultProperties
 */

DefaultProperties
{
	SocketState = STATE_Uninitialized;
	TickChildren = true;

	/** Constants */
	ASC_NL = 10;
	ASC_CR = 13;

	/** Internals */
	m_resolver = None;
	m_socket = (sock_hi = -1, sock_lo = -1);
}
