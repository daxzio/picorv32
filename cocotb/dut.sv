module dut #(
    integer ENABLE_COUNTERS      = 1
    ,integer ENABLE_COUNTERS64    = 1
    ,integer ENABLE_REGS_16_31    = 1
    ,integer ENABLE_REGS_DUALPORT = 1
    ,integer TWO_STAGE_SHIFT      = 1
    ,integer BARREL_SHIFTER       = 0
    ,integer TWO_CYCLE_COMPARE    = 0
    ,integer TWO_CYCLE_ALU        = 0
    ,integer COMPRESSED_ISA       = 0
    ,integer CATCH_MISALIGN       = 1
    ,integer CATCH_ILLINSN        = 1
    ,integer ENABLE_PCPI          = 0
    ,integer ENABLE_MUL           = 0
    ,integer ENABLE_FAST_MUL      = 0
    ,integer ENABLE_DIV           = 0
    ,integer ENABLE_IRQ           = 0
    ,integer ENABLE_IRQ_QREGS     = 1
    ,integer ENABLE_IRQ_TIMER     = 1
    ,integer ENABLE_TRACE         = 0
    ,integer REGS_INIT_ZERO       = 0
    ,integer MASKED_IRQ          = 32'h0000_0000
    ,integer LATCHED_IRQ          = 32'hffff_ffff
    ,integer PROGADDR_RESET       = 32'h0000_0000
    ,integer PROGADDR_IRQ         = 32'h0000_0010
    ,integer STACKADDR            = 32'hffff_ffff
    ,parameter G_HEXFILE          = "./firmware.hex"
) (
    input  clk,
    input  resetn,
    output trap,

    // AXI4-lite master memory interface

    //     output        mem_axi_awvalid,
    //     input         mem_axi_awready,
    //     output [31:0] mem_axi_awaddr,
    //     output [ 2:0] mem_axi_awprot,
    // 
    //     output        mem_axi_wvalid,
    //     input         mem_axi_wready,
    //     output [31:0] mem_axi_wdata,
    //     output [ 3:0] mem_axi_wstrb,
    // 
    //     input         mem_axi_bvalid,
    //     output        mem_axi_bready,
    // 
    //     output        mem_axi_arvalid,
    //     input         mem_axi_arready,
    //     output [31:0] mem_axi_araddr,
    //     output [ 2:0] mem_axi_arprot,
    // 
    //     input         mem_axi_rvalid,
    //     output        mem_axi_rready,
    //     input  [31:0] mem_axi_rdata,

    //     output        mem_axi_awvalid,
    //     output        mem_axi_awready,
    //     output [31:0] mem_axi_awaddr,
    //     output [ 2:0] mem_axi_awprot,
    // 
    //     output        mem_axi_wvalid,
    //     output         mem_axi_wready,
    //     output [31:0] mem_axi_wdata,
    //     output [ 3:0] mem_axi_wstrb,
    // 
    //     output         mem_axi_bvalid,
    //     output        mem_axi_bready,
    // 
    //     output        mem_axi_arvalid,
    //     output         mem_axi_arready,
    //     output [31:0] mem_axi_araddr,
    //     output [ 2:0] mem_axi_arprot,
    // 
    //     output         mem_axi_rvalid,
    //     output        mem_axi_rready,
    //     output  [31:0] mem_axi_rdata,

    // Pico Co-Processor Interface (PCPI)
    output        pcpi_valid,
    output [31:0] pcpi_insn,
    output [31:0] pcpi_rs1,
    output [31:0] pcpi_rs2,
    input         pcpi_wr,
    input  [31:0] pcpi_rd,
    input         pcpi_wait,
    input         pcpi_ready,

    // IRQ interface
    input  [31:0] irq,
    output [31:0] eoi,

`ifdef RISCV_FORMAL
    output        rvfi_valid,
    output [63:0] rvfi_order,
    output [31:0] rvfi_insn,
    output        rvfi_trap,
    output        rvfi_halt,
    output        rvfi_intr,
    output [ 4:0] rvfi_rs1_addr,
    output [ 4:0] rvfi_rs2_addr,
    output [31:0] rvfi_rs1_rdata,
    output [31:0] rvfi_rs2_rdata,
    output [ 4:0] rvfi_rd_addr,
    output [31:0] rvfi_rd_wdata,
    output [31:0] rvfi_pc_rdata,
    output [31:0] rvfi_pc_wdata,
    output [31:0] rvfi_mem_addr,
    output [ 3:0] rvfi_mem_rmask,
    output [ 3:0] rvfi_mem_wmask,
    output [31:0] rvfi_mem_rdata,
    output [31:0] rvfi_mem_wdata,
`endif

    // Trace Interface
    output        trace_valid,
    output [35:0] trace_data
);


    logic        w_mem_axi_awvalid;
    logic        w_mem_axi_awready;
    logic [31:0] w_mem_axi_awaddr;
    logic [ 2:0] w_mem_axi_awprot;
    logic        w_mem_axi_wvalid;
    logic        w_mem_axi_wready;
    logic [31:0] w_mem_axi_wdata;
    logic [ 3:0] w_mem_axi_wstrb;
    logic        w_mem_axi_bvalid;
    logic        w_mem_axi_bready;
    logic        w_mem_axi_arvalid;
    logic        w_mem_axi_arready;
    logic [31:0] w_mem_axi_araddr;
    logic [ 2:0] w_mem_axi_arprot;
    logic        w_mem_axi_rvalid;
    logic        w_mem_axi_rready;
    logic [31:0] w_mem_axi_rdata;

    picorv32_axi #(
          .ENABLE_IRQ    (1)
        , .ENABLE_TRACE  (1)
        , .ENABLE_MUL    (1)
        , .ENABLE_DIV    (1)
        , .COMPRESSED_ISA(1)
    ) i_picorv32_axi (
        .*
        , .mem_axi_awvalid(w_mem_axi_awvalid)
        , .mem_axi_awready(1'b1)
        , .mem_axi_awaddr (w_mem_axi_awaddr)
        , .mem_axi_awprot (w_mem_axi_awprot)
        , .mem_axi_wvalid (w_mem_axi_wvalid)
        , .mem_axi_wready (w_mem_axi_wready)
        , .mem_axi_wdata  (w_mem_axi_wdata)
        , .mem_axi_wstrb  (w_mem_axi_wstrb)
        , .mem_axi_bvalid (w_mem_axi_bvalid)
        , .mem_axi_bready (w_mem_axi_bready)
        , .mem_axi_arvalid(w_mem_axi_arvalid)
        , .mem_axi_arready(w_mem_axi_arready)
        , .mem_axi_araddr (w_mem_axi_araddr)
        , .mem_axi_arprot (w_mem_axi_arprot)
        , .mem_axi_rvalid (w_mem_axi_rvalid)
        , .mem_axi_rready (w_mem_axi_rready)
        , .mem_axi_rdata  (w_mem_axi_rdata)
    );

    //     assign mem_axi_awvalid =  w_mem_axi_awvalid;
    //     assign mem_axi_awaddr =   w_mem_axi_awaddr;
    //     assign mem_axi_awprot =   w_mem_axi_awprot;
    //     assign mem_axi_wvalid =   w_mem_axi_wvalid;
    //     assign mem_axi_wdata =    w_mem_axi_wdata;
    //     assign mem_axi_wstrb =    w_mem_axi_wstrb;
    //     assign mem_axi_bready =   w_mem_axi_bready;
    //     assign mem_axi_arvalid =  w_mem_axi_arvalid;
    //     assign mem_axi_araddr =   w_mem_axi_araddr;
    //     assign mem_axi_arprot =   w_mem_axi_arprot;
    //     assign mem_axi_rready =   w_mem_axi_rready;
    // 
    // //     assign  w_mem_axi_awready =  mem_axi_awready;
    // //     assign  w_mem_axi_wready =   mem_axi_wready;
    // //     assign  w_mem_axi_bvalid =   mem_axi_bvalid;
    // //     assign  w_mem_axi_arready =  mem_axi_arready;
    // //     assign  w_mem_axi_rvalid =   mem_axi_rvalid;
    // //     assign  w_mem_axi_rdata =    mem_axi_rdata;
    // 
    //     assign  mem_axi_awready =  w_mem_axi_awready;
    //     assign  mem_axi_wready =   w_mem_axi_wready;
    //     assign  mem_axi_bvalid =   w_mem_axi_bvalid;
    //     assign  mem_axi_arready =  w_mem_axi_arready;
    //     assign  mem_axi_rvalid =   w_mem_axi_rvalid;
    //     assign  mem_axi_rdata =    w_mem_axi_rdata;

    axi_memory #(
          .G_ID_WIDTH (1)
        , .G_INIT_FILE(G_HEXFILE)
    ) i_axi_memory (
          .s_aclk        (clk)
        , .s_aresetn     (resetn)
        , .s_axi_awid    (1'b0)
        , .s_axi_awaddr  (w_mem_axi_awaddr)
        , .s_axi_awlen   (8'b0)
        , .s_axi_awsize  (3'b0)
        , .s_axi_awburst (2'b0)
        , .s_axi_awlock  (1'd0)
        , .s_axi_awcache (4'd0)
        , .s_axi_awprot  (w_mem_axi_awprot)
        , .s_axi_awqos   (4'd0)
        , .s_axi_awregion(4'd0)
        , .s_axi_awuser  (1'd0)
        , .s_axi_awvalid (w_mem_axi_awvalid)
        , .s_axi_awready (w_mem_axi_awready)
        , .s_axi_wdata   (w_mem_axi_wdata)
        , .s_axi_wstrb   (w_mem_axi_wstrb)
        , .s_axi_wlast   (1'b1)
        , .s_axi_wuser   (1'd0)
        , .s_axi_wvalid  (w_mem_axi_wvalid)
        , .s_axi_wready  (w_mem_axi_wready)
        , .s_axi_bid     ()
        , .s_axi_bresp   ()
        , .s_axi_buser   ()
        , .s_axi_bvalid  (w_mem_axi_bvalid)
        , .s_axi_bready  (w_mem_axi_bready)
        , .s_axi_arid    (1'b0)
        , .s_axi_araddr  (w_mem_axi_araddr)
        , .s_axi_arlen   (8'b0)
        , .s_axi_arsize  (3'b0)
        , .s_axi_arburst (2'b0)
        , .s_axi_arlock  (1'd0)
        , .s_axi_arcache (4'd0)
        , .s_axi_arprot  (w_mem_axi_arprot)
        , .s_axi_arqos   (4'd0)
        , .s_axi_arregion(4'd0)
        , .s_axi_aruser  (1'd0)
        , .s_axi_arvalid (w_mem_axi_arvalid)
        , .s_axi_arready (w_mem_axi_arready)
        , .s_axi_rid     ()
        , .s_axi_rdata   (w_mem_axi_rdata)
        , .s_axi_rresp   ()
        , .s_axi_rlast   ()
        , .s_axi_ruser   ()
        , .s_axi_rvalid  (w_mem_axi_rvalid)
        , .s_axi_rready  (w_mem_axi_rready)
    );

    //`ifdef COCOTB_SIM
`ifdef COCOTB_ICARUS
    initial begin
        $dumpfile("dut.vcd");
        $dumpvars(0, dut);
        /* verilator lint_off STMTDLY */
        #1;
        /* verilator lint_on STMTDLY */
    end
`endif


endmodule

