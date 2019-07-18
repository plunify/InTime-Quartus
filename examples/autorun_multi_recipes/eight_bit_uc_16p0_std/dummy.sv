module dummy #(

	parameter CHAIN_LENGTH = 10

) ( 
   input clk,
	input rst_n,
	input in, 
   output out

);

wire dummu_a_out ;

	 dummy_a u_dummy_a (
		.clk (clk)
		,.rst_n (rst_n)
		,.in(in) 
		,.out(dummy_a_out)
	 );
    defparam u_dummy_a.CHAIN_LENGTH = 5;

 
genvar i;
reg [CHAIN_LENGTH-1:0] dreg;

assign out = dreg [CHAIN_LENGTH -1] & dummy_a_out;
 	 
generate
      for (i=1; i<CHAIN_LENGTH ; i=i+1)
      begin: D
			always @ (posedge clk or negedge rst_n)
         begin
            if (!rst_n)
            begin					
					dreg[i] <= 1'b0;
            end
            else
            begin
               dreg [i] <= dreg [i] ^ dreg [i-1];				   	
            end
         end
      end			
endgenerate    

			always @ (posedge clk or negedge rst_n)
         begin
            if (!rst_n)
            begin	
               dreg[0] <= 1'b0;				
            end
            else
            begin
				   dreg [0] <= in;			   	
            end
         end        

endmodule 
