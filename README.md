# dram_controller
Advanced VLSI HW 2


A DRAM controller is an on chip component of the processor, responsible for communicating with off 
chip DRAM systems. Data is actually stored inside multiple banks in interleaved fashion. All banks of 
the DRAM can be accessed parallely. Each bank has a two dimensional matrix of bit cells(capacitor) 
and a row buffer.  

Below are the steps/commands to read data from DRAM : 

a) RA (row access): An address in DRAM gets divided into a tuple <Bankid, rowid, colid>. Bankid 
selects the bank; while the rowid selects a row and all the bit cells in the row are stored in the 
row buffer. 

b) CA (column access): A column is selected by the colid and the bit corresponding to that column 
stored in the row buffer is sent out of the bank. 


c) PRE (precharge): When all the required columns are read out, the entire row in the row buffer 
is written back into the original row position of the bank (since the capacitors leak the charge 
over time which may corrupt the data). 
 
When a request of different row arrives at controller, first the existing row inside the row buffer needs 
to pre precharged before the new row’s RA step begins.Assuming the number of banks is 8. Each bank 
has  a  128  X  8  matrix  of  bit  cells,  i.e  each  bank  can  hold  1024  bits  of  data.  Write  a  verilog  code  to 
implement this design. 

Besides the above mentioned functionality, there are additional commands that need to be 
supported.  
 
REFRESH: Even though all rows of the DRAM bank are not accessed, still because of the leaky nature 
of capacitors, each row of the DRAM bank needs to be periodically refreshed. During the refresh time 
of a row, same row access is prohibited. Assume refresh rate is 125ms. 

![image](https://user-images.githubusercontent.com/30788600/157744551-3b9cc74d-d8f5-46f3-81d5-ff8be11c201b.png)


Constraints: 

a) Since inside the DRAM there is no additional command buffer, all the commands need to be 
sent one by one (sequentially).  

b) Each command has its own execution delay. So the controller has to send the commands in 
such a way that all such delay constraints of DRAM can be maintained and no command gets 
ignored. 

c) Periodically REFRESH command needs to be issued

d) Though each bank can be accessed simultaneously but at a time only one bank can transfer 
data to DRAM controller via DRAM bus. 
 

