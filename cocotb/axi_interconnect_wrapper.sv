module axi_interconnect_wrapper #(
    integer G_USEIP = 0
    , integer G_SLAVE_AXI = 1
    , integer G_MASTER_AXI = 2
    , integer G_DATA_WIDTH = 32
    , integer G_ADDR_WIDTH = 32
    , integer G_S_ID_WIDTH = 4
    , integer G_M_ID_WIDTH = G_S_ID_WIDTH
    , integer G_M_REGIONS = 1
    , integer G_AWUSER_WIDTH = 1
    , integer G_WUSER_WIDTH = 1
    , integer G_BUSER_WIDTH = 1
    , integer G_ARUSER_WIDTH = 1
    , integer G_RUSER_WIDTH = 1
    , parameter G_M_BASE_ADDR = 0  // verilog_lint: waive explicit-parameter-storage-type (not supported in vivado)
    , parameter G_M_ADDR_WIDTH = 0  // verilog_lint: waive explicit-parameter-storage-type (not supported in vivado)
) (
      input aclk
    , input aresetn

    , input  [  (G_S_ID_WIDTH*G_SLAVE_AXI)-1:0] s_axi_awid
    , input  [  (G_ADDR_WIDTH*G_SLAVE_AXI)-1:0] s_axi_awaddr
    , input  [             (8*G_SLAVE_AXI)-1:0] s_axi_awlen
    , input  [             (3*G_SLAVE_AXI)-1:0] s_axi_awsize
    , input  [             (2*G_SLAVE_AXI)-1:0] s_axi_awburst
    , input  [             (1*G_SLAVE_AXI)-1:0] s_axi_awlock
    , input  [             (4*G_SLAVE_AXI)-1:0] s_axi_awcache
    , input  [             (3*G_SLAVE_AXI)-1:0] s_axi_awprot
    , input  [             (4*G_SLAVE_AXI)-1:0] s_axi_awregion
    , input  [             (4*G_SLAVE_AXI)-1:0] s_axi_awqos
    , input  [(G_AWUSER_WIDTH*G_SLAVE_AXI)-1:0] s_axi_awuser
    , input  [             (1*G_SLAVE_AXI)-1:0] s_axi_awvalid
    , output [             (1*G_SLAVE_AXI)-1:0] s_axi_awready
    , input  [  (G_DATA_WIDTH*G_SLAVE_AXI)-1:0] s_axi_wdata
    , input  [             (4*G_SLAVE_AXI)-1:0] s_axi_wstrb
    , input  [             (1*G_SLAVE_AXI)-1:0] s_axi_wlast
    , input  [ (G_WUSER_WIDTH*G_SLAVE_AXI)-1:0] s_axi_wuser
    , input  [             (1*G_SLAVE_AXI)-1:0] s_axi_wvalid
    , output [             (1*G_SLAVE_AXI)-1:0] s_axi_wready
    , output [  (G_S_ID_WIDTH*G_SLAVE_AXI)-1:0] s_axi_bid
    , output [             (2*G_SLAVE_AXI)-1:0] s_axi_bresp
    , output [ (G_BUSER_WIDTH*G_SLAVE_AXI)-1:0] s_axi_buser
    , output [             (1*G_SLAVE_AXI)-1:0] s_axi_bvalid
    , input  [             (1*G_SLAVE_AXI)-1:0] s_axi_bready
    , input  [  (G_S_ID_WIDTH*G_SLAVE_AXI)-1:0] s_axi_arid
    , input  [  (G_ADDR_WIDTH*G_SLAVE_AXI)-1:0] s_axi_araddr
    , input  [             (8*G_SLAVE_AXI)-1:0] s_axi_arlen
    , input  [             (3*G_SLAVE_AXI)-1:0] s_axi_arsize
    , input  [             (2*G_SLAVE_AXI)-1:0] s_axi_arburst
    , input  [             (1*G_SLAVE_AXI)-1:0] s_axi_arlock
    , input  [             (4*G_SLAVE_AXI)-1:0] s_axi_arcache
    , input  [             (3*G_SLAVE_AXI)-1:0] s_axi_arprot
    , input  [             (4*G_SLAVE_AXI)-1:0] s_axi_arregion
    , input  [             (4*G_SLAVE_AXI)-1:0] s_axi_arqos
    , input  [(G_ARUSER_WIDTH*G_SLAVE_AXI)-1:0] s_axi_aruser
    , input  [             (1*G_SLAVE_AXI)-1:0] s_axi_arvalid
    , output [             (1*G_SLAVE_AXI)-1:0] s_axi_arready
    , output [  (G_S_ID_WIDTH*G_SLAVE_AXI)-1:0] s_axi_rid
    , output [  (G_DATA_WIDTH*G_SLAVE_AXI)-1:0] s_axi_rdata
    , output [             (2*G_SLAVE_AXI)-1:0] s_axi_rresp
    , output [             (1*G_SLAVE_AXI)-1:0] s_axi_rlast
    , output [ (G_RUSER_WIDTH*G_SLAVE_AXI)-1:0] s_axi_ruser
    , output [             (1*G_SLAVE_AXI)-1:0] s_axi_rvalid
    , input  [             (1*G_SLAVE_AXI)-1:0] s_axi_rready

    , output [  (G_M_ID_WIDTH*G_MASTER_AXI)-1:0] m_axi_awid
    , output [  (G_ADDR_WIDTH*G_MASTER_AXI)-1:0] m_axi_awaddr
    , output [             (8*G_MASTER_AXI)-1:0] m_axi_awlen
    , output [             (3*G_MASTER_AXI)-1:0] m_axi_awsize
    , output [             (2*G_MASTER_AXI)-1:0] m_axi_awburst
    , output [             (1*G_MASTER_AXI)-1:0] m_axi_awlock
    , output [             (4*G_MASTER_AXI)-1:0] m_axi_awcache
    , output [             (3*G_MASTER_AXI)-1:0] m_axi_awprot
    , output [             (4*G_MASTER_AXI)-1:0] m_axi_awregion
    , output [             (4*G_MASTER_AXI)-1:0] m_axi_awqos
    , output [(G_AWUSER_WIDTH*G_MASTER_AXI)-1:0] m_axi_awuser
    , output [             (1*G_MASTER_AXI)-1:0] m_axi_awvalid
    , input  [             (1*G_MASTER_AXI)-1:0] m_axi_awready
    , output [  (G_DATA_WIDTH*G_MASTER_AXI)-1:0] m_axi_wdata
    , output [             (4*G_MASTER_AXI)-1:0] m_axi_wstrb
    , output [             (1*G_MASTER_AXI)-1:0] m_axi_wlast
    , output [ (G_WUSER_WIDTH*G_MASTER_AXI)-1:0] m_axi_wuser
    , output [             (1*G_MASTER_AXI)-1:0] m_axi_wvalid
    , input  [             (1*G_MASTER_AXI)-1:0] m_axi_wready
    , input  [  (G_M_ID_WIDTH*G_MASTER_AXI)-1:0] m_axi_bid
    , input  [             (2*G_MASTER_AXI)-1:0] m_axi_bresp
    , input  [ (G_BUSER_WIDTH*G_MASTER_AXI)-1:0] m_axi_buser
    , input  [             (1*G_MASTER_AXI)-1:0] m_axi_bvalid
    , output [             (1*G_MASTER_AXI)-1:0] m_axi_bready
    , output [  (G_M_ID_WIDTH*G_MASTER_AXI)-1:0] m_axi_arid
    , output [  (G_ADDR_WIDTH*G_MASTER_AXI)-1:0] m_axi_araddr
    , output [             (8*G_MASTER_AXI)-1:0] m_axi_arlen
    , output [             (3*G_MASTER_AXI)-1:0] m_axi_arsize
    , output [             (2*G_MASTER_AXI)-1:0] m_axi_arburst
    , output [             (1*G_MASTER_AXI)-1:0] m_axi_arlock
    , output [             (4*G_MASTER_AXI)-1:0] m_axi_arcache
    , output [             (3*G_MASTER_AXI)-1:0] m_axi_arprot
    , output [             (4*G_MASTER_AXI)-1:0] m_axi_arregion
    , output [             (4*G_MASTER_AXI)-1:0] m_axi_arqos
    , output [(G_ARUSER_WIDTH*G_MASTER_AXI)-1:0] m_axi_aruser
    , output [             (1*G_MASTER_AXI)-1:0] m_axi_arvalid
    , input  [             (1*G_MASTER_AXI)-1:0] m_axi_arready
    , input  [  (G_M_ID_WIDTH*G_MASTER_AXI)-1:0] m_axi_rid
    , input  [  (G_DATA_WIDTH*G_MASTER_AXI)-1:0] m_axi_rdata
    , input  [             (2*G_MASTER_AXI)-1:0] m_axi_rresp
    , input  [             (1*G_MASTER_AXI)-1:0] m_axi_rlast
    , input  [ (G_RUSER_WIDTH*G_MASTER_AXI)-1:0] m_axi_ruser
    , input  [             (1*G_MASTER_AXI)-1:0] m_axi_rvalid
    , output [             (1*G_MASTER_AXI)-1:0] m_axi_rready
);

    localparam logic [(32*32)-1:0] x_address_map = G_M_BASE_ADDR[0*32+:G_MASTER_AXI*32];
    localparam logic [(32*32)-1:0] x_address_width = G_M_ADDR_WIDTH[0*32+:G_MASTER_AXI*32];

    localparam logic [(32*32)-1:0] w_address_map = (0 == G_M_BASE_ADDR) ? {
        32'h01f00000,
        32'h01e00000,
        32'h01d00000,
        32'h01c00000,
        32'h01b00000,
        32'h01a00000,
        32'h01900000,
        32'h01800000,
        32'h01700000,
        32'h01600000,
        32'h01500000,
        32'h01400000,
        32'h01300000,
        32'h01200000,
        32'h01100000,
        32'h01000000,
        32'h00f00000,
        32'h00e00000,
        32'h00d00000,
        32'h00c00000,
        32'h00b00000,
        32'h00a00000,
        32'h00900000,
        32'h00800000,
        32'h00700000,
        32'h00600000,
        32'h00500000,
        32'h00400000,
        32'h00300000,
        32'h00200000,
        32'h00100000,
        32'h00000000
    } : x_address_map;

    localparam logic [(32*32)-1:0] w_address_width = (0 == G_M_ADDR_WIDTH) ? {32{32'd20}} : x_address_width;

    generate
        if (0 == G_USEIP) begin
            axi_interconnect #(
                  .S_COUNT     (G_SLAVE_AXI)
                , .M_COUNT     (G_MASTER_AXI)
                , .DATA_WIDTH  (G_DATA_WIDTH)
                , .ADDR_WIDTH  (G_ADDR_WIDTH)
                , .ID_WIDTH    (G_S_ID_WIDTH)
                , .M_BASE_ADDR (w_address_map[0+:32*G_MASTER_AXI])
                , .M_ADDR_WIDTH(w_address_width[0+:32*G_MASTER_AXI])
            ) i_axi_interconnect (
                .*
                , .clk(aclk)
                , .rst(~aresetn)
            );
        end else begin
        end
    endgenerate

endmodule
