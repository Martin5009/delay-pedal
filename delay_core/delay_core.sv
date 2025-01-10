module delay_core
        #(parameter ADC_NSCK = 16,
        parameter ADC_CS_LEN = 528,
        parameter ADC_DIV = 3,
        parameter DAC_NSCK = 24,
        parameter DAC_CS_LEN = 8,
        parameter DAC_DIV = 3,
        parameter RAM_NSCK = 48,
        parameter RAM_CS_LEN = 8,
        parameter RAM_DIV = 1,
        parameter RAM_END_ADDR = 24'h01FFFF,
        parameter W_PTR_START_ADDR = 24'h000000,
        parameter R_PTR_OFFSET = 24'h01001C)
        (input logic clk,
        input  logic nrst,
        input  logic step,
        output logic sck_adc,
        output logic cnv_adc,
        input  logic sdi_adc,
        output logic sck_dac,
        output logic syn_dac,
        output logic sdo_dac,
        output logic sck_ram,
        output logic css_ram,
        input  logic sdi_ram,
        output logic sdo_ram);

    typedef enum logic [3:0] {S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11} statetype;
    statetype state, nextstate;

    logic cs_done_ram, cs_done_adc, cs_done_dac, spi_done_ram, spi_done_adc, spi_done_dac;
    logic cs_en_adc, cs_en_dac, cs_en_ram;
    logic sdo_adc, sdi_dac;

    logic [RAM_NSCK-1:0] tx_ram, rx_ram;
    logic [ADC_NSCK-1:0] tx_adc, rx_adc;
    logic [DAC_NSCK-1:0] tx_dac, rx_dac;

    logic [23:0] ram_r_ptr, ram_w_ptr;
    
    cs_generator #(ADC_CS_LEN) cs_gen_adc(clk, nrst, cs_en_adc, cnv_adc, cs_done_adc);
    spi_controller #(ADC_NSCK, ADC_NSCK, ADC_NSCK, ADC_DIV) spi_con_adc(clk, nrst, sdi_adc, cnv_adc, sdo_adc, sck_adc, tx_adc, rx_adc, spi_done_adc);

    cs_generator #(DAC_CS_LEN) cs_gen_dac(clk, nrst, cs_en_dac, syn_dac, cs_done_dac);
    spi_controller #(DAC_NSCK, DAC_NSCK, DAC_NSCK, DAC_DIV) spi_con_dac(clk, nrst, sdi_dac, syn_dac, sdo_dac, sck_dac, tx_dac, rx_dac, spi_done_dac);

    cs_generator #(RAM_CS_LEN) cs_gen_ram(clk, nrst, cs_en_ram, css_ram, cs_done_ram);
    spi_controller #(RAM_NSCK, RAM_NSCK, RAM_NSCK, RAM_DIV) spi_con_ram(clk, nrst, sdi_ram, css_ram, sdo_ram, sck_ram, tx_ram, rx_ram, spi_done_ram);

    //update read & write pointers
    always_ff @(posedge clk) begin
        if (~nrst) begin
            ram_w_ptr <= W_PTR_START_ADDR;
            ram_r_ptr <= W_PTR_START_ADDR + R_PTR_OFFSET;
        end
        else if (step) begin
            if (ram_w_ptr + 2'd2 >= RAM_END_ADDR) ram_w_ptr <= ram_w_ptr + 2'd2 - RAM_END_ADDR;
            else ram_w_ptr <= ram_w_ptr + 2'd2;

            if (ram_r_ptr + 2'd2 >= RAM_END_ADDR) ram_r_ptr <= ram_r_ptr + 2'd2 - RAM_END_ADDR;
            else ram_r_ptr <= ram_r_ptr + 2'd2;
        end
    end

    //state register
    always_ff @(posedge clk) begin
        if (~nrst) state <= S0;
        else state <= nextstate;
    end

    //next state logic
    always_comb begin
        case (state)
            S0: if (step)                           nextstate = S1;
                else                                nextstate = S0;
            S1:                                     nextstate = S2;
            S2: if (cs_done_ram)                    nextstate = S3;
                else                                nextstate = S2;
            S3: if (spi_done_ram)                   nextstate = S4;
                else                                nextstate = S3;
            S4:                                     nextstate = S5;
            S5: if (cs_done_dac)                    nextstate = S6;
                else                                nextstate = S5;
            S6: if (spi_done_dac)                   nextstate = S7;
                else                                nextstate = S6;
            S7: if (cs_done_adc)                    nextstate = S8;
                else                                nextstate = S7;
            S8: if (spi_done_adc)                   nextstate = S9;
                else                                nextstate = S8;
            S9:                                     nextstate = S10;
            S10: if (cs_done_ram)                   nextstate = S11;
                 else                               nextstate = S10;
            S11: if (spi_done_ram)                  nextstate = S0;
                 else                               nextstate = S11;
            default:                                nextstate = S0;
        endcase
    end

    //output logic
    assign cs_en_adc = (state == S1);
    assign cs_en_dac = (state == S4);
    assign cs_en_ram = (state == S1) | (state == S9);

    always_comb begin
        case (state)
            S2: tx_ram = {8'b00000010, ram_w_ptr, rx_adc};
            S3: tx_ram = {8'b00000010, ram_w_ptr, rx_adc};
            S10: tx_ram = {8'b00000011, ram_r_ptr, 16'b00000000};
            S11: tx_ram = {8'b00000011, ram_r_ptr, 16'b00000000};
            default: tx_ram = 64'b0;
        endcase
    end

    assign tx_adc = 64'b0;
    assign tx_dac = {2'b00, rx_ram[15:0]};

endmodule