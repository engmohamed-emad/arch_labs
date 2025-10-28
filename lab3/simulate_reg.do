vlib work
vmap work work
vcom *.vhd
vsim work.regfile_dff

add wave sim:/regfile_dff/clk
add wave sim:/regfile_dff/reset
add wave sim:/regfile_dff/write_en
add wave sim:/regfile_dff/read_addr0
add wave sim:/regfile_dff/read_addr1
add wave sim:/regfile_dff/write_addr
add wave sim:/regfile_dff/write_data
add wave sim:/regfile_dff/read_data0
add wave sim:/regfile_dff/read_data1
add wave sim:/regfile_dff/reg_q(0)
add wave sim:/regfile_dff/reg_q(1)
add wave sim:/regfile_dff/reg_q(2)
add wave sim:/regfile_dff/reg_q(3)
add wave sim:/regfile_dff/reg_q(4)
add wave sim:/regfile_dff/reg_q(5)
add wave sim:/regfile_dff/reg_q(6)
add wave sim:/regfile_dff/reg_q(7)

#for clock
force -repeat 10ns sim:/regfile_dff/clk 0 0ns, 1 5ns
force sim:/regfile_dff/reset 1 0ns, 0 10ns

#for make readaddr and enable write
force sim:/regfile_dff/read_addr0 3'b000 0
force sim:/regfile_dff/read_addr1 3'b000 0
force sim:/regfile_dff/write_en 1 10ns

#write to registers tests
force sim:/regfile_dff/write_addr 3'b000 10ns
force sim:/regfile_dff/write_data 8'hff 10ns

force sim:/regfile_dff/write_addr 3'b001 20ns
force sim:/regfile_dff/write_data 8'h11 20ns

force sim:/regfile_dff/write_addr 3'b111 30ns
force sim:/regfile_dff/write_data 8'h90 30ns

force sim:/regfile_dff/write_addr 3'b011 40ns
force sim:/regfile_dff/write_data 8'h08 40ns

#read from registers tests
force sim:/regfile_dff/read_addr0 3'b001 50ns
force sim:/regfile_dff/read_addr1 3'b111 50ns
force sim:/regfile_dff/write_addr 3'b100 50ns
force sim:/regfile_dff/write_data 8'h03 50ns

force sim:/regfile_dff/read_addr0 3'b010 60ns
force sim:/regfile_dff/read_addr1 3'b011 60ns

force sim:/regfile_dff/read_addr0 3'b100 70ns
force sim:/regfile_dff/read_addr1 3'b101 70ns

force sim:/regfile_dff/read_addr0 3'b110 80ns
force sim:/regfile_dff/read_addr1 3'b000 80ns
force sim:/regfile_dff/write_addr 3'b000 80ns
force sim:/regfile_dff/write_data 8'h01 80ns

# Run the simulation
run 500
