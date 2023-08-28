`ifndef UART_RX_SV
`define UART_RX_SV

module uart_rx (
      output   logic       rx_done,
      output   logic       rx_busy,
      output   logic [7:0] rx_data,
      input    logic       rx,      
      input    logic       rx_start,  // enable signal for rx logic
      input    logic       clk, 
      input    logic       rst
   );

   localparam IDLE_VAL  = 1'b1;
   localparam START_VAL = 1'b0;

   typedef enum logic [1:0] {
      STATE_IDLE,
      STATE_START,
      STATE_DATA,
      STATE_STOP
   } t_fsm_state;

   t_fsm_state state, nxt_state;

   logic [7:0] rx_data_nxt;

   logic [2:0] pos, pos_nxt;

   always_ff @ (posedge clk or posedge rst) begin
      if (rst) begin
         state <= STATE_IDLE;
         pos   <= '0;
      end
      else begin
         state <= nxt_state;
         pos   <= pos_nxt;
      end
   end

   // rx_data flop
   always_ff @(posedge clk)
      rx_data <= rx_data_nxt;

   always_comb begin
      nxt_state   = STATE_IDLE;
      pos_nxt     = '0;
      rx_data_nxt = rx_data;
      case (state)
         STATE_IDLE: begin
            nxt_state = rx_start ? ((rx != IDLE_VAL) ? STATE_START : STATE_IDLE) : STATE_IDLE;
         end

         STATE_START: begin
            nxt_state = STATE_DATA;
            pos_nxt   = pos + 1'b1;
            rx_data_nxt[pos] = rx;    // first bit
         end

         STATE_DATA: begin
            nxt_state         = (pos == 7) ? STATE_STOP : STATE_DATA;
            pos_nxt           = pos + 1'b1;
            rx_data_nxt[pos]  = rx;
         end
      
         STATE_STOP: begin
            nxt_state = STATE_IDLE;
         end

      endcase
   end
   
   assign rx_busy = (state != STATE_IDLE);
   assign rx_done = (state == STATE_STOP);
   
endmodule

`endif
