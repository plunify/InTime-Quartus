module dummy_a #(

	parameter CHAIN_LENGTH = 10

) ( 
   input clk,
	input rst_n,
	input in, 
   output out

);


genvar i;
reg [CHAIN_LENGTH-1:0] dreg;

assign out = dreg [CHAIN_LENGTH -1];
 	 
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
