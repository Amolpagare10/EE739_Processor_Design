library IEEE;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all; 
library work;
use work.Gates.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Libraries

entity Pipeline is
    port (
        -- Input
        clock, reset, reset_im, reset_dm: in std_logic;
        -- Output: register file state for debugging/observation
        out_temp_r0, r0, R1, R2, R3, R4, R5, R6, R7: out std_logic_vector(15 downto 0)
    );
end Pipeline;

architecture bhv of Pipeline is
-------------------------------------------------------------------------------------------
-- ALL Component instantiation
    component Adder_16bit is
        port (
        A: in std_logic_vector(15 downto 0);
        B: in std_logic_vector(15 downto 0);
        X: out std_logic_vector(15 downto 0)); 
    end component;
   
	 
    component temp_reg is
        port(
            clock, reset: in std_logic; 
            temp_r0_d : in std_logic_vector(15 downto 0);
            temp : out std_logic_vector(15 downto 0);
            temp_W : in std_logic);
    end component;

    component alu is
        port (
        A: in std_logic_vector(15 downto 0);
        B: in std_logic_vector(15 downto 0);
		  Car: in std_logic_vector(15 downto 0);
        sel: in std_logic_vector(1 downto 0);
        X: out std_logic_vector(15 downto 0);
        alu_carry,alu_zero: out std_logic
        );
    end component;
    
    -- component p1_reg is 
	-- port(
	-- 	 clock,P1_DB,p1_w,reset: in std_logic;
	-- 	 P1_PC,P1_IR : in std_logic_vector(15 downto 0);
	-- 	 P1_out: out std_logic_vector(32 downto 0));
    -- end component;
    
	-- component p2_reg is 
	-- port(
	-- 	 p2_w,clock,reset : in std_logic;
	-- 	  Op_code_stg2: in std_logic_vector(3 downto 0); --(41 downto 38)
	-- 	  Ra,Rb,Rc,last_3: in std_logic_vector(2 downto 0);  --(37 downto 35), (34 downto 32), (31 downto 29), (19 downto 17)
	-- 	  Immi: in std_logic_vector(8 downto 0);  --(28 downto 20)
	-- 	  PC_in_stg2: in std_logic_vector(15 downto 0); --(15 downto 0)
	-- 	  data_bit: in std_logic; --(16)
	-- 	  p2_out: out std_logic_vector(41 downto 0));
	-- end component;

      component p3_reg is 
	port(
	    p3_w,clock,Databit_stg3,reset : in std_logic;
		 Ra_val,Rb_val: in std_logic_vector(15 downto 0); --(41 downto 38)
		 Save_add,last_3_stg3: in std_logic_vector(2 downto 0); 
         Op_code_stg3: in std_logic_vector(3 downto 0); --(37 downto 35), (34 downto 32), (31 downto 29), (19 downto 17)
		 Immedi: in std_logic_vector(15 downto 0);  --(28 downto 20)
		 Pc_imm2,PC_Stg3: in std_logic_vector(15 downto 0);
		 p3_out: out std_logic_vector(90 downto 0));
    end component;
	 
	  
    component P4_Reg is port(
	    p4_w,clock,reset : in std_logic;
		 hazardbit_4: in std_logic; --(55)
		 Ra_data: in std_logic_vector(15 downto 0);  --(54 downto 37)
		 Alu_out: in std_logic_vector(15 downto 0);  --(38 downto 23)
		 Ra_Rc: in std_logic_vector(2 downto 0);  --(22 downto 20)
		 PC_in: in std_logic_vector(15 downto 0); --(19 downto 4)
		 Op_code: in std_logic_vector(3 downto 0); --(3 downto 0)
		 stopbit,databit: in std_logic;
		 p4_out: out std_logic_vector(57 downto 0));
     end component;
	  	  
   component p5_reg is 
	port(
	    p5_w,clock,hazardbit_stg5,reset : in std_logic;
		 reg_val_stg5: in std_logic_vector(15 downto 0); 
		 reg_add_stg5: in std_logic_vector(2 downto 0); 
         opcode_stg5: in std_logic_vector(3 downto 0); --(37 downto 35), (34 downto 32), (31 downto 29), (19 downto 17)
		 count_stg5: in std_logic_vector(2 downto 0);  --(28 downto 20)
		 pc_stg5: in std_logic_vector(15 downto 0);
		  stopbit,databit: in std_logic;
		 p5_out: out std_logic_vector(44 downto 0));
   end component;
	
	 
 component register_file is 
	port(
		 clock, RF_W, RF_W_pc, reset : in std_logic;
		 A_rega, A_regb,A_s6 : in std_logic_vector(2 downto 0);
		 D_s6,D_pc_write : in std_logic_vector(15 downto 0);
		 D_pc, D_rega,D_regb: out std_logic_vector(15 downto 0);
         R_out: out std_logic_vector(127 downto 0));
  end component;
	

    component instr_memory is 
        port(
            M_add_i: in std_logic_vector(15 downto 0);
            M_inp_i: in std_logic_vector(15 downto 0);
            clock,reset, Mem_W_i : in std_logic;
            M_data_i : out std_logic_vector(15 downto 0)
            );	 
    end component;

    component data_memory is 
    port(
        M_add: in std_logic_vector(15 downto 0);
         M_inp: in std_logic_vector(15 downto 0);
         clock,reset, Mem_W : in std_logic;
        M_data : out std_logic_vector(15 downto 0)
        );	 
    end component;



	component lmsm_controller is 
	port(
		  Imm: in std_logic_vector(7 downto 0);
		 Ra: in std_logic_vector(15 downto 0);
		 ctrl_s4: in std_logic;
		 clock: in std_logic;
		  Dptr : out std_logic_vector(15 downto 0);
		 Rx_to_load_store : out std_logic_vector(2 downto 0);
		 count : out std_logic_vector(2 downto 0)
		 );	 
	end component;

	component pipeline_controller is
		port (
			  clock: in std_logic;
			  cd4,cd5,cd6:in std_logic;
			  db_stg3,db_stg4,db_stg5:in std_logic;
					count: in std_logic_vector(2 downto 0);
					opc_stg3: in std_logic_vector(3 downto 0);
					opc_stg4: in std_logic_vector(3 downto 0);
					opc_stg5: in std_logic_vector(3 downto 0);
					opc_stg6: in std_logic_vector(3 downto 0);
	-- Control pins from BrPred,RF_read,Execute_Stage
	-- Final Output to be given to PC_new of Next stage to be written to R0 of RF;
		 PC_start: out std_logic;
		P1: out std_logic;
		 P2: out std_logic
		 );
	end component ;

-------------------------------------------------------------------------------------------------------------------	
signal p4_w,hazardbit_4:std_logic:='0';
signal Ra_data: std_logic_vector(15 downto 0) := (others => '0');  --(54 downto 37)
signal Alu_out:  std_logic_vector(15 downto 0) := (others => '0');  --(38 downto 23)
signal Ra_Rc:  std_logic_vector(2 downto 0) := (others => '0');  --(22 downto 20)
signal PC_in: std_logic_vector(15 downto 0) := (others => '0'); --(19 downto 4)
signal Op_code: std_logic_vector(3 downto 0):= (others => '0'); --(3 downto 0)
signal p4_out: std_logic_vector(57 downto 0) := (others => '0');
signal p5_out: std_logic_vector(44 downto 0) := (others => '0');

