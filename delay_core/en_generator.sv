module cs_generator 
        #(parameter THRESHOLD = 8)
        (input logic clk,
        input logic nrst,
        input logic en, 
        output logic cs,
        output logic done);

    typedef enum logic [1:0] {S0, S1, S2} statetype;
    statetype state, nextstate;

    logic cnt_nrst, en_pos_edge;
    logic [$clog2(THRESHOLD+1)-1:0] cnt;

    counter #($clog2(THRESHOLD+1)) cntr(clk, 1'b1, cnt_nrst, 1'b0, cnt);
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

module pulse_train_gen #(parameter DIV = 1)
        (input  logic clk,
         input  logic en,
         input  logic nrst,
         output logic pulse);

    typedef enum logic [1:0] {S0, S1, S2} statetype;
    statetype state, nextstate;

    logic [DIV-1:0] cnt;
    logic cnt_nrst;

    always_ff @(posedge clk) begin
        if (~nrst) state <= S0;
        else state <= nextstate;
    end

    counter #(DIV) cntr(clk, en, cnt_nrst, 1'b0, cnt);

    always_comb begin
        case (state)
            S0: if (~en)                    nextstate = S0;
                else                        nextstate = S1;
            S1: if (~en)                    nextstate = S0;
                else if (cnt >= 2**DIV-2)   nextstate = S2;
                else                        nextstate = S1;
            S2: if (~en)                    nextstate = S0;
                else                        nextstate = S1;
            default:                        nextstate = S0;
        endcase
    end

    assign cnt_nrst = (state == S1);
    assign pulse = (state == S2);

endmodule