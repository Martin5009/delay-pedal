`timescale 1us/1ns

module edge_detector_tb();

    logic clk, d, e;

    neg_edge_detector dut(clk, d, e);

    always begin
        clk = 1'b0; #5;
        clk = 1'b1; #5;
    end

    initial begin
        $dumpfile("edge_detector.vcd");
        $dumpvars(0,edge_detector_tb);

        d=0; #10;
        d=1; #10;
        d=0; #20;
        d=1; #20;
        d=0; #20;
        $finish;
    end

endmodule