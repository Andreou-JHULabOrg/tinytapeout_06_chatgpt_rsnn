/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

//`define default_netname none

`default_nettype none

module tt_um_chatgpt_rsnn_paolaunisa (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

//  // All output pins must be assigned. If not used, assign to 0.
//  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
//  assign uio_out = 0;
//  assign uio_oe  = 0;
  
  wire rst = ! rst_n;
  wire output_spikes;
  wire end_writing;
  wire data_written;
  
   
    RSNN_TopModule u_RSNN_TopModule (
        .input_spikes(ui_in[2:0]),
        .clk(clk),
        .reset(rst),
        .system_enable(ena),
        .spike_input_reg_enable(ui_in[3]),
        .RSNN_enable(ui_in[4]),
        .data_in(ui_in[5]),
        .load_params(ui_in[6]),
        .output_spikes(output_spikes),
        .end_writing(end_writing),
        .data_written(data_written)
    );
    
      
  assign uo_out[2:0]=output_spikes;
  assign uo_out[3]=end_writing;
  assign uo_out[4]=data_written;
  assign uo_out[7:5]=3'b0;
  
  
    //assign uo_out = {7'b0000000, spike};
    assign uio_out = 8'b0;
    assign uio_oe = 8'b1; //used bidirectional pins as input
    
endmodule