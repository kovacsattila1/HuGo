----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:39:21 03/10/2014 
-- Design Name: 
-- Module Name:    pwm - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pwm_ultra is
    Port ( src_clk : in  STD_LOGIC;
           src_ce : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  start : in  STD_LOGIC;
           h : in  STD_LOGIC_VECTOR (31 downto 0);
			  min_val : in STD_LOGIC_VECTOR (31 downto 0);
			  max_val : in STD_LOGIC_VECTOR (31 downto 0);
			  div_value : in STD_logic_vector(9 downto 0);
           pwm_out : out  STD_LOGIC);
end pwm_ultra;


architecture Behavioral of pwm_ultra is

type casee is(RDY,INIT,HIGH,LOW);
signal actual_case : casee;
signal next_case : casee;
signal pwm_sig, pwm_next_sig : STD_LOGIC;
signal counter, counter_next : STD_LOGIC_VECTOR(31 downto 0);
signal q_clk: STD_LOGIC;


begin

State_R:process(q_clk,reset)
begin

if reset = '1' then
			actual_case<= RDY;
			counter<=(others => '0');
			pwm_sig<='0';
	elsif (q_clk'event and q_clk='1') then
			actual_case<=next_case;
			counter<=counter_next;
			pwm_sig<=pwm_next_sig;
	end if;

end process State_R;

next_case_log:process(actual_case, start,counter)
begin

case(actual_case) is
	when RDY =>
		if start='1'   
			then
				next_case<=INIT;
			else
				next_case<=RDY;
		end if;
		
	when INIT =>
		if counter <min_val--"0000010000000000" 			-- ??? 
			then
				next_case<=INIT;
			else
				next_case<=HIGH;
		end if;

	when HIGH =>
		if counter<(h+min_val)  		-- ????
			then	
				next_case<=HIGH;
			else
				next_case<=LOW;
		end if;
		
	when LOW =>
		if counter<max_val  	--???
			then
				next_case<=LOW;
			else
				next_case<=RDY;
		end if;
	end case;
end process next_case_log;

WITH actual_case SELECT 
counter_next<=(others => '0')WHEN RDY,
					counter+1     WHEN others; 
				
				
WITH actual_case SELECT
pwm_next_sig<= '0' WHEN RDY,
					'1' WHEN INIT,
					'1' WHEN HIGH,
					'0' WHEN LOW;
		
		
modulo:process(src_clk,reset)

variable x: integer range 1023 downto 0 := 0;
variable q: STD_LOGIC:= '0';

begin
if src_clk'event and src_clk='1' then
	if x<div_value then 							--- n ??????
		x:=x+1;
		q:=q;
	else
		x:=0;
		q:=not(q);
	end if;
	q_clk<=q;
end if;

end process modulo;
pwm_out<=pwm_next_sig;
end Behavioral;

