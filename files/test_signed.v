`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:01:52 07/06/2014 
// Design Name: 
// Module Name:    test_signed 
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

// unsigned
// expect: interpret -5 to 11, at the 11th pushing str, led become light
// then at the 5th pushing, led become dark
module test_signed(
    clk, rst, str, dout, dout_flag
    );


input   clk;
input   rst;
input   str;

parameter   SIZE = 4;

output  [SIZE - 1 : 0]  dout;
output                  dout_flag;

reg     [SIZE - 1 : 0]  dout;
reg                     dout_flag;


reg     [SIZE - 1 : 0]  i;
reg     [SIZE - 1 : 0]  flag;
reg                     str_r0;
reg                     str_r1;
reg                     str_pos;

// posedge detect
always @(posedge clk) begin
    if (rst) begin
        // reset
        str_r0 <= 1'b0;
        str_r1 <= 1'b0;
    end
    else begin
        str_r0 <= str;
        str_r1 <= str_r0;
    end
end


always @(posedge clk) begin
    str_pos <= str_r0 && (!str_r1);
end

always @(posedge clk) begin
    if (rst) begin
        // reset
        flag <= 0;
    end
    else begin
        flag <= -4'sd5;    // signed value to unsigned reg
        // flag <= -4'd5;    // unsigned value to unsigned reg
    end
end

always @(posedge clk) begin
    if (rst) begin
        // reset
        i <= 0;
        dout <= 0;
    end
    else begin
        if (str_pos) begin
            i <= i + 1;
            dout <= i;
        end
        else begin
            i <= i;
            dout <= i;
        end
    end
end

always @(posedge clk) begin
    if (rst) begin
        // reset
        dout_flag <= 0;
    end
    else begin
        if (i < flag) begin
            dout_flag <= 1'b0;
        end
        else begin
            dout_flag <= 1'b1;
        end
    end
end

endmodule


// signed 
// expect: interpret -5 to -5, at the 8th pushing str, led become light
// then at the 3 th pushing, led become dark
/*module test_signed(
    clk, rst, str, dout, dout_flag
    );


input   clk;
input   rst;
input   str;

parameter   SIZE = 4;

output  [SIZE - 1 : 0]  dout;
output                  dout_flag;

reg     [SIZE - 1 : 0]  dout;
reg                     dout_flag;


reg     signed  [SIZE - 1 : 0]  i;
reg     signed  [SIZE - 1 : 0]  flag = 0;
reg                             str_r0;
reg                             str_r1;
reg                             str_pos;

// posedge detect
always @(posedge clk) begin
    if (rst) begin
        // reset
        str_r0 <= 1'b0;
        str_r1 <= 1'b0;
    end
    else begin
        str_r0 <= str;
        str_r1 <= str_r0;
    end
end


always @(posedge clk) begin
    str_pos <= str_r0 && (!str_r1);
end

always @(posedge clk) begin
    if (rst) begin
        // reset
        flag <= 0;
    end
    else begin
        // flag <= -4'sd5;    // signed value to signed reg
        flag <= -4'd5;    // unsigned value to signed reg
    end
end

always @(posedge clk) begin
    if (rst) begin
        // reset
        i <= 0;
        dout <= 0;
    end
    else begin
        if (str_pos) begin
            i <= i + 1;
            dout <= i;
        end
        else begin
            i <= i;
            dout <= i;
        end
    end
end

always @(posedge clk) begin
    if (rst) begin
        // reset
        dout_flag <= 0;
    end
    else begin
        if (i < flag) begin
            dout_flag <= 1'b0;
        end
        else begin
            dout_flag <= 1'b1;
        end
    end
end
 
 endmodule*/