
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY partD IS
    GENERIC (n : INTEGER := 8);
    PORT (
        A : IN STD_LOGIC_VECTOR (n - 1 DOWNTO 0);
        Cin : IN STD_LOGIC;
        S0 : IN STD_LOGIC;
        S1 : IN STD_LOGIC;
        F : OUT STD_LOGIC_VECTOR (n - 1 DOWNTO 0);
        Cout : OUT STD_LOGIC);
END partD;

ARCHITECTURE Behavioral OF partD IS
BEGIN
    PROCESS (A, Cin, S0, S1)
    BEGIN
        Cout <= '0'; -- Default value

        IF S1 = '0' THEN
            IF S0 = '0' THEN -- S=1100: Logic shift left A
                F <= A(n - 2 DOWNTO 0) & '0';
                Cout <= A(n - 1);
            ELSE -- S=1101: Rotate left A 
                F <= A(n - 2 DOWNTO 0) & A(n - 1);
                Cout <= A(n - 1);

            END IF;
        ELSE
            IF S0 = '0' THEN -- S=1110: Rotate left A with a carry
                F <= A(n - 2 DOWNTO 0) & Cin;
                Cout <= A(n - 1);
            ELSE -- S=1111: F = 00000000
                F <= (OTHERS => '0');
                Cout <= '0';
            END IF;
        END IF;
    END PROCESS;
END Behavioral;