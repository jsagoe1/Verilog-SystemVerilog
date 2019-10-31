//level-to-pulse detector

//moore type

module level_to_pulse_converter (output logic pulse,
                                 output logic [1:0] statemon,
                                 input logic level,
                                 input logic clock);
  
  logic [1:0] 					state, next_state;
  
  assign statemon  = state;
  
  always_ff @(posedge clock)
    state <= next_state;
  
  always_comb begin
    case (state)
      0: begin
        pulse = 0;
        if (level == 1)
          next_state = 1;
        else
          next_state = 0;
      end
      
      1: begin
        pulse = 1;
        if (level == 1)
          next_state = 2;
        else
          next_state = 0;
      end
      
      2: begin
        pulse = 0;
        if (level == 0)
          next_state = 0;
        else
          next_state = 2;
      end
      default: next_state = 0;
      
    endcase
  end
endmodule


module test;
  
  logic pulse, level, clock;
  logic [1:0] statemon;
  
  level_to_pulse_converter l0(.pulse(pulse),
                              .statemon(statemon),
                              .level(level),
                              .clock(clock));
  
  initial begin
    level = 0;
    clock = 0;
    #3 level = 1;
    #15 level = 0;
    #5 level = 1;
    #100 $finish;
  end
  
  always begin
    #2 clock = ~clock;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1);
  end
    
  
endmodule
