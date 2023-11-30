`timescale 1ns / 1ps
/**
 * This module implements a stack with reconfigurable data width and size
 *
 * Parameters:
 *      WIDTH - 데이터 크기
 *      LENGTH - 최대 데이터 저장 개수
 *
 * Inputs:
 *      push_i - Push 신호
 *      pop_i - Pop 신호
 *      data_i - Push 시 입력 데이터
 *
 * Outputs:
 *      data_o - Pop 시 출력 데이터
 *      full_o - Stack 가득 찼는지 여부
 *      empty_o - Stack 비었는지 여부
 * 
 * Ring buffer 코드를 Stack용으로 개조
 */
module stack #(
    parameter   WIDTH           = 8,
                LENGTH          = 128
)(
    clk
,   rstn
,   push_i
,   pop_i
,   data_i
,   data_o
,   full
,   empty
);
input clk, rstn;
input push_i;
input pop_i;
input       [WIDTH-1:0] data_i;
output reg  [WIDTH-1:0] data_o;
output reg              full;
output reg              empty;

localparam  MEM_DEPTH   = LENGTH,               // LENGTH 개수 데이터 저장 위해선 LENGTH Depth의 Memory 필요
            ADDR_BIT    = $clog2(MEM_DEPTH)+1;  // Memory 주소 표현을 위한 비트 수. 음수 표현을 위해 1비트 추가

reg [WIDTH-1:0] buffer_m [0:MEM_DEPTH-1];
reg signed [ADDR_BIT-1:0] top_r;

/**
 * 모듈의 상태를 판단하고, 다음 top 값을 계산하는 logic
 */
reg [ADDR_BIT-1:0] top_next;
reg can_push, can_pop;
reg do_push, do_pop, do_forward;
always @(*) begin
    // Buffer state
    full  = (top_r == LENGTH-1);
    empty = (top_r[ADDR_BIT-1]);    // top이 음수면 empty

    // Push, pop이 가능한지 판단
    can_push = ~full;
    can_pop = ~empty;

    // Push, pop, forward 진행 신호 생성
    do_push = push_i & can_push & ~pop_i;
    do_pop = pop_i & can_pop & ~push_i;
    do_forward = (push_i & pop_i);      // Push, Pop 동시 입력 시 input->output으로 forward

    // 다음 top 값 결정
    if (do_push)
        top_next = top_r + 1;
    else if (do_pop)
        top_next = top_r - 1;
    else
        top_next = top_r;
end

// Head, top transition logic
always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        top_r <= {(ADDR_BIT){1'b1}};  // -1로 초기화
    end
    else begin
        top_r <= top_next;
    end
end

// Enqueue logic
always @(posedge clk) begin
    if (do_push)
        buffer_m[top_r+1] <= data_i;
end

// Dequeue logic
always @(*) begin
    if (do_pop)
        data_o = buffer_m[top_r];
    else if (do_forward)
        data_o = data_i;
    else
        data_o = {(WIDTH){1'b0}};
end

endmodule