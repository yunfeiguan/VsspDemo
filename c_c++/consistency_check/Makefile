consistency_check:consistency_check.o network.o thread.o time.o
	g++ consistency_check.o network.o thread.o time.o  -o consistency_check -lpthread

consistency_check.o:consistency_check.cc io_write_read.h network.h thread.h time.h
	g++ -c consistency_check.cc -o consistency_check.o 

time.o:time.cc time.h
	g++ -c time.cc -o time.o
network.o:network.cc thread.h
	g++ -c network.cc -o network.o

thread.o:thread.cc
	g++ -c thread.cc -o thread.o 

clean:
	rm -rf *.o consistency_check

#c++ write_read_sync.cc network.cc thread.cc -lpthread -o write_read_sync

