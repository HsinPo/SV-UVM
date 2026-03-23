// ==============================================================================
// File        : rtl/ahb_sram.v
// Description : AHB-Lite SRAM 
//               (Zero Wait State, supports only Word-aligned Read/Write)
// ==============================================================================

module ahb_sram (
    input  wire        hclk,
    input  wire        hresetn,

    // Signals from Master
    input  wire [31:0] haddr,
    input  wire        hwrite,
    input  wire [ 1:0] htrans,
    input  wire [ 2:0] hsize,
    input  wire [ 2:0] hburst,
    input  wire [31:0] hwdata,

    // Signals from SRAM to Master
    output reg  [31:0] hrdata,
    output wire        hready,
    output wire        hresp
);

    // ==========================================
    // 1. Memory Array Declaration (256 x 32-bit)
    // ==========================================
    reg [31:0] mem [0:255];

    // ==========================================
    // 2. Happy-Path: Always Ready
    // ==========================================
    assign hready = 1'b1; // No wait states
    assign hresp  = 1'b0; // Always OKAY response

    // ==========================================
    // 3. Pipeline Registers (The Core Logic)
    // ==========================================
    // Because AHB has a 1-cycle delay between the Address Phase and Data Phase,
    // the SRAM must "sample" the Master's request during the Address Phase,
    // and process hwdata or hrdata in the following cycle (Data Phase).
    
    reg [31:0] addr_reg;
    reg        write_reg;
    reg        valid_reg; // Indicates if the sampled HTRANS is NONSEQ or SEQ

    always @(posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            addr_reg  <= 32'd0;
            write_reg <= 1'b0;
            valid_reg <= 1'b0;
        end else begin
            // ---------------------------------------------------------
            // TODO: What should you write here?
            // Hint: When Master issues a valid HTRANS (NONSEQ/SEQ) and 
            //       hready is 1, sample haddr and hwrite into the regs!
            // ---------------------------------------------------------
            
        end
    end

    // ==========================================
    // 4. Actual Memory Read/Write (Data Phase)
    // ==========================================
    always @(posedge hclk) begin
        // ---------------------------------------------------------
        // TODO: What should you write here?
        // Hint: If valid_reg is 1 and write_reg is 1, 
        //       write hwdata into mem[addr_reg].
        //       If it is a read (write_reg == 0), 
        //       drive mem[addr_reg] to hrdata.
        // ---------------------------------------------------------

    end

endmodule