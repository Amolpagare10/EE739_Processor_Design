library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IF_stage is
    port (
        clk             : in  STD_LOGIC;
        rst             : in  STD_LOGIC;  -- Active high
        fetch_stall_i   : in  STD_LOGIC;  -- From decoder
        rs_full_i       : in  STD_LOGIC;  -- From RS
        pc_c_IF_i       : in  STD_LOGIC_VECTOR(15 downto 0);  -- New PC from decoder/controller
        pc_en_c_IF_i    : in  STD_LOGIC;  -- Enable from controller

        pc1_IF_o        : out STD_LOGIC_VECTOR(15 downto 0);
        pc2_IF_o        : out STD_LOGIC_VECTOR(15 downto 0);
        inst1_IF_o      : out STD_LOGIC_VECTOR(15 downto 0);
        inst2_IF_o      : out STD_LOGIC_VECTOR(15 downto 0)
    );
end IF_stage;

architecture Behavioral of IF_stage is
    signal pc           : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    type mem_array is array (0 to 255) of STD_LOGIC_VECTOR(15 downto 0);
    signal inst_mem     : mem_array := (
        0  => x"AB32",  1  => x"41F0",  2  => x"0D3C",  3  => x"CE09",
        4  => x"178A",  5  => x"FF21",  6  => x"00BE",  7  => x"7342",
        8  => x"9213",  9  => x"60C5", 10  => x"A5A5", 11  => x"D33F",
        12 => x"1004", 13 => x"EEEE", 14 => x"5A1C", 15 => x"BC00",
        16 => x"9F2D", 17 => x"AF21", 18 => x"4E3C", 19 => x"C7B2",
        20 => x"FE12", 21 => x"8811", 22 => x"1122", 23 => x"0099",
        24 => x"ABCD", 25 => x"7F7F", 26 => x"1001", 27 => x"1208",
        28 => x"3456", 29 => x"7777", 30 => x"FFFF", 31 => x"C001",
        others => (others => '0')
    );

    signal pc1_reg, pc2_reg       : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal inst1_reg, inst2_reg   : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

    signal stall : STD_LOGIC;
begin

    stall <= fetch_stall_i or rs_full_i;

    process(clk, rst)
        variable pc_int  : unsigned(15 downto 0);
        variable index   : integer range 0 to 255;
    begin
        if rst = '1' then
            pc         <= (others => '0');
            pc1_reg    <= (others => '0');
            pc2_reg    <= (others => '0');
            inst1_reg  <= (others => '0');
            inst2_reg  <= (others => '0');
        elsif rising_edge(clk) then
            if stall = '0' then
                if pc_en_c_IF_i = '1' then
                    pc <= pc_c_IF_i;
                else
                    pc <= std_logic_vector(unsigned(pc) + 2);
                end if;

                pc_int := unsigned(pc);
                index := to_integer(pc_int(5 downto 0)); -- Only 6-bit index used
                inst1_reg <= inst_mem(index);
                inst2_reg <= inst_mem((index + 1) mod 256);

                pc1_reg <= pc;
                pc2_reg <= std_logic_vector(unsigned(pc) + 1);
            end if;
            -- else retain old values (latch behavior already handled)
        end if;
    end process;

    -- Assign outputs
    pc1_IF_o   <= pc1_reg;
    pc2_IF_o   <= pc2_reg;
    inst1_IF_o <= inst1_reg;
    inst2_IF_o <= inst2_reg;

end Behavioral;