signal cd4,cd5,cd6: std_logic:='0';
signal db_stg3,db_stg4,db_stg5:std_logic:='0';
signal opc_stg3: std_logic_vector(3 downto 0):= (others => '0');
signal opc_stg4: std_logic_vector(3 downto 0):= (others => '0');
signal opc_stg5: std_logic_vector(3 downto 0):= (others => '0');
signal opc_stg6: std_logic_vector(3 downto 0):= (others => '0');

signal alu_Stg_1_A: std_logic_vector(15 downto 0) := (others => '0');
signal alu_Stg_1_B: std_logic_vector(15 downto 0) := (others => '0');

signal alu_Stg_1_C: std_logic_vector(15 downto 0) := (others => '0');
signal Br_Pred: std_logic_vector(15 downto 0) := (others => '0');
signal BrVal_Stg_3: std_logic_vector(15 downto 0) := (others => '0');
signal BrVal_Stg_4: std_logic_vector(15 downto 0) := (others => '0');

signal CStg_4: std_logic := '0' ;
signal CStg_3: std_logic := '0' ;
signal CStg_1: std_logic := '0' ;

signal Branch_MUX_out: std_logic_vector(15 downto 0) := (others => '0');

signal RF_W_pc: std_logic:='0'; 
signal D_pc_write: std_logic_vector(15 downto 0) := (others => '0');
signal D_pc: std_logic_vector(15 downto 0) := (others => '0');

signal Mem_W_i: std_logic:='0'; 
signal M_add_i: std_logic_vector(15 downto 0) := (others => '0');
signal M_inp_i: std_logic_vector(15 downto 0) := (others => '0');
signal M_data_i: std_logic_vector(15 downto 0) := (others => '0');

--signal CStg_1: std_logic:='0';
signal Databit: std_logic:='0';
signal PC_in_Stg_1: std_logic_vector(15 downto 0) := (others => '0'); 
signal PC_out: std_logic_vector(15 downto 0) := (others => '0');
signal Stop_signal: std_logic;


signal PC_start: std_logic:='1';
signal P1:std_logic:='1'; -- some stage ahead might prompt it to stop;
-- might have to use a controller later;
signal P1_DB:std_logic:='0';
signal P1_w:std_logic:='0';
signal P1_PC: std_logic_vector(15 downto 0) := (others => '0'); 
signal P1_IR: std_logic_vector(15 downto 0) := (others => '0'); 
signal P1_out: std_logic_vector(32 downto 0) := (others => '0'); 

signal p2: std_logic:='1';
signal p2_w: std_logic:='0';
signal Op_code_stg2: std_logic_vector(3 downto 0) := (others => '0');  --(41 downto 38)
signal Ra,Rb,Rc,last_3: std_logic_vector(2 downto 0) := (others => '0');   --(37 downto 35), (34 downto 32), (31 downto 29), (19 downto 17)
signal Immi: std_logic_vector(8 downto 0) := (others => '0');   --(28 downto 20)
signal PC_in_stg2: std_logic_vector(15 downto 0) := (others => '0'); --(15 downto 0)
signal data_bit: std_logic:='0'; --(16)
signal p2_out: std_logic_vector(41 downto 0)  := (others => '0'); 
signal stopbit_s5,databit_s5: std_logic;
signal stopbit_s4,databit_s4 : std_logic;

signal alu_Stg_3_A: std_logic_vector(15 downto 0) := (others => '0');
signal alu_Stg_3_B: std_logic_vector(15 downto 0) := (others => '0');
signal alu_Stg_3_C: std_logic_vector(15 downto 0) := (others => '0');

signal A_rega: std_logic_vector(2 downto 0) := (others => '0');
signal A_regb: std_logic_vector(2 downto 0) := (others => '0');
signal D_rega: std_logic_vector(15 downto 0) := (others => '0');
signal D_regb: std_logic_vector(15 downto 0) := (others => '0');

signal RF_out_A: std_logic_vector(15 downto 0):= (others => '0');
signal D_val4_A: std_logic_vector(15 downto 0):= (others => '0');
signal D_val5_A: std_logic_vector(15 downto 0):= (others => '0');
signal D_val6_A: std_logic_vector(15 downto 0):= (others => '0');
-- Control pins from BrPred,RF_read,Execute_Stage
signal DStg_4_A: std_logic:= '0';
signal DStg_5_A: std_logic:= '0';
signal DStg_6_A: std_logic:= '0';
-- Final Output to be given to PC_new of Next stage to be written to R0 of RF;
signal Dependency_MUX_out_A: std_logic_vector(15 downto 0);

signal RF_out_B: std_logic_vector(15 downto 0):= (others => '0');
signal D_val4_B: std_logic_vector(15 downto 0):= (others => '0');
signal D_val5_B: std_logic_vector(15 downto 0):= (others => '0');
signal D_val6_B: std_logic_vector(15 downto 0):= (others => '0');
    -- Control pins from BrPred,RF_read,Execute_Stage
signal DStg_4_B: std_logic:= '0';
signal DStg_5_B: std_logic:= '0';
signal DStg_6_B: std_logic:= '0';
    -- Final Output to be given to PC_new of Next stage to be written to R0 of RF;
signal Dependency_MUX_out_B: std_logic_vector(15 downto 0);
signal  p3 : std_logic:='1';
signal  p3_w,Databit_stg3 : std_logic:='0';
signal  Ra_val,Rb_val: std_logic_vector(15 downto 0):= (others => '0'); --(41 downto 38)
signal  Save_add,last_3_stg3: std_logic_vector(2 downto 0):= (others => '0');
signal  Op_code_stg3: std_logic_vector(3 downto 0):= (others => '0'); --(37 downto 35), (34 downto 32), (31 downto 29), (19 downto 17)
signal  Immedi: std_logic_vector(15 downto 0):= (others => '0');  --(28 downto 20)
signal  Pc_imm2,PC_Stg3: std_logic_vector(15 downto 0):= (others => '0');
signal  p3_out: std_logic_vector(90 downto 0):= (others => '0');

signal alu_ex_A: std_logic_vector(15 downto 0) := (others => '0');
signal alu_ex_B: std_logic_vector(15 downto 0) := (others => '0');
signal alu_ex_C: std_logic_vector(15 downto 0) := (others => '0');
signal alu_ex_Car: std_logic_vector(15 downto 0) := (others => '0');
signal Sel_ex: std_logic_vector(1 downto 0) := (others => '0');
signal alu_carry,alu_zero: std_logic:='0';

signal Address_Stg3_A_4: std_logic_vector(2 downto 0) := (others => '0');
signal Address_Stg3_B_4: std_logic_vector(2 downto 0) := (others => '0');
signal Address_Stg_4: std_logic_vector(2 downto 0) := (others => '0');
--signal hazardbit_4: std_logic:='0';
signal sel_A_4: std_logic:='0';
signal sel_B_4: std_logic:='0';

signal WriteBit: std_logic:='0';  
signal Condition: std_logic:='0';
signal Update: std_logic:='0';  
signal PC_in_Stg_4: std_logic_vector(15 downto 0) := (others => '0');
signal Branch_to: std_logic_vector(15 downto 0) := (others => '0');
signal Op_codebpred:std_logic_vector(3 downto 0):=(others =>'0');
signal global_carry:std_logic:='0';
signal global_zero:std_logic:='0';

