
module  freq_div_by_n_10b (
    output logic clkout,
    input  logic rstb,
    input  logic bypass,
    input  logic clkin,
    input  logic [9:0] ratio,
    input  logic ratio_upd_req,
    output logic ratio_upd_ack
);

   logic rst, rat_is_odd, phase_track;
   logic clkdiv;

   logic [8:0] load_value;

   assign rst    = !rstb;

   ratio_samp iratio_samp (
        .clkin      (clkin),
        .rst        (rst),
        .upd_req    (ratio_upd_req),
        .upd_ack    (ratio_upd_ack),
        .ratio      (ratio),
        .phase_track(phase_track),
        .load_value (load_value),
        .rat_is_odd (rat_is_odd)
    );

    clk_counter  icnt (
        .rst        (rst),
        .clkin      (clkin),
        .load_value (load_value),
        .phase_track(phase_track),
        .rat_is_odd (rat_is_odd),
        .clkdiv     (clkdiv)
    );

    output_mux  imux (
        .clkin  (clkin),
        .clkdiv (clkdiv),
        .rst    (rst),
        .bypass (bypass),
        .clkout (clkout)
    );

endmodule
