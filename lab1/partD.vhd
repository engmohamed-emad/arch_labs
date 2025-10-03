
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity partD is
    Port ( A : in STD_LOGIC_VECTOR (7 downto 0);
           Cin : in STD_LOGIC;
           S0 : in STD_LOGIC;
           S1 : in STD_LOGIC;
           F : out STD_LOGIC_VECTOR (7 downto 0);
           Cout : out STD_LOGIC);
end partD;

architecture Behavioral of partD is
begin
    process(A, Cin, S0, S1)
    begin
        Cout <= '0';  -- Default value
        
        if S1 = '0' then
            if S0 = '0' then          -- S=1100: Logic shift left A
                F <= A(6 downto 0) & '0';
                Cout <= A(7);
            else                      -- S=1101: Rotate left A 
                F <= A(6 downto 0) & A(7);
                Cout <= A(7);
                
            end if;
        else
            if S0 = '0' then          -- S=1110: Rotate left A with a carry
                F <= A(6 downto 0) & Cin;
                Cout <= A(7);
            else                      -- S=1111: F = 00000000
                F <= (others => '0');
                Cout <= '0';
            end if;
        end if;
    end process;
end Behavioral;