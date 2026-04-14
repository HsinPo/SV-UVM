// ==============================================================================
// File        : vip/ahb_driver.sv
// Description : AHB Master Driver (Object-Oriented)
// ==============================================================================

class ahb_driver;
    // 1. Declare a virtual interface (the remote control to physical hardware)
    virtual ahb_if vif;

    // 2. Constructor: Connect the physical interface to the virtual interface upon object creation
    function new(virtual ahb_if vif);
        this.vif = vif;
    endfunction

    // ---------------------------------------------------------
    // Tool A: Write Task
    // ---------------------------------------------------------
    task write(input logic [31:0] addr, input logic [31:0] data);
        $display("[%0t] Driver: Preparing to write Data 0x%08X to Address 0x%08X", $time, data, addr);
        
        // 1. Address Phase
        @(posedge vif.hclk);
        vif.haddr  <= addr;
        vif.hwrite <= 1'b1;
        vif.htrans <= 2'b10; // NONSEQ
        
        // 2. Data Phase
        @(posedge vif.hclk);
        vif.htrans <= 2'b00; // IDLE
        vif.hwdata <= data;
        
        // 3. Cleanup: Clear the data bus after writing
        @(posedge vif.hclk);
        vif.hwdata <= 32'h0;
    endtask

    // ---------------------------------------------------------
    // Tool B: Read Task
    // ---------------------------------------------------------
    task read(input logic [31:0] addr, output logic [31:0] rdata);
        $display("[%0t] Driver: Preparing to read from Address 0x%08X", $time, addr);
        
        // 1. Address Phase
        @(posedge vif.hclk);
        vif.haddr  <= addr;
        vif.hwrite <= 1'b0;
        vif.htrans <= 2'b10; // NONSEQ
        
        // 2. Data Phase
        @(posedge vif.hclk);
        vif.htrans <= 2'b00; // IDLE
        
        // 3. Sample Data
        @(posedge vif.hclk);
        rdata = vif.hrdata;  // Note: Using '=' here because we are reading hardware values into a software variable
    endtask

endclass