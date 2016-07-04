----------------------------------------------------------------------------------
-- Author:        Jørgen Ryther Hoem
--
-- Course:        Digital System Design with VHDL (ET062G)     
--                Mid Sweden University, 2016
-- 
-- Module Name:   jrh_main_top - Behavioral
-- Project Name:  Range Sensor System
-- Description:   Main top file for the project 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;


entity jrh_main_top is
    
    port(
        -- General
        clock_in       : in  std_logic;
        enable_in      : in  std_logic;
        reset_in       : in  std_logic;
      
        -- SRF05
        echo_pulse_in  : in  std_logic;
        trig_pulse_out : out std_logic;
        led_out        : out std_logic_vector(15 downto 0) := (others => '0');
        
        -- LCD
        lcd_segment    : out std_logic_vector(6 downto 0) := (others => '0');
        lcd_position   : out std_logic_vector(3 downto 0) := (others => '1');
        
        -- VGA
        vga_hsync      : out std_logic := '0';
        vga_vsync      : out std_logic := '0';
        vga_red        : out std_logic_vector(3 downto 0) := (others => '0');
        vga_blue       : out std_logic_vector(3 downto 0) := (others => '0');
        vga_green      : out std_logic_vector(3 downto 0) := (others => '0');
        
        -- Data display options
        cont_sw        : in  std_logic := '0';
        half_sw        : in  std_logic := '0';
        push_btn       : in  std_logic_vector(4 downto 0) := (others => '0')
    );

end jrh_main_top;

architecture Behavioral of jrh_main_top is
    
    -- clock signals
    signal clock_vga  : std_logic := '0';
    signal clock_slow : std_logic := '0';
    
    -- sensor signals
    signal int_distance : std_logic_vector(15 downto 0) := (others => '0');
   
begin   

    CLOCK_GENERATOR: 
        entity work.clock_gen_module 
        port map(
            clock_100mhz_in  => clock_in,
            clock_108mhz_out => clock_vga,
            clock_1mhz_out   => clock_slow
        );

    SRF05_SENSOR: 
        entity work.srf05_core 
        port map(
            clock_in       => clock_slow,
            enable_in      => enable_in,
            echo_pulse_in  => echo_pulse_in,
            trig_pulse_out => trig_pulse_out,
            distance_out   => int_distance
        );

    LED_7SEGMENT: 
        entity work.led7seg_core 
        port map(
            clock_in     => clock_slow,
            binary_in    => int_distance,
            segment_out  => lcd_segment,
            position_out => lcd_position,
            led_out      => led_out
        );
    
    VGA_GRAPHICS:
        entity work.vga_core
        port map(
            clock_in   => clock_vga,
            clock_slow => clock_slow,
            reset_in   => reset_in,
            data_in    => int_distance,
            vga_hsync  => vga_hsync,
            vga_vsync  => vga_vsync,
            vga_red    => vga_red,
            vga_blue   => vga_blue,
            vga_green  => vga_green,
            cont_sw    => cont_sw,
            half_sw    => half_sw,
            push_btn   => push_btn
        );



end Behavioral;
