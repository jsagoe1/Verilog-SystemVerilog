

`ifndef BAUDRATEGEN_SV
`define BAUDRATEGEN_SV

module baudrategen (
   output   logic          baud_out,     // output of baud gen
   input    logic          clkin,        // input  clock of baud gen (25MHz)
   input    logic          rst,          // reset
   input    logic  [1:0]   baud_sel      // 00-19200, 01-38400, 10-57600, 11 - 115200
);


   // count values for each phase of clkout
   // *_M1 is for the low phase such that the
   // high phase is always one clkin cycle longer
   localparam  LOAD_VAL_BAUD_19200     = 13'd1301;
   localparam  LOAD_VAL_BAUD_38400     = 13'd650;
   localparam  LOAD_VAL_BAUD_57600     = 13'd433;
   localparam  LOAD_VAL_BAUD_115200    = 13'd216;

   logic [12:0]   load_val, load_val_m1, load_val_final;
   logic [12:0]   cnt, cnt_nxt, cnt_m1;

   logic          baud_out, clkout_nxt, ovfl;

   // decode baud_sel to obtain buad generator load value
   always_comb begin
      case (baud_sel)
         2'b00: load_val = LOAD_VAL_BAUD_19200;
         2'b01: load_val = LOAD_VAL_BAUD_38400;
         2'b10: load_val = LOAD_VAL_BAUD_57600;
         2'b11: load_val = LOAD_VAL_BAUD_115200;
      endcase
   end   
   
   // counter logic
   assign {ovfl, cnt_m1}   = cnt - 1'b1; 
   assign cnt_nxt          = baud_out ? load_val : cnt_m1;    // reload counter with load value
   
   always_ff @(posedge clkin or posedge rst) begin
      if (rst) cnt <= '0;
      else     cnt <= cnt_nxt;
   end

   assign baud_out = (cnt == '0);

   
endmodule

`endif
