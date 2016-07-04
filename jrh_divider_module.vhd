----------------------------------------------------------------------------------
-- Author:        Jørgen Ryther Hoem
--
-- Course:        Digital System Design with VHDL (ET062G)     
--                Mid Sweden University, 2016
-- 
-- Module Name:   jrh_divider_module - Behavioral
-- Project Name:  Range Sensor System
-- Description:   58 Divider, part of the SRF05 core
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;


entity divider_module is
        
   port(
        clock_in : in  std_logic := '0';
        data_in  : in  std_logic_vector(15 downto 0) := (others => '0');
        data_out : out std_logic_vector(15 downto 0) := (others => '0')
   );
        
end divider_module;


architecture Behavioral of divider_module is

begin

    process(clock_in, data_in)
    begin

        if clock_in'event and clock_in = '1' then    

            if to_integer(unsigned(data_in)) < 58 then
                data_out <= (others => '0');
            else
                -- since regular division should be avoided, (2^16)/58 = 1129,9 => 1130.
                data_out <= std_logic_vector(resize(resize(unsigned(data_in) * 1130, 32) srl 16, 16));  
            end if;
            
        end if;

    end process;

end Behavioral;
