

vsim work.alu

# ? waveform
add wave -position insertpoint \
sim:/alu/A \
sim:/alu/B \
sim:/alu/S \
sim:/alu/Cin \
sim:/alu/F \
sim:/alu/Cout

# AND
force -freeze sim:/alu/A 8'hF5 0
force -freeze sim:/alu/B 8'hAA 0
force -freeze sim:/alu/S 4'b0100 0
force -freeze sim:/alu/Cin 0 0
run

# OR
force -freeze sim:/alu/S 4'b0101 0
run

# NOR
force -freeze sim:/alu/S 4'b0110 0
run

# NOT
force -freeze sim:/alu/S 4'b0111 0
run

# Logic shift right A
force -freeze sim:/alu/A 8'hF5 0
force -freeze sim:/alu/S 4'b1000 0
run

# Rotate right A
force -freeze sim:/alu/S 4'b1001 0
run

# Rotate right A with Carry (Cin=0)
force -freeze sim:/alu/Cin 0 0
force -freeze sim:/alu/S 4'b1010 0
run

# Rotate right A with Carry (Cin=1)
force -freeze sim:/alu/Cin 1 0
force -freeze sim:/alu/S 4'b1010 0
run

# Arithmetic shift right A
force -freeze sim:/alu/S 4'b1011 0
run

# Logic shift left A
force -freeze sim:/alu/S 4'b1100 0
run

# Rotate left A
force -freeze sim:/alu/S 4'b1101 0
run

# Rotate left A with Carry (Cin=0)
force -freeze sim:/alu/Cin 0 0
force -freeze sim:/alu/S 4'b1110 0
run

# Rotate left A with Carry (Cin=1)
force -freeze sim:/alu/Cin 1 0
force -freeze sim:/alu/S 4'b1110 0
run

# 0000
force -freeze sim:/alu/S 4'b1111 0
run

# Rotate right A with different input (A=7A)
force -freeze sim:/alu/A 8'h7A 0
force -freeze sim:/alu/S 4'b1001 0
run


