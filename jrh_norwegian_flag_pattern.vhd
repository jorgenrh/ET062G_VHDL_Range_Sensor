----------------------------------------------------------------------------------
-- Author:        Jørgen Ryther Hoem
--
-- Course:        Digital System Design with VHDL (ET062G)     
--                Mid Sweden University, 2016
-- 
-- Module Name:   jrh_norwegian_flag_pattern - Behavioral
-- Project Name:  Range Sensor System
-- Description:   Flag pattern for VGA, part of the VGA core 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity norwegian_flag_pattern is

    -- set the horizontal and vertical limits 
    -- for each color, from a to b
	generic( 
		h_red1_a    : integer := 0;
    	h_red1_b    : integer := 384;
        h_white1_a  : integer := 384;
        h_white1_b  : integer := 448;
        h_blue_a    : integer := 448;
        h_blue_b    : integer := 576;
        h_white2_a  : integer := 576;
        h_white2_b  : integer := 640;
        h_red2_a    : integer := 640;
        h_red2_b    : integer := 1280;
        v_red1_a    : integer := 0;
        v_red1_b    : integer := 384;
        v_white1_a  : integer := 384;
        v_white1_b  : integer := 448;
        v_blue_a    : integer := 448;
        v_blue_b    : integer := 576;
        v_white2_a  : integer := 576;
        v_white2_b  : integer := 640;
        v_red2_a    : integer := 640;
        v_red2_b    : integer := 1024
    );
    port(
        enable_in : in  std_logic;  --display enable ('1' = display time, '0' = blanking time)
        row       : in  integer;    --row pixel coordinate
        column    : in  integer;    --column pixel coordinate
        red       : out std_logic_vector(3 downto 0) := (others => '0');  --red magnitude output to dac
        green     : out std_logic_vector(3 downto 0) := (others => '0');  --green magnitude output to dac
        blue      : out std_logic_vector(3 downto 0) := (others => '0')   --blue magnitude output to dac
    );

end norwegian_flag_pattern;

architecture Behavioral of norwegian_flag_pattern is

begin 
    
    process(enable_in, row, column)    
    begin

    if enable_in = '1' then
        
        -- write the norwegian flag        
        if (((row > v_blue_a and row <= v_blue_b) and column <= h_red2_b) 
                or ((column > h_blue_a and column <= h_blue_b) and row <= v_red2_b)) then
            red   <= (others => '0');
            green <= (others => '0');
            blue  <= (others => '1');      
        elsif (((row > v_white1_a and row <= v_white1_b) 
                or (row > v_white2_a and row <= v_white2_b)) and column <= h_red2_b) then
            red   <= (others => '1');
            green <= (others => '1');
            blue  <= (others => '1');      
        elsif (((column > h_white1_a and column <= h_white1_b) 
                or (column > h_white2_a and column <= h_white2_b)) and row <= v_red2_b) then
            red   <= (others => '1');
            green <= (others => '1');
            blue  <= (others => '1');      
        elsif (((row >= v_red1_a and row <= v_red1_b) 
                or (row > v_red2_a and row <= v_red2_b)) and column <= h_red2_b) then
            red   <= (others => '1');
            green <= (others => '0');
            blue  <= (others => '0');      
        elsif (((column > h_red1_a and column <= h_red1_b) 
                or (column > h_red2_a and column <= h_red2_b)) and row <= v_red2_b) then
            red   <= (others => '1');
            green <= (others => '0');
            blue  <= (others => '0');
        else
            red   <= (others => '0');
            green <= (others => '0');
            blue  <= (others => '0');
        end if;

    else --blanking 

        red   <= (others => '0');
        green <= (others => '0');
        blue  <= (others => '0');

    end if;
  
  end process;

end Behavioral;