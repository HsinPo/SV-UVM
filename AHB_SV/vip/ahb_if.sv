// ==============================================================================
// File        : vip/ahb_if.sv
// Description : AHB-Lite Physical Interface. 
//               Acts as a bundle of wires connecting the DUT and the UVM environment.
// ==============================================================================

interface ahb_if (
    input logic hclk,
    input logic hresetn
);

    // ==========================================
    // Master to Slave Signals (Command & Data)
    // ==========================================
    logic [31:0] haddr;   // Address bus
    logic        hwrite;  // Transfer direction (1: Write, 0: Read)
    logic [ 1:0] htrans;  // Transfer type (IDLE, BUSY, NONSEQ, SEQ)
    logic [ 2:0] hsize;   // Transfer size
    logic [ 2:0] hburst;  // Burst type
    logic [31:0] hwdata;  // Write data bus

    // ==========================================
    // Slave to Master Signals (Response)
    // ==========================================
    logic [31:0] hrdata;  // Read data bus
    logic        hready;  // Ready signal from slave
    logic        hresp;   // Transfer response (OKAY, ERROR)

endinterface