signal Address_Stg3_A_5: std_logic_vector(2 downto 0) := (others => '0');
signal Address_Stg3_B_5: std_logic_vector(2 downto 0) := (others => '0');
signal Address_Stg_5: std_logic_vector(2 downto 0) := (others => '0');
signal hazardbit_5: std_logic:='0';
signal sel_A_5: std_logic:='0';
signal sel_B_5: std_logic:='0';

signal M_add: std_logic_vector(15 downto 0) := (others => '0');
signal M_inp: std_logic_vector(15 downto 0) := (others => '0');
signal M_data: std_logic_vector(15 downto 0) := (others => '0');
signal Mem_W:std_logic:='0';

-- LM_block;
signal Imm: std_logic_vector(7 downto 0) := (others => '0');
signal Ra_mem: std_logic_vector(15 downto 0) := (others => '0');
signal Ctrl_s4:std_logic:='0';
signal Dptr: std_logic_vector(15 downto 0) := (others => '0');
signal Rx_to_load_store: std_logic_vector(2 downto 0) := (others => '0');
signal count: std_logic_vector(2 downto 0) := (others => '0');

-- memory;
-- 43bits
signal p5_w:std_logic:='0';
signal count_stg5: std_logic_vector(2 downto 0):=(others =>'0');  --3 bit 42 41 40
signal opcode_stg5: std_logic_vector(3 downto 0):=(others =>'0'); --4 bit 39 downto 36
signal reg_val_stg5 : std_logic_vector(15 downto 0):=(others =>'0'); --16 bit
signal reg_add_stg5: std_logic_vector(2 downto 0):=(others =>'0'); --3 bit
signal hazardbit_stg5: std_logic:='0'; --1 bit
signal pc_stg5: std_logic_vector(15 downto 0):=(others =>'0');  --16 bit
--signal p5_out:std_logic_vector(42 downto 0):=(others =>'0');

signal temp :std_logic_vector(15 downto 0):= (others => '0');
signal temp_r0_d  :std_logic_vector(15 downto 0):= (others => '0');
signal temp_w : std_logic:='0'; --1 bit

--Stage-6
signal Address_Stg3_A_6: std_logic_vector(2 downto 0) := (others => '0');
signal Address_Stg3_B_6: std_logic_vector(2 downto 0) := (others => '0');
signal Address_Stg_6: std_logic_vector(2 downto 0) := (others => '0');
signal hazardbit_6: std_logic:='0';
signal sel_A_6: std_logic:='0';
signal sel_B_6: std_logic:='0';

--stage-6
signal RF_W: std_logic:='0';
signal A_s6: std_logic_vector(2 downto 0) := (others => '0');
signal D_s6: std_logic_vector(15 downto 0) := (others => '0');
signal R_out: std_logic_vector(127 downto 0); 
----------------------------------------------------------------------------------------------------------
begin
    -- signals for output
	 
 out_temp_r0 <= temp_r0_d;
 R0 <= R_out(15 downto 0);
 R1 <= R_out(31 downto 16);
 R2 <= R_out(47 downto 32);
 R3 <= R_out(63 downto 48);
 R4 <= R_out(79 downto 64);
 R5 <= R_out(95 downto 80);
 R6 <= R_out(111 downto 96);
 R7 <= R_out(127 downto 112);
	 
adder_Stg1: Adder_16bit port map (alu_Stg_1_A,alu_Stg_1_B,alu_Stg_1_C);
-- For PC+2 in Stage 1;
-- Stage 3 for PC+IMM*2;

Rfile: register_file port map (clock, RF_W, RF_W_pc,reset,A_rega, A_regb,A_s6,D_s6,D_pc_write,D_pc, D_rega,D_regb,R_out);
-- Register file 

IMem:instr_memory port map(M_add_i,M_inp_i,clock,reset_im, Mem_W_i,M_data_i);
-- Instruction Memory 

--------------------------------------------- Pipeline Registers--------------------------------------------------------------------------
pipeline3: p3_reg port map(p3_w,clock,Databit_stg3,reset,Ra_val,Rb_val,Save_add,last_3_stg3,Op_code_stg3,Immedi,Pc_imm2,PC_Stg3,p3_out);
pipeline4:p4_reg port map(p4_w,clock,reset,hazardbit_4,Ra_data,Alu_out, Ra_Rc,PC_in,Op_code,stopbit_s4,databit_s4,p4_out);
pipeline_reg5:p5_reg port map (p5_w,clock,hazardbit_stg5,reset,reg_val_stg5,reg_add_stg5,opcode_stg5,count_stg5,pc_stg5,stopbit_s5,databit_s5,p5_out);
-------------------------------------------------------------------------------------------------------------------------------------------------------

adder_PC_2IMM: Adder_16bit port map(alu_Stg_3_A,alu_Stg_3_B,alu_Stg_3_C);

t_reg0:temp_reg port map(clock,reset,temp_r0_d,temp,temp_W);

alu_main: alu port map(alu_ex_A,alu_ex_B,alu_ex_Car,Sel_ex,alu_ex_C,alu_carry,alu_zero);

Dmem: data_memory port map(M_add,M_inp,clock,reset,mem_W,M_data);
lmsm_block:lmsm_controller port map(Imm,Ra_mem,ctrl_s4,clock,Dptr,Rx_to_load_store,count);
pipController: pipeline_controller port map(clock,cd4,cd5,cd6,db_stg3,db_stg4,db_stg5,count,opc_stg3,opc_stg4,opc_stg5,opc_stg6,PC_start,P1,P2);


--------------------------------------------------------------------------------------------------------------------------------------------------

-- Instruction_Fetch: process(clock,reset)
-- begin
-- if (reset = '0') then
    
--     if(rising_edge(clock)) then
-- 	     P1_w<='0';
-- 		  RF_w_pc<='0';
-- 		  -- by default the writing control signals are off 
--         if(PC_start='1')  then
       
-- 							  M_add_i<=D_pc;  -- programmer Counter points to the instruction memory 
-- 							  P1_PC<=D_pc; -- pipeline reg-1  
-- 							  PC_in_Stg_1<=D_pc; -- Point to get the Branch value if needed 
-- 							  P1_IR<=M_data_i; -- Save the IR to Pipeline Reg 1 
							  
-- 							  alu_Stg_1_A<=D_pc;
-- 							  alu_Stg_1_B<="0000000000000010"; 
-- 							     -- Input to Adder 
-- 							  Br_Pred<=PC_out; -- connect Pc_out of branch predictor to brPred named variable of MUX;
-- 							  P1_DB<=Databit;
-- 							  -- passing the Databit ahead
							  
-- 							  P1_w<='1';
-- 							  D_pc_write<=Branch_MUX_out;
-- 							  RF_w_pc<='1';
        
--         end if;
-- end if;
-- end if;
-- end process;


-- --------------------------------------------------------------------------------------------------------------------------------------------------

