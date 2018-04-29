// -----------------------------------------------------------------------------
// Title   :  Serial Port Transmit Handler Module
// Author  :  Mike DeLong
// Version :  0.0
// Details :  This module contains the serial transmit handler state machine.
// -----------------------------------------------------------------------------

module SerialPort_TX
(
    // ------------------------------------------------------------------------
    // Clocks and Resets
    // ------------------------------------------------------------------------
    input clk,
    input rst_n,

    // ------------------------------------------------------------------------
    // Baud Control Signals
    // ------------------------------------------------------------------------
    input [ 1:0] phase,
    input change,

    // ------------------------------------------------------------------------
    // FIFO Input Signals
    // ------------------------------------------------------------------------
    input [ 7:0] tx_data,
    input tx_dv,
    output full,

    // ------------------------------------------------------------------------
    // Physical Transmit Line
    // ------------------------------------------------------------------------
    output reg tx
);

    // -------------------------------------------------------------------------
    // Local Parameters
    // -------------------------------------------------------------------------
    localparam idle=2'b00, start=2'b01, snd=2'b10, stop=2'b11;

    // -------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------
    reg          [ 1:0] state;
    reg          [ 7:0] tx_data_r;
    reg                 tx_dv_r;
    wire                rst_w;

    // FIFO Related Signal
    wire                tx_fifo_e_w;
    wire         [ 7:0] tx_fifo_dout_w;
    reg                 tx_fifo_rd_r;
    reg          [ 7:0] tx_reg_r;
    reg          [ 2:0] tx_cnt_r;

    // -------------------------------------------------------------------------
    // Concurrent Logic
    // -------------------------------------------------------------------------
    assign rst_w                       = ~rst_n;

    // -------------------------------------------------------------------------
    // Components
    // -------------------------------------------------------------------------
    SerialPort_TX_FIFO32x8 TX_FIFO
    (
        .clk(clk),
        .srst(rst_w),
        .din(tx_data),
        .wr_en(tx_dv),
        .rd_en(tx_fifo_rd_r),
        .dout(tx_fifo_dout_w),
        .full(full),
        .almost_full(),
        .wr_ack(),
        .overflow(),
        .empty(tx_fifo_e_w),
        .almost_empty(),
        .valid(),
        .underflow(),
        .data_count(),
        .prog_full(),
        .prog_empty()
    );
    // -------------------------------------------------------------------------
    // Always Process
    // -------------------------------------------------------------------------
    always @(posedge clk) begin : Serial_Transmitter
        if(rst_n == 0) begin
            state                                <= 'b0;                        // Reset State :: idle
            tx_cnt_r                             <= 'b0;                        // Reset Transmit Counter
            tx_reg_r                             <= 'b0;                        // Reset Transmit Register
            tx_dv_r                              <= 'b0;                        // Reset the Internal Data Valid Strobe

        end else begin
            // -----------------------------------------------------------------
            // Defaults
            // -----------------------------------------------------------------
            tx_fifo_rd_r                         <= 1'b0;                       // Normally Not Asserted (Active High)

            // -----------------------------------------------------------------
            // State Machine
            // -----------------------------------------------------------------
            case(state)

                // -------------------------------------------------------------
                // idle state
                // In this state, we wait for the data in the FIFO.
                // -------------------------------------------------------------
                idle : begin
                    // Control TX Physical Line
                    if((phase == 2'h0) && (change == 1'b1)) begin
                        tx                       <= 1'b1;                       // Normally High While Inactive

                    end

                    // Look for FIFO Data
                    if(tx_fifo_e_w == 1'b0) begin
                        // Switch State
                        state                    <= start;                      // Next State :: start

                        // Read FIFO
                        tx_reg_r                 <= tx_fifo_dout_w;             // Register FIFO Output Data
                        tx_fifo_rd_r             <= 1'b1;                       // Assert FIFO Read Strobe

                    end
                end

                // -------------------------------------------------------------
                // start state
                // In this state, we send the start bit.
                // -------------------------------------------------------------
                start : begin
                    if((phase == 2'h0) && (change == 1'b1)) begin
                        tx                       <= 1'b0;                       // Start Bit (Low)
                        state                    <= snd;                        // Next State :: snd

                    end
                end

                // -------------------------------------------------------------
                // snd state
                // In this state, we send the data bits.
                // -------------------------------------------------------------
                snd : begin
                    if((phase == 2'h0) && (change == 1'b1)) begin
                        // Send Data
                        tx_cnt_r                 <= tx_cnt_r + 1'b1;            // Increment Send Bit Counter
                        tx                       <= tx_reg_r[tx_cnt_r];         // Put TX Bit on the Physical Line

                        // State Change Logic
                        if(tx_cnt_r == 3'h7) begin
                            state                <= stop;                       // Next State :: stop
                            tx_cnt_r             <= 3'b000;                     // Reset Transmit Bit Counter

                        end
                        state                    <= stop;                       // Next State :: stop

                    end
                end

                // -------------------------------------------------------------
                // stop state
                // In this state, we send the stop bit.
                // -------------------------------------------------------------
                stop : begin
                    if((phase == 2'h0) && (change == 1'b1)) begin
                        tx                       <= 1'b0;                       // Put Stop Bit on the TX Line
                        state                    <= idle;                       // Next State :: idle

                    end
                end
            endcase
        end
    end
endmodule