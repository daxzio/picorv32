from random import randint     
from cocotb import start_soon
from cocotb import test
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge

from interfaces.clkreset import ClkReset
from interfaces.axi_driver import AxiDriver, tointeger
from interfaces.picorv32ram import Picorv32Ram
from interfaces.picorv32ram import Picorv32Monitor
from interfaces.cocotbext_logger import CocoTBExtLogger
from interfaces.pcpi import PCPI

import logging

class testbench:
    def __init__(self, dut, reset_sense=1):
        self.cr = ClkReset(dut, reset_sense=reset_sense)        

        self.pcpi = PCPI(dut)
        #self.axi = Picorv32Ram(dut, hexfile='firmware.hex')
        self.mon = Picorv32Monitor(dut)

        self.irq = dut.irq
        self.irq.setimmediatevalue(0)

    
@test()
async def test_dut_basic(dut):
    tb = testbench(dut, reset_sense=0)

    await tb.cr.wait_clkn(200)
    tb.irq.value = 0x10
    await tb.cr.wait_clkn()
    tb.irq.value = 0

#     await tb.mon.wait_trap()
    await RisingEdge(tb.mon.trap)
    await tb.cr.wait_clkn(200)
    
    await tb.cr.end_test()