-- Decode: process(clock,reset)
-- begin
-- if (reset = '0') then
-- if(rising_edge(clock)) then
--      p2_w<='0';
-- 	  -- the pipeline reg-2 is off by default 
--     if (P1='1') then 
-- 	 -- Stage-2 execution signal 
-- 						 PC_in_stg2 <= p1_out(32 downto 17);
-- 						 Op_code_stg2 <= p1_out(16 downto 13); 
-- 						 -- filling the pipeline register
-- 						 Ra <= p1_out(12 downto 10);
-- 						 Rb <= p1_out(9 downto 7);
-- 						 Rc <= p1_out(6 downto 4);
-- 						  -- Register addresses
-- 						 Immi <= p1_out(9 downto 1); 
-- 						  -- Immediate values
-- 						 last_3 <= p1_out(3 downto 1);
-- 						 data_bit <= p1_out(0);
-- 						  -- move divisions 
-- 						 p2_w <= '1';
						  
-- 						  if(Op_code_stg2="0110" or Op_code_stg2="0111") then
-- 							  if(count= "000") then
-- 											Imm<=Immi(7 downto 0); 
-- 							  end if;
-- 						  end if;  
--      end if;
-- 	  end if;
-- end if;

-- end process;


-- --------------------------------------------------------------------------------------------------------------------------------------------------

-- RegF_Read: process(clock,reset)
-- begin
-- if (reset = '0') then
--     if (rising_edge(clock)) then
-- 	       p3_w <= '0';
-- 			 if(CStg_3='1') then 
-- 					CStg_3<='0';
-- 			  end if;
			 
--         if(P2='1') then
--             db_stg3<=p2_out(16); --SM
-- 				-- if the PC is found in database then that is set as 1 ;
--             opc_stg3<=p2_out(41 downto 38);
-- 				-- Op_Code
-- 		      if(p2_out(41 downto 38)="0111") then 

-- 				  A_rega<=p2_out(37 downto 35);
-- 				  -- RegA address
-- 				  Address_Stg3_A_4<=p2_out(37 downto 35);
-- 				  Address_Stg3_A_5<=p2_out(37 downto 35);
-- 				  Address_Stg3_A_6<=p2_out(37 downto 35);
-- 				  -- Sending the Address to Hazard Detector 
-- 						if(p2_out(37 downto 35)="000") then
-- 							 RF_out_A<=temp;
-- 						else
-- 							 RF_out_A<=D_rega;   
-- 						end if;
--                   -- if the address is of R0 then the value is fetched from Temp register

-- 						Ra_mem<=Dependency_MUX_out_A;
-- 						-- Value from the Dependency MUX;
-- 						A_regb<=Rx_to_load_store;
-- 						-- In case of lmsm block 
-- 						Address_Stg3_B_4<=Rx_to_load_store;
-- 						Address_Stg3_B_5<=Rx_to_load_store;
-- 						Address_Stg3_B_6<=Rx_to_load_store;
-- 						-- Another address goes from Rx to load store;
						
-- 						if(Rx_to_load_store="000") then
-- 							 RF_out_B<=temp;
-- 						else
-- 							 RF_out_B<=D_regB;
-- 						end if;

							
-- 					  Rb_val<=Dependency_MUX_out_B;
--                  -- Final value from Rb_val;
-- 					  PC_Stg3<=p2_out(15 downto 0);
-- 					  -- PC in this stage
-- 					  Op_code_stg3<= p2_out(41 downto 38);
-- 					  -- Opcode passed ahead
-- 					  p3_w<='1';


-- 					elsif (p2_out(41 downto 38)="0110") then 
-- 																	--LM

-- 							 A_rega<=p2_out(37 downto 35);
-- 							 -- to get the address from where to start point 
-- 							 Address_Stg3_A_4<=p2_out(37 downto 35);
-- 							 Address_Stg3_A_5<=p2_out(37 downto 35);
-- 							 Address_Stg3_A_6<=p2_out(37 downto 35);
-- 							 -- to hazard detector
							 
-- 							 if(p2_out(37 downto 35)="000") then
-- 								  RF_out_A<=temp;
-- 							 else
-- 								  RF_out_A<=D_rega;   
-- 							 end if;
							 
-- 							 Ra_mem<=Dependency_MUX_out_A;
-- 							 -- Get the Ra address from where to start pointing in Memory
-- 							 Op_code_stg3<= p2_out(41 downto 38);
-- 							 PC_Stg3<=p2_out(15 downto 0);
-- 							 p3_w<='1';


-- 			 elsif (p2_out(41 downto 38)="0101") then  
-- 																	-- SW
--                 -- send this address of Ra and Rb into hazard detector of st4,5,6; and use the Dependency MUX to get the correct value;
-- 						  A_regb<=p2_out(34 downto 32);
-- 						  A_rega<=p2_out(37 downto 35);
-- 						  -- Get the Address to point
-- 						  Address_Stg3_A_4<=p2_out(37 downto 35);
-- 						  Address_Stg3_A_5<=p2_out(37 downto 35);
-- 						  Address_Stg3_A_6<=p2_out(37 downto 35);
-- 						  -- Hazard detector 1 address input
-- 						  if(p2_out(37 downto 35)="000") then
-- 								RF_out_A<=temp;
-- 						  else
-- 								RF_out_A<=D_rega;   
-- 						  end if;
						  
-- 						  Address_Stg3_B_4<=p2_out(34 downto 32);
-- 						  Address_Stg3_B_5<=p2_out(34 downto 32);
-- 						  Address_Stg3_B_6<=p2_out(34 downto 32);
-- 						  -- hazard detector 2 address
-- 						  if(p2_out(34 downto 32)="000") then
-- 								RF_out_B<=temp;
-- 						  else
-- 								RF_out_B<=D_regb;   
-- 						  end if;
						  
-- 						  Ra_val<=Dependency_MUX_out_A;
-- 						  Rb_val<=Dependency_MUX_out_B;
-- 						   -- Value to be passed ahead
							
-- 						  Op_code_stg3<= p2_out(41 downto 38);
-- 						  PC_Stg3<=p2_out(15 downto 0);
-- 						  Immedi<=p2_out(25)&p2_out(25)&p2_out(25)&p2_out(25)&p2_out(25)&p2_out(25)&p2_out(25)&p2_out(25)&p2_out(25)&p2_out(25)&p2_out(25 downto 20);
-- 						  p3_w<='1';
						  
-- 						  -- pass on  Ra[address] , Rb  and PC and OpCode


-- 				elsif (p2_out(41 downto 38)="0100") then 
-- 							  -- LW
-- 										 A_regb<=p2_out(34 downto 32);
-- 										 -- get the Rb value
-- 										 Address_Stg3_B_4<=p2_out(34 downto 32);
-- 										 Address_Stg3_B_5<=p2_out(34 downto 32);
-- 										 Address_Stg3_B_6<=p2_out(34 downto 32);
-- 										 -- hazard detector input
-- 										 if(p2_out(34 downto 32)="000") then
-- 											  RF_out_B<=temp;
-- 										 else
-- 											  RF_out_B<=D_regb;   
-- 										 end if;
-- 										  -- value of R0 
-- 										 Rb_val<=Dependency_MUX_out_B;
-- 										 -- Rb value 
-- 										 PC_Stg3<=p2_out(15 downto 0);
-- 										 Op_code_stg3<= p2_out(41 downto 38);
-- 										 Save_add<=p2_out(37 downto 35);
-- 										 p3_w<='1';

