# ========== WELCOME PART ==========
#
# КРАТКАЯ ИНФОРМАЦИЯ
#
# Скрипт предназначен для автоматизированного создания и сборки проекта в среде Vivado.
# Скрипт предназначен для работы со следующей файловой структурой:
#    \bd – файлы блочного дизайна 
#    \cores – файлы ip-ядер (например, файлы .xco .xcix или .xci)                      
#    \rtl – файлы с hdl-кодом 
#        \file_name – подпапка с программным модулем и его тестбенчем 
#    \software – код и библиотеки для процессорных модулей 
#    \xdc_ucf – файлы проектных ограничений 
#
# Подробное описание файловой структуры и правила именования файлов приведены в документе "ПЛИС Маршрут разработки" в разделе 4.5.
#
# КАК ИСПОЛЬЗОВАТЬ
#
# Перед запуском необходимо выбрать в тексте скрипта парт-номер ПЛИС и название проекта. А также необходимость синтеза и имплемента проекта после создания.
# Это можно сделать в разделе USER PART
#
# Параметры по умолчанию:
# ---- part_number "xc7k325tffg676-2"
# ---- project_name "bpu"
# ---- need_synth 1
# ---- need_impl 0
#
# Остальные параметры и код скрипта менять не нужно.
#
# ВАЖНО: скрипт создаёт папку project в своей директории для размещения проекта. 
#        Если папка с таким названием уже существует, ОНА БУДЕТ УДАЛЕНА ВМЕСТЕ СО ВСЕМ СОДЕРЖИМЫМ
# 
# Для запуска: open Vivado, Tools -> Run TCL script... -> make_project.tcl.
#              Обратите внимание, что предварительно необходимо скачать или создать папку src с исходниками проекта.
#              Скрипт закроет текущий проект и откроет созданный проект в текущем окне.
#
# ========== END WELCOME PART ==========
#
# ========== USER PART ==========
#
# Project parameters
#
set part_number "xc7k420tffg901-1"
set project_name "bpu"
#
set top_file_name "top"
set language "VHDL"
#
# Synthesis and Implementation
#
set need_synth 1
set need_impl 0
#
# Directories
#
set src_dir [file dirname [file normalize [info script]]]
cd ${src_dir}
cd ../
set project_dir [pwd]
#
# Dicts for project files
# 
### Dicts for different folders
#
dict set bd_files ext_1 *.bd
dict set bd_files ext_2 *.vhd
#
dict set core_files ext_1 */*.xci
dict set core_files ext_2 *.xcix
#
dict set rtl_files ext_1 */*.vhd
dict set rtl_files ext_2 */*.v
dict set rtl_files ext_3 */*.sv
#
dict set sw_files ext_1 *.c
#
dict set constr_files ext_1 *.xdc
dict set constr_files ext_2 *.ucf
#
### Complete dict with file types for each folder
#
dict set files "bd" ${bd_files} 
dict set files "cores" ${core_files} 
dict set files "rtl" ${rtl_files} 
dict set files "software" ${sw_files} 
dict set files "xdc_ucf" ${constr_files} 
#
# ========== END USER PART ==========
#
# ========== SCRIPT PART ==========
#
# Special procedure for finde files
#
proc findFiles { basedir pattern } {
    set basedir [string trimright [file join [file normalize $basedir] { }]]
    set fileList {}
	
    foreach fileName [glob -nocomplain -type {f r} -path $basedir $pattern] {
        lappend fileList $fileName
    }	
    foreach dirName [glob -nocomplain -type {d  r} -path $basedir *] {
        set subDirList [findFiles $dirName $pattern]
        if { [llength $subDirList] > 0 } {
            foreach subDirFile $subDirList {
		lappend fileList $subDirFile
            }
        }
    }
    return $fileList
}
#
# Initialize info
#
puts "BUILD PROJECT IS [string toupper ${project_name}] STARTED"
puts "TARGET DEVICE IS [string toupper ${part_number}]"
puts "TARGET LANGUAGE IS [string toupper ${language}]"
puts "TOP FILE IS [string tolower ${top_file_name}]"
#
puts "==================="
#
puts "SOURCES DIRECTORY IS ${src_dir}"
puts "PROJECT DIRECTORY IS ${project_dir}. It would be deleted if existing now"
#
puts "==================="


