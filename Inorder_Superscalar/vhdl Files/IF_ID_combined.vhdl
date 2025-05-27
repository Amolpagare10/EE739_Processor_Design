-- VHDL equivalent of IF_ID_combined module

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IF_ID_combined is
    Port (
        clk                   : in  std_logic;
        rst                   : in  std_logic; -- Active high
        fetch_stall_i         : in  std_logic;
        rs_full_i             : in  std_logic;
        pc_c_IF_i             : in  std_logic_vector(15 downto 0);
        pc_en_c_IF_i          : in  std_logic;
        IF_ID_reg_clear_i     : in  std_logic;

        -- Outputs from decoder
        ra1_ID_o              : out std_logic_vector(2 downto 0);
        ra2_ID_o              : out std_logic_vector(2 downto 0);
        rb1_ID_o              : out std_logic_vector(2 downto 0);
        rb2_ID_o              : out std_logic_vector(2 downto 0);
        jmp1_pc_reg_ID_o      : out std_logic_vector(2 downto 0);
        jmp2_pc_reg_ID_o      : out std_logic_vector(2 downto 0);
        rrf_in_data1          : out std_logic_vector(15 downto 0);
        rrf_in_data2          : out std_logic_vector(15 downto 0);
        input_entry_1_ID_o    : out std_logic_vector(46 downto 0);
        input_entry_2_ID_o    : out std_logic_vector(46 downto 0);
        pc1                   : out std_logic_vector(15 downto 0);
        pc2                   : out std_logic_vector(15 downto 0)
    );
end IF_ID_combined;

architecture Behavioral of IF_ID_combined is

    signal pc1_IF_w, pc2_IF_w        : std_logic_vector(15 downto 0);
    signal inst1_IF_w, inst2_IF_w    : std_logic_vector(15 downto 0);
    signal pc1_ID_reg_w, pc2_ID_reg_w : std_logic_vector(15 downto 0);
    signal inst1_ID_reg_w, inst2_ID_reg_w : std_logic_vector(15 downto 0);

    -- Components declaration
    component IF_stage
        Port (
            clk            : in  std_logic;
            rst            : in  std_logic;
            fetch_stall_i  : in  std_logic;
            rs_full_i      : in  std_logic;
            pc_c_IF_i      : in  std_logic_vector(15 downto 0);
            pc_en_c_IF_i   : in  std_logic;
            pc1_IF_o       : out std_logic_vector(15 downto 0);
            pc2_IF_o       : out std_logic_vector(15 downto 0);
            inst1_IF_o     : out std_logic_vector(15 downto 0);
            inst2_IF_o     : out std_logic_vector(15 downto 0)
        );
    end component;

    component IF_ID_reg
        Port (
            clk                : in  std_logic;
            rst                : in  std_logic;
            IF_ID_reg_clear_i  : in  std_logic;
            pc1_IF_o           : in  std_logic_vector(15 downto 0);
            pc2_IF_o           : in  std_logic_vector(15 downto 0);
            inst1_IF_o         : in  std_logic_vector(15 downto 0);
            inst2_IF_o         : in  std_logic_vector(15 downto 0);
            pc1_ID_o           : out std_logic_vector(15 downto 0);
            pc2_ID_o           : out std_logic_vector(15 downto 0);
            inst1_ID_o         : out std_logic_vector(15 downto 0);
            inst2_ID_o         : out std_logic_vector(15 downto 0)
        );
    end component;

    component ID_Stage
        Port (
            clk               : in  std_logic;
            rst               : in  std_logic;
            pc1_ID_i          : in  std_logic_vector(15 downto 0);
            pc2_ID_i          : in  std_logic_vector(15 downto 0);
            inst1_ID_i        : in  std_logic_vector(15 downto 0);
            inst2_ID_i        : in  std_logic_vector(15 downto 0);

            -- Bypassed Inputs
            ra1_data          : in std_logic_vector(15 downto 0);
            ra2_data          : in std_logic_vector(15 downto 0);
            rb1_data          : in std_logic_vector(15 downto 0);
            rb2_data          : in std_logic_vector(15 downto 0);
            jmp1_reg_data     : in std_logic_vector(15 downto 0);
            jmp2_reg_data     : in std_logic_vector(15 downto 0);
            ra1_valid         : in std_logic;
            ra2_valid         : in std_logic;
            rb1_valid         : in std_logic;
            rb2_valid         : in std_logic;
            jmp1_reg_valid    : in std_logic;
            jmp2_reg_valid    : in std_logic;
            rrf_tag_data_1    : in std_logic_vector(6 downto 0);
            rrf_tag_data_2    : in std_logic_vector(6 downto 0);

            -- Outputs
            ra1_ID_o          : out std_logic_vector(2 downto 0);
            ra2_ID_o          : out std_logic_vector(2 downto 0);
            rb1_ID_o          : out std_logic_vector(2 downto 0);
            rb2_ID_o          : out std_logic_vector(2 downto 0);
            jmp1_pc_reg       : out std_logic_vector(2 downto 0);
            jmp2_pc_reg       : out std_logic_vector(2 downto 0);
            rrf_in_data1      : out std_logic_vector(15 downto 0);
            rrf_in_data2      : out std_logic_vector(15 downto 0);
            input_entry_1_ID_o : out std_logic_vector(46 downto 0);
            input_entry_2_ID_o : out std_logic_vector(46 downto 0)
        );
    end component;

