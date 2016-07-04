----------------------------------------------------------------------------------
-- Author:        Jørgen Ryther Hoem
--
-- Course:        Digital System Design with VHDL (ET062G)     
--                Mid Sweden University, 2016
-- 
-- Module Name:   testbench_ram - Testbench
-- Project Name:  Range Sensor System
-- Description:   Testbench for the RAM controller
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench_ram is
end testbench_ram;

architecture Testbench of testbench_ram is

    constant clock_pulse : time := 10 ns;  
     
    constant ram_length  : integer := 5;
    constant ram_depth   : integer := 9;
    constant ram_addrlen : integer := 9;

    signal clock_in      : std_logic := '0';
    signal clock_vga     : std_logic := '0';
    signal clock_slow    : std_logic := '0';
    
    signal write_data : std_logic_vector(ram_depth-1 downto 0) := (others => '0');

    signal read_en    : std_logic := '0';
    signal read_addr  : std_logic_vector(ram_addrlen-1 downto 0) := (others => '0');
    signal read_data  : std_logic_vector(ram_depth-1 downto 0) := (others => '0');
    signal continuous : std_logic := '0';
    
begin

    CLOCK_GENERATOR: 
        entity work.clock_gen_module 
        port map(
            clock_100mhz_in  => clock_in,
            clock_108mhz_out => clock_vga,
            clock_1mhz_out   => clock_slow
        );

    RAM_CTRL: 
        entity work.ram_ctrl_module
        generic map(
            ram_length  => ram_length,
            ram_depth   => ram_depth,
            ram_addrlen => ram_addrlen
        )
        port map(
            clock_in   => clock_vga,
            write_data => write_data,
            read_addr  => read_addr,
            read_data  => read_data,
            continuous => continuous
        );


    -- clock sim
    clock_sim: process
    begin
        clock_in <= '1';
        wait for clock_pulse/2;
        clock_in <= '0';
        wait for clock_pulse/2;
    end process;

    -- fill RAM with values from 100 to 0 (slow clock)
    write_test: process
        variable inc : integer := 100;
    begin
        wait until rising_edge(clock_slow);

        write_data <= std_logic_vector(to_unsigned(inc, ram_depth)); 
        inc := inc - 1;
        if inc < 0 then
            inc := 100;
        end if;
    end process;

    -- read RAM (vga clock)
    read_test: process
        variable addr : integer := 0;
    begin
        wait until rising_edge(clock_vga);

        read_addr <= std_logic_vector(to_unsigned(addr, ram_addrlen)); 
        if addr+1 = ram_length then
            addr := 0;
        else
            addr := addr + 1;
        end if;
    end process;

end Testbench;
