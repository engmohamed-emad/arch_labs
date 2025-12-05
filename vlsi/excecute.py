import numpy as np

# ========================
# LOAD DATA
# ========================
input_mat = np.loadtxt("input.txt", dtype=np.uint8)
kernel = np.loadtxt("kernel.txt", dtype=np.uint8)

N = input_mat.shape[0]
K = kernel.shape[0]
OUT = N - K + 1

output = np.zeros((OUT, OUT), dtype=np.int32)

# ========================
# OPEN DEBUG FILE
# ========================
debug = open("debug_stages.txt", "w")

debug.write("====== STAGE BY STAGE CONVOLUTION DEBUG ======\n\n")

# ========================
# CONVOLUTION WITH FULL STAGES
# ========================
for i in range(OUT):
    for j in range(OUT):

        region = input_mat[i:i+K, j:j+K]
        psum = 0

        debug.write(f"\n--- Output Pixel [{i},{j}] ---\n")
        debug.write("Sliding Window:\n")
        debug.write(str(region) + "\n")

        for ki in range(K):
            for kj in range(K):
                a = int(region[ki, kj])
                b = int(kernel[ki, kj])
                prod = a * b
                psum += prod

                debug.write(
                    f"A={a}  B={b}  PROD={prod}  PSUM={psum}\n"
                )

        output[i, j] = psum

# ========================
# SAVE FINAL OUTPUT
# ========================
np.savetxt("expected.txt", output, fmt="%d")
debug.close()

print("✅ Golden Model Executed")
print("✅ Debug stages saved in debug_stages.txt")
print("✅ Final output saved in expected.txt")
