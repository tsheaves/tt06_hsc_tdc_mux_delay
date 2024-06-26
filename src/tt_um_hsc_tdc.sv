`define default_netname none
// `timescale 1ns/1ps
module tt_um_hsc_tdc (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output reg  [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

assign uio_oe = 8'hFF;
assign uio_out = 8'h00;

localparam DL_TYPE = "DMUX";
localparam POP_METHOD = "SV";
localparam N = 64;
localparam N_SYNC = 1;

localparam N_o = $clog2(N);
  
initial begin
  $display("%d", N_o);
end
  
logic
    clk_launch, 
    clk_capture,
    pg_src,
    pg_bypass,
    pg_in,
    pg_tog,
    val_in;

logic [N_o:0]
    hw;

logic
    val_out;

generate
    if(N_o+1 == 7) begin : genblk_uout_full
        always@(*) begin
            uo_out[N_o:0] = hw;
            uo_out[7] = val_out;
        end
    end else if(N_o+1 < 7) begin : genblk_uout_unused
        always@(*) begin
            uo_out[6:N_o+1] = {6-N_o{1'b0}}; 
            uo_out[N_o:0] = hw;
            uo_out[7] = val_out;
        end
    end
endgenerate

// Pin mapping
always@(*) begin
    clk_launch    = ui_in[0];
    clk_capture   = ui_in[1];
    pg_src        = ui_in[2];
    pg_bypass     = ui_in[3];
    pg_in         = ui_in[4];
    pg_tog        = ui_in[5];
    val_in        = ui_in[6];
end

tdc_top #(
    .N(N),
    .DL_TYPE(DL_TYPE),
    .N_SYNC(N_SYNC),
    .POP_METHOD(POP_METHOD)
) tdc_inst (
    .clk_launch(clk_launch),
    .clk_capture(clk_capture),
    .rst(!rst_n),
    .en(ena),
    .val_in(val_in),    
    .pg_src(pg_src),
    .pg_bypass(pg_bypass),
    .pg_in(pg_in),
    .pg_tog(pg_tog),
    .hw(hw),
    .val_out(val_out)
);

endmodule
