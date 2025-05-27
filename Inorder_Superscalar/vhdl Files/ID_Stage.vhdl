library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ID_Stage is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           pc1_ID_i, pc2_ID_i : in STD_LOGIC_VECTOR(15 downto 0);
           inst1_ID_i, inst2_ID_i : in STD_LOGIC_VECTOR(15 downto 0);

           -- Regfile moderator signals
           ra1_data, ra2_data : in STD_LOGIC_VECTOR(15 downto 0);
           ra1_valid, ra2_valid : in STD_LOGIC;
           rb1_data, rb2_data : in STD_LOGIC_VECTOR(15 downto 0);
           rb1_valid, rb2_valid : in STD_LOGIC;
           jmp1_reg_data, jmp2_reg_data : in STD_LOGIC_VECTOR(15 downto 0);
           jmp1_reg_valid, jmp2_reg_valid : in STD_LOGIC;
           rrf_tag_data_1, rrf_tag_data_2 : in STD_LOGIC_VECTOR(2 downto 0);

           -- Outputs to RS
           input_entry_1_ID_o, input_entry_2_ID_o : out STD_LOGIC_VECTOR(46 downto 0);
           -- Outputs to Regfile moderator
           ra1_ID_o, ra2_ID_o : out STD_LOGIC_VECTOR(2 downto 0);
           rb1_ID_o, rb2_ID_o : out STD_LOGIC_VECTOR(2 downto 0);
           jmp1_pc_reg, jmp2_pc_reg : out STD_LOGIC_VECTOR(2 downto 0);
           rrf_in_data1, rrf_in_data2 : out STD_LOGIC_VECTOR(15 downto 0)
           );
end ID_Stage;

architecture Behavioral of ID_Stage is
    -- Internal signals
    signal rd1, rd2, ra1, ra2, rb1, rb2 : STD_LOGIC_VECTOR(2 downto 0);
    signal imm1, imm2 : STD_LOGIC_VECTOR(15 downto 0);
    signal complement_bit1, complement_bit2 : STD_LOGIC;
    signal jmp1_pc, jmp2_pc : STD_LOGIC_VECTOR(15 downto 0);
    signal ret1_pc, ret2_pc : STD_LOGIC_VECTOR(15 downto 0);
    signal br1_pc, br2_pc : STD_LOGIC_VECTOR(15 downto 0);
    signal inst1_w, inst2_w : STD_LOGIC_VECTOR(15 downto 0);
    signal pc1__w, pc2__w : STD_LOGIC_VECTOR(15 downto 0);
    
    -- LSU, Branch, Jump, LM/SM and ALU internal signals for both instructions
    signal rd1_lsu, rd2_lsu, rb1_lsu, rb2_lsu : STD_LOGIC_VECTOR(2 downto 0);
    signal imm1_lsu, imm2_lsu : STD_LOGIC_VECTOR(15 downto 0);

    -- Branch handler internal signals for instructions
    signal ra1_br, ra2_br, rb1_br, rb2_br : STD_LOGIC_VECTOR(2 downto 0);
    signal br1_pc_int, br2_pc_int : STD_LOGIC_VECTOR(15 downto 0);

    -- Jump handler internal signals for instructions
    signal rd1_jmp, rd2_jmp : STD_LOGIC_VECTOR(2 downto 0);
    signal jmp1_pc_reg_int, jmp2_pc_reg_int : STD_LOGIC_VECTOR(2 downto 0);
    signal jmp1_pc_int, jmp2_pc_int : STD_LOGIC_VECTOR(15 downto 0);
    signal ret1_pc_int, ret2_pc_int : STD_LOGIC_VECTOR(15 downto 0);

    -- LM/SM handler internal signals for instructions
    signal rd1a_lmsm, rd2a_lmsm, rb1a_lmsm, rb2a_lmsm : STD_LOGIC_VECTOR(2 downto 0);
    signal imm1a_lmsm, imm2a_lmsm : STD_LOGIC_VECTOR(15 downto 0);

    -- ALU handler internal signals for instructions
    signal rd1_alu, rd2_alu, ra1_alu, ra2_alu, rb1_alu, rb2_alu : STD_LOGIC_VECTOR(2 downto 0);
    signal imm1_alu, imm2_alu : STD_LOGIC_VECTOR(15 downto 0);
    signal complement1_bit_alu, complement2_bit_alu : STD_LOGIC;
    signal alu1_invalid, alu2_invalid : STD_LOGIC;

    -- Ready signals
    signal inst1_ready, inst2_ready : STD_LOGIC;

