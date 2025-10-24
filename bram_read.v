`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2025 00:16:02
// Design Name: 
// Module Name: bram_read
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module bram_reader #(
    parameter ADDR_WIDTH = 15,
    parameter DATA_WIDTH = 32
)(
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  enable,

    output reg  [ADDR_WIDTH-1:0] rd_addr,
    input  wire [DATA_WIDTH-1:0] rd_data,

    output reg                   tvalid,
    output reg  [DATA_WIDTH-1:0] tdata
);

    reg [ADDR_WIDTH-1:0] counter;
    reg [1:0]             latency_counter;
    reg                   reading;

    reg [DATA_WIDTH-1:0] data_pipe1, data_pipe2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter         <= 0;
            rd_addr         <= 0;
            tdata           <= 0;
            tvalid          <= 0;
            data_pipe1      <= 0;
            data_pipe2      <= 0;
            latency_counter <= 0;
            reading         <= 0;
        end else begin
            if (enable) begin
                rd_addr <= counter;
                counter <= (counter == (2**ADDR_WIDTH - 1)) ? 0 : counter + 1;
                reading <= 1;
            end

            // Pipeline for BRAM latency = 2
            data_pipe1 <= rd_data;
            data_pipe2 <= data_pipe1;
            tdata      <= data_pipe2;

            if (reading) begin
                if (latency_counter < 2)
                    latency_counter <= latency_counter + 1;

                tvalid <= (latency_counter >= 2);
            end else begin
                tvalid <= 0;
            end
        end
    end

endmodule



