// ==============================================================================
// File        : vip/ahb_generator.sv
// Description : Generator class. Responsible for creating transaction objects
//               and sending them to the driver via mailbox. Includes both
//               directed sanity checks and randomized tests.
// ==============================================================================

class ahb_generator;
    // Mailbox to send transactions to the driver
    mailbox #(ahb_transaction) mbx;

    // Constructor
    function new(mailbox #(ahb_transaction) mbx);
        this.mbx = mbx;
    endfunction

    // ---------------------------------------------------------
    // Run Phase: Generate Directed and Random Transactions
    // ---------------------------------------------------------
    task run(int count);
        ahb_transaction tr;
        logic [31:0] rand_addr;

        $display("\n[%0t] [GEN] Starting Generator...", $time);
        
        // =========================================================
        // Part 1: Directed Tests (Sanity Checks)
        // =========================================================
        $display("[%0t] [GEN] --- Running Directed Tests ---", $time);
        
        // Test 1: Write to specific address 0x0000_0010
        tr = new();
        tr.addr     = 32'h0000_0010;
        tr.data     = 32'hAAAA_BBBB;
        tr.is_write = 1'b1; 
        mbx.put(tr);

        // Test 2: Read from specific address 0x0000_0010 (Expect PASS)
        tr = new();
        tr.addr     = 32'h0000_0010;
        tr.is_write = 1'b0; 
        mbx.put(tr);

        // Test 3: Write to specific address 0x0000_0020
        tr = new();
        tr.addr     = 32'h0000_0020;
        tr.data     = 32'h1234_5678;
        tr.is_write = 1'b1; 
        mbx.put(tr);

        // Test 4: Read from specific address 0x0000_0020 (Expect PASS)
        tr = new();
        tr.addr     = 32'h0000_0020;
        tr.is_write = 1'b0; 
        mbx.put(tr);

        // =========================================================
        // Part 2: Random Tests
        // =========================================================
        $display("[%0t] [GEN] --- Running %0d Random Test Pairs ---", $time, count);
        
        // Generate Write/Read pairs to ensure the Scoreboard can verify data
        for (int i = 0; i < count; i++) begin
            // Generate a random, word-aligned address (masking the lowest 2 bits)
            // Using $urandom to avoid svverification license limitations
            rand_addr = $urandom_range(32'h0000_0100, 32'h0000_0FFF) & 32'hFFFF_FFFC;

            // Random Write Transaction
            tr = new();
            tr.addr     = rand_addr;
            tr.data     = $urandom();
            tr.is_write = 1'b1;
            mbx.put(tr);

            // Random Read Transaction (Same address to trigger Scoreboard check)
            tr = new();
            tr.addr     = rand_addr;
            tr.is_write = 1'b0;
            mbx.put(tr);
        end
        
        $display("[%0t] [GEN] Generation Complete.", $time);
    endtask
endclass