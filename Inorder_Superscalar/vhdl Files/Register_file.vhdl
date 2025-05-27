library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
-- Libraries

entity register_file is 
    port(
        clock, RF_W, RF_W_pc, reset : in std_logic;
        A_rega, A_regb, A_s6 : in std_logic_vector(2 downto 0);
        D_s6, D_pc_write : in std_logic_vector(15 downto 0);
        D_pc, D_rega, D_regb : out std_logic_vector(15 downto 0);
        R_out : out std_logic_vector(127 downto 0)
    );
end entity register_file;

architecture behav of register_file is
    type reg_array_type is array (7 downto 0) of std_logic_vector(15 downto 0);
    signal registers : reg_array_type := (
        0 => "0000000000000000",
        1 => "0000000000000001",
        2 => "0000000000000010",
        3 => "0000000000000000",
        4 => "0000000000000101",
        5 => "0000000000000101",
        6 => "0000000000000111",
        7 => "0000000000000000"
    );

begin
    RF_writing: process(clock, reset)
    begin
        if reset = '1' then
            for i in 0 to 7 loop
                registers(i) <= (others => '0'); -- Reset all bits to '0'
            end loop;
        elsif rising_edge(clock) then
            if RF_W = '1' then
                registers(to_integer(unsigned(A_s6))) <= D_s6; -- Write data to the selected register
            end if;
				if RF_W_pc = '1' then
                registers(0) <= D_pc_write; -- Write to the first register R0 (program counter)
            end if;
        end if;
    end process RF_writing;

    -- Asynchronous reading
    D_rega <= registers(to_integer(unsigned(A_rega))); -- Read data from selected register
    D_regb <= registers(to_integer(unsigned(A_regb))); -- Read data from selected register
    D_pc <= registers(0); -- Read the first register
    R_out <= registers(7) & registers(6) & registers(5) & registers(4) & registers(3) & registers(2) & registers(1) & registers(0); -- Concatenate all registers

end architecture behav;
