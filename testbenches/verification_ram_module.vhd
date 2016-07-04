----------------------------------------------------------------------------------
-- Author:        Jørgen Ryther Hoem
--
-- Course:        Digital System Design with VHDL (ET062G)     
--                Mid Sweden University, 2016
-- 
-- Module Name:   verification_ram_module - Verification
-- Project Name:  Range Sensor System
-- Description:   Verification/test module for the RAM module
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity verification_ram_module is

    port(
        clock_in  :  in std_logic;
        switch_in :  in std_logic_vector(8 downto 0) := (others => '0');
        led_out   : out std_logic_vector(8 downto 0) := (others => '0')
    );
    
end verification_ram_module;

architecture Verification of verification_ram_module is

    -- RAM configuration
    constant ram_length  : integer := 512;
    constant ram_depth   : integer := 9;
    constant ram_addrlen : integer := 9;

    -- RAM signals
    signal reset_in   : std_logic := '1';
    signal read_en    : std_logic := '0';
    signal write_en   : std_logic := '0';
    signal read_addr  : std_logic_vector(ram_addrlen-1 downto 0) := (others => '0');
    signal write_addr : std_logic_vector(ram_addrlen-1 downto 0) := (others => '0');
    signal write_data : std_logic_vector(ram_depth-1 downto 0) := (others => '0');
    signal read_data  : std_logic_vector(ram_depth-1 downto 0) := (others => '0');

    -- internal signals
    signal ram_full : std_logic := '0';

begin

    RAM_MOD: 
        entity work.ram_module
        generic map(
            ram_length  => ram_length,
            ram_depth   => ram_depth,
            ram_addrlen => ram_addrlen
        )
        port map(
            clock_in => clock_in,
            read_en  => read_en,
            write_en  => write_en,
            read_addr => read_addr,
            write_addr => write_addr,
            write_data => write_data,
            read_data => read_data
        );


    process(clock_in)    

        variable count : integer := 0;

    begin
        
        if clock_in'event and clock_in = '1' then
    
            if ram_full = '1' then -- read address by using switches
            
                read_en <= '1';
                read_addr <= switch_in;
                led_out <= read_data;                                
            
            else -- fill ram once
            
                if count <= 399 then
                    write_en <= '1';
                    write_addr <= std_logic_vector(to_unsigned(count, 9));
                    write_data <= std_logic_vector(to_unsigned(count, 9));
                    count := count + 1;
                else
                    write_en <= '0';
                    ram_full <= '1';
                    count := 0;
                end if;
                                
            end if;
            
        end if;
    
    end process;
    

end Verification;