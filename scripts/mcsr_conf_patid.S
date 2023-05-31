# See LICENSE for license details.

#*****************************************************************************
# mcsr_conf_patid.S
#-----------------------------------------------------------------------------
#
# Test PATID CSR.
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64M
RVTEST_CODE_BEGIN

  # Check that mcpuid reports the correct XLEN
#if __riscv_xlen == 64
  TEST_CASE(2, a0, 0x2, csrr a0, misa; srl a0, a0, 62)
#else
  TEST_CASE(2, a0, 0x1, csrr a0, misa; srl a0, a0, 30)
#endif

  # Check that mhartid reports 0
  TEST_CASE(3, a0, 0x0, csrr a0, mhartid)

  # Check that reading the following CSRs doesn't cause an exception
  csrr a0, 0xa00

  # Check that writing the following CSRs doesn't cause an exception
  # Set the PatID to 1
  li t0, 1
  csrs 0xa00, t0

  li t1, 0x70000000
  li t2, 0xFFFF

  # flush the cache before reconfiguration
  sb t2, 8(t1)
  sb t2, 12(t1)
  # commit the flush
  li t2, 1
  sb t2, 280(t1)


  li t2, 0x0A0A
  # set the size of pat 0 and 1 to 0xA
  sb t2, 24(t1)
  li t2, 1
  # commit the change 
  sb t2, 312(t1)


  # Check data written into PATID CSR
  csrr a0, 0xa00

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
