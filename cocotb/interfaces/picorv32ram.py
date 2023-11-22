import logging
from cocotb import start_soon
from cocotb.triggers import RisingEdge, FallingEdge
from cocotbext.axi import AxiLiteBus
from cocotbext.axi import AxiLiteRam, AxiLiteRamWrite
from interfaces.cocotbext_logger import CocoTBExtLogger

class Picorv32Monitor(AxiLiteRam, CocoTBExtLogger):

    def __init__(self, dut, axi_prefix="mem_axi", clk_name="clk", hexfile=None):
        #CocoTBExtLogger.__init__(self, type(self).__name__)
        CocoTBExtLogger.__init__(self, "Picorv32Monitor")
        self.enable_logging()

        self.clk = getattr(dut, clk_name)
        #self.bus = AxiLiteBus.from_prefix(dut, axi_prefix)
        self.awready = dut.i_picorv32_axi.mem_axi_awready
        self.awvalid = dut.i_picorv32_axi.mem_axi_awvalid
        self.awaddr = dut.i_picorv32_axi.mem_axi_awaddr
        self.wready = dut.i_picorv32_axi.mem_axi_wready
        self.wvalid = dut.i_picorv32_axi.mem_axi_wvalid
        self.wdata = dut.i_picorv32_axi.mem_axi_wdata
        self.trap = dut.trap
        self.test_passed = False
        
        start_soon(self._monitor())
        start_soon(self.wait_trap())
    
    async def _monitor(self):
        chars = ""
        self.waddr = 0
        while True:
            await RisingEdge(self.clk)
            if self.awvalid.value == 1:
            #if self.awready.value == 1 and self.awvalid.value == 1:
                self.waddr = int(self.awaddr)
            
            if self.wready.value == 1 and self.wvalid.value == 1:
                self.data = int(self.wdata)
                if (self.waddr < 128*1024):
                    pass
                elif 0x10000000 == self.waddr:
                    #print(chr(self.data), end='', flush=True)
                    if 10 == self.data:
                        self.log.info(chars)
                        chars = ""
                    else:
                        chars += chr(self.data)
                        
                elif 0x20000000 == self.waddr:
                    if 123456789 == self.data:
                        self.log.info('RiscV tests Completed Successfully')
                        self.test_passed = True
                    else:
                        self.log.warning('RiscV tests Completed Unsuccessfully')
                else:
                    raise Exception(f'Addr out of range: 0x{self.waddr:08x}')

    async def wait_trap(self):
        await RisingEdge(self.trap)
        self.log.info('Trap Detected')
        if not self.test_passed:
            raise Exception('Test failed')
            

class Picorv32Ram(AxiLiteRam, CocoTBExtLogger):

    async def _write(self, address, data):
        self.write(address % self.size, data)
        if (address < 128*1024):
            pass
        elif 0x10000000 == address:
            pass
            #print(data.decode(), end='', flush=True)
        elif 0x20000000 == address:
            if 123456789 == int.from_bytes(data, byteorder='little'):
                #self.log.info('Test Completed Successfully')
                self.test_passed = True
            else:
                pass
                #self.log.warning('Test Completed Unsuccessfully')
        else:
            raise Exception('Addr out of range')

    def __init__(self, dut, axi_prefix="mem_axi", clk_name="clk", hexfile=None):
        #CocoTBExtLogger.__init__(self, type(self).__name__)
        CocoTBExtLogger.__init__(self, "Picorv32Ram")
        self.enable_logging()
        #self.test_passed = False
        
        f = open(hexfile)
        lines = f.readlines()
        f.close()
        self.mem = []
        for line in lines:
            m = int(line.rstrip(),16)
            for i in range(4):
                self.mem.append((m>>(i*8)) & 0xff)

        self.trap = dut.trap
        AxiLiteRam.__init__(self, AxiLiteBus.from_prefix(dut, axi_prefix), getattr(dut, clk_name), mem=self.mem, size=2**32)

        self.write_if.log.setLevel(logging.WARNING)
        self.read_if.log.setLevel(logging.WARNING)
        
        self.read_if.ar_channel.bus.araddr.setimmediatevalue(0)
        self.read_if.r_channel.bus.rdata.setimmediatevalue(0)
        self.write_if.aw_channel.bus.awaddr.setimmediatevalue(0)
        self.write_if.w_channel.bus.wstrb.setimmediatevalue(0)
        self.write_if.w_channel.bus.wdata.setimmediatevalue(0)
    
        self.write_if._write = self._write.__get__(self.write_if, AxiLiteRamWrite)
        self.write_if.test_passed = False
        #self.write_if.log.setLevel(logging.INFO)

    async def wait_trap(self):
        await RisingEdge(self.trap)
        self.log.info('Trap Detected')
        if not self.write_if.test_passed:
            raise Exception('Test failed')
            
