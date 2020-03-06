// lecture11 - Fixed Point Computations in Verilog
//
// Write a module that computes the
// cubic expression 
//
//    f(x) = 0.85 * x^3 + 1
//
// The input  data is a signed fix<10, 7>
// The output data is a signed fix<10, 6>
// In case of overflow, the module returns 0
//

// f(x) = CONST_0_85 * in * in * in + CONST_1
//      = CONST_0_85 * square * in + CONST_1
//      = CONST_0_85 * cubic + CONST_1
//      = cmul + CONST_1

// VARIABLES   PRECISION   SIGN
// =================================
// in          <10, 7>     signed
// square      <20, 14>    unsigned
// square_10   <10, 7>     unsigned
// cubic       <20, 14>    signed
// cubic_10    <10, 6>     signed
// 
// CONST_0_85  <10, 9>     unsigned
// cmul        <20, 15>    signed
// cmul_10     <10, 6>     signed
// CONST_1     <10, 6>     unsigned
// out         <10, 6>     signed

module cubic( input signed  [9:0] in,     // <10, 7> signed
              output signed [9:0] out);   // <10, 6> signed

  parameter  [9:0] CONST_0_85 = (0.85 * 512); // <10, 9> signed
  parameter  [9:0] CONST_1    = (1 * 64);     // <10, 6> signed
    
  wire       ovfsquare, ovfcubic;

  // in^2 Operation (positive result)
  wire [19:0] square;         // <20, 14> unsigned
  wire [9:0]  square_10;      // <10, 7>  unsigned
  
  assign square = {{10{in[9]}}, in} * {{10{in[9]}}, in};  // in * in
  assign square_10 = square[16:7];
  
  assign ovfsquare = (square[19:17] != 3'b000);
  
  
  // in^3 Operation (signed result)
  wire signed [19:0] cubic;    // <20, 14> signed
  wire signed [9:0]  cubic_10; // <10, 6>  signed
  
  assign cubic = {10'b0, square_10} * {{10{in[9]}}, in}; //square_10 * in
  assign cubic_10 = cubic[17:8];
  
  assign ovfcubic = (cubic[19:17] != 3'b000) &&
                    (cubic[19:17] != 3'b111);
  
  // in^3 * Constant
  wire signed [19:0] cmul;      // <20, 15> signed
  wire signed [9:0]   cmul_10;   // <10, 6>  signed
  
  assign cmul = {10'b0, CONST_0_85} * {{10{cubic_10[9]}}, cubic_10}; // CONST_0_85 * cubic_10
  assign cmul_10 = cmul[18:9];
  
  
  // in^3 * Constant "+ 1"
  wire signed [9:0] result;      // <10, 6> signed
  
  assign result = cmul_10 + CONST_1;
  
  assign out = (ovfsquare || ovfcubic) ? 10'd0 : result;

endmodule