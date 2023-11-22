module axi_memory #(
    integer G_DATAWIDTH = 32
    , parameter G_INIT_FILE = ""  // verilog_lint: waive explicit-parameter-storage-type (not supported in vivado)
    , integer G_ID_WIDTH = 4
    , integer G_WEWIDTH = ((G_DATAWIDTH - 1) / 8) + 1
    , integer G_AWUSER_ENABLE = 0
    , integer G_AWUSER_WIDTH = 1
    , integer G_WUSER_ENABLE = 0
    , integer G_WUSER_WIDTH = 1
    , integer G_BUSER_ENABLE = 0
    , integer G_BUSER_WIDTH = 1
    , integer G_ARUSER_ENABLE = 0
    , integer G_ARUSER_WIDTH = 1
    , integer G_RUSER_ENABLE = 0
    , integer G_RUSER_WIDTH = 1
) (
      input                       s_aclk
    , input                       s_aresetn
    , input  [    G_ID_WIDTH-1:0] s_axi_awid
    , input  [              31:0] s_axi_awaddr
    , input  [               7:0] s_axi_awlen
    , input  [               2:0] s_axi_awsize
    , input  [               1:0] s_axi_awburst
    , input                       s_axi_awlock
    , input  [               3:0] s_axi_awcache
    , input  [               2:0] s_axi_awprot
    , input  [               3:0] s_axi_awqos
    , input  [               3:0] s_axi_awregion
    , input  [G_AWUSER_WIDTH-1:0] s_axi_awuser
    , input                       s_axi_awvalid
    , output                      s_axi_awready
    , input  [   G_DATAWIDTH-1:0] s_axi_wdata
    , input  [     G_WEWIDTH-1:0] s_axi_wstrb
    , input                       s_axi_wlast
    , input  [ G_WUSER_WIDTH-1:0] s_axi_wuser
    , input                       s_axi_wvalid
    , output                      s_axi_wready
    , output [    G_ID_WIDTH-1:0] s_axi_bid
    , output [               1:0] s_axi_bresp
    , output [ G_BUSER_WIDTH-1:0] s_axi_buser
    , output                      s_axi_bvalid
    , input                       s_axi_bready
    , input  [    G_ID_WIDTH-1:0] s_axi_arid
    , input  [              31:0] s_axi_araddr
    , input  [               7:0] s_axi_arlen
    , input  [               2:0] s_axi_arsize
    , input  [               1:0] s_axi_arburst
    , input                       s_axi_arlock
    , input  [               3:0] s_axi_arcache
    , input  [               2:0] s_axi_arprot
    , input  [               3:0] s_axi_arqos
    , input  [               3:0] s_axi_arregion
    , input  [G_ARUSER_WIDTH-1:0] s_axi_aruser
    , input                       s_axi_arvalid
    , output                      s_axi_arready
    , output [    G_ID_WIDTH-1:0] s_axi_rid
    , output [   G_DATAWIDTH-1:0] s_axi_rdata
    , output [               1:0] s_axi_rresp
    , output                      s_axi_rlast
    , output [ G_RUSER_WIDTH-1:0] s_axi_ruser
    , output                      s_axi_rvalid
    , input                       s_axi_rready
);

    localparam integer G_SLAVE_AXI = 1;
    localparam integer G_MASTER_AXI = 3;
    localparam integer G_S_ID_WIDTH = 1;
    //localparam integer G_M_ID_WIDTH = G_S_ID_WIDTH + $clog2(G_SLAVE_AXI);
    localparam integer G_M_ID_WIDTH = G_S_ID_WIDTH;

    genvar i;

    logic [                          G_S_ID_WIDTH-1:0] a_axi_awid     [G_SLAVE_AXI-1:0];
    logic [                                      31:0] a_axi_awaddr   [G_SLAVE_AXI-1:0];
    logic [                                       7:0] a_axi_awlen    [G_SLAVE_AXI-1:0];
    logic [                                       2:0] a_axi_awsize   [G_SLAVE_AXI-1:0];
    logic [                                       1:0] a_axi_awburst  [G_SLAVE_AXI-1:0];
    logic                                              a_axi_awlock   [G_SLAVE_AXI-1:0];
    logic [                                       3:0] a_axi_awcache  [G_SLAVE_AXI-1:0];
    logic [                                       2:0] a_axi_awprot   [G_SLAVE_AXI-1:0];
    logic [                                       3:0] a_axi_awregion [G_SLAVE_AXI-1:0];
    logic [                                       3:0] a_axi_awqos    [G_SLAVE_AXI-1:0];
    logic                                              a_axi_awvalid  [G_SLAVE_AXI-1:0];
    logic                                              a_axi_awready  [G_SLAVE_AXI-1:0];
    logic [                                      31:0] a_axi_wdata    [G_SLAVE_AXI-1:0];
    logic [                                       3:0] a_axi_wstrb    [G_SLAVE_AXI-1:0];
    logic                                              a_axi_wlast    [G_SLAVE_AXI-1:0];
    logic                                              a_axi_wvalid   [G_SLAVE_AXI-1:0];
    logic                                              a_axi_wready   [G_SLAVE_AXI-1:0];
    logic [                          G_S_ID_WIDTH-1:0] a_axi_bid      [G_SLAVE_AXI-1:0];
    logic [                                       1:0] a_axi_bresp    [G_SLAVE_AXI-1:0];
    logic                                              a_axi_bvalid   [G_SLAVE_AXI-1:0];
    logic                                              a_axi_bready   [G_SLAVE_AXI-1:0];
    logic [                          G_S_ID_WIDTH-1:0] a_axi_arid     [G_SLAVE_AXI-1:0];
    logic [                                      31:0] a_axi_araddr   [G_SLAVE_AXI-1:0];
    logic [                                       7:0] a_axi_arlen    [G_SLAVE_AXI-1:0];
    logic [                                       2:0] a_axi_arsize   [G_SLAVE_AXI-1:0];
    logic [                                       1:0] a_axi_arburst  [G_SLAVE_AXI-1:0];
    logic                                              a_axi_arlock   [G_SLAVE_AXI-1:0];
    logic [                                       3:0] a_axi_arcache  [G_SLAVE_AXI-1:0];
    logic [                                       2:0] a_axi_arprot   [G_SLAVE_AXI-1:0];
    logic [                                       3:0] a_axi_arregion [G_SLAVE_AXI-1:0];
    logic [                                       3:0] a_axi_arqos    [G_SLAVE_AXI-1:0];
    logic                                              a_axi_arvalid  [G_SLAVE_AXI-1:0];
    logic                                              a_axi_arready  [G_SLAVE_AXI-1:0];
    logic [                          G_S_ID_WIDTH-1:0] a_axi_rid      [G_SLAVE_AXI-1:0];
    logic [                                      31:0] a_axi_rdata    [G_SLAVE_AXI-1:0];
    logic [                                       1:0] a_axi_rresp    [G_SLAVE_AXI-1:0];
    logic                                              a_axi_rlast    [G_SLAVE_AXI-1:0];
    logic                                              a_axi_rvalid   [G_SLAVE_AXI-1:0];
    logic                                              a_axi_rready   [G_SLAVE_AXI-1:0];

    logic [    ($bits(a_axi_awid[0])*G_SLAVE_AXI)-1:0] y_axi_awid;
    logic [  ($bits(a_axi_awaddr[0])*G_SLAVE_AXI)-1:0] y_axi_awaddr;
    logic [   ($bits(a_axi_awlen[0])*G_SLAVE_AXI)-1:0] y_axi_awlen;
    logic [  ($bits(a_axi_awsize[0])*G_SLAVE_AXI)-1:0] y_axi_awsize;
    logic [ ($bits(a_axi_awburst[0])*G_SLAVE_AXI)-1:0] y_axi_awburst;
    logic [  ($bits(a_axi_awlock[0])*G_SLAVE_AXI)-1:0] y_axi_awlock;
    logic [ ($bits(a_axi_awcache[0])*G_SLAVE_AXI)-1:0] y_axi_awcache;
    logic [  ($bits(a_axi_awprot[0])*G_SLAVE_AXI)-1:0] y_axi_awprot;
    logic [($bits(a_axi_awregion[0])*G_SLAVE_AXI)-1:0] y_axi_awregion;
    logic [   ($bits(a_axi_awqos[0])*G_SLAVE_AXI)-1:0] y_axi_awqos;
    logic [ ($bits(a_axi_awvalid[0])*G_SLAVE_AXI)-1:0] y_axi_awvalid;
    logic [ ($bits(a_axi_awready[0])*G_SLAVE_AXI)-1:0] y_axi_awready;
    logic [   ($bits(a_axi_wdata[0])*G_SLAVE_AXI)-1:0] y_axi_wdata;
    logic [   ($bits(a_axi_wstrb[0])*G_SLAVE_AXI)-1:0] y_axi_wstrb;
    logic [   ($bits(a_axi_wlast[0])*G_SLAVE_AXI)-1:0] y_axi_wlast;
    logic [  ($bits(a_axi_wvalid[0])*G_SLAVE_AXI)-1:0] y_axi_wvalid;
    logic [  ($bits(a_axi_wready[0])*G_SLAVE_AXI)-1:0] y_axi_wready;
    logic [     ($bits(a_axi_bid[0])*G_SLAVE_AXI)-1:0] y_axi_bid;
    logic [   ($bits(a_axi_bresp[0])*G_SLAVE_AXI)-1:0] y_axi_bresp;
    logic [  ($bits(a_axi_bvalid[0])*G_SLAVE_AXI)-1:0] y_axi_bvalid;
    logic [  ($bits(a_axi_bready[0])*G_SLAVE_AXI)-1:0] y_axi_bready;
    logic [    ($bits(a_axi_arid[0])*G_SLAVE_AXI)-1:0] y_axi_arid;
    logic [  ($bits(a_axi_araddr[0])*G_SLAVE_AXI)-1:0] y_axi_araddr;
    logic [   ($bits(a_axi_arlen[0])*G_SLAVE_AXI)-1:0] y_axi_arlen;
    logic [  ($bits(a_axi_arsize[0])*G_SLAVE_AXI)-1:0] y_axi_arsize;
    logic [ ($bits(a_axi_arburst[0])*G_SLAVE_AXI)-1:0] y_axi_arburst;
    logic [  ($bits(a_axi_arlock[0])*G_SLAVE_AXI)-1:0] y_axi_arlock;
    logic [ ($bits(a_axi_arcache[0])*G_SLAVE_AXI)-1:0] y_axi_arcache;
    logic [  ($bits(a_axi_arprot[0])*G_SLAVE_AXI)-1:0] y_axi_arprot;
    logic [($bits(a_axi_arregion[0])*G_SLAVE_AXI)-1:0] y_axi_arregion;
    logic [   ($bits(a_axi_arqos[0])*G_SLAVE_AXI)-1:0] y_axi_arqos;
    logic [ ($bits(a_axi_arvalid[0])*G_SLAVE_AXI)-1:0] y_axi_arvalid;
    logic [ ($bits(a_axi_arready[0])*G_SLAVE_AXI)-1:0] y_axi_arready;
    logic [     ($bits(a_axi_rid[0])*G_SLAVE_AXI)-1:0] y_axi_rid;
    logic [   ($bits(a_axi_rdata[0])*G_SLAVE_AXI)-1:0] y_axi_rdata;
    logic [   ($bits(a_axi_rresp[0])*G_SLAVE_AXI)-1:0] y_axi_rresp;
    logic [   ($bits(a_axi_rlast[0])*G_SLAVE_AXI)-1:0] y_axi_rlast;
    logic [  ($bits(a_axi_rvalid[0])*G_SLAVE_AXI)-1:0] y_axi_rvalid;
    logic [  ($bits(a_axi_rready[0])*G_SLAVE_AXI)-1:0] y_axi_rready;

    generate
        for (i = 0; i < G_SLAVE_AXI; i = i + 1) begin : g_axi_mapping_vector
            assign y_axi_awid[($bits(a_axi_awid[0])*i)+:($bits(a_axi_awid[0]))] = a_axi_awid[i];
            assign y_axi_awaddr[($bits(a_axi_awaddr[0])*i)+:($bits(a_axi_awaddr[0]))] = a_axi_awaddr[i];
            assign y_axi_awlen[($bits(a_axi_awlen[0])*i)+:($bits(a_axi_awlen[0]))] = a_axi_awlen[i];
            assign y_axi_awsize[($bits(a_axi_awsize[0])*i)+:($bits(a_axi_awsize[0]))] = a_axi_awsize[i];
            assign y_axi_awburst[($bits(a_axi_awburst[0])*i)+:($bits(a_axi_awburst[0]))] = a_axi_awburst[i];
            assign y_axi_awlock[($bits(a_axi_awlock[0])*i)+:($bits(a_axi_awlock[0]))] = a_axi_awlock[i];
            assign y_axi_awcache[($bits(a_axi_awcache[0])*i)+:($bits(a_axi_awcache[0]))] = a_axi_awcache[i];
            assign y_axi_awprot[($bits(a_axi_awprot[0])*i)+:($bits(a_axi_awprot[0]))] = a_axi_awprot[i];
            assign y_axi_awregion[($bits(a_axi_awregion[0])*i)+:($bits(a_axi_awregion[0]))] = a_axi_awregion[i];
            assign y_axi_awqos[($bits(a_axi_awqos[0])*i)+:($bits(a_axi_awqos[0]))] = a_axi_awqos[i];
            assign y_axi_awvalid[($bits(a_axi_awvalid[0])*i)+:($bits(a_axi_awvalid[0]))] = a_axi_awvalid[i];
            assign a_axi_awready[i] = y_axi_awready[($bits(a_axi_awready[0])*i)+:($bits(a_axi_awready[0]))];
            assign y_axi_wdata[($bits(a_axi_wdata[0])*i)+:($bits(a_axi_wdata[0]))] = a_axi_wdata[i];
            assign y_axi_wstrb[($bits(a_axi_wstrb[0])*i)+:($bits(a_axi_wstrb[0]))] = a_axi_wstrb[i];
            assign y_axi_wlast[($bits(a_axi_wlast[0])*i)+:($bits(a_axi_wlast[0]))] = a_axi_wlast[i];
            assign y_axi_wvalid[($bits(a_axi_wvalid[0])*i)+:($bits(a_axi_wvalid[0]))] = a_axi_wvalid[i];
            assign a_axi_wready[i] = y_axi_wready[($bits(a_axi_wready[0])*i)+:($bits(a_axi_wready[0]))];
            assign a_axi_bid[i] = y_axi_bid[($bits(a_axi_bid[0])*i)+:($bits(a_axi_bid[0]))];
            assign a_axi_bresp[i] = y_axi_bresp[($bits(a_axi_bresp[0])*i)+:($bits(a_axi_bresp[0]))];
            assign a_axi_bvalid[i] = y_axi_bvalid[($bits(a_axi_bvalid[0])*i)+:($bits(a_axi_bvalid[0]))];
            assign y_axi_bready[($bits(a_axi_bready[0])*i)+:($bits(a_axi_bready[0]))] = a_axi_bready[i];
            assign y_axi_arid[($bits(a_axi_arid[0])*i)+:($bits(a_axi_arid[0]))] = a_axi_arid[i];
            assign y_axi_araddr[($bits(a_axi_araddr[0])*i)+:($bits(a_axi_araddr[0]))] = a_axi_araddr[i];
            assign y_axi_arlen[($bits(a_axi_arlen[0])*i)+:($bits(a_axi_arlen[0]))] = a_axi_arlen[i];
            assign y_axi_arsize[($bits(a_axi_arsize[0])*i)+:($bits(a_axi_arsize[0]))] = a_axi_arsize[i];
            assign y_axi_arburst[($bits(a_axi_arburst[0])*i)+:($bits(a_axi_arburst[0]))] = a_axi_arburst[i];
            assign y_axi_arlock[($bits(a_axi_arlock[0])*i)+:($bits(a_axi_arlock[0]))] = a_axi_arlock[i];
            assign y_axi_arcache[($bits(a_axi_arcache[0])*i)+:($bits(a_axi_arcache[0]))] = a_axi_arcache[i];
            assign y_axi_arprot[($bits(a_axi_arprot[0])*i)+:($bits(a_axi_arprot[0]))] = a_axi_arprot[i];
            assign y_axi_arregion[($bits(a_axi_arregion[0])*i)+:($bits(a_axi_arregion[0]))] = a_axi_arregion[i];
            assign y_axi_arqos[($bits(a_axi_arqos[0])*i)+:($bits(a_axi_arqos[0]))] = a_axi_arqos[i];
            assign y_axi_arvalid[($bits(a_axi_arvalid[0])*i)+:($bits(a_axi_arvalid[0]))] = a_axi_arvalid[i];
            assign a_axi_arready[i] = y_axi_arready[($bits(a_axi_arready[0])*i)+:($bits(a_axi_arready[0]))];
            assign a_axi_rid[i] = y_axi_rid[($bits(a_axi_rid[0])*i)+:($bits(a_axi_rid[0]))];
            assign a_axi_rdata[i] = y_axi_rdata[($bits(a_axi_rdata[0])*i)+:($bits(a_axi_rdata[0]))];
            assign a_axi_rresp[i] = y_axi_rresp[($bits(a_axi_rresp[0])*i)+:($bits(a_axi_rresp[0]))];
            assign a_axi_rlast[i] = y_axi_rlast[($bits(a_axi_rlast[0])*i)+:($bits(a_axi_rlast[0]))];
            assign a_axi_rvalid[i] = y_axi_rvalid[($bits(a_axi_rvalid[0])*i)+:($bits(a_axi_rvalid[0]))];
            assign y_axi_rready[($bits(a_axi_rready[0])*i)+:($bits(a_axi_rready[0]))] = a_axi_rready[i];
        end
    endgenerate

    logic [                           G_M_ID_WIDTH-1:0] b_axi_awid     [G_MASTER_AXI-1:0];
    logic [                                       31:0] b_axi_awaddr   [G_MASTER_AXI-1:0];
    logic [                                        7:0] b_axi_awlen    [G_MASTER_AXI-1:0];
    logic [                                        2:0] b_axi_awsize   [G_MASTER_AXI-1:0];
    logic [                                        1:0] b_axi_awburst  [G_MASTER_AXI-1:0];
    logic                                               b_axi_awlock   [G_MASTER_AXI-1:0];
    logic [                                        3:0] b_axi_awcache  [G_MASTER_AXI-1:0];
    logic [                                        2:0] b_axi_awprot   [G_MASTER_AXI-1:0];
    logic [                                        3:0] b_axi_awregion [G_MASTER_AXI-1:0];
    logic [                                        3:0] b_axi_awqos    [G_MASTER_AXI-1:0];
    logic                                               b_axi_awvalid  [G_MASTER_AXI-1:0];
    logic                                               b_axi_awready  [G_MASTER_AXI-1:0];
    logic [                                       31:0] b_axi_wdata    [G_MASTER_AXI-1:0];
    logic [                                        3:0] b_axi_wstrb    [G_MASTER_AXI-1:0];
    logic                                               b_axi_wlast    [G_MASTER_AXI-1:0];
    logic                                               b_axi_wvalid   [G_MASTER_AXI-1:0];
    logic                                               b_axi_wready   [G_MASTER_AXI-1:0];
    logic [                           G_M_ID_WIDTH-1:0] b_axi_bid      [G_MASTER_AXI-1:0];
    logic [                                        1:0] b_axi_bresp    [G_MASTER_AXI-1:0];
    logic                                               b_axi_bvalid   [G_MASTER_AXI-1:0];
    logic                                               b_axi_bready   [G_MASTER_AXI-1:0];
    logic [                           G_M_ID_WIDTH-1:0] b_axi_arid     [G_MASTER_AXI-1:0];
    logic [                                       31:0] b_axi_araddr   [G_MASTER_AXI-1:0];
    logic [                                        7:0] b_axi_arlen    [G_MASTER_AXI-1:0];
    logic [                                        2:0] b_axi_arsize   [G_MASTER_AXI-1:0];
    logic [                                        1:0] b_axi_arburst  [G_MASTER_AXI-1:0];
    logic                                               b_axi_arlock   [G_MASTER_AXI-1:0];
    logic [                                        3:0] b_axi_arcache  [G_MASTER_AXI-1:0];
    logic [                                        2:0] b_axi_arprot   [G_MASTER_AXI-1:0];
    logic [                                        3:0] b_axi_arregion [G_MASTER_AXI-1:0];
    logic [                                        3:0] b_axi_arqos    [G_MASTER_AXI-1:0];
    logic                                               b_axi_arvalid  [G_MASTER_AXI-1:0];
    logic                                               b_axi_arready  [G_MASTER_AXI-1:0];
    logic [                           G_M_ID_WIDTH-1:0] b_axi_rid      [G_MASTER_AXI-1:0];
    logic [                                       31:0] b_axi_rdata    [G_MASTER_AXI-1:0];
    logic [                                        1:0] b_axi_rresp    [G_MASTER_AXI-1:0];
    logic                                               b_axi_rlast    [G_MASTER_AXI-1:0];
    logic                                               b_axi_rvalid   [G_MASTER_AXI-1:0];
    logic                                               b_axi_rready   [G_MASTER_AXI-1:0];

    logic [    ($bits(b_axi_awid[0])*G_MASTER_AXI)-1:0] x_axi_awid;
    logic [  ($bits(b_axi_awaddr[0])*G_MASTER_AXI)-1:0] x_axi_awaddr;
    logic [   ($bits(b_axi_awlen[0])*G_MASTER_AXI)-1:0] x_axi_awlen;
    logic [  ($bits(b_axi_awsize[0])*G_MASTER_AXI)-1:0] x_axi_awsize;
    logic [ ($bits(b_axi_awburst[0])*G_MASTER_AXI)-1:0] x_axi_awburst;
    logic [  ($bits(b_axi_awlock[0])*G_MASTER_AXI)-1:0] x_axi_awlock;
    logic [ ($bits(b_axi_awcache[0])*G_MASTER_AXI)-1:0] x_axi_awcache;
    logic [  ($bits(b_axi_awprot[0])*G_MASTER_AXI)-1:0] x_axi_awprot;
    logic [($bits(b_axi_awregion[0])*G_MASTER_AXI)-1:0] x_axi_awregion;
    logic [   ($bits(b_axi_awqos[0])*G_MASTER_AXI)-1:0] x_axi_awqos;
    logic [ ($bits(b_axi_awvalid[0])*G_MASTER_AXI)-1:0] x_axi_awvalid;
    logic [ ($bits(b_axi_awready[0])*G_MASTER_AXI)-1:0] x_axi_awready;
    logic [   ($bits(b_axi_wdata[0])*G_MASTER_AXI)-1:0] x_axi_wdata;
    logic [   ($bits(b_axi_wstrb[0])*G_MASTER_AXI)-1:0] x_axi_wstrb;
    logic [   ($bits(b_axi_wlast[0])*G_MASTER_AXI)-1:0] x_axi_wlast;
    logic [  ($bits(b_axi_wvalid[0])*G_MASTER_AXI)-1:0] x_axi_wvalid;
    logic [  ($bits(b_axi_wready[0])*G_MASTER_AXI)-1:0] x_axi_wready;
    logic [     ($bits(b_axi_bid[0])*G_MASTER_AXI)-1:0] x_axi_bid;
    logic [   ($bits(b_axi_bresp[0])*G_MASTER_AXI)-1:0] x_axi_bresp;
    logic [  ($bits(b_axi_bvalid[0])*G_MASTER_AXI)-1:0] x_axi_bvalid;
    logic [  ($bits(b_axi_bready[0])*G_MASTER_AXI)-1:0] x_axi_bready;
    logic [    ($bits(b_axi_arid[0])*G_MASTER_AXI)-1:0] x_axi_arid;
    logic [  ($bits(b_axi_araddr[0])*G_MASTER_AXI)-1:0] x_axi_araddr;
    logic [   ($bits(b_axi_arlen[0])*G_MASTER_AXI)-1:0] x_axi_arlen;
    logic [  ($bits(b_axi_arsize[0])*G_MASTER_AXI)-1:0] x_axi_arsize;
    logic [ ($bits(b_axi_arburst[0])*G_MASTER_AXI)-1:0] x_axi_arburst;
    logic [  ($bits(b_axi_arlock[0])*G_MASTER_AXI)-1:0] x_axi_arlock;
    logic [ ($bits(b_axi_arcache[0])*G_MASTER_AXI)-1:0] x_axi_arcache;
    logic [  ($bits(b_axi_arprot[0])*G_MASTER_AXI)-1:0] x_axi_arprot;
    logic [($bits(b_axi_arregion[0])*G_MASTER_AXI)-1:0] x_axi_arregion;
    logic [   ($bits(b_axi_arqos[0])*G_MASTER_AXI)-1:0] x_axi_arqos;
    logic [ ($bits(b_axi_arvalid[0])*G_MASTER_AXI)-1:0] x_axi_arvalid;
    logic [ ($bits(b_axi_arready[0])*G_MASTER_AXI)-1:0] x_axi_arready;
    logic [     ($bits(b_axi_rid[0])*G_MASTER_AXI)-1:0] x_axi_rid;
    logic [   ($bits(b_axi_rdata[0])*G_MASTER_AXI)-1:0] x_axi_rdata;
    logic [   ($bits(b_axi_rresp[0])*G_MASTER_AXI)-1:0] x_axi_rresp;
    logic [   ($bits(b_axi_rlast[0])*G_MASTER_AXI)-1:0] x_axi_rlast;
    logic [  ($bits(b_axi_rvalid[0])*G_MASTER_AXI)-1:0] x_axi_rvalid;
    logic [  ($bits(b_axi_rready[0])*G_MASTER_AXI)-1:0] x_axi_rready;


    generate
        for (i = 0; i < G_MASTER_AXI; i = i + 1) begin : g_axi_mapping_array
            assign b_axi_awid[i] = x_axi_awid[($bits(b_axi_awid[0])*i)+:($bits(b_axi_awid[0]))];
            assign b_axi_awaddr[i] = x_axi_awaddr[($bits(b_axi_awaddr[0])*i)+:($bits(b_axi_awaddr[0]))];
            assign b_axi_awlen[i] = x_axi_awlen[($bits(b_axi_awlen[0])*i)+:($bits(b_axi_awlen[0]))];
            assign b_axi_awsize[i] = x_axi_awsize[($bits(b_axi_awsize[0])*i)+:($bits(b_axi_awsize[0]))];
            assign b_axi_awburst[i] = x_axi_awburst[($bits(b_axi_awburst[0])*i)+:($bits(b_axi_awburst[0]))];
            assign b_axi_awlock[i] = x_axi_awlock[($bits(b_axi_awlock[0])*i)+:($bits(b_axi_awlock[0]))];
            assign b_axi_awcache[i] = x_axi_awcache[($bits(b_axi_awcache[0])*i)+:($bits(b_axi_awcache[0]))];
            assign b_axi_awprot[i] = x_axi_awprot[($bits(b_axi_awprot[0])*i)+:($bits(b_axi_awprot[0]))];
            assign b_axi_awregion[i] = x_axi_awregion[($bits(b_axi_awregion[0])*i)+:($bits(b_axi_awregion[0]))];
            assign b_axi_awqos[i] = x_axi_awqos[($bits(b_axi_awqos[0])*i)+:($bits(b_axi_awqos[0]))];
            assign b_axi_awvalid[i] = x_axi_awvalid[($bits(b_axi_awvalid[0])*i)+:($bits(b_axi_awvalid[0]))];
            assign x_axi_awready[($bits(b_axi_awready[0])*i)+:($bits(b_axi_awready[0]))] = b_axi_awready[i];
            assign b_axi_wdata[i] = x_axi_wdata[($bits(b_axi_wdata[0])*i)+:($bits(b_axi_wdata[0]))];
            assign b_axi_wstrb[i] = x_axi_wstrb[($bits(b_axi_wstrb[0])*i)+:($bits(b_axi_wstrb[0]))];
            assign b_axi_wlast[i] = x_axi_wlast[($bits(b_axi_wlast[0])*i)+:($bits(b_axi_wlast[0]))];
            assign b_axi_wvalid[i] = x_axi_wvalid[($bits(b_axi_wvalid[0])*i)+:($bits(b_axi_wvalid[0]))];
            assign x_axi_wready[($bits(b_axi_wready[0])*i)+:($bits(b_axi_wready[0]))] = b_axi_wready[i];
            assign x_axi_bid[($bits(b_axi_bid[0])*i)+:($bits(b_axi_bid[0]))] = b_axi_bid[i];
            assign x_axi_bresp[($bits(b_axi_bresp[0])*i)+:($bits(b_axi_bresp[0]))] = b_axi_bresp[i];
            assign x_axi_bvalid[($bits(b_axi_bvalid[0])*i)+:($bits(b_axi_bvalid[0]))] = b_axi_bvalid[i];
            assign b_axi_bready[i] = x_axi_bready[($bits(b_axi_bready[0])*i)+:($bits(b_axi_bready[0]))];
            assign b_axi_arid[i] = x_axi_arid[($bits(b_axi_arid[0])*i)+:($bits(b_axi_arid[0]))];
            assign b_axi_araddr[i] = x_axi_araddr[($bits(b_axi_araddr[0])*i)+:($bits(b_axi_araddr[0]))];
            assign b_axi_arlen[i] = x_axi_arlen[($bits(b_axi_arlen[0])*i)+:($bits(b_axi_arlen[0]))];
            assign b_axi_arsize[i] = x_axi_arsize[($bits(b_axi_arsize[0])*i)+:($bits(b_axi_arsize[0]))];
            assign b_axi_arburst[i] = x_axi_arburst[($bits(b_axi_arburst[0])*i)+:($bits(b_axi_arburst[0]))];
            assign b_axi_arlock[i] = x_axi_arlock[($bits(b_axi_arlock[0])*i)+:($bits(b_axi_arlock[0]))];
            assign b_axi_arcache[i] = x_axi_arcache[($bits(b_axi_arcache[0])*i)+:($bits(b_axi_arcache[0]))];
            assign b_axi_arprot[i] = x_axi_arprot[($bits(b_axi_arprot[0])*i)+:($bits(b_axi_arprot[0]))];
            assign b_axi_arregion[i] = x_axi_arregion[($bits(b_axi_arregion[0])*i)+:($bits(b_axi_arregion[0]))];
            assign b_axi_arqos[i] = x_axi_arqos[($bits(b_axi_arqos[0])*i)+:($bits(b_axi_arqos[0]))];
            assign b_axi_arvalid[i] = x_axi_arvalid[($bits(b_axi_arvalid[0])*i)+:($bits(b_axi_arvalid[0]))];
            assign x_axi_arready[($bits(b_axi_arready[0])*i)+:($bits(b_axi_arready[0]))] = b_axi_arready[i];
            assign x_axi_rid[($bits(b_axi_rid[0])*i)+:($bits(b_axi_rid[0]))] = b_axi_rid[i];
            assign x_axi_rdata[($bits(b_axi_rdata[0])*i)+:($bits(b_axi_rdata[0]))] = b_axi_rdata[i];
            assign x_axi_rresp[($bits(b_axi_rresp[0])*i)+:($bits(b_axi_rresp[0]))] = b_axi_rresp[i];
            assign x_axi_rlast[($bits(b_axi_rlast[0])*i)+:($bits(b_axi_rlast[0]))] = b_axi_rlast[i];
            assign x_axi_rvalid[($bits(b_axi_rvalid[0])*i)+:($bits(b_axi_rvalid[0]))] = b_axi_rvalid[i];
            assign b_axi_rready[i] = x_axi_rready[($bits(b_axi_rready[0])*i)+:($bits(b_axi_rready[0]))];
        end
    endgenerate

    assign a_axi_awid[0]     = s_axi_awid;
    assign a_axi_awaddr[0]   = s_axi_awaddr;
    assign a_axi_awlen[0]    = s_axi_awlen;
    assign a_axi_awsize[0]   = s_axi_awsize;
    assign a_axi_awburst[0]  = s_axi_awburst;
    assign a_axi_awlock[0]   = s_axi_awlock;
    assign a_axi_awcache[0]  = s_axi_awcache;
    assign a_axi_awprot[0]   = s_axi_awprot;
    assign a_axi_awregion[0] = 0;
    assign a_axi_awqos[0]    = s_axi_awqos;
    assign a_axi_awvalid[0]  = s_axi_awvalid;
    assign s_axi_awready     = a_axi_awready[0];
    assign a_axi_wdata[0]    = s_axi_wdata;
    assign a_axi_wstrb[0]    = s_axi_wstrb;
    assign a_axi_wlast[0]    = s_axi_wlast;
    assign a_axi_wvalid[0]   = s_axi_wvalid;
    assign s_axi_wready      = a_axi_wready[0];
    assign s_axi_bid         = a_axi_bid[0];
    assign s_axi_bresp       = a_axi_bresp[0];
    assign s_axi_bvalid      = a_axi_bvalid[0];
    assign a_axi_bready[0]   = s_axi_bready;
    assign a_axi_arid[0]     = s_axi_arid;
    assign a_axi_araddr[0]   = s_axi_araddr;
    assign a_axi_arlen[0]    = s_axi_arlen;
    assign a_axi_arsize[0]   = s_axi_arsize;
    assign a_axi_arburst[0]  = s_axi_arburst;
    assign a_axi_arlock[0]   = s_axi_arlock;
    assign a_axi_arcache[0]  = s_axi_arcache;
    assign a_axi_arprot[0]   = s_axi_arprot;
    assign a_axi_arregion[0] = 0;
    assign a_axi_arqos[0]    = s_axi_arqos;
    assign a_axi_arvalid[0]  = s_axi_arvalid;
    assign s_axi_arready     = a_axi_arready[0];
    assign s_axi_rid         = a_axi_rid[0];
    assign s_axi_rdata       = a_axi_rdata[0];
    assign s_axi_rresp       = a_axi_rresp[0];
    assign s_axi_rlast       = a_axi_rlast[0];
    assign s_axi_rvalid      = a_axi_rvalid[0];
    assign a_axi_rready[0]   = s_axi_rready;

    localparam logic [(32*16)-1:0] w_address_map = {
        32'hf0000000,
        32'he0000000,
        32'hd0000000,
        32'hc0000000,
        32'hb0000000,
        32'ha0000000,
        32'h90000000,
        32'h80000000,
        32'h70000000,
        32'h60000000,
        32'h50000000,
        32'h40000000,
        32'h30000000,
        32'h20000000,
        32'h10000000,
        32'h00000000
    };
    localparam logic [(32*16)-1:0] w_address_width = {
        32'd20,
        32'd20,
        32'd20,
        32'd20,
        32'd20,
        32'd20,
        32'd20,
        32'd20,
        32'd20,
        32'd20,
        32'd20,
        32'd20,
        32'd20,
        32'd28,
        32'd28,
        32'd28
    };

    axi_interconnect_wrapper #(
          .G_USEIP       (0)
        , .G_SLAVE_AXI   (G_SLAVE_AXI)
        , .G_MASTER_AXI  (G_MASTER_AXI)
        , .G_S_ID_WIDTH  (G_S_ID_WIDTH)
        , .G_M_BASE_ADDR (w_address_map[0+:32*G_MASTER_AXI])
        , .G_M_ADDR_WIDTH(w_address_width[0+:32*G_MASTER_AXI])
    ) i_axi_interconnect (
          .aclk          (s_aclk)
        , .aresetn       (w_aresetn)
        , .s_axi_awid    (y_axi_awid)
        , .s_axi_awaddr  (y_axi_awaddr)
        , .s_axi_awlen   (y_axi_awlen)
        , .s_axi_awsize  (y_axi_awsize)
        , .s_axi_awburst (y_axi_awburst)
        , .s_axi_awlock  (y_axi_awlock)
        , .s_axi_awcache (y_axi_awcache)
        , .s_axi_awprot  (y_axi_awprot)
        , .s_axi_awregion(y_axi_awregion)
        , .s_axi_awqos   (y_axi_awqos)
        , .s_axi_awuser  ({G_SLAVE_AXI{1'b0}})
        , .s_axi_awvalid (y_axi_awvalid)
        , .s_axi_awready (y_axi_awready)
        , .s_axi_wdata   (y_axi_wdata)
        , .s_axi_wstrb   (y_axi_wstrb)
        , .s_axi_wlast   (y_axi_wlast)
        , .s_axi_wuser   ({G_SLAVE_AXI{1'b0}})
        , .s_axi_wvalid  (y_axi_wvalid)
        , .s_axi_wready  (y_axi_wready)
        , .s_axi_bid     (y_axi_bid)
        , .s_axi_bresp   (y_axi_bresp)
        , .s_axi_buser   ()
        , .s_axi_bvalid  (y_axi_bvalid)
        , .s_axi_bready  (y_axi_bready)
        , .s_axi_arid    (y_axi_arid)
        , .s_axi_araddr  (y_axi_araddr)
        , .s_axi_arlen   (y_axi_arlen)
        , .s_axi_arsize  (y_axi_arsize)
        , .s_axi_arburst (y_axi_arburst)
        , .s_axi_arlock  (y_axi_arlock)
        , .s_axi_arcache (y_axi_arcache)
        , .s_axi_arprot  (y_axi_arprot)
        , .s_axi_arregion(y_axi_arregion)
        , .s_axi_arqos   (y_axi_arqos)
        , .s_axi_aruser  ({G_SLAVE_AXI{1'b0}})
        , .s_axi_arvalid (y_axi_arvalid)
        , .s_axi_arready (y_axi_arready)
        , .s_axi_rid     (y_axi_rid)
        , .s_axi_rdata   (y_axi_rdata)
        , .s_axi_rresp   (y_axi_rresp)
        , .s_axi_rlast   (y_axi_rlast)
        , .s_axi_ruser   ()
        , .s_axi_rvalid  (y_axi_rvalid)
        , .s_axi_rready  (y_axi_rready)
        , .m_axi_awid    (x_axi_awid)
        , .m_axi_awaddr  (x_axi_awaddr)
        , .m_axi_awlen   (x_axi_awlen)
        , .m_axi_awsize  (x_axi_awsize)
        , .m_axi_awburst (x_axi_awburst)
        , .m_axi_awlock  (x_axi_awlock)
        , .m_axi_awcache (x_axi_awcache)
        , .m_axi_awprot  (x_axi_awprot)
        , .m_axi_awregion(x_axi_awregion)
        , .m_axi_awqos   (x_axi_awqos)
        , .m_axi_awuser  ()
        , .m_axi_awvalid (x_axi_awvalid)
        , .m_axi_awready (x_axi_awready)
        , .m_axi_wdata   (x_axi_wdata)
        , .m_axi_wstrb   (x_axi_wstrb)
        , .m_axi_wlast   (x_axi_wlast)
        , .m_axi_wuser   ()
        , .m_axi_wvalid  (x_axi_wvalid)
        , .m_axi_wready  (x_axi_wready)
        , .m_axi_bid     (x_axi_bid)
        , .m_axi_bresp   (x_axi_bresp)
        , .m_axi_buser   ({G_MASTER_AXI{1'b0}})
        , .m_axi_bvalid  (x_axi_bvalid)
        , .m_axi_bready  (x_axi_bready)
        , .m_axi_arid    (x_axi_arid)
        , .m_axi_araddr  (x_axi_araddr)
        , .m_axi_arlen   (x_axi_arlen)
        , .m_axi_arsize  (x_axi_arsize)
        , .m_axi_arburst (x_axi_arburst)
        , .m_axi_arlock  (x_axi_arlock)
        , .m_axi_arcache (x_axi_arcache)
        , .m_axi_arprot  (x_axi_arprot)
        , .m_axi_arregion(x_axi_arregion)
        , .m_axi_arqos   (x_axi_arqos)
        , .m_axi_aruser  ()
        , .m_axi_arvalid (x_axi_arvalid)
        , .m_axi_arready (x_axi_arready)
        , .m_axi_rid     (x_axi_rid)
        , .m_axi_rdata   (x_axi_rdata)
        , .m_axi_rresp   (x_axi_rresp)
        , .m_axi_rlast   (x_axi_rlast)
        , .m_axi_ruser   ({G_MASTER_AXI{1'b0}})
        , .m_axi_rvalid  (x_axi_rvalid)
        , .m_axi_rready  (x_axi_rready)
    );

    generate
        for (i = 1; i < G_MASTER_AXI; i = i + 1) begin
            assign b_axi_arready[i] = 0;
            assign b_axi_rdata[i]   = 0;
            assign b_axi_rid[i]     = 0;
            assign b_axi_rlast[i]   = 0;
            assign b_axi_rvalid[i]  = 0;
            assign b_axi_rresp[i]   = 0;

            assign b_axi_awready[i] = 1;
            assign b_axi_bid[i]     = 0;
            //assign b_axi_bready[i] = 0;
            assign b_axi_bvalid[i]  = 1;
            assign b_axi_bresp[i]   = 0;
            assign b_axi_wready[i]  = 1;
        end
    endgenerate

    axi_2p #(
          .G_MEMDEPTH     (32768)
        , .G_ID_WIDTH     (G_ID_WIDTH)
        , .G_INIT_FILE    (G_INIT_FILE)
        , .G_AWUSER_ENABLE(G_AWUSER_ENABLE)
        , .G_AWUSER_WIDTH (G_AWUSER_WIDTH)
        , .G_WUSER_ENABLE (G_WUSER_ENABLE)
        , .G_WUSER_WIDTH  (G_WUSER_WIDTH)
        , .G_BUSER_ENABLE (G_BUSER_ENABLE)
        , .G_BUSER_WIDTH  (G_BUSER_WIDTH)
        , .G_ARUSER_ENABLE(G_ARUSER_ENABLE)
        , .G_ARUSER_WIDTH (G_ARUSER_WIDTH)
        , .G_RUSER_ENABLE (G_RUSER_ENABLE)
        , .G_RUSER_WIDTH  (G_RUSER_WIDTH)
    ) i_axi_2p (
        .*
        , .s_axi_awid    (b_axi_awid[0])
        , .s_axi_awaddr  (b_axi_awaddr[0])
        , .s_axi_awlen   (b_axi_awlen[0])
        , .s_axi_awsize  (b_axi_awsize[0])
        , .s_axi_awburst (b_axi_awburst[0])
        , .s_axi_awlock  (b_axi_awlock[0])
        , .s_axi_awcache (b_axi_awcache[0])
        , .s_axi_awprot  (b_axi_awprot[0])
        , .s_axi_awqos   (b_axi_awqos[0])
        , .s_axi_awregion(b_axi_awregion[0])
        //, .s_axi_awuser       (b_axi_awuser  [0])
        , .s_axi_awuser  (1'b0)
        , .s_axi_awvalid (b_axi_awvalid[0])
        , .s_axi_awready (b_axi_awready[0])
        , .s_axi_wdata   (b_axi_wdata[0])
        , .s_axi_wstrb   (b_axi_wstrb[0])
        , .s_axi_wlast   (b_axi_wlast[0])
        //, .s_axi_wuser        (b_axi_wuser   [0])
        , .s_axi_wuser   (1'b0)
        , .s_axi_wvalid  (b_axi_wvalid[0])
        , .s_axi_wready  (b_axi_wready[0])
        , .s_axi_bid     (b_axi_bid[0])
        , .s_axi_bresp   (b_axi_bresp[0])
        //, .s_axi_buser        (b_axi_buser   [0])
        , .s_axi_buser   ()
        , .s_axi_bvalid  (b_axi_bvalid[0])
        , .s_axi_bready  (b_axi_bready[0])
        , .s_axi_arid    (b_axi_arid[0])
        , .s_axi_araddr  (b_axi_araddr[0])
        , .s_axi_arlen   (b_axi_arlen[0])
        , .s_axi_arsize  (b_axi_arsize[0])
        , .s_axi_arburst (b_axi_arburst[0])
        , .s_axi_arlock  (b_axi_arlock[0])
        , .s_axi_arcache (b_axi_arcache[0])
        , .s_axi_arprot  (b_axi_arprot[0])
        , .s_axi_arqos   (b_axi_arqos[0])
        , .s_axi_arregion(b_axi_arregion[0])
        //, .s_axi_aruser       (b_axi_aruser  [0])
        , .s_axi_aruser  (1'b0)
        , .s_axi_arvalid (b_axi_arvalid[0])
        , .s_axi_arready (b_axi_arready[0])
        , .s_axi_rid     (b_axi_rid[0])
        , .s_axi_rdata   (b_axi_rdata[0])
        , .s_axi_rresp   (b_axi_rresp[0])
        , .s_axi_rlast   (b_axi_rlast[0])
        //, .s_axi_ruser        (b_axi_ruser   [0])
        , .s_axi_ruser   ()
        , .s_axi_rvalid  (b_axi_rvalid[0])
        , .s_axi_rready  (b_axi_rready[0])
    );


endmodule
