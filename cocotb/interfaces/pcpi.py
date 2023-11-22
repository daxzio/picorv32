from interfaces.cocotbext_logger import CocoTBExtLogger
class PCPI(CocoTBExtLogger):
    def __init__(self, dut):
        CocoTBExtLogger.__init__(self, type(self).__name__)

        self.pcpi_valid = dut.pcpi_valid
        self.pcpi_insn  = dut.pcpi_insn 
        self.pcpi_rs1   = dut.pcpi_rs1  
        self.pcpi_rs2   = dut.pcpi_rs2  
        self.pcpi_wr    = dut.pcpi_wr   
        self.pcpi_rd    = dut.pcpi_rd   
        self.pcpi_wait  = dut.pcpi_wait 
        self.pcpi_ready = dut.pcpi_ready

        self.pcpi_wr.setimmediatevalue(0)
        self.pcpi_rd.setimmediatevalue(0)
        self.pcpi_wait.setimmediatevalue(0)
        self.pcpi_ready.setimmediatevalue(0)
