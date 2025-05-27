library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all; 
-- Libraries

entity P4_Reg is 
	port(
	    p4_w,clock,reset : in std_logic;
		 hazardbit_4: in std_logic; --(55)
		 Ra_data: in std_logic_vector(15 downto 0);  --(54 downto 39)
		 Alu_out: in std_logic_vector(15 downto 0);  --(38 downto 23)
		 Ra_Rc: in std_logic_vector(2 downto 0);  --(22 downto 20)
		 PC_in: in std_logic_vector(15 downto 0); --(19 downto 4)
		 Op_code: in std_logic_vector(3 downto 0); --(3 downto 0)
		 stopbit,databit: in std_logic; 
		 
		 p4_out: out std_logic_vector(57 downto 0));
end entity P4_Reg;

architecture behav of P4_Reg is
signal temp: std_logic_vector(57 downto 0):= (others => '0');
begin 

temp_writing : process(clock,reset)
begin

	if (reset = '1') then
		temp <= (others=>'0');
	else
		if (rising_edge(clock) and (p4_w = '1')) then
			temp <=  stopbit & databit &   hazardbit_4 & Ra_data & Alu_out & Ra_Rc & PC_in & Op_code;
		else
			null;
		end if;
	end if; 
	
end process;
p4_out<= temp;
end architecture behav;