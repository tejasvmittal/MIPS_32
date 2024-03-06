`timescale 1ns / 1ps

module EX_pipe_stage(
    input [31:0] id_ex_instr,
    input [31:0] reg1, reg2,
    input [31:0] id_ex_imm_value,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_write_back_result,
    input id_ex_alu_src,
    input [1:0] id_ex_alu_op,
    input [1:0] Forward_A, Forward_B,
    output [31:0] alu_in2_out, // the calculated address for branch
    output [31:0] alu_result // the actual output from the ALU
    );

    // Write your code here
    wire [3:0] alu_control;
    wire [31:0] alu_in1;
    wire [31:0] alu_in2;
    wire [31:0] supp_mux2_out;
    
    ALUControl alu_control_unit(
        .ALUOp(id_ex_alu_op),
        .Function(id_ex_instr[5:0]),
        .ALU_Control(alu_control)  
    );
    
    mux4 #(32) supp_mux1(
        .a(reg1),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .sel(Forward_A),
        .y(alu_in1)        
    );
    
    mux4 #(32) supp_mux2(
        .a(reg2),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .sel(Forward_B),
        .y(supp_mux2_out)
    );
    
    mux2 #(32) supp_mux3(
        .a(supp_mux2_out),
        .b(id_ex_imm_value),
        .sel(id_ex_alu_src),
        .y(alu_in2)
    );
    
    ALU alu_unit(
        .a(alu_in1),
        .b(alu_in2),
        .alu_control(alu_control),
        .alu_result(alu_result)
    );
    
    assign alu_in2_out = supp_mux2_out;      
       
endmodule