-- 				elsif (p2_out(41 downto 38)="0111" or p2_out(41 downto 38)="0010") then 
-- 							  -- ADA, ADC, ADZ,AWC,ACA,ACC,ACZ,ACW,
-- 							   --NDU,NDC,NDZ,NCU,NCC,NCZA_regb <=p2_out(34 downto 32);
-- 											A_regb<=p2_out(34 downto 32);
-- 											A_rega<=p2_out(37 downto 35);
											
-- 											Address_Stg3_A_4<=p2_out(37 downto 35);
-- 											Address_Stg3_A_5<=p2_out(37 downto 35);
-- 											Address_Stg3_A_6<=p2_out(37 downto 35);
											
-- 											if(p2_out(37 downto 35)="000") then
-- 												 RF_out_A<=temp;
-- 											else
-- 												 RF_out_A<=D_rega;   
-- 											end if;
											
-- 											Address_Stg3_B_4<=p2_out(34 downto 32);
-- 											Address_Stg3_B_5<=p2_out(34 downto 32);
-- 											Address_Stg3_B_6<=p2_out(34 downto 32);
											
-- 											if(p2_out(34 downto 32)="000") then
-- 												 RF_out_B<=temp;
-- 											else
-- 												 RF_out_B<=D_regb;   
-- 											end if;
											
-- 											Ra_val<=Dependency_MUX_out_A;
-- 											Rb_val<=Dependency_MUX_out_B;
-- 											-- Register addresses 
-- 											Op_code_stg3<= p2_out(41 downto 38);
-- 											Save_add<=p2_out(31 downto 29);
-- 											PC_Stg3<=p2_out(15 downto 0);
-- 											last_3_stg3<=p2_out (19 downto 17);
-- 											p3_w<='1';
							  
-- 			elsif (p2_out(41 downto 38)="0001") then 
-- 							  --ADI, 
-- 									A_rega<=p2_out(37 downto 35);
-- 									Address_Stg3_A_4<=p2_out(37 downto 35);
-- 									Address_Stg3_A_5<=p2_out(37 downto 35);
-- 									Address_Stg3_A_6<=p2_out(37 downto 35);
									
-- 									if(p2_out(37 downto 35)="000") then
-- 										 RF_out_A<=temp;
-- 									else
-- 										 RF_out_A<=D_rega;   
-- 									end if;
									
-- 									Op_code_stg3<=p2_out(41 downto 38);
-- 									Save_add<=p2_out(34 downto 32);
-- 									PC_Stg3<=p2_out(15 downto 0);
-- 									Immedi<=p2_out(25)&p2_out(25)&p2_out(25)&p2_out(25)&p2_out(25)&p2_out(25)&p2_out(25)&p2_out(25)&p2_out(25)&p2_out(25)&p2_out(25 downto 20);
									
-- 									p3_w<='1';

							 	  
-- 		   elsif (p2_out(41 downto 38)="0011") then 
-- 							  --LLI,
-- 										 Op_code_stg3 <= p2_out(41 downto 38);
-- 										 Save_add     <= p2_out(37 downto 35);
-- 										 PC_Stg3      <= p2_out(15 downto 0);
-- 										 Immedi<="0000000" & p2_out(28 downto 20);
-- 										 p3_w<='1';
--                            -- Load lower 7 bits 
														
-- 			 elsif (p2_out(41 downto 38)="1001" or p2_out(41 downto 38)="1010" or p2_out(41 downto 38)="1000" ) then 
-- 							-- BLT -- BLE  -- BEQ
-- 							--{Nothing Special just fetch the instruction update PC}
-- 							-- BLT 
-- 							A_regb<=p2_out(34 downto 32);
-- 							A_rega<=p2_out(37 downto 35);
							
-- 							Address_Stg3_A_4<=p2_out(37 downto 35);
-- 							Address_Stg3_A_5<=p2_out(37 downto 35);
-- 							Address_Stg3_A_6<=p2_out(37 downto 35);
-- 							if(p2_out(37 downto 35)="000") then
-- 								 RF_out_A<=temp;
-- 							else
-- 								 RF_out_A<=D_rega;   
-- 							end if;
							
-- 							Address_Stg3_B_4<=p2_out(34 downto 32);
-- 							Address_Stg3_B_5<=p2_out(34 downto 32);
-- 							Address_Stg3_B_6<=p2_out(34 downto 32);
-- 							if(p2_out(34 downto 32)="000") then
-- 								 RF_out_B<=temp;
-- 							else
-- 								 RF_out_B<=D_regb;   
-- 							end if;
							
-- 							Ra_val<=Dependency_MUX_out_A;
-- 							Rb_val<=Dependency_MUX_out_B;
-- 							PC_Stg3 <= p2_out(15 downto 0);
-- 							Op_code_stg3<=p2_out(41 downto 38);
-- 							Databit_stg3<=p2_out(16);
-- 							-- Databit ,Opcode is  passed ahead
-- 							alu_Stg_3_A<= p2_out(15 downto 0);
-- 							alu_Stg_3_B<= p2_out(27)&p2_out(27)&p2_out(27)&p2_out(27)&p2_out(27)&p2_out(27)&p2_out(27)&p2_out(27 downto 20)&'0';
-- 							Pc_imm2<=alu_Stg_3_C;
-- 							p3_w<='1';
-- 							-- Fetch correct RegA and RegB values devoid of hazards and pass to  PC-3: PC+2*IMM,PC,RegA,RegB,OP_code
										
							  
-- 		    elsif (p2_out(41 downto 38)="1100") then 
-- 									-- JAL
-- 									-- in case of JAL 
-- 									PC_Stg3 <= p2_out(15 downto 0);
-- 									Op_code_stg3 <= p2_out(41 downto 38);
-- 									alu_Stg_3_A<= p2_out(15 downto 0);
-- 									alu_Stg_3_B<= p2_out(27)&p2_out(27)&p2_out(27)&p2_out(27)&p2_out(27)&p2_out(27)&p2_out(27)&p2_out(27 downto 20)&'0';
-- 									Pc_imm2 <= alu_Stg_3_C;
-- 									Databit_stg3<=p2_out(16);
-- 									-- if DB was zero then compute the below and let it branch 
-- 									-- Save this value for this particular PC and PC+2*IMM9 in the next stage while writing
-- 									-- Do Cstg3<=1;
-- 									p3_w<='1';
-- 									if(p2_out(16)='0') then 
-- 										 CStg_3<='1';
-- 									end if;
							  
-- 		  elsif (p2_out(41 downto 38)="1101") then 
-- 							  -- For Unconditional Jumps JLR and JRI 
-- 							  -- JLR 
-- 									A_regb<=p2_out(34 downto 32);
-- 									Address_Stg3_B_4<=p2_out(34 downto 32);
-- 									Address_Stg3_B_5<=p2_out(34 downto 32);
-- 									Address_Stg3_B_6<=p2_out(34 downto 32);
-- 							  if(p2_out(34 downto 32)="000") then
-- 							  RF_out_B<=temp;
-- 								 else
-- 									  RF_out_B<=D_regb;   
-- 								 end if;
							  
-- 									Rb_val<=Dependency_MUX_out_B;
-- 									Op_code_stg3<=p2_out(41 downto 38);
-- 									Save_add<=p2_out(37 downto 35);
-- 									PC_Stg3<=p2_out(15 downto 0);
-- 									p3_w<='1';
							  
