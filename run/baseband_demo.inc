#
# \brief  Virtualized Android on Yoga 900
# \author Alexander Senier
# \date   2016-09-17
#

set build_components {
	app/backdrop
	app/vbox_pointer
	core init
	drivers/framebuffer
	drivers/input
	drivers/rtc
	drivers/timer
	drivers/usb
	server/input_merger
	server/log_tee
	server/nic_bridge
	server/nit_fb
	server/nitpicker
	server/part_blk
	server/report_rom
	server/rump_fs
	server/terminal
	server/terminal_log
	virtualbox5
	server/baseband_firewall
}

if [have_spec uefi] {
	set fb_binary "fb_boot_drv"
} else {
	set fb_binary "fb_drv"
}

source ${genode_dir}/repos/base/run/platform_drv.inc

# Taken from repos/ports/run/virtualbox.run
# override defaults of platform_drv.inc --- Why?
proc platform_drv_priority {} { return { priority="-1"} }

append_platform_drv_build_components

build $build_components

create_boot_directory

#
# Generate config
#

append config {
<config>
	<parent-provides>
		<service name="ROM"/>
		<service name="IRQ"/>
		<service name="IO_MEM"/>
		<service name="IO_PORT"/>
		<service name="PD"/>
		<service name="RM"/>
		<service name="CPU"/>
		<service name="LOG"/>
	</parent-provides>
	<default-route>
		<any-service> <parent/> <any-child/> </any-service>
	</default-route>
	<default caps="100"/>
}

append_platform_drv_config

append config {

	<start name="ps2_drv">
		<resource name="RAM" quantum="1M"/>
		<provides><service name="Input"/></provides>
	</start>

	<start name="usb_devices">
		<binary name="report_rom"/>
		<resource name="RAM" quantum="1M"/>
		<provides> <service name="Report"/> <service name="ROM"/> </provides>
		<config verbose="yes">
			<default-policy report="usb_drv -> devices"/>
		</config>
	</start>

	<start name="usb_drv" caps="120">
		<resource name="RAM" quantum="64M"/>
		<provides>
			<service name="Input"/>
			<service name="Block"/>
			<service name="Nic"/>
		</provides>
		<config ehci="yes" uhci="yes" ohci="yes" xhci="yes">
			<storage/>
			<nic mac="02:00:00:00:01:01" />
			<hid>
}

append config "<touchscreen width=\"$screen_width\" height=\"$screen_height\" multitouch=\"yes\"/>"

append config {
			</hid>
		</config>
		<route>
			<!--<service name="LOG"><child name="terminal_log"/></service>-->
			<service name="Report"> <child name="usb_devices"/> </service>
			<any-service> <parent/> <any-child/> </any-service>
		</route>
	</start>

	<start name="input_merger">
		<resource name="RAM" quantum="1M" />
		<provides> <service name="Input" /> </provides>
		<config>
			<input label="ps2" />
			<input label="usb" />
		</config>
		<route>
			<service name="Input" label="ps2"> <child name="ps2_drv" /> </service>
			<service name="Input" label="usb"> <child name="usb_drv" /> </service>
			<any-service> <parent/> </any-service>
		</route>
	</start>

	<start name="fb_drv">
}
		append config "<binary name=\"$fb_binary\"/>"

append config {
		<resource name="RAM" quantum="16M"/>
		<provides>
			<service name="Framebuffer"/>
		</provides>
	</start>

	<start name="timer">
		<resource name="RAM" quantum="1M"/>
		<provides><service name="Timer"/></provides>
	</start>

	<start name="nit_report">
		<binary name="report_rom"/>
		<resource name="RAM" quantum="2M"/>
		<provides> <service name="Report"/> <service name="ROM"/> </provides>
		<config verbose="yes">
			<policy label="vbox_pointer -> hover"               report="nitpicker -> hover"/>
			<policy label="vbox_pointer -> xray"                report="nitpicker -> xray"/>
			<policy label="vbox_pointer -> shape1"              report="android -> shape"/>
		</config>
	</start>

	<start name="nitpicker">
		<resource name="RAM" quantum="1M"/>
		<provides><service name="Nitpicker"/></provides>
		<config>
			<domain name="pointer" layer="1" origin="pointer" content="client" label="no"/>
			<domain name="default" layer="2" content="client" label="no" focus="click" hover="always" />
			<policy label_prefix="vbox_pointer" domain="pointer"/>
			<default-policy domain="default"/>
		</config>
		<route>
			<service name="Input"> <child name="input_merger" /> </service>
			<service name="Framebuffer"> <child name="fb_drv" /> </service>
			<service name="Report"> <child name="nit_report" /> </service>
			<any-service> <parent/> <any-child/> </any-service>
		</route>
	</start>
}

