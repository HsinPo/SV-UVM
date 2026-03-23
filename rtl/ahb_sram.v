// ==============================================================================
// File        : rtl/ahb_sram.v
// Description : AHB-Lite SRAM 
//               (Zero Wait State, supports only Word-aligned Read/Write)
// ==============================================================================

module ahb_sram (
    // ==========================================
    // Global Clock and Reset Signals
    // ==========================================
    input  wire        hclk,    // System clock (All operations trigger on posedge)
    input  wire        hresetn, // Active-low system reset (0: reset the SRAM state)

    // ==========================================
    // Master to SRAM (Address Phase Signals)
    // ==========================================
    input  wire [31:0] haddr,   // Target address for the transfer
    input  wire        hwrite,  // Transfer direction (1: Write, 0: Read)
    input  wire [ 1:0] htrans,  // Transfer type (Only 2'b10 NONSEQ or 2'b11 SEQ are valid)
    input  wire [ 2:0] hsize,   // Transfer size (For phase 1, we assume 3'b010 Word only)
    input  wire [ 2:0] hburst,  // Burst type (SRAM mostly ignores this and relies on htrans)
    
    // ==========================================
    // Master to SRAM (Data Phase Signal)
    // ==========================================
    input  wire [31:0] hwdata,  // Write data payload from Master (Used in Write Phase)

    // ==========================================
    // SRAM to Master (Data Phase Signals)
    // ==========================================
    output wire [31:0] hrdata,  // Read data payload to Master (Used in Read Phase)
    output wire        hready,  // Ready signal (1: Ready/Done, 0: Wait state)
    output wire        hresp    // Transfer response (0: OKAY, 1: ERROR for invalid access)
);

    // ==========================================
    // Internal Memory and Pipeline Registers
    // ==========================================
    
    // 1. The Actual Memory Array
    reg [31:0] mem [0:255];     // 256 entries of 32-bit (1 Word)
    // ==========================================
    // 2. Arbitrary: Always Ready
    // ==========================================
    assign hready = 1'b1; // No wait states
    assign hresp  = 1'b0; // Always OKAY response

    // ==========================================
    // 3. Pipeline Registers (The Core Logic)
    // ==========================================
    // Because AHB has a 1-cycle delay between the Address Phase and Data Phase,
    // the SRAM must "sample" the Master's request during the Address Phase,
    // and process hwdata or hrdata in the following cycle (Data Phase).
    reg [31:0] addr_reg;        // Stores the requested address for the next cycle
    reg        write_reg;       // Stores the hwrite command (1: Write, 0: Read)
    reg        valid_reg;       // Asserts to 1 if the sampled htrans is a valid transfer

    always @(posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            addr_reg  <= 32'd0;
            write_reg <= 1'b0;
            valid_reg <= 1'b0;
        end else begin
            // ---------------------------------------------------------
            // When Master issues a valid HTRANS (NONSEQ/SEQ) and 
            // hready is 1, sample haddr and hwrite into the regs.
            // ---------------------------------------------------------
            if (hready) begin             
                if (htrans>2'b01) begin // NONSEQ = 2'b10, SEQ = 2'b11
                    addr_reg <= haddr; // copy the address
                    write_reg <= hwrite; // copy the command
                    valid_reg <= 1'b1;
                end else valid_reg <= 1'b0;
            end
        end
    end

// ==========================================
    // 4. Actual Memory Read/Write (Data Phase)
    // ==========================================
    // Write Logic: Sequential Logic
    // Only update memory on the positive edge of the clock.
    always @(posedge hclk) begin
        // Check the pipeline registers: Is it a valid order AND a write command?
        if (valid_reg == 1'b1 && write_reg == 1'b1) begin
            // Write hwdata into the specific drawer (Word index: addr_reg / 4)
            mem[addr_reg[9:2]] <= hwdata;
        end
    end

    // Read Logic: Combinational Logic
    // For Zero Wait State read, use continuous assignment.
    // As soon as addr_reg changes, hrdata reflects the new drawer's content.
    assign hrdata = mem[addr_reg[9:2]];

endmodule