module RRF (clk, rst, we, write_tag, write_data, busy_set, busy_tag, read_tag, read_data, read_valid, read_busy, 
            broadcast_valid, broadcast_tag, broadcast_data);
            
    input clk;
    input rst;
    // Write port
    input we;                        // Write enable
    input [5:0] write_tag;          
    input [15:0] write_data;
    // Busy management
    input busy_set;                  // Mark register as busy
    input [5:0] busy_tag;
    // Read interface (for external logic)
    input [5:0] read_tag;
    output reg [15:0] read_data;
    output reg read_valid;
    output reg read_busy;
    // Broadcast outputs to RS
    output reg broadcast_valid;
    output reg [5:0] broadcast_tag;
    output reg [15:0] broadcast_data;

    // Define the RRF structure
    reg busy_bit [0:55];
    reg valid_bit [0:55];
    reg [15:0] data_field [0:55];

    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 56; i = i + 1) begin
                busy_bit[i] <= 0;
                valid_bit[i] <= 0;
                data_field[i] <= 16'b0;
            end
            broadcast_valid <= 0;
            broadcast_tag <= 6'b0;
            broadcast_data <= 16'b0;
        end else begin
            broadcast_valid <= 0; // Default

            // Set busy bit (give it lower priority than write)
            if (busy_set && busy_tag < 56) begin
                busy_bit[busy_tag] <= 1;
                valid_bit[busy_tag] <= 0; // Invalidate data since a new instruction will write
            end

            // Write data to RRF (also clears busy bit)
            if (we && write_tag < 56) begin
                data_field[write_tag] <= write_data;
                valid_bit[write_tag] <= 1;
                busy_bit[write_tag] <= 0;  // <- Key fix

                // Broadcast written value
                broadcast_valid <= 1;
                broadcast_tag <= write_tag;
                broadcast_data <= write_data;
            end
        end
    end

    // Asynchronous read for external units (can be made synchronous if needed)
    always @(*) begin
        if (read_tag < 56) begin
            read_data = data_field[read_tag];
            read_valid = valid_bit[read_tag];
            read_busy = busy_bit[read_tag];
        end else begin
            read_data = 16'b0;
            read_valid = 0;
            read_busy = 0;
        end
    end

endmodule
