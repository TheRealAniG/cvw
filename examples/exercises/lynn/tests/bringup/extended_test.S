// Extended RV32I Test Suite
// Logic: Each block verifies a specific instruction extension.
// If a test fails, the error code is loaded into 'gp' (x3).

.extern return_extended_test
.extern fail

    .section .text.init
    .globl extended_test
    .type  extended_test, @function

extended_test:

# =============================================================================
# 1. BRANCHING (BNE, BLT, BLTU, BGE, BGEU)
# =============================================================================
check_bne:
    # --- These SHOULD branch to test_blt ---
    li  t0, 1; li t1, 2; bne t0, t1, 1f; li gp, 501; j fail
    1: li t0, -1; li t1, 1; bne t0, t1, 1f; li gp, 502; j fail
    1: li t0, 0; li t1, 5; bne t0, t1, 1f; li gp, 503; j fail
    1: li t0, 0x7F; li t1, 0x80; bne t0, t1, 1f; li gp, 504; j fail
    1: li t0, 0xAA; li t1, 0x55; bne t0, t1, 1f; li gp, 505; j fail
    1:

    # --- These SHOULD NOT branch (if they do, they hit bne_err) ---
    li  t0, 100; li t1, 100; bne t0, t1, bne_err
    li  t0, 0; li t1, 0; bne t0, t1, bne_err
    li  t0, -50; li t1, -50; bne t0, t1, bne_err
    li  t0, 0x7F; li t1, 0x7F; bne t0, t1, bne_err
    li  t0, 0x80; li t1, 0x80; bne t0, t1, bne_err

    # Final jump to the next instruction group
    j test_blt

bne_err:
    li  gp, 506
    j   fail

test_blt:
    # --- These SHOULD branch to 1f ---
    li  t0, -2; li t1, -1; blt t0, t1, 1f; li gp, 511; j fail
    1: li t0, -10; li t1, 0; blt t0, t1, 1f; li gp, 512; j fail
    1: li t0, -100; li t1, 100; blt t0, t1, 1f; li gp, 513; j fail
    1: li t0, 0x80000000; li t1, 0x7FFFFFFF; blt t0, t1, 1f; li gp, 514; j fail
    1: li t0, 0; li t1, 1; blt t0, t1, 1f; li gp, 515; j fail
    1:

    # --- These SHOULD NOT branch (if they do, they hit blt_err) ---
    li  t0, 5; li t1, 5; blt t0, t1, blt_err
    li  t0, 10; li t1, 5; blt t0, t1, blt_err
    li  t0, 0; li t1, -1; blt t0, t1, blt_err
    li  t0, 1; li t1, 1; blt t0, t1, blt_err
    li  t0, 0x7FFFFFFF; li t1, 0x80000000; blt t0, t1, blt_err

    # Final jump to the next instruction group
    j test_bltu

blt_err:
    li  gp, 516
    j   fail

test_bltu:
    # --- These SHOULD branch to 1f ---
    li  t0, 1; li t1, -1; bltu t0, t1, 1f; li gp, 521; j fail
    1: li t0, 0; li t1, 1; bltu t0, t1, 1f; li gp, 522; j fail
    1: li t0, 0x7FFFFFFF; li t1, 0x80000000; bltu t0, t1, 1f; li gp, 523; j fail
    1: li t0, 0x0000FFFF; li t1, 0xFFFF0000; bltu t0, t1, 1f; li gp, 524; j fail
    1: li t0, 0xFFFFFFFE; li t1, 0xFFFFFFFF; bltu t0, t1, 1f; li gp, 525; j fail
    1:

    # --- These SHOULD NOT branch (if they do, they hit bltu_err) ---
    li  t0, -1; li t1, 1; bltu t0, t1, bltu_err    # 0xFFFFFFFF is NOT < 1
    li  t0, 10; li t1, 10; bltu t0, t1, bltu_err
    li  t0, 0; li t1, 0; bltu t0, t1, bltu_err
    li  t0, 0x80000000; li t1, 0x7FFFFFFF; bltu t0, t1, bltu_err
    li  t0, -1; li t1, -1; bltu t0, t1, bltu_err

    # Final jump to the next instruction group
    j test_bge

bltu_err:
    li  gp, 526
    j   fail

