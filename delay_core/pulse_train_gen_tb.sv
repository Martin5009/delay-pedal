`timescale 1us/1ns

module pulse_train_gen_tb();

    parameter DIV = 2;

    logic clk, en, nrst, pulse;

    pulse_train_gen #(DIV) dut(clk, en, nrst, pulse);

    always begin
        clk = 1'b0; #5;
        clk = 1'b1; #5;
    end

    initial begin
        $dumpfile("pulse_train_gen.vcd");
        $dumpvars(0,pulse_train_gen_tb);
        
        nrst = 0; en = 0; #10;
        nrst = 1; en = 1; #200;
        en = 0; #100;
        en = 1; #1000;

        $finish;
    end

endmodule