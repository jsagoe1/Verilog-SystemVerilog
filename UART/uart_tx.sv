`ifndef UART_TX_SV
`define UART_TX_SV

module uart_tx (
      output   logic       tx,
      output   logic       tx_done,
      output   logic       tx_busy,      
      input    logic [7:0] tx_data,
      input    logic       tx_start,
      input    logic       clk, 
      input    logic       rst
   );

   localparam IDLE_VAL  = 1'b1;
   localparam START_VAL = 1'b0;
   localparam STOP_VAL  = 1'b1;

   typedef enum logic [1:0] {
      STATE_IDLE,
      STATE_START,
      STATE_DATA,
      STATE_STOP
   } t_fsm_state;

   t_fsm_state state, nxt_state;

   logic [2:0] pos, pos_nxt;
   logic       tx_nxt;

   always_ff @ (posedge clk or posedge rst) begin
      if (rst) begin
         state <= STATE_IDLE;
         tx    <= IDLE_VAL;
         pos   <= '0;
      end
      else begin
         state <= nxt_state;
         tx    <= tx_nxt;
         pos   <= pos_nxt;
      end
   end

   always_comb begin
      nxt_state = STATE_IDLE;
      pos_nxt   = '0;      
      tx_nxt    = IDLE_VAL;
      case (state)
         STATE_IDLE: begin
            nxt_state = tx_start ? STATE_START : STATE_IDLE;
            tx_nxt    = tx_start ? START_VAL   : IDLE_VAL;
         end

         STATE_START: begin
            nxt_state = STATE_DATA;
            tx_nxt    = tx_data[pos];
            pos_nxt   = pos + 1'b1;
         end

         STATE_DATA: begin
            nxt_state = (pos == 7) ? STATE_STOP : STATE_DATA;
            tx_nxt    = tx_data[pos];
            pos_nxt   = pos + 1'b1;
         end
      
         STATE_STOP: begin
            nxt_state = STATE_IDLE;
            tx_nxt    = STOP_VAL;
         end

      endcase
   end

   assign tx_busy = (state != STATE_IDLE);
   assign tx_done = (state == STATE_STOP);

endmodule

`endif
