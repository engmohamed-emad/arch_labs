-- filepath: d:\assignments\vhdl\arch_labs\lab4\button_detector.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity button_detector is
    port (
        clk         : in  std_logic;
        reset_btns  : in  std_logic;
        buttonsIn   : in  std_logic_vector(9 downto 0);
        enaElevator : out std_logic;
        buttonsOut  : out std_logic_vector(9 downto 0)
    );
end entity;

architecture behave of button_detector is
begin
    process(clk, reset_btns)
    begin
        if reset_btns = '1' then
            buttonsOut <= (others => '0');
            enaElevator <= '0';
        elsif rising_edge(clk) then
            buttonsOut <= buttonsIn;
            if buttonsIn /= "0000000000" then
                enaElevator <= '1';
            else
                enaElevator <= '0';
            end if;
        end if;
    end process;
end architecture;