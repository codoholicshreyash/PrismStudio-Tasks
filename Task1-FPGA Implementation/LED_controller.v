`timescale 1ns / 1ps
`define FAST_SIM

module led_controller (
    input clk,
    input rst,
    input button,
    output reg [2:0] leds,
    output reg clk_0_5hz,
    output reg clk_2hz
);

`ifdef FAST_SIM
    parameter DIV_0_5HZ = 50;
    parameter DIV_2HZ   = 12;
`else
    parameter DIV_0_5HZ = 100_000_000;
    parameter DIV_2HZ   = 25_000_000;
`endif

reg [26:0] counter_0_5hz = 0;
reg [25:0] counter_2hz = 0;

reg button_ff = 0;
wire button_rising = button & ~button_ff;

always @(posedge clk)
    button_ff <= button;

always @(posedge clk) begin
    if (rst) begin
        counter_0_5hz <= 0;
        clk_0_5hz <= 0;
    end else if (counter_0_5hz == DIV_0_5HZ/2 - 1) begin
        clk_0_5hz <= ~clk_0_5hz;
        counter_0_5hz <= 0;
    end else begin
        counter_0_5hz <= counter_0_5hz + 1;
    end
end

always @(posedge clk) begin
    if (rst) begin
        counter_2hz <= 0;
        clk_2hz <= 0;
    end else if (counter_2hz == DIV_2HZ/2 - 1) begin
        clk_2hz <= ~clk_2hz;
        counter_2hz <= 0;
    end else begin
        counter_2hz <= counter_2hz + 1;
    end
end

reg [1:0] state = 0;

always @(posedge clk) begin
    if (rst) begin
        state <= 0;
        leds <= 3'b000;
    end else if (button_rising) begin
        state <= state + 1;
    end

    case (state)
        2'd0: leds <= 3'b000;
        2'd1: leds <= clk_0_5hz ? 3'b001 : 3'b000;
        2'd2: leds <= clk_2hz   ? 3'b010 : 3'b000;
        2'd3: leds <= clk_2hz   ? 3'b111 : 3'b000;
    endcase
end

endmodule
