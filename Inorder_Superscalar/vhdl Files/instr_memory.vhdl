library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
-- Libraries

entity instr_memory is 
    port(
        M_add_i     : in std_logic_vector(15 downto 0); -- Memory address input
        M_inp_i     : in std_logic_vector(15 downto 0); -- Memory data input
        clock, reset, Mem_W_i : in std_logic; -- Control signals
        M_data_i    : out std_logic_vector(15 downto 0) -- Memory data output
    );	 
end entity instr_memory;

architecture behav of instr_memory is
    -- Define the type for memory storage
    type array_of_vectors is array (63 downto 0) of std_logic_vector(7 downto 0);
    
    -- Initialize memory with default values and 10 instructions
    signal mem_storage : array_of_vectors := (
    0  => "00010010",  -- Low byte of instruction 1
    1  => "10011000",  -- High byte of instruction 1
    2  => "00010010",  -- Low byte of instruction 2
    3  => "10011010",  -- High byte of instruction 2
    4  => "00010010",  -- Low byte of instruction 3
    5  => "10011001",  -- High byte of instruction 3
    6  => "00010010",  -- Low byte of instruction 4
    7  => "10011011",  -- High byte of instruction 4
    8  => "00010010",  -- Low byte of instruction 5
    9  => "10011100",  -- High byte of instruction 5
    10 => "00010010",  -- Low byte of instruction 6
    11 => "10011110",  -- High byte of instruction 6
    12 => "00010010",  -- Low byte of instruction 7
    13 => "10011101",  -- High byte of instruction 7
    14 => "00010010",  -- Low byte of instruction 8
    15 => "10011111",  -- High byte of instruction 8
    16 => "00000101",  -- Low byte of instruction 9
    17 => "00000010",  -- High byte of instruction 9
    18 => "00100010",  -- Low byte of instruction 10
    19 => "10011000",  -- High byte of instruction 10
    20 => "00100010",  -- Low byte of instruction 11
    21 => "10011010",  -- High byte of instruction 11
    22 => "00100010",  -- Low byte of instruction 12
    23 => "10011001",  -- High byte of instruction 12
    24 => "00100010",  -- Low byte of instruction 13
    25 => "10011100",  -- High byte of instruction 13
    26 => "00100010",  -- Low byte of instruction 14
    27 => "10011110",  -- High byte of instruction 14
    28 => "00100010",  -- Low byte of instruction 15
    29 => "10011101",  -- High byte of instruction 15
    30 => "00110010",  -- Low byte of instruction 16
    31 => "00000011",  -- High byte of instruction 16
    32 => "01000010",  -- Low byte of instruction 17
    33 => "00000010",  -- High byte of instruction 17
    34 => "01010101",  -- Low byte of instruction 18
    35 => "00010000",  -- High byte of instruction 18
    36 => "01101100",  -- Low byte of instruction 19
    37 => "11111110",  -- High byte of instruction 19
    38 => "01111100",  -- Low byte of instruction 20
    39 => "01101010",  -- High byte of instruction 20
    40 => "10001110",  -- Low byte of instruction 21
    41 => "11001100",  -- High byte of instruction 21
    42 => "10010101",  -- Low byte of instruction 22
    43 => "10110101",  -- High byte of instruction 22
    44 => "10101100",  -- Low byte of instruction 23
    45 => "10001110",  -- High byte of instruction 23
    46 => "11000011",  -- Low byte of instruction 24
    47 => "00001000",  -- High byte of instruction 24
    48 => "11010101",  -- Low byte of instruction 25
    49 => "11000000",  -- High byte of instruction 25
    50 => "11110110",  -- Low byte of instruction 26
    51 => "00111100",  -- High byte of instruction 26
    others => (others => '0') -- Initialize the rest to zero
);

begin
    -- Writing Process (Synchronous)
    mem_write: process(clock, reset)
    begin
        if reset = '1' then
            mem_storage <= (others => (others => '0')); -- Reset memory on reset
        elsif rising_edge(clock) then
            if Mem_W_i = '1' then
                -- Write data into memory at given address
                mem_storage(to_integer(unsigned(M_add_i)))     <= M_inp_i(7 downto 0); -- Low byte
                mem_storage(to_integer(unsigned(M_add_i)) + 1) <= M_inp_i(15 downto 8); -- High byte
            end if;
        end if;
    end process;

    -- Reading Process (Asynchronous)
    M_data_i <= mem_storage(to_integer(unsigned(M_add_i)) + 1) & mem_storage(to_integer(unsigned(M_add_i))); 

end architecture behav;
