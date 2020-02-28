`timescale 1ns/1ps

module cubictb;

  reg  signed [ 9: 0]  in;
  wire signed [ 9: 0] out;

  cubic DUT1(.in(in), .out(out));

  integer n;

  initial
    begin
    in = 10'd0;
    for (n = 0; n < 1024; n = n + 8)
      begin
      #10;
      $display("in %x (%d) (%f) out %x (%d) (%f) ", in,   in, $itor( in)  / 128.0  , 
      	                                            out, out, $itor(out) / 64.0);
      in = in + 10'd8;
      end
      $stop;
    end

endmodule

// vsim -c quadratictb -do "run -all; exit"