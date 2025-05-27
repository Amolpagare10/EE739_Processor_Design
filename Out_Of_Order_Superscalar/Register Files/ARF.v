module ARF (clk, rst, rename_en, rename_addr, rename_tag, write_en, write_addr, write_data, read_addr, read_data,
            read_busy, read_tag);

    input clk;
    input rst;
    // Rename: assign tag to a register
    input rename_en;
    input [2:0] rename_addr;        // 3 bits for 8 registers
    input [5:0] rename_tag;         // RRF index
    // Writeback: retire and update register with actual data
    input write_en;
    input [2:0] write_addr;
    input [15:0] write_data;
    // Read port
    input [2:0] read_addr;
    output reg [15:0] read_data;
    output reg read_busy;
    output reg [5:0] read_tag;

    // Register fields
    reg busy_bit [0:7];
    reg [15:0] data_field [0:7];
    reg [5:0] tag_field [0:7];  // Maps to RRF tag

    integer i;

    // Initialization and updates
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1) begin
                busy_bit[i] <= 0;
                data_field[i] <= 0;
                tag_field[i] <= 0;
            end
        end else begin
            // Handle rename
            if (rename_en) begin
                busy_bit[rename_addr] <= 1;
                tag_field[rename_addr] <= rename_tag;
            end

            // Handle writeback/retire
            if (write_en) begin
                data_field[write_addr] <= write_data;
                busy_bit[write_addr] <= 0;
            end
        end
    end

    // Combinational read logic
    always @(*) begin
        if (busy_bit[read_addr]) begin
            read_busy = 1;
            read_data = 16'b0;
            read_tag = tag_field[read_addr];
        end else begin
            read_busy = 0;
            read_data = data_field[read_addr];
            read_tag = 6'b0;
        end
    end

endmodule
