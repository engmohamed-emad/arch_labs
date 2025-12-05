import numpy as np

# ========================
# LOAD FILES
# ========================
expected = np.loadtxt("expected.txt")
hardware = np.loadtxt("results.txt")

expected = expected.flatten()
hardware = hardware.flatten()

# ========================
# CHECK SIZE MATCH
# ========================
if len(expected) != len(hardware):
    print("❌ SIZE MISMATCH!")
    print("Expected size:", len(expected))
    print("Hardware size:", len(hardware))
    exit()

# ========================
# COMPARE WITH TOLERANCE
# ========================
tolerance = 1
errors = 0

for i in range(len(expected)):
    diff = abs(expected[i] - hardware[i])

    if diff > tolerance:
        print(
            f"❌ MISMATCH at index {i} | "
            f"SW={expected[i]} | HW={hardware[i]} | DIFF={diff}"
        )
        errors += 1

# ========================
# FINAL RESULT
# ========================
if errors == 0:
    print("\n✅✅✅ HARDWARE MATCHES SOFTWARE ✅✅✅")
else:
    print(f"\n❌❌❌ TOTAL ERRORS: {errors}")
