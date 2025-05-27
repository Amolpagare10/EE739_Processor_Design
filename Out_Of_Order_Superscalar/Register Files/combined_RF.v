//Combined Register file

module unified_register_file (
    input wire clk,
    input wire rst,

    // ========== RRF ALLOCATION ==========
    input wire alloc_req,                   // Allocation request from decode
    output reg [5:0] alloc_tag,             // Allocated RRF tag
    output reg alloc_valid,                 // Set if allocation successful

    // ========== WRITE TO RRF ==========
    input wire rrf_write_en,
    input wire [5:0] rrf_write_tag,
    input wire [15:0] rrf_write_data,
	 
	 // Broadcast outputs to RS
    output reg broadcast_valid,
    output reg [5:0] broadcast_tag, 
    output reg [15:0] broadcast_data,

    // ========== RRF to ARF COMMIT ==========
    input wire commit_en,
    input wire [5:0] commit_rrf_tag,        // RRF index (8-63)
    input wire [2:0] commit_arf_addr,       // ARF index (0-7)

    // ========== READ ==========
    input wire [2:0] read_addr,             // ARF address (0-7)
    output reg [15:0] read_data,
    output reg read_valid,
    output reg read_busy,
    output reg [5:0] read_forward_tag,      // Tag to forward if value not ready

    // ========== Internal State Outputs (for debugging/visualization) ==========
    output reg [15:0] arf_data_out [0:7],
    output reg [15:0] rrf_data_out [8:63]
);

    // ARF: 0-7
    reg [15:0] arf_data [0:7];
    reg busy_bit_arf [0:7];
    reg [5:0] tag_arf [0:7];

    // RRF: 8-63
    reg [15:0] rrf_data [8:63];
    reg busy_bit_rrf [8:63];
    reg valid_bit_rrf [8:63];

    integer i;

    // ========== RESET LOGIC ==========
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1) begin
                arf_data[i] <= 0;
                busy_bit_arf[i] <= 0;
                tag_arf[i] <= 0;
            end
            for (i = 8; i < 64; i = i + 1) begin
                rrf_data[i] <= 0;
                busy_bit_rrf[i] <= 0;
                valid_bit_rrf[i] <= 0;
            end
				
				broadcast_valid <= 0;
            broadcast_tag <= 6'b0;
            broadcast_data <= 16'b0;
				
        end else begin
            // ========== RRF WRITE ==========
            if (rrf_write_en && rrf_write_tag >= 8 && rrf_write_tag < 64) begin
                rrf_data[rrf_write_tag] <= rrf_write_data;
                busy_bit_rrf[rrf_write_tag] <= 0;
                valid_bit_rrf[rrf_write_tag] <= 1;
					 
					 // Broadcast data to RS
                broadcast_valid <= 1;
                broadcast_tag <= write_tag;
                broadcast_data <= write_data;
            end

            // ========== RRF to ARF COMMIT ==========
            if (commit_en && commit_rrf_tag >= 8 && commit_rrf_tag < 64) begin
                arf_data[commit_arf_addr] <= rrf_data[commit_rrf_tag];
                busy_bit_arf[commit_arf_addr] <= 0;
                valid_bit_rrf[commit_rrf_tag] <= 0;
            end
        end
    end

    // ========== RRF TAG ALLOCATION ==========
    always @(*) begin
        alloc_valid = 0;
        alloc_tag = 6'b0;
        if (alloc_req) begin
            for (i = 8; i < 64; i = i + 1) begin
                if (valid_bit_rrf[i] == 0) begin
                    alloc_tag = i[5:0];
                    alloc_valid = 1;
                    disable for;
                end
            end
        end
    end

    always @(posedge clk) begin
        if (alloc_valid)
            valid_bit_rrf[alloc_tag] <= 1;
    end

    // ========== READ LOGIC ==========
    always @(*) begin
        if (busy_bit_arf[read_addr] == 0) begin
            // ARF not busy
            read_data = arf_data[read_addr];
            read_valid = 1;
            read_busy = 0;
            read_forward_tag = 6'b0;
        end else begin
            // ARF busy → get RRF tag
            reg [5:0] tag;
            tag = tag_arf[read_addr];
            if (busy_bit_rrf[tag] == 0 && valid_bit_rrf[tag] == 1) begin
                read_data = rrf_data[tag];
                read_valid = 1;
                read_busy = 0;
                read_forward_tag = 6'b0;
            end else begin
                read_data = 16'b0;
                read_valid = 0;
                read_busy = 1;
                read_forward_tag = tag;
            end
        end
    end

    // ========== Optional: Debug Outputs ==========
    always @(*) begin
        for (i = 0; i < 8; i = i + 1)
            arf_data_out[i] = arf_data[i];
        for (i = 8; i < 64; i = i + 1)
            rrf_data_out[i] = rrf_data[i];
    end

endmodule
