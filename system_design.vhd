-- filepath: d:\assignments\vhdl\arch_labs\lab4\system_design.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_elevator is
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        reset_btns  : in  std_logic;
        buttonsIn   : in  std_logic_vector(9 downto 0);
        floor       : out unsigned(3 downto 0);
        door_open   : out std_logic;
        moving_up   : out std_logic;
        moving_down : out std_logic
    );
end entity;

architecture rtl of top_elevator is

    signal req         : std_logic_vector(9 downto 0);
    signal enaElevator : std_logic;
    COMPONENT abutton_detectordder IS
        PORT (
            clk : IN STD_LOGIC;
            reset_btns : IN STD_LOGIC;
            buttonsIn : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            enaElevator : IN STD_LOGIC;
            buttonsOut : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
        );
    END COMPONENT;
begin

    btn_det : button_detector
        port map (
            clk         => clk,
            reset_btns  => reset_btns,
            buttonsIn   => buttonsIn,
            enaElevator => enaElevator,
            buttonsOut  => req
        );

    elev_ctrl : elevator
        generic map (
            N_FLOORS => 10
        )
        port map (
            clk         => clk,
            reset       => reset,
            req         => req,
            floor       => floor,
            door_open   => door_open,
            moving_up   => moving_up,
            moving_down => moving_down
        );

end architecture;