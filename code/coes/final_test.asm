#提示:dm的大小至少开到128*32位。pow并非幂运算,而是用二分法实现了一个乘法。正确结果:x10=0x80,x30=0x520,x31=0x1314.额其实主要是看x10.如果过程中不对的话,x10会是另外的值。

play:       #0~5
        addi    x28,x0,-1
        ori     x29,x0,2
        andi     x30,x28,1312
        sll     x31,x30,x29
        addi    x10,x0,1940
        xor    x31,x31,x10

selectTuT:  #6~1b
        jal    x10,w1
w1:
        jal    x11,w2
w2:     
        blt     x10,x11,w4
w3:
        jal     x0,pow32
w4:
        addi    x12,x0,20
        addi    x10,x0,20
        addi    x11,x0,24
        sw      x11,20(x0)
        sw      x10,24(x0)
        lw      x10,0(x10)
        lw      x10,0(x10)
        beq     x10,x12,w6
w5:
        jal     x0,pow81
w6:
        jal    x10,w7
w7:
        lw      x10,0(x10)
        addi     x10,x11,5
        jal     x10,w8
w8:
        jalr    x10,x10,0
        jalr    x10,x10,0
        jalr    x10,x10,0
        jalr    x10,x10,0
        jal     powTrue
pow125:     #1c~27
        addi    x10,x0,5
        addi    x11,x0,3
        jal    x6,start
pow81:
        addi    x10,x0,3
        addi    x11,x0,4
        jal    x6,start
powTrue:
        addi    x10,x0,32
        addi    x11,x0,4
        jal    x6,start
pow32:
        addi    x10,x0,2
        addi    x11,x0,5
        jal    x6,start
start:  #28~33
        jal     x1,powFake
        jal     x1,end
powFake:
        addi    x2,x2,-24
        sw      x1,20(x2)
        sw      x8,16(x2)
        addi    x8,x2,24
        sw      x10,-12(x8)
        sw      x11,-16(x8)
        lw      x15,-16(x8)
        bne     x15,x0,L2
        addi    x15,x0,0
        jal     x0,L3
L2:         #34~4e
        lw      x15,-16(x8)
        srli    x14,x15,31
        add     x15,x14,x15
        srai    x15,x15,1
        addi    x11,x15,0
        lw      x10,-12(x8)
        jal     x1,powFake
        addi      x15,x10,0
        sw      x15,-20(x8)
        lw      x15,-20(x8)
        add     x15,x15,x15
        sw      x15,-24(x8)
        lw      x15,-16(x8)
        andi    x15,x15,1
        beq     x15,x0,L4
        lw      x14,-24(x8)
        lw      x15,-12(x8)
        add     x15,x14,x15
        sw      x15,-24(x8)
L4:
        lw      x15,-24(x8)
L3:
        addi      x10,x15,0
        lw      x1,20(x2)
        lw      x8,16(x2)
        addi    x2,x2,24
        jalr    x0,x1,0
end:
        add    x5,x0,x10