test_bge:
    # --- These SHOULD branch to 1f ---
    li  t0, 5; li t1, 5; bge t0, t1, 1f; li gp, 531; j fail
    1: li t0, 10; li t1, 5; bge t0, t1, 1f; li gp, 532; j fail
    1: li t0, 0; li t1, -1; bge t0, t1, 1f; li gp, 533; j fail
    1: li t0, -1; li t1, -1; bge t0, t1, 1f; li gp, 534; j fail
    1: li t0, 0x7FFFFFFF; li t1, 0x80000000; bge t0, t1, 1f; li gp, 535; j fail
    1:

    # --- These SHOULD NOT branch (if they do, they hit bge_err) ---
    li  t0, 4; li t1, 5; bge t0, t1, bge_err
    li  t0, -2; li t1, -1; bge t0, t1, bge_err
    li  t0, -100; li t1, 100; bge t0, t1, bge_err
    li  t0, 0x80000000; li t1, 0x7FFFFFFF; bge t0, t1, bge_err
    li  t0, 0; li t1, 1; bge t0, t1, bge_err

    # Final jump to the next instruction group
    j test_bgeu

bge_err:
    li  gp, 536
    j   fail

test_bgeu:
    # --- These SHOULD branch to 1f ---
    li  t0, -1; li t1, 0; bgeu t0, t1, 1f; li gp, 541; j fail
    1: li t0, 5; li t1, 5; bgeu t0, t1, 1f; li gp, 542; j fail
    1: li t0, -1; li t1, -1; bgeu t0, t1, 1f; li gp, 543; j fail
    1: li t0, 0x80000000; li t1, 0x7FFFFFFF; bgeu t0, t1, 1f; li gp, 544; j fail
    1: li t0, 100; li t1, 50; bgeu t0, t1, 1f; li gp, 545; j fail
    1:

    # --- These SHOULD NOT branch (if they do, they hit bgeu_err) ---
    li  t0, 0; li t1, 1; bgeu t0, t1, bgeu_err
    li  t0, 0x7FFFFFFF; li t1, 0x80000000; bgeu t0, t1, bgeu_err
    li  t0, 1; li t1, -1; bgeu t0, t1, bgeu_err
    li  t0, 0xFFFFFFFE; li t1, 0xFFFFFFFF; bgeu t0, t1, bgeu_err
    li  t0, 0; li t1, 0xFFFFFFFF; bgeu t0, t1, bgeu_err

    # Final jump to the next instruction group
    j check_shifts

bgeu_err:
    li  gp, 546
    j   fail

# =============================================================================
# 2. SHIFTS (SLL, SLLI, SRL, SRLI, SRA, SRAI)
# =============================================================================
check_shifts:
    # --- SLLI: Shift Left Logical Immediate (10 Tests) ---
    li t0, 0x1; slli t1, t0, 4; li t2, 0x10
    beq t1, t2, 1f; li gp, 601; j fail
    1: li t0, 0x1; slli t1, t0, 1; li t2, 0x2
    beq t1, t2, 1f; li gp, 602; j fail
    1: li t0, 0xABC; slli t1, t0, 0; li t2, 0xABC
    beq t1, t2, 1f; li gp, 603; j fail
    1: li t0, 0xFF; slli t1, t0, 8; li t2, 0xFF00
    beq t1, t2, 1f; li gp, 604; j fail
    1: li t0, 0x1; slli t1, t0, 31; li t2, 0x80000000
    beq t1, t2, 1f; li gp, 605; j fail
    1: li t0, 0xF0000000; slli t1, t0, 4; li t2, 0x0
    beq t1, t2, 1f; li gp, 606; j fail
    1: li t0, 0x800; slli t1, t0, 4; li t2, 0x8000
    beq t1, t2, 1f; li gp, 607; j fail
    1: li t0, 0x5; slli t1, t0, 2; li t2, 0x14
    beq t1, t2, 1f; li gp, 608; j fail
    1: li t0, 0xFFFFFFFF; slli t1, t0, 1; li t2, 0xFFFFFFFE
    beq t1, t2, 1f; li gp, 609; j fail
    1: li t0, 0x80000000; slli t1, t0, 1; li t2, 0x0
    beq t1, t2, 1f; li gp, 610; j fail
    1:

    j test_srli

