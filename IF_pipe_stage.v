`timescale 1ns / 1ps


module IF_pipe_stage(
    input clk, reset,
    input en,
    input [9:0] branch_address,
    input [9:0] jump_address,
    input branch_taken,
    input jump,
    output [9:0] pc_plus4,
    output [31:0] instr
    );

wire[9:0] mux_out;
wire[9:0] pc;
reg [9:0] pc_out;

mux2 #(10) mux_branch(
    .a(pc_plus4),
    .b(branch_address),
    .sel(branch_taken),
    .y(mux_out)
);
    
mux2 #(10) mux_jump(
    .a(mux_out),
    .b(jump_address),
    .sel(jump),
    .y(pc)
);

always @ (posedge clk or posedge reset) begin
    if (reset)
        pc_out = 10'b0;
    else if (en) 
        pc_out = pc;
end


assign pc_plus4 = pc_out + 10'b0000000100;

instruction_mem instruction_mem_inst(
    .read_addr(pc_out),
    .data(instr)
);
// Use instr_mem module from previous labs
// write your code here
      
endmodule
