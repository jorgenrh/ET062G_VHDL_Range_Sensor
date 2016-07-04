----------------------------------------------------------------------------------
-- Author:        Jørgen Ryther Hoem
--
-- Course:        Digital System Design with VHDL (ET062G)     
--                Mid Sweden University, 2016
-- 
-- Module Name:   testbench_main_project - Testbench
-- Project Name:  Range Sensor System
-- Description:   Testbench for the top file, whole project
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity testbench_main_project is
end testbench_main_project;

architecture Testbench of testbench_main_project is

    -- General
    signal clock_in       :  std_logic := '0';
    signal enable_in      :  std_logic := '0';
    signal reset_in       :  std_logic := '1';
  
    -- SRF05
    signal echo_pulse_in  : std_logic := '0';
    signal trig_pulse_out : std_logic := '0';
    signal led_out        : std_logic_vector(15 downto 0) := (others => '0');
    
    -- LCD
    signal lcd_segment    : std_logic_vector(6 downto 0) := (others => '0');
    signal lcd_position   : std_logic_vector(3 downto 0) := (others => '1');
    
    -- VGA
    signal vga_hsync      : std_logic := '0';
    signal vga_vsync      : std_logic := '0';
    signal vga_red        : std_logic_vector(3 downto 0) := (others => '0');
    signal vga_blue       : std_logic_vector(3 downto 0) := (others => '0');
    signal vga_green      : std_logic_vector(3 downto 0) := (others => '0');
    
    -- tb functionality
    signal snapshot       : std_logic := '0';
    signal reading        : std_logic := '0';
        

    
    signal clock_vga      : std_logic := '0';
    
    constant clock_pulse  : time := 10 ns;
    
begin

    MAIN_PROJECT:
        entity work.jrh_main_top
        port map(
            -- General
            clock_in       => clock_in,
            enable_in      => enable_in,
            reset_in       => reset_in,
          
            -- SRF05
            echo_pulse_in  => echo_pulse_in,
            trig_pulse_out => trig_pulse_out,
            led_out        => led_out,
            
            -- LCD
            lcd_segment    => lcd_segment,
            lcd_position   => lcd_position,
            
            -- VGA
            vga_hsync      => vga_hsync,
            vga_vsync      => vga_vsync,
            vga_red        => vga_red,
            vga_blue       => vga_blue,
            vga_green      => vga_green
        );        


    VGA_SIMULATOR:
        entity work.testbench_comp_vga2bmp
        generic map(
            file_name  => "C:\VHDL\vga_output.bmp"
        )
        port map(
            clock_in   => clock_vga,
            vga_hsync  => vga_hsync,
            vga_vsync  => vga_vsync,
            vga_red    => vga_red,
            vga_green  => vga_green,
            vga_blue   => vga_blue,
            snapshot   => snapshot,
            reading    => reading
        );

    CLOCK_GENERATOR: 
        entity work.clock_gen_module 
        port map(
            clock_100mhz_in  => clock_in,
            clock_108mhz_out => clock_vga
        );


    -- Simulate 100 MHz clock pulse
    clock_sim: process
    begin
        clock_in <= '1';
        wait for clock_pulse/2;
        clock_in <= '0';
        wait for clock_pulse/2;
    end process;    


    fake_echo_pulse: process
        variable ep : time := 14500 us; -- 250 cm
    begin
        
        -- wait for trigger pulse
        --wait until rising_edge(trig_pulse_out);
        wait for 10 us;
        
        -- simulate burst wait
        wait for 25 us; -- 40kHz
        
        -- create pulse
        echo_pulse_in <= '1';        
        wait for ep;       
        echo_pulse_in <= '0';
        
        wait;
    end process;
    
    -- vga to bmp snapshot (this is to trigger the rising edge)
    take_snapshot: process
    begin
        wait for 10 us;
        snapshot <= '1';
        wait;
    end process;


end Testbench;
