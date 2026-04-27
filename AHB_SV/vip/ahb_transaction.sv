// ==============================================================================
// File        : vip/ahb_transaction.sv
// Description : AHB Transaction Item (The Data Container)
// ==============================================================================

class ahb_transaction;
    // rand for random test
    rand logic [31:0] addr;
    rand logic [31:0] data;
    rand bit          is_write; // 1: WRITE, 0: READ

    // Debug 
    function void display(string name = "Transaction");
        $display("[%s] Addr=0x%08X, Data=0x%08X, Type=%s", 
                 name, addr, data, (is_write ? "WRITE" : "READ"));
    endfunction
endclass