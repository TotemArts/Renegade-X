class Rx_UDPLink_DLLBind extends Object DLLBind(Rx_UDPLink);

dllimport final function Socket c_socket();
dllimport final function int c_bind(Socket in_socket, int in_port, string bindAddress);
dllimport final function int c_bind_any(Socket in_socket, string bindAddress);
dllimport final function int c_recvfrom(Socket in_socket, out byte out_buffer[255], int out_buffer_size, out string senderAddress); 	// We are returning a string to unrealscript. The string must be preallocated in unrealscript larger then what the dll returns.
dllimport final function int c_set_blocking(Socket in_socket, int in_value); // in_value: 0 for false (non-blocking), 1 for true (blocking)
dllimport final function int c_sendto(Socket in_socket, int in_port, string in_address, byte in_buffer[255], int in_buffer_size, int isBroadcast);
dllimport final function int c_get_last_error();
dllimport final function int c_close(Socket in_socket);
dllimport final function int c_enableBroadcast(Socket in_socket); 