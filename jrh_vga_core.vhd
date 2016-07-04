----------------------------------------------------------------------------------
-- Author:        Jørgen Ryther Hoem
--
-- Course:        Digital System Design with VHDL (ET062G)     
--                Mid Sweden University, 2016
-- 
-- Module Name:   jrh_vga_core - Behavioral
-- Project Name:  Range Sensor System
-- Description:   VGA core, handles all VGA functionality
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;


entity vga_core is

    port(
        -- general signals
        clock_in   : in  std_logic;
        clock_slow : in  std_logic;
        reset_in   : in  std_logic;
        
        -- data in signal
        data_in    : in  std_logic_vector(15 downto 0) := (others => '0');
        
        -- control signals
        cont_sw    : in  std_logic := '0';
        half_sw    : in  std_logic := '0';
        push_btn   : in  std_logic_vector(4 downto 0) := (others => '0');
        
        -- VGA signals
        vga_hsync  : out std_logic := '0';
        vga_vsync  : out std_logic := '0';
        vga_red    : out std_logic_vector(3 downto 0) := (others => '0');
        vga_blue   : out std_logic_vector(3 downto 0) := (others => '0');
        vga_green  : out std_logic_vector(3 downto 0) := (others => '0')
    );

end vga_core;

architecture Behavioral of vga_core is

    -- VGA signals
    signal int_disp_en   : std_logic := '0';
    signal int_rowsel    : integer   := 0;
    signal int_colsel    : integer   := 0;    
    signal int_red       : std_logic_vector(3 downto 0) := (others => '0');
    signal int_green     : std_logic_vector(3 downto 0) := (others => '0');
    signal int_blue      : std_logic_vector(3 downto 0) := (others => '0');

    -- RAM configuration
    constant ram_length  : integer := 512;
    constant ram_depth   : integer := 9;
    constant ram_addrlen : integer := 9;

    -- RAM signals
    signal read_addr     : std_logic_vector(ram_addrlen-1 downto 0) := (others => '0');
    signal read_data     : std_logic_vector(ram_depth-1 downto 0)   := (others => '0');
    signal write_data    : std_logic_vector(ram_depth-1 downto 0)   := (others => '0');

    -- Graphics behaviour
    shared variable graph_x   : integer   := 704; --704
    shared variable graph_y   : integer   := 100; -- 100
    shared variable graph_w   : integer   := ram_length;
    shared variable graph_h   : integer   := 400;
 

   
