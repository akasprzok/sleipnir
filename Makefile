compile_protos:
	protoc --proto_path=./protos --elixir_opt=include_docs=true --elixir_out=./lib protos/logproto.proto
	protoc --proto_path=./protos --elixir_opt=include_docs=true --elixir_out=./lib protos/timestamp.proto
