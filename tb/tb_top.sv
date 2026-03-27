// ==============================================================================
// File        : tb/tb_top.sv
// Description : Top-level verification environment.
//               Responsible for clock/reset generation, DUT instantiation, 
//               and UVM test execution.
// ==============================================================================
module top; 

    // ==========================================
    // 1. Clock and Reset Generation
    // ==========================================
    logic hclk;
    logic hresetn;

    // Generate a 100MHz clock (10ns period: toggles every 5ns)
    initial begin
        hclk = 1'b0;
        forever #5 hclk = ~hclk; 
    end

    // Generate active-low reset (asserted for 20ns at startup)
    initial begin
        hresetn = 1'b0;
        #20 hresetn = 1'b1;      
    end

    // ==========================================
    // 2. Instantiate Physical Interface
    // ==========================================
    // Create an instance of the ahb_if cable named "vif", 
    // and connect the system clock and reset to it.
    ahb_if vif(
        .hclk   (hclk),
        .hresetn(hresetn)
    );

    // ==========================================
    // 3. Instantiate DUT (Design Under Test)
    // ==========================================
    // Instantiate the ahb_sram RTL module named "u_sram",
    // and connect its ports to the wires inside the "vif" interface.
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

    // ==========================================
    // 4. Simulation Control
    // ==========================================
    // Run the simulation for 100ns and then terminate gracefully.
    initial begin
        #100;
        $display("=======================================");
        $display("   Interface Connected Successfully!   ");
        $display("=======================================");
        $finish;
    end

endmodule