onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /window_analysis_tb/clk
add wave -noupdate /window_analysis_tb/nrst_in
add wave -noupdate -divider {frame interface}
add wave -noupdate -color Gold -radix decimal /window_analysis_tb/sample_data_in
add wave -noupdate -color Gold /window_analysis_tb/cycle_start_in
add wave -noupdate -color Gold -radix unsigned /window_analysis_tb/window_delay_in
add wave -noupdate -color Gold -radix unsigned /window_analysis_tb/window_pow_in
add wave -noupdate -divider {fifo interface}
add wave -noupdate /window_analysis_tb/read_enable_in
add wave -noupdate -radix binary /window_analysis_tb/fifo_state_out
add wave -noupdate -radix hexadecimal /window_analysis_tb/read_data_out
add wave -noupdate -divider output_data
add wave -noupdate -color Magenta -radix unsigned /window_analysis_tb/cycle_number
add wave -noupdate -color Magenta -radix decimal /window_analysis_tb/zero_offset
add wave -noupdate -color Magenta -radix decimal /window_analysis_tb/max_amp
add wave -noupdate -color Magenta -radix unsigned /window_analysis_tb/max_time
add wave -noupdate -divider -height 30 {UUT INTERNAL SIGNALS}
add wave -noupdate -divider {frame processing}
add wave -noupdate /window_analysis_tb/uut/state_r
add wave -noupdate /window_analysis_tb/uut/cycle_start_sync(1)
add wave -noupdate /window_analysis_tb/uut/cycle_start_sync(0)
add wave -noupdate -radix unsigned /window_analysis_tb/uut/delay_counter
add wave -noupdate -color Salmon -radix decimal /window_analysis_tb/uut/sample_data
add wave -noupdate -color Salmon -radix unsigned /window_analysis_tb/uut/time_counter
add wave -noupdate -radix decimal -childformat {{/window_analysis_tb/uut/sum_sample_data(13) -radix decimal} {/window_analysis_tb/uut/sum_sample_data(12) -radix decimal} {/window_analysis_tb/uut/sum_sample_data(11) -radix decimal} {/window_analysis_tb/uut/sum_sample_data(10) -radix decimal} {/window_analysis_tb/uut/sum_sample_data(9) -radix decimal} {/window_analysis_tb/uut/sum_sample_data(8) -radix decimal} {/window_analysis_tb/uut/sum_sample_data(7) -radix decimal} {/window_analysis_tb/uut/sum_sample_data(6) -radix decimal} {/window_analysis_tb/uut/sum_sample_data(5) -radix decimal} {/window_analysis_tb/uut/sum_sample_data(4) -radix decimal} {/window_analysis_tb/uut/sum_sample_data(3) -radix decimal} {/window_analysis_tb/uut/sum_sample_data(2) -radix decimal} {/window_analysis_tb/uut/sum_sample_data(1) -radix decimal} {/window_analysis_tb/uut/sum_sample_data(0) -radix decimal}} -subitemconfig {/window_analysis_tb/uut/sum_sample_data(13) {-height 15 -radix decimal} /window_analysis_tb/uut/sum_sample_data(12) {-height 15 -radix decimal} /window_analysis_tb/uut/sum_sample_data(11) {-height 15 -radix decimal} /window_analysis_tb/uut/sum_sample_data(10) {-height 15 -radix decimal} /window_analysis_tb/uut/sum_sample_data(9) {-height 15 -radix decimal} /window_analysis_tb/uut/sum_sample_data(8) {-height 15 -radix decimal} /window_analysis_tb/uut/sum_sample_data(7) {-height 15 -radix decimal} /window_analysis_tb/uut/sum_sample_data(6) {-height 15 -radix decimal} /window_analysis_tb/uut/sum_sample_data(5) {-height 15 -radix decimal} /window_analysis_tb/uut/sum_sample_data(4) {-height 15 -radix decimal} /window_analysis_tb/uut/sum_sample_data(3) {-height 15 -radix decimal} /window_analysis_tb/uut/sum_sample_data(2) {-height 15 -radix decimal} /window_analysis_tb/uut/sum_sample_data(1) {-height 15 -radix decimal} /window_analysis_tb/uut/sum_sample_data(0) {-height 15 -radix decimal}} /window_analysis_tb/uut/sum_sample_data
add wave -noupdate -color {Sky Blue} -radix decimal -childformat {{/window_analysis_tb/uut/zero_offset(12) -radix decimal} {/window_analysis_tb/uut/zero_offset(11) -radix decimal} {/window_analysis_tb/uut/zero_offset(10) -radix decimal} {/window_analysis_tb/uut/zero_offset(9) -radix decimal} {/window_analysis_tb/uut/zero_offset(8) -radix decimal} {/window_analysis_tb/uut/zero_offset(7) -radix decimal} {/window_analysis_tb/uut/zero_offset(6) -radix decimal} {/window_analysis_tb/uut/zero_offset(5) -radix decimal} {/window_analysis_tb/uut/zero_offset(4) -radix decimal} {/window_analysis_tb/uut/zero_offset(3) -radix decimal} {/window_analysis_tb/uut/zero_offset(2) -radix decimal} {/window_analysis_tb/uut/zero_offset(1) -radix decimal} {/window_analysis_tb/uut/zero_offset(0) -radix decimal}} -subitemconfig {/window_analysis_tb/uut/zero_offset(12) {-color {Sky Blue} -height 15 -radix decimal} /window_analysis_tb/uut/zero_offset(11) {-color {Sky Blue} -height 15 -radix decimal} /window_analysis_tb/uut/zero_offset(10) {-color {Sky Blue} -height 15 -radix decimal} /window_analysis_tb/uut/zero_offset(9) {-color {Sky Blue} -height 15 -radix decimal} /window_analysis_tb/uut/zero_offset(8) {-color {Sky Blue} -height 15 -radix decimal} /window_analysis_tb/uut/zero_offset(7) {-color {Sky Blue} -height 15 -radix decimal} /window_analysis_tb/uut/zero_offset(6) {-color {Sky Blue} -height 15 -radix decimal} /window_analysis_tb/uut/zero_offset(5) {-color {Sky Blue} -height 15 -radix decimal} /window_analysis_tb/uut/zero_offset(4) {-color {Sky Blue} -height 15 -radix decimal} /window_analysis_tb/uut/zero_offset(3) {-color {Sky Blue} -height 15 -radix decimal} /window_analysis_tb/uut/zero_offset(2) {-color {Sky Blue} -height 15 -radix decimal} /window_analysis_tb/uut/zero_offset(1) {-color {Sky Blue} -height 15 -radix decimal} /window_analysis_tb/uut/zero_offset(0) {-color {Sky Blue} -height 15 -radix decimal}} /window_analysis_tb/uut/zero_offset
add wave -noupdate -color {Sky Blue} -radix decimal /window_analysis_tb/uut/max_ampl
add wave -noupdate -color {Sky Blue} -radix unsigned /window_analysis_tb/uut/max_time
add wave -noupdate -color {Sky Blue} /window_analysis_tb/uut/cycle_number
add wave -noupdate -divider fifo_buffer
add wave -noupdate /window_analysis_tb/uut/write_data
add wave -noupdate /window_analysis_tb/uut/read_data
add wave -noupdate /window_analysis_tb/uut/wr_en
add wave -noupdate /window_analysis_tb/uut/rd_en
add wave -noupdate /window_analysis_tb/uut/reset_mem
add wave -noupdate /window_analysis_tb/uut/full
add wave -noupdate /window_analysis_tb/uut/empty
add wave -noupdate /window_analysis_tb/uut/almost_full
add wave -noupdate /window_analysis_tb/uut/almost_empty
add wave -noupdate -radix unsigned /window_analysis_tb/uut/rd_count
add wave -noupdate -radix unsigned /window_analysis_tb/uut/wr_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {624000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 263
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
WaveRestoreZoom {476500 ps} {1132900 ps}
