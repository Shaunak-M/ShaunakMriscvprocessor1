module imem (
    input  logic [31:0] a,
    output logic [31:0] rd
);
    logic [31:0] RAM [0:63];

    initial $readmemh("riscvtest.txt", RAM);  // put your hex program in this file

    assign rd = RAM[a[31:2]];  // word aligned
endmodule
