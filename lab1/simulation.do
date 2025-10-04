vcom *.vhd
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
force sim:/alu/A 8'hF5 0
force sim:/alu/B 8'hAA 0
force sim:/alu/S 4'b0100 0
force sim:/alu/Cin 0 0
run

# OR
force sim:/alu/S 4'b0101 0
run

# NOR
force sim:/alu/S 4'b0110 0
run

# NOT
force sim:/alu/S 4'b0111 0
run

# Logic shift right A
force sim:/alu/A 8'hF5 0
force sim:/alu/S 4'b1000 0
run

# Rotate right A
force sim:/alu/S 4'b1001 0
run

# Rotate right A with Carry (Cin=0)
force sim:/alu/Cin 0 0
force sim:/alu/S 4'b1010 0
run

# Rotate right A with Carry (Cin=1)
force sim:/alu/Cin 1 0
force sim:/alu/S 4'b1010 0
run

# Arithmetic shift right A
force sim:/alu/S 4'b1011 0
run

# Logic shift left A
force sim:/alu/S 4'b1100 0
run

# Rotate left A
force sim:/alu/S 4'b1101 0
run

# Rotate left A with Carry (Cin=0)
force sim:/alu/Cin 0 0
force sim:/alu/S 4'b1110 0
run

# Rotate left A with Carry (Cin=1)
force sim:/alu/Cin 1 0
force sim:/alu/S 4'b1110 0
run

# 0000
force sim:/alu/S 4'b1111 0
run

# Rotate right A with different input (A=7A)
force sim:/alu/A 8'h7A 0
force sim:/alu/S 4'b1001 0
run

#pass a value test
force sim:/alu/A 8'h0F 0
force sim:/alu/B 8'hxx 0
force sim:/alu/S 4'b0000 0
force sim:/alu/Cin 0 0
run

#add a + b
force sim:/alu/A 8'h0F 0
force sim:/alu/B 8'h01 0
force sim:/alu/S 4'b0001 0
force sim:/alu/Cin 0 0
run

#add a + b with another value producing carry out
force sim:/alu/A 8'hFF 0
force sim:/alu/B 8'h01 0
force sim:/alu/S 4'b0001 0
force sim:/alu/Cin 0 0
run

#A - B - 1
force sim:/alu/A 8'hFF 0
force sim:/alu/B 8'h01 0
force sim:/alu/S 4'b0010 0
force sim:/alu/Cin 0 0
run

#A - 1
force sim:/alu/A 8'hFF 0
force sim:/alu/B 8'hxx 0
force sim:/alu/S 4'b0011 0
force sim:/alu/Cin 0 0
run

#A + 1
force sim:/alu/A 8'h0E 0
force sim:/alu/B 8'hxx 0
force sim:/alu/S 4'b0000 0
force sim:/alu/Cin 1 0
run

#A + B + 1
force sim:/alu/A 8'hFF 0
force sim:/alu/B 8'h01 0
force sim:/alu/S 4'b0001 0
force sim:/alu/Cin 1 0
run

#A - B
force sim:/alu/A 8'h0F 0
force sim:/alu/B 8'h01 0
force sim:/alu/S 4'b0010 0
force sim:/alu/Cin 1 0
run

#0
force sim:/alu/A 8'hF0 0
force sim:/alu/B 8'hxx 0
force sim:/alu/S 4'b0011 0
force sim:/alu/Cin 1 0
run
