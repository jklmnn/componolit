#
# Build
#

set build_components {
	core init
        drivers/timer
        drivers/nic
        drivers/vga_log
        drivers/input/spec/ps2
	server/http_filter
	server/log_terminal
	server/nic_loopback
	server/nic_router
	server/tcp_s_terminal_c
        server/terminal_s_tcp_c
}

if { $use_virtualbox == 1 } {
    append build_components {
        drivers/framebuffer/vesa
        drivers/rtc
        drivers/input/dummy
        virtualbox5
        server/rump_fs
        server/part_blk
        server/fs_log
        drivers/ahci
    }
} else {
    append build_components {
	app/lighttpd
    }
}

source ${genode_dir}/repos/base/run/platform_drv.inc
append_platform_drv_build_components

build $build_components

create_boot_directory

#
# Generate config
#

set config {
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
	<default caps="500"/>
}

append_platform_drv_config

append config {

	<start name="timer">
	    <resource name="RAM" quantum="1M"/>
	    <provides><service name="Timer"/></provides>
        </start>

        <start name="ps2_drv">
            <resource name="RAM" quantum="4M"/>
            <provides>
                <service name="Input"/>
            </provides>
        </start>
}
if { $use_virtualbox == 1 } {
    append config {
        <start name="dummy_input_drv">
            <resource name="RAM" quantum="1M"/>
            <provides>
                <service name="Input"/>
            </provides>
        </start>

        <start name="fb_drv">
            <resource name="RAM" quantum="24M"/>
            <provides>
                <service name="Framebuffer"/>
            </provides>
        </start>

        <start name="rtc_drv">
            <resource name="RAM" quantum="2M"/>
            <provides>
                <service name="Rtc"/>
            </provides>
        </start>
    }
}
append config {
        <start name="vga_log_drv">
            <resource name="RAM" quantum="2M"/>
            <provides>
                <service name="LOG"/>
            </provides>
            <route>
}
if { $use_virtualbox == 0 } {
    append config {
                <service name="Input"><child name="ps2_drv"/></service>
    }
} else {
    append config {
                <service name="Input"><child name="dummy_input_drv"/></service>
    }
}
append config {
                <any-service> <parent/> <any-child/> </any-service>
            </route>
        </start>
}

if { $use_virtualbox == 0 } {
    append config {
	<start name="lighttpd">
		<resource name="RAM" quantum="128M" />
		<config>
			<arg value="lighttpd" />
			<arg value="-f" />
			<arg value="/etc/lighttpd/lighttpd.conf" />
			<arg value="-D" />
			<vfs>
				<dir name="dev">
					<log/>
					<null/>
					<inline name="rtc">2000-01-01 00:00</inline>
				</dir>
				<dir name="etc">
					<dir name="lighttpd">
						<inline name="lighttpd.conf">
# lighttpd configuration
server.port          = 80
server.document-root = "/website"
server.event-handler = "select"
server.network-backend = "write"
index-file.names     = (
  "index.xhtml", "index.html", "index.htm", "demo.html"
)
mimetype.assign      = (
  ".html"         =>      "text/html",
  ".htm"          =>      "text/html"
)
#debug.log-request-handling = "enable"
						</inline>
					</dir>
				</dir>
				<dir name="website">
					<tar name="website.tar"/>
				</dir>
			</vfs>
			<libc stdin="/dev/null" stdout="/dev/log" stderr="/dev/log" rtc="/dev/rtc"/>
		</config>
		<route>
                        <service name="LOG"><child name="vga_log_drv"/></service>
			<service name="Nic"> <child name="hub"/> </service>
			<any-service> <parent/> <any-child/> </any-service>
		</route>
	</start>
    }
}

