----------------------------------------------------------------------------------
-- Author:        Jørgen Ryther Hoem
--
-- Course:        Digital System Design with VHDL (ET062G)     
--                Mid Sweden University, 2016
-- 
-- Module Name:   jrh_pulse_gen_module - Behavioral
-- Project Name:  Range Sensor System
-- Description:   Trigger pulse generator, part of the SRF05 core 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity pulse_gen_module is

    port (
        clock_in  : in  std_logic;
        enable_in : in  std_logic;
        pwidth_in : in  std_logic_vector(3 downto 0) := (others => '0');
        pulse_out : out std_logic := '0'
    );

end pulse_gen_module;

architecture Behavioral of pulse_gen_module is

begin
    
    process(clock_in, enable_in, pwidth_in)
    
        constant pls_length  : integer := 100000; -- 10 Hz period
        variable pls_width   : integer := 10;
        variable pls_counter : integer := 1;
        variable clk_pulse   : std_logic := '0';
            
    begin

        if clock_in'event and clock_in = '1' and enable_in = '1' then  
        
            -- change the pulse width between 10 and 20 us in runtime
            -- (not used in the project since the pulse width is static)
            if to_integer(unsigned(pwidth_in)) /= pls_width then
                if to_integer(unsigned(pwidth_in)) > 10 then 
                    pls_width := 10;
                else
                    pls_width := to_integer(unsigned(pwidth_in)) + 10; 
                end if;
            end if;        
                
            -- control the trigger pulse width
            if pls_counter < pls_width then
                pulse_out <= '1';
            elsif pls_counter > pls_width then
                pulse_out <= '0';
            end if;
            
            -- control the period
            if pls_counter >= pls_length then
                pls_counter := 1;
            else
                pls_counter := pls_counter + 1;
            end if;
        
        end if;    
    
    end process;

end Behavioral;
