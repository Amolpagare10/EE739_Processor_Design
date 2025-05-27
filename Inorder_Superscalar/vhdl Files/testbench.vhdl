library std;
library ieee;
use ieee.std_logic_1164.all;
-- Libraries

entity Testbench is
end entity;

architecture Behave of Testbench is
--Signal for Clock in Testbench 
signal clock : std_logic:= '1';
signal reset : std_logic:= '0';
signal reset_im, reset_dm : std_logic:= '0';
signal out_temp_r0,r0,R1,R2,R3,R4,R5,R6,R7: std_logic_vector(15 downto 0) := (others => '0'); 
component CPU is
    port (
        clock, reset,reset_im,reset_dm: in std_logic;
        out_temp_r0,R0,R1,R2,R3,R4,R5,R6,R7 : out std_logic_vector(15 downto 0)
    );
end component;


begin
clock<= not clock after 25 ns;
dut_instance:  CPU port map ( clock, reset,reset_im,reset_dm,out_temp_r0,r0,R1,R2,R3,R4,R5,R6,R7);
--Instantiating the component and give the clock and reset and we can see the signals as testbench outputs.
end Behave;