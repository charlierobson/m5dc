`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:		6/2013
// Design Name:
// Module Name:
// Project Name: 
// Target Devices:	XC9572XL 
// Tool versions:
// Description:
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Main(
	// host side
	input [7:0] HostAddressBus,
	inout [7:0] HostDataBus,
	input nReset,					// System reset
//	input nIORQ,
//	input nM1,
	input nIN,
	input nOUT,

	// client side
	inout [7:0] ClientDataBus,
	input ClientReadLine,		// client read strobe
	input ClientWriteLine,		// client write strobe
	input ClientStatusLine		// client status strobe
);


	// Host and client data registers.
	reg [7:0] Buffer;				// Data going from Host <-> client

	// Handshake bits
	reg HostBufferFull;			// Set by Host write, cleared by client read.
	reg ClientBufferFull; 		// Set by client write, cleared by Host read.
	reg CommandBit;				// bit 0 of host address bus when host writes. 0 = command, 1 = data
	reg [3:0] Top4;				// top 4 bits of status - may be used for anything but initially i'm thinking verifying CPLD program
	
	// Assignments here default to wire type

	// Z80 IO requests on port $70-$77 inclusive
	//
	// $70 is host write + data    3'b000
	// $71 is host write + command 3'b001
	// $72 is host read data		 3'b010
	// $74 is host read status		 3'b100
	//

	assign HostWriteCommand	= !nOUT & HostAddressBus[7:0] == 8'b11xxx000;
	assign HostWriteData		= !nOUT & HostAddressBus[7:0] == 8'b11xxx001;
	assign HostWrite			= HostWriteCommand | HostWriteData;
	
	assign HostRead			= !nIN & HostAddressBus[7:0] == 8'b11xxx010;
	assign HostStatusRead	= !nIN & HostAddressBus[7:0] == 8'b11xxx100;
	
	assign HostDetect			= !nIN & HostAddressBus[7:0] == 8'b11xxx110;
	assign HostVersion		= !nIN & HostAddressBus[7:0] == 8'b11xxx111;

	assign ClientWrite		 = ClientWriteLine & !ClientStatusLine;
	assign ClientRead			 = ClientReadLine  & !ClientStatusLine;
	assign ClientStatusRead	 = ClientStatusLine & ClientReadLine;
	assign ClientStatusWrite = ClientStatusLine & ClientWriteLine;

	// Host & client selection logic is POSITIVE, active high

	localparam VERSION = 8'b10; // 1.0

	// Latch read or write
	assign ClientDataBus = ClientRead ? Buffer : (ClientStatusRead ? {HostDriveID,3'b0,CommandBit,ClientBufferFull,HostBufferFull} : 8'bz);
	assign HostDataBus   = HostRead   ? Buffer : (HostStatusRead   ? {Top4,       1'b0,CommandBit,ClientBufferFull,HostBufferFull} : (HostDetect ? 8'd42 : (HostVersion ? VERSION : 8'bz)));

	// Latch the databus when the host writes
	// Make a note of which port (cmd [0]/ or data [1]) was written to
	// clear various bits on status write. CAREFUL! a race condition exists here.
	//	Client and host conditions shouldn't be checked in the same always block as they can be written simultaneously.
	// it should be OK though as the client status writes should only happen when the host is reading. this needs
	// to be assured in client code.
	always @(negedge nReset or posedge ClientStatusWrite or posedge HostWriteCommand)
	begin
		if (!nReset) begin
			CommandBit <= 1'b0;
		end else if (ClientStatusWrite) begin
			CommandBit <= 0;
			Top4 <= ClientDataBus[7:4];
		end else begin
			CommandBit <= 1;
		end
	end

	// Latch the databus when the client writes
	always @(posedge ClientWrite or posedge HostWrite)
	begin
		if (HostWrite) begin
			Buffer <= HostDataBus;
		end else begin
			Buffer <= ClientDataBus;
		end
	end

	// HostBufferFull
	// Set by a write from the host, cleared by a read by the client or nReset.
	always @(negedge nReset or posedge ClientRead or negedge HostWrite)
	begin
		if(!nReset)
			HostBufferFull <= 1'b0;
		else if(ClientRead)
			HostBufferFull <= 1'b0;
		else
			// set when the host write completes, to ensure that data is present
			// for the client to read
			HostBufferFull <= 1'b1;
	end

	// ClientBufferFull
	//	Set by a write from the client, cleared by a read by the host or nReset.
	always @(negedge nReset or posedge ClientWrite or negedge HostRead)
	begin
		if(!nReset)
			ClientBufferFull <= 1'b0;
		else if(ClientWrite)
			// set when the client writes. host doesn't check this and the einsdein core
			// is single threaded so we can use the pos edge safely
			ClientBufferFull <= 1'b1;
		else
			// cleared when host has completed its read,
			// otherwise einsdein could stuff multiple bytes in the time
			// the host system has HostRead asserted
			ClientBufferFull <= 1'b0;
	end

endmodule
