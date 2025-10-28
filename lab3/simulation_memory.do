vlib work
vmap work work
vcom *.vhd
vsim work.registerMemo

add wave sim:/registerMemo/clk
add wave sim:/registerMemo/reset
add wave sim:/registerMemo/write_en
add wave sim:/registerMemo/read_addr0
add wave sim:/registerMemo/read_addr1
add wave sim:/registerMemo/write_addr
add wave sim:/registerMemo/write_data
add wave sim:/registerMemo/read_data0
add wave sim:/registerMemo/read_data1
add wave sim:/registerMemo/ram(0)
add wave sim:/registerMemo/ram(1)
add wave sim:/registerMemo/ram(2)
add wave sim:/registerMemo/ram(3)
add wave sim:/registerMemo/ram(4)
add wave sim:/registerMemo/ram(5)
add wave sim:/registerMemo/ram(6)
add wave sim:/registerMemo/ram(7)

#for clock
force -repeat 10ns sim:/registerMemo/clk 0 0ns, 1 5ns
force sim:/registerMemo/reset 1 0ns, 0 10ns

#for make readaddr and enable write
force sim:/registerMemo/read_addr0 3'b000 0
force sim:/registerMemo/read_addr1 3'b000 0
force sim:/registerMemo/write_en 1 10ns

#write to registers tests
force sim:/registerMemo/write_addr 3'b000 10ns
force sim:/registerMemo/write_data 8'hff 10ns

force sim:/registerMemo/write_addr 3'b001 20ns
force sim:/registerMemo/write_data 8'h11 20ns

force sim:/registerMemo/write_addr 3'b111 30ns
force sim:/registerMemo/write_data 8'h90 30ns

force sim:/registerMemo/write_addr 3'b011 40ns
force sim:/registerMemo/write_data 8'h08 40ns

#read from registers tests
force sim:/registerMemo/read_addr0 3'b001 50ns
force sim:/registerMemo/read_addr1 3'b111 50ns
force sim:/registerMemo/write_addr 3'b100 50ns
force sim:/registerMemo/write_data 8'h03 50ns

force sim:/registerMemo/read_addr0 3'b010 60ns
force sim:/registerMemo/read_addr1 3'b011 60ns

force sim:/registerMemo/read_addr0 3'b100 70ns
force sim:/registerMemo/read_addr1 3'b101 70ns

force sim:/registerMemo/read_addr0 3'b110 80ns
force sim:/registerMemo/read_addr1 3'b000 80ns
force sim:/registerMemo/write_addr 3'b000 80ns
force sim:/registerMemo/write_data 8'h01 80ns

# Run the simulation
run 500
