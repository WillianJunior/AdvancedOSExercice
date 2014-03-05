all: main display clock tempConv sensor

main: main.erl
	erlc main.erl

display: display.erl
	erlc display.erl

clock: clock.erl
	erlc clock.erl

tempConv: tempConv.erl
	erlc tempConv.erl

sensor: sensor.erl
	erlc sensor.erl

clean:
	rm *.beam