library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity branch_handler is
    Port ( inst : in STD_LOGIC_VECTOR(15 downto 0);  -- Instruction input
           rb : out STD_LOGIC_VECTOR(2 downto 0);     -- Operand register 1 (rb)
           ra : out STD_LOGIC_VECTOR(2 downto 0);     -- Operand register 2 (ra)
           immed : out STD_LOGIC_VECTOR(15 downto 0)  -- Immediate value output
           );
end branch_handler;

architecture Behavioral of branch_handler is
begin
    process(inst)
    begin
        -- Assigning values to the output signals based on the instruction
        ra <= inst(11 downto 9);           -- Extract bits 11 to 9 for register ra
        rb <= inst(8 downto 6);            -- Extract bits 8 to 6 for register rb
        immed <= std_logic_vector(unsigned(inst(5 downto 0)) * 2); -- Multiply immediate value by 2
    end process;
end Behavioral;