begin

    RAM_CONTROLLER: 
        entity work.ram_ctrl_module
        generic map(
            ram_length  => ram_length,
            ram_depth   => ram_depth,
            ram_addrlen => ram_addrlen
        )
        port map(
            clock_in   => clock_in,
            write_data => write_data,
            read_addr  => read_addr,
            read_data  => read_data,
            continuous => cont_sw
        );

    VGA_CONTROLLER: 
        entity work.vga_ctrl_module 
        port map(
            pixel_clk => clock_in,
            reset_n   => reset_in,
            h_sync    => vga_hsync,
            v_sync    => vga_vsync,
            disp_ena  => int_disp_en,
            column    => int_colsel,
            row       => int_rowsel
        );

    FLAG_PATTERN: 
        entity work.norwegian_flag_pattern 
        port map(
            enable_in => int_disp_en,
            row       => int_rowsel,
            column    => int_colsel,
            red       => int_red,
            green     => int_green,
            blue      => int_blue
        );



    --
    -- Data storage process
    ---- --- -- - - - - - - - - - - - - - - - - -    
    data_storage: 
    process(clock_slow)
    begin
        
        if clock_slow'event and clock_slow = '1' then
            
            -- constrain the value if it is above 400
            if to_integer(unsigned(data_in)) > 400 then
                write_data <= std_logic_vector(to_unsigned(400, ram_depth));                            
            else
                write_data <= std_logic_vector(resize(unsigned(data_in), ram_depth));            
            end if;
                    
        end if;
        
    end process;
    

    --
    -- Graphics process
    ---- --- -- - - - - - - - - - - - - - - - - -    
    graphics: 
    process(clock_in)
    
        variable data      : integer := 0;
        variable data_live : integer := 0;       
        
        constant meter_h   : integer := 8; 
    
    begin
    
        if clock_in'event and clock_in = '1' then
            
            -- "raw" sensor data 
            data_live := to_integer(unsigned(data_in));

            if half_sw = '0' then
                -- if half size, divide data by 2 using right shift
                -- since regular division should be avoided, (2^9)/2 = 256.
                data := to_integer(resize(resize(unsigned(read_data) * 256, 18) srl 9, 9));
                graph_h := 200;      
            else
                data := to_integer(unsigned(read_data));
                graph_h := 400;                                
            end if;

            -- Draw graphics
            
            -- frame:
            if ((int_rowsel = graph_y-1 or int_rowsel = (graph_y+graph_h) or int_rowsel = (graph_y+graph_h+meter_h)) and 
                    (int_colsel >= graph_x-1 and int_colsel <= (graph_x+graph_w))) or 
                        ((int_colsel = graph_x-1 or int_colsel = (graph_x+graph_w)) and 
                            (int_rowsel >= graph_y and int_rowsel <= (graph_y+graph_h+meter_h))) then
                vga_red <= (others => '0');
                vga_green <= (others => '1');
                vga_blue <= (others => '1');                

            -- bar/meter:
            elsif (int_colsel >= graph_x) and (int_colsel < (graph_x+graph_w)) then
                
                -- read data from RAM (won't have any effect untill next cycle)
                read_addr <= std_logic_vector(to_unsigned(ram_length - (int_colsel - graph_x), ram_addrlen));
                            
                -- plot bar graph
                if (int_rowsel >= (graph_h+graph_y-data)) and (int_rowsel < (graph_h+graph_y)) then
                    vga_red   <= (others => '0');
                    vga_green <= (others => '0');
                    vga_blue  <= (others => '0');                    
                -- plot meter
                elsif (int_rowsel >= (graph_y+graph_h+1) and int_rowsel < (graph_y+graph_h+meter_h)) and (int_colsel < (graph_x+data_live)) then
                    vga_red   <= (others => '0');
                    vga_green <= (others => '0');
                    vga_blue  <= (others => '0');
                -- plot background
                else
                    vga_red   <= int_red;
                    vga_green <= int_green;
                    vga_blue  <= int_blue;                
                end if;
            
            -- background:
            else
                vga_red   <= int_red;
                vga_green <= int_green;
                vga_blue  <= int_blue;                
            end if;
        
        end if;    
    
    end process;


    --
    -- Animation process
    ---- --- -- - - - - - - - - - - - - - - - - -    
    animation: 
    process(clock_in)

        -- move states
        type move_type is (IDLE, MOVE_LEFT, MOVE_RIGHT, MOVE_UP, MOVE_DOWN);
        variable move : move_type;
                
        -- end of movement values
        variable x_end   : integer := 0; 
        variable y_end   : integer := 0;
        
        -- animation counter        
        variable counter : integer := 0;
    
    begin

        if clock_in'event and clock_in = '1' then

            if counter >= 540000 then -- 5 ms
                
                counter := 0;
                
                if move /= IDLE then

                    -- move the graph accordingly
                    case move is
                        when MOVE_LEFT => 
                            if graph_x <= x_end or graph_x-5 <= 0 then
                                move := IDLE;
                            else 
                                graph_x := graph_x - 1;                            
                            end if;
                        when MOVE_RIGHT => 
                            if graph_x >= x_end or graph_x+5+graph_w >= 1279 then
                                move := IDLE;
                            else 
                                graph_x := graph_x + 1;                            
                            end if;
                        when MOVE_UP => 
                            if graph_y <= y_end then
                                move := IDLE;
                            else 
                                graph_y := graph_y - 1;                            
                            end if;
                        when MOVE_DOWN => 
                            if graph_y >= y_end or graph_y+5+graph_h >= 1023 then
                                move := IDLE;
                            else
                                graph_y := graph_y + 1;                            
                            end if;
                        when others => null;                                    
                    end case;
                
                end if;
            
            else
                counter := counter + 1;
            end if;            
            
            -- move increment/decrement is 10 px
            if move = IDLE then
                
                if push_btn(0) = '1' then -- center
                    graph_x := 703;
                    graph_y := 100;
                elsif push_btn(1) = '1' then -- up
                    y_end := graph_y - 10;
                    move := MOVE_UP;
                elsif push_btn(2) = '1' then -- left
                    x_end := graph_x - 10;
                    move := MOVE_LEFT;
                elsif push_btn(3) = '1' then -- right
                    x_end := graph_x + 10;
                    move := MOVE_RIGHT;
                elsif push_btn(4) = '1' then -- down
                    y_end := graph_y + 10;
                    move := MOVE_DOWN;
                end if;            
            
            end if;
            

        end if;
    
    end process;
    
    
    
end Behavioral;
