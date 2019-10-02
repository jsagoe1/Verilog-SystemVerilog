//asynchronuos fifo design adapted from Clifford E. Cummings available online at
//"http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO1.pdf"

module async_fifo #(int width = 8, addrsize = 8)
  (output logic [width-1:0] 	                rdata,				//data output
   output logic					wfull,				//full flag
   output logic					rempty,				//buffer empty flag
   input logic [width-1:0] 		        wdata,				//write input data
   input logic					winc,				//write enable
   input logic					wclk,				//write clock
   input logic					wrst_n,				//write reset (active low)
   input logic					rinc,				//read enabled
   input logic					rclk,				//read clock
   input logic					rrst_n);			//read reset
  
  logic [addrsize-1:0] 	waddr;						//write address
  logic [addrsize-1:0] 	raddr;						//read address
  logic [addrsize:0] 	wptr;						//write pointerr
  logic [addrsize:0]	rptr;						//read pointer
  logic [addrsize:0]	wq2_rptr;					//synchronized read pointer
  logic [addrsize:0]	rq2_wptr;					//synchronized write pointer
  
  
  sync_r2w #(addrsize) s1 (.wq2_rptr(wq2_rptr),
                           .rptr(rptr),
                           .wclk(wclk),
                           .wrst_n(wrst_n));
  
  sync_w2r #(addrsize) s2 (.rq2_wptr(rq2_wptr),
                           .wptr(wptr),
                           .rclk(rclk),
                           .rrst_n(rrst_n));
  
  fifo_memory #(width, addrsize) f0 (.rdata(rdata),
                                     .wdata(wdata),
                                     .waddr(waddr),
                                     .raddr(raddr),
                                     .wclken(winc), 
                                     .wfull(wfull),
                                     .wclk(wclk));
  
  rptr_empty #(addrsize) r0 (.rempty(rempty),
                             .raddr(raddr),
                             .rptr(rptr),
                             .rq2_wptr(rq2_wptr),
                             .rinc(rinc),
                             .rclk(rclk),
                             .rrst_n(rrst_n));
  
  wptr_full #(addrsize) w0 (.wfull(wfull),
                            .waddr(waddr),
                            .wptr(wptr),
                            .wq2_rptr(wq2_rptr),
                            .winc(winc), 
                            .wclk(wclk),
                            .wrst_n(wrst_n));
  
endmodule


// FIFO memory module
module fifo_memory #(int addrsize = 4, int width = 8)
  (output logic [width-1:0] 	rdata,	//read data input
   input logic 	[width-1:0] 	wdata,	//write data input
   input logic 	[addrsize-1:0]	waddr,	//write address
   input logic  [addrsize-1:0]	raddr,	//read address
   input logic 	wclk,					//write clock
   input logic  wclken,					//write clock enable
   input logic  wfull);					//fifo full flag
  
  localparam int depth = 1 << addrsize;
  
  logic [width-1:0] mem [0:depth-1];
  
  assign rdata = mem[raddr];
  
  always_ff @(posedge wclk)
    //write only if (write enabled and not full)
    if (wclken && !wfull)
      mem[waddr] <= wdata;
  
endmodule


//write domain to read domain synchronizer
module sync_w2r #(int addrsize = 8)
  (output logic	[addrsize:0]	rq2_wptr,	//synchronized write_pointer graycode
   input logic	[addrsize:0]	wptr,		//write pointer
   input logic			rclk, 		//read clock
   input logic			rrst_n);	//read logic reset (Active low)
  
  logic [addrsize:0]	rq1_wptr;			//connection point b/n sync FFs
  
  always_ff @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) begin
      rq1_wptr <= 0;
      rq2_wptr <= 0;
    end
    else begin
      rq1_wptr <= wptr;
      rq2_wptr <= rq1_wptr;
    end
  end
endmodule


