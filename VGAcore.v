`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:        Adrian Sacks 
// Module Name:     VGAcore
// Description:     Outputs the proper vertical and horizontal synch 
//                  pulses, as well as when there is video, for the
//                  follow VGA signal timing specs:
//                  640 x 480 @ 60 Hz
//                  25 MHz Pixel Clock(*)
//                  
//                  For changing the timing parameters for different specs: 
//                  http://martin.hinner.info/vga/timing.html
//
//
//                  (*) : For a bare bones VGA driver, it's okay that 
//                        the Pixel Clock is not exactly 25.175 MHz.
// Revision 0.01 -  File Created

//////////////////////////////////////////////////////////////////////////////////


module VGAcore
    #(  // Horizonal timing 
        parameter hDisp  = 640,
        parameter hFp    = 16,
        parameter hPulse = 96,
        parameter hBp    = 48,
        
        // Vertical timing 
        parameter vDisp  = 480,
        parameter vFp    = 11,   
        parameter vPulse = 2,
        parameter vBp    = 31
    )
     (  input          pixClk,
        input          rst,
        output  [$clog2(hDisp+hFp+hPulse+hBp) - 1:0] horiz_counter,
        output  [$clog2(vDisp+vFp+vPulse+vBp) - 1:0] vert_counter,
        output  reg    video,
        output  reg    horiz_sync_pulse,
        output  reg    vert_sync_pulse
     );
     
     localparam hEND        = hDisp + hFp + hPulse + hBp; 
     localparam hSyncStart  = hDisp + hFp;
     localparam hSyncEnd    = hDisp + hFp + hPulse;
     
     localparam vEND        = vDisp + vFp + vPulse + vBp;
     localparam vSyncStart  = vDisp + vFp;
     localparam vSyncEnd    = vDisp + vFp + vPulse;
     
     reg [$clog2(hEND) - 1:0]  hc;
     reg [$clog2(vEND) - 1:0]  vc;
     
     always@(posedge pixClk or posedge rst)
        begin
            if(rst) begin
                hc <= 0;
                vc <= 0;
                horiz_sync_pulse <= 0;
                vert_sync_pulse <= 0;
                video <= 0;
            end
            else begin
               
                if(hc == hEND)
                    hc <= 0; 
                else hc <= hc + 1'b1;
                
                if((vc == vEND) && (hc == hEND))
                   vc <= 0; 
                else if(hc == hEND)
                    vc <= vc + 1'b1; 
                
                horiz_sync_pulse <= ~((hc >= hSyncStart) && (hc <= hSyncEnd));
                vert_sync_pulse  <= ~((vc >= vSyncStart) && (vc <= vSyncEnd));
                video            <=  ((hc < hDisp) && (vc < vDisp));
            end
        end 
        
     // Continuously assign temp registers to outputs of module    
     assign horiz_counter       = hc;
     assign vert_counter        = vc;
     
endmodule
