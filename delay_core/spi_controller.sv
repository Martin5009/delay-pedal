module spi_controller
        #(parameter TX_WIDTH = 24,
        parameter RX_WIDTH = 24,
        parameter NSCK = 40,
        parameter CNT_WIDTH = 6)
        (input  logic clk,
        input  logic nrst,
        input  logic sdi,
        input  logic cs,
        output logic sdo,
        output logic sck,
        input  logic [TX_WIDTH-1:0] tx_data,
        output logic [RX_WIDTH-1:0] rx_data,
        output logic done);

    typedef enum logic [2:0] {S0, S1, S2, S3} statetype;
    statetype state, nextstate;

    logic cs_nedge, sck_en, rx_en;
    logic [CNT_WIDTH-1:0] cnt;
    logic [TX_WIDTH-1:0] tx_buffer;
    logic [RX_WIDTH-1:0] rx_buffer;

    edge_detector ned1(clk, nrst, 1'b0, cs, cs_nedge);
    counter #(CNT_WIDTH) cntr(clk, 1'b1, sck_en, cnt);

    assign sck = (clk & sck_en);

    always_ff @(negedge clk) begin
        if (sck_en) tx_buffer <= {tx_buffer[TX_WIDTH-2:0], 1'b0};
    end

    always_ff @(posedge clk) begin
        if (~nrst) begin
            tx_buffer <= 32'b0;
            rx_buffer <= 32'b0;
            rx_data <= 32'b0;
        end
        else if (rx_en) begin
            rx_buffer <= {rx_buffer[RX_WIDTH-2:0], sdi};
        end
        else begin
            tx_buffer <= tx_data;
            rx_data <= rx_buffer;
        end
    end

    //sck state machine
    always_ff @(posedge clk) begin
        if (~nrst) state <= S0;
        else state <= nextstate;
    end

    always_comb begin
        case (state)
            S0: if (cs_nedge)      nextstate = S1;
                else               nextstate = S0;
            S1:                    nextstate = S2;
            S2: if (cnt == NSCK-2) nextstate = S3;
                else               nextstate = S2;
            S3:                    nextstate = S0;
            default:               nextstate = S0;
        endcase
    end

    assign rx_en = (state == S1) | (state == S2);
    assign sck_en = (state == S2) | (state == S3);
    assign sdo = tx_buffer[TX_WIDTH-1];
    assign done = (state == S0);

endmodule