// -----------------------------------------------------------------------------
// Title   :  Serial Port Test Bench
// Author  :  Mike DeLong
// Version :  0.0
// Details :  Serial Port top level test bench module.
// -----------------------------------------------------------------------------

`timescale 1ns/100ps

module SerialPort_tb();

    // -------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------
    reg        clk_r                   = 1'b1;
    reg        rst_n_r                 = 1'b1;
    reg        tx_r;
    reg        rx_r;
    reg [ 7:0] tx_data_r;
    reg        tx_dv_r;
    reg [ 7:0] rx_data_r;
    reg        rx_dv_r;

    // -------------------------------------------------------------------------
    //
    // -------------------------------------------------------------------------
    SerialPort
    #(
        .SYSTEM_CLOCK(100000000),
        .BAUD_RATE(115200)
    ) DUT (
        .clk(clk_r),
        .rst_n(rst_n_r),
        .rx(rx_r),
        .tx(tx_r),
        .rx_data(rx_data_r),
        .rx_dv(rx_dv_r),
        .tx_data(tx_data_r),
        .tx_dv(tx_dv_r)
    );

    // -------------------------------------------------------------------------
    // Initial Processes
    // -------------------------------------------------------------------------
    initial begin : Clock_Generator
        while(1) begin
            clk_r                      <= ~clk_r;
            #5;

        end
    end

    initial begin : Reset_Generator
        #100;
        rst_n_r                        <= 1'b0;

    end
endmodule // SerialPort_tb