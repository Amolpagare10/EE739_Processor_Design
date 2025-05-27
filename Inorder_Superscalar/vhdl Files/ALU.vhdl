library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Libraries

entity alu is
    port (
        A: in std_logic_vector(15 downto 0);
        B: in std_logic_vector(15 downto 0);
		  Car: in std_logic_vector(15 downto 0);
        sel: in std_logic_vector(1 downto 0);
        X: out std_logic_vector(15 downto 0);
        alu_carry, alu_zero: out std_logic
    );
end alu;
-- 

architecture a1 of alu is
    function add(A: in std_logic_vector(15 downto 0);
                 B: in std_logic_vector(15 downto 0))
        return std_logic_vector is
        variable sum : std_logic_vector(15 downto 0) := (others => '0');
        variable carry : std_logic := '0';  -- Only one bit needed for carry
    begin
        for i in 0 to 15 loop
            sum(i) := A(i) xor B(i) xor carry;
            carry := (A(i) and B(i)) or (carry and (A(i) xor B(i)));
        end loop;
        return carry&sum;
    end add;

    function nandab(A: in std_logic_vector(15 downto 0);
                    B: in std_logic_vector(15 downto 0))
        return std_logic_vector is
        variable nandofab : std_logic_vector(15 downto 0) := (others => '0');
    begin
        for i in 0 to 15 loop
            nandofab(i) := (A(i) nand B(i));
        end loop;
        return  nandofab;
    end nandab;

begin
    oc: process(A, B, sel)
        variable temp: std_logic_vector(16 downto 0) := (others => '0');
        variable twos_complement_B: std_logic_vector(15 downto 0) := (others => '0'); 
        variable twos_complement_B2: std_logic_vector(15 downto 0) := (others => '0');
    begin
        if sel = "00" then 
            temp := add(A, B);
            X <= temp(15 downto 0);
				
        elsif sel = "01" then
		      temp := '0'& nandab(A, B);
		      temp:=  '0'& nandab(temp(15 downto 0), Car);
				X <= temp(15 downto 0);
            
        elsif sel = "10" then
            temp := '0'& nandab(A, B);
            X <= temp(15 downto 0);
				
		  elsif sel = "11" then
            temp := add(A, B);
				temp:=add(temp(15 downto 0), Car);
            X <= temp(15 downto 0);		
        end if;

        if temp(15 downto 0) = "0000000000000000" then
            alu_zero <= '1';
        else
            alu_zero <= '0';
        end if;
		  alu_carry <= temp(16);
    end process;
end a1;
