`timescale 1ns/1ns

module delay_core_tb();

    logic clk, nrst, sck_adc, cnv_adc, sdi_adc, sck_dac, syn_dac, sdo_dac, sck_ram, css_ram, sdi_ram, sdo_ram, done;

    delay_core dut(clk, nrst, sck_adc, cnv_adc, sdi_adc, sck_dac, syn_dac, sdo_dac, sck_ram, css_ram, sdi_ram, sdo_ram, done);
    
    always begin
        clk = 1'b0; #5;
        clk = 1'b1; #5;
    end

    initial begin
        $dumpfile("delay_core.vcd");
        $dumpvars(0, delay_core_tb);

        nrst=0; sdi_adc = 1; sdi_ram = 1; #10;
        nrst = 1; #10;
        
        #10000;
    
        $finish;
    end

endmodule