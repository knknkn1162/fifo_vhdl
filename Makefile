GHDLC=ghdl
PROJECT_NAME=work
WORKDIR=.
WAVEDIR=${WORKDIR}/wave
FLAGS=--work=${PROJECT_NAME} --workdir=${WORKDIR}/
#TB_OPTION=--assert-level=error
MODULES=\
	counter \
	gray_counter \
	bicounter \
	port1_ram \
	sync_fifo \
	fifo
TESTS=\
	gray_counter
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
