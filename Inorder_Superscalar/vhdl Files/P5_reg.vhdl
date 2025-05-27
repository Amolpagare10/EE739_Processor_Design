library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all; 
-- Libraries

entity p5_reg is 
	port(
	    p5_w,clock,hazardbit_stg5,reset : in std_logic;
		 reg_val_stg5: in std_logic_vector(15 downto 0); 
		 reg_add_stg5: in std_logic_vector(2 downto 0); 
         opcode_stg5: in std_logic_vector(3 downto 0); --(37 downto 35), (34 downto 32), (31 downto 29), (19 downto 17)
		 count_stg5: in std_logic_vector(2 downto 0);  --(28 downto 20)
		 pc_stg5: in std_logic_vector(15 downto 0);
		 stopbit,databit: in std_logic;
		 
		 p5_out: out std_logic_vector(44 downto 0));
		  
end entity p5_reg;

architecture behav of p5_reg is
signal temp: std_logic_vector(44 downto 0):= (others => '0');
begin 

temp_writing : process(clock,reset)
begin

	if (reset = '1') then
		temp <= (others=>'0');
	else
		if (rising_edge(clock) and (p5_w = '1')) then
			temp <= stopbit & databit & count_stg5 & opcode_stg5 & reg_val_stg5 & reg_add_stg5 & hazardbit_stg5 & pc_stg5 ;
				--42 downto 40 --39 downto 36 --35 downto 20   --19 downto 17   --16         --15 downto 0
		else
			null;
		end if;	
	end if; 
   
end process;

p5_out<= temp;
end architecture behav;