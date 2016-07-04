----------------------------------------------------------------------------------
-- Author:        Jørgen Ryther Hoem
--
-- Course:        Digital System Design with VHDL (ET062G)     
--                Mid Sweden University, 2016
-- 
-- Module Name:   testbench_srf05_core - Testbench
-- Project Name:  Range Sensor System
-- Description:   Testbench for the SRF05 core
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all; 


entity testbench_srf05_core is
end testbench_srf05_core;


architecture Testbench of testbench_srf05_core is

    constant clock_pulse : time := 1 us; -- 1 MHz clock

    signal clock_in       : std_logic := '0';
    signal enable_in      : std_logic := '1';
    signal echo_pulse_in  : std_logic := '0';
    signal trig_pulse_out : std_logic := '0';
    signal distance_out   : std_logic_vector(15 downto 0) := (others => '0');

begin
    
    -- SRF05 sensor core
    SRF05_SENSOR: 
        entity work.srf05_core
        port map(
            clock_in       => clock_in,
            enable_in      => enable_in,
            echo_pulse_in  => echo_pulse_in,
            trig_pulse_out => trig_pulse_out,
            distance_out   => distance_out
        );


    -- Simulate 1 MHz clock pulse
    clock_sim: process
    begin
        clock_in <= '1';
        wait for clock_pulse/2;
        clock_in <= '0';
        wait for clock_pulse/2;
    end process;            
    
    
    fake_echo_pulse: process
        variable ep : time := 58 us;
    begin
        
        -- wait for trigger pulse
        wait until rising_edge(trig_pulse_out);
        
        -- simulate burst delay
        wait for 20 us;
        
        -- create pulse
        echo_pulse_in <= '1';        
        wait for ep;       
        echo_pulse_in <= '0';

        -- increase next echo pulse by 58
        ep := ep + 58 us;
        
    end process;
    

end Testbench;
