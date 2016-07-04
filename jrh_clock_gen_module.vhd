----------------------------------------------------------------------------------
-- Author:        Jørgen Ryther Hoem
--
-- Course:        Digital System Design with VHDL (ET062G)     
--                Mid Sweden University, 2016
-- 
-- Module Name:   jrh_clock_gen_module - Behavioral
-- Project Name:  Range Sensor System
-- Description:   1 MHz and 108 MHz (external module) clock generator
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all; 

entity clock_gen_module is

    port (
        clock_100mhz_in  : in  std_logic;
        clock_108mhz_out : out std_logic := '0';
        clock_1mhz_out   : out std_logic := '0'
    );

end clock_gen_module;

architecture Behavioral of clock_gen_module is
    
begin
    
    -- 108 MHz clock
    CLOCK_108MHZ_MODULE: 
        entity work.clk_wiz_0 
        port map(
            clk_in1  => clock_100mhz_in,
            clk_out1 => clock_108mhz_out
        );
    
    
    gen_1mhz_clock: 
    process(clock_100mhz_in)
    
        variable clk_counter : integer := 1;
        variable clk_pulse   : std_logic := '0';
    
    begin
    
        if clock_100mhz_in'event and clock_100mhz_in = '1' then    
        
            if clk_counter >= 50 then
                clk_counter    := 1;
                clk_pulse      := not(clk_pulse);
                clock_1mhz_out <= clk_pulse;
            else
                clk_counter := clk_counter + 1;
            end if;

        end if;

    end process;

end Behavioral;
