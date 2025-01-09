module counter #(parameter N=4)
        (input  logic clk,
         input  logic en,
         input  logic nrst,
         output logic [N-1:0] cnt);

    always_ff @(posedge clk) begin
        if (~nrst) cnt <= 1'b0;
        else if (en) cnt <= cnt + 1'b1;
    end

endmodule