// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

`include "parameters.svh"

module controller(
        input   logic [6:0]   Op,
        input   logic         BranchOp,
        input   logic [2:0]   Funct3,
        input   logic         Funct7b5,
        input   logic [1:0]   AddrOffset,
        output  logic         ALUResultSrc,
        output  logic         ResultSrc,
        output  logic [3:0]   WriteByteEn,
        output  logic         PCSrc,
        output  logic         RegWrite,
        output  logic [1:0]   ALUSrc,
        output  logic [2:0]   ImmSrc,
        output  logic [1:0]   ALUControl,
        output  logic         MemEn,
        output  logic         LUI,
        output  logic         CSRSrc
    `ifdef DEBUG
        , input   logic [31:0]  insn_debug
    `endif
    );

    logic Branch, Jump;
    logic Sub, ALUOp;
    logic MemWrite;
    logic [12:0] controls;

    // Main decoder
    always_comb
        case(Op)
            // RegWrite_ImmSrc_ALUSrc_ALUOp_ALUResultSrc_MemWrite_ResultSrc_Branch_Jump_Load
            7'b0000011: controls = 13'b1_000_01_0_0_0_1_0_0_1; // lw
            7'b0100011: controls = 13'b0_001_01_0_0_1_0_0_0_1; // sw
            7'b0110011: controls = 13'b1_xxx_00_1_0_0_0_0_0_0; // R-type
            7'b0010011: controls = 13'b1_000_01_1_0_0_0_0_0_0; // I-type ALU
            7'b1100011: controls = 13'b0_010_11_0_0_0_0_1_0_0; // beq
            7'b1101111: controls = 13'b1_011_11_0_1_0_0_0_1_0; // jal
            7'b1100111: controls = 13'b1_000_01_0_1_0_0_0_1_0; // jalr
            7'b0110111: controls = 13'b1_100_01_0_0_0_0_0_0_0; // lui
            7'b0010111: controls = 13'b1_100_11_0_0_0_0_0_0_0; //auipc
            7'b1110011: controls = 13'b1_000_01_0_0_0_0_0_0_0; // csrrs

            default: begin
                `ifdef DEBUG
                    // controls = 13'bx_xxx_xx_x_x_x_x_x_x_x; // non-implemented instruction
                    // if ((insn_debug !== 'x)) begin
                        // $display("Instruction not implemented: %h", insn_debug);
                        // $finish(-1);
                    // end
                `else
                    controls = 13'b0; // non-implemented instruction
                `endif
            end
        endcase

    assign {RegWrite, ImmSrc, ALUSrc, ALUOp, ALUResultSrc, MemWrite,
        ResultSrc, Branch, Jump, MemEn} = controls;

    // ALU Control Logic
    assign Sub = ALUOp & (Funct3 == 3'b000) & Funct7b5 & Op[5];
    assign ALUControl = {Sub, ALUOp};

    // PCSrc logic
    assign PCSrc = Branch & BranchOp | Jump;
    assign LUI = (Op == 7'b0110111); //changed
    assign CSRSrc = (Op == 7'b1110011) & (Funct3 == 3'b010);

    // MemWrite logic
    always_comb begin
        if (MemWrite) begin
            case (Funct3[1:0])
                2'b00: // SB (Store Byte)
                    case (AddrOffset)
                        2'b00: WriteByteEn = 4'b0001;
                        2'b01: WriteByteEn = 4'b0010;
                        2'b10: WriteByteEn = 4'b0100;
                        2'b11: WriteByteEn = 4'b1000;
                    endcase
                2'b01: // SH (Store Halfword)
                    case (AddrOffset[1])
                        1'b0:  WriteByteEn = 4'b0011;
                        1'b1:  WriteByteEn = 4'b1100;
                    endcase
                default: WriteByteEn = 4'b1111; // SW (Store Word)
            endcase
        end else begin
            WriteByteEn = 4'b0000;
        end
    end
endmodule
