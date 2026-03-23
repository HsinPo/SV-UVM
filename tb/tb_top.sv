// ==============================================================================
// File        : tb/tb_top.sv
// Description : Top-level verification environment.
//               Responsible for clock/reset generation, DUT instantiation, 
//               and UVM test execution.
// ==============================================================================

`timescale 1ns/1ps

module top; // Note: This module name "top" must match the one in your run.sh

    // ==========================================
    // 1. Global Signals Declaration (Clock & Reset)
    // ==========================================
    logic hclk;
    logic hresetn;

    // ==========================================
    // 2. Clock Generation
    // ==========================================
    // Initialize to 0, toggle every 5ns -> Period = 10ns (100MHz)
    initial begin
        hclk = 1'b0;
        forever #5 hclk = ~hclk; 
    end

    // ==========================================
    // 3. Reset Generation
    // ==========================================
    // Active-low reset: Assert to 0 at start, release to 1 after 20ns
    initial begin
        hresetn = 1'b0;
        #20 hresetn = 1'b1;
    end

    // ==========================================
    // (Undone Steps)
    // 4. Instantiate AHB Interface
    // 5. Instantiate DUT (ahb_sram)
    // 6. UVM run_test() and config_db setup
    // ==========================================

endmodule