module ratio_samp (
    input  logic        rst,
    input  logic        clkin,
    input  logic [9:0]  ratio,
    input  logic        phase_track,
    input  logic        upd_req,
    output logic        upd_ack,
    output logic [8:0]  load_value,
    output logic        rat_is_odd
);

    logic clkrsamp, clkinb;
    logic enclkrsamp;
    logic upd_req_sync0, upd_req_sync1;

    logic [8:0] load_even, load_odd, ratdiv2, ratdiv2_minus1;
    logic [9:0] ratio_set, ratio_rst, ratio_samp;

    assign clkinb       = ~clkin;
    assign clkrsamp     = clkin && enclkrsamp;

    assign enclkrsamp   = upd_req_sync1 && !upd_ack;

   // 3x metaflop to allow ratio sampling
   always_ff @(posedge clkinb or posedge rst) begin
        if (rst) {upd_req_sync0, upd_req_sync1, upd_ack} <= '0;
        else     {upd_req_sync0, upd_req_sync1, upd_ack} <= {upd_req, upd_req_sync0, upd_req_sync1};
   end

   // ratio sampling
   for (genvar i=0; i<10; i++) begin
        // set the flop values to the ratio value at interface during reset
        // asynchronuosly
        assign ratio_rst[i] = ~ratio[i] && rst;
        assign ratio_set[i] =  ratio[i] && rst;

        always_ff @(posedge clkrsamp or posedge ratio_set[i] or posedge ratio_rst[i]) begin
            if      (ratio_set[i]) ratio_samp[i] <= 1'b1;
            else if (ratio_rst[i]) ratio_samp[i] <= 1'b0;
            else                   ratio_samp[i] <= ratio[i];
        end
   end

   assign ratdiv2        = ratio_samp[9:1];
   assign ratdiv2_minus1 = (ratdiv2 - 1'b1);
   assign rat_is_odd     = ratio_samp[0];
   assign load_even      = ratdiv2_minus1;
   assign load_odd       = phase_track ? ratdiv2 : ratdiv2_minus1;

   assign load_value     = rat_is_odd ? load_odd : load_even; // divide ratio_samp by 2 - 1

endmodule
