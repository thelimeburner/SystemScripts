
CC=go
GOBUILD=$(CC) build

all: server client
	
	
server:
	$(GOBUILD) server.go

client: 
	$(GOBUILD) client.go


clean:
	rm -rf server client

serve:
	./server

test:
	./client
