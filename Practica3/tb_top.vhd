library IEEE;
library std; --Libreria que usaremos en la practica 3
use std.textio.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top is 
end tb_top;
        
architecture testBench of tb_top is
  component top_practica1 is
  generic (
      g_sys_clock_freq_KHZ  : integer := 100e3; -- Value of the clock frequencies in KHz
      g_debounce_time 		: integer := 20;  -- Time for the debouncer in ms
      g_reset_value 		: std_logic := '0'; -- Value for the synchronizer 
      g_number_flip_flps 	: natural := 2 	-- Number of ffs used to synchronize	
  );
  port (
      rst_n         : in std_logic;
      clk100Mhz     : in std_logic;
      BTNC           : in std_logic;
      LED           : out std_logic
  );
end component;

  constant timer_debounce : integer := 1; --ms
  constant freq : integer := 100_000; --KHZ
  constant clk_period : time := (1 ms/ freq);

  -- Inputs 
  signal  rst_n       :   std_logic := '0';
  signal  clk         :   std_logic := '0';
  signal  BTN     :   std_logic := '0';
  -- Output
  signal  LED   :   std_logic;
  -- Senial fin de simulacion
  signal  fin_sim : boolean := false;
  
begin
  UUT: top_practica1
    generic map(g_debounce_time => timer_debounce)
    port map (
      rst_n     => rst_n,
      clk100Mhz => clk,
      BTNC       => BTN,
      LED       => LED
    );
	
  --Proceso de generacion del reloj 
  clock: process
  begin
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
      if fin_sim = true then
        wait;
     end if;
     
      
  end process;
  
  process is 
  --variables para manejar los ficheros
  file file_INPUT : text;
  file file_OUTPUT : text;
  variable v_status_input: file_open_status;
  variable v_status_output: file_open_status;
  
  variable v_ILINE: line; --Para almacenar cada linea del fichero
  variable v_OLINE: line;
  --Variables para los valores de entrada
  variable v_RST: integer; --Valor del boton que obtendremos del fichero
  variable v_BTNC: integer;
  variable v_TIME: time;
  
  --Variables para los valores de salida
  variable v_expected: std_logic;
  variable v_LED: integer;
  
  begin 
  
  --Abrimos los ficheros con la instruccion file_open (punto 2.2.2)
  file_open(v_status_input, file_INPUT, "../input.txt", read_mode);
  file_open(v_status_output, file_OUTPUT, "../output.txt", write_mode);
  
  --2.2.3 Uso de assert para verificacion de seniales
  
  --Comprobamos que se abren correctamente, en caso contrario paramos la simulacion
  assert v_status_input = open_ok 
    report "El fichero input.txt no se ha abierto correctamente"
    severity failure; --Con severity failure forzamos la simulacion a parar
	
  assert v_status_output = open_ok
    report "El fichero output.txt no se ha abierto correctamente"
    severity failure; --Con severity failure forzamos la simulacion a parar
  
  
  --2.2.6
   write(v_oline, string'("Simulation of top_practica1.vhd"));
   writeline(file_OUTPUT, v_OLINE);

    while (not endfile(file_INPUT)) loop
		readline(file_INPUT, v_ILINE); --lee toda la linea
		read(v_ILINE, v_TIME);         --lee hasta un espacio en blanco
		read(v_ILINE, v_RST);
		read(v_ILINE, v_BTNC);
		read(v_ILINE, v_LED);
		
		--2.2.5
		BTN <= to_unsigned(v_BTNC,1)(0); --Como es un std_logic se debe hacer con (v_btn, 1)(0), si fuera simple seria con (v_btn) solamente 
		rst_n <= to_unsigned(v_RST,1)(0);
		v_expected:= to_unsigned(v_LED,1)(0);
		
		wait for v_TIME;
		
		--2.2.6 Escribimos el reporte
		write(v_OLINE, "Time: " & time'image(v_TIME) & "  rst_n: " & integer'image(v_RST) & "  BTNC: " & integer'image(v_BTNC)); --primero debemos escribir con write todos los valores en una linea
		writeline(file_OUTPUT, v_OLINE); --despues de crear una linea se puede escribir en un archivo mediante writeline
		
		assert v_expected /= LED
		  report "ERROR"
		  severity note;
		  
		  if(v_expected = LED) then
		      write(v_OLINE, "LED: " & integer'image(v_LED));
		      writeline(file_OUTPUT, v_OLINE);
		  else
		      write(v_OLINE, "ERROR: " & "  Expected LED to be: " & integer'image(v_LED) &
		      "  actual value: " & std_logic'image(LED));
		      writeline(file_OUTPUT, v_OLINE);
            end if;
    end loop;
    
    write(v_oline, string'("END SIMULATION"));
    writeline(file_OUTPUT, v_OLINE);
     fin_sim <= true;
    wait;
    
  end process;
    
end testBench;