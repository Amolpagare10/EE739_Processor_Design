library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity alu_handler is
    Port ( inst_i : in STD_LOGIC_VECTOR(15 downto 0);
           complement_bit_o : out STD_LOGIC;
           alu_invalid_o : out STD_LOGIC;
           rd_o : out STD_LOGIC_VECTOR(2 downto 0);
           ra_o : out STD_LOGIC_VECTOR(2 downto 0);
           rb_o : out STD_LOGIC_VECTOR(2 downto 0);
           imm_o : out STD_LOGIC_VECTOR(15 downto 0)
           );
end alu_handler;

architecture Behavioral of alu_handler is
begin
    process(inst_i)
    begin
        -- Default values for outputs in case of unknown or invalid instruction
        rd_o <= "ZZZ";
        ra_o <= "ZZZ";
        rb_o <= "ZZZ";
        imm_o <= (others => '0');
        complement_bit_o <= '0';
        alu_invalid_o <= '0';
        
        case inst_i(15 downto 12) is
            when "0000" => -- ADI
                rd_o <= inst_i(8 downto 6);
                ra_o <= inst_i(11 downto 9);
                rb_o <= "ZZZ"; -- No second operand
                imm_o <= "000000" & inst_i(5 downto 0); -- Immediate value (extended to 16 bits)
                complement_bit_o <= '0';
                alu_invalid_o <= '0';

            when "0001" => -- Addition
                case inst_i(2 downto 0) is
                    when "000" | "010" | "001" => -- ADA, ADC, ADZ
                        rd_o <= inst_i(5 downto 3);
                        rb_o <= inst_i(8 downto 6);
                        ra_o <= inst_i(11 downto 9);
                        imm_o <= (others => '0');
                        complement_bit_o <= '0';
                        alu_invalid_o <= '0';

                    when "100" | "110" | "101" => -- ACA, ACC, ACZ
                        rd_o <= inst_i(5 downto 3);
                        rb_o <= inst_i(8 downto 6);
                        ra_o <= inst_i(11 downto 9);
                        imm_o <= (others => '0');
                        complement_bit_o <= '1';
                        alu_invalid_o <= '0';

                    when "011" | "111" => -- AWC, ACW (to be completed)
                        rd_o <= inst_i(5 downto 3);
                        rb_o <= inst_i(8 downto 6);
                        ra_o <= inst_i(11 downto 9);
                        imm_o <= (others => '0');
                        complement_bit_o <= '0';
                        alu_invalid_o <= '0';
                    
                    when others =>
                        alu_invalid_o <= '1';
                end case;

            when "0010" => -- NAND operations
                case inst_i(2 downto 0) is
                    when "000" | "010" | "001" => -- NDU, NDC, NDZ
                        rd_o <= inst_i(5 downto 3);
                        rb_o <= inst_i(8 downto 6);
                        ra_o <= inst_i(11 downto 9);
                        imm_o <= (others => '0');
                        complement_bit_o <= '0';
                        alu_invalid_o <= '0';

                    when "100" | "110" | "101" => -- NCU, NCC, NCZ
                        rd_o <= inst_i(5 downto 3);
                        rb_o <= inst_i(8 downto 6);
                        ra_o <= inst_i(11 downto 9);
                        imm_o <= (others => '0');
                        complement_bit_o <= '1';
                        alu_invalid_o <= '0';

                    when others =>
                        alu_invalid_o <= '1';
                end case;

            when others => -- Default case for invalid opcodes
                alu_invalid_o <= '1';
        end case;
    end process;
end Behavioral;
