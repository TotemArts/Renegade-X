class Rx_TCPLink_DLLBind extends Object DLLBind(Rx_TCPLink);

/** Imported functions to interface with corresponding WinSock functions */
dllimport final function c_token(out ByteArrayWrapper data);
dllimport final function Socket c_socket();
//dllimport final function int c_resolve(byte in_hostname[1024]);
dllimport final function int c_bind(Socket in_socket, int in_port);
dllimport final function int c_bind_next(Socket in_socket, int in_port);
dllimport final function int c_bind_any(Socket in_socket);
dllimport final function int c_listen(Socket in_socket);
dllimport final function AcceptedSocket c_accept(Socket in_socket);
dllimport final function int c_connect(Socket in_socket, int in_address, int in_port);
dllimport final function int c_close(Socket in_socket);
dllimport final function int c_recv(Socket in_socket, out byte out_buffer[255], int out_buffer_size);
dllimport final function int c_send(Socket in_socket, byte in_buffer[255], int in_buffer_size);
dllimport final function int c_set_blocking(Socket in_socket, int in_value); // in_value: 0 for false (non-blocking), 1 for true (blocking)
dllimport final function int c_check_status(Socket in_socket); // -1: remove the socket; 0: still processing connect; 1: connected
dllimport final function int c_get_last_error();
dllimport final function bool UpdateGame();
dllimport final function UpdateDiscordRPC(string in_server_name, string in_level_name, int in_player_count, int in_max_players, int in_team_num, int in_time_elapsed, int in_time_remaining);
dllimport final function take_ss(pointer viewport, out ByteArrayWrapper data);
dllimport final function write_ss(out ByteArrayWrapper in_data);
dllimport final function int copy_array_to_buffer(out ByteBufferWrapper destination, out ByteArrayWrapper source, int offset); // returns bytes copied
dllimport final function set_cap(out ByteBufferWrapper buffer, out ByteArrayWrapper cap);
dllimport final function int read_cap(int in_offset);
dllimport final function bool start_ping_request(string in_str);
dllimport final function int get_ping(string in_str);
dllimport final function clear_pings();
