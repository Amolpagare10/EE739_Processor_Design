library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all; 
-- Libraries

entity p3_reg is 
	port(
	     p3_w,clock,Databit_stg3,reset : in std_logic;
		 Ra_val,Rb_val: in std_logic_vector(15 downto 0); --(41 downto 38)
		 Save_add,last_3_stg3: in std_logic_vector(2 downto 0); 
         Op_code_stg3: in std_logic_vector(3 downto 0); --(37 downto 35), (34 downto 32), (31 downto 29), (19 downto 17)
		 Immedi: in std_logic_vector(15 downto 0);  --(28 downto 20)
		 Pc_imm2,PC_Stg3: in std_logic_vector(15 downto 0);
		 p3_out: out std_logic_vector(90 downto 0));
end entity p3_reg;

architecture behav of p3_reg is
signal temp: std_logic_vector(90 downto 0):= (others => '0');
begin 

temp_writing : process(clock,reset)
begin

	if (reset = '1') then
		temp <= (others=>'0');
	else
		if (rising_edge(clock) and (p3_w = '1')) then
			temp <= Ra_val & Rb_val & Save_add & Immedi & Pc_imm2 & PC_Stg3 & Op_code_stg3 & last_3_stg3	&Databit_stg3;
	        --90 to 75  --74 to 59   --58 56 --55 to 40 -39to24 -23 to 8   -7to4           --3 to 1     -- 0
		else
			null;
	    end if;
	end if;
   	
end process;

p3_out<= temp;
end architecture behav;