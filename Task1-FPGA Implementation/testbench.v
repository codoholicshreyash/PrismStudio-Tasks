`timescale 1ns / 1ps

module tb_led_controller;
    reg clk = 0;
    reg rst = 1;
    reg button = 0;
    wire [2:0] leds;
    wire clk_0_5hz, clk_2hz;

    led_controller uut (
        .clk(clk),
        .rst(rst),
        .button(button),
        .leds(leds),
        .clk_0_5hz(clk_0_5hz),
        .clk_2hz(clk_2hz)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_led_controller);

        #20 rst = 0;

        #100 button = 1; #40 button = 0;
        #500 button = 1; #40 button = 0;
        #500 button = 1; #40 button = 0;
        #500 button = 1; #40 button = 0;

        #10000 $finish;
    end
endmodule