test_srli:
    # --- SRLI: Shift Right Logical Immediate (10 Tests) ---
    li t0, 0x80000000; srli t1, t0, 1; li t2, 0x40000000
    beq t1, t2, 1f; li gp, 611; j fail
    1: li t0, 0x1; srli t1, t0, 1; li t2, 0x0
    beq t1, t2, 1f; li gp, 612; j fail
    1: li t0, 0xFFFFFFFF; srli t1, t0, 4; li t2, 0x0FFFFFFF
    beq t1, t2, 1f; li gp, 613; j fail
    1: li t0, 0xABC; srli t1, t0, 0; li t2, 0xABC
    beq t1, t2, 1f; li gp, 614; j fail
    1: li t0, 0x1; srli t1, t0, 31; li t2, 0x0
    beq t1, t2, 1f; li gp, 615; j fail
    1: li t0, 0x80000000; srli t1, t0, 31; li t2, 0x1
    beq t1, t2, 1f; li gp, 616; j fail
    1: li t0, 0xF0F0F0F0; srli t1, t0, 4; li t2, 0x0F0F0F0F
    beq t1, t2, 1f; li gp, 617; j fail
    1: li t0, 0x5; srli t1, t0, 2; li t2, 0x1
    beq t1, t2, 1f; li gp, 618; j fail
    1: li t0, 0x400; srli t1, t0, 10; li t2, 0x1
    beq t1, t2, 1f; li gp, 619; j fail
    1: li t0, 0xFF; srli t1, t0, 8; li t2, 0x0
    beq t1, t2, 1f; li gp, 620; j fail
    1:

    j test_srai

test_srai:
    # --- SRAI: Shift Right Arithmetic Immediate (10 Tests) ---
    li t0, 0x80000000; srai t1, t0, 1; li t2, 0xC0000000
    beq t1, t2, 1f; li gp, 621; j fail
    1: li t0, 0x80000000; srai t1, t0, 31; li t2, 0xFFFFFFFF
    beq t1, t2, 1f; li gp, 622; j fail
    1: li t0, 0x7FFFFFFF; srai t1, t0, 1; li t2, 0x3FFFFFFF
    beq t1, t2, 1f; li gp, 623; j fail
    1: li t0, 0xFFFFFFFF; srai t1, t0, 16; li t2, 0xFFFFFFFF
    beq t1, t2, 1f; li gp, 624; j fail
    1: li t0, 0x00000001; srai t1, t0, 1; li t2, 0x0
    beq t1, t2, 1f; li gp, 625; j fail
    1: li t0, 0xAAAAAAA0; srai t1, t0, 4; li t2, 0xFAAAAAAA
    beq t1, t2, 1f; li gp, 626; j fail
    1: li t0, 0x55555550; srai t1, t0, 4; li t2, 0x05555555
    beq t1, t2, 1f; li gp, 627; j fail
    1: li t0, -2; srai t1, t0, 1; li t2, -1
    beq t1, t2, 1f; li gp, 628; j fail
    1: li t0, 0; srai t1, t0, 5; li t2, 0
    beq t1, t2, 1f; li gp, 629; j fail
    1: li t0, 0x40000000; srai t1, t0, 31; li t2, 0x0
    beq t1, t2, 1f; li gp, 630; j fail
    1:

# --- SLL/SRL/SRA: Register-Register Shifts ---
    li t0, 0x1; li t1, 4; sll t2, t0, t1; li t3, 0x10
    beq t2, t3, 1f; li gp, 651; j fail
    1:
    li t0, 0x80; li t1, 2; srl t2, t0, t1; li t3, 0x20
    beq t2, t3, 1f; li gp, 652; j fail
    1:
    li t0, 0xFFFFFFF0; li t1, 4; sra t2, t0, t1; li t3, 0xFFFFFFFF
    beq t2, t3, 1f; li gp, 653; j fail
    1:

    j check_slt

