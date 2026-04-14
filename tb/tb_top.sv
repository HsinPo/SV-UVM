// ==============================================================================
// File        : tb/tb_top.sv
// Description : Top-level testbench for AHB SRAM (Object-Oriented Version).
//               This file handles hardware connections and instantiates the 
//               driver class to perform transactions.
// ==============================================================================

`timescale 1ns/1ps
`include "../vip/ahb_driver.sv"

module tb_top; 

    // ==========================================
    // 1. Clock and Reset Generation
    // ==========================================
    logic hclk;
    logic hresetn;

    // Generate a 100MHz clock (10ns period)
    initial begin
        hclk = 1'b0;
        forever #5 hclk = ~hclk; 
    end

    // Generate active-low reset
    initial begin
        hresetn = 1'b0;
        #20 hresetn = 1'b1;      
    end

    // ==========================================
    // 2. Instantiate Physical Interface
    // ==========================================
    // This is the physical wire bundle
    ahb_if vif(
        .hclk   (hclk),
        .hresetn(hresetn)
    );

    // ==========================================
    // 3. Instantiate DUT (Design Under Test)
    // ==========================================
    ahb_sram u_sram (
        .hclk   (hclk),
        .hresetn(hresetn),
        .haddr  (vif.haddr),
        .hwrite (vif.hwrite),
        .htrans (vif.htrans),
        .hsize  (vif.hsize),
        .hburst (vif.hburst),
        .hwdata (vif.hwdata),
        .hrdata (vif.hrdata),
        .hready (vif.hready),
        .hresp  (vif.hresp)
    );

    // ==========================================================================
    // 4. OOP Verification Logic
    // ==========================================================================
    
    // Declare the Driver object and a variable for readback data
    ahb_driver   driver;
    logic [31:0] read_data;

    initial begin
        // [Step 0] Initialize physical signals to safe states (Avoid X-propagation)
        vif.haddr  = 32'h0;
        vif.hwrite = 1'b0;
        vif.htrans = 2'b00; // IDLE
        vif.hsize  = 3'b010;
        vif.hburst = 3'b000;
        vif.hwdata = 32'h0;

        // [Step 1] Instantiate the Driver and pass the virtual interface pointer
        // This connects the software 'driver' to the hardware 'vif'
        driver = new(vif);

        // [Step 2] Wait for system to be ready
        wait(hresetn == 1'b1);
        @(posedge hclk);

        $display("-----------------------------------------");
        $display("[%0t] Starting OOP-based Test Scenario...", $time);
        
        // [Step 3] Execute Transactions using Driver Tasks
        // No more manual signal toggling here!
        
        // Write DEADBEEF to Address 0x4
        driver.write(32'h0000_0004, 32'hDEADBEEF);
        
        // Write CAFEBABE to Address 0x8
        driver.write(32'h0000_0008, 32'hCAFEBABE);
        
        // Read back from Address 0x4 to verify
        driver.read(32'h0000_0004, read_data);
        
        // [Step 4] Self-Checking (Scoreboard Logic)
        if (read_data == 32'hDEADBEEF) begin
            $display("=======================================");
            $display("   [SUCCESS] Data Match: 0x%08X", read_data);
            $display("=======================================");
        end else begin
            $display("=======================================");
            $display("   [FAIL] Data Mismatch!");
            $display("   Expected: 0xDEADBEEF, Got: 0x%08X", read_data);
            $display("=======================================");
        end

        #100;
        $display("[%0t] Test Finished.", $time);
        $finish;
    end

endmodule