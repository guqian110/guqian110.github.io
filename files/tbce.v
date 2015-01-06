`timescale 1ns / 1ps
`include "global_define.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Qian Gu
// Email: guqian110@gmail.com
// 
// Create Date:    20:14:34 09/24/2014 
// Design Name: 
// Module Name:    TBCE 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: Tail Biting Convolution Encoder (TBCE)
//              channel encoder for signal bits, rate = 1/3, refer to LTE
//              (n, k, K) = (3, 1, 7)
//              g0 = 133(octal)
//              g1 = 171(octal)
//              g2 = 165(octal)
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Module Declaration                                                         //
////////////////////////////////////////////////////////////////////////////////
module TBCE(
    clk_i, clk_o, rst, din, din_init, din_vld, dout, dout_vld
    );

////////////////////////////////////////////////////////////////////////////////
// Port Declarations                                                          //
////////////////////////////////////////////////////////////////////////////////
    // IO port parameters
    localparam      DIN_INIT_WIDTH = 6;

    // input
    input                               clk_i;  // input data clk
    input                               clk_o;  // output data clk = 3*clk_i
    input                               rst;
    input                               din;
    input   [DIN_INIT_WIDTH -1 : 0]     din_init;
    input                               din_vld;

    // output
    output  reg     dout;
    output  reg     dout_vld;
    
//////////////////////////////////////////////////////////////////////////////// 
// Parameter Declarations                                                     //
////////////////////////////////////////////////////////////////////////////////
    parameter           CONST_LEN = 7,
                        ENCODED_WIDTH = 3,
                        INDX_WIDTH = 6,
                        INDX_MAX = 2,
                        INDX_STEP = 1;

////////////////////////////////////////////////////////////////////////////////
// Reg & Wire Declarations                                                    //
////////////////////////////////////////////////////////////////////////////////
    reg     [CONST_LEN - 2 : 0]      shift_reg;      // m = K - 1
    reg                              tmp;
    reg                              data;
    reg                              tmp_vld;
    reg                              data_vld;
    reg     [ENCODED_WIDTH - 1 : 0]  encoded_data;
    reg                              encoded_data_vld;
    reg     [INDX_WIDTH - 1 : 0]     indx;

////////////////////////////////////////////////////////////////////////////////
// Main Body of Code                                                          //
////////////////////////////////////////////////////////////////////////////////

    // reg the din. delay 2 clk, the 1st clk for initialize the encoder, the 2nd
    // clk to read the input and start to work.
    always @(posedge clk_i) begin
        tmp <= din;
        data <= tmp;    
    end

    // reg the din_vld
    always @(posedge clk_i) begin
        tmp_vld <= din_vld;
        data_vld <= tmp_vld;
    end

    // encode data
    always @(posedge clk_i) begin
        if (rst) begin
            // reset
            encoded_data <= `INIT_VALUE;
            encoded_data_vld <= `INVALID;
            shift_reg <= din_init;
        end
        else begin
            if (data_vld) begin
                encoded_data[0] <= data + shift_reg[4] + shift_reg[3] + shift_reg[1] + shift_reg[0];
                encoded_data[1] <= data + shift_reg[5] + shift_reg[4] + shift_reg[3] + shift_reg[0];
                encoded_data[2] <= data + shift_reg[5] + shift_reg[4] + shift_reg[2] + shift_reg[0];
                encoded_data_vld <= `VALID;
                shift_reg <= {data, shift_reg[5:1]};
            end
            else begin
                encoded_data <= `INIT_VALUE;
                encoded_data_vld <= `INVALID;
                shift_reg <= din_init;
            end
        end
    end

    //////////////////////////////////////////////////////////
    // parallel to serial, clk_o frequency is 3*clk_i    //
    //////////////////////////////////////////////////////////

    // generate the output index
    always @(posedge clk_o) begin
        if (rst) begin
            // reset
            indx <= `INIT_VALUE;
        end
        else begin
            if (encoded_data_vld) begin
                if (indx == INDX_MAX) begin
                    indx <= `INIT_VALUE;
                end
                else begin
                    indx <= indx + INDX_STEP;
                end
            end
            else begin
                indx <= `INIT_VALUE;
            end
        end
    end

    // dout
    always @(posedge clk_o) begin
        if (rst) begin
            // reset
            dout <= `INIT_VALUE;
        end
        else begin
            dout <= encoded_data[indx];
        end
    end

    // dout_vld
    always @(posedge clk_o) begin
        if (rst) begin
            // reset
            dout_vld <= `INVALID;
        end
        else begin
            if (encoded_data_vld) begin
                dout_vld <= `VALID;
            end
            else begin
                dout_vld <= `INVALID;
            end
        end
    end

endmodule
