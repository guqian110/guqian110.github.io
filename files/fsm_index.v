`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Qian Gu (guqian110@gmail.com)
// 
// Create Date:    13:47:47 04/21/2015 
// Design Name: 
// Module Name:    FSM_INDEX 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: A toy project to test index one-hot FSM coding style.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

// index one-hot FSM
module FSM_INDEX(
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


    parameter   [4:0]   // synopsys enum code
                        IDLE  = 5'd0,
                        S1    = 5'd1,
                        S2    = 5'd2,
                        S3    = 5'd3,
                        ERROR = 5'd4;

    // synopsys state_vector state
    reg     [4:0]   // synopsys enum code
                    CS, NS;

    always @(posedge clk) begin
        if (rst) begin
            CS       <= 5'b0;
            CS[IDLE] <= 1'b1;
        end
        else begin
            CS <= NS;
        end
    end

    always @* begin
        NS = 5'b0;
        case (1'b1)     // synthesis full_case parallel_case
            CS[IDLE]: begin
                if      (!i1) NS[IDLE]  = 1'b1;
                else if ( i2) NS[S1]    = 1'b1;
                else if ( i3) NS[S2]    = 1'b1;
                else          NS[ERROR] = 1'b1;
            end
            CS[S1]: begin
                if      (!i2) NS[S1]    = 1'b1;
                else if ( i3) NS[S2]    = 1'b1;
                else if ( i4) NS[S3]    = 1'b1;
                else          NS[ERROR] = 1'b1;
            end
            CS[S2]: begin
                if      ( i3) NS[S2]    = 1'b1;
                else if ( i4) NS[S3]    = 1'b1;
                else          NS[ERROR] = 1'b1;
            end
            CS[S3]: begin
                if      (!i1) NS[IDLE]  = 1'b1;
                else if ( i2) NS[ERROR] = 1'b1;
                else          NS[S3]    = 1'b1;
            end
            CS[ERROR]: begin
                if (restart) NS[IDLE]  = 1'b1;
                else         NS[ERROR] = 1'b1;
            end
        endcase
    end

    always @(posedge clk) begin
        err <= 0;
        o1  <= 0;
        o2  <= 0;
        o3  <= 0;
        o4  <= 0;
        case(1'b1)
            CS[IDLE]: begin
                // do nothing
            end
            CS[S1]: begin
                o2 <= 1;
            end
            CS[S2]: begin
                o2 <= 1;
                o3 <= 1;
            end
            CS[S3]: begin
                o4 <= 1;
            end
            CS[ERROR]: begin
                err <= 1;
            end
        endcase
    end

endmodule