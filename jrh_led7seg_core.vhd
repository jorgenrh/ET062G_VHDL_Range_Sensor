----------------------------------------------------------------------------------
-- Author:        Jørgen Ryther Hoem
--
-- Course:        Digital System Design with VHDL (ET062G)     
--                Mid Sweden University, 2016
-- 
-- Module Name:   jrh_led7seg_core - Behavioral
-- Project Name:  Range Sensor System
-- Description:   LED and 7-segment display core
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity led7seg_core is

    port (
        clock_in     : in  std_logic;
        binary_in    : in  std_logic_vector(15 downto 0);
        segment_out  : out std_logic_vector(6 downto 0) := (others => '0');
        position_out : out std_logic_vector(3 downto 0) := (others => '1');
        led_out      : out std_logic_vector(15 downto 0) := (others => '0')
    );

end led7seg_core;

architecture Behavioral of led7seg_core is

    signal bcd0, bcd1, bcd2, bcd3 : std_logic_vector(3 downto 0);
    
begin
    
    BIN2BCD_MODULE: 
        entity work.bin_to_4bcd_module 
        port map (
            binary_in => binary_in,
            bcd0 => bcd0,
            bcd1 => bcd1,
            bcd2 => bcd2,
            bcd3 => bcd3
        );
    
    
    -- 7-segment display
    seven_segment_display:
    process(clock_in, bcd0, bcd1, bcd2, bcd3)
    
        type bcd_array is array(3 downto 0) of std_logic_vector(3 downto 0); 
        variable bcd : bcd_array := (bcd0, bcd1, bcd2, bcd3);
        
        variable seg_position : integer := 0;
        variable clk_counter  : integer := 1;
    
    begin

        bcd := (bcd0, bcd1, bcd2, bcd3);
        
        if clock_in'event and clock_in = '1' then 

            if clk_counter >= 1000 then -- 1000 * 1us = 1 kHz update

                -- iterate trough each of the positions
                if seg_position < 4 then
                                                       
                    -- convert BCD into 7-segment                 
                    case bcd(seg_position) is       -- abcdefg
                        when "0000" => segment_out <= "0000001";  -- 0
                        when "0001" => segment_out <= "1001111";  -- 1
                        when "0010" => segment_out <= "0010010";  -- 2
                        when "0011" => segment_out <= "0000110";  -- 3
                        when "0100" => segment_out <= "1001100";  -- 4 
                        when "0101" => segment_out <= "0100100";  -- 5
                        when "0110" => segment_out <= "0100000";  -- 6
                        when "0111" => segment_out <= "0001111";  -- 7
                        when "1000" => segment_out <= "0000000";  -- 8
                        when "1001" => segment_out <= "0000100";  -- 9
                        when others => segment_out <= "1111111"; 
                    end case;
                    
                    -- set the 7-segment position                 
                    case seg_position is
                        when 0 => position_out <= "0111";
                        when 1 => position_out <= "1011";
                        when 2 => position_out <= "1101";
                        when 3 => position_out <= "1110";
                        when others => position_out <= "1111"; 
                    end case;
                               
                    seg_position := seg_position + 1;                    
                    clk_counter := 1;
                    
                else
                    seg_position := 0;
                end if;
                
            else             
                clk_counter := clk_counter + 1;            
            end if;
            
        end if; -- clock

    end process;    


    -- SRF05 LED meter
    led_meter_bar:
    process(clock_in)-- data_in)

        variable num : integer := 0;
        variable lim : integer := 0;

    begin
    
        if clock_in'event and clock_in = '1' then
                   
            num := 0;
            lim := to_integer(unsigned(binary_in));
           
            case lim is
                when   0        => num := 0;
                when   1 to  30 => num := 1;
                when  31 to  60 => num := 3;
                when  61 to  90 => num := 7;
                when  91 to 120 => num := 15; 
                when 121 to 150 => num := 31;
                when 151 to 180 => num := 63;
                when 181 to 210 => num := 127;
                when 211 to 240 => num := 255;
                when 241 to 270 => num := 511;
                when 271 to 300 => num := 1023;
                when 301 to 330 => num := 2047;
                when 331 to 360 => num := 4095;
                when 361 to 390 => num := 8191;
                when 391 to 420 => num := 16383;
                when 421 to 450 => num := 32767;
                when others => num := 52428; -- out-of-range pattern
            end case;
            
            led_out <= std_logic_vector(to_unsigned(num, 16));

        end if;
    
    end process;


end Behavioral;
