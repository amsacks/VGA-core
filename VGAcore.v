module VGAcore_v2
    #(  // System Frequency and Pixel Frequency
        parameter sys_F = 100_000_000,
        parameter pix_F = 25_000_000,

        // Horizonal timing 
        parameter hDisp  = 640,
        parameter hFp    = 16,
        parameter hPulse = 96,
        parameter hBp    = 48,
        parameter hEnd   = 800, 

        // Vertical timing 
        parameter vDisp  = 480,
        parameter vFp    = 11,   
        parameter vPulse = 2,
        parameter vBp    = 31,
        parameter vEnd   = 524
    )
    (
        input   clk,
        input   rst, 
        output  pix_tick,
        output  hsync,
        output  vsync,
        output  video,
        output  [$clog2(hEnd)-1:0] pix_x,
        output  [$clog2(vEnd)-1:0] pix_y 
    );

    localparam CLKS_PER_TICK = sys_F/pix_F; 
    
    reg  [$clog2(CLKS_PER_TICK) - 1:0] pixel_reg;
    reg  [$clog2(hEnd)          - 1:0] pix_x_reg, pix_x_nxt;
    reg  [$clog2(vEnd)          - 1:0] pix_y_reg, pix_y_nxt;
    reg                                hsync_reg;
    reg                                vsync_reg;
    
    wire [$clog2(CLKS_PER_TICK) - 1:0] pixel_nxt;  
    wire                               hsync_nxt;
    wire                               vsync_nxt; 
    
    always @(posedge clk or posedge rst)
        begin
            if(rst)
                begin
                    pixel_reg <= 0; 
                    pix_x_reg <= 0;
                    pix_y_reg <= 0; 
                    hsync_reg <= 0;
                    vsync_reg <= 0; 
                end
            else 
                begin
                    pixel_reg <= pixel_nxt; 
                    pix_x_reg <= pix_x_nxt;
                    pix_y_reg <= pix_y_nxt; 
                    hsync_reg <= hsync_nxt;
                    vsync_reg <= vsync_nxt; 
                end
             
        end 
    
    // Next-state Logic
    assign pixel_nxt = (pixel_reg == CLKS_PER_TICK - 1) ? 0 : pixel_reg + 1'b1;
    assign hsync_nxt = ( (pix_x_reg >= hDisp + hFp) &&
                            (pix_x_reg <= hDisp + hFp + hPulse + hBp - 1)) ? 0 : 1;
    assign vsync_nxt = ( (pix_y_reg >= vDisp + vFp) && 
                            (pix_y_reg <= vDisp + vFp + vPulse + vBp - 1)) ? 0 : 1; 
    
    always @(*)
        begin
            pix_x_nxt = pix_x_reg;
            pix_y_nxt = pix_y_reg; 
            if(pix_tick)
                if(pix_x_reg == hEnd - 1) pix_x_nxt = 0;
                else                      pix_x_nxt = pix_x_reg + 1'b1;
            if(pix_tick && (pix_x_reg == hEnd - 1))
                if(pix_y_reg == vEnd - 1) pix_y_nxt = 0;
                else                      pix_y_nxt = pix_y_reg + 1'b1;
        end 
    
    // Output Logic
    assign pix_tick = (pixel_reg == CLKS_PER_TICK - 1) ? 1 : 0; 
    assign video    = (pix_x_reg < hDisp && pix_y_reg < vDisp);
    assign hsync    = hsync_reg;
    assign vsync    = vsync_reg;
    assign pix_x    = pix_x_reg;
    assign pix_y    = pix_y_reg;
    
endmodule