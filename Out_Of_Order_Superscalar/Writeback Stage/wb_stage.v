module writeback_stage (
    input wire clk,
    input wire rst,

    input wire commit_valid,
    input wire [2:0] commit_rd_tag,
    input wire [15:0] commit_data,     
    output reg [15:0] arf_out [0:7],            
);

    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1)
                arf_out[i] <= 0;
        end else begin
            if (commit_valid) begin
                arf_out[commit_rd_tag] <= commit_data;
            end
        end
    end

endmodule