# =============================================================================
# 3. SET LESS THAN (SLTU, SLTIU)
# =============================================================================
check_slt:
    # --- SLTU: Set Less Than Unsigned (10 Tests) ---
    li t0, -1; li t1, 1; sltu t2, t0, t1; li t3, 0
    beq t2, t3, 1f; li gp, 701; j fail
    1: li t0, 1; li t1, -1; sltu t2, t0, t1; li t3, 1
    beq t2, t3, 1f; li gp, 702; j fail
    1: li t0, 0; li t1, 1; sltu t2, t0, t1; li t3, 1
    beq t2, t3, 1f; li gp, 703; j fail
    1: li t0, 1; li t1, 0; sltu t2, t0, t1; li t3, 0
    beq t2, t3, 1f; li gp, 704; j fail
    1: li t0, 5; li t1, 5; sltu t2, t0, t1; li t3, 0
    beq t2, t3, 1f; li gp, 705; j fail
    1: li t0, 0x7FFFFFFF; li t1, 0x80000000; sltu t2, t0, t1; li t3, 1
    beq t2, t3, 1f; li gp, 706; j fail
    1: li t0, 0xFFFFFFFE; li t1, 0xFFFFFFFF; sltu t2, t0, t1; li t3, 1
    beq t2, t3, 1f; li gp, 707; j fail
    1: li t0, 0; li t1, 0; sltu t2, t0, t1; li t3, 0
    beq t2, t3, 1f; li gp, 708; j fail
    1: li t0, 0x80000000; li t1, 0; sltu t2, t0, t1; li t3, 0
    beq t2, t3, 1f; li gp, 709; j fail
    1: li t0, 0xAAAAAAA; li t1, 0xBBBBBBB; sltu t2, t0, t1; li t3, 1
    beq t2, t3, 1f; li gp, 710; j fail
    1:

    j test_sltiu

test_sltiu:
    # --- SLTIU: Set Less Than Immediate Unsigned (10 Tests) ---
    li t0, 5; sltiu t1, t0, 10; li t2, 1
    beq t1, t2, 1f; li gp, 711; j fail
    1: li t0, 10; sltiu t1, t0, 5; li t2, 0
    beq t1, t2, 1f; li gp, 712; j fail
    1: li t0, 0; sltiu t1, t0, 1; li t2, 1
    beq t1, t2, 1f; li gp, 713; j fail
    1: li t0, 1; sltiu t1, t0, 0; li t2, 0
    beq t1, t2, 1f; li gp, 714; j fail
    1: li t0, 100; sltiu t1, t0, 100; li t2, 0
    beq t1, t2, 1f; li gp, 715; j fail
    1: li t0, -1; sltiu t1, t0, 2047; li t2, 0 # MaxU is not < 2047
    beq t1, t2, 1f; li gp, 716; j fail
    1: li t0, 0; sltiu t1, t0, -1; li t2, 1 # 0 is < MaxU
    beq t1, t2, 1f; li gp, 717; j fail
    1: li t0, 0x7FFFFFFF; sltiu t1, t0, 0x400; li t2, 0
    beq t1, t2, 1f; li gp, 718; j fail
    1: li t0, 2046; sltiu t1, t0, 2047; li t2, 1
    beq t1, t2, 1f; li gp, 719; j fail
    1: li t0, 0x80000000; sltiu t1, t0, 1; li t2, 0
    beq t1, t2, 1f; li gp, 720; j fail
    1:

# --- SLT: Set Less Than (Signed Register-Register) ---
    li t0, -1; li t1, 1; slt t2, t0, t1; li t3, 1
    beq t2, t3, 1f; li gp, 751; j fail
    1:
    li t0, 1; li t1, -1; slt t2, t0, t1; li t3, 0
    beq t2, t3, 1f; li gp, 752; j fail
    1:
    li t0, 0x7FFFFFFF; li t1, 0x80000000; slt t2, t0, t1; li t3, 0
    beq t2, t3, 1f; li gp, 753; j fail
    1:

    j check_mem
# =============================================================================
# 4. MEMORY (LB, LBU, LH, LHU, SB, SH)
# =============================================================================
check_mem:
    la  t0, test_data

    # --- SB/LB: Store/Load Byte (10 Tests) ---
    li t1, 0xFE; sb t1, 0(t0); lb t2, 0(t0); li t3, 0xFFFFFFFE
    beq t2, t3, 1f; li gp, 801; j fail
    1: li t1, 0x7F; sb t1, 1(t0); lb t2, 1(t0); li t3, 0x0000007F
    beq t2, t3, 1f; li gp, 802; j fail
    1: li t1, 0x80; sb t1, 2(t0); lb t2, 2(t0); li t3, 0xFFFFFF80
    beq t2, t3, 1f; li gp, 803; j fail
    1: li t1, 0x00; sb t1, 3(t0); lb t2, 3(t0); li t3, 0x00000000
    beq t2, t3, 1f; li gp, 804; j fail
    1: li t1, 0xFF; sb t1, 0(t0); lb t2, 0(t0); li t3, 0xFFFFFFFF
    beq t2, t3, 1f; li gp, 805; j fail
    1: li t1, 0x01; sb t1, 1(t0); lb t2, 1(t0); li t3, 0x00000001
    beq t2, t3, 1f; li gp, 806; j fail
    1: li t1, 0xAA; sb t1, 2(t0); lb t2, 2(t0); li t3, 0xFFFFFFAA
    beq t2, t3, 1f; li gp, 807; j fail
    1: li t1, 0x55; sb t1, 3(t0); lb t2, 3(t0); li t3, 0x00000055
    beq t2, t3, 1f; li gp, 808; j fail
    1: li t1, 0x0F; sb t1, 0(t0); lb t2, 0(t0); li t3, 0x0000000F
    beq t2, t3, 1f; li gp, 809; j fail
    1: li t1, 0xF0; sb t1, 1(t0); lb t2, 1(t0); li t3, 0xFFFFFFF0
    beq t2, t3, 1f; li gp, 810; j fail
    1:

    j test_lbu

