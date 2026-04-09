// ==============================================================================
// File        : tb/tb_top.sv
// Description : Top-level testbench for AHB SRAM.
//               Includes IP bring-up (Sanity Check) with manual AHB transactions
//               and architectural TODOs for future UVM migration.
// ==============================================================================

`timescale 1ns/1ps

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
    // 4. IP Bring-up: Manual Stimulus for Initial Connectivity Test
    // ==========================================================================
    // TODO: This block is for initial bring-up only. 
    // In a professional UVM environment:
    //   - The DATA values (DEADBEEF) will move to a 'uvm_sequence'.
    //   - The PIN-WIGGLING (timing) will move to a 'uvm_driver'.
    //   - This 'initial' block will be REMOVED from the hardware top.
    // ==========================================================================
    initial begin
        // --- [Initial Reset State] ---
        vif.haddr  = 32'h0;
        vif.hwrite = 1'b0;
        vif.htrans = 2'b00; 
        vif.hsize  = 3'b010;
        vif.hburst = 3'b000;
        vif.hwdata = 32'h0;

        wait(hresetn == 1'b1);
        @(posedge hclk);

        $display("-----------------------------------------");
        $display("[%0t] Starting IP Bring-up...", $time);
        
        // --- [WRITE PHASE] ---
        // [TODO]: Move these assignments to uvm_driver's run_phase()
        vif.haddr  = 32'h0000_0004; 
        vif.hwrite = 1'b1;          
        vif.htrans = 2'b10;         
        
        @(posedge hclk); 
        
        // [TODO]: Data phase logic should be handled by the driver's pipeline logic
        vif.htrans = 2'b00;         
        vif.hwdata = 32'hDEADBEEF;  // [YODO]: Data value should come from a uvm_sequence_item
        
        @(posedge hclk);            
        vif.hwdata = 32'h0;         

        // --- [READ PHASE] ---
        vif.haddr  = 32'h0000_0004; 
        vif.hwrite = 1'b0;          
        vif.htrans = 2'b10;         
        
        @(posedge hclk);            
        vif.htrans = 2'b00;         
        @(posedge hclk);            
        
        // --- [SELF-CHECKING] ---
        // [TODO]: This comparison logic will move to a 'uvm_scoreboard'
        if (vif.hrdata == 32'hDEADBEEF) begin
            $display("=======================================");
            $display("   [SUCCESS] Sanity PASS               ");
            $display("=======================================");
        end else begin
            $display("=======================================");
            $display("   [FAIL] Sanity FAILED                ");
            $display("=======================================");
        end

        #50;
        $finish;
    end

endmodule