//read domain to write domain synchronizer 
module sync_r2w #(int addrsize = 8)
  (output logic	[addrsize:0]	wq2_rptr,	//synchronized read_pointer graycode
   input logic	[addrsize:0]	rptr,		//read pointer
   input logic			wclk, 		//write clock
   input logic			wrst_n);	//write logic reset (Active low)
  
  logic [addrsize:0]	wq1_rptr;			//connection point b/n sync FFs
  
  always_ff @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) begin
      wq1_rptr <= 0;
      wq2_rptr <= 0;
    end
    else begin
      wq1_rptr <= rptr;
      wq2_rptr <= wq1_rptr;
    end
  end
endmodule


//read_pointer, read_address and read empty flag generator
module rptr_empty #(int addrsize = 8)
  (output logic 				rempty,		//empty flag
   output logic [addrsize-1:0] 	                raddr,		//read address
   output logic	[addrsize:0] 	                rptr,		//read pointer
   input logic	[addrsize:0] 	                rq2_wptr,	//synchronized write pointer (gray code)
   input logic					rinc,		//read enable
   input logic					rclk,		//read clock
   input logic					rrst_n);	//read logic reset
  
  logic [addrsize:0] 	rbin;				//binary counter latched output
  logic [addrsize:0] 	rgraynext;			//converted binary to gray code
  logic [addrsize:0]	rbinnext;			//read binary counter adder output
  
  always_ff @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) begin
      rbin <= 0;
      rptr <= 0;
    end
    else begin;
      rbin <= rbinnext;
      rptr <= rgraynext;
    end
  end
  
  // Memory read-address pointer
  assign raddr = rbin[addrsize-1:0];			//msb of counter value not used in address
  assign rbinnext = rbin + (rinc & ~rempty);	//if enabled and not empty
  assign rgraynext = (rbinnext>>1) ^ rbinnext;	//bin to gray
  
  // FIFO empty when the next rptr == synchronized wptr or on reset
  assign rempty_val = (rgraynext == rq2_wptr);
  
  always_ff @(posedge rclk or negedge rrst_n)
    if (!rrst_n) rempty <= 1'b1;
  else 
    rempty <= rempty_val;
endmodule


//write_pointer, write_address and write address generator
module wptr_full #(int addrsize = 8)
  (output logic                 wfull,			//buffer full flag
   output logic [addrsize-1:0] 	waddr,			//write address
   output logic	[addrsize:0] 	  wptr,			//write pointer
   input logic [addrsize:0] 	    wq2_rptr,		//synchronized read pointer(gray code)
   input logic 	                winc,			//write enable
   input logic	                wclk,			//write logic clock
   input logic	                wrst_n);		//write logic reset
  
  logic [addrsize:0] 		wbin;				//write counter latched output
  logic [addrsize:0]		wgraynext;			//gray code from counter
  logic [addrsize:0]		wbinnext;			//write binary counter adder output
  
  always_ff @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) begin
      wbin <= 0;
      wptr <= 0;
    end
    else begin
      wbin <= wbinnext;
      wptr <= wgraynext;
    end
  end
  
  // Memory write-address pointer
  assign waddr = wbin[addrsize-1:0];
  assign wbinnext = wbin + (winc & ~wfull);
  assign wgraynext = (wbinnext>>1) ^ wbinnext;
  
  //------------------------------------------------------------------
  // Simplified version of the three necessary full-tests:
  // assign wfull_val=((wgnext[ADDRSIZE] !=wq2_rptr[ADDRSIZE] ) &&
  // (wgnext[ADDRSIZE-1] !=wq2_rptr[ADDRSIZE-1]) &&
  // (wgnext[ADDRSIZE-2:0]==wq2_rptr[ADDRSIZE-2:0]));
  //------------------------------------------------------------------
  
  assign wfull_val = (wgraynext=={~wq2_rptr[addrsize:addrsize-1],wq2_rptr[addrsize-2:0]});
  
  always_ff @(posedge wclk or negedge wrst_n)
    if (!wrst_n)
      wfull <= 1'b0;
  else 
    wfull <= wfull_val;
endmodule

   































