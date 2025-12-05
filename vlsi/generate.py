import numpy as np

# ========================
# CONFIGURATION
# ========================
N = 16   # Input size (16 to 64)
K = 3    # Kernel size (2 to 16)

# ========================
# DATA GENERATION
# ========================
input_mat = np.random.randint(0, 256, (N, N), dtype=np.uint8)
kernel = np.random.randint(0, 256, (K, K), dtype=np.uint8)

# ========================
# SAVE TO FILES
# ========================
np.savetxt("input.txt", input_mat, fmt="%d")
np.savetxt("kernel.txt", kernel, fmt="%d")

print("✅ Input and Kernel Generated Successfully")
print("Input Shape:", input_mat.shape)
print("Kernel Shape:", kernel.shape)