test_lbu:
    # --- LBU: Load Byte Unsigned (10 Tests) ---
    li t1, 0xFE; sb t1, 0(t0); lbu t2, 0(t0); li t3, 0xFE
    beq t2, t3, 1f; li gp, 811; j fail
    1: li t1, 0x80; sb t1, 1(t0); lbu t2, 1(t0); li t3, 0x80
    beq t2, t3, 1f; li gp, 812; j fail
    1: li t1, 0xFF; sb t1, 2(t0); lbu t2, 2(t0); li t3, 0xFF
    beq t2, t3, 1f; li gp, 813; j fail
    1: li t1, 0x00; sb t1, 3(t0); lbu t2, 3(t0); li t3, 0x00
    beq t2, t3, 1f; li gp, 814; j fail
    1: li t1, 0x7F; sb t1, 0(t0); lbu t2, 0(t0); li t3, 0x7F
    beq t2, t3, 1f; li gp, 815; j fail
    1: li t1, 0xAA; sb t1, 1(t0); lbu t2, 1(t0); li t3, 0xAA
    beq t2, t3, 1f; li gp, 816; j fail
    1: li t1, 0x55; sb t1, 2(t0); lbu t2, 2(t0); li t3, 0x55
    beq t2, t3, 1f; li gp, 817; j fail
    1: li t1, 0x12; sb t1, 3(t0); lbu t2, 3(t0); li t3, 0x12
    beq t2, t3, 1f; li gp, 818; j fail
    1: li t1, 0x81; sb t1, 0(t0); lbu t2, 0(t0); li t3, 0x81
    beq t2, t3, 1f; li gp, 819; j fail
    1: li t1, 0xF0; sb t1, 1(t0); lbu t2, 1(t0); li t3, 0xF0
    beq t2, t3, 1f; li gp, 820; j fail
    1:

    j test_lh

test_lh:
    # --- SH/LH: Store/Load Halfword (10 Tests) ---
    li t1, 0x8ABC; sh t1, 4(t0); lh t2, 4(t0); li t3, 0xFFFF8ABC
    beq t2, t3, 1f; li gp, 821; j fail
    1: li t1, 0x7FFF; sh t1, 6(t0); lh t2, 6(t0); li t3, 0x00007FFF
    beq t2, t3, 1f; li gp, 822; j fail
    1: li t1, 0x8000; sh t1, 4(t0); lh t2, 4(t0); li t3, 0xFFFF8000
    beq t2, t3, 1f; li gp, 823; j fail
    1: li t1, 0x0001; sh t1, 6(t0); lh t2, 6(t0); li t3, 0x00000001
    beq t2, t3, 1f; li gp, 824; j fail
    1: li t1, 0xFFFF; sh t1, 4(t0); lh t2, 4(t0); li t3, 0xFFFFFFFF
    beq t2, t3, 1f; li gp, 825; j fail
    1: li t1, 0x0000; sh t1, 6(t0); lh t2, 6(t0); li t3, 0x00000000
    beq t2, t3, 1f; li gp, 826; j fail
    1: li t1, 0xAAAA; sh t1, 4(t0); lh t2, 4(t0); li t3, 0xFFFFAAAA
    beq t2, t3, 1f; li gp, 827; j fail
    1: li t1, 0x5555; sh t1, 6(t0); lh t2, 6(t0); li t3, 0x00005555
    beq t2, t3, 1f; li gp, 828; j fail
    1: li t1, 0x1234; sh t1, 4(t0); lh t2, 4(t0); li t3, 0x00001234
    beq t2, t3, 1f; li gp, 829; j fail
    1: li t1, 0xF0F0; sh t1, 6(t0); lh t2, 6(t0); li t3, 0xFFFFF0F0
    beq t2, t3, 1f; li gp, 830; j fail
    1:
    j test_lhu

