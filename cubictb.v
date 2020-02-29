`timescale 1ns/1ps

module cubictb;

  reg  signed [ 9: 0]  in;
  wire signed [ 9: 0] out;

  cubic DUT1(.in(in),
             .out(out) );

  integer n, loss_count;
  real loss, loss_sum;
  reg ovf;

  initial begin
    in = 10'd0;
    loss = 0.0;
    loss_sum = 0.0;
    loss_count = 0;
    
    for (n = 0; n < 1024; n = n + 8) begin
      #10;
      
      $display("in: 0x%x, %4d, %3.5f | out: 0x%x, %4d, %3.5f | actual:, %3.5f"
               , in, in, $itor( in)  / 128.0
               , out, out, $itor(out) / 64.0
               , $itor( 0.85 * (in / 128.0) ** 3 + 1.0) );
      
      // loss & overflow calculation      
      loss = ((out / 64.0) - ( 0.85 * (in / 128.0) ** 3 + 1.0));
      ovf = ((in/128.0) >= 2.0) || ((in/128.0) <= -2.0);
      
      if (!ovf) begin
         $display("loss (out - actual): %f\n", loss );
         loss_sum = (loss >= 0.0) ? (loss_sum + loss) : (loss_sum - loss);
         loss_count = loss_count + 1;  
      end else begin
         $display("loss (out - actual): overflow\n");
      end
      
      in = in + 10'd8;
    end // for (n = 0; n < 1024; n = n + 8)
      
    $display("AVG loss: %2.5f (should be smaller than 0.025)\n "
               ,(loss_sum / loss_count) );
    
    $stop;
  end // initial

endmodule

// vsim -c cubictb -do "run -all; exit"