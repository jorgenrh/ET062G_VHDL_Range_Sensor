----------------------------------------------------------------------------------
-- Author:        Jørgen Ryther Hoem
--
-- Course:        Digital System Design with VHDL (ET062G)     
--                Mid Sweden University, 2016
-- 
-- Module Name:   testbench_led7seg_core - Testbench
-- Project Name:  Range Sensor System
-- Description:   Testbench for LED7Seg core
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench_led7seg_core is
end testbench_led7seg_core;

architecture Testbench of testbench_led7seg_core is

    signal clock_slow    : std_logic := '0';
    signal distance_in   : std_logic_vector(15 downto 0) := (others => '0');
    signal lcd_segment   : std_logic_vector(6 downto 0) := (others => '0');
    signal lcd_position  : std_logic_vector(3 downto 0) := (others => '1');
    signal led_out       : std_logic_vector(15 downto 0) := (others => '0');
    
    constant clock_pulse : time := 1 us; -- 1 MHz clock

begin

    LED_7SEGMENT: 
        entity work.led7seg_core 
        port map(
            clock_in     => clock_slow,
            binary_in    => distance_in,
            segment_out  => lcd_segment,
            position_out => lcd_position,
            led_out      => led_out
        );


    -- Simulate 1 MHz clock pulse
    clock_sim: process
    begin
        clock_slow <= '1';
        wait for clock_pulse/2;
        clock_slow <= '0';
        wait for clock_pulse/2;
    end process;            

    -- send dummy data
    dummy_data: process
    begin
        distance_in <= std_logic_vector(to_unsigned(9876, 16));
        wait;
    end process;            


end Testbench;