append_if [expr $use_pointer] config {
	<start name="vbox_pointer" priority="-1">
		<resource name="RAM" quantum="2M"/>
		<config>
			<policy label="vm_fb" rom="shape1"/>
		</config>
		<route>
			<service name="Nitpicker"> <child name="nitpicker"/>  </service>
			<service name="ROM" label="shape1"> <child name="nit_report"/> </service>
			<service name="ROM" label="hover"> <child name="nit_report"/> </service>
			<service name="ROM" label="xray"> <child name="nit_report"/> </service>
			<any-service> <parent/> </any-service>
		</route>
	</start>
}

append config {
	<start name="terminal_fb">
		<binary name="nit_fb"/>
		<resource name="RAM" quantum="16M"/>
		<provides>
			<service name="Framebuffer"/>
			<service name="Input"/>
		</provides>
}

append config "<config xpos=\"$terminal_xpos\" ypos=\"$terminal_ypos\" width=\"$terminal_width\" height=\"$terminal_height\" refresh_rate=\"25\"/>"

append config {
	</start>

	<start name="terminal">
		<resource name="RAM" quantum="3M"/>
		<provides><service name="Terminal"/></provides>
		<config>
			<!-- supported built-in font sizes are 8, 12, 16, 24 and 36 -->
			<font size="36" />
		</config>
		<route>
			<service name="Input"> <child name="terminal_fb"/> </service>
			<service name="Framebuffer"> <child name="terminal_fb"/> </service>
			<any-service> <parent/> <any-child/></any-service>
		</route>
	</start>

	<start name="terminal_log">
		<resource name="RAM" quantum="1M"/>
		<provides><service name="LOG"/></provides>
	</start>

	<start name="log_tee">
		<resource name="RAM" quantum="2M"/>
		<provides> <service name="LOG"/> </provides>
		<route>
			<service name="LOG"> <child name="terminal_log"/> </service>
			<any-service> <parent/> <any-child/></any-service>
		</route>
	</start>

	<alias name="logger" child="terminal_log"/>

	<start name="rtc_drv">
		<resource name="RAM" quantum="1M"/>
		<provides> <service name="Rtc"/> </provides>
		<route>
			<service name="LOG"> <child name="logger"/> </service>
			<any-service> <parent/> <any-child/></any-service>
		</route>
	</start>

	<start name="partition_report">
		<binary name="report_rom"/>
		<resource name="RAM" quantum="5M" />
		<provides>
			<service name="Report"/>
			<service name="ROM"/>
		</provides>
		<config verbose="yes"/>
		<route>
			<service name="LOG"> <child name="logger"/> </service>
			<any-service> <parent/> <any-child/> </any-service>
		</route>
	</start>

	<start name="part_blk">
		<resource name="RAM" quantum="10M" />
		<provides><service name="Block" /></provides>
		<config use_gpt="yes">
			<report partitions="yes"/>
			<policy label_prefix="data_fs" partition="2" writeable="true" />
		</config>
		<route>
			<service name="Block"> <child name="usb_drv"/> </service>
			<service name="Report"> <child name="partition_report" /> </service>
			<service name="LOG"> <child name="logger"/> </service>
			<any-service> <parent/> <any-child/> </any-service>
		</route>
	</start>

	<start name="data_fs" caps="200">
		<binary name="rump_fs"/>
		<resource name="RAM" quantum="8M" />
		<provides>
			<service name="File_system"/>
		</provides>
		<config fs="ext2fs">
			<policy label_prefix="android" root="/" writeable="yes"/>
			<policy label_prefix="backdrop" root="/images" writeable="no"/>
		</config>
		<route>
			<service name="Block"> <child name="part_blk"/> </service>
			<service name="LOG"> <child name="logger"/> </service>
			<any-service> <parent/> <any-child/> </any-service>
		</route>
	</start>

	<start name="backdrop" priority="-1">
		<resource name="RAM" quantum="128M"/>
		<config>
			<libc/>
			<vfs>
				<dir name="demo"> <fs/> </dir>
				<rom name="background.png"/>
			</vfs>
			<fill color="#ffffff" />
			<image png="background.png" anchor="top_left" alpha="255" xpos="0" ypos="0" />
		</config>
		<route>
			<service name="LOG"> <child name="logger"/> </service>
			<service name="Filesystem"> <child name="data_fs" /> </service>
			<service name="Nitpicker"> <child name="nitpicker" label="backdrop" /> </service>
			<any-service> <parent/> <any-child/> </any-service>
		</route>
	</start>


	<start name="vm_fb">
		<binary name="nit_fb"/>
		<resource name="RAM" quantum="16M"/>
		<provides>
			<service name="Framebuffer"/>
			<service name="Input"/>
		</provides>
}

