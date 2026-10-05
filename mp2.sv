// fade colors

module mp2 #(
    parameter INC_DEC_INTERVAL = 12000, // set 1 ms interval for incrementing / decrementing PWM value
    parameter INC_DEC_MAX = 200, // delay 200 before state changes by INC_DEC_VAL
    parameter PWM_INTERVAL= 12000, // 12000 clock cycles = 1ms for PWM period
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX //decrement / increment value for each state transition
)(
    input logic clk,
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
);

    localparam RGB_R_Y = 3'd0; // red to yellow
    localparam RGB_Y_G = 3'd1; // yellow to green
    localparam RGB_G_C = 3'd2; // green to cyan
    localparam RGB_C_B = 3'd3; // cyan to blue  
    localparam RGB_B_M = 3'd4; // blue to magenta
    localparam RGB_M_R = 3'd5; // magenta to red

    logic [2:0] current_state = RGB_R_Y; // start at red to yellow state
    logic [2:0] next_state; // next state of the FSM

    // Declare state variables
    logic [$clog2(PWM_INTERVAL) - 1:0] R_VAL; 
    logic [$clog2(PWM_INTERVAL) - 1:0] G_VAL;
    logic [$clog2(PWM_INTERVAL) - 1:0] B_VAL;
    logic [$clog2(PWM_INTERVAL) - 1:0] PWM_COUNTER = 0; //count pwm cycles to determine when to turn on/off the RGB pins

    // Declare variables for timing state transitions
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0; //count clock cycles to determine when to increment / decrement the RGB values
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0; //count to determine when to transition to the next state
    logic time_to_inc_dec = 1'b0; 
    logic time_to_transition = 1'b0; 


    initial begin
        R_VAL = PWM_INTERVAL; // start at red
        G_VAL = 0;
        B_VAL = 0;
    end

    always_ff @(posedge time_to_transition) 
        current_state <= next_state; // update current state to be next state

    always_comb begin
        next_state = 3'bxx;
        case(current_state)
            RGB_R_Y:
                next_state = RGB_Y_G;
            RGB_Y_G:
                next_state = RGB_G_C;
            RGB_G_C:
                next_state = RGB_C_B;
            RGB_C_B:
                next_state = RGB_B_M;
            RGB_B_M:
                next_state = RGB_M_R;
            RGB_M_R:
                next_state = RGB_R_Y;
        endcase
    end

     always_ff @(posedge clk) begin
        if (count == INC_DEC_INTERVAL - 1) begin
            count <= 0;
            time_to_inc_dec <= 1'b1;
        end
        else begin
            count <= count + 1;
            time_to_inc_dec <= 1'b0;
        end
    end

    always_ff @(posedge time_to_inc_dec) begin
        case (current_state)
            RGB_R_Y: begin //
                R_VAL <= PWM_INTERVAL; // Red on
                G_VAL <= G_VAL + INC_DEC_VAL; // Green on
                B_VAL <= 0; // Blue off
            end
            RGB_Y_G: begin
                R_VAL <= R_VAL - INC_DEC_VAL; // Red off
                G_VAL <= PWM_INTERVAL; // Green on
                B_VAL <= 0; // Blue off
            end
            RGB_G_C: begin
                R_VAL <= 0; // Red off
                G_VAL <= PWM_INTERVAL; // Green on
                B_VAL <= B_VAL + INC_DEC_VAL; // Blue on
            end
            RGB_C_B: begin
                R_VAL <= 0; // Red off
                G_VAL <= G_VAL - INC_DEC_VAL; // Green off
                B_VAL <= PWM_INTERVAL; // Blue on
            end
            RGB_B_M: begin
                R_VAL <= R_VAL + INC_DEC_VAL; // Red on
                G_VAL <= 0; // Green off
                B_VAL <= PWM_INTERVAL; // Blue on
            end
            RGB_M_R: begin
                R_VAL <= PWM_INTERVAL; // Red on
                G_VAL <= 0; // Green off
                B_VAL <= B_VAL - INC_DEC_VAL; // Blue off
            end
        endcase
    end

     always_ff @(posedge time_to_inc_dec) begin 
        if (inc_dec_count == INC_DEC_MAX - 1) begin
            inc_dec_count <= 0;
            time_to_transition <= 1'b1;
        end
        else begin
            inc_dec_count <= inc_dec_count + 1;
            time_to_transition <= 1'b0;
        end
    end

    always_ff @(posedge clk) begin // counter for PWM period
        if (PWM_COUNTER == PWM_INTERVAL - 1) 
        
            PWM_COUNTER <= 0;
        else
            PWM_COUNTER <= PWM_COUNTER + 1;
    end

    // Assign physical LED pin outputs 
    assign RGB_R = !(PWM_COUNTER < R_VAL); //invert the output so that 0 is on and 1 is off
    assign RGB_G = !(PWM_COUNTER < G_VAL);
    assign RGB_B = !(PWM_COUNTER < B_VAL);

endmodule