-- 							  -- Fetch the correct RegB value pass OP_Code and Reg_A address
																			  
-- 		   elsif (p2_out(41 downto 38)="1111") then 
-- 																	-- JRI
-- 								 A_rega<=p2_out(37 downto 35);
-- 								 Address_Stg3_A_4<=p2_out(37 downto 35);
-- 								 Address_Stg3_A_5<=p2_out(37 downto 35);
-- 								 Address_Stg3_A_6<=p2_out(37 downto 35);
							
-- 									 if(p2_out(37 downto 35)="000") then
-- 											RF_out_A<=temp;
-- 									  else
-- 											RF_out_A<=D_rega;   
-- 									  end if;
							
-- 								 Ra_val<=Dependency_MUX_out_A;
-- 								 Immedi<=p2_out(27)&p2_out(27)&p2_out(27)&p2_out(27)&p2_out(27)&p2_out(27)&p2_out(27)&p2_out(27 downto 20)&'0';
-- 								 Op_code_stg3<=p2_out(41 downto 38);
-- 								 Databit_stg3<=p2_out(16);
-- 								 PC_Stg3<=p2_out(15 downto 0);
-- 								 p3_w<='1'; 
							
-- 							-- Fetch the correct RegA value and Imm should be passed along with Op_code and RegA value;
-- 							-- op_code,
							
-- 		  else 
-- 			 Null;
-- 			end if;	 
        
-- 		  end if;
-- 		  end if;
-- 		  end if;
-- end process;


--------------------------------------------------------------------------------------------------------------------------------------------------

Execute: process(clock,reset)
begin
if (reset = '0') then
if (rising_edge(clock)) then
      if(CStg_4='1') then 
			CStg_4<='0';
		end if;
          p4_w<='0';  
	       Update<='0';
            
if(P3='1') then
       hazardbit_4<='0';
									 
        if(p3_out(7 downto 4) ="0111"  or p3_out(7 downto 4) ="0110") then 
           if(p3_out(7 downto 4)=p4_out(3 downto 0)) then 
                 ctrl_s4<='0';
              else
                 ctrl_s4<='1';    
           end if;
        end if;
			Op_codebpred<= p3_out(7 downto 4);
			WriteBit <= p3_out(0);    --databit
		   PC_in_Stg_4 <= p3_out(23 downto 8);    --PC	
			
			           case p3_out(7 downto 4) is                  --on the basis of opcode
							  when "0001" =>              --ADD
									alu_ex_A <= p3_out(90 downto 75);
									if p3_out(3)='0' then          --complement bit
										alu_ex_B <= p3_out(74 downto 59);
										alu_ex_Car<= "000000000000000"&Global_carry;
									else 
										 alu_ex_B <= not p3_out(74 downto 59);
										 alu_ex_Car<= "000000000000000"&Global_carry;
									end if;
									
									if(p3_out(2 downto 1)="11") then 
										 Sel_ex <= "11";
									else
										 Sel_ex <= "00";
									end if; 
			
			
									
							  when "0010" =>              --NAND
									alu_ex_A <= p3_out(90 downto 75);
									if p3_out(3)='0' then          --complement bit
										alu_ex_B <= p3_out(74 downto 59);
										alu_ex_Car<= "000000000000000"&Global_carry;
									else 
										 alu_ex_B <= not p3_out(74 downto 59);
										 alu_ex_Car<= "000000000000000"&Global_carry;
									end if;
									
									if(p3_out(2 downto 1)="11") then 
										 Sel_ex <= "01";
									else
										 Sel_ex <= "10";
									end if; 
									
									
							  when "0000" =>                     --adi
							  alu_ex_A <= p3_out(90 downto 75);    --regA
									alu_ex_B <= p3_out(55 downto 40);
							  Sel_ex <= "00";				 
									
							  
							  when "0011" =>                     --LLI
									alu_ex_A <= p3_out(55 downto 40);
									alu_ex_B <= "0000000000000000";
									Sel_ex <= "00";
									
		 
							  when "0100" | "0101" =>            --LW,SW
									alu_ex_A <= p3_out(55 downto 40);
									alu_ex_B <= p3_out(74 downto 59);
									Sel_ex <= "00";
									
		 
							  when "1000" | "1001" | "1010" =>   --BEQ,BLT,BLE           
									alu_ex_A <= p3_out(90 downto 75);
									alu_ex_B <= p3_out(74 downto 59);
									Sel_ex <= "00";
									
							  when "1100" | "1101" =>            --JAL,JLR       
									alu_ex_A <= p3_out(23 downto 8);
									alu_ex_B <= "0000000000000010";
									Sel_ex <= "00";
									
							  when others =>
									alu_ex_A <= "0000000000000000";  -- Default case
									alu_ex_B <= "0000000000000000";
					
						 end case;
	  
	             global_carry <= alu_carry;
					 global_zero <= alu_zero;
						 
						
                if ((p3_out(7 downto 4)="0001") or (p3_out(7 downto 4)="0010")) then    --ADD,NAND
                                
							  case p3_out(2 downto 1) is 
							  
							  when "00" => 
										 Alu_out <= alu_ex_C;
										 Hazardbit_4 <= '1'; 
										 
							  when "10" => 
										 if (global_carry='1') then
											  Alu_out <= alu_ex_C;
											  Hazardbit_4 <= '1';     --confirmed that Rc is going to be written by add or nand instruction
										 end if;
									
							  when "01" => 
										 if (global_zero='1') then
											  Alu_out <= alu_ex_C;
											  Hazardbit_4 <= '1';     --confirmed that Rc is going to be written by add or nand instruction
										 end if;
									
							  when "11" => 
									Alu_out <= alu_ex_C;


									Hazardbit_4 <= '1'; 					
										 
							  when others =>
							  null;
						  end case; 
		
		
                --ADI,LLI,LW,LM,JAL,JLR
            
            else
                 case p3_out(7 downto 4) is
								 when "0000" | "0011" | "0100" | "0110" | "1100" | "1101" =>
									  Hazardbit_4 <= '1';
									  Alu_out <= alu_ex_C;
								 when others =>
									  null;
						end case;

            end if;
				
		  -- case statement for Branch_to assignment	
				case (p3_out(7 downto 4)) is 
						  
					  when "1100" | "1000" | "1001" | "1010" =>  --JAL,BEQ,BLT,BLE
								Branch_to <= p3_out(39 downto 24);      --pc_imm2
								-- Calculated value where to branch 
				 
					  when "1101" =>                         --JLR
								Branch_to <= p3_out(74 downto 59);  --regB
								--  where to point
				
					  when "1111" =>                         --JRI
								Branch_to <= Alu_out;               --Ra+imm*2	
								-- Ra+Imm*2 for Jump and Link to Register
								 
						  when others =>
						  null;
			 
			  end case; 

			opc_stg4<=p3_out(7 downto 4);	       
			-- Send op code to pipeline controller
			stopbit_s4 <= Stop_signal;
			-- send the stop signal to prompt it to stop the corresponding stages on the basis of OpCode 
			databit_s4 <= p3_out(0);      
			-- If data is present in Database then the value is 1
			db_stg4<= p3_out(0);  
			
		  --Hazard unit
			Address_Stg_4 <= p3_out(58 downto 56);     --Save Address
			-- Address where to save
			D_val4_A<= alu_out;
			D_val4_B<= alu_out;
			-- These values are going to be as value pins in the Dependency MUX
			cd4<=Stop_signal;
			-- For the Pipeline controller
			
			Ra_data <= p3_out(90 downto 75);
         Ra_Rc <= p3_out(58 downto 56);
         PC_in <= p3_out(23 downto 8);
         Op_code <= p3_out(7 downto 4);
			-- Opcode going to next stage
			
         p4_w <= '1';               
		  --Branch Predictor
        --case statement for condition assignment
		  
         case (p3_out(7 downto 4)) is     
              when "1000" =>  --BEQ
                     Condition <= global_zero;   
							Update <= '1'; 
							-- This prompts the branch predictor to update the where to branch and the history bit
          
              when "1101" | "1100" | "1111" =>        --JAL,JLR,JRI(unconditional branches)
                     Condition <= '1';  
							Update <= '1'; 
                     	-- This prompts the branch predictor to update the where to branch and the history bit
         
              when "1001" =>                --BLT                    
                     Condition <= global_carry;  
							Update <= '1'; 
								-- This prompts the branch predictor to update the where to branch and the history bit
      
              when "1010" =>                --BLE                   
                     Condition <= (global_carry or global_zero);  
							Update <= '1'; 
								-- This prompts the branch predictor to update the where to branch and the history bit
                      
				  when others =>
				  null;
       
         end case; 
			
   -- This sends a select high to the branching MUX in stage 1 
		if(Stop_signal='1') then
				case (p4_out(3 downto 0)) is 
				  when "1101" | "1100" | "1111" | "1001"| "1010" |"1000"   =>        -- JAL,JLR,JRI(unconditional branches)
										CStg_4<='1';                                       -- BEQ,BLT,BLE(conditional branches)
				  when others =>						
										CStg_4<='0';
										null;
				end case; 
		  else  
				 null;
		  end if;
