----------------------------------------------------------------------------------
-- Author:        Jørgen Ryther Hoem
--
-- Course:        Digital System Design with VHDL (ET062G)     
--                Mid Sweden University, 2016
-- 
-- Module Name:   testbench_clock_gen - Testbench
-- Project Name:  Range Sensor System
-- Description:   Testbench for the Clock Generator
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity testbench_clock_gen is
end testbench_clock_gen;

architecture Testbench of testbench_clock_gen is
    
    -- clock signals
    signal clock_in      : std_logic := '0';
    signal clock_vga     : std_logic := '0';
    signal clock_slow    : std_logic := '0';

    constant clock_pulse : time := 10 ns;
    
begin

    CLOCK_GENERATOR: 
        entity work.clock_gen_module 
        port map(
            clock_100mhz_in  => clock_in,
            clock_108mhz_out => clock_vga,
            clock_1mhz_out   => clock_slow
        );

    -- Simulate 100 MHz clock pulse
    clock_sim: process
    begin
        clock_in <= '1';
        wait for clock_pulse/2;
        clock_in <= '0';
        wait for clock_pulse/2;
    end process;            

end Testbench;