# Create project folder if its not exist
#
close_project -quiet
#
if {[file exists ${project_name}] == 1} { file delete -force ${project_name} }
file mkdir ${project_name}
#
puts "${project_dir} CREATED"
puts "==================="
#
cd ${project_dir}
#
# Create Vivado project
#
create_project -part ${part_number} -name ${project_name} -dir ${project_dir}/${project_name} -force
set_property target_language ${language} [current_project]
start_gui -quiet
#
puts "VIVADO PROJECT CREATED"
puts "==================="
#
# Add files into project
#
puts "ADD FILES IN CREATED PROJECT STARTED"
#
dict for {type type_files} $files {

	puts "${type} files will be added"

	dict for {key ext} ${type_files} {
    
	    set appended_files [findFiles ${src_dir}/${type} ${ext}]
	    puts "Finded [llength ${appended_files}] ${ext} files for add"
	    
	    foreach project_file ${appended_files} {
	    	if {${type} == "xdc_ucf"} { 
	    		add_files -fileset constrs_1 -norecurse ${project_file} 
	    		} else {
	    			if {[string match "*_tb.*" ${project_file}]} { 
	    				add_files -fileset sim_1 -norecurse ${project_file} 
	    				} else {
	    					add_files -fileset sources_1 -norecurse ${project_file}
	    				}
	    	}
			puts "${project_file} added"
		} 
	}
	puts "${type} files added"
	puts "==================="
}
#
puts "ALL FILES ADDED"
puts "==================="
#
# Set top file and compilation order
#
puts "SETTING TOP AND SIMS FILES"
#
set_property top ${top_file_name} [current_fileset]
puts "Set ${top_file_name} as top file"
#
set src_files [findFiles ${src_dir}/rtl "*/*_tb.*"]
for {set i 0} {$i < [llength ${src_files}]} {incr i} {
	set_property used_in_synthesis false [get_files [lindex ${src_files} $i]]
	puts "[lindex ${src_files} $i] set only for simulation"
}
#
puts "SETTING COMPLETED"
puts "==================="
#
# Regenerate cores
#
puts "CORES REGENERATION STARTED"
report_ip_status -name ip_status -quiet
#
set IpCores [get_ips]
#
for {set i 0} {$i < [llength ${IpCores}]} {incr i} {
	set IpSingle [lindex ${IpCores} $i]
	
	set locked [get_property IS_LOCKED ${IpSingle}]
	set upgrade [get_property UPGRADE_VERSIONS ${IpSingle}]
	if {${upgrade} != "" && ${locked}} {
		upgrade_ip ${IpSingle}
		puts "Core ${IpSingle} regenerated"
	}
}
#
report_ip_status -name ip_status -quiet
#
puts "CORES REGENERATED"
puts "==================="
#
# Run synthesis and implemenation
#
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
#
set_property strategy {Vivado Synthesis Defaults} [get_runs synth_1]
set_property strategy {Vivado Implementation Defaults} [get_runs impl_1]
#
if {${need_synth}} {
	puts "SYTHESIS START"
	launch_runs synth_1
	wait_on_run synth_1
	open_run synth_1 -name synth_1
	report_utilization -name utilization_1
	puts "SYTHESIS FINISHED"
	puts "==================="
}
#
if {${need_impl}} {
	if {${need_synth}} {
		puts "IMPLEMENTATION START"
		launch_runs impl_1 -to_step write_bitstream
		wait_on_run impl_1
		open_run impl_1 -name impl_1
		report_utilization -name utilization_1
		puts "IMPLEMENTATION FINISHED"
		puts "READY TO GENERATE BITSTREAM"
		puts "===================" 
	} else {
		puts "IMPLEMENTATION DOESNT START"
		puts "NEED SYNTHESIS BEFORE"
		puts "===================" 
	}
}
#
#
puts "Current directory [pwd]"
puts "BUILD PROJECT FINISHED"
#
# ========== END SCRIPT PART ==========