append config "<config xpos=\"$vm_xpos\" ypos=\"$vm_ypos\" width=\"$vm_width\" height=\"$vm_height\" refresh_rate=\"25\"/>"

append config {
		<route>
			<service name="LOG"> <child name="logger"/> </service>
			<any-service> <parent/> <any-child/> </any-service>
		</route>
	</start>

	<start name="baseband-fw" priority="-1">
		<resource name="RAM" quantum="16M"/>
		<provides><service name="Nic"/></provides>
		<config uplink="bp" downlink="ap"/>
		<route>
			<service name="Nic"><child name="usb_drv"/></service>
			<service name="LOG"><child name="logger"/></service>
			<any-service><parent/><any-child/></any-service>
		</route>
	</start>
	<alias name="nic_srv" child="baseband-fw"/>

	<start name="android" caps="500">
		<binary name="virtualbox5-nova"/>
		<resource name="RAM" quantum="2500M"/>
		<config vbox_file="vm/android.vbox" vm_name="Android">
			<libc stdout="/dev/log" stderr="/dev/log" rtc="/dev/rtc"/>
			<vfs>
				<dir name="dev"> <log/> <rtc/> </dir>
				<dir name="dev"> <terminal/> </dir>
				<dir name="vm"> <fs/> </dir>
			</vfs>
		</config>
		<route>
			<service name="Framebuffer"> <child name="vm_fb" /> </service>
			<service name="Input"> <child name="vm_fb" /> </service>
			<service name="Filesystem"> <child name="data_fs" /> </service>
			<service name="LOG"> <child name="logger"/> </service>
			<service name="Report"> <child name="nit_report"/> </service>
			<service name="Nic"> <child name="nic_srv"/> </service>
			<any-service> <parent /> <any-child /> </any-service>
		</route>
	</start>

</config>
}

install_config $config

#
# Boot modules
#

# Copy background image
exec cp [genode_dir]/repos/componolit/doc/img/baseband_demo_bg-${screen_width}x${screen_height}.png bin/background.png

# generic modules
set boot_modules {
	backdrop
	background.png
	core
	fb_boot_drv
	fb_drv
	init
	input_merger
	ld.lib.so
	libc.lib.so
	libc_pipe.lib.so
	libc_terminal.lib.so
	libiconv.lib.so
	libm.lib.so
	libpng.lib.so
	log_tee
	nic_bridge
	nit_fb
	nitpicker
	part_blk
	ps2_drv
	pthread.lib.so
	qemu-usb.lib.so
	report_rom
	rtc_drv
	rump_fs
	rump_fs.lib.so
	rump.lib.so
	stdcxx.lib.so
	terminal
	terminal_log
	timer
	usb_drv
	vbox_pointer
	virtualbox5-nova
	zlib.lib.so
	baseband-fw
}

append_platform_drv_boot_modules

build_boot_image $boot_modules