if { $use_virtualbox == 1 } {
    append config {
        <start name="ahci_drv">
            <resource name="RAM" quantum="16M"/>
            <provides>
                <service name="Block"/>
            </provides>
            <config>
                <!--<policy label_prefix="rump_fs" device="1" writeable="yes"/>-->
                <policy label_prefix="part_blk" device="1" writeable="yes"/>
            </config>
            <route>
                <service name="LOG"><child name="vga_log_drv"/></service>
                <any-service> <parent/> <any-child/> </any-service>
            </route>
        </start>


        <start name="part_blk">
            <resource name="RAM" quantum="16M"/>
            <provides>
                <service name="Block"/>
            </provides>
            <config use_gpt="yes">
                <policy label_prefix="rump_fs" partition="1" writeable="true"/>
            </config>
            <route>
                <service name="LOG"><child name="vga_log_drv"/></service>
                <service name="Block"><child name="ahci_drv"/></service>
                <any-service> <parent/> <any-child/> </any-service>
            </route>
        </start>

        <start name="rump_fs">
            <resource name="RAM" quantum="16M"/>
            <provides>
                <service name="File_system"/>
            </provides>
            <config fs="ext2fs">
                <policy label_prefix="virtualbox5-nova" root="/vm/" writeable="yes"/>
                <policy label_prefix="fs_log" root="/log/" writeable="yes"/>
            </config>
            <route>
                <service name="Block"><child name="part_blk"/></service>
                <service name="LOG"><child name="vga_log_drv"/></service>
                <any-service> <parent/> <any-child/> </any-service>
            </route>
        </start>

        <start name="fs_log">
            <resource name="RAM" quantum="8M"/>
            <provides>
                <service name="LOG"/>
            </provides>
            <config>
                <policy label_prefix="virtualbox5-nova" truncate="yes"/>
            </config>
            <route>
                <service name="LOG"><child name="vga_log_drv"/></service>
                <any-service> <parent/> <any-child/> </any-service>
            </route>
        </start>

        <start name="virtualbox5-nova" caps="1000">
            <resource name="RAM" quantum="3072M"/>
            <config vbox_file="debian/machine.vbox" vm_name="Debian">
                <libc stdout="/dev/log" stdin="/dev/log" rtc="/dev/rtc"/>
                <vfs>
                    <dir name="dev"><log/><rtc/><terminal/></dir>
                    <fs writeable="yes"/>
                </vfs>
            </config>
            <route>
                <service name="LOG"><child name="fs_log"/></service>
                <service name="Input"><child name="ps2_drv"/></service>
                <service name="Framebuffer"><child name="fb_drv"/></service>
                <service name="Nic"><child name="hub"/></service>
                <service name="File_system"><child name="rump_fs"/></service>
                <service name="Terminal"><child name="log_terminal"/></service>
                <any-service> <parent/> <any-child/> </any-service>
            </route>
        </start>
    }
}

