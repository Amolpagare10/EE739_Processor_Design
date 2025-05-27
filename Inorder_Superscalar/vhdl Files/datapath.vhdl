library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Datapath is
    Port (
        clock     : in std_logic;
        reset     : in std_logic;
        reset_im  : in std_logic;
        reset_dm  : in std_logic;
        -- Register file observation outputs (from both pipelines)
        r0_out, r1_out, r2_out, r3_out, r4_out, r5_out, r6_out, r7_out : out std_logic_vector(15 downto 0);
    );
end Datapath;

architecture Structural of Datapath is

    -- COMPONENT DECLARATIONS

    -- Combined Fetch and decode stage
    component IF_ID_Combined is
    Port (
        clk     : in std_logic;
        reset   : in std_logic;
        instr1  : out std_logic_vector(15 downto 0);
        instr2  : out std_logic_vector(15 downto 0)
    );
    end component;
    
    -- Reservation station
    component ReservationStation is
    Port (
        clk       : in std_logic;
        reset     : in std_logic;
        instr1    : in std_logic_vector(15 downto 0);
        instr2    : in std_logic_vector(15 downto 0);
        issue1    : out std_logic;
        issue2    : out std_logic
    );
    end component;

    -- Scoreboard to handle (Read after write dependency)
    component Scoreboard is
        generic (
            REG_COUNT   : integer := 8;
            ISSUE_WIDTH : integer := 2
        );
        port (
            clk          : in std_logic;
            rst          : in std_logic;
            issue_valid  : in std_logic_vector(ISSUE_WIDTH - 1 downto 0);
            src1_reg     : in std_logic_vector(ISSUE_WIDTH * 3 - 1 downto 0);
            src2_reg     : in std_logic_vector(ISSUE_WIDTH * 3 - 1 downto 0);
            dest_reg     : in std_logic_vector(ISSUE_WIDTH * 3 - 1 downto 0);
            can_issue    : out std_logic_vector(ISSUE_WIDTH - 1 downto 0);
            commit_valid : in std_logic_vector(ISSUE_WIDTH - 1 downto 0);
            commit_reg   : in std_logic_vector(ISSUE_WIDTH * 3 - 1 downto 0)
        );
    end component;


    -- Old Pipeline for next 3 stages
    component Pipeline is
        Port (
            clock     : in std_logic;
            reset     : in std_logic;
            reset_im  : in std_logic;
            reset_dm  : in std_logic;
            out_temp_r0, R0, R1, R2, R3, R4, R5, R6, R7 : out std_logic_vector(15 downto 0)
        );
    end component;

    -- INTERNAL SIGNALS
    signal instr1, instr2              : std_logic_vector(15 downto 0);
    signal issue1, issue2             : std_logic;
    signal issue_ok1, issue_ok2       : std_logic;

    -- Scoreboard Signals
    signal issue_valid_s     : std_logic_vector(1 downto 0);
    signal can_issue_s       : std_logic_vector(1 downto 0);
    signal src1_reg_s        : std_logic_vector(5 downto 0);  -- 2*3
    signal src2_reg_s        : std_logic_vector(5 downto 0);
    signal dest_reg_s        : std_logic_vector(5 downto 0);

    signal commit_valid_s    : std_logic_vector(1 downto 0);
    signal commit_reg_s      : std_logic_vector(5 downto 0);

begin

    -- FETCH & DECODE SHARED UNIT
    -- Instantiate the IF_ID_combined module
    IF_ID_inst : entity work.IF_ID_combined
        port map (
            clk                   => clk,
            rst                   => rst,
            fetch_stall_i         => fetch_stall_i,
            rs_full_i             => rs_full_i,
            pc_c_IF_i             => pc_c_IF_i,
            pc_en_c_IF_i          => pc_en_c_IF_i,
            IF_ID_reg_clear_i     => IF_ID_reg_clear_i,

            -- Outputs from decoder
            ra1_ID_o              => ra1_ID_o,
            ra2_ID_o              => ra2_ID_o,
            rb1_ID_o              => rb1_ID_o,
            rb2_ID_o              => rb2_ID_o,
            jmp1_pc_reg_ID_o      => jmp1_pc_reg_ID_o,
            jmp2_pc_reg_ID_o      => jmp2_pc_reg_ID_o,
            rrf_in_data1          => rrf_in_data1,
            rrf_in_data2          => rrf_in_data2,
            input_entry_1_ID_o    => input_entry_1_ID_o,
            input_entry_2_ID_o    => input_entry_2_ID_o,
            pc1                   => pc1,
            pc2                   => pc2
        );

    -- SCOREBOARD
    scoreboard_inst : Scoreboard
        generic map (
            REG_COUNT   => 8,
            ISSUE_WIDTH => 2
        )
        port map (
            clk          => clk,
            rst          => rst,
            issue_valid  => issue_valid_s,
            src1_reg     => src1_reg_s,
            src2_reg     => src2_reg_s,
            dest_reg     => dest_reg_s,
            can_issue    => can_issue_s,
            commit_valid => commit_valid_s,
            commit_reg   => commit_reg_s
        );


    -- RESERVATION STATION
    RS : ReservationStation
        Port Map (
            clk     => clock,
            reset   => reset,
            instr1  => instr1,
            instr2  => instr2,
            issue1  => issue1,
            issue2  => issue2
        );

    -- PIPELINE 1
    PIPE1 : Pipeline
        Port Map (
            clock     => clock,
            reset     => reset,
            reset_im  => reset_im,
            reset_dm  => reset_dm,
            out_temp_r0 => open,
            R0 => r0_out_1,
            R1 => r1_out_1,
            R2 => r2_out_1,
            R3 => r3_out_1,
            R4 => r4_out_1,
            R5 => r5_out_1,
            R6 => r6_out_1,
            R7 => r7_out_1
        );

    -- PIPELINE 2
    PIPE2 : Pipeline
        Port Map (
            clock     => clock,
            reset     => reset,
            reset_im  => reset_im,
            reset_dm  => reset_dm,
            out_temp_r0 => open,
            R0 => r0_out_2,
            R1 => r1_out_2,
            R2 => r2_out_2,
            R3 => r3_out_2,
            R4 => r4_out_2,
            R5 => r5_out_2,
            R6 => r6_out_2,
            R7 => r7_out_2
        );

end Structural;
