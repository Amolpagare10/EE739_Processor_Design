library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Libraries

entity Branch_MUX is
    port (
        Alu_C_Stg_1: in std_logic_vector(15 downto 0);
        Br_Pred: in std_logic_vector(15 downto 0);
        BrVal_Stg_3: in std_logic_vector(15 downto 0);
        BrVal_Stg_4: in std_logic_vector(15 downto 0);
		  -- based on branching values
        CStg_4: in std_logic;
        CStg_3: in std_logic;
        CStg_1: in std_logic;
		  -- based on selecting values 
		  clock: in std_logic;
		  
        Branch_MUX_out: out std_logic_vector(15 downto 0)
    );
end Branch_MUX;

architecture bhv of Branch_MUX is
begin
    selecting: process(CStg_4, CStg_3, CStg_1,clock)
    begin 
        if (CStg_4 = '1') then 
            Branch_MUX_out <= BrVal_Stg_4;
        elsif (CStg_3 = '1') then 
            Branch_MUX_out <= BrVal_Stg_3;
        elsif (CStg_1 = '1') then 
            Branch_MUX_out <= Br_Pred;
        else 
            Branch_MUX_out <= Alu_C_Stg_1;  
        end if;
    end process;
end bhv;
