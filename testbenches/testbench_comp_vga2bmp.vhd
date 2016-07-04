----------------------------------------------------------------------------------
-- Author:        Jørgen Ryther Hoem
--
-- Course:        Digital System Design with VHDL (ET062G)     
--                Mid Sweden University, 2016
-- 
-- Module Name:   testbench_comp_vga2bmp - Testbench
-- Project Name:  Range Sensor System
-- Description:   Testbench component, VGA simulator that saves one frame as BMP
--                if the snapshot signal is set high. The capturing is dependent
--                of vsync and hsync. 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;


entity testbench_comp_vga2bmp is

    generic(
        bmp_width  : integer := 1280;   
        bmp_height : integer := 1024;
        h_bporch   : integer := 248;
        v_bporch   : integer := 38;
        file_name  : string  := "C:\VHDL\VGA_output.bmp"  
    );
    port(
        clock_in   : in  std_logic;

        vga_hsync  : in  std_logic := '0';
        vga_vsync  : in  std_logic := '0';

        vga_red    : in  std_logic_vector(3 downto 0) := (others => '0');
        vga_green  : in  std_logic_vector(3 downto 0) := (others => '0');
        vga_blue   : in  std_logic_vector(3 downto 0) := (others => '0');

        snapshot   : in  std_logic := '0';
        reading    : out std_logic := '0'
    );

end testbench_comp_vga2bmp;

architecture Testbench of testbench_comp_vga2bmp is

    -- file data type
    type file_type is file of character;    	    
    file outfile : file_type;
   
    -- array for header data
	subtype byte is integer range 0 to 255;
    type byte_array is array(natural range <>) of byte; 
    
    -- array for rgb values    
    type frame_col is array(0 to bmp_height-1) of byte;
    type full_frame is array(0 to bmp_width-1) of frame_col;
     
    
begin

    process

        -- calculate BMP sizes for header
        constant bmp_area : integer := (bmp_width * bmp_height);
        constant bmp_size : integer := (bmp_area * 3);

        -- create header array
        variable header : byte_array(0 to 53) := (others => 0);
        
        -- RGB arrays to reverse the pixel order later
        variable rbg_red   : full_frame := (others => (others => 0));
        variable rbg_green : full_frame := (others => (others => 0));
        variable rbg_blue  : full_frame := (others => (others => 0));
      
        -- sync counter for vertical/horizontal back porch
        variable sync_count : integer := 0;
      
        -- function for converting integer into 4 bytes for the header
        function int_to_4bytes(val : integer) return byte_array is
            variable ret : byte_array(0 to 3) := (others => 0);
        begin
            ret(0) := to_integer(resize(shift_right(to_unsigned(val, 32),  0), 8));
            ret(1) := to_integer(resize(shift_right(to_unsigned(val, 32),  8), 8));
            ret(2) := to_integer(resize(shift_right(to_unsigned(val, 32), 16), 8));
            ret(3) := to_integer(resize(shift_right(to_unsigned(val, 32), 24), 8));
            return ret;
        end function;
        
    begin
        
        -- wait for iiit    
        wait until rising_edge(snapshot);


        -- READ VGA PIXEL DATA
        ------------------------------------------------------
        
        report "waiting for vsync ...";
        wait until rising_edge(vga_vsync);
        report "starting!";
        
        -- compensate for vertical back porch
        sync_count := 0;
        while sync_count < v_bporch loop
            wait until falling_edge(vga_hsync);
            sync_count := sync_count + 1;
        end loop;
        
        -- wait for two horizontal syncs before capturing 
        wait until falling_edge(vga_hsync);
        wait until falling_edge(vga_hsync);

        -- start to read pixel values
        -- by using loops the front porch can be ignored
        for y in 0 to bmp_height-1 loop
            
            -- wait for new line
            wait until falling_edge(vga_hsync);        

            -- compensate for horizontal back porch
            sync_count := 0;
            while sync_count < h_bporch loop
                wait until falling_edge(clock_in);
                sync_count := sync_count + 1;
            end loop;

            -- read line pixels
            for x in 0 to bmp_width-1 loop
                
                -- read after falling clock edge to get an updated signal
                wait until falling_edge(clock_in);
                
                -- indicate reading status
                reading <= '1';
                     
                -- convert RGB888 to RGB444 (the simple way by left shifting) 
                rbg_red(x)(y) := to_integer(resize(unsigned(vga_red), 8) sll 4);            
                rbg_green(x)(y) := to_integer(resize(unsigned(vga_green), 8) sll 4);            
                rbg_blue(x)(y) := to_integer(resize(unsigned(vga_blue), 8) sll 4);            
                     
            end loop;
               
        end loop;
        
        -- set reading status to off
        reading <= '0';
        

        -- SAVE VGA PIXEL DATA AS 24-BIT BMP
        ------------------------------------------------------

        -- generate header data
        -- http://www.fastgraph.com/help/bmp_header_format.html
        header( 0 to  1) := (0 => character'pos('B'), 1 => character'pos('M')); -- signature
        header( 2 to  5) := int_to_4bytes(bmp_size+54); -- total size width*height*3 + 54
        header( 6 to  9) := (others => 0);              -- reserved, must be 0
        header(10 to 13) := int_to_4bytes(54);          -- offset to start of image data in bytes
        header(14 to 17) := int_to_4bytes(40);          -- size of BITMAPINFOHEADER structure, must be 40
        header(18 to 21) := int_to_4bytes(bmp_width);   -- image width in pixels
        header(22 to 25) := int_to_4bytes(bmp_height);  -- image height in pixels
        header(26 to 27) := (0 => 1,  1 => 0);          -- number of planes in the image, must be 1
        header(28 to 29) := (0 => 24, 1 => 0);          -- number of bits per pixel (1, 4, 8, or 24)
        header(30 to 33) := (others => 0);              -- compression type (0=none, 1=RLE-8, 2=RLE-4)
        header(34 to 37) := int_to_4bytes(bmp_size);    -- size of image data in bytes (including padding)
        header(38 to 41) := (others => 0);              -- horizontal resolution in pixels per meter (unreliable)
        header(42 to 45) := (others => 0);              -- vertical resolution in pixels per meter (unreliable)
        header(46 to 49) := (others => 0);              -- number of colors in image, or zero
        header(50 to 53) := (others => 0);              -- number of important colors, or zero          
            
        -- open file
        file_open(outfile, file_name, write_mode);
            
        -- write header to file
        for i in 0 to 53 loop
            write(outfile, character'val(header(i)));
        end loop;

        -- write RGB (BGR) data to file, and flip it vertically
        for y in bmp_height-1 downto 0 loop
            for x in 0 to bmp_width-1 loop
                write(outfile, character'val(rbg_blue(x)(y)));
                write(outfile, character'val(rbg_green(x)(y)));
                write(outfile, character'val(rbg_red(x)(y)));
            end loop;
        end loop;
        
        -- close file
        file_close(outfile);

        wait;
    
    end process;


end Testbench;
