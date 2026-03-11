// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

module alu(
        input   logic [31:0]    SrcA, SrcB,
        input   logic [1:0]     ALUControl,
        input   logic [2:0]     Funct3,
        input   logic           Funct7b5,
        input   logic [6:0]     Funct7,
        output  logic [31:0]    ALUResult, IEUAdr,
        input   logic           LUI
    );

    logic [31:0] CondInvb, Sum, SLT;
    logic ALUOp, Sub, Overflow, Neg, LT;
    logic [2:0] ALUFunct;
    logic [31:0] SLTU;
    logic [63:0] MulResult;
    logic isMul;

    assign {Sub, ALUOp} = ALUControl;
    assign isMul = (Funct7 == 7'b0000001) & ALUOp;

    // Force subtraction for SLT/SLTI (Funct3 = 010)
    logic ForceSub;
    assign ForceSub = Sub | (ALUOp & (Funct3 == 3'b010));

    // Add or subtract
    assign CondInvb = ForceSub ? ~SrcB : SrcB;
    assign Sum = SrcA + CondInvb + {{(31){1'b0}}, ForceSub};
    assign SLTU = {31'b0, (SrcA < SrcB)};
    assign IEUAdr = Sum;

    // Set less than based on subtraction result
    assign Overflow = (SrcA[31] ^ SrcB[31]) & (SrcA[31] ^ Sum[31]);
    assign Neg = Sum[31];
    assign LT = Neg ^ Overflow;
    assign SLT = {31'b0, LT};
    assign ALUFunct = Funct3 & {3{ALUOp}};

    // Multiply result selection
    always_comb begin
        case (Funct3)
            3'b000: MulResult = $signed({{1{SrcA[31]}}, SrcA}) * $signed({{1{SrcB[31]}}, SrcB}); // MUL
            3'b001: MulResult = $signed({{1{SrcA[31]}}, SrcA}) * $signed({{1{SrcB[31]}}, SrcB}); // MULH
            3'b010: MulResult = $signed({{1{SrcA[31]}}, SrcA}) * $signed({1'b0, SrcB});           // MULHSU
            3'b011: MulResult = {1'b0, SrcA} * {1'b0, SrcB};                                     // MULHU
            default: MulResult = 64'b0;
        endcase
    end

    always_comb begin
        if (LUI) ALUResult = SrcB;
        else if (isMul) begin
            case (Funct3)
                3'b000:  ALUResult = MulResult[31:0];   // MUL
                default: ALUResult = MulResult[63:32];  // MULH, MULHSU, MULHU
            endcase
        end
        else case (ALUFunct)
            3'b000: ALUResult = Sum;
            3'b001: ALUResult = SrcA << SrcB[4:0];
            3'b010: ALUResult = SLT;
            3'b100: ALUResult = SrcA ^ SrcB;
            3'b011: ALUResult = SLTU;
            3'b101: if (Funct7b5) ALUResult = $signed(SrcA) >>> SrcB[4:0];
                    else          ALUResult = SrcA >> SrcB[4:0];
            3'b110: ALUResult = SrcA | SrcB;
            3'b111: ALUResult = SrcA & SrcB;
            default: ALUResult = 32'bx;
        endcase
    end
endmodule
