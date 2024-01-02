module output_mux (
    input logic clkin,
    input logic clkdiv,
    input logic bypass,
    input logic rst,
    output logic clkout
);

    logic bypass_en,      div_en;
    logic bypass_en_sync, div_en_sync;
    logic bypass_en_sync_falling, div_en_sync_falling;
    logic bypass_en_sync0, div_en_sync0;

    logic clking, clkdivg;

    // gated pre-synchronized enables
    //
    assign bypass_en =  bypass && !div_en_sync_falling;
    assign div_en    = !bypass && !bypass_en_sync_falling;

    // synchronize the enables into respective clock domains
    //
    always_ff @(posedge clkin or posedge rst) begin
        if (rst) {bypass_en_sync0, bypass_en_sync} <= '0;
        else     {bypass_en_sync0, bypass_en_sync} <= {bypass_en, bypass_en_sync0};
    end

    always_ff @(posedge clkdiv or posedge rst) begin
        if (rst) {div_en_sync0, div_en_sync} <= '0;
        else     {div_en_sync0, div_en_sync} <= {div_en, div_en_sync0};
    end

    // get a negatove egde version for clock gating
    //
    always_ff @(negedge clkin or posedge rst) begin
        if (rst) bypass_en_sync_falling <= '0;
        else     bypass_en_sync_falling <= bypass_en_sync;
    end

    always_ff @(negedge clkdiv or posedge rst) begin
        if (rst) div_en_sync_falling <= '0;
        else     div_en_sync_falling <= div_en_sync;
    end

    // output MUXing
    assign clking  = clkin  && bypass_en_sync_falling;
    assign clkdivg = clkdiv && div_en_sync_falling;

    assign clkout = clking || clkdivg;

endmodule
