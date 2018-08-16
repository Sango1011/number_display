module calc_display(clock,reset,data,R,state,next,count);
    input clock, reset;
    input [3:0] data; 
    output reg [19:0] R;
    output reg [1:0] state, next;
    output reg [2:0] count;
    
    parameter S0=2'b00, S1=2'b01;
 
     //reset conditions
    always@(posedge clock or posedge reset)
    begin
        if (reset) begin                      
            R<=20'b0; state<=S0; count<=3'b001; end 
        else 
            state<=next; end
          
	//state transition logic
    always@(state,R,count)
    begin
        case(state)
            S0: begin
                if(R > 20'b0 && R < 20'b1010) next=S1;
                else next=S0;
                end
            S1: next=S1;
            default: next=S0;
        endcase
    end
     
	//state transistion operations
    always@(posedge clock)
    begin		
        case(state)
            S0: begin if(R < 20'b1010 && R > 20'b0) begin	//do the following when 0 to 9
                    count <= count+1'b1; 			//increment the count
                    R <= {R[15:0],data}; end		//load in the data and shift left                   
                else R <= {R[19:4],data}; end 	     //just load with no shift
            S1: begin if(count < 3'b101) begin		//conditions to continue to accept data
                    R <= {R[15:0],data};		//left shift in data
                    count <= count+1'b1; end		//increase the count
                else R <= R;	end		
            default: state <= S0;
        endcase
    end
    
	//output conditions
    always@(R)				
    begin
        if(R[3:0] == 4'b1111 && count == 3'b001)
            R = 20'b0;				//don't allow a negative sign be the first value
        else if (R[3:0] == 4'b1111 && count == 3'b101)
            R = {4'b1111,R[19:4]};              //only allow a negative in the 5th digit
        else if(R[3:0] < 4'b1111 && count == 3'b101) 
            R = {4'b0,R[19:4]};
        else if (R[3:0]==4'b1111) begin	//conditions on where the negative sign is to display
            case(count)
                3'b010: R = {R[19:8],4'b1111,R[7:4]};
                3'b011: R = {R[19:12],4'b1111,R[11:4]};
                3'b100: R = {R[19:16],4'b1111,R[15:4]};
                3'b101: R = {4'b1111,R[19:4]};
            default: R = R;
        endcase
			if (count==1'b1) count=count;		//fix the count when a negative sign shifts in
			else count = count-1'b1; end
        else if (R[19:16] == 4'b1111)			//when 5th digit is negative display as follows
            begin count = 5; R = {4'b1111,R[15:0]}; end    
        else if(R[3:0] > 4'b1001) 
            begin
            R = {4'b0000,R[19:4]};	//blocking values 10 or greater from shifting in
            count = count-1'b1;		//blocking the count from increasing
            end
        else R = R;
    end
    
endmodule
