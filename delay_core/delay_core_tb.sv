`timescale 1ns/1ns

module delay_core_tb();

    parameter ADC_NSCK = 16;
    parameter ADC_CS_LEN = 66;
    parameter DAC_NSCK = 24;
    parameter DAC_CS_LEN = 2;
    parameter RAM_NSCK = 48;
    parameter RAM_CS_LEN = 2;
    parameter RAM_END_ADDR = 24'h01FFFF;
    parameter W_PTR_START_ADDR = 24'h000000;
    parameter R_PTR_START_ADDR = 24'h01001C;

    logic clk, nrst, step, sck_adc, cnv_adc, sdi_adc, sck_dac, syn_dac, sdo_dac, sck_ram, css_ram, sdi_ram, sdo_ram;

    delay_core #(ADC_NSCK, ADC_CS_LEN, DAC_NSCK, DAC_CS_LEN, RAM_NSCK, RAM_CS_LEN, RAM_END_ADDR, W_PTR_START_ADDR, R_PTR_START_ADDR) 
            dut(clk, nrst, step, sck_adc, cnv_adc, sdi_adc, sck_dac, syn_dac, sdo_dac, sck_ram, css_ram, sdi_ram, sdo_ram);
    
    always begin
        clk = 1'b0; #7;
        clk = 1'b1; #7;
    end

    initial begin
        $dumpfile("delay_core.vcd");
        $dumpvars(0, delay_core_tb);

        nrst=0; step=0; sdi_adc = 1; sdi_ram = 1; #50;
        nrst = 1; step = 1; #50;
        step = 0; #50;
        #7350;
        step=1; #50;
        step=0; #50;
        #7350;
    
        $finish;
    end

endmodule