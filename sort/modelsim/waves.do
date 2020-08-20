onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 25 {INPUT INTERFACE}
add wave -noupdate /sorter_stack_tb/uut/snk_reset
add wave -noupdate /sorter_stack_tb/uut/snk_clock
add wave -noupdate -color Gold /sorter_stack_tb/uut/snk_valid
add wave -noupdate -color Gold /sorter_stack_tb/uut/snk_sop
add wave -noupdate -color Gold /sorter_stack_tb/uut/snk_eop
add wave -noupdate -color Gold /sorter_stack_tb/uut/snk_data
add wave -noupdate /sorter_stack_tb/uut/snk_ready
add wave -noupdate -divider -height 25 {OUTPUT INTERFACE}
add wave -noupdate /sorter_stack_tb/uut/src_reset
add wave -noupdate /sorter_stack_tb/uut/src_clock
add wave -noupdate -color Salmon /sorter_stack_tb/uut/src_valid
add wave -noupdate -color Salmon /sorter_stack_tb/uut/src_sop
add wave -noupdate -color Salmon /sorter_stack_tb/uut/src_eop
add wave -noupdate -color Salmon -radix unsigned /sorter_stack_tb/uut/src_data
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 354
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1155 ns}