begin

    -- IF Stage
    IF_stage_inst : IF_stage
        port map (
            clk            => clk,
            rst            => rst,
            fetch_stall_i  => fetch_stall_i,
            rs_full_i      => rs_full_i,
            pc_c_IF_i      => pc_c_IF_i,
            pc_en_c_IF_i   => pc_en_c_IF_i,
            pc1_IF_o       => pc1_IF_w,
            pc2_IF_o       => pc2_IF_w,
            inst1_IF_o     => inst1_IF_w,
            inst2_IF_o     => inst2_IF_w
        );

    -- IF/ID Register
    IF_ID_reg_inst : IF_ID_reg
        port map (
            clk               => clk,
            rst               => rst,
            IF_ID_reg_clear_i => IF_ID_reg_clear_i,
            pc1_IF_o          => pc1_IF_w,
            pc2_IF_o          => pc2_IF_w,
            inst1_IF_o        => inst1_IF_w,
            inst2_IF_o        => inst2_IF_w,
            pc1_ID_o          => pc1_ID_reg_w,
            pc2_ID_o          => pc2_ID_reg_w,
            inst1_ID_o        => inst1_ID_reg_w,
            inst2_ID_o        => inst2_ID_reg_w
        );

    -- ID Stage
    ID_Stage_inst : ID_Stage
        port map (
            clk               => clk,
            rst               => rst,
            pc1_ID_i          => pc1_ID_reg_w,
            pc2_ID_i          => pc2_ID_reg_w,
            inst1_ID_i        => inst1_ID_reg_w,
            inst2_ID_i        => inst2_ID_reg_w,

            ra1_data          => (others => '0'),
            ra2_data          => (others => '0'),
            rb1_data          => (others => '0'),
            rb2_data          => (others => '0'),
            jmp1_reg_data     => (others => '0'),
            jmp2_reg_data     => (others => '0'),
            ra1_valid         => '0',
            ra2_valid         => '0',
            rb1_valid         => '0',
            rb2_valid         => '0',
            jmp1_reg_valid    => '0',
            jmp2_reg_valid    => '0',
            rrf_tag_data_1    => (others => '0'),
            rrf_tag_data_2    => (others => '0'),

            ra1_ID_o          => ra1_ID_o,
            ra2_ID_o          => ra2_ID_o,
            rb1_ID_o          => rb1_ID_o,
            rb2_ID_o          => rb2_ID_o,
            jmp1_pc_reg       => jmp1_pc_reg_ID_o,
            jmp2_pc_reg       => jmp2_pc_reg_ID_o,
            rrf_in_data1      => rrf_in_data1,
            rrf_in_data2      => rrf_in_data2,
            input_entry_1_ID_o => input_entry_1_ID_o,
            input_entry_2_ID_o => input_entry_2_ID_o
        );

    pc1 <= pc1_IF_w;
    pc2 <= pc2_IF_w;

end Behavioral;
