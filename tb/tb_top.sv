// ==============================================================================
// File        : tb/tb_top.sv
// Description : Top-level testbench. Instantiates the DUT, connects the physical
//               interface, and kicks off the OOP-based verification environment.
// ==============================================================================

`timescale 1ns/1ps

// Include the VIP package exactly once
`include "../vip/ahb_pkg.sv"

module tb_top; 
    // Import all classes from the package namespace
    import ahb_pkg::*;
    
    // ==========================================================================
    // Hardware Signals and DUT Instantiation
    // ==========================================================================
    logic hclk;
    logic hresetn;

    // Clock and Reset generation
    initial begin hclk = 1'b0; forever #5 hclk = ~hclk; end
    initial begin hresetn = 1'b0; #20 hresetn = 1'b1; end

    // Physical Interface instantiation
    ahb_if vif(.hclk(hclk), .hresetn(hresetn));
    
    // Design Under Test (DUT) instantiation
    ahb_sram u_sram (
        .hclk(hclk), 
        .hresetn(hresetn), 
        .haddr(vif.haddr), 
        .hwrite(vif.hwrite),
        .htrans(vif.htrans), 
        .hsize(vif.hsize), 
        .hburst(vif.hburst), 
        .hwdata(vif.hwdata), 
        .hrdata(vif.hrdata), 
        .hready(vif.hready), 
        .hresp(vif.hresp)
    );

    // ==========================================================================
    // OOP Verification Environment Execution
    // ==========================================================================
    
    // Single environment handle
    ahb_env env; 

    initial begin
        // Initialize bus signals
        vif.haddr  = 32'h0; 
        vif.hwrite = 1'b0; 
        vif.htrans = 2'b00; 
        vif.hwdata = 32'h0;

        // [Build Phase] Instantiate the environment and pass the virtual interface
        env = new(vif); 

        // Wait for hardware reset to complete before driving anything
        wait(hresetn == 1'b1);
        @(posedge hclk);

        // [Run Phase] Kick off the entire verification environment
        env.run();

        // =========================================================
        // Drain Time: Prevent simulation from exiting prematurely
        // =========================================================
        
        // 1. Wait until the Generator has pushed everything and the Driver has fetched it all
        wait(env.mbx.num() == 0);

        // 2. Add extra time for the Driver to finish driving the bus, 
        //    the Monitor to sample, and the Scoreboard to compare the final transactions.
        #500; 
        
        // =========================================================

        // [Report Phase] Print final verification results
        env.report();
        
        $display("[%0t] [TB_TOP] Simulation Finished.", $time);
        $finish;
    end
endmodule