test_lhu:
    # --- LHU: Load Halfword Unsigned (10 Tests) ---
    li t1, 0x8ABC; sh t1, 4(t0); lhu t2, 4(t0); li t3, 0x00008ABC
    beq t2, t3, 1f; li gp, 831; j fail
    1: li t1, 0xFFFF; sh t1, 6(t0); lhu t2, 6(t0); li t3, 0x0000FFFF
    beq t2, t3, 1f; li gp, 832; j fail
    1: li t1, 0x8000; sh t1, 4(t0); lhu t2, 4(t0); li t3, 0x00008000
    beq t2, t3, 1f; li gp, 833; j fail
    1: li t1, 0x0000; sh t1, 6(t0); lhu t2, 6(t0); li t3, 0x00000000
    beq t2, t3, 1f; li gp, 834; j fail
    1: li t1, 0x7FFF; sh t1, 4(t0); lhu t2, 4(t0); li t3, 0x00007FFF
    beq t2, t3, 1f; li gp, 835; j fail
    1: li t1, 0xAAAA; sh t1, 6(t0); lhu t2, 6(t0); li t3, 0x0000AAAA
    beq t2, t3, 1f; li gp, 836; j fail
    1: li t1, 0x5555; sh t1, 4(t0); lhu t2, 4(t0); li t3, 0x00005555
    beq t2, t3, 1f; li gp, 837; j fail
    1: li t1, 0x0001; sh t1, 6(t0); lhu t2, 6(t0); li t3, 0x00000001
    beq t2, t3, 1f; li gp, 838; j fail
    1: li t1, 0xF0F0; sh t1, 4(t0); lhu t2, 4(t0); li t3, 0x0000F0F0
    beq t2, t3, 1f; li gp, 839; j fail
    1: li t1, 0x1234; sh t1, 6(t0); lhu t2, 6(t0); li t3, 0x00001234
    beq t2, t3, 1f; li gp, 840; j fail
    1:
    j check_immed

# =============================================================================
# 5. UPPER IMMEDIATES & JUMPS (LUI, AUIPC, JALR)
# =============================================================================
check_immed:
    # --- LUI: Load Upper Immediate (10 Tests) ---
    li t1, 0x12345000; lui t0, 0x12345
    beq t0, t1, 1f; li gp, 901; j fail
    1: li t1, 0x00001000; lui t0, 0x00001
    beq t0, t1, 1f; li gp, 902; j fail
    1: li t1, 0x80000000; lui t0, 0x80000
    beq t0, t1, 1f; li gp, 903; j fail
    1: li t1, 0xFFFFF000; lui t0, 0xFFFFF
    beq t0, t1, 1f; li gp, 904; j fail
    1: li t1, 0x00000000; lui t0, 0x00000
    beq t0, t1, 1f; li gp, 905; j fail
    1: li t1, 0xABCDE000; lui t0, 0xABCDE
    beq t0, t1, 1f; li gp, 906; j fail
    1: li t1, 0x55555000; lui t0, 0x55555
    beq t0, t1, 1f; li gp, 907; j fail
    1: li t1, 0x10101000; lui t0, 0x10101
    beq t0, t1, 1f; li gp, 908; j fail
    1: li t1, 0x7FFFF000; lui t0, 0x7FFFF
    beq t0, t1, 1f; li gp, 909; j fail
    1: li t1, 0xCAFEF000; lui t0, 0xCAFEF
    beq t0, t1, 1f; li gp, 910; j fail
    1:

    j test_auipc

