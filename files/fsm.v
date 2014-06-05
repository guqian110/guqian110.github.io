`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:53:47 06/05/2014 
// Design Name: 
// Module Name:    fsm_cs 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////
// Module Declaration                                                            //
///////////////////////////////////////////////////////////////////////////////////
module fsm_cs(
    clk, rst_n, jump, dout_p, dout_q
    );


///////////////////////////////////////////////////////////////////////////////////
// Port Declaration                                                              //
///////////////////////////////////////////////////////////////////////////////////
    // input
    input       clk;
    input       rst_n;
    input       jump;

    // output
    output      dout_p;
    output      dout_q;

    // output attribute
    reg         dout_p;
    reg         dout_q;

/////////////////////////////////////////////////////////////////////////////////////
// Parameter Declaration                                                           //
/////////////////////////////////////////////////////////////////////////////////////
    parameter       IDLE = 4'b0001,
                    S1   = 4'b0010,
                    S2   = 4'b0100,
                    S3   = 4'b1000;

////////////////////////////////////////////////////////////////////////////////////
// Wire & Reg Declaration                                                         //
////////////////////////////////////////////////////////////////////////////////////
    reg     [3:0]       CS;
    reg     [3:0]       NS;

    reg     [3:0]       cnt;
    reg                cnt_fin;

/////////////////////////////////////////////////////////////////////////////////////
// Main Body of Code                                                               //
/////////////////////////////////////////////////////////////////////////////////////

    // counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            cnt <= 4'b0;
        end
        else begin
            if (CS != IDLE) begin
                cnt <= cnt + 1;
            end
            else begin
                cnt <= cnt;
            end
            if (cnt == 4'b1111) begin
                cnt_fin <= 1'b1;
            end
            else begin
                cnt_fin <= 1'b0;
            end
        end
    end

    /////////////////////////////////////////////////
    // FSM                                         //
    /////////////////////////////////////////////////
    // FSM-1
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            CS <= IDLE;
        end
        else begin
            CS <= NS;
        end
    end

    // FSM-2
    always @* begin
        NS = 4'bx;
        case (CS)
            IDLE: begin
                if (jump) begin
                    NS = S1;
                end
                else begin
                    NS = IDLE;
                end
            end
            S1: begin
                if (cnt_fin) begin
                    NS = S2;
                end
                else begin
                    NS = S1;
                end
            end
            S2: begin
                if (cnt_fin) begin
                    NS = S3;
                end
                else begin
                    NS = S2;
                end
            end
            S3: begin
                if (cnt_fin) begin
                    NS = IDLE;
                end
                else begin
                    NS = S3;
                end
            end
            default: begin
                NS = IDLE;
            end
        endcase
    end

    // FSM-3
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // reset
            dout_p <= 1'b0;
            dout_q <= 1'b0;
        end
        else begin
            dout_p <= 1'b0;
            dout_q <= 1'b0;
            case (NS)
                IDLE: begin
                    // do nothing
                end
                S1: begin
                    dout_p <= 1'b1;
                end
                S2: begin
                    dout_q <= 1'b1;
                end
                S3: begin
                    dout_p <= 1'b1;
                    dout_q <= 1'b1;
                end
                default: begin
                    // do nothing
                end
            endcase
        end
    end


endmodule
