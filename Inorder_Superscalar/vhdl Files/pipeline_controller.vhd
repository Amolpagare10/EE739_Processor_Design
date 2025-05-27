library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Libraries

entity pipeline_controller is
	port (
        clock: in std_logic;
        cd4,cd5,cd6:in std_logic;
        db_stg3,db_stg4,db_stg5:in std_logic;
            count: in std_logic_vector(2 downto 0);
            opc_stg3: in std_logic_vector(3 downto 0);
            opc_stg4: in std_logic_vector(3 downto 0);
            opc_stg5: in std_logic_vector(3 downto 0);
            opc_stg6: in std_logic_vector(3 downto 0);
-- A priority based method on which pipeline registers to open based on which type of instruction is in which stage
    PC_start: out std_logic;
	 P1: out std_logic;
    P2: out std_logic
    );
end pipeline_controller;

architecture bhv of pipeline_controller is
    signal P1_cont, P2_cont, PC_start_cont: std_logic := '1';
begin
    selecting: process(clock)
    begin 
        if rising_edge(clock) then
            -- Default assignments
            PC_start_cont <= '1';
            P1_cont <= '1';
            P2_cont <= '1';

            -- Edge-sensitive conditions
            if falling_edge(clock) then
                -- Conditions for falling edge
                if (opc_stg6 = "1001" or opc_stg6 = "1010" or opc_stg6 = "1101" or opc_stg6 = "1000" or opc_stg6 = "1111") and cd6 = '1' then
                    P1_cont <= '1';
                    P2_cont <= '1';
						  
					 elsif (opc_stg5 = "1001" or opc_stg5 = "1010" or opc_stg5 = "1101" or opc_stg5 = "1000" or opc_stg5 = "1111") and cd5 = '1' then
                    P1_cont <= '1';
                    P2_cont <= '0';
						  
					 elsif (opc_stg4 = "1001" or opc_stg4 = "1010" or opc_stg4 = "1101" or opc_stg4 = "1000" or opc_stg4 = "1111") and cd4 = '1' then
                    P1_cont <= '0';
                    P2_cont <= '0';	
						  
						  ----------------------------------------------------
					 elsif (opc_stg5 = "1100") and db_stg5 = '0' then
                    P1_cont <= '1';
                    P2_cont <= '1';	
						  
					 elsif (opc_stg4 = "1100") and db_stg4 = '0' then
                    P1_cont <= '1';
                    P2_cont <= '0';	
						  
					 elsif (opc_stg3 = "1100") and db_stg3 = '0' then
                    P1_cont <= '0';
                    P2_cont <= '0';							  
						  
						  ----------------------------------------------------						  
					 elsif (opc_stg5 = "0111" and count = "000") then
                    PC_start_cont <= '1';
                    P1_cont <= '1';
                    P2_cont <= '1';
						  
                elsif (opc_stg3 = "0110" and count /= "000") then
                    PC_start_cont <= '0';
                    P1_cont <= '0';
                    P2_cont <= '0';
						  
					 elsif (opc_stg6 = "0110" and count = "000") then
                    PC_start_cont <= '1';
                    P1_cont <= '1';
                    P2_cont <= '1';
						  
                elsif (opc_stg3 = "0111" and count /= "000") then
                    PC_start_cont <= '0';
                    P1_cont <= '0';
                    P2_cont <= '0';
						  ----------------------------------------------------
                end if;
            end if;
        end if;
    end process selecting;

    PC_start <= PC_start_cont;
    P1 <= P1_cont;
    P2 <= P2_cont;
end bhv;



