.section .text.init
    .globl fir
fir:
    subw  t0, a3, a4
    addiw t0, t0, 1
    li    t1, 0
    addiw a5, a4, -1

outer_loop:
    bge   t1, t0, done_outer
    li    a6, 0
    li    t2, 0

inner_loop:
    bge   t2, a4, done_inner

    subw  t3, t1, t2
    addw  t3, t3, a5
    slli  t3, t3, 2
    add   t3, a0, t3
    lw    t4, 0(t3)

    slli  t5, t2, 2
    add   t5, a1, t5
    lw    t6, 0(t5)

    mul   t4, t4, t6
    slli  t4, t4, 1
    srli  t4, t4, 32

    addw  a6, a6, t4
    addiw t2, t2, 1
    j     inner_loop

done_inner:
    slli  t3, t1, 2
    add   t3, a2, t3
    sw    a6, 0(t3)
    addiw t1, t1, 1
    j     outer_loop

done_outer:
    ret
