// ==============================================================================
// File        : tb/tb_top.sv
// Description : Top-level testbench for AHB SRAM. Instantiates physical 
//               interfaces, DUT, and the OOP verification environment.
//               Executes Generator and Driver concurrently using fork-join_any.
// ==============================================================================

`timescale 1ns/1ps

// ==============================================================================
// 1. OOP Blueprint Includes (Compilation order matters!)
// ==============================================================================
`include "../vip/ahb_transaction.sv" 
`include "../vip/ahb_generator.sv" 
`include "../vip/ahb_driver.sv" 

module tb_top; 
    
    // ==========================================================================
    // Hardware Signal Declarations
    // ==========================================================================
    logic hclk;
    logic hresetn;

    // Clock and Reset generation
    initial begin hclk = 1'b0; forever #5 hclk = ~hclk; end
    initial begin hresetn = 1'b0; #20 hresetn = 1'b1; end

    // ==========================================================================
    // Physical Interface & DUT Connection
    // ==========================================================================
    ahb_if vif(.hclk(hclk), .hresetn(hresetn));
    
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
    // 2. OOP Verification Infrastructure
    // ==========================================================================
    
    // Declare the parameterized mailbox and OOP components
    mailbox #(ahb_transaction) mbx;    
    ahb_generator              gen;    
    ahb_driver                 driver; 

    initial begin
        // Initialize physical signals to safe states (Avoid X-propagation)
        vif.haddr  = 32'h0; 
        vif.hwrite = 1'b0; 
        vif.htrans = 2'b00; 
        vif.hwdata = 32'h0;

        // [Step 1] Instantiate the mailbox first
        mbx = new();

        // [Step 2] Instantiate components and assign the shared mailbox
        gen    = new(mbx);
        driver = new(vif, mbx);

        // [Step 3] Wait for hardware reset to complete before starting the test
        wait(hresetn == 1'b1);
        @(posedge hclk);

        $display("=======================================================");
        $display("[%0t] [TB_TOP] Automated AHB Environment Started!", $time);
        $display("=======================================================");
        
        // [Step 4] Parallel Execution
        // Start Generator and Driver concurrently. The block exits when 
        // the Generator finishes producing the requested number of packets.
        fork
            gen.run(15);  // Task 1: Generator produces 15 random packets
            driver.run(); // Task 2: Driver infinite loop to consume packets
        join_any          

        // [Step 5] Drain Time & Shutdown
        // Allow the driver enough time to process the final packet from the mailbox
        #100; 
        
        $display("=======================================================");
        $display("[%0t] [TB_TOP] Simulation Finished Successfully!", $time);
        $display("=======================================================");
        
        // Terminate the simulation
        $finish;
    end
endmodule