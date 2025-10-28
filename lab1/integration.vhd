LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY alu IS
    GENERIC (n : INTEGER := 8);
    PORT (
        A : IN STD_LOGIC_VECTOR (n - 1 DOWNTO 0);
        B : IN STD_LOGIC_VECTOR (n - 1 DOWNTO 0);
        S : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        Cin : IN STD_LOGIC;
        F : OUT STD_LOGIC_VECTOR (n - 1 DOWNTO 0);
        Cout : OUT STD_LOGIC);
END alu;

ARCHITECTURE Structural OF alu   IS

    COMPONENT partA IS
        GENERIC (n : INTEGER := 8);
        PORT (
            a : IN STD_LOGIC_VECTOR (n - 1 DOWNTO 0);
            b : IN STD_LOGIC_VECTOR (n - 1 DOWNTO 0);
            sel : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            cin : IN STD_LOGIC;
            f : OUT STD_LOGIC_VECTOR (n - 1 DOWNTO 0);
            cout : OUT STD_LOGIC);
    END COMPONENT;
    COMPONENT partB IS
        GENERIC (n : INTEGER := 8);
        PORT (
            A : IN STD_LOGIC_VECTOR (n - 1 DOWNTO 0);
            B : IN STD_LOGIC_VECTOR (n - 1 DOWNTO 0);
            S0 : IN STD_LOGIC;
            S1 : IN STD_LOGIC;
            F : OUT STD_LOGIC_VECTOR (n - 1 DOWNTO 0));
    END COMPONENT;
    COMPONENT partC IS
        GENERIC (n : INTEGER := 8);

        PORT (
            A : IN STD_LOGIC_VECTOR (n - 1 DOWNTO 0);
            Cin : IN STD_LOGIC;
            S0 : IN STD_LOGIC;
            S1 : IN STD_LOGIC;
            F : OUT STD_LOGIC_VECTOR (n - 1 DOWNTO 0);
            Cout : OUT STD_LOGIC);
    END COMPONENT;

    COMPONENT partD IS
        GENERIC (n : INTEGER := 8);
        PORT (
            A : IN STD_LOGIC_VECTOR (n - 1 DOWNTO 0);
            Cin : IN STD_LOGIC;
            S0 : IN STD_LOGIC;
            S1 : IN STD_LOGIC;
            F : OUT STD_LOGIC_VECTOR (n - 1 DOWNTO 0);
            Cout : OUT STD_LOGIC);
    END COMPONENT;

    SIGNAL F_B, F_C, F_D, F_A : STD_LOGIC_VECTOR (n - 1 DOWNTO 0);
    SIGNAL Cout_C, Cout_D, cout_a : STD_LOGIC;

BEGIN

    u0 : partA
    GENERIC MAP(n => n)
    PORT MAP(
        a => A,
        b => B,
        sel => S,
        cin => Cin, -- this is the line
        f => F_A,
        cout => cout_a
    );
    -- Instantiate Part B (S3='0', S2='1')
    U1 : partB
    GENERIC MAP(n => n)
    PORT MAP(
        A => A,
        B => B,
        S0 => S(0),
        S1 => S(1),
        F => F_B
    );

    -- Instantiate Part C (S3='1', S2='0')
    U2 : partC
    GENERIC MAP(n => n)
    PORT MAP(
        A => A,
        Cin => Cin,
        S0 => S(0),
        S1 => S(1),
        F => F_C,
        Cout => Cout_C
    );

    -- Instantiate Part D (S3='1', S2='1')
    U3 : partD
    GENERIC MAP(n => n)
    PORT MAP(
        A => A,
        Cin => Cin,
        S0 => S(0),
        S1 => S(1),
        F => F_D,
        Cout => Cout_D
    );

    -- Output selection based on S(3) and S(2)
    PROCESS (S, F_B, F_C, F_D, F_A, Cout_C, Cout_D, cout_a)
    BEGIN
        CASE S(3 DOWNTO 2) IS
            WHEN "01" => -- Part B operations
                F <= F_B;
                Cout <= '0';
            WHEN "10" => -- Part C operations
                F <= F_C;
                Cout <= Cout_C;
            WHEN "11" => -- Part D operations
                F <= F_D;
                Cout <= Cout_D;
            WHEN OTHERS => -- Part A or undefined
                F <= F_A;
                Cout <= cout_a;
        END CASE;
    END PROCESS;

END Structural;