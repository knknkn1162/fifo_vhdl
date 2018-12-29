GHDLC=ghdl
PROJECT_NAME=instr
WORKDIR=..
WAVEDIR=${WORKDIR}/wave
FLAGS=--work=${PROJECT_NAME} --workdir=${WORKDIR}/
#TB_OPTION=--assert-level=error
MODULES=\
	counter \
	bicounter \
	port1_ram \
	fifo
TESTS=
OBJS=$(addsuffix .o, ${MODULES})
TESTBENCHES=$(addsuffix _tb, ${TESTS})

.PHONY: all

all: $(OBJS) $(TESTBENCHES)

%_tb: %_tb.o %.o
	$(GHDLC) -e $(FLAGS) $@
	$(GHDLC) -r ${FLAGS} $@ --vcd=${WAVEDIR}/out_$@.vcd ${TB_OPTION}

%: %.o
	# do nothing

%.o: %.vhdl
	$(GHDLC) -a $(FLAGS) $<
