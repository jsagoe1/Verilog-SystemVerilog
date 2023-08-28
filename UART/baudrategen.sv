

`ifndef BAUDRATEGEN_SV
`define BAUDRATEGEN_SV

module baudrategen (
   output   logic          clkout,       // output clock of baud gen
   input    logic          clkin,        // input  clock of baud gen (25MHz)
   input    logic          rst,          // reset
   input    logic          baud_en,      // en for baud
   input    logic  [1:0]   baud_sel      // 00-19200, 01-38400, 10-57600, 11 - 115200
);


   // count values for each phase of clkout
   // *_M1 is for the low phase such that the
   // high phase is always one clkin cycle longer
   localparam  LOAD_VAL_BAUD_19200     = 13'd6511;
   localparam  LOAD_VAL_BAUD_19200_M1  = 13'd6510;
   localparam  LOAD_VAL_BAUD_38400     = 13'd325;
   localparam  LOAD_VAL_BAUD_38400_M1  = 13'd324;
   localparam  LOAD_VAL_BAUD_57600     = 13'd217;
   localparam  LOAD_VAL_BAUD_57600_M1  = 13'd215;
   localparam  LOAD_VAL_BAUD_115200    = 13'd108;
   localparam  LOAD_VAL_BAUD_115200_M1 = 13'd107;

   logic [12:0]   load_val, load_val_m1, load_val_final;
   logic [12:0]   cnt, cnt_nxt, cnt_m1;
   logic          baud_en_l;
   logic          clkin_gated;

   logic          toggle_en, clkout_nxt, ovfl;

   // decode baud_sel to obtain buad generator load value
   always_comb begin
      case (baud_sel)
         2'b00: begin load_val = LOAD_VAL_BAUD_19200;    load_val_m1 = LOAD_VAL_BAUD_19200_M1;  end
         2'b01: begin load_val = LOAD_VAL_BAUD_38400;    load_val_m1 = LOAD_VAL_BAUD_38400_M1;  end
         2'b10: begin load_val = LOAD_VAL_BAUD_57600;    load_val_m1 = LOAD_VAL_BAUD_57600_M1;  end
         2'b11: begin load_val = LOAD_VAL_BAUD_115200;   load_val_m1 = LOAD_VAL_BAUD_115200_M1; end
      endcase
   end

   assign load_val_final = clkout ? load_val_m1 : load_val;
   
   // internal latch based clock gating for baudgenerator
   always_latch
      if (~clkin)
         baud_en_l <= baud_en;
   assign clkin_gated = clkin && baud_en_l;

   
   // counter logic
   assign {ovfl, cnt_m1}   = cnt - 1'b1; 
   assign cnt_nxt          = toggle_en ? load_val_final : cnt_m1;    // reload counter with load value
   
   always_ff @(posedge clkin_gated or posedge rst) begin
      if (rst) cnt <= '0;
      else     cnt <= cnt_nxt;
   end

   assign toggle_en = (cnt == '0);

   // output clock
   assign clkout_nxt = toggle_en ^ clkout;
   always_ff @(posedge clkin_gated or posedge rst) begin
      if (rst) clkout <= '0;
      else     clkout <= clkout_nxt;
   end
   
endmodule

`endif