test_auipc:
    # --- AUIPC: Add Upper Immediate to PC (10 Tests) ---
    # [1] Offset 0 (Direct PC capture)
    loc1: auipc t0, 0; la t1, loc1
    beq t0, t1, 1f; li gp, 911; j fail
    1:
    # [2] Offset 0x1000 (1 page forward) - FIXED: Used li/add for large offset
    loc2: auipc t0, 1; la t1, loc2; li t2, 0x1000; add t1, t1, t2
    beq t0, t1, 1f; li gp, 912; j fail
    1:
    # [3] Large offset
    loc3: auipc t0, 0x12345; la t1, loc3; li t2, 0x12345000; add t1, t1, t2
    beq t0, t1, 1f; li gp, 913; j fail
    1:
    # [4] Lower bits ignored - FIXED: Used li/add for large offset
    loc4: auipc t0, 0x00002; la t1, loc4; li t2, 0x2000; add t1, t1, t2
    beq t0, t1, 1f; li gp, 914; j fail
    1:
    # [5] Negative offset (Sign extension of 20-bit immediate)
    loc5: auipc t0, 0xFFFFF; la t1, loc5; li t2, 0xFFFFF000; add t1, t1, t2
    beq t0, t1, 1f; li gp, 915; j fail
    1:
    # [6] Another negative offset (-2 pages)
    loc6: auipc t0, 0xFFFFE; la t1, loc6; li t2, 0xFFFFE000; add t1, t1, t2
    beq t0, t1, 1f; li gp, 916; j fail
    1:
    # [7] Zero immediate again (Consistency check)
    loc7: auipc t0, 0; la t1, loc7
    beq t0, t1, 1f; li gp, 917; j fail
    1:
    # [8] Max positive offset
    loc8: auipc t0, 0x7FFFF; la t1, loc8; li t2, 0x7FFFF000; add t1, t1, t2
    beq t0, t1, 1f; li gp, 918; j fail
    1:
    # [9] Pattern 0xAAAAA
    loc9: auipc t0, 0xAAAAA; la t1, loc9; li t2, 0xAAAAA000; add t1, t1, t2
    beq t0, t1, 1f; li gp, 919; j fail
    1:
    # [10] Pattern 0x55555
    loc10: auipc t0, 0x55555; la t1, loc10; li t2, 0x55555000; add t1, t1, t2
    beq t0, t1, 1f; li gp, 920; j fail
    1:

    j test_jalr

test_jalr:
    # --- JALR: Jump and Link Register (10 Tests) ---
    # [1] Basic jump with 0 offset
    la t0, 1f
    jalr ra, 0(t0)          # ra should now be the address of the 'li gp' below
    li gp, 921; j fail      # Hardware must skip this
    1:

    # [2] Verify ra was set correctly (ra should be address of 'li gp' above)
    la t1, 1b               # Get address of label '1:'
    addi t1, t1, -8         # Subtract 8 bytes (j fail and li gp) to get back to 'li gp'
    beq ra, t1, 1f; li gp, 922; j fail
    1:

    # [3] Jump with positive immediate offset
    la t0, 1f - 4; jalr ra, 4(t0); li gp, 923; j fail
    1:

    # [4] Jump with negative immediate offset
    la t0, 1f + 4; jalr ra, -4(t0); li gp, 924; j fail
    1:

    # [5] Verify JALR clears the low bit (LSB) of the target address
    la t0, 1f; ori t0, t0, 1; jalr ra, 0(t0); li gp, 925; j fail
    1:

    # [6] Jump using a different base register (t1)
    la t1, 1f; jalr ra, 0(t1); li gp, 926; j fail
    1:

    # [7] Jump and link to a different link register (t2)
    la t0, 1f
    jalr t2, 0(t0)
    li gp, 927; j fail
    1:
    la t1, 1b; addi t1, t1, -8 # Calculate address of 'li gp, 927'
    beq t2, t1, 1f; li gp, 928; j fail
    1:

    # [8] Multiple jumps in sequence (Chain test)
    la t0, 2f; jalr ra, 0(t0); li gp, 929; j fail
    2: la t0, 1f; jalr ra, 0(t0); li gp, 930; j fail
    1:

    # [9] Max positive 12-bit offset (2044 for alignment)
    la t0, 1f - 2044; jalr ra, 2044(t0); li gp, 931; j fail
    1:

    # [10] Max negative 12-bit offset (-2048)
    la t0, 1f + 2048; jalr ra, -2048(t0); li gp, 932; j fail
    1:

    j pass

# =============================================================================
# FINISH
# =============================================================================
# =============================================================================
# FINISH
# =============================================================================
pass:
    j return_extended_test

.section .data
.align 4            # Forces the data to start on a 4-byte boundary
test_data:
    .zero 32        # Allocates 32 bytes of zeros (plenty of room for offsets 4 and 6)
