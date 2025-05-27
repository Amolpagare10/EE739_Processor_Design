module reorder_buffer (
    input wire clk,
    input wire rst,
    input wire [15:0] pc1_i, pc2_i,
    input wire [2:0] rd1_id, rd2_id,       // Destination tags from RRF
    input wire valid1, valid2,             // Valid signals for instructions
    input wire commit_en,

    input wire [15:0] rrf_data [0:7],      // RRF values (8 physical regs)
    output reg [15:0] arf [0:7],           // ARF (8 architectural regs)

    output reg [2:0] commit_rd_tag,
    output reg [15:0] commit_pc,
    output reg commit_valid
);

    parameter ROB_SIZE = 64;

    reg [15:0] rob_pc [0:ROB_SIZE-1];
    reg [2:0] rob_tag [0:ROB_SIZE-1];
    reg rob_valid [0:ROB_SIZE-1];

    reg [5:0] head, tail;

    integer i;

    //========================
    // Reset
    //========================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            head <= 0;
            tail <= 0;
            commit_valid <= 0;
            for (i = 0; i < ROB_SIZE; i = i + 1) begin
                rob_valid[i] <= 0;
            end
            for (i = 0; i < 8; i = i + 1) begin
                arf[i] <= 16'b0;
            end
        end
    end

    //========================
    // ROB Insertion Logic
    //========================
    always @(posedge clk) begin
        if (!rst) begin
            if (valid1) begin
                rob_pc[tail] <= pc1_i;
                rob_tag[tail] <= rd1_id;
                rob_valid[tail] <= 1;
                tail <= (tail + 1) % ROB_SIZE;
            end
            if (valid2) begin
                rob_pc[tail] <= pc2_i;
                rob_tag[tail] <= rd2_id;
                rob_valid[tail] <= 1;
                tail <= (tail + 1) % ROB_SIZE;
            end
        end
    end

    //========================
    // ROB Commit Logic
    //========================
    always @(posedge clk) begin
        if (!rst) begin
            if (commit_en && rob_valid[head]) begin
                commit_pc <= rob_pc[head];
                commit_rd_tag <= rob_tag[head];
                commit_valid <= 1;

                // Write to ARF
                arf[rob_tag[head]] <= rrf_data[rob_tag[head]];

                // Deallocate ROB entry
                rob_valid[head] <= 0;
                head <= (head + 1) % ROB_SIZE;
            end else begin
                commit_valid <= 0;
            end
        end
    end

endmodule
