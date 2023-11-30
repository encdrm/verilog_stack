`timescale 1ns / 1ps

module tb_stack();

reg clk, rstn;
reg push, pop;
reg [7:0] stack_in;
wire [7:0] stack_out;
wire full;
wire empty;

stack #(
    .WIDTH(8)
,   .LENGTH(5)
) Q1 (
    .clk(clk)
,   .rstn(rstn)
,   .push_i(push)
,   .pop_i(pop)
,   .data_i(stack_in)
,   .data_o(stack_out)
,   .full(full)
,   .empty(empty)
);

integer i = 0;
initial begin
    clk = 0;
    rstn = 0;
    push = 0; pop = 0;
    stack_in = 0;
    #20 rstn = 1;
    #20;

    // Push test
    push = 1; pop = 0;
    for (i=0; i<16; i=i+1) begin
        stack_in = "a" + i;
        #10;
    end

    // Pop test
    push = 0; pop = 1;
    for (i=0; i<20; i=i+1) begin
        #10;
    end

    // Push & pop simultaneously
    push = 1; pop = 1;
    for (i=0; i<16; i=i+1) begin
        stack_in = "a" + i;
        #10;
    end
    
    push = 0; pop = 0;
    #100;
    $finish;
end

always #5 clk = ~clk;

endmodule
