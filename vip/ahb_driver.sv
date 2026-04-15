// ==============================================================================
// File        : vip/ahb_driver.sv
// Description : AHB Master Driver (TLM Upgraded)
//               Drives ahb_transaction items onto the physical AHB interface.
// ==============================================================================

class ahb_driver;
    // Virtual interface: The remote control to the physical hardware
    virtual ahb_if vif;

    // Constructor: Assigns the physical interface to the virtual pointer
    function new(virtual ahb_if vif);
        this.vif = vif;
    endfunction

    // ---------------------------------------------------------
    // Upgraded Task: Process a single Transaction item directly
    // ---------------------------------------------------------
    task drive_item(ahb_transaction tr);
        $display("[%0t] Driver: Received new transaction item...", $time);
        tr.display("Driver_Drive");

        // 1. Address Phase
        @(posedge vif.hclk);
        vif.haddr  <= tr.addr;
        vif.hwrite <= tr.is_write;
        vif.htrans <= 2'b10; // NONSEQ
        
        // 2. Data Phase
        @(posedge vif.hclk);
        vif.htrans <= 2'b00; // IDLE
        
        if (tr.is_write) begin
            vif.hwdata <= tr.data; // Drive data onto the bus for write operations
        end 
        
        // 3. Cleanup & Read Sampling Phase
        @(posedge vif.hclk);
        
        if (!tr.is_write) begin
            // If it's a read operation, sample the bus and store it back into the packet
            tr.data = vif.hrdata; 
        end
        
        // Clear the write data bus to avoid X-propagation or trailing values
        vif.hwdata <= 32'h0;
    endtask

endclass