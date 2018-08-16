//This is the dataflow code for a code converter that drives an active low seven-segment display

module code_converter2 (A,B,C,D,X1,X2,X3,X4,X5,X6,X7);
	input A,B,C,D;
	output X1,X2,X3,X4,X5,X6,X7;
	wire Z1;
	
	assign Z1 = (A&B)|(A&C),
			X1 = (B&~C&~D)|(~A&~B&~C&D)|Z1,
			X2 = (B&~C&D)|(B&C&~D)|Z1,
			X3 = (~B&C&~D)|Z1,
			X4 = (B&~C&~D)|(A&B&C&D)|(B&C&D)|Z1,
			X5 = (B&~C&~D)|D|Z1,
			X6 = (~A&~B&D)|(C&D)|(~B&C&~D)|Z1,
			X7 = (~A&~B&~C)|(B&C&D)|Z1;
			
endmodule