`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:        Adrian Sacks
// Create Date:     05/25/2022 07:08:47 AM
// Module Name:     VGAcore_tb
// Project Name:    CoinCollector
// Description:     This module tests whether the vertical and horiontal
//                  synch pulses are outputing at the expected hc and vc count. 
// Revision 0.01 -  File Created
//////////////////////////////////////////////////////////////////////////////////

module VGAcore_tb();

reg         clk_tb;
reg         rstn_tb;
wire [10:0] hc_tb;
wire [9:0]  vc_tb;
wire        video_tb;
wire        h_pulse_tb;
wire        v_pulse_tb;
    
VGAcore 
    #(  .hDisp(640),
        .hFp(16),
        .hPulse(96),
        .hBp(48),

        .vDisp(480),
        .vFp(10),   
        .vPulse(2),
        .vBp(33)
    )

Test
    (
        .pixClk(clk_tb),
        .rstn(rstn_tb),
        .horiz_counter(hc_tb),
        .vert_counter(vc_tb),
        .video(video_tb),
        .horiz_sync_pulse(h_pulse_tb),
        .vert_sync_pulse(v_pulse_tb)
    );

// Issue quick reset.
initial
    begin
        clk_tb = 0;
        rstn_tb = 1;
        #2
        rstn_tb = 0; 
        #20
        rstn_tb = 1;
    end

always 
    begin
        #20
        clk_tb = ~clk_tb;
    end
    
initial
    begin
        repeat(1000) @(posedge clk_tb);  
        $finish;
    end
       
endmodule