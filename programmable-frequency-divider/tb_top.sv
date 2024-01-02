module tb_top();

    logic clkout;
    logic bypass;
    logic clkin;
    logic [9:0] ratio;
    logic ratio_upd_req;
    logic ratio_upd_ack;
    logic rst_syncb_0, rst_syncb_1, rst_syncb, rstb;


// Instantiate the top level module under test (DUT)
//
freq_div_by_n_10b dut (
    .clkout          (clkout),
    .rstb            (rst_syncb),
    .bypass          (bypass),
    .clkin           (clkin),
    .ratio           (ratio),
    .ratio_upd_req   (ratio_upd_req),
    .ratio_upd_ack   (ratio_upd_ack)
);


int clkin_phase_ns;
assign clkin_phase_ns = $urandom_range(100, 500);

always #(clkin_phase_ns) clkin  = ~clkin;

//reset sync
// async assert, sync deassert
always_ff @(posedge clkin or negedge rstb) begin
    if   (!rstb) {rst_syncb_0, rst_syncb_1, rst_syncb}   <= '0;
    else         {rst_syncb_0, rst_syncb_1, rst_syncb}   <= {1'b1, rst_syncb_0, rst_syncb_1};
end

initial begin
   // Dump all variables in TB and below as well as SVAs
   //
   `ifdef VCS
     $fsdbDumpSVA;
     $fsdbDumpvars(0,tb_top,"+all");
   `endif
end
  
initial begin
   clkin  = 0;
   bypass = 0;
   rstb    = 0;
   ratio  = $urandom_range(5,15);
   ratio_upd_req = 0;

   repeat(2) @(posedge clkin);
   #1; rstb = 1;
   repeat(20) @(posedge clkin);
   repeat(10) begin
        // change ratio
        @(posedge clkin);
        #($urandom_range(100));
        ratio  = $urandom_range(10,40);

        // make update req
        make_upd_req();

        // wait 100 input clock cycles
        repeat(100) @(posedge clkin);

        // set bypass
        #($urandom_range(10)) bypass = 1;
        repeat(100) @(posedge clkin);
        // disable bypass
        #($urandom_range(10)) bypass = 0;
        repeat(100) @(posedge clkin);
   end
   #200;
   $finish;

end

task make_upd_req();
    ratio_upd_req = 1;
    @(posedge ratio_upd_ack);
    repeat(2) @(posedge clkin);
    ratio_upd_req = 0;
    @(negedge ratio_upd_ack);
    #20;
endtask

endmodule
