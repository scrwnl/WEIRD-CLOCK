program weird_clock
    use, intrinsic :: iso_c_binding
    use mod_socket
    implicit none

    integer(c_int) :: lsock, asock, status
    type(sockaddr_in), target :: addr, client
    character(len=2), parameter :: crlf = c_carriage_return // c_new_line
    character(:), allocatable, target :: response

    integer(c_size_t) :: response_len
    lsock = c_socket(AF_INET, SOCK_STREAM, 0)

    if (lsock .lt. 0) then
        print*,"Error: Cannot make socket."
        stop 1
    end if

    call c_memset(c_loc(addr), 0, sizeof(addr))
    addr%sin_family = AF_INET
    addr%sin_port = c_htons(8080)
    addr%sin_addr = c_htonl(INADDR_ANY)
    
    status = c_bind(lsock, c_loc(addr), sizeof(addr))
    
    if (status .lt. 0) then
        print*, "Error: Cannot bind socket"
        stop 1
    end if

    status = c_listen(lsock, 5)
    
    do
        asock = c_accept(lsock, c_null_ptr, c_null_ptr)
        response = &
        "HTTP/1.1 200 OK" // crlf // &
        "Server: Oreore Fortran HTTP Server 1.0" // crlf // &
        "Content-Type: text/html; charset=utf-8" // crlf // &
        "x-Oreore-Greeting: Selamat malam" // crlf // &
        "" // crlf // &
        "<!DOCTYPE html>" // crlf // &
        "<meta charset=utf-8>" // crlf // &
        "<title>The Weird Clock</title>" // crlf // &
        "<meta http-equiv=refresh content='1;URL=/'>" // crlf // &
        "<h1>Date: " // ctime(time()) // "</h1>" // crlf // c_null_char

        response_len = c_strlen(c_loc(response))
        print*, "===== SENT RESPONSE ====="
        print*, response
        status = c_send(asock, c_loc(response), response_len, 0)
        status = c_close(asock)
    enddo

    status = c_close(lsock)
end program weird_clock
