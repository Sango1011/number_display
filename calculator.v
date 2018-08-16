module calculator(clock,reset,D,N,state,neg);
    input clock, reset;
    input [3:0] N; 
    output reg [19:0]D;
    output reg [2:0] state;
    output reg neg;
	reg [2:0] next;
	reg [3:0]N1,N2,N3,N4,N5;
    
    parameter S0=3'b000, S1=3'b001, S2=3'b010, S3=3'b011, S4=3'b100, S5=3'b101;
    
	//reset conditions
	always@(posedge clock or posedge reset)
    begin
        if(reset)
            begin
            state <= S0;
            end
        else state <= next;
    end
    
	//state transition logic
    always@(state,N)
    begin
        case(state)
            S0: if(N==4'b0 || N > 4'b1001) next=S0;  
                else next=S1;
            S1: if (N>4'b1001) next=S1;
				else next=S2;
			S2: begin 
				if (N==4'b1111 && neg==1'b1) next=S1;
				else if (N>4'b1001) next=S2;
				else next=S3; end
			S3: begin
				if (N==4'b1111 && neg==1'b1) next=S2;
				else if (N>4'b1001) next=S3;
				else next=S4; end
			S4: begin
				if (N==4'b1111 && neg==1'b1) next=S3;
				else if (N>4'b1001) next=S4;
				else next=S5; end
			S5:  next=S5;
            default: next=S0;
        endcase
    end
    
    //reset conditions
    always@(posedge clock or posedge reset)
    begin
        if (reset) begin
            D<=20'b0; state<=S0; neg<=1'b0; N1<=1'b0; N2<=1'b0; N3<=1'b0;N4<=1'b0;N5<=1'b0; end		//reset conditions
        else  state<=next;
     end
     
	//state transistion operations         
    always@(posedge clock)
    begin        
        case(state)
            S0: begin 
                if(N>4'b0 && N<4'b1010)   
                    N1<=N; end     					//move input to N1
            S1: begin 
                if(N==4'b1111) begin				
                    N2<=N; neg<=~neg; end		// transfer to N2 and toggle negative
                else if (N<4'b1010) N2<=N;
                else N2<=4'b0; end	
			S2: begin	
				if (N==4'b1111) begin
					if (neg) begin
						N3<=N; neg=~neg; end
					else begin N3<=N; neg=~neg; end end
				else if (N<4'b1010) N3<=N; 
				else N3<=4'b0; end
			S3: begin	
				if (N==4'b1111) begin
					if (neg) begin
						neg=~neg; end
					else begin N4<=N; neg=~neg; end end
				else if (N<4'b1010) N4<=N; 
				else N4<=4'b0; end 
			S4: begin	
				if (N==4'b1111) begin
					if (neg) begin
						neg=~neg; end
					else begin N5<=N; neg=~neg; end end
				else N5<=4'b0; end
            default: state <= S0;
        endcase
    end
    
	//output conditions
    always@(state)				
    begin
        case(state)
			S0: D=20'b0;
			S1: D={16'b0,N1};
			S2: D={12'b0,N1,N2};
			S3: D={8'b0,N1,N2,N3};
			S4: D={4'b0,N1,N2,N3,N4};
			S5: D={N5,N1,N2,N3,N4};
		endcase
	end
    
endmodule
