`timescale 1ns / 1ps


module ID_pipe_stage(
    input  clk, reset,
    input  [9:0] pc_plus4,
    input  [31:0] instr,
    input  mem_wb_reg_write, // enable writing to register
    input  [4:0] mem_wb_write_reg_addr, // the address of the register to be written to
    input  [31:0] mem_wb_write_back_data, // the data to be written to the register. 
    input  Data_Hazard,
    input  Control_Hazard,
    output [31:0] reg1, reg2,
    output [31:0] imm_value,
    output [9:0] branch_address,
    output [9:0] jump_address,
    output branch_taken,
    output [4:0] destination_reg, 
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_read,  
    output mem_write,
    output alu_src,
    output reg_write,
    output jump
    );
    // write your code here 
    // Remember that we test if the branch is taken or not in the decode stage.  
    
    wire branch;
    wire eq_test;
    wire [27:0] instr_25_0_sl;
    wire [33:0] imm_value_sl;
    wire reg_dst;
    wire hazard_sel;
    
    wire mem_to_reg_wire, mem_read_wire, mem_write_wire, alu_src_wire, reg_write_wire;
    wire [1:0] alu_op_wire;
    wire [31:0] imm_value_sign_extend;
    wire [31:0] reg1_wire, reg2_wire;
    
    assign hazard_sel = (~Data_Hazard | Control_Hazard);
       
    control control_unit(
        .reset(reset),
        .opcode(instr[31:26]),
        .reg_dst(reg_dst),
        .mem_to_reg(mem_to_reg_wire),
        .alu_op(alu_op_wire),
        .mem_read(mem_read_wire),
        .mem_write(mem_write_wire),
        .alu_src(alu_src_wire),
        .reg_write(reg_write_wire),
        .branch(branch),
        .jump(jump)        
    );
    
    mux2 #(1) mux_mem_to_reg(.a(mem_to_reg_wire), .b(1'b0), .sel(hazard_sel), .y(mem_to_reg));
    mux2 #(2) mux_alu_op(.a(alu_op_wire), .b(2'b00), .sel(hazard_sel), .y(alu_op));
    mux2 #(1) mux_mem_read(.a(mem_read_wire), .b(1'b0), .sel(hazard_sel), .y(mem_read));
    mux2 #(1) mux_mem_write(.a(mem_write_wire), .b(1'b0), .sel(hazard_sel), .y(mem_write));
    mux2 #(1) mux_alu_src(.a(alu_src_wire), .b(1'b0), .sel(hazard_sel), .y(alu_src));
    mux2 #(1) mux_reg_write(.a(reg_write_wire), .b(1'b0), .sel(hazard_sel), .y(reg_write));
     
    
    // if hazard or flush is true, set control signals to 0
    
       
    register_file registers_inst(
        .clk(clk),
        .reset(reset),
        .reg_write_en(mem_wb_reg_write),
        .reg_write_dest(mem_wb_write_reg_addr),
        .reg_write_data(mem_wb_write_back_data),
        .reg_read_addr_1(instr[25:21]),
        .reg_read_addr_2(instr[20:16]),
        .reg_read_data_1(reg1_wire),
        .reg_read_data_2(reg2_wire)
    );

    assign eq_test = (reg1_wire == reg2_wire) ? 1'b1 : 1'b0;
    assign branch_taken = eq_test & branch;
    assign instr_25_0_sl = instr[25:0] << 2;
    assign jump_address = instr_25_0_sl[9:0]; // RECHECK
    
    assign reg1 = reg1_wire;
    assign reg2 = reg2_wire;
    
    sign_extend sign_extend_unit(
        .sign_ex_in(instr[15:0]),
        .sign_ex_out(imm_value_sign_extend)
    );
    
    // setting branch address
    assign imm_value_sl = imm_value_sign_extend << 2;
    assign branch_address = imm_value_sl[9:0] + pc_plus4;
    assign imm_value = imm_value_sign_extend;
    
    mux2 #(5) reg_mux (
        .a(instr[20:16]),
        .b(instr[15:11]),
        .sel(reg_dst),
        .y(destination_reg)        
    );
       
endmodule
