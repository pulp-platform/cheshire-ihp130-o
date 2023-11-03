s|for \(i = 0; i < advance; i = i \+ 1\);|for \(i = 0; i < 0; i = i \+ 1\);|g
s|rst_addr_q <= boot_addr_i;|rst_addr_q <= 64'h0000000002000000;|g
