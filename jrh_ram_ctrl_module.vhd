----------------------------------------------------------------------------------
-- Author:        Jørgen Ryther Hoem
--
-- Course:        Digital System Design with VHDL (ET062G)     
--                Mid Sweden University, 2016
-- 
-- Module Name:   jrh_ram_ctrl_module - Behavioral
-- Project Name:  Range Sensor System
-- Description:   RAM controller, circular buffer as FIFO for the RAM module
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_ctrl_module is
    
    generic(
        ram_length  : integer;-- := 512;
        ram_depth   : integer;-- := 9;
        ram_addrlen : integer-- := 9
    );
    port(
        clock_in   : in  std_logic;
        write_data : in  std_logic_vector(ram_depth-1 downto 0);
        read_addr  : in  std_logic_vector(ram_addrlen-1 downto 0);
        read_data  : out std_logic_vector(ram_depth-1 downto 0);
        continuous : in  std_logic := '0'   
    );
    
end ram_ctrl_module;

architecture Behavioral of ram_ctrl_module is
    
    -- write signals
    signal w_en       : std_logic := '0';
    signal w_addr     : std_logic_vector(ram_addrlen-1 downto 0) := (others => '0');
    signal w_data     : std_logic_vector(ram_depth-1 downto 0) := (others => '0');

    -- read signals
    signal r_en       : std_logic := '0';
    signal r_addr     : std_logic_vector(ram_addrlen-1 downto 0) := (others => '0');
    
    -- internal signals
    signal read_shift : integer := 0;

begin

    RAM_BLOCK: 
        entity work.ram_module
        generic map(
            ram_length  => ram_length,
            ram_depth   => ram_depth,
            ram_addrlen => ram_addrlen
        )
        port map(
            clock_in    => clock_in,
            read_en     => r_en,
            write_en    => w_en,
            read_addr   => r_addr,
            write_addr  => w_addr,
            write_data  => w_data,
            read_data   => read_data
        );

    
    -- Write data to RAM as a circular buffer
    write_process: 
    process(clock_in, write_data)
    
        variable last_data : integer := 999;        
        variable w_index : integer := 0; 
        variable counter : integer := 0;
       
    begin
        
        if rising_edge(clock_in) then
        
            -- write and update index
            if (continuous = '0' and to_integer(unsigned(write_data)) /= last_data)
                or (continuous = '1' and counter >= 10800000) then

                last_data := to_integer(unsigned(write_data));
    
                w_en <= '1';
                               
                w_addr <= std_logic_vector(to_unsigned(w_index, ram_addrlen));
                w_data <= write_data;                     
                read_shift <= w_index;

                if w_index = ram_length-1 then
                    w_index := 0;
                else
                    w_index := w_index + 1;            
                end if;                                

                counter := 0;
                
            else 
            
                w_en <= '0';
                counter := counter + 1;

            end if;
        
        end if; 
               
    end process;
    
    
    -- Read data from RAM as circular buffer
    read_process: 
    process(clock_in)

        variable r_index : integer := 0;

    begin

        if rising_edge(clock_in) then
    
            r_en <= '1';
            -- shift the read address to the correct value
            r_index := read_shift + to_integer(unsigned(read_addr)) - 1;

            --report "READING RAM (" & integer'image(read_shift) & "): addr: " & integer'image(to_integer(unsigned(read_addr))) & " index: " & integer'image(r_index);
            
            if r_index >= ram_length then
                r_addr <= std_logic_vector(to_unsigned(r_index - ram_length, ram_addrlen));
            elsif r_index < 0 then
                r_addr <= std_logic_vector(to_unsigned(ram_length + r_index, ram_addrlen));
            else
                r_addr <= std_logic_vector(to_unsigned(r_index, ram_addrlen));
            end if;                
            
        end if;
    
    end process;
 


end Behavioral;
