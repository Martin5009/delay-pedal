module edge_detector(input  logic clk,
                        input  logic nrst,
                        input  logic pol,
                        input  logic d,
                        output logic e);

    logic d_dly;

    always @(posedge clk) begin
        if (~nrst) d_dly <= 0;
        else d_dly <= d;
    end

    always_comb begin
        if (pol) e = d & ~d_dly;
        else e = ~d & d_dly;
    end

endmodule