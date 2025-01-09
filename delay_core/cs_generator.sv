module cs_generator 
        #(parameter THRESHOLD = 8,
        parameter CNT_WIDTH = 4)
        (input logic clk,
        input logic nrst,
        input logic en, 
        output logic cs,
        output logic done);

    typedef enum logic [1:0] {S0, S1, S2} statetype;
    statetype state, nextstate;

    logic cnt_nrst, en_pos_edge;
    logic [CNT_WIDTH-1:0] cnt;

    counter #(CNT_WIDTH) cntr(clk, 1'b1, cnt_nrst, cnt);
    edge_detector ped(clk, nrst, 1'b1, en, en_pos_edge);

    always_ff @(posedge clk) begin
        if (~nrst) state <= S0;
        else state <= nextstate;
    end

    always_comb begin
        case (state)
            S0: if (en_pos_edge)        nextstate = S1;
                else                    nextstate = S0;
            S1: if (cnt == THRESHOLD)   nextstate = S0;
                else                    nextstate = S1;
            default:                    nextstate = S0;
        endcase
    end

    assign cnt_nrst = ~(state == S0);
    assign cs = (state == S1);
    assign done = (state == S0);

endmodule