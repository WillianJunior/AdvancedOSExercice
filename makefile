CFLAGS = -Wall

all: build run

run:
	erl -pa ebin

build: main display clock tempConv sensor

main: src/main.erl
	erlc $(CFLAGS) -o ebin src/main.erl

display: src/display.erl
	erlc $(CFLAGS) -o ebin src/display.erl

clock: src/clock.erl
	erlc $(CFLAGS) -o ebin src/clock.erl

tempConv: src/tempConv.erl
	erlc $(CFLAGS) -o ebin src/tempConv.erl

sensor: src/sensor.erl
	erlc $(CFLAGS) -o ebin src/sensor.erl

clean:
	rm ebin/*