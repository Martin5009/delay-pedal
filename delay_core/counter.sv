module counter #(parameter N=4)
        (input  logic clk,
         input  logic en,
         input  logic nrst,
         input  logic [N-1:0] init,
         output logic [N-1:0] cnt);

    always_ff @(posedge clk) begin
        if (~nrst) cnt <= init;
        else if (en) cnt <= cnt + 1'b1;
    end

endmodule