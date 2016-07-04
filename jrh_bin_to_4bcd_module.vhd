----------------------------------------------------------------------------------
-- Author:        Jørgen Ryther Hoem
--
-- Course:        Digital System Design with VHDL (ET062G)     
--                Mid Sweden University, 2016
-- 
-- Module Name:   jrh_bin_to_4bcd_module - Behavioral
-- Project Name:  Range Sensor System
-- Description:   16-bit binary to 4 BCD converter, part of the LED7Seg core
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity bin_to_4bcd_module is
    
    port (
        binary_in : in std_logic_vector(15 downto 0);
        bcd3      : out std_logic_vector(3 downto 0);
        bcd2      : out std_logic_vector(3 downto 0);
        bcd1      : out std_logic_vector(3 downto 0);
        bcd0      : out std_logic_vector(3 downto 0)
    );
    
end bin_to_4bcd_module;

architecture Behavioral of bin_to_4bcd_module is
    
begin
    
    process (binary_in)
            
        -- split the binary data in into 4 segments
        variable shift : unsigned(31 downto 0);    
        alias binary is shift(15 downto 0);
        alias bcd0a is shift(19 downto 16);
        alias bcd1a is shift(23 downto 20);
        alias bcd2a is shift(27 downto 24);
        alias bcd3a is shift(31 downto 28);
        
    begin
        
        if unsigned(binary_in) > 9999 then
            binary := to_unsigned(9999, 16);
        else
            binary := unsigned(binary_in);
        end if;
            
        bcd0a := X"0";
        bcd1a := X"0";
        bcd2a := X"0";
        bcd3a := X"0";
        
        -- adjust each segment until it is correct
        for i in 1 to binary'Length loop
            if bcd0a >= 5 then
                bcd0a := bcd0a + 3;
            end if;
               
            if bcd1a >= 5 then
                bcd1a := bcd1a + 3;
            end if;
               
            if bcd2a >= 5 then
                bcd2a := bcd2a + 3;
            end if;
    
            if bcd3a >= 5 then
                bcd3a := bcd3a + 3;
            end if;
    
            shift := shift_left(shift, 1);
        end loop;
            
        bcd3 <= std_logic_vector(bcd3a);
        bcd2 <= std_logic_vector(bcd2a);
        bcd1 <= std_logic_vector(bcd1a);
        bcd0 <= std_logic_vector(bcd0a);
        
    end process;

end Behavioral;
