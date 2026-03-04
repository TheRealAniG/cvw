// riscvsingle.sv
// RISC-V single-cycle processor
// David_Harris@hmc.edu 2020

module alu(
        input   logic [31:0]    SrcA, SrcB,
        input   logic [1:0]     ALUControl,
        input   logic [2:0]     Funct3,
        input   logic           Funct7b5,
        output  logic [31:0]    ALUResult, IEUAdr,
        input   logic           LUI //changed
    );

    logic [31:0] CondInvb, Sum, SLT;
    logic ALUOp, Sub, Overflow, Neg, LT;
    logic [2:0] ALUFunct;
    logic [31:0] SLTU;

    assign {Sub, ALUOp} = ALUControl;

    // Force subtraction for SLT/SLTI (Funct3 = 010)
    logic ForceSub;
    assign ForceSub = Sub | (ALUOp & (Funct3 == 3'b010));

    // Add or subtract
    assign CondInvb = ForceSub ? ~SrcB : SrcB;
    assign Sum = SrcA + CondInvb + {{(31){1'b0}}, ForceSub};
    assign SLTU = {31'b0, (SrcA < SrcB)};
    assign IEUAdr = Sum; // Send this out to IFU and LSU


    // Set less than based on subtraction result
    assign Overflow = (SrcA[31] ^ SrcB[31]) & (SrcA[31] ^ Sum[31]);
    assign Neg = Sum[31];
    assign LT = Neg ^ Overflow;
    assign SLT = {31'b0, LT};
    assign ALUFunct = Funct3 & {3{ALUOp}}; // Force ALUFunct to 0 to Add when ALUOp = 0

    always_comb begin //changed
        if (LUI) ALUResult = SrcB;
        else case (ALUFunct)
            3'b000: ALUResult = Sum;
            3'b001: ALUResult = SrcA << SrcB[4:0]; // SLL, SLLI
            3'b010: ALUResult = SLT;
            3'b100: ALUResult = SrcA ^ SrcB;
            3'b011: ALUResult = SLTU;  // Funct3 011 is SLTU
            3'b101: if (Funct7b5) ALUResult = $signed(SrcA) >>> SrcB[4:0]; // SRA
            else          ALUResult = SrcA >> SrcB[4:0];           // SRL
            3'b110: ALUResult = SrcA | SrcB;
            3'b111: ALUResult = SrcA & SrcB;
            default: ALUResult = 32'bx;
        endcase
    end
endmodule
