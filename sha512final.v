`timescale 1ns / 1ps 
 
module sha512final ( 
    input wire clk, 
    input wire reset, 
    input wire [1023:0] message,  // 1024-bit input block 
    output reg [511:0] hash       // 512-bit output hash 
); 
  
// 64-bit rotate right function 
function [63:0] ROR(input [63:0] x, input [10:0] n); 
    ROR = (x >> n) | (x << (64 - n)); 
endfunction 
  
// Initial hash values (SHA-512 constants) 
reg [63:0] h0 = 64'h6a09e667f3bcc908; 
reg [63:0] h1 = 64'hbb67ae8584caa73b; 
reg [63:0] h2 = 64'h3c6ef372fe94f82b; 
reg [63:0] h3 = 64'ha54ff53a5f1d36f1; 
reg [63:0] h4 = 64'h510e527fade682d1; 
reg [63:0] h5 = 64'h9b05688c2b3e6c1f; 
reg [63:0] h6 = 64'h1f83d9abfb41bd6b; 
reg [63:0] h7 = 64'h5be0cd19137e2179; 
  
// SHA-512 round constants 
reg [63:0] k [0:79]; 
initial begin 
    k[ 0] = 64'h428a2f98d728ae22; k[ 1] = 64'h7137449123ef65cd; 
    k[ 2] = 64'hb5c0fbcfec4d3b2f; k[ 3] = 64'he9b5dba58189dbbc; 
    k[ 4] = 64'h3956c25bf348b538; k[ 5] = 64'h59f111f1b605d019; 
    k[ 6] = 64'h923f82a4af194f9b; k[ 7] = 64'hab1c5ed5da6d8118; 
    k[ 8] = 64'hd807aa98a3030242; k[ 9] = 64'h12835b0145706fbe; 
    k[10] = 64'h243185be4ee4b28c; k[11] = 64'h550c7dc3d5ffb4e2; 
    k[12] = 64'h72be5d74f27b896f; k[13] = 64'h80deb1fe3b1696b1; 
    k[14] = 64'h9bdc06a725c71235; k[15] = 64'hc19bf174cf692694; 
    k[16] = 64'he49b69c19ef14ad2; k[17] = 64'hefbe4786384f25e3; 
    k[18] = 64'h0fc19dc68b8cd5b5; k[19] = 64'h240ca1cc77ac9c65; 
    k[20] = 64'h2de92c6f592b0275; k[21] = 64'h4a7484aa6ea6e483; 
    k[22] = 64'h5cb0a9dcbd41fbd4; k[23] = 64'h76f988da831153b5; 
    k[24] = 64'h983e5152ee66dfab; k[25] = 64'ha831c66d2db43210; 
    k[26] = 64'hb00327c898fb213f; k[27] = 64'hbf597fc7beef0ee4; 
    k[28] = 64'hc6e00bf33da88fc2; k[29] = 64'hd5a79147930aa725; 
    k[30] = 64'h06ca6351e003826f; k[31] = 64'h142929670a0e6e70; 
    k[32] = 64'h27b70a8546d22ffc; k[33] = 64'h2e1b21385c26c926; 
    k[34] = 64'h4d2c6dfc5ac42aed; k[35] = 64'h53380d139d95b3df; 
    k[36] = 64'h650a73548baf63de; k[37] = 64'h766a0abb3c77b2a8; 
    k[38] = 64'h81c2c92e47edaee6; k[39] = 64'h92722c851482353b; 
    k[40] = 64'ha2bfe8a14cf10364; k[41] = 64'ha81a664bbc423001; 
    k[42] = 64'hc24b8b70d0f89791; k[43] = 64'hc76c51a30654be30; 
    k[44] = 64'hd192e819d6ef5218; k[45] = 64'hd69906245565a910; 
    k[46] = 64'hf40e35855771202a; k[47] = 64'h106aa07032bbd1b8; 
    k[48] = 64'h19a4c116b8d2d0c8; k[49] = 64'h1e376c085141ab53; 
    k[50] = 64'h2748774cdf8eeb99; k[51] = 64'h34b0bcb5e19b48a8; 
    k[52] = 64'h391c0cb3c5c95a63; k[53] = 64'h4ed8aa4ae3418acb; 
    k[54] = 64'h5b9cca4f7763e373; k[55] = 64'h682e6ff3d6b2b8a3; 
    k[56] = 64'h748f82ee5defb2fc; k[57] = 64'h78a5636f43172f60; 
    k[58] = 64'h84c87814a1f0ab72; k[59] = 64'h8cc702081a6439ec; 
    k[60] = 64'h90befffa23631e28; k[61] = 64'ha4506cebde82bde9; 
    k[62] = 64'hbef9a3f7b2c67915; k[63] = 64'hc67178f2e372532b; 
    k[64] = 64'hca273eceea26619c; k[65] = 64'hd186b8c721c0c207; 
    k[66] = 64'heada7dd6cde0eb1e; k[67] = 64'hf57d4f7fee6ed178; 
    k[68] = 64'h06f067aa72176fba; k[69] = 64'h0a637dc5a2c898a6; 
    k[70] = 64'h113f9804bef90dae; k[71] = 64'h1b710b35131c471b; 
    k[72] = 64'h28db77f523047d84; k[73] = 64'h32caab7b40c72493; 
    k[74] = 64'h3c9ebe0a15c9bebc; k[75] = 64'h431d67c49c100d4c; 
    k[76] = 64'h4cc5d4becb3e42b6; k[77] = 64'h597f299cfc657e2a; 
    k[78] = 64'h5fcb6fab3ad6faec; k[79] = 64'h6c44198c4a475817; 
end 
  
// Working variables 
reg [63:0] a, b, c, d, e, f, g, h; 
reg [63:0] w [0:79]; 
reg [63:0] temp1, temp2; 
integer i; 
  
always @(posedge clk or posedge reset) begin 
    if (reset) begin 
        hash <= 512'b0; 
        for (i = 0; i < 80; i = i + 1) 
            w[i] <= 0; 
        a = 0; b = 0; c = 0; d = 0; 
        e = 0; f = 0; g = 0; h = 0; 
    end else begin 
        for (i = 0; i < 16; i = i + 1) 
            w[i] = message[1023 - (i * 64) -: 64]; 
  
        for (i = 16; i < 80; i = i + 1) 
            w[i] = (ROR(w[i-2], 19) ^ ROR(w[i-2], 61) ^ (w[i-2] >> 6)) + w[i-7] + 
                   (ROR(w[i-15], 1) ^ ROR(w[i-15], 8) ^ (w[i-15] >> 7)) + w[i-16]; 
  
        a = h0; b = h1; c = h2; d = h3; 
        e = h4; f = h5; g = h6; h = h7; 
  
        for (i = 0; i < 80; i = i + 1) begin 
            temp1 = h + (ROR(e,14)^ROR(e,18)^ROR(e,41)) + ((e&f)^((~e)&g)) + k[i] + w[i]; 
            temp2 = (ROR(a,28)^ROR(a,34)^ROR(a,39)) + ((a&b)^(a&c)^(b&c)); 
            h = g; g = f; f = e; e = d + temp1; 
            d = c; c = b; b = a; a = temp1 + temp2; 
        end 
  
        h0 = h0 + a; h1 = h1 + b; h2 = h2 + c; h3 = h3 + d; 
        h4 = h4 + e; h5 = h5 + f; h6 = h6 + g; h7 = h7 + h; 
  
        hash = {h0, h1, h2, h3, h4, h5, h6, h7}; 
    end 
end 
  
endmodule 
