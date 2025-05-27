library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity lsu_handler is
    Port ( inst : in STD_LOGIC_VECTOR(15 downto 0);   -- Instruction input
           rd : out STD_LOGIC_VECTOR(2 downto 0);     -- Destination register
           ra : out STD_LOGIC_VECTOR(2 downto 0);     -- Address register
           immed : out STD_LOGIC_VECTOR(15 downto 0)   -- Immediate value output
           );
end lsu_handler;

architecture Behavioral of lsu_handler is
begin
    process(inst)
    begin
        -- Default assignments for unknown opcodes
        rd <= "000";        -- Default value for rd
        ra <= "000";        -- Default value for ra
        immed <= (others => '0'); -- Default value for immed

        -- Check the instruction's opcode
        case inst(15 downto 12) is
            when "0011" =>  -- LLI
                rd <= inst(11 downto 9);
                immed <= "0000000" & inst(8 downto 0);  -- Immediate value extended to 16 bits
                ra <= "000";  -- No address register for LLI

            when "0100" =>  -- LW (Load Word)
                rd <= inst(11 downto 9);
                ra <= inst(8 downto 6);
                immed <= std_logic_vector(signed(inst(5 downto 0)));  -- Sign-extended immediate value

            when "0101" =>  -- SW (Store Word)
                rd <= inst(11 downto 9);
                ra <= inst(8 downto 6);
                immed <= std_logic_vector(signed(inst(5 downto 0)));  -- Sign-extended immediate value

            when "0110" =>  -- LM (Load Multiple)
                rd <= inst(11 downto 9);
                immed <= "00000000" & inst(7 downto 0);  -- Immediate value extended to 16 bits
                ra <= "000";  -- No address register for LM

            when "0111" =>  -- SM (Store Multiple)
                rd <= inst(11 downto 9);
                immed <= "00000000" & inst(7 downto 0);  -- Immediate value extended to 16 bits
                ra <= "000";  -- No address register for SM

            when others =>  -- Default case for invalid instructions
                rd <= "000";  -- Default value for rd
                ra <= "000";  -- Default value for ra
                immed <= (others => '0');  -- Default immediate value
        end case;
    end process;
end Behavioral;
