LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY register_memory IS

    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        write_en : IN STD_LOGIC;
        write_addr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        write_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        read_addr0 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        read_addr1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        read_data0 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        read_data1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY register_memory;

ARCHITECTURE struct OF register_memory IS
    TYPE ram_type IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL ram : ram_type := (OTHERS => (OTHERS => '0'));
BEGIN
    decoder : PROCESS (write_addr, write_en, clk, reset)
        VARIABLE addr_int : INTEGER RANGE 0 TO 7;
    BEGIN
        IF write_en = '1' THEN
            addr_int := to_integer(unsigned(write_addr));
            IF rising_edge(clk) THEN
                ram(addr_int) <= write_data;
            END IF;
        END IF;
    END PROCESS decoder;
    read0 : PROCESS (read_addr0, write_addr, write_en, write_data)
        VARIABLE addr_int : INTEGER RANGE 0 TO 7;
    BEGIN
        addr_int := to_integer(unsigned(read_addr0));
        IF write_en = '1' AND read_addr0 = write_addr THEN
            read_data0 <= write_data;
        ELSE
            read_data0 <= ram(addr_int);
        END IF;
    END PROCESS read0;
    read1 : PROCESS (read_addr1, write_addr, write_en, write_data)
        VARIABLE addr_int : INTEGER RANGE 0 TO 7;
    BEGIN
        addr_int := to_integer(unsigned(read_addr1));
        IF write_en = '1' AND read_addr1 = write_addr THEN
            read_data1 <= write_data;
        ELSE
            read_data1 <= ram(addr_int);
        END IF;
    END PROCESS read1;
END ARCHITECTURE struct;