end if;
end if;
end if;

end process;


--------------------------------------------------------------------------------------------------------------------------------------------------
--haz_detector stg  (Get the Rc_add from Stage-5, Get the Rc_add from Execute);
Mem_Access: process(clock)
begin
    if (reset = '0') then
        if (rising_edge(clock)) then
		       p5_w<='0';
            -- Writing in Pipeline register only at the rising edge of the clock and only if the bit is set(EN==1)
		 stopbit_s5 <= p4_out(57);
		 cd5<=p4_out(57);
		 databit_s5 <= p4_out(56);
		 db_stg5 <=p4_out(56);
		 opc_stg5<=p4_out(3 downto 0);
            -- pass the values ahead;
				
				--For SM
            if(p4_out(3 downto 0) = "0111") then
                count_stg5 <= count;
					 -- pass the count value
                M_inp <= p4_out(54 downto 39);
                M_add <= Dptr;
					 -- get the address from LmSm Block 
                mem_W <= '1';
                opcode_stg5 <= p4_out(3 downto 0);    
                p5_w <= '1';
                hazardbit_5 <= '0';

            elsif(p4_out(3 downto 0) = "0101") then
                -- For SW 
                M_inp <= p4_out(54 downto 39);
                M_add <= p4_out(38 downto 23);
                mem_W <= '1';
					 -- For SW stage store the value in Memory
                opcode_stg5 <= p4_out(3 downto 0);   
                hazardbit_5 <= '0';
					 -- 

            elsif(p4_out(3 downto 0) = "0100") then
                --  LW
                M_add <= p4_out(38 downto 23);
                reg_val_stg5 <= M_data;
                reg_add_stg5 <= p4_out(22 downto 20);
                opcode_stg5 <= p4_out(3 downto 0); 
                hazardbit_5 <= '1';
                Address_Stg_5 <= p4_out(22 downto 20);
                D_val5_A <= M_data;
                D_val5_B <= M_data;
                p5_w <= '1';

            elsif(p4_out(3 downto 0) = "0110") then
                -- LM
                M_add <= Dptr;
                reg_val_stg5 <= M_data;
                count_stg5 <= count;
                opcode_stg5 <= p4_out(3 downto 0); 
                reg_add_stg5 <= Rx_to_load_store;   
                p5_w <= '1';

            elsif(p4_out(3 downto 0) = "0011") then
                --LLI 
                reg_val_stg5 <= p4_out(54 downto 39);
                reg_add_stg5 <= p4_out(22 downto 20);
                opcode_stg5 <= p4_out(3 downto 0); 
                hazardbit_5 <= '1';
                Address_Stg_5 <= p4_out(22 downto 20);
                D_val5_A <= M_data;
                D_val5_B <= M_data;
                p5_w <= '1';

            elsif(p4_out(3 downto 0) = "0000") then
                -- ADI
                reg_val_stg5 <= p4_out(54 downto 39);
                reg_add_stg5 <= p4_out(22 downto 20);
                opcode_stg5 <= p4_out(3 downto 0); 
                hazardbit_5 <= '1';
                hazardbit_stg5 <= '1';
                Address_Stg_5 <= p4_out(22 downto 20);
                D_val5_A <= p4_out(54 downto 39);
                D_val5_B <= p4_out(54 downto 39);
                p5_w <= '1';

            elsif(p4_out(3 downto 0) = "0001") then
                -- ADA, ADC, ADZ,AWC,ACA,ACC,ACZ,ACW,
                reg_val_stg5 <= p4_out(54 downto 39);
                reg_add_stg5 <= p4_out(22 downto 20);
                opcode_stg5 <= p4_out(3 downto 0); 
                hazardbit_5 <= p4_out(55);
                hazardbit_stg5 <= p4_out(55);
                Address_Stg_5 <= p4_out(22 downto 20);
                D_val5_A <= p4_out(54 downto 39);
                D_val5_B <= p4_out(54 downto 39);
                p5_w <= '1';

            elsif(p4_out(3 downto 0) = "0010") then
                --NDU,NDC,NDZ,NCU,NCC,NCZ 
                reg_val_stg5 <= p4_out(54 downto 39);
                reg_add_stg5 <= p4_out(22 downto 20);
                opcode_stg5 <= p4_out(3 downto 0); 
                hazardbit_5 <= p4_out(55);
                hazardbit_stg5 <= p4_out(55);
                Address_Stg_5 <= p4_out(22 downto 20);
                D_val5_A <= p4_out(54 downto 39);
                D_val5_B <= p4_out(54 downto 39);
                p5_w <= '1';

            --Jump type
            elsif(p4_out(3 downto 0) = "1000") then
                -- For Conditional Jumps and the value of JAL PC+2*IMM can be used 
                -- BEQ BLT BLE JAL ;
                --{Nothing Special just fetch the instruction update PC}
                -- BEQ
                opcode_stg5 <= p4_out(3 downto 0);
                p5_w <= '1';

            elsif(p4_out(3 downto 0) = "1001") then
                -- BLT 
                opcode_stg5 <= p4_out(3 downto 0);
                p5_w <= '1';

            elsif(p4_out(3 downto 0) = "1010") then
                -- BLE
                opcode_stg5 <= p4_out(3 downto 0);
                p5_w <= '1';

            elsif(p4_out(3 downto 0) = "1100") then
                -- JAL
                reg_val_stg5 <= p4_out(54 downto 39);
                reg_add_stg5 <= p4_out(22 downto 20);
                opcode_stg5 <= p4_out(3 downto 0); 
                hazardbit_5 <= p4_out(55);
                hazardbit_stg5 <= p4_out(55);
                Address_Stg_5 <= p4_out(22 downto 20);
					 
                D_val5_A <= p4_out(54 downto 39);
                D_val5_B <= p4_out(54 downto 39);
                p5_w <= '1';

            elsif(p4_out(3 downto 0) = "1101") then
                -- For Unconditional Jumps JLR and JRI 
                -- JLR 
                reg_val_stg5 <= p4_out(54 downto 39);
                reg_add_stg5 <= p4_out(22 downto 20);
                opcode_stg5 <= p4_out(3 downto 0); 
                hazardbit_5 <= p4_out(55);
                hazardbit_stg5 <= p4_out(55);
                Address_Stg_5 <= p4_out(22 downto 20);
                D_val5_A <= p4_out(54 downto 39);
                D_val5_B <= p4_out(54 downto 39);
                p5_w <= '1';

            elsif(p4_out(3 downto 0) = "1110") then
                -- JRI 
                opcode_stg5 <= p4_out(3 downto 0);
                p5_w <= '1';
                -- Just pass OpCode ahead;
            else 
				         null;
         
			   end if;		
        end if;
	 end if;
