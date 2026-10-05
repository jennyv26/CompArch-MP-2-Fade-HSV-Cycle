`timescale 10ns/10ns
`include "mp2.sv"

module mp2_tb;

    parameter INC_DEC_INTERVAL = 60;
    parameter INC_DEC_MAX = 6;
    parameter PWM_INTERVAL = 100;

    logic clk = 0;
    logic RGB_R;
    logic RGB_G;        
    logic RGB_B;

    mp2 # (
        .INC_DEC_INTERVAL   (INC_DEC_INTERVAL),
        .INC_DEC_MAX        (INC_DEC_MAX),
        .PWM_INTERVAL       (PWM_INTERVAL)
    ) u0 (
        .clk                (clk), 
        .RGB_R              (RGB_R),
        .RGB_G              (RGB_G),
        .RGB_B              (RGB_B)
    );

    initial begin
        $dumpfile("mp2.vcd");
        $dumpvars(0, mp2_tb);
        #60000000
        $finish; 
    end

    always begin
        #4 clk = ~clk;
    end

endmodule