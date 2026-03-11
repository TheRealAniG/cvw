// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

`include "parameters.svh"

module ieu(
        input   logic           clk, reset,
        input   logic [31:0]    Instr,
        input   logic [31:0]    PC, PCPlus4,
        output  logic           PCSrc,
        output  logic [3:0]     WriteByteEn,
        output  logic [31:0]    IEUAdr, WriteData,
        input   logic [31:0]    ReadData,
        output  logic           MemEn
    );

    logic RegWrite, Jump, BranchOp, ALUResultSrc, ResultSrc, LUI; //changed
    logic [1:0]  ALUSrc;
    logic [2:0]  ImmSrc;
    logic [1:0]  ALUControl;
    logic        CSRSrc;
    logic [31:0] CSRReadData;

    csrfile csr(.clk, .reset, .CSRAdr(Instr[31:20]), .Op(Instr[6:0]), .Funct3(Instr[14:12]),
        .Funct7b5(Instr[30]), .BranchOp, .CSRReadData);

    controller c(.Op(Instr[6:0]), .Funct3(Instr[14:12]), .Funct7b5(Instr[30]), .BranchOp, .AddrOffset(IEUAdr[1:0]),
        .ALUResultSrc, .ResultSrc, .WriteByteEn, .PCSrc,
        .ALUSrc, .RegWrite, .ImmSrc, .ALUControl, .MemEn, .LUI, .CSRSrc
    `ifdef DEBUG
        , .insn_debug(Instr)
    `endif
    );

    datapath dp(.clk, .reset, .Funct3(Instr[14:12]),
        .ALUResultSrc, .ResultSrc, .ALUSrc, .RegWrite, .ImmSrc, .ALUControl, .BranchOp,
        .PC, .PCPlus4, .Instr, .IEUAdr, .WriteData, .ReadData, .LUI, .CSRSrc, .CSRReadData);
endmodule
