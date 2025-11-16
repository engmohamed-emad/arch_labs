LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY seven_segment_decoder IS
    PORT (
        floor_number : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        segments : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END ENTITY seven_segment_decoder;

ARCHITECTURE behavioral OF seven_segment_decoder IS
BEGIN
    PROCESS (floor_number)
        VARIABLE floor_int : INTEGER;
    BEGIN
        floor_int := to_integer(unsigned(floor_number));

        CASE floor_int IS
            WHEN 0 => segments <= "0000001";
            WHEN 1 => segments <= "1001111";
            WHEN 2 => segments <= "0010010";
            WHEN 3 => segments <= "0000110";
            WHEN 4 => segments <= "1001100";
            WHEN 5 => segments <= "0100100";
            WHEN 6 => segments <= "0100000";
            WHEN 7 => segments <= "0001111";
            WHEN 8 => segments <= "0000000";
            WHEN 9 => segments <= "0000100";
            WHEN OTHERS => segments <= "1111111"; -- All off
        END CASE;
    END PROCESS;
END ARCHITECTURE behavioral;