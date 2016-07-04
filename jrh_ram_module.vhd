----------------------------------------------------------------------------------
-- Author:        Jørgen Ryther Hoem
--
-- Course:        Digital System Design with VHDL (ET062G)     
--                Mid Sweden University, 2016
-- 
-- Module Name:   jrh_ram_module - Behavioral
-- Project Name:  Range Sensor System
-- Description:   RAM module, implemented as block RAM
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ram_module is

    generic(
        ram_length  : integer;-- := 512;
        ram_depth   : integer;-- := 8;
        ram_addrlen : integer-- := 9
    );
    port(
        clock_in    : in  std_logic;
        read_en     : in  std_logic;
        write_en    : in  std_logic;
        read_addr   : in  std_logic_vector(ram_addrlen-1 downto 0) := (others => '0');
        write_addr  : in  std_logic_vector(ram_addrlen-1 downto 0) := (others => '0');
        write_data  : in  std_logic_vector(ram_depth-1 downto 0) := (others => '0');
        read_data   : out std_logic_vector(ram_depth-1 downto 0) := (others => '0')
    );
    
end ram_module;

architecture Behavioral of ram_module is

    -- define the RAM data type
    subtype ram_data is std_logic_vector(ram_depth-1 downto 0);
    type ram_type is array(0 to ram_length-1) of ram_data;
    
    -- create RAM array
    signal ram : ram_type := (others => (others => '0'));

    -- define how the RAM is implemented, BRAM in this case
    attribute ram_style: string;
    attribute ram_style of ram : signal is "block";

begin


    process(clock_in)
    begin
        
        if clock_in'event and clock_in = '1' then
    
            if write_en = '1' then            
                ram(to_integer(unsigned(write_addr))) <= write_data;
            end if;

            if read_en = '1' then
                read_data <= ram(to_integer(unsigned(read_addr)));
            end if;
                        
        end if;
    
    end process;
    

end Behavioral;
