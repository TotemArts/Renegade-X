class Rx_UDPLink extends Object;

struct Socket {
	var int sock_hi;
	var int sock_lo;
};

enum ESocketState
{
	STATE_Uninitialized,
	STATE_Initialized,
	STATE_Closed,
	STATE_Open,
};

var private Socket m_socket;
var private IpAddr m_socket_info;

var ELinkMode LinkMode;
var ELineMode InLineMode, OutLineMode;

var private array<byte> m_buffer;
var private byte m_internal_read_buffer[255];
var private byte m_internal_write_buffer[255];

var const byte ASC_NL, ASC_CR;

var privatewrite ESocketState SocketState;

/** Binds to a port */
function int BindPort(string bindAddress, optional int PortNum, optional bool bUseNextAvailable)
{
	if (InitSock() == false)
		return 0;

	SocketState = STATE_Open;

	if (PortNum == 0)
		return `RxEngineObject.UDPDllCore.c_bind_any(m_socket, bindAddress);
	
	return `RxEngineObject.UDPDllCore.c_bind(m_socket, PortNum, bindAddress);
}

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

/** Closes the Socket */
function Close()
{
	SocketState = STATE_Closed;

	`RxEngineObject.UDPDllCore.c_close(m_socket);
	Closed();
}

/** Called when the connection is closed for any reason */
event Closed();

/** Called when a successful connect has been made */
event Opened();

// ReceivedLine: Called when data is received and connection mode is MODE_Line.
// \r\n is stripped from the line
event ReceivedLine(string Line);

/**
 * @brief Sends a text string over the Socket
 * 
 * @param Str String to send over the Socket
 * @return Number of bytes sent
 */
function int SendText(coerce string Str, int port, string address)
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
			result += SendBinary(buffer_index, m_internal_write_buffer, port, address);
			buffer_index = 0;
		}
	}

	if (buffer_index != 0)
		result += SendBinary(buffer_index, m_internal_write_buffer, port, address);

	return result;
}

/**
 * @brief Sends binary data over the Socket
 * 
 * @param Count Maximum number of bytes to send
 * @param B Array containing the bytes to send
 * @return Number of bytes sent
 */
function int SendBinary(int Count, byte B[255], int port, string address)
{
	local int result;
	
	if (Count == 0)
		return 0;

	if(address == "255.255.255.255")
		result = `RxEngineObject.UDPDllCore.c_sendto(m_socket, port, address, B, Count, 1);
	else
		result = `RxEngineObject.UDPDllCore.c_sendto(m_socket, port, address, B, Count, 0);

	if (result <= 0)
	{
		if (IsLastErrorSerious())
			Close();
		return 0;
	}

	return result;
}

/**
 * @brief Reads binary data from the Socket
 * 
 * @param Count Number of bytes to read
 * @param B Array containing the byte buffer to use
 * @return Number of bytes read
 */
function int ReadBinary(int Count, out byte B[255], out string senderAddress)
{
	local int result;

	if (Count == 0)
		return 0;

	senderAddress = "xxxxxxxxxxxxxxxxxxxxxxxxx"; //preallocate string size

	result = `RxEngineObject.UDPDllCore.c_recvfrom(m_socket, B, Count, senderAddress);
	if (result <= 0)
	{
		if (IsLastErrorSerious())
		{
			`log("Rx_UDPLink ReadBinary() Is Serious");
			Close();
		}
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
function int ReadText(out string Str, out string senderAddress)
{
	local int index, count;

	count = ReadBinary(ArrayCount(m_internal_read_buffer), m_internal_read_buffer, senderAddress);

	for (index = 0; index != count; ++index)
		Str $= Chr(m_internal_read_buffer[index]);

	return count;
}

final function int GetLastError()
{
	return `RxEngineObject.UDPDllCore.c_get_last_error();
}

final function int EnableBroadcast()
{
	return `RxEngineObject.UDPDllCore.c_enableBroadcast(m_socket);
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
		`log("Rx_UDPLink: Encounted serious error:" @ error);
		return true;
	}
}

// ReceivedText: Called when data is received and connection mode is MODE_Text.
event ReceivedText(string Text);

// ReceivedBinary: Called when data is received and connection mode is MODE_Binary.
event ReceivedBinary(int Count, byte B[255]);

event OnTick(float DeltaTime);

private final function bool InitSock()
{
	local int i;

	`log("UDPLink: Init",,'DevNet');
	// Initialize Rx_UDPLink_DLLBind
	if (`RxEngineObject.UDPDllCore == None)
		`RxEngineObject.UDPDllCore = new class'Rx_UDPLink_DLLBind';

	//init buffers
	
	for ( i = 0; i < 255; i++)
		m_internal_read_buffer[i] = byte("x");

	for ( i = 0; i < 255; i++)
		m_internal_read_buffer[i] = byte("x");

	// Initialize Socket
	if (SocketState == STATE_Uninitialized)
	{
		m_socket = `RxEngineObject.UDPDllCore.c_socket();
		if (m_socket.sock_hi == -1 && m_socket.sock_lo == -1)
		{
			`log("Error: Unable to create socket");
			return false;
		}
		`RxEngineObject.UDPDllCore.c_set_blocking(m_socket, 0);
		SocketState = STATE_Initialized;
	}

	return true;
}

/** Processes any pending data. */
final function Tick(float DeltaTime)
{
	local int index, count;
	local byte data;
	local string text, senderAddress;

	if (SocketState == STATE_Open) // Check incoming data
	{
		count = ReadBinary(ArrayCount(m_internal_read_buffer), m_internal_read_buffer, senderAddress);
		if (count == 0) // No data to process
			return;

		`logd("UDPLink: Tick() count is not 0. SenderAddress="@senderAddress,,'DevNetTrafficDetail');

		if (LinkMode == MODE_Binary)
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
					{
						m_buffer.AddItem(data);
						++index;
					}
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
				`log("Rx_UDPLink/Error: No such LinkMode");
				break;
			}
		}
	}

	OnTick(DeltaTime);
}

DefaultProperties
{
	SocketState = STATE_Uninitialized;
	m_socket = (sock_hi = -1, sock_lo = -1);

	/** Constants */
	ASC_NL = 10;
	ASC_CR = 13;
}
