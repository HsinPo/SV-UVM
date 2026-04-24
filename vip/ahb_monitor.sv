// ==============================================================================
// File        : vip/ahb_monitor.sv
// Description : AHB Bus Monitor. 
//               Performs passive sampling of interface signals to reconstruct 
//               transaction objects for verification.
// ==============================================================================

class ahb_monitor;
    // Virtual interface handle used to sample physical signals
    virtual ahb_if vif;
    
    // Mailbox to transfer reconstructed transactions to the Scoreboard
    mailbox #(ahb_transaction) mon_mbx; 

    // Constructor: Assigns the virtual interface and scoreboard mailbox
    function new(virtual ahb_if vif, mailbox #(ahb_transaction) mon_mbx);
        this.vif = vif;
        this.mon_mbx = mon_mbx;
    endfunction

    // Main run task: Continuously monitors AHB bus protocol phases
    task run();
        ahb_transaction tr;
        
        forever begin
            // ---------------------------------------------------------
            // 1. Address Phase Sampling
            // ---------------------------------------------------------
            // Wait for clock edge and check for a NONSEQ (2'b10) transfer type
            @(posedge vif.hclk);
            if (vif.htrans == 2'b10) begin 
                // Instantiate a new transaction object to hold sampled data
                tr = new(); 
                
                // Sample address and control signals during Address Phase
                tr.addr     = vif.haddr;
                tr.is_write = vif.hwrite;
                
                // ---------------------------------------------------------
                // 2. Data Phase Sampling (Next Clock Cycle)
                // ---------------------------------------------------------
                @(posedge vif.hclk);
                
                // Handle wait-states: Loop until HREADY is high
                while (!vif.hready) @(posedge vif.hclk);
                
                // Sample data based on the transaction type captured in Address Phase
                if (tr.is_write) begin
                    tr.data = vif.hwdata; // Capture Write Data
                end else begin
                    tr.data = vif.hrdata; // Capture Read Data
                end
                
                // ---------------------------------------------------------
                // 3. Data Output
                // ---------------------------------------------------------
                // Push the reconstructed transaction into the mailbox
                mon_mbx.put(tr);
                
                // Display sampled information in the simulation log
                $display("[%0t] [Monitor] Sampled %s: Addr=0x%h, Data=0x%h", 
                         $time, (tr.is_write ? "WR" : "RD"), tr.addr, tr.data);
            end
        end
    endtask
endclass