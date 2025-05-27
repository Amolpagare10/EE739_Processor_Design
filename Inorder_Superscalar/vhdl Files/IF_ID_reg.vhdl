library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IF_ID_reg is
    port (
        clk                : in  STD_LOGIC;
        rst                : in  STD_LOGIC;
        IF_ID_reg_clear_i  : in  STD_LOGIC;
        pc1_IF_o           : in  STD_LOGIC_VECTOR(15 downto 0);
        pc2_IF_o           : in  STD_LOGIC_VECTOR(15 downto 0);
        inst1_IF_o         : in  STD_LOGIC_VECTOR(15 downto 0);
        inst2_IF_o         : in  STD_LOGIC_VECTOR(15 downto 0);
        pc1_ID_o           : out STD_LOGIC_VECTOR(15 downto 0);
        pc2_ID_o           : out STD_LOGIC_VECTOR(15 downto 0);
        inst1_ID_o         : out STD_LOGIC_VECTOR(15 downto 0);
        inst2_ID_o         : out STD_LOGIC_VECTOR(15 downto 0)
    );
end IF_ID_reg;

architecture Behavioral of IF_ID_reg is
    signal pc1_reg, pc2_reg         : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal inst1_reg, inst2_reg     : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
begin

    process(clk, rst)
    begin
        if rst = '1' or IF_ID_reg_clear_i = '1' then
            pc1_reg    <= (others => '0');
            pc2_reg    <= (others => '0');
            inst1_reg  <= (others => '0');
            inst2_reg  <= (others => '0');
        elsif rising_edge(clk) then
            pc1_reg    <= pc1_IF_o;
            pc2_reg    <= pc2_IF_o;
            inst1_reg  <= inst1_IF_o;
            inst2_reg  <= inst2_IF_o;
        end if;
    end process;

    -- Assign internal signals to outputs
    pc1_ID_o   <= pc1_reg;
    pc2_ID_o   <= pc2_reg;
    inst1_ID_o <= inst1_reg;
    inst2_ID_o <= inst2_reg;

end Behavioral;
