module cmd_parser (
    input clk,
    input reset,
    input [7:0] rx_data,
    input rx_valid,
    output reg [15:0] display_val,
    output reg show_error,
    output reg update_display
);
    reg [2:0] state;
    reg [15:0] temp_val;
    reg [1:0] digit_count;

    localparam IDLE = 0, CMD = 1, GET_DIGIT = 2, DONE = 3, ERR = 4;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            temp_val <= 0;
            digit_count <= 0;
            display_val <= 0;
            show_error <= 0;
            update_display <= 0;
        end else begin
            update_display <= 0;
            show_error <= 0;

            if (rx_valid) begin
                case (state)
                    IDLE: begin
                        if (rx_data == "S")
                            state <= CMD;
                        else if (rx_data == "C") begin
                            display_val <= 0;
                            update_display <= 1;
                        end else
                            state <= ERR;
                    end
                    CMD: begin
                        if (rx_data >= "0" && rx_data <= "9") begin
                            temp_val <= (rx_data - "0");
                            digit_count <= 1;
                            state <= GET_DIGIT;
                        end else
                            state <= ERR;
                    end
                    GET_DIGIT: begin
                        if (rx_data >= "0" && rx_data <= "9" && digit_count < 4) begin
                            temp_val <= temp_val * 10 + (rx_data - "0");
                            digit_count <= digit_count + 1;
                        end else if (digit_count == 4) begin
                            display_val <= temp_val;
                            update_display <= 1;
                            state <= IDLE;
                        end else
                            state <= ERR;
                    end
                    ERR: begin
                        show_error <= 1;
                        state <= IDLE;
                    end
                endcase
            end
        end
    end
endmodule
