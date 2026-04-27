// ==============================================================================
// File        : vip/ahb_scoreboard.sv
// Description : Scoreboard using associative array for sparse memory modeling.
// ==============================================================================

class ahb_scoreboard;
    mailbox #(ahb_transaction) mon_mbx;
    
    // Hash Map for sparse
    logic [31:0] ref_mem [int]; 
    
    int pass_cnt = 0;
    int fail_cnt = 0;

    function new(mailbox #(ahb_transaction) mon_mbx);
        this.mon_mbx = mon_mbx;
    endfunction

    task run();
        ahb_transaction tr;
        $display("[%0t] [SCB] Scoreboard is active.", $time);
        
        forever begin
            mon_mbx.get(tr);

            if (tr.is_write) begin
                
                ref_mem[tr.addr] = tr.data;
                $display("[%0t] [SCB] Model Updated: Addr=0x%08X, Data=0x%08X", $time, tr.addr, tr.data);
            end else begin
                if (ref_mem.exists(tr.addr)) begin
                    if (ref_mem[tr.addr] == tr.data) begin
                        pass_cnt++;
                        $display("[%0t] [SCB] [PASS] Addr=0x%08X", $time, tr.addr);
                    end else begin
                        fail_cnt++;
                        $error("[%0t] [SCB] [FAIL] Addr=0x%08X | Exp: 0x%08X, Act: 0x%08X", $time, tr.addr, ref_mem[tr.addr], tr.data);
                    end
                end else begin
                    $display("[%0t] [SCB] [WARN] Read uninitialized Addr=0x%08X", $time, tr.addr);
                end
            end
        end
    endtask

    function void report();
        $display("\n=======================================================");
        $display(" VERIFICATION REPORT ");
        $display("=======================================================");
        $display("  TOTAL PASS : %0d", pass_cnt);
        $display("  TOTAL FAIL : %0d", fail_cnt);
        $display("=======================================================\n");
    endfunction
endclass