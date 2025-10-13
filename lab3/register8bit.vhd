library ieee;
use ieee.std_logic_1164.all;

entity reg8 is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;  
        en    : in  std_logic;
        d     : in  std_logic_vector(7 downto 0);
        q     : out std_logic_vector(7 downto 0)
    );
end entity reg8;

architecture struct of reg8 is
    component my_DFF is
        port (
            d   : in  std_logic;
            clk : in  std_logic;
            rst : in  std_logic;  
            q   : out std_logic
        );
    end component;

    signal d_in  : std_logic_vector(7 downto 0);
    signal q_int : std_logic_vector(7 downto 0);  
begin
    gen_bits: for i in 0 to 7 generate
        d_in(i) <= d(i) when en = '1' else q_int(i);  
        dff_i: my_DFF port map (  
            d   => d_in(i),
            clk => clk,
            rst => reset,  
            q   => q_int(i)
        );
    end generate gen_bits;

    q <= q_int;  
end architecture struct;