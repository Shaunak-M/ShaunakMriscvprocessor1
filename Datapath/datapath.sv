module datapath (
    input  logic        clk, reset,
    input  logic [1:0]  ResultSrc,
    input  logic        PCSrc, ALUSrc,
    input  logic        RegWrite,
    input  logic [1:0]  ImmSrc,
    input  logic [2:0]  ALUControl,
    output logic        Zero,
    output logic [31:0] PC,
    input  logic [31:0] Instr,
    output logic [31:0] ALUResult, WriteData,
    input  logic [31:0] ReadData
);
    logic [31:0] PCNext, PCPlus4, PCTarget;
    logic [31:0] ImmExt;
    logic [31:0] SrcA, SrcB;
    logic [31:0] Result;

    // next PC logic
    flopr #(32) pcreg   (clk, reset, PCNext, PC);
    adder       pcadd4  (PC, 32'd4, PCPlus4);
    adder       pcaddbr (PC, ImmExt, PCTarget);
    mux2 #(32)  pcmux   (PCPlus4, PCTarget, PCSrc, PCNext);

    // register file logic
    regfile     rf      (clk, RegWrite, Instr[19:15], Instr[24:20],
                         Instr[11:7], Result, SrcA, WriteData);
    extend      ext     (Instr[31:7], ImmSrc, ImmExt);

    // ALU logic
    mux2 #(32)  srcbmux (WriteData, ImmExt, ALUSrc, SrcB);
    alu         alu     (SrcA, SrcB, ALUControl, ALUResult, Zero);
    mux3 #(32)  resultmux (ALUResult, ReadData, PCPlus4, ResultSrc, Result);
endmodule


module flopr #(parameter WIDTH = 8) (
    input  logic             clk, reset,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
    always_ff @(posedge clk, posedge reset)
        if (reset) q <= 0;
        else       q <= d;
endmodule


module regfile (
    input  logic        clk,
    input  logic        we3,
    input  logic [4:0]  a1, a2, a3,
    input  logic [31:0] wd3,
    output logic [31:0] rd1, rd2
);
    logic [31:0] rf [31:0];

    // write on rising edge; x0 is hardwired to 0
    always_ff @(posedge clk)
        if (we3) rf[a3] <= wd3;

    assign rd1 = (a1 != 0) ? rf[a1] : 32'b0;
    assign rd2 = (a2 != 0) ? rf[a2] : 32'b0;
endmodule


module extend (
    input  logic [31:7] instr,
    input  logic [1:0]  immsrc,
    output logic [31:0] immext
);
    always_comb begin
        case (immsrc)
            2'b00:   immext = {{20{instr[31]}}, instr[31:20]};                                   // I-type
            2'b01:   immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};                      // S-type
            2'b10:   immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};      // B-type
            2'b11:   immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};    // J-type
            default: immext = 32'bx;
        endcase
    end
endmodule
