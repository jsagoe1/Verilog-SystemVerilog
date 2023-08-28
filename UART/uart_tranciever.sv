
`ifndef UART_TRANCIEVER_SV
`define UART_TRANCIEVER_SV

module uart_tranciever (
   input    logic          clkin,      // input clock 25MHz
   input    logic          rst,        // master reset for all
   input    logic [1:0]    baud_sel,   // baudrate selector: 2'b00: 19200 | 2'b01: 38400 | 2'b10: 57600 | 2'b11: 115200
   input    logic          rx,         // rx in
   input    logic [7:0]    tx_data,    // data to be transmitted by uart
   input    logic          tx_start,   // tranmit start signal
   input    logic          rx_start,   // reciever start signal
   output   logic          baud_out,   // buadrate output for probe
   output   logic          tx_done,    // pulse indicator for tx done
   output   logic          rx_done,    // pulse indicator for rx done
   output   logic          tx_busy,    // tx in progress
   output   logic          rx_busy,    // rx in progress
   output   logic [7:0]    rx_data     // rx latched data
);
   
 
   baudrategen baudgen (
      .baud_out   (baud_out),
      .clkin      (clkin),
      .rst        (rst),
      .baud_sel   (baud_sel)
   );
   

   uart_tx transmitter (
      .tx         (tx),
      .tx_done    (tx_done),
      .tx_busy    (tx_busy),
      .tx_data    (tx_data),
      .tx_start   (tx_start),
      .clk        (baud_out),
      .rst        (rst)
   );

   uart_rx receiver    (
      .rx         (rx),
      .rx_done    (rx_done),
      .rx_busy    (rx_busy),
      .rx_data    (rx_data),
      .rx_start   (rx_start),
      .clk        (baud_out),
      .rst        (rst)
   );

endmodule
`endif
