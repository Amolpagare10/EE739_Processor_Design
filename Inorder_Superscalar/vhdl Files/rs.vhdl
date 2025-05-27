library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reservation_station is
    generic (
        ALU_UNITS : integer := 2;
        LS_UNITS  : integer := 2;
        FPT_UNITS : integer := 0
    );
    port (
        clk              : in  STD_LOGIC;
        rst              : in  STD_LOGIC;
        wr_en            : in  STD_LOGIC;
        rd_en            : in  STD_LOGIC;
        input_entry      : in  STD_LOGIC_VECTOR(43 downto 0);
        full             : out STD_LOGIC;
        empty            : out STD_LOGIC;
        instructions_out_alu : out STD_LOGIC_VECTOR((36 * ALU_UNITS) - 1 downto 0);
        instructions_out_ls  : out STD_LOGIC_VECTOR((36 * LS_UNITS) - 1 downto 0)
        -- instructions_out_fpt : out STD_LOGIC_VECTOR((36 * FPT_UNITS) - 1 downto 0)
    );
end reservation_station;

architecture Behavioral of reservation_station is

    constant RS_SIZE : integer := 64;
    type rs_array is array (0 to RS_SIZE-1) of STD_LOGIC_VECTOR(43 downto 0);
    signal rs : rs_array := (others => (others => '0'));

    signal wr_ptr : integer range 0 to RS_SIZE-1 := 0;
    signal rd_ptr : integer range 0 to RS_SIZE-1 := 0;

    signal alu_op : integer := 0;
    signal ls_op  : integer := 0;
    signal fpt_op : integer := -1;

begin

    -- Write logic (Asynchronous-like inside clocked process)
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                for i in 0 to RS_SIZE-1 loop
                    rs(i) <= (others => '0');
                end loop;
                wr_ptr <= 0;
                rd_ptr <= 0;
            else
                if (wr_en = '1' and full = '0') then
                    rs(wr_ptr) <= input_entry;
                    wr_ptr <= (wr_ptr + 1) mod RS_SIZE;
                end if;
            end if;
        end if;
    end process;

    -- Read and dispatch logic
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                alu_op <= 0;
                ls_op  <= 0;
                fpt_op <= -1;

                if (rd_en = '1' and empty = '0') then
                    variable temp_rd_ptr : integer := rd_ptr;
                    variable opcode      : STD_LOGIC_VECTOR(3 downto 0);

                    while rs(temp_rd_ptr)(40) = '1' and
                          alu_op < ALU_UNITS and
                          ls_op < LS_UNITS loop

                        opcode := rs(temp_rd_ptr)(4 downto 1);

                        case opcode is
                            -- ALU opcodes
                            when "0000" | "0001" | "0010" | "1100" | "1111" =>
                                instructions_out_alu((36*(alu_op+1))-1 downto 36*alu_op) <= 
                                    rs(temp_rd_ptr)(4 downto 1) & rs(temp_rd_ptr)(21 downto 5) & rs(temp_rd_ptr)(38 downto 23);
                                alu_op <= alu_op + 1;

                            -- LS opcodes
                            when "0011" | "0100" | "0101" =>
                                instructions_out_ls((36*(ls_op+1))-1 downto 36*ls_op) <= 
                                    rs(temp_rd_ptr)(4 downto 1) & rs(temp_rd_ptr)(21 downto 5) & rs(temp_rd_ptr)(38 downto 23);
                                ls_op <= ls_op + 1;

                            when others =>
                                null;
                        end case;

                        temp_rd_ptr := (temp_rd_ptr + 1) mod RS_SIZE;
                    end loop;

                    rd_ptr <= temp_rd_ptr;
                end if;

                -- Reset counters after dispatch
                alu_op <= 0;
                ls_op  <= 0;
                fpt_op <= -1;
            end if;
        end if;
    end process;

    -- Full and Empty status logic
    full  <= '1' when ((wr_ptr + 1) mod RS_SIZE) = rd_ptr else '0';
    empty <= '1' when wr_ptr = rd_ptr else '0';

end Behavioral;
