
// data memory
module dm(clk, DMWr, addr, din, dout,DMType);
   input          clk;
   input          DMWr;
   input  [31:0]   addr;
   input  [31:0]  din;
   input  [2:0]   DMType;
   output reg [31:0]  dout;
     
   reg [31:0]  dmem[127:0];
   wire [6:0] word_addr = addr[8:2];    //  字地址
   wire [1:0] byte_offset = addr[1:0];
   wire [3:0]  bwe;           // 4位的字节写使能
   wire [31:0] data_to_write; // 对齐后的待写入数据

   assign bwe = 
    // 只有当DMWr为高时，才可能产生有效的bwe
    (DMWr == 1'b0) ? 4'b0000 :
    // 根据数据类型生成掩码
    (DMType == `dm_word)     ? 4'b1111 :
    (DMType == `dm_halfword) ? (byte_offset == 2'b00 ? 4'b0011 : 4'b1100) : // 只处理对齐的sh
    (DMType == `dm_byte)     ? (4'b0001 << byte_offset) :
                              4'b0000; // 其他类型(如load)不写入

// 2. 对齐写入数据 (组合逻辑)
// 一个健壮的技巧是复制字节/半字，然后让BWE来选择
/* assign data_to_write = 
    (DMType == `dm_byte)     ? {4{din[7:0]}} :      // {d,d,d,d}
    (DMType == `dm_halfword) ? {2{din[15:0]}} :   // {d,d}
                              din;                 // 默认是整个字 */

// 让debug_dmem_data的值等于当前地址所指向的dmem单元的值

// --- 时序写入逻辑 (增加了$display) ---
always @(posedge clk) begin
    // 只在DMWr为高电平时执行
    if (DMWr) begin
        // 使用一个case语句来控制打印，让信息更清晰
        case (DMType)
            `dm_word: begin
                dmem[word_addr] <= din;
                // 打印信息：时间，操作类型，字节地址，写入的32位值
                $display("@%0t: [DM Write] SW to Addr 0x%h, Data: 0x%h", $time, addr, din);
            end

            `dm_halfword: begin
                // 根据地址偏移量选择写入高半字还是低半字
                case (byte_offset)
                    2'b00: dmem[word_addr][15:0] <= din[15:0];
                    2'b10: dmem[word_addr][31:16] <= din[15:0];
                    default:; // 非对齐的sh不操作
                endcase
                // 打印信息：时间，操作类型，字节地址，写入的16位值
                $display("@%0t: [DM Write] SH to Addr 0x%h, Data: 0x%h", $time, addr, din[15:0]);
            end

            `dm_byte: begin
                // 根据字节偏移量选择写入哪个字节
                case (byte_offset)
                    2'b00: dmem[word_addr][7:0]   <= din[7:0];
                    2'b01: dmem[word_addr][15:8]  <= din[7:0];
                    2'b10: dmem[word_addr][23:16] <= din[7:0];
                    2'b11: dmem[word_addr][31:24] <= din[7:0];
                endcase
                // 打印信息：时间，操作类型，字节地址，写入的8位值
                $display("@%0t: [DM Write] SB to Addr 0x%h, Data: 0x%h", $time, addr, din[7:0]);
            end
            
            default: begin
                // 如果需要，也可以为无效操作打印信息
                 $display("@%0t: [DM Write] Invalid DMType, no write.", $time);
            end
        endcase
        
        // --- 如何看到写入后的值 (方法二) ---
        // 注意：这会产生大量的日志信息
        // 使用 $strobe 而不是 $display，它会在当前时间步的所有事件都完成后才执行
        // 所以它能看到 dmem 被非阻塞赋值更新后的值。
      //  $strobe("@%0t: [DM Check] After Write, dmem[0x%h] is now: 0x%h", $time, word_addr, dmem[word_addr]);

    end
end

      // 从内存中读取的逻辑
      wire [31:0] raw_word_from_mem = dmem[word_addr];
            reg [31:0] shifted_data;
   always@ * begin 
      case (byte_offset)  // 将数据右移到最低位 方便进行扩展
            2'b00: shifted_data = raw_word_from_mem;
            2'b01: shifted_data = raw_word_from_mem >> 8;
            2'b10: shifted_data = raw_word_from_mem >> 16;
            2'b11: shifted_data = raw_word_from_mem >> 24;
      endcase
case (DMType)
            // -- 加载字 --
            `dm_word: 
                dout = raw_word_from_mem; // 对于lw，直接使用原始的、未移位的32位字

            // -- 加载半字 --
            `dm_halfword: // lh
                // 取出低16位，并进行符号位扩展
                dout = {{16{shifted_data[15]}}, shifted_data[15:0]}; 
            `dm_halfword_unsigned: // lhu
                // 取出低16位，并进行零扩展
                dout = {16'b0, shifted_data[15:0]};

            // -- 加载字节 --
            `dm_byte: // lb
                // 取出低8位，并进行符号位扩展
                dout = {{24{shifted_data[7]}}, shifted_data[7:0]};
            `dm_byte_unsigned: // lbu
                // 取出低8位，并进行零扩展
                dout = {24'b0, shifted_data[7:0]};

            // 对于所有存储指令(sw, sh, sb)或其他无效类型，输出是无关的
            default: 
                dout = 32'hxxxxxxxx; 
        endcase

   end

 
endmodule    
         /* `dm_halfword_unsigned : begin 
            dmem[word_addr][15:0] <= $unsigned (din[15:0]);
         end
         `dm_byte_unsigned : begin 
            dmem[word_addr][7:0] <= $unsigned (din[7:0]);
         end */

/* 
            wire [4:0] byte_block = low_addr + 7;
   wire [4:0]halfword_block = low_addr + 15;
   always @(posedge clk)
      if (DMWr) begin
         //dmem[addr[8:2]] <= din;
         case (DMType) 
         `dm_byte : begin 
            dmem[word_addr][byte_block:low_addr] <= din[7:0];
            $display("dmem[0x%8X] = 0x%8X, ", word_addr << 2, din[7:0]); 
            $display("finished :dmem[0x%8x] = 0x%8x",word_addr << 2 , dmem[word_addr]);
         end
         `dm_word : begin
            dmem[word_addr] <= din;
            $display("dmem[0x%8X] = 0x%8X, ", word_addr << 2, din); 
            $display("finished :dmem[0x%8x] = 0x%8x",word_addr << 2 , dmem[word_addr]);
         end
         `dm_halfword : begin 
            dmem[word_addr][halfword_block:low_addr] <= din[15:0];
            $display("dmem[0x%8X] = 0x%8X, ", word_addr << 2, din[15:0]); 
            $display("finished :dmem[0x%8x] = 0x%8x",word_addr << 2 , dmem[word_addr]);
         end

         default : begin  
            dmem[word_addr] <= 32'hdeadbeef;
         end
         endcase
       // $display("dmem[0x%8X] = 0x%8X,", addr << 2, din); 
      end
    */


    


  // assign dout = dmem[addr[8:2]];
/*    assign dout = (DMType == `dm_byte) ? dmem[word_addr][7:0] :
                  (DMType == `dm_halfword) ? dmem[word_addr][15:0] :
                  (DMType ==  `dm_word) ? dmem[word_addr] : 
                  (DMType == `dm_halfword_unsigned ) ? $unsigned (dmem[word_addr][15:0]) :
                  (DMType == `dm_byte_unsigned) ? $unsigned (dmem[word_addr][7:0]) :
                  32'hdeadbeaf;

 
    */