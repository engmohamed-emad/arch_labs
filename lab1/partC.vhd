LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY partC IS
    GENERIC (n : INTEGER := 8);
    PORT (
        A : IN STD_LOGIC_VECTOR (n - 1 DOWNTO 0);
        Cin : IN STD_LOGIC;
        S0 : IN STD_LOGIC;
        S1 : IN STD_LOGIC;
        F : OUT STD_LOGIC_VECTOR (n - 1 DOWNTO 0);
        Cout : OUT STD_LOGIC);
END partC;

ARCHITECTURE Behavioral OF partC IS
BEGIN
    PROCESS (A, Cin, S0, S1)
    BEGIN
        Cout <= '0'; -- Default value

        IF S1 = '0' THEN
            IF S0 = '0' THEN -- S=1000: Logic shift right A
                F <= '0' & A(n - 1 DOWNTO 1);
                Cout <= A(0);
            ELSE -- S=1001: Rotate right A
                F <= A(0) & A(n - 1 DOWNTO 1);
                Cout <= A(0);
            END IF;
        ELSE
            IF S0 = '0' THEN -- S=1010: Rotate right A with Carry
                F <= Cin & A(n - 1 DOWNTO 1);
                Cout <= A(0);
            ELSE -- S=1011: Arithmetic shift right A
                F <= A(n - 1) & A(n - 1 DOWNTO 1);
                Cout <= A(0);
            END IF;
        END IF;
    END PROCESS;
END Behavioral;