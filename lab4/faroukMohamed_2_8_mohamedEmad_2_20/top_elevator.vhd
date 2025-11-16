LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY top_elevator IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        reset_btns : IN STD_LOGIC;
        buttonsIn : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        floor : OUT unsigned(3 DOWNTO 0);
        door_open : OUT STD_LOGIC;
        moving_up : OUT STD_LOGIC;
        moving_down : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE rtl OF top_elevator IS

    SIGNAL req : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL enaElevator : STD_LOGIC;
    COMPONENT button_detector IS
        PORT (
            clk : IN STD_LOGIC;
            reset_btns : IN STD_LOGIC;
            buttonsIn : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            enaElevator : OUT STD_LOGIC;
            buttonsOut : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT elevator IS
        PORT (
            clk : IN STD_LOGIC;
            reset: IN STD_LOGIC;
            req : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            floor : OUT unsigned(3 DOWNTO 0);
            door_open : OUT STD_LOGIC;
            moving_up : OUT STD_LOGIC;
            moving_down : OUT STD_LOGIC 
        );
    END COMPONENT;
BEGIN

    btn_det : button_detector
    PORT MAP(
        clk => clk,
        reset_btns => reset_btns,
        buttonsIn => buttonsIn,
        enaElevator => enaElevator,
        buttonsOut => req
    );

    elev_ctrl : elevator
    PORT MAP(
        clk => clk,
        reset => reset,
        req => req,
        floor => floor,
        door_open => door_open,
        moving_up => moving_up,
        moving_down => moving_down
    );

END ARCHITECTURE;