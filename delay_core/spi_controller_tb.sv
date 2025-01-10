`timescale 1us/1ns

module spi_controller_tb();
    parameter RX_WIDTH = 8;
    parameter TX_WIDTH = 8;
    parameter NSCK = 16;
    parameter SCK_DIV = 2;

    logic clk, nrst, sdi, cs, sdo, sck, done;
    logic [TX_WIDTH-1:0] tx_data;
    logic [RX_WIDTH-1:0] rx_data;

    spi_controller #(TX_WIDTH, RX_WIDTH, NSCK, SCK_DIV) dut(clk, nrst, sdi, cs, sdo, sck, tx_data, rx_data, done);

    always begin
        clk = 1'b0; #5;
        clk = 1'b1; #5;
    end

    initial begin
        $dumpfile("spi_controller.vcd");
        $dumpvars(0,spi_controller_tb);
        
        nrst=0; cs=0; sdi=1; tx_data = 8'b10101010; #10;
        nrst=1; cs=0; #10;
        cs=1; #20;
        cs=0; #60;
        #2000;

        $finish;
    end

endmodule