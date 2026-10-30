module aludec (
    input  logic       opb5,
    input  logic [2:0] funct3,
    input  logic       funct7b5,
    input  logic [1:0] ALUOp,
    output logic [2:0] ALUControl
);
    logic RtypeSub;
    assign RtypeSub = funct7b5 & opb5;   // sub only for R-type

    always_comb begin
        case (ALUOp)
            2'b00:   ALUControl = 3'b000;  // add (lw/sw)
            2'b01:   ALUControl = 3'b001;  // sub (beq)
            default: case (funct3)
                3'b000:  ALUControl = RtypeSub ? 3'b001 : 3'b000; // sub / add
                3'b010:  ALUControl = 3'b101;                     // slt
                3'b110:  ALUControl = 3'b011;                     // or
                3'b111:  ALUControl = 3'b010;                     // and
                default: ALUControl = 3'bxxx;
            endcase
        endcase
    end
endmodule
