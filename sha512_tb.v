module sha512_tb; 
  
    reg clk; 
    reg reset; 
    reg [1023:0] message; 
    wire [511:0] hash; 
  
    // Instantiate SHA-256 module 
    sha512final uut ( 
        .clk(clk), 
        .reset(reset), 
        .message(message), 
        .hash(hash) 
    ); 
  
    // Clock generation 
    always #5 clk = ~clk; 
  
    initial begin 
        // Initialize signals 
        clk = 0; 
        reset = 1; 
    // Padded 1024-bit message for "abc" 
      
message=1024'h6162638000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000018; 
         
        #10 reset = 0; 
  
        // Wait for computation 
        #100; 
  
        // Display result 
       
  
        // End simulation 
        #10 $finish; 
    end 
  
endmodule
