
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY partB IS
    GENERIC (n : INTEGER := 8);
    PORT (
        A : IN STD_LOGIC_VECTOR (n - 1 DOWNTO 0);
        B : IN STD_LOGIC_VECTOR (n - 1 DOWNTO 0);
        S0 : IN STD_LOGIC;
        S1 : IN STD_LOGIC;
        F : OUT STD_LOGIC_VECTOR (n - 1 DOWNTO 0));
END partB;

ARCHITECTURE Behavioral OF partB IS
BEGIN
    PROCESS (A, B, S0, S1)
    BEGIN
        IF S1 = '0' THEN
            IF S0 = '0' THEN
                F <= A AND B; -- S=0100: F = A and B
            ELSE
                F <= A OR B; -- S=0101: F = A or B
            END IF;
        ELSE
            IF S0 = '0' THEN
                F <= A NOR B; -- S=0110: F = A nor B
            ELSE
                F <= NOT A; -- S=0111: F = not A
            END IF;
        END IF;
    END PROCESS;
END Behavioral;