library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all; 	 
-- Libraries

entity data_memory is 
    port(
        M_add   : in std_logic_vector(15 downto 0);
        M_inp   : in std_logic_vector(15 downto 0);
        clock, reset, Mem_W : in std_logic;
        M_data  : out std_logic_vector(15 downto 0)
    );	 
end entity data_memory;

architecture behav of data_memory is
    type array_of_vectors is array (63 downto 0) of std_logic_vector(7 downto 0);
    signal mem_storage : array_of_vectors := (others => (others => '0'));
    -- To store the instruction registers at mem_Address(M_Add)
begin
    -- Writing Process
    mem_write: process(clock, reset)
    begin
        if reset = '1' then
            mem_storage <= (others => (others => '0')); -- Reset all memory elements to '0'
        elsif rising_edge(clock) then
            if Mem_W = '1' then
                mem_storage(to_integer(unsigned(M_add)))     <= M_inp(7 downto 0);
                mem_storage(to_integer(unsigned(M_add)) + 1) <= M_inp(15 downto 8);
            end if;
        end if;
    end process mem_write;

    -- Reading is asynchronous, just the address is needed to fetch the data.
    M_data <= mem_storage(to_integer(unsigned(M_add))) & mem_storage(to_integer(unsigned(M_add)) + 1);
end architecture behav;
