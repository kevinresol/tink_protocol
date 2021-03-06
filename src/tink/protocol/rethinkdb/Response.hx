package tink.protocol.rethinkdb;

import haxe.Int64;
import haxe.io.Bytes;

@:forward
abstract Response(ResponseBase) from ResponseBase to ResponseBase {
	@:from
	public static function fromBytes(bytes:Bytes):Response {
		var token = Int64.make(bytes.getInt32(0), bytes.getInt32(4));
		var json = bytes.sub(12, bytes.length - 12).toString();
		return new ResponseBase(token, json);
	}
}

class ResponseBase {
	public var token:Int64;
	public var json:String;
	public function new(token, json) {
		this.token = token;
		this.json = json;
	}
}
@:enum
abstract ResponseType(Int) from Int {
	var SUCCESS_ATOM = 1;
	var SUCCESS_SEQUENCE = 2;
	var SUCCESS_PARTIAL = 3;
	var WAIT_COMPLETE = 4;
	var SERVER_INFO = 5;
	var CLIENT_ERROR = 16;
	var COMPILE_ERROR = 17;
	var RUNTIME_ERROR = 18;
}

@:enum
abstract ErrorType(Int) from Int {
	var INTERNAL = 1000000;
	var RESOURCE_LIMIT = 2000000;
	var QUERY_LOGIC = 3000000;
	var NON_EXISTENCE = 3100000;
	var OP_FAILED = 4100000;
	var OP_INDETERMINATE = 4200000;
	var USER = 5000000;
	var PERMISSION_ERROR = 6000000;
}

@:enum
abstract ResponseNote(Int) from Int {
	var SEQUENCE_FEED = 1;
	var ATOM_FEED = 2;
	var ORDER_BY_LIMIT_FEED = 3;
	var UNIONED_FEED = 4;
	var INCLUDES_STATES = 5;
}