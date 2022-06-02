compile_protos:
	protoc --proto_path=./protos --elixir_out=./lib protos/logproto.proto
