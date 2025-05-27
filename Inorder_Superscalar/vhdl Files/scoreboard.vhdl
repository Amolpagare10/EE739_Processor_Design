library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity scoreboard is
    generic (
        REG_COUNT : integer := 8;
        ISSUE_WIDTH : integer := 2
    );
    port (
        clk            : in  STD_LOGIC;
        rst            : in  STD_LOGIC;

        -- Instruction issue interface
        issue_valid    : in  STD_LOGIC_VECTOR(ISSUE_WIDTH-1 downto 0);
        src1_reg       : in  STD_LOGIC_VECTOR((ISSUE_WIDTH*3)-1 downto 0);
        src2_reg       : in  STD_LOGIC_VECTOR((ISSUE_WIDTH*3)-1 downto 0);
        dest_reg       : in  STD_LOGIC_VECTOR((ISSUE_WIDTH*3)-1 downto 0);

        can_issue      : out STD_LOGIC_VECTOR(ISSUE_WIDTH-1 downto 0);

        -- Instruction commit interface
        commit_valid   : in  STD_LOGIC_VECTOR(ISSUE_WIDTH-1 downto 0);
        commit_reg     : in  STD_LOGIC_VECTOR((ISSUE_WIDTH*3)-1 downto 0)
    );
end entity scoreboard;

architecture Behavioral of scoreboard is
    type busy_array is array (0 to REG_COUNT-1) of STD_LOGIC;
    signal busy : busy_array := (others => '0');
    signal can_issue_int : STD_LOGIC_VECTOR(ISSUE_WIDTH-1 downto 0);
    signal src1_reg_arr : array(0 to ISSUE_WIDTH-1) of STD_LOGIC_VECTOR(2 downto 0);
    signal src2_reg_arr : array(0 to ISSUE_WIDTH-1) of STD_LOGIC_VECTOR(2 downto 0);
    signal dest_reg_arr : array(0 to ISSUE_WIDTH-1) of STD_LOGIC_VECTOR(2 downto 0);

    integer i;
begin

    -- Convert src1_reg, src2_reg, dest_reg from 1D to 2D arrays
    process (src1_reg)
    begin
        for i in 0 to ISSUE_WIDTH-1 loop
            src1_reg_arr(i) <= src1_reg(3*i+2 downto 3*i);
        end loop;
    end process;

    process (src2_reg)
    begin
        for i in 0 to ISSUE_WIDTH-1 loop
            src2_reg_arr(i) <= src2_reg(3*i+2 downto 3*i);
        end loop;
    end process;

    process (dest_reg)
    begin
        for i in 0 to ISSUE_WIDTH-1 loop
            dest_reg_arr(i) <= dest_reg(3*i+2 downto 3*i);
        end loop;
    end process;

    -- Reset logic and commit logic
    process (clk, rst)
    begin
        if rst = '1' then
            for i in 0 to REG_COUNT-1 loop
                busy(i) <= '0';
            end loop;
        elsif rising_edge(clk) then
            -- On commit, clear busy bit
            for i in 0 to ISSUE_WIDTH-1 loop
                if commit_valid(i) = '1' then
                    busy(to_integer(unsigned(commit_reg(3*i+2 downto 3*i)))) <= '0';
                end if;
            end loop;

            -- On issue, set destination register busy
            for i in 0 to ISSUE_WIDTH-1 loop
                if issue_valid(i) = '1' and can_issue_int(i) = '1' then
                    busy(to_integer(unsigned(dest_reg_arr(i)))) <= '1';
                end if;
            end loop;
        end if;
    end process;

    -- Combinational logic to check for RAW hazards
    process (issue_valid, busy)
    begin
        for i in 0 to ISSUE_WIDTH-1 loop
            if issue_valid(i) = '1' then
                -- An instruction can issue only if both source registers are not busy
                if busy(to_integer(unsigned(src1_reg_arr(i)))) = '0' and
                   busy(to_integer(unsigned(src2_reg_arr(i)))) = '0' then
                    can_issue_int(i) <= '1';
                else
                    can_issue_int(i) <= '0';
                end if;
            else
                can_issue_int(i) <= '0';
            end if;
        end loop;
    end process;

    -- Output the can_issue signals
    can_issue <= can_issue_int;

end architecture Behavioral;
