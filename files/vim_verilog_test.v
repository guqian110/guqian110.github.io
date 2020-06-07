    module my_module #(
        // clk & rst
        input clk,
        input rst_n,
        // module 1 port
         
        input  wire  [31 : 0]  signal_1,   // signal to module 1
        // module 2 port
        
        input  wire  [31 : 0]  signal_2,  // signal to module 2
        input  wire  [31 : 0]  signal_3, // signal to module 2
        // module 3 port
        output  wire  [31 : 0]  signal_4   // input signal to module 3
        )
        // do something
    endmodule