library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package elevator_pkg is
  constant DEFAULT_FLOORS : integer := 10;
  subtype floor_index is integer range 0 to DEFAULT_FLOORS-1;
end package elevator_pkg;