end process;


--------------------------------------------------------------------------------------------------------------------------------------------------
write_back: process(clock)
begin
if (reset = '0') then
    if (rising_edge(clock)) then
        RF_w<='0';
        temp_w<='0';
        -- Writing in Pipeline register only at the rising edge of the clock and only if the bit is set(EN==1)
        cd6<=p5_out(44);
        --sm
        opc_stg6<=p5_out(39 downto 36);
        
		  if (p5_out(39 downto 36)="0101") then
          null;
        --sw
        elsif (p5_out(39 downto 36)="0111") then
            null;
        -- if LM 
        elsif (p5_out(39 downto 36)="0110") then
            D_s6 <= p5_out(35 downto 20);
            A_s6 <= p5_out(19 downto 17);
        
            if(p5_out(19 downto 17)="000") then 
                temp_r0_d<=p5_out(35 downto 20);
                temp_w<='1';   
                RF_W <= '0';
            else
                RF_W <= '1';
                temp_w<='0';
                end if;
        
        -- if LW
        elsif (p5_out(39 downto 36)="0100") then
            D_s6 <= p5_out(35 downto 20);
            A_s6 <= p5_out(19 downto 17);
            
            if(p5_out(19 downto 17)="000") then 
                temp_r0_d<=p5_out(35 downto 20);
                temp_w<='1';   
                RF_W <= '0';
            else
                RF_W <= '1';
                temp_w<='0';
                end if;
        
        --LLI 
        elsif (p5_out(39 downto 36)="0011") then
            D_s6 <= p5_out(35 downto 20);
            A_s6 <= p5_out(19 downto 17);
            
            if(p5_out(19 downto 17)="000") then 
                temp_r0_d<=p5_out(35 downto 20);
                temp_w<='1';   
                RF_W <= '0';
            else
                RF_W <= '1';
                temp_w<='0';
                end if;
        
            hazardbit_6 <= '1';
            Address_Stg_6 <= p5_out(19 downto 17);
            D_val6_B <= p5_out(35 downto 20);
            D_val6_A <= p5_out(35 downto 20);

        -- ADI
        elsif (p5_out(39 downto 36)="0000") then
            D_s6 <= p5_out(35 downto 20);
            A_s6 <= p5_out(19 downto 17);
           
            if(p5_out(19 downto 17)="000") then 
                temp_r0_d<=p5_out(35 downto 20);
                temp_w<='1';   
                RF_W <= '0';
            else
                RF_W <= '1';
                temp_w<='0';
                end if;
        
            hazardbit_6 <= '1';
             Address_Stg_6 <= p5_out(19 downto 17);
            D_val6_B <= p5_out(35 downto 20);
            D_val6_A <= p5_out(35 downto 20);
				
        elsif (p5_out(39 downto 36)="0001") then
            hazardbit_6 <= p5_out(16);
        
            if (p5_out(16) = '1') then
                D_s6 <= p5_out(35 downto 20);
                A_s6 <= p5_out(19 downto 17);
                
                    if(p5_out(19 downto 17)="000") then 
                    temp_r0_d<=p5_out(35 downto 20);
                    temp_w<='1';   
                    RF_W <= '0';
                else
                    RF_W <= '1';
                    temp_w<='0';
                    end if;
        
             Address_Stg_6 <= p5_out(19 downto 17);
                D_val6_B <= p5_out(35 downto 20);
                D_val6_A <= p5_out(35 downto 20);
            
            else 
                RF_W <= '0';
            end if;

        elsif (p5_out(39 downto 36)="0010") then
            hazardbit_6 <= p5_out(16);
        
            if (p5_out(16) = '1') then
                D_s6 <= p5_out(35 downto 20);
                A_s6 <= p5_out(19 downto 17);
                
                if(p5_out(19 downto 17)="000") then 
                    temp_r0_d<=p5_out(35 downto 20);
                    temp_w<='1';   
                    RF_W <= '0';
                else
                    RF_W <= '1';
                    temp_w<='0';
                    end if;
                Address_Stg_6 <= p5_out(19 downto 17);
                D_val6_B <= p5_out(35 downto 20);
                D_val6_A <= p5_out(35 downto 20);
            
            else 
                RF_W <= '0';
            end if;

        -- BEQ
        elsif (p5_out(39 downto 36)="1000") then
            null;
        -- BLT 
        elsif (p5_out(39 downto 36)="1001") then
            null;
        -- BLE
        elsif (p5_out(39 downto 36)="1010") then
            null;
   
        elsif (p5_out(39 downto 36)="1100") then
            D_s6 <= p5_out(35 downto 20);
            A_s6 <= p5_out(19 downto 17);
            
                if(p5_out(19 downto 17)="000") then 
                    temp_r0_d<=p5_out(35 downto 20);
                    temp_w<='1';   
                    RF_W <= '0';
                else
                    RF_W <= '1';
                    temp_w<='0';
                    end if;
        
            hazardbit_6 <= p5_out(16);
            Address_Stg_6 <= p5_out(19 downto 17);
            D_val6_B <= p5_out(35 downto 20);
            D_val6_A <= p5_out(35 downto 20);
   
        elsif (p5_out(39 downto 36)="1101") then
            D_s6 <= p5_out(35 downto 20);
            A_s6 <= p5_out(19 downto 17);
            
                if(p5_out(19 downto 17)="000") then 
                    temp_r0_d<=p5_out(35 downto 20);
                    temp_w<='1';   
                    RF_W <= '0';
                else
                    RF_W <= '1';
                    temp_w<='0';
                    end if;
        
            hazardbit_6 <= p5_out(16);
            Address_Stg_6 <= p5_out(19 downto 17);

            D_val6_B <= p5_out(35 downto 20);
            D_val6_A <= p5_out(35 downto 20);
				
        elsif (p5_out(39 downto 36)="1111") then
            null;
		  else 
		     null;
        end if;
    
	 end if;	
end if;
end process;

--------------------------------------------------------------------------------------------------------------------------------------------------
end bhv;

--------------------------------------------------------------------------------------------------------------------------------------------------