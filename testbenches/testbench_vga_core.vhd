----------------------------------------------------------------------------------
-- Author:        Jørgen Ryther Hoem
--
-- Course:        Digital System Design with VHDL (ET062G)     
--                Mid Sweden University, 2016
-- 
-- Module Name:   testbench_vga_core - Testbench
-- Project Name:  Range Sensor System
-- Description:   Testbench for the VGA core
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench_vga_core is
end testbench_vga_core;

architecture Testbench of testbench_vga_core is

    -- VGA signals
    signal vga_hsync  : std_logic := '0';
    signal vga_vsync  : std_logic := '0';
    signal vga_red    : std_logic_vector(3 downto 0) := (others => '0');
    signal vga_blue   : std_logic_vector(3 downto 0) := (others => '0');
    signal vga_green  : std_logic_vector(3 downto 0) := (others => '0');

    -- vga functionality
    signal reset_in   : std_logic := '1';
    signal half_sw    : std_logic := '0';
    signal push_btn   : std_logic_vector(4 downto 0) := (others => '0');

    -- tb functionality
    signal snapshot   : std_logic := '0';
    
    -- clock signals
    signal clock_in   : std_logic := '0';
    signal clock_vga  : std_logic := '0';
    signal clock_slow : std_logic := '0';
    
    -- sensor data
    signal data_in    : std_logic_vector(15 downto 0) := (others => '0');
    
    -- vga2bm reading status
    signal reading    : std_logic := '0';
    
    -- tb simulated clock pulse
    constant clock_pulse  : time := 10 ns;
    
begin

    VGA_DISPLAY:
        entity work.vga_core
        port map(
            clock_in   => clock_vga,
            clock_slow => clock_slow,
            reset_in   => reset_in,
            data_in    => data_in,
            half_sw    => half_sw,
            vga_hsync  => vga_hsync,
            vga_vsync  => vga_vsync,
            vga_red    => vga_red,
            vga_green  => vga_green,
            vga_blue   => vga_blue
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
            clock_108mhz_out => clock_vga,
            clock_1mhz_out   => clock_slow
       );

    -- clock simulator
    clock_sim: process
    begin
        clock_in <= '1';
        wait for clock_pulse/2;
        clock_in <= '0';
        wait for clock_pulse/2;
    end process;    
    
    -- add dummy data
    dummy_data: process
        variable data  : integer := 1;               
        variable count : integer := 0;               
    begin
        data_in <= std_logic_vector(to_unsigned(data, 16));
        wait for 1 us;
        data := data + 1;
        if data > 400 then
            data := 1;
            count := count + 1;
        end if;        
        if count >= 2 then
            wait;
        end if;
    end process;

    -- vga to bmp snapshot
    take_snapshot: process
    begin
        snapshot <= '1';
        wait;
    end process;

  

end Testbench;
