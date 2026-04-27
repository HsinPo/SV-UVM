// ==============================================================================
// File        : vip/ahb_env.sv
// Description : Top-level Environment class. Responsible for instantiating,
//               connecting, and running all verification components (Agents & Checkers).
// ==============================================================================

class ahb_env;
    // ---------------------------------------------------------
    // Component and Resource Declarations
    // ---------------------------------------------------------
    ahb_generator  gen;
    ahb_driver     driver;
    ahb_monitor    mon;
    ahb_scoreboard scb;
    
    // Mailboxes for inter-component communication (TLM precursors)
    mailbox #(ahb_transaction) mbx;
    mailbox #(ahb_transaction) mon_mbx;
    
    // Virtual interface handle for DUT interaction
    virtual ahb_if vif;

    // ---------------------------------------------------------
    // Build Phase: Object Instantiation and Connection
    // ---------------------------------------------------------
    function new(virtual ahb_if vif);
        this.vif = vif;
        
        // 1. Construct mailboxes
        mbx     = new();
        mon_mbx = new();
        
        // 2. Instantiate components and pass required handles
        gen    = new(mbx);
        driver = new(vif, mbx);
        mon    = new(vif, mon_mbx);
        scb    = new(mon_mbx);
    endfunction

    // ---------------------------------------------------------
    // Run Phase: Component Execution
    // ---------------------------------------------------------
    task run();
        $display("\n=======================================================");
        $display("[%0t] [ENV] Starting Verification Environment...", $time);
        $display("=======================================================\n");
        
        // Launch all component run tasks concurrently
        fork
            gen.run(15);  // Generate 15 randomized transactions
            driver.run(); 
            mon.run();
            scb.run();
        join_any
    endtask

    // ---------------------------------------------------------
    // Report Phase: Final Summary
    // ---------------------------------------------------------
    function void report();
        // Delegate reporting duty to the scoreboard
        scb.report(); 
    endfunction
    
endclass