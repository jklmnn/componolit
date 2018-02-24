ifeq ($(ANDROID_SOURCE),)
$(error "Please set ANDROID_SOURCE to AOSP tree")
endif

all: HelloWorld.art

%.class: %.java
	javac -source 1.6 -target 1.6 -cp . $<

%.jar: Manifest %.class
	jar cfm $@ $^

%.run: %.jar
	java -jar $< $*

%.dex: %.jar
	$(ANDROID_SOURCE)/prebuilts/sdk/tools/dx --dex --output $@ $<

%.art: %.dex
	env -i /bin/bash $(ANDROID_SOURCE)/out/host/linux-x86/bin/art $(ART_ARGS) -classpath $< $*

clean:
	rm -f *.jar *.class *.dex *.strace *.ltrace
