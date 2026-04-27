// ==============================================================================
// File        : vip/ahb_driver.sv
// Description : AHB Master Driver (TLM Upgraded with Mailbox)
//               Continuously fetches items from the mailbox and drives them
//               onto the physical AHB interface.
// ==============================================================================

class ahb_driver;
    // Virtual interface: The remote control to the physical hardware
    virtual ahb_if vif;
    
    // Parameterized mailbox: Strictly accepts only ahb_transaction types
    mailbox #(ahb_transaction) mbx; 

    // Constructor: Assigns the physical interface and mailbox
    function new(virtual ahb_if vif, mailbox #(ahb_transaction) mbx);
        this.vif = vif;
        this.mbx = mbx;
    endfunction

    // ---------------------------------------------------------
    // Main Task: Infinite loop to process transactions
    // ---------------------------------------------------------
    task run();
        ahb_transaction tr; // Handle to hold the fetched packet
        
        $display("[%0t] [Driver] Driver is online! Monitoring mailbox...", $time);
        
        // Infinite loop to keep the driver running actively in the background
        forever begin
            // Fetch packet from mailbox (Blocking: sleeps here if mailbox is empty)
            mbx.get(tr); 
            
            $display("[%0t] [Driver] Fetched new packet! Driving to bus...", $time);
            // tr.display("Driver_Drive"); // Optional: Uncomment to see packet details

            // ==========================================================
            // Physical Hardware Timing Logic (AHB Protocol)
            // ==========================================================
            
            // 1. Address Phase
            @(posedge vif.hclk);
            vif.haddr  <= tr.addr;
            vif.hwrite <= tr.is_write;
            vif.htrans <= 2'b10; // NONSEQ
            
            // 2. Data Phase
            @(posedge vif.hclk);
            vif.htrans <= 2'b00; // IDLE
            
            if (tr.is_write) begin
                // Drive data onto the bus for write operations
                vif.hwdata <= tr.data; 
            end 
            
            // 3. Cleanup & Read Sampling Phase
            @(posedge vif.hclk);
            
            if (!tr.is_write) begin
                // Sample the bus and store read data back into the packet
                tr.data = vif.hrdata; 
            end
            
            // Clear the write data bus to avoid X-propagation or trailing values
            vif.hwdata <= 32'h0;
            // ==========================================================
            
        end // End of forever loop
    endtask

endclass