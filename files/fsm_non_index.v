`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Qian Gu (guqian110@gmail.com)
// 
// Create Date:    15:11:27 04/16/2015 
// Design Name: 
// Module Name:    FSM_NON_INDEX 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: A toy project to test non-index ont-hot FSM coding style.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

// non-index one-hot FSM
module FSM_NON_INDEX(
    input       clk,
    input       rst,
    input       restart,
    input       i1,
    input       i2,
    input       i3,
    input       i4,

    output    reg  err,
    output    reg  o1,
    output    reg  o2,
    output    reg  o3,
    output    reg  o4
    );

    localparam   [4:0]   // synopsys enum code
                        IDLE  = 5'b00001,
                        S1    = 5'b00010,
                        S2    = 5'b00100,
                        S3    = 5'b01000,
                        ERROR = 5'b10000;

    // synopsys state_vector state
    reg     [4:0]   // synopsys enum code
                    CS, NS;

    always @(posedge clk) begin
        if (rst) begin
            CS <= IDLE;
        end
        else begin
            CS <= NS;
        end
    end

    always @* begin
        NS = 5'bx;
        case (CS)     // synthesis full_case parallel_case
            IDLE: begin
                if      (!i1) NS = IDLE;
                else if ( i2) NS = S1;
                else if ( i3) NS = S2;
                else          NS = ERROR;
            end
            S1: begin
                if      (!i2) NS = S1;
                else if ( i3) NS = S2;
                else if ( i4) NS = S3;
                else          NS = ERROR;
            end
            S2: begin
                if      ( i3) NS = S2;
                else if ( i4) NS = S3;
                else          NS = ERROR;
            end
            S3: begin
                if      (!i1) NS = IDLE;
                else if ( i2) NS = ERROR;
                else          NS = S3;
            end
            ERROR: begin
                if (restart) NS = IDLE;
                else         NS = ERROR;
            end
        endcase
    end

    always @(posedge clk) begin
        err <= 0;
        o1  <= 0;
        o2  <= 0;
        o3  <= 0;
        o4  <= 0;
        case(NS)
            IDLE: begin
                // do nothing
            end
            S1: begin
                o2 <= 1;
            end
            S2: begin
                o2 <= 1;
                o3 <= 1;
            end
            S3: begin
                o4 <= 1;
            end
            ERROR: begin
                err <= 1;
            end
        endcase
    end

 endmodule