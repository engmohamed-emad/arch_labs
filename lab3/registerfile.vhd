library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        write_en    : in  std_logic;
        write_addr  : in  std_logic_vector(2 downto 0);
        write_data  : in  std_logic_vector(7 downto 0);
        read_addr0  : in  std_logic_vector(2 downto 0);
        read_addr1  : in  std_logic_vector(2 downto 0);
        read_data0  : out std_logic_vector(7 downto 0);
        read_data1  : out std_logic_vector(7 downto 0)
    );
end entity register_file;

architecture struct of register_file is
    component reg8 is
        port (
            clk   : in  std_logic;
            reset : in  std_logic;
            en    : in  std_logic;
            d     : in  std_logic_vector(7 downto 0);
            q     : out std_logic_vector(7 downto 0)
        );
    end component;

    type reg_array_t is array (0 to 7) of std_logic_vector(7 downto 0);
    signal reg_q : reg_array_t;
    signal reg_en : std_logic_vector(0 to 7);
begin
    decoder: process (write_addr, write_en)
        variable addr_int : integer range 0 to 7;
    begin
        reg_en <= (others => '0');
        if write_en = '1' then
            addr_int := to_integer(unsigned(write_addr));
            reg_en(addr_int) <= '1';
        end if;
    end process decoder;

    -- Instantiate 8 registers
    gen_regs: for i in 0 to 7 generate
        reg_i: reg8 port map (
            clk   => clk,
            reset => reset,
            en    => reg_en(i),
            d     => write_data,
            q     => reg_q(i)
        );
    end generate gen_regs;

    
    read0: process (read_addr0, write_addr, write_en, write_data, reg_q)
        variable addr_int : integer range 0 to 7;
    begin
        addr_int := to_integer(unsigned(read_addr0));
        if write_en = '1' and read_addr0 = write_addr then
            read_data0 <= write_data;
        else
            read_data0 <= reg_q(addr_int);
        end if;
    end process read0;

    
    read1: process (read_addr1, write_addr, write_en, write_data, reg_q)
        variable addr_int : integer range 0 to 7;
    begin
        addr_int := to_integer(unsigned(read_addr1));
        if write_en = '1' and read_addr1 = write_addr then
            read_data1 <= write_data;
        else
            read_data1 <= reg_q(addr_int);
        end if;
    end process read1;
end architecture struct;
