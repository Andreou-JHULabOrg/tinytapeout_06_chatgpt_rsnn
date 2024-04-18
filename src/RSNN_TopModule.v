`timescale 1ns / 1ps

module RSNN_TopModule(
    input [2:0] input_spikes,           // 3-bit input spikes for the network
    input clk,                          // Clock signal
    input reset,                        // Asynchronous reset, active high
    input system_enable,                // Global enable signal for the entire system (asynchronous)
    input spike_input_reg_enable,       // Enable signal for the input spike register (asynchronous)
    input RSNN_enable,                  // Enable signal specifically for the RSNN (asynchronous)
    input data_in,                      // Serial data input for FIFO Memory
    input load_params,                  // Signal to start loading parameters into the MemoryCU
    output [2:0] output_spikes,         // 3-bit output spikes from the network
    output end_writing,                 // Signal from FIPO_Memory indicating end of writing
    output data_written                 // Signal from FIPO_Memory indicating a bit has been written
);

    // Synchronized enable signals
    wire sync_system_enable;
    wire sync_spike_input_reg_enable;
    wire sync_RSNN_enable;

    // Synchronizers for each asynchronous enable input
    synchronizer sync_system_enable_sync(
        .clk(clk),
        .reset(reset),
        .async_in(system_enable),
        .sync_out(sync_system_enable)
    );

    synchronizer sync_spike_input_reg_enable_sync(
        .clk(clk),
        .reset(reset),
        .async_in(spike_input_reg_enable),
        .sync_out(sync_spike_input_reg_enable)
    );

    synchronizer sync_RSNN_enable_sync(
        .clk(clk),
        .reset(reset),
        .async_in(RSNN_enable),
        .sync_out(sync_RSNN_enable)
    );

    // Intermediate connections
    wire [2:0] registered_spikes;
    wire [215:0] network_weights;
    wire [95:0] network_params;
    wire [311:0] parallel_out;
    wire params_reg_enable;

    // Combining synchronized system_enable with other enables
    wire combined_spike_input_reg_enable = sync_system_enable && sync_spike_input_reg_enable;
    wire combined_RSNN_enable = sync_system_enable && sync_RSNN_enable;
    wire enable_fipo_combined = sync_system_enable && params_reg_enable;

    // Register module to store and forward input spikes
    register #(.WIDTH(3)) input_spike_register (
        .clk(clk),
        .reset(reset),
        .enable(combined_spike_input_reg_enable),
        .data_in(input_spikes),
        .data_out(registered_spikes)
    );

    // FIPO Memory module
    FIPO_Memory fipo_memory (
        .clk(clk),
        .rst(reset),
        .enable(enable_fipo_combined),
        .serial_in(data_in),
        .parallel_out(parallel_out),
        .end_writing(end_writing),
        .data_written(data_written)
    );

    // Assigning weights and parameters from parallel_out
    assign network_weights = parallel_out[311:96]; // Weights are taken from bits 311:96
    assign network_params = parallel_out[95:0];   // Parameters are taken from bits 95:0

    // Memory Control Unit
    MemoryCU memory_control_unit (
        .clk(clk),
        .rst(reset),
        .enable(sync_system_enable),
        .load_params(load_params),
        .params_reg_enable(params_reg_enable)
    );

    // Three-Layer Recurrent Spiking Neural Network
    ThreeLayerNeuralNetwork rsnn (
        .clk(clk),
        .reset(reset),
        .enable(combined_RSNN_enable),
        .external_input_spikes(registered_spikes),
        .input_weights(network_weights),
        .neuron_params(network_params),
        .output_spikes(output_spikes)
    );

endmodule

// Synchronizer module definition
module synchronizer(
    input clk,
    input reset,
    input async_in,
    output reg sync_out
);
    reg intermediate;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            intermediate <= 0;
            sync_out <= 0;
        end else begin
            intermediate <= async_in; // First stage
            sync_out <= intermediate; // Second stage
        end
    end
endmodule
