// -----------------------------------------------------------------------------
// Title   :  Common Serial Port Baud Rate Generator Module
// Author  :  Mike DeLong
// Version :  0.0
// Details :  This module generates the baud rate clock for the TX/RX modules.
// -----------------------------------------------------------------------------

module SerialPort_BaudGen
    #(
      parameter SYSTEM_CLOCK           = 100000000,
      parameter BAUD_RATE              = 115200
     )
    (
     // ------------------------------------------------------------------------
     // Clock and Reset
     // ------------------------------------------------------------------------
     input clk,                                                                 // Input Logic Clock
     input rst_n,                                                               // Input Logic Reset (Active Low)

     // ------------------------------------------------------------------------
     // Baud Rate
     // ------------------------------------------------------------------------
     output [ 1:0] phase,                                                       // Baud Rate Phase
     output change                                                              // Baud Rate Change Strobe
    );

    // -------------------------------------------------------------------------
    // Local Parameters
    // -------------------------------------------------------------------------
    localparam QCNT                    = SYSTEM_CLOCK/(BAUD_RATE*4);            // Quarter Count

    // -------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------
    reg unsigned [ 1:0] phase_r;
    reg unsigned [31:0] baud_cnt_r;
    reg                 change_r;

    // -------------------------------------------------------------------------
    // Concurrent Logic
    // -------------------------------------------------------------------------
    assign change                      = change_r;                             // Assign Internal Signal to Port
    assign phase                       = phase_r;                              // Assign Internal Signal to Port

    // -------------------------------------------------------------------------
    // Always Process
    // -------------------------------------------------------------------------
    always @(posedge clk) begin : Baud_Rate_Generator
        if(rst_n == 1'b1) begin
            phase_r                    <= 2'h0;                                 // Reset Phase Position Counter
            change_r                   <= 1'b0;                                 // Reset Change Strobe
            baud_cnt_r                 <= 32'h0;                                // Reset Baud Rate Counter

        end else begin
            // Defaults
            change_r                   <= 1'b0;                                 // Normally Deasserted (Active High)

            // Logic
            if(baud_cnt_r < QCNT) begin
                baud_cnt_r             <= baud_cnt_r + 2'h1;                    // Increment Baud Rate Counter

            end else begin
                baud_cnt_r             <= 32'h0;                                // Reset Counter
                change_r               <= 1'b1;                                 // Assert Change Strobe
                phase_r                <= phase_r + 2'h1;                       // Increment Phase Counter (Roll)

            end
        end
    end
endmodule