append config {
	<start name="hub">
	   <binary name="nic_router"/>
		<resource name="RAM" quantum="24M"/>
		<provides><service name="Nic"/></provides>
		<config verbose="no" verbose_packets="no" verbose_domain_state="no">
}
if { $use_virtualbox == 1 } {
    append config {
			<policy label_prefix="virtualbox5-nova" domain="down"/>
    }
} else {
    append config {
			<policy label_prefix="lighttpd" domain="down"/>
    }
}
append config {
         <policy label_prefix="terminal_tcp" domain="up"/>

         <domain name="down" interface="10.0.4.254/24">
            <dhcp-server ip_first="10.0.4.1" ip_last="10.0.4.1" ip_lease_time_sec="3600"/>
            <tcp dst="10.0.3.1/24"><permit-any domain="up"/></tcp>
         </domain>

         <domain name="up" interface="10.0.3.254/24">
            <dhcp-server ip_first="10.0.3.1" ip_last="10.0.3.10" ip_lease_time_sec="3600"/>
            <tcp dst="10.0.4.1/24"><permit-any domain="down"/></tcp>
         </domain>
		</config>
		<route>
                    <service name="Nic"> <child name="nic_loopback"/> </service>
                    <service name="LOG"><child name="vga_log_drv"/></service>
                    <any-service> <parent/> <any-child/> </any-service>
		</route>
	</start>

	<start name="nic_loopback">
		<resource name="RAM" quantum="1M"/>
		<provides><service name="Nic"/></provides>
	</start>

	<start name="terminal_tcp">
		<resource name="RAM" quantum="16M"/>
		<provides>
			<service name="Terminal"/>
		</provides>
                <route>
                    <service name="LOG"><child name="vga_log_drv"/></service>
                    <service name="Nic"><child name="hub"/></service>
                    <any-service><parent/><any-child/></any-service>
                </route>
		<config server_ip="10.0.4.1" server_port="80">
			<vfs>
				<dir name="dev">
					<log/>
					<null/>
					<inline name="rtc">2000-01-01 00:00</inline>
				</dir>
			</vfs>
			<libc stdout="/dev/log" stderr="/dev/log" rtc="/dev/rtc"/>
		</config>
	</start>

	<start name="http_filter">
		<resource name="RAM" quantum="8M"/>
		<provides>
			<service name="Terminal"/>
		</provides>
		<route>
			<service name="Terminal"><child name="terminal_tcp"/></service>
			<any-service><parent/><any-child/></any-service>
		</route>
	</start>

	<start name="tcp_terminal">
		<resource name="RAM" quantum="12M"/>
		<route>
			<service name="Nic"><child name="nic_drv"/></service>
			<service name="Terminal"><child name="http_filter"/></service>
                        <service name="LOG"><child name="vga_log_drv"/></service>
			<any-service><parent/><any-child/></any-service>
		</route>

		<config>
			<vfs>
				<dir name="dev">
					<log/>
					<null/>
					<inline name="rtc">2000-01-01 00:00</inline>
				</dir>
			</vfs>
			<libc stdout="/dev/log" stderr="/dev/log" rtc="/dev/rtc"/>
		</config>
	</start>

	<start name="nic_drv">
		<binary name="} [nic_drv_binary] {"/>
		<resource name="RAM" quantum="4M"/>
		<provides><service name="Nic"/></provides>
	</start>

	<start name="log_terminal">
		<resource name="RAM" quantum="8M"/>
		<provides>
			<service name="Terminal"/>
		</provides>
	</start>

</config>}

install_config $config

#
# Boot modules
#

# generic modules
append boot_modules {
	core init
        timer } [nic_drv_binary] {
        ps2_drv
        vga_log_drv
	nic_router
	nic_loopback
	ld.lib.so
	ada.lib.so
        libc.lib.so
	lwip_legacy.lib.so
	libm.lib.so
	http_filter
	log_terminal
	tcp_terminal
        terminal_tcp
	vfs.lib.so
}

if { $use_virtualbox == 1 } {
    append boot_modules {
        rtc_drv
        dummy_input_drv
        fb_drv
        ahci_drv
        virtualbox5-nova
        rump_fs
        rump.lib.so
        rump_fs.lib.so
        part_blk
        fs_log
        libc_pipe.lib.so
        libc_terminal.lib.so
        libiconv.lib.so
        pthread.lib.so
        qemu-usb.lib.so
        stdcxx.lib.so
    }
} else {
    append boot_modules {
	lighttpd
	website.tar
	posix.lib.so
	zlib.lib.so
    }
}

# Copy website
exec tar cfv bin/website.tar -C ${genode_dir}/repos/componolit/demo/wind_turbine_hmi demo.html style.css script.js

# platform-specific modules
lappend_if [have_spec linux] boot_modules fb_sdl

append_platform_drv_boot_modules

build_boot_image $boot_modules


append_if [have_spec x86]     qemu_args " -net nic,model=e1000 "
append_if [have_spec lan9118] qemu_args " -net nic,model=lan9118 "

append qemu_args " -net user -redir tcp:5555::80 -m 4096"
append qemu_args " -serial mon:stdio -cpu phenom"
append qemu_args " -device ahci,id=ahci -drive id=disk,file=bin/genode.img,format=raw,if=none -device ide-hd,drive=disk,bus=ahci.1 "

run_genode_until forever