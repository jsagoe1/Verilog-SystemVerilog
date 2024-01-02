module clk_counter (
    input logic         clkin,
    input logic         rst,
    input logic [8:0]   load_value,
    input logic         rat_is_odd,
    output logic        phase_track,
    output logic        clkdiv
);

    logic cnt_zero;
    logic clk21, clk83;
    logic [8:0] cnt, cnt_nxt, cnt_nxt_final;

    logic phase_track_nxt, phase_track_L;

    ///////////////////////////////////////////////////////////////////////////////////////////
    // SEGMENTED COUNTERS GATED BY LSB ALL ZEROS
    //////////////////////////////////////////////////////////////////////////////////////////

    assign clk21   = (cnt[0]   != '0)  || clkin;
    assign clk83   = (cnt[2:0] != '0)  || clkin;

    assign cnt_nxt[0]   = !cnt[0];    // same as minus 1
    assign cnt_nxt[2:1] = cnt[2:1] - 2'b1;
    assign cnt_nxt[8:3] = cnt[8:3] - 6'b1;

    assign cnt_zero     = (cnt[8:0] == '0);

    assign cnt_nxt_final = cnt_zero ? load_value : cnt_nxt;

    // clock counters
    // Next states gated by LSB all zeros
    always_ff @(posedge clkin or posedge rst) begin
        if (rst) cnt[0] <= '0;
        else     cnt[0] <= cnt_nxt_final[0];
    end

    always_ff @(posedge clk21 or posedge rst) begin
        if (rst) cnt[2:1] <= '0;
        else     cnt[2:1] <= cnt_nxt_final[2:1];
    end

    always_ff @(posedge clk83 or posedge rst) begin
        if (rst) cnt[8:3] <= '0;
        else     cnt[8:3] <= cnt_nxt_final[8:3];
    end

    ////////////////////////////////////////////////////////////////////////////////////////
    // CLOCK GEN
    ///////////////////////////////////////////////////////////////////////////////////////
    assign phase_track_nxt = phase_track ^ cnt_zero;

    always_ff @(posedge clkin or posedge rst) begin
        if (rst) phase_track <= '0;
        else     phase_track <= phase_track_nxt;
    end

    always_ff @(negedge clkin or posedge rst) begin
        if      (rst)    phase_track_L <= '0;
        else if (!clkin) phase_track_L <= phase_track_nxt;
    end

    assign clkdiv = phase_track || (rat_is_odd && phase_track_L);

endmodule
