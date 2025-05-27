library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity jump_handler is
    Port ( inst : in STD_LOGIC_VECTOR(15 downto 0);  -- Instruction input
           ra : out STD_LOGIC_VECTOR(2 downto 0);     -- Register for jump address (JAL/JLR)
           rb : out STD_LOGIC_VECTOR(2 downto 0);     -- Destination address register (JLR)
           immed : out STD_LOGIC_VECTOR(15 downto 0)  -- Immediate value output
           );
end jump_handler;

architecture Behavioral of jump_handler is
begin
    process(inst)
    begin
        -- Default assignments for unknown opcodes
        ra <= "000";           -- Default value for ra
        rb <= "000";           -- Default value for rb
        immed <= (others => '0'); -- Default immediate value

        -- Check the instruction's opcode
        case inst(15 downto 12) is
            when "1100" | "1111" =>  -- JAL and JRI instructions
                ra <= inst(11 downto 9);  -- Set ra to the instruction's ra field
                immed <= std_logic_vector(unsigned(inst(8 downto 0)) * 2);  -- Immediate * 2
                rb <= "000";  -- For JAL and JRI, rb is not used, set to zero.

            when "1101" =>  -- JLR instruction
                ra <= inst(11 downto 9);  -- Set ra to the instruction's ra field
                rb <= inst(8 downto 6);   -- Set rb to the instruction's rb field (destination address)
                immed <= (others => '0'); -- No immediate for JLR

            when others =>  -- Default case for invalid instructions
                ra <= "000";  -- Default value for ra
                rb <= "000";  -- Default value for rb
                immed <= (others => '0'); -- Default immediate value
        end case;
    end process;
end Behavioral;
