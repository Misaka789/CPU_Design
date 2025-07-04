
# sw_i 10到14 为输入, 写入需要求因数个数的值, 和斐波那契的结果显示类似,数码管输出因数个数, sw_i 15为1 的时候输出随输入的变化是瞬时的
.globl _start
.text
_start:
# --- 1. Initialization (只执行一次) ---
    # lui x3, 0xFFFF0  (gp = 0xFFFF0000)
    lui     x3, 0xFFFF0


master_loop:
    # --- A. Read Input N from Switches ---
    # lw x8, 4(x3)  (s0 = mem[gp+4])
    lw      x8, 4(x3)
    srli x8 ,x8 ,10
    andi   x8 ,x8 , 0x1F

    # --- B. Re-initialize for a new calculation ---
    # li x18, 0  (s2 = 0) -> addi x18, x0, 0
    addi    x18, x0, 0
    # li x9, 1   (s1 = 1) -> addi x9, x0, 1
    addi    x9, x0, 1

    # --- C. Core Algorithm: Find Factor Count ---
    # If N (x8) is 0, skip calculation and display 0
    beq     x8, x0, display_result

calculation_loop:
    # Check if we are done (if i > N)
    # blt x8, x9, display_result (blt s0, s1, ...)
    blt     x8, x9, display_result

    # Prepare and call modulo subroutine
    # mv x10, x8 (a0 = s0) -> addi x10, x8, 0
    addi    x10, x8, 0
    # mv x11, x9 (a1 = s1) -> addi x11, x9, 0
    addi    x11, x9, 0
    # jal x1, modulo (jal ra, modulo)
    jal     x1, modulo
    # Remainder is now in x7 (t2)

    # Check if it's a factor
    # bne x7, x0, not_a_factor (bne t2, x0, ...)
    bne     x7, x0, not_a_factor
    # addi x18, x18, 1 (addi s2, s2, 1)
    addi    x18, x18, 1

not_a_factor:
    # addi x9, x9, 1 (addi s1, s1, 1)
    addi    x9, x9, 1
    # j calculation_loop -> jal x0, calculation_loop
    jal     x0, calculation_loop

    # --- D. Display the Result ---
display_result:
    # sw x18, 12(x3) (sw s2, 12(gp))
    sw      x18, 12(x3)

    # --- E. Loop back to start over ---
    # j master_loop -> jal x0, master_loop
    jal     x0, master_loop
    
# ===========================================================================
# 3. SUBROUTINE: modulo
# ===========================================================================
modulo:
    # mv x5, x10 (t0 = a0) -> addi x5, x10, 0
    addi    x5, x10, 0
    # mv x6, x11 (t1 = a1) -> addi x6, x11, 0
    addi    x6, x11, 0
    
mod_loop:
    # blt x5, x6, mod_end (blt t0, t1, ...)
    blt     x5, x6, mod_end
    # sub x5, x5, x6 (sub t0, t0, t1)
    sub     x5, x5, x6
    # j mod_loop -> jal x0, mod_loop
    jal     x0, mod_loop

mod_end:
    # mv x7, x5 (t2 = t0) -> addi x7, x5, 0
    addi    x7, x5, 0
    # ret -> jalr x0, x1, 0
    jalr    x0, x1, 0