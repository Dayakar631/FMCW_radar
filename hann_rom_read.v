`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.06.2025 23:58:44
// Design Name: 
// Module Name: hann_rom_read
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


module hann_rom_reader #(
    parameter ADDR_WIDTH = 7,     // log2(128)
    parameter DATA_WIDTH = 16
)(
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  enable,

    output reg  [ADDR_WIDTH-1:0] rd_addr,
    input  wire [DATA_WIDTH-1:0] rd_data,

    output reg                   tvalid,  // high 1 cycle before tdata
    output reg  [DATA_WIDTH-1:0] tdata
);

    reg [ADDR_WIDTH-1:0] counter;

    // Two pipeline registers to account for ROM latency
    reg [DATA_WIDTH-1:0] data_pipe1, data_pipe2;
    reg                  valid_pipe0, valid_pipe1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter       <= 0;
            rd_addr       <= 0;
            data_pipe1    <= 0;
            data_pipe2    <= 0;
            valid_pipe0   <= 0;
            valid_pipe1   <= 0;
            tdata         <= 0;
            tvalid        <= 0;
        end else begin
            // ---- Address Generation ----
            if (enable) begin
                rd_addr <= counter;
                if (counter == 127)
                    counter <= 0;
                else
                    counter <= counter + 1;
            end

            // ---- ROM Latency Compensation ----
            data_pipe1  <= rd_data;
            data_pipe2  <= data_pipe1;
            tdata       <= data_pipe2;

            valid_pipe0 <= enable;
            valid_pipe1 <= valid_pipe0;
            tvalid      <= valid_pipe1;  // high 1 cycle before tdata
        end
    end

endmodule

