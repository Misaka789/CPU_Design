

    ##########################################
# 初始化学号：0x31845726 (8位BCD)
##########################################
addi 	x2, x0, 0x31
slli 	x2, x2, 8
addi 	x2, x2, 0x84
slli 	x2, x2, 16
addi 	x3, x0, 0x57
slli 	x3, x3, 8
addi 	x3, x3, 0x26
add		x2, x2, x3				# x2 = 0x31845726
sw 		x2, 0(x0)               # mem[0] = stuno

##########################################
# 初始化参数与外循环
##########################################
addi    x11, x0, 8              # N = 8
lw      x15, 0(x0)              # x15 = stuno
addi    x2, x0, 0               # i = 0
addi    x4, x0, 0x0f            # mask0 = 0x0f

loop1:
    and     x7, x15, x4         # a = stuno & mask0
    slli    x9, x2, 2           # 4 * i
    srl     x7, x7, x9          # a >> (4 * i)
    slli    x5, x4, 4           # mask1 = mask0 << 4
    add     x12, x2, x0         # bestj = i
    add     x13, x7, x0         # tmpMax = a
    addi    x3, x2, 1           # j = i + 1

loop2:
    beq     x3, x11, checkswap
    and     x8, x15, x5
    slli    x10, x3, 2
    srl     x8, x8, x10
    slt     x14, x13, x8
    beq     x14, x0, incrLoop2
    add     x13, x8, x0         # tmpMax = b
    add     x12, x3, x0         # bestj = j

incrLoop2:
    slli    x5, x5, 4
    addi    x3, x3, 1
    jal     x0, loop2

checkswap:
    slt     x14, x2, x12
    beq     x14, x0, incrLoop1
    jal     x1, swap

incrLoop1:
    slli    x4, x4, 4
    addi    x2, x2, 1
    bne     x2, x11, loop1

##########################################
# 排序完成后写回
##########################################
result:
    sw      x15, 4(x0)          # mem[4] = sorted_stuno

##########################################
# 显示模块
##########################################
    addi    x2, x0, 0xff
    slli    x2, x2, 8
    addi    x2, x2, 0xff
    slli    x2, x2, 16          # x2 = 0xffff0000

    ori     x16, x2, 0x0004     # x16 = 0xffff0004 (switch input address)
    ori     x17, x2, 0x000c     # x17 = 0xffff000c (seg7 output address)

display:
    lw      x5, 0(x16)          # load switch value
    andi    x5, x5, 0x100
    beq     x5, x0, dispstuno

dispsortedstuno:
    lw      x3, 4(x0)           # load sorted_stuno
    jal     x0, displayseg7label

dispstuno:
    lw      x3, 0(x0)           # load original stuno

displayseg7label:
    sw      x3, 0(x17)          # output to seg7
    jal     x0, display

##########################################
# swap 函数：x1作为return地址
##########################################
swap:
    addi    x5, x0, 0x0f
    slli    x10, x12, 2         # 4 * bestj
    sll     x5, x5, x10         # mask1 = 0x0f << (4 * bestj)
    or      x6, x4, x5          # mask2 = mask0 | mask1
    xori    x6, x6, -1          # mask2 = ~mask2
    and     x15, x15, x6        # clear a and tmpMax positions
    sll     x8, x13, x9         # tmpMax << (4*i)
    or      x15, x15, x8
    sll     x7, x7, x10         # a << (4*bestj)
    or      x15, x15, x7
    jalr    x0, x1, 0



// 以下为可以在venus上面运行的代码

    ##########################################
# 初始化学号：0x31845726 (8位BCD)
##########################################
addi    x29, x0 , 0x1F8
addi 	x2, x0, 0x31
slli 	x2, x2, 8
addi 	x2, x2, 0x84
slli 	x2, x2, 16
addi 	x3, x0, 0x57
slli 	x3, x3, 8
addi 	x3, x3, 0x26
add		x2, x2, x3				# x2 = 0x31845726
sw 		x2, 0(x29)               # mem[0] = stuno

##########################################
# 初始化参数与外循环
##########################################
addi    x11, x0, 8              # N = 8
lw      x15, 0(x29)              # x15 = stuno
addi    x2, x0, 0               # i = 0
addi    x4, x0, 0x0f            # mask0 = 0x0f

loop1:
    and     x7, x15, x4         # a = stuno & mask0
    slli    x9, x2, 2           # 4 * i
    srl     x7, x7, x9          # a >> (4 * i)
    slli    x5, x4, 4           # mask1 = mask0 << 4
    add     x12, x2, x0         # bestj = i
    add     x13, x7, x0         # tmpMax = a
    addi    x3, x2, 1           # j = i + 1

loop2:
    beq     x3, x11, checkswap
    and     x8, x15, x5
    slli    x10, x3, 2
    srl     x8, x8, x10
    slt     x14, x13, x8
    beq     x14, x0, incrLoop2
    add     x13, x8, x0         # tmpMax = b
    add     x12, x3, x0         # bestj = j

incrLoop2:
    slli    x5, x5, 4
    addi    x3, x3, 1
    jal     x0, loop2

checkswap:
    slt     x14, x2, x12
    beq     x14, x0, incrLoop1
    jal     x1, swap

incrLoop1:
    slli    x4, x4, 4
    addi    x2, x2, 1
    bne     x2, x11, loop1

##########################################
# 排序完成后写回
##########################################
result:
    sw      x15, 4(x29)          # mem[4] = sorted_stuno

##########################################
# 显示模块
##########################################
    addi    x2, x0, 0xff
    slli    x2, x2, 8
    addi    x2, x2, 0xff
    slli    x2, x2, 16          # x2 = 0xffff0000

    ori     x16, x2, 0x0004     # x16 = 0xffff0004 (switch input address)
    ori     x17, x2, 0x000c     # x17 = 0xffff000c (seg7 output address)

display:
    lw      x5, 0(x16)          # load switch value
    andi    x5, x5, 0x100
    beq     x5, x0, dispstuno

dispsortedstuno:
    lw      x3, 4(x29)           # load sorted_stuno
    jal     x0, displayseg7label

dispstuno:
    lw      x3, 0(x29)           # load original stuno

displayseg7label:
    sw      x3, 0(x17)          # output to seg7
    jal     x0, display

##########################################
# swap 函数：x1作为return地址
##########################################
swap:
    addi    x5, x0, 0x0f
    slli    x10, x12, 2         # 4 * bestj
    sll     x5, x5, x10         # mask1 = 0x0f << (4 * bestj)
    or      x6, x4, x5          # mask2 = mask0 | mask1
    xori    x6, x6, -1          # mask2 = ~mask2
    and     x15, x15, x6        # clear a and tmpMax positions
    sll     x8, x13, x9         # tmpMax << (4*i)
    or      x15, x15, x8
    sll     x7, x7, x10         # a << (4*bestj)
    or      x15, x15, x7
    jalr    x0, x1, 0
