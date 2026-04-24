// ==============================================================================
// File        : vip/ahb_generator.sv
// Description : Stimulus Generator. Generates randomized ahb_transaction items
//               and sends them to the driver via a parameterized mailbox.
// ==============================================================================

class ahb_generator;
    // Parameterized mailbox to ensure type safety
    mailbox #(ahb_transaction) mbx; 

    // Constructor: Receive the mailbox assigned by the top environment
    function new(mailbox #(ahb_transaction) mbx);
        this.mbx = mbx;
    endfunction

    // Main task: Generate a specified number of transactions
    task run(int count);
        ahb_transaction tr;
        $display("[%0t] [Generator] Started! Preparing to generate %0d packets...", $time, count);

        for (int i = 0; i < count; i++) begin
            // 1. Create a new transaction item
            tr = new(); 
            
            // 2. Randomize the transaction constraints
            // Duo to license, can't use randomize
            /* if (!tr.randomize()) begin 
                $fatal("[%0t] [Generator] FATAL: Randomization failed!", $time);
            end*/
            tr.addr     = $urandom();
            tr.data     = $urandom();
            tr.is_write = $urandom_range(0, 1);
            
            // 3. Put the randomized transaction into the mailbox
            mbx.put(tr); 
            $display("[%0t] [Generator] Packet %0d sent to mailbox (Addr: 0x%08X)", $time, i, tr.addr);
        end
        
        $display("[%0t] [Generator] Successfully sent all %0d packets. Task finished.", $time, count);
    endtask
endclass