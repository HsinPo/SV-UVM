// ==============================================================================
// File        : tb/tb_top.sv
// Description : Top-level testbench for AHB SRAM (Transaction-Level Phase 1).
//               This version manually creates ahb_transaction items and 
//               passes them directly to the ahb_driver.
// ==============================================================================

`timescale 1ns/1ps

// ==============================================================================
// 1. OOP Blueprint Includes (Order is STRICTLY IMPORTANT!)
// ==============================================================================
// Step 1: Include the data item first (Driver needs to know it)
`include "../vip/ahb_transaction.sv" 

// Step 2: Include the Driver
`include "../vip/ahb_driver.sv" 

module tb_top; 

    // ==========================================================================
    // 2. Hardware Signal Generation (Clock & Reset)
    // ==========================================================================
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

    // ==========================================================================
    // 3. Instantiate Physical Interfaces & DUT
    // ==========================================================================
    // Physical wire bundle
    ahb_if vif(
        .hclk   (hclk),
        .hresetn(hresetn)
    );

    // Design Under Test (AHB SRAM)
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
    // 4. OOP Verification Execution
    // ==========================================================================
    
    // Declare the Driver and a Transaction handle
    ahb_driver      driver;
    ahb_transaction tr;

    initial begin
        // [Step 0] Initialize physical signals to safe states (Avoid X-propagation)
        vif.haddr  = 32'h0;
        vif.hwrite = 1'b0;
        vif.htrans = 2'b00; // IDLE
        vif.hsize  = 3'b010;
        vif.hburst = 3'b000;
        vif.hwdata = 32'h0;

        // [Step 1] Instantiate the Driver and assign the virtual interface
        driver = new(vif);

        // [Step 2] Wait for hardware reset to complete
        wait(hresetn == 1'b1);
        @(posedge hclk);

        $display("=======================================================");
        $display("[%0t] [TB_TOP] Starting OOP Transaction Test...", $time);
        $display("=======================================================");
        
        // ---------------------------------------------------------
        // Test Scenario 1: Write DEADBEEF to 0x04
        // ---------------------------------------------------------
        tr = new();                  // Create an empty transaction box
        tr.addr     = 32'h0000_0004; // Fill in the address
        tr.data     = 32'hDEADBEEF;  // Fill in the data
        tr.is_write = 1'b1;          // Set operation to WRITE
        
        driver.drive_item(tr);       // Hand the box to the driver

        // ---------------------------------------------------------
        // Test Scenario 2: Read back from 0x04
        // ---------------------------------------------------------
        tr = new();                  // Create a NEW empty transaction box
        tr.addr     = 32'h0000_0004;
        tr.is_write = 1'b0;          // Set operation to READ
        
        driver.drive_item(tr);       // Driver will sample bus and put data back into tr.data

        // ---------------------------------------------------------
        // Result Checking
        // ---------------------------------------------------------
        if (tr.data == 32'hDEADBEEF) begin
            $display("   [SUCCESS] Data Match: 0x%08X", tr.data);
        end else begin
            $display("   [FAIL] Data Mismatch! Expected: 0xDEADBEEF, Got: 0x%08X", tr.data);
        end

        #100;
        $display("=======================================================");
        $display("[%0t] [TB_TOP] Test completed. Shutting down.", $time);
        $display("=======================================================");
        $finish;
    end

endmodule