module uart_rx (
    input clk,
    input reset,
    input rx,
    output reg [7:0] data_out,
    output reg data_valid
);
    parameter CLK_PER_BIT = 434; // For 115200 baud @ 50MHz

    reg [9:0] rx_shift;
    reg [3:0] bit_idx;
    reg [15:0] clk_cnt;
    reg receiving;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_valid <= 0;
            receiving <= 0;
            clk_cnt <= 0;
            bit_idx <= 0;
        end else begin
            if (!receiving && !rx) begin // Start bit detected
                receiving <= 1;
                clk_cnt <= 0;
                bit_idx <= 0;
            end else if (receiving) begin
                clk_cnt <= clk_cnt + 1;
                if (clk_cnt == CLK_PER_BIT) begin
                    clk_cnt <= 0;
                    rx_shift[bit_idx] <= rx;
                    bit_idx <= bit_idx + 1;
                    if (bit_idx == 9) begin
                        data_out <= rx_shift[8:1]; // 8-bit ASCII
                        data_valid <= 1;
                        receiving <= 0;
                    end
                end else begin
                    data_valid <= 0;
                end
            end else begin
                data_valid <= 0;
            end
        end
    end
endmodule
