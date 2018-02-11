`timescale 1ns / 1ps
module stopwatchController(seg, an, clk, dp, start, stop, up, reset, lap, set);
    output [0:6] seg;
    output [3:0] an;
    output [0:0] dp;
    input clk;
    input start;
    input stop;
    input up;
    input reset;
    input lap;
    input set;

    reg [0:3] dots = 4'b1010;
    reg tick = 1'b0;
    reg running = 1'b0;
    reg flashing = 1'b0;
    reg started = 1'b0;
    reg countDirection = 1'b1;
    reg resetState = 1'b0;
    reg lapState = 1'b0;
    reg setState = 1'b0;
    
    wire [3:0] A;
    wire [3:0] B;
    wire [3:0] C;
    wire [3:0] D;
    
    reg [3:0] lapA;
    reg [3:0] lapB;
    reg [3:0] lapC;
    reg [3:0] lapD;

    integer count = 0;

    always @(posedge clk)
    begin
        // Start stop
        if(start)
        begin
            running = 1'b1;
            flashing = 1'b0;
            lapState = 1'b0;
        end
        
        if(stop)
        begin
            running = 1'b0;
            flashing = 1'b0;
        end

        // Count Direction
        if(!running)
            countDirection = up;

        // Reset
        if(!running)
            resetState = reset;
        if(reset)
            started = 0;
        if(resetState)
            lapState = 0;

        // Stop at 0 and flash
        if(A == 0 && B == 0 && C == 0 && D == 0 && started && setState == 0)
        begin
            running = 0;
            flashing = 1;
            started = 0;
        end
        
        // Started
        if(A != 0 || B != 0 || C != 0 || D != 0)
        begin
            started = 1;
            flashing = 0;
        end
        
        // Lap Button
        if(lap)
            lapState = 1'b1;
        
        // Lap Display
        if(!lapState)
        begin
            lapA = A;
            lapB = B;
            lapC = C;
            lapD = D;
        end
        
        // Set setState
        if(!running)
            setState = set;
        
        if(!setState)
            count = count + 1;
        else
            count = count + 5;
            
        if(count >= 5000000)
        begin
            tick = tick + 1'b1;
            count = 0;
        end
    end

    counter counter1(A, B, C, D, tick, resetState, running, countDirection);

    fourdigitdriver driver1(lapA, lapB, lapC, lapD, clk, dots, seg, an, dp, flashing);

endmodule