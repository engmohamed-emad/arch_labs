library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity INTEGRATION is
    Port ( A : in STD_LOGIC_VECTOR (7 downto 0);
           B : in STD_LOGIC_VECTOR (7 downto 0);
           S : in STD_LOGIC_VECTOR (3 downto 0);
           Cin : in STD_LOGIC;
           F : out STD_LOGIC_VECTOR (7 downto 0);
           Cout : out STD_LOGIC);
end INTEGRATION;

architecture Structural of ALU is
    
    component partB is
        Port ( A : in STD_LOGIC_VECTOR (7 downto 0);
               B : in STD_LOGIC_VECTOR (7 downto 0);
               S0 : in STD_LOGIC;
               S1 : in STD_LOGIC;
               F : out STD_LOGIC_VECTOR (7 downto 0));
    end component;
    
    component partC is
        Port ( A : in STD_LOGIC_VECTOR (7 downto 0);
               Cin : in STD_LOGIC;
               S0 : in STD_LOGIC;
               S1 : in STD_LOGIC;
               F : out STD_LOGIC_VECTOR (7 downto 0);
               Cout : out STD_LOGIC);
    end component;
    
    component partD is
        Port ( A : in STD_LOGIC_VECTOR (7 downto 0);
               Cin : in STD_LOGIC;
               S0 : in STD_LOGIC;
               S1 : in STD_LOGIC;
               F : out STD_LOGIC_VECTOR (7 downto 0);
               Cout : out STD_LOGIC);
    end component;
    
    signal F_B, F_C, F_D : STD_LOGIC_VECTOR (7 downto 0);
    signal Cout_C, Cout_D : STD_LOGIC;
    
begin
    
    -- Instantiate Part B (S3='0', S2='1')
    U1: partB port map(
        A => A,
        B => B,
        S0 => S(0),
        S1 => S(1),
        F => F_B
    );
    
    -- Instantiate Part C (S3='1', S2='0')
    U2: partC port map(
        A => A,
        Cin => Cin,
        S0 => S(0),
        S1 => S(1),
        F => F_C,
        Cout => Cout_C
    );
    
    -- Instantiate Part D (S3='1', S2='1')
    U3: partD port map(
        A => A,
        Cin => Cin,
        S0 => S(0),
        S1 => S(1),
        F => F_D,
        Cout => Cout_D
    );
    
    -- Output selection based on S(3) and S(2)
    process(S, F_B, F_C, F_D, Cout_C, Cout_D)
    begin
        case S(3 downto 2) is
            when "01" =>   -- Part B operations
                F <= F_B;
                Cout <= '0';
            when "10" =>   -- Part C operations
                F <= F_C;
                Cout <= Cout_C;
            when "11" =>   -- Part D operations
                F <= F_D;
                Cout <= Cout_D;
            when others => -- Part A or undefined
                F <= (others => '0');
                Cout <= '0';
        end case;
    end process;
    
end Structural;
