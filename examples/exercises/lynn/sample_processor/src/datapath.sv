// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

module datapath(
        input   logic           clk, reset,
        input   logic [2:0]     Funct3,
        input   logic           ALUResultSrc, ResultSrc,
        input   logic [1:0]     ALUSrc,
        input   logic           RegWrite,
        input   logic [2:0]     ImmSrc,
        input   logic [1:0]     ALUControl,
        input   logic           LUI, //changed
        output  logic           BranchOp,
        input   logic [31:0]    PC, PCPlus4,
        input   logic [31:0]    Instr,
        output  logic [31:0]    IEUAdr, WriteData,
        input   logic [31:0]    ReadData
    );

    logic [31:0] ImmExt;
    logic [31:0] R1, R2, SrcA, SrcB;
    logic [31:0] ALUResult, IEUResult, Result;

    // register file logic
    regfile rf(.clk, .WE3(RegWrite), .A1(Instr[19:15]), .A2(Instr[24:20]),
        .A3(Instr[11:7]), .WD3(Result), .RD1(R1), .RD2(R2));

    extend ext(.Instr(Instr[31:7]), .ImmSrc, .ImmExt);

    // ALU logic
    cmp cmp(.R1, .R2, .Funct3(Instr[14:12]), .BranchOp(BranchOp));

    mux2 #(32) srcamux(R1, PC, ALUSrc[1], SrcA);
    mux2 #(32) srcbmux(R2, ImmExt, ALUSrc[0], SrcB);

    alu alu(.SrcA, .SrcB, .ALUControl, .Funct3, .Funct7b5(Instr[30]), .ALUResult, .IEUAdr, .LUI);

    logic [31:0] SelectedData;
    logic [7:0]  ByteVal;
    logic [15:0] HalfVal;

    // Use the lower bits of the address to shift the correct byte to the bottom
    assign ByteVal = ReadData >> (IEUAdr[1:0] * 8);
    assign HalfVal = ReadData >> (IEUAdr[1] * 16);

    always_comb begin
        case (Funct3)
            3'b000:  SelectedData = {{24{ByteVal[7]}}, ByteVal};  // LB
            3'b001:  SelectedData = {{16{HalfVal[15]}}, HalfVal}; // LH
            3'b100:  SelectedData = {24'b0, ByteVal};             // LBU
            3'b101:  SelectedData = {16'b0, HalfVal};             // LHU
            3'b010:  SelectedData = ReadData;                     // LW
            default: SelectedData = ReadData;
        endcase
    end

    mux2 #(32) ieuresultmux(ALUResult, PCPlus4, ALUResultSrc, IEUResult);
    mux2 #(32) resultmux(IEUResult, SelectedData, ResultSrc, Result);

    // SB repeats the byte 4 times, SH repeats the halfword twice
    always_comb begin
        case (Funct3[1:0])
            2'b00:   WriteData = {4{R2[7:0]}};   // SB
            2'b01:   WriteData = {2{R2[15:0]}};  // SH
            default: WriteData = R2;             // SW
        endcase
    end
endmodule
