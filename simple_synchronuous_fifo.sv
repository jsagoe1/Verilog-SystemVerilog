//simple sync fifo 

module sync_fifo #(int depth_bits = 8, int input_width = 8)
  (output logic [input_width - 1:0] 	data_out,
   input logic [input_width - 1:0] 		data_in,
   input uwire 							clock,
   input uwire 							reset,
   input uwire 							write_enable,
   input uwire							read_enable);
  
  logic [input_width -1:0] memory [0:2^depth_bits - 1];
  logic [depth_bits -1:0] write_address;
  logic [depth_bits -1:0] read_address;
  logic		full;
  logic 	empty;
  logic 	overrun;
  logic		underrun;
  logic 	[depth_bits-1:0] next_read_address;
  logic 	[depth_bits-1:0] dbl_write_address;
  
  //separate write and read inputs and output in different 
  //always blocks
  always_ff @(posedge clock)
    if (write_enable)
      memory[write_address] <= data_in;
  
  always_ff @(posedge clock)
    if (read_enable)
      data_out <= memory[read_address];
  
  //write logic and control
  always_ff @(posedge clock)
    begin
      if (reset)
        begin
          write_address <= 0;
          overrun <= 0;
        end
      else if (write_enable)
        begin
          //update fifo write address anytime a write is made
          //to the fifo and it is not full
          //or
          //any time a write is made to the fifo at the same 
          //time a read is made from the fifo
          
          if ((!full) || (read_enable))
              write_address <= write_address + 1'b1;
          else
            overrun <=1'b1;
        end
    end
  
  //read logic and control
  always_ff @(posedge clock)
    begin
      if (reset)
        begin
          read_address <= 0;
          underrun <= 0;
        end
      else if (read_enable)
        begin
          //on any request, increment the read pointer if fifo 
          //is not empty -- independent of whether a write 
          //operation is taking place at the dame time
          
          if (!empty)
            read_address <= read_address + 1'b1;
          else
            //if a read request is made when fifo is full, 
            //set the underrun error flag
            underrun <= 1'b1;
        end
    end
 
  
  //logic for checking if fifo is full
  always_ff @(posedge clock)
    begin
      if (reset)
        begin
          full <= 1'b0;
          empty <= 1'b1;
        end
      else
        casez({write_enable, read_enable, !full, !empty})
          
          4'b01?1: begin   //a perfect successful read
            full <= 1'b0;
            empty <= (next_read_address == write_address);
          end
          
          4'b101?: begin 	// a perfect successfull write
            full <= (dbl_write_address == read_address);
          end
          
          4'b11?0: begin	// Successful write, failed read
            full  <= 1'b0;
            empty <= 1'b0;
          end
          
          4'b11?1: begin	// Successful read and write
             full  <= full;
             empty <= 1'b0;
          end
          
          default: begin end
          
        endcase
    end
  
  assign dbl_write_address = write_address + 2;  // 
  assign next_read_address = read_address + 1'b1;
  
endmodule
 
  
  
  
