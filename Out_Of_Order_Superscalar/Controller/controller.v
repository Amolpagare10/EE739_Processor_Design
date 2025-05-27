//Controller

module Controller (
    input clk,
    input reset,

    //PC INPUTS
    input [15:0] pc_decode,
    input        valid_decode,

    input [15:0] pc_scheduler,
    input        valid_scheduler,

    input [15:0] pc_exe,
    input        valid_exe,

    input [15:0] pc_rob,
    input        valid_rob,

    // PC OUTPUT 
    output reg [15:0] pc_out,
    output reg        pc_external,   

    //STALLING INPUTS 
    input        stall_req,         
    input [5:0]  stall_opcode,     

    input        resume_scheduler,  
    input        resume_exe,        

    //STALLING OUTPUT
    output reg stop_fetch,
    output reg clear_ifid,

    //FLUSH OUTPUT 
    output reg flush  
);

    // Opcodes 
    localparam OPCODE_JAL = 4'b1100;
    localparam OPCODE_JRL = 4'b1101;
    localparam OPCODE_JRI = 4'b1111;

    // FSM for stalling control
    typedef enum logic [1:0] {
        STALL_NONE,
        STALL_JRL,
        STALL_JRI
    } stall_state_t;

    stall_state_t stall_state;


    // PC PRIORITY LOGIC
	always @(*) begin
        pc_out      = 16'b0;
        pc_external = 0;

        if (valid_rob) begin
            pc_out      = pc_rob;
            pc_external = 1;
        end else if (valid_exe) begin
            pc_out      = pc_exe;
            pc_external = 1;
        end else if (valid_scheduler) begin
            pc_out      = pc_scheduler;
            pc_external = 1;
        end else if (valid_decode) begin
            pc_out      = pc_decode;
            pc_external = 1;
        end
    end


    // STALLING FSM
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            stall_state <= STALL_NONE;
            stop_fetch  <= 0;
            clear_ifid  <= 0;
        end else begin
            clear_ifid <= 0;  

            case (stall_state)
                STALL_NONE: begin
                    if (stall_req) begin
                        case (stall_opcode)
                            OPCODE_JAL: begin
                                clear_ifid  <= 1;
                                stop_fetch  <= 0;
                                stall_state <= STALL_NONE;
                            end
                            OPCODE_JRL: begin
                                clear_ifid  <= 1;
                                stop_fetch  <= 1;
                                stall_state <= STALL_JRL;
                            end
                            OPCODE_JRI: begin
                                clear_ifid  <= 1;
                                stop_fetch  <= 1;
                                stall_state <= STALL_JRI;
                            end
                        endcase
                    end
                end

                STALL_JRL: begin
                    if (resume_scheduler) begin
                        stop_fetch  <= 0;
                        stall_state <= STALL_NONE;
                    end
                end

                STALL_JRI: begin
                    if (resume_exe) begin
                        stop_fetch  <= 0;
                        stall_state <= STALL_NONE;
                    end
                end
            endcase
        end
    end

    // FLUSH ON ROB PC
    reg valid_rob_d;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            flush <= 0;
            valid_rob_d <= 0;
        end else begin
            valid_rob_d <= valid_rob;
            flush <= (valid_rob && !valid_rob_d);  
        end
    end

endmodule
