// -----------------------------------------------------------------------------
// Title   :  Serial Port Receive Handler Module
// Author  :  Mike DeLong
// Version :  0.0
// Details :  This module handles the receive of the serial data line.
// -----------------------------------------------------------------------------

module SerialPort_RX
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
     // FIFO Output Signals
     // ------------------------------------------------------------------------
     output [ 7:0] rx_data,
     output rx_dv,

     // ------------------------------------------------------------------------
     // Physical Transmit Line
     // ------------------------------------------------------------------------
     input rx
    );

    // -------------------------------------------------------------------------
    // Local Parameters
    // -------------------------------------------------------------------------
    localparam idle=2'b00, rcv=2'b01, stop=2'b10, done=2'b11;

    // -------------------------------------------------------------------------
    // Typedefs
    // -------------------------------------------------------------------------
    // -------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------
    reg          [ 1:0] state;
    reg          [ 2:0] rx_cnt_r;
    reg          [ 7:0] rx_reg_r;
    reg          [ 7:0] rx_data_r;
    reg                 rx_dv_r;

    // -------------------------------------------------------------------------
    // Concurrent Logic
    // -------------------------------------------------------------------------
    assign rx_data                     = rx_data_r;
    assign rx_dv                       = rx_dv_r;

    // -------------------------------------------------------------------------
    // Components
    // -------------------------------------------------------------------------
    // -------------------------------------------------------------------------
    // Always Process
    // -------------------------------------------------------------------------
    always @(posedge clk) begin : Serial_Receiver
        if(rst_n == 0) begin
            state                                <= 'b0;                        // Reset State :: idle
            rx_cnt_r                             <= 'b0;                        // Reset Receive Counter
            rx_reg_r                             <= 'b0;                        // Reset Receive Register
            rx_data_r                            <= 'b0;                        // Reset the Internal Data Regsiter
            rx_dv_r                              <= 'b0;                        // Reset the Internal Data Valid Strobe

        end else begin
            // -----------------------------------------------------------------
            // Defaults
            // -----------------------------------------------------------------
            rx_dv_r                              <= 1'b0;                       // Normally Not Valid

            // -----------------------------------------------------------------
            // State Machine
            // -----------------------------------------------------------------
            case(state)

                // -------------------------------------------------------------
                // idle state
                // In this state, we wait for the start bit.
                // -------------------------------------------------------------
                idle : begin
                    if((phase == 2'h2) && (change == 1'b1) && (rx == 1'b0)) begin
                        state                    <= rcv;                        // Next State :: rcv

                    end
                end

                // -------------------------------------------------------------
                // rcv state
                // In this state, we wait register the input data line.
                // -------------------------------------------------------------
                rcv : begin
                    if((phase == 2'h2) && (change == 1'b1)) begin
                        // Receive Data
                        rx_cnt_r                 <= rx_cnt_r + 3'h1;            // Increment Receive Bit Counter
                        rx_reg_r[rx_cnt_r]       <= rx;                         // Register Recive Bit

                        // State Change Logic
                        if(rx_cnt_r == 3'h7) begin
                            state                <= stop;                       // Next State :: stop
                            rx_cnt_r             <= 3'b000;                     // Reset Reciever Bit Counter

                        end
                    end
                end

                // -------------------------------------------------------------
                // stop state
                // In this state, we wait for the stop bit.
                // -------------------------------------------------------------
                stop : begin
                    if((phase == 2'h2) && (change == 1'b1) && (rx == 1'b1)) begin
                        state                    <= done;                       // Next State :: done

                    end
                end

                // -------------------------------------------------------------
                // done state
                // In this state, we regsiter the output and data valid strobe.
                // -------------------------------------------------------------
                done : begin
                    rx_data_r                    <= rx_reg_r;                   // Register the Output Data to FIFO
                    rx_dv_r                      <= 1'b1;                       // Strobe the Data Valid Line
                    state                        <= idle;                       // Next State :: idle

                end
            endcase
        end
    end
endmodule // SerialPort_RX