begin
    -- ALU Handler instantiations
    alu1: entity work.alu_handler
        port map (
            inst_i => inst1_ID_i,
            complement_bit_o => complement1_bit_alu,
            alu_invalid_o => alu1_invalid,
            rd_o => rd1_alu,
            ra_o => ra1_alu,
            rb_o => rb1_alu,
            imm_o => imm1_alu
        );

    alu2: entity work.alu_handler
        port map (
            inst_i => inst2_ID_i,
            complement_bit_o => complement2_bit_alu,
            alu_invalid_o => alu2_invalid,
            rd_o => rd2_alu,
            ra_o => ra2_alu,
            rb_o => rb2_alu,
            imm_o => imm2_alu
        );

    -- LSU Handler instantiations
    lsu1: entity work.lsu_handler
        port map (
            inst_i => inst1_ID_i,
            rd_o => rd1_lsu,
            rb_o => rb1_lsu,
            imm_o => imm1_lsu
        );

    lsu2: entity work.lsu_handler
        port map (
            inst_i => inst2_ID_i,
            rd_o => rd2_lsu,
            rb_o => rb2_lsu,
            imm_o => imm2_lsu
        );

    -- Branch Handler instantiations
    br_h1: entity work.branch_handler
        port map (
            inst_i => inst1_ID_i,
            pc_i => pc1_ID_i,
            ra => ra1_br,
            rb => rb1_br,
            br_pc_o => br1_pc_int
        );

    br_h2: entity work.branch_handler
        port map (
            inst_i => inst2_ID_i,
            pc_i => pc2_ID_i,
            ra => ra2_br,
            rb => rb2_br,
            br_pc_o => br2_pc_int
        );

    -- Jump Handler instantiations
    jmp_h1: entity work.jump_handler
        port map (
            inst_i => inst1_ID_i,
            pc_i => pc1_ID_i,
            jmp_pc_o => jmp1_pc_int,
            ret_pc_o => ret1_pc_int,
            rd_o => rd1_jmp,
            jmp_pc_reg_o => jmp1_pc_reg_int,
            imm_o => imm1_alu
        );

    jmp_h2: entity work.jump_handler
        port map (
            inst_i => inst2_ID_i,
            pc_i => pc2_ID_i,
            jmp_pc_o => jmp2_pc_int,
            ret_pc_o => ret2_pc_int,
            rd_o => rd2_jmp,
            jmp_pc_reg_o => jmp2_pc_reg_int,
            imm_o => imm2_alu
        );

    -- LM/SM Handler instantiations
    lmsm_h1: entity work.lm_sm_handler
        port map (
            clk => clk,
            inst_i => inst1_ID_i,
            rd1_o => rd1a_lmsm,
            rb1_o => rb1a_lmsm,
            imm1_o => imm1a_lmsm,
            rd2_o => rd2a_lmsm,
            rb2_o => rb2a_lmsm,
            imm2_o => imm2a_lmsm
        );

    lmsm_h2: entity work.lm_sm_handler
        port map (
            clk => clk,
            inst_i => inst2_ID_i,
            rd1_o => rd1b_lmsm,
            rb1_o => rb1b_lmsm,
            imm1_o => imm1b_lmsm,
            rd2_o => rd2b_lmsm,
            rb2_o => rb2b_lmsm,
            imm2_o => imm2b_lmsm
        );

    -- First instruction processing process
    process(clk, rst)
    begin
        if rst = '1' then
            inst1_w <= (others => '0');
            pc1__w <= (others => '0');
            rd1 <= (others => '0');
            ra1 <= (others => '0');
            rb1 <= (others => '0');
            imm1 <= (others => '0');
            complement_bit1 <= '0';
            jmp1_pc <= (others => '0');
            ret1_pc <= (others => '0');
            br1_pc <= (others => '0');
            jmp1_pc_reg <= (others => '0');
        else
            inst1_w <= inst1_ID_i;
            pc1__w <= pc1_ID_i;
            case inst1_ID_i(15 downto 12) is
                when "0001" | "0010" | "0000" => -- ALU operations
                    ra1 <= ra1_alu;
                    rb1 <= rb1_alu;
                    rd1 <= rd1_alu;
                    imm1 <= imm1_alu;
                    complement_bit1 <= complement1_bit_alu;
                when "1100" | "1101" | "1111" => -- Jump Instructions
                    jmp1_pc <= jmp1_pc_int;
                    ret1_pc <= ret1_pc_int;
                    rd1 <= rd1_jmp;
                    ra1 <= (others => 'Z');
                    rb1 <= (others => 'Z');
                    imm1 <= imm1_alu;
                    complement_bit1 <= '0';
                    jmp1_pc_reg <= jmp1_pc_reg_int;
                -- Add other cases as needed for different instruction opcodes
                when others => -- Default case
                    ra1 <= (others => 'Z');
                    rb1 <= (others => 'Z');
                    rd1 <= (others => 'Z');
                    imm1 <= (others => '0');
                    complement_bit1 <= '0';
            end case;
        end if;
    end process;

    -- Second instruction processing process
    process(clk, rst)
    begin
        if rst = '1' then
            inst2_w <= (others => '0');
            pc2__w <= (others => '0');
            rd2 <= (others => '0');
            ra2 <= (others => '0');
            rb2 <= (others => '0');
            imm2 <= (others => '0');
            complement_bit2 <= '0';
            jmp2_pc <= (others => '0');
            ret2_pc <= (others => '0');
            br2_pc <= (others => '0');
            jmp2_pc_reg <= (others => '0');
        else
            inst2_w <= inst2_ID_i;
            pc2__w <= pc2_ID_i;
            case inst2_ID_i(15 downto 12) is
                when "0001" | "0010" | "0000" => -- ALU operations
                    ra2 <= ra2_alu;
                    rb2 <= rb2_alu;
                    rd2 <= rd2_alu;
                    imm2 <= imm2_alu;
                    complement_bit2 <= complement2_bit_alu;
                when "1100" | "1101" | "1111" => -- Jump Instructions
                    jmp2_pc <= jmp2_pc_int;
                    ret2_pc <= ret2_pc_int;
                    rd2 <= rd2_jmp;
                    ra2 <= (others => 'Z');  -- High impedance (don't care)
                    rb2 <= (others => 'Z');  -- High impedance (don't care)
                    imm2 <= imm2_alu;
                    complement_bit2 <= '0';
                    jmp2_pc_reg <= jmp2_pc_reg_int;
                when "1000" | "1001" => -- Branch Instructions
                    br2_pc <= br2_pc_int;  -- In RS store PC + 2*imm in RRF and store the reg tag to rd
                    ra2 <= ra2_br;
                    rb2 <= rb2_br;
                    rd2 <= (others => 'Z');  -- No destination register
                    imm2 <= (others => '0');
                    complement_bit2 <= '0';
                when "0011" | "0100" | "0101" => -- LLI, LW, SW Instructions
                    ra2 <= (others => 'Z');
                    rb2 <= rb2_lsu;
                    rd2 <= rd2_lsu;
                    imm2 <= imm2_lsu;
                    complement_bit2 <= '0';
                when "0110" | "0111" => -- LM and SM Instructions
                    rb2 <= rb2b_lmsm;
                    rd2 <= rd2b_lmsm;
                    imm2 <= imm2b_lmsm;
                    complement_bit2 <= '0';
                when others =>  -- Default case (Invalid Instruction)
                    ra2 <= (others => 'Z');
                    rb2 <= (others => 'Z');
                    rd2 <= (others => 'Z');
                    imm2 <= (others => '0');
                    complement_bit2 <= '0';
            end case;
        end if;
    end process;


end Behavioral;
