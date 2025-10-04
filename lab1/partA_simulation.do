vcom partA.vhd
vsim work.partA
add wave -position insertpoint \
sim:/partA/a \
sim:/partA/b \
sim:/partA/sel \
sim:/partA/cin \
sim:/partA/f \
sim:/partA/cout
#pass a value test
force sim:/partA/a 8'h0f 0
force sim:/partA/b 8'hxx 0
force sim:/partA/sel 4'b0000 0
force sim:/partA/cin 0 0
run

#add a + b
force sim:/partA/a 8'h0f 0
force sim:/partA/b 8'h01 0
force sim:/partA/sel 4'b0001 0
force sim:/partA/cin 0 0
run

#add a + b with another value producing carry out
force sim:/partA/a 8'hff 0
force sim:/partA/b 8'h01 0
force sim:/partA/sel 4'b0001 0
force sim:/partA/cin 0 0
run

#a - b - 1
force sim:/partA/a 8'hff 0
force sim:/partA/b 8'h01 0
force sim:/partA/sel 4'b0010 0
force sim:/partA/cin 0 0
run

#a - 1
force sim:/partA/a 8'hff 0
force sim:/partA/b 8'hxx 0
force sim:/partA/sel 4'b0011 0
force sim:/partA/cin 0 0
run

#a + 1
force sim:/partA/a 8'h0e 0
force sim:/partA/b 8'hxx 0
force sim:/partA/sel 4'b0000 0
force sim:/partA/cin 1 0
run

#a + b + 1
force sim:/partA/a 8'hff 0
force sim:/partA/b 8'h01 0
force sim:/partA/sel 4'b0001 0
force sim:/partA/cin 1 0
run

#a - b
force sim:/partA/a 8'h0f 0
force sim:/partA/b 8'h01 0
force sim:/partA/sel 4'b0010 0
force sim:/partA/cin 1 0
run

#0
force sim:/partA/a 8'hf0 0
force sim:/partA/b 8'hxx 0
force sim:/partA/sel 4'b0011 0
force sim:/partA/cin 1 0
run
