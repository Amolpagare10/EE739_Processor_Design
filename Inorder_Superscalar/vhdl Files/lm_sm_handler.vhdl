library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity lm_sm_handler is
    Port ( clk : in STD_LOGIC; 
           inst_i : in STD_LOGIC_VECTOR(15 downto 0);  -- Instruction input
           rd1_o, rd2_o : out STD_LOGIC_VECTOR(2 downto 0); -- Destination registers
           rb1_o, rb2_o : out STD_LOGIC_VECTOR(2 downto 0); -- Operand registers
           imm1_o, imm2_o : out STD_LOGIC_VECTOR(15 downto 0) -- Immediate values
           );
end lm_sm_handler;

architecture Behavioral of lm_sm_handler is
    integer i;
begin
    -- Process for handling LM and SM instructions based on the clock signal
    process(clk)
    begin
        if rising_edge(clk) then
            case inst_i(15 downto 12) is
                when "0110" =>  -- LM
                    for i in 0 to 3 loop
                        if inst_i(2*i) = '1' then
                            rb1_o <= STD_LOGIC_VECTOR(to_unsigned(i, 3));
                            rd1_o <= inst_i(11 downto 9);
                        else
                            rb1_o <= "ZZZ";
                            rd1_o <= "ZZZ";
                        end if;
                    end loop;
                    imm1_o <= (others => '0');

                when "0111" =>  -- SM
                    for i in 0 to 3 loop
                        if inst_i(2*i) = '1' then
                            rb1_o <= STD_LOGIC_VECTOR(to_unsigned(i, 3));
                            rd1_o <= inst_i(11 downto 9);
                        else
                            rb1_o <= "ZZZ";
                            rd1_o <= "ZZZ";
                        end if;
                    end loop;
                    imm1_o <= (others => '0');

                when others =>  -- Default case
                    rd1_o <= "ZZZ";
                    rb1_o <= "ZZZ";
                    imm1_o <= (others => '0');
            end case;
        end if;
    end process;

    -- Process for handling the second part of LM and SM instructions
    process(inst_i)
    begin
        case inst_i(15 downto 12) is
            when "0110" =>  -- LM
                for i in 0 to 3 loop
                    if inst_i(2*i + 1) = '1' then
                        rb2_o <= STD_LOGIC_VECTOR(to_unsigned(i, 3));
                        rd2_o <= inst_i(11 downto 9);
                    else
                        rb2_o <= "ZZZ";
                        rd2_o <= "ZZZ";
                    end if;
                end loop;
                imm2_o <= (others => '0');

            when "0111" =>  -- SM
                for i in 0 to 3 loop
                    if inst_i(2*i + 1) = '1' then
                        rb2_o <= STD_LOGIC_VECTOR(to_unsigned(i, 3));
                        rd2_o <= inst_i(11 downto 9);
                    else
                        rb2_o <= "ZZZ";
                        rd2_o <= "ZZZ";
                    end if;
                end loop;
                imm2_o <= (others => '0');

            when others =>  -- Default case
                rd2_o <= "ZZZ";
                rb2_o <= "ZZZ";
                imm2_o <= (others => '0');
        end case;
    end process;

end Behavioral;
