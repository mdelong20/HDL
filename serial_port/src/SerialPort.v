// -----------------------------------------------------------------------------
// Title   :  Common Serial Port Module
// Author  :  Mike DeLong
// Version :  0.0
// Details :  This module is the top level container for the paramatizable
//            serial port.
// -----------------------------------------------------------------------------

module SerialPort
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
     // Pin Interface
     // ------------------------------------------------------------------------
     input rx,                                                                  // Serial Recieve Line
     output tx,                                                                 // Serial Send Line

     // ------------------------------------------------------------------------
     // RX FIFO Interface
     // ------------------------------------------------------------------------
     output [7:0] rx_data,                                                      // Receive Data Vector
     output rx_dv,                                                              // Receive Data Valid Strobe

     // ------------------------------------------------------------------------
     // TX FIFO Interface
     // ------------------------------------------------------------------------
     input [7:0] tx_data,                                                       // Transmit Data Vector
     input tx_dv,                                                               // Transmit Data Valid Strobe
     output full                                                                // Transmit FIFO Full
    );

    // -------------------------------------------------------------------------
    // Local Parameters
    // -------------------------------------------------------------------------
    // -------------------------------------------------------------------------
    // Concurrent Logic
    // -------------------------------------------------------------------------
    // -------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------
    wire [ 1:0] phase_w;
    wire        change_w;
    wire [ 7:0] rx_data_w;
    wire        rx_dv_w;


    // -------------------------------------------------------------------------
    // Component Instantiations
    // -------------------------------------------------------------------------
    SerialPort_BaudGen
    #(
        .SYSTEM_CLOCK(SYSTEM_CLOCK),
        .BAUD_RATE(BAUD_RATE)
    ) Baud_Rate_Generator (
        .clk(clk),
        .rst_n(rst_n),
        .phase(phase_w),
        .change(change_w)
    );

    SerialPort_RX Serial_Port_Receiver
    (
        .clk(clk),
        .rst_n(rst_n),
        .phase(phase_w),
        .change(change_w),
        .rx_data(rx_data_w),
        .rx_dv(rx_dv_w),
        .rx(rx)
    );

    SerialPort_TX Serial_Port_Transmitter
    (
        .clk(clk),
        .rst_n(rst_n),
        .phase(phase_w),
        .change(change_w),
        .tx_data(tx_data),
        .tx_dv(tx_dv),
        .full(full),
        .tx(tx)
    );

    // -------------------------------------------------------------------------
    // Always Process
    // -------------------------------------------------------------------------
    // -------------------------------------------------------------------------
    // Sync Processes
    // -------------------------------------------------------------------------

endmodule