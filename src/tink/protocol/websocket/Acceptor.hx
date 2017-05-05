package tink.protocol.websocket;

import tink.streams.Accumulator;
import tink.streams.Stream;
import tink.streams.IdealStream;
import tink.streams.RealStream;
import tink.io.StreamParser;
import tink.Url;
import tink.Chunk;

using tink.CoreApi;
using tink.io.Source;

class Acceptor {
	public static function wrap(handler:tink.protocol.Handler, ?onError:Error->Void):tink.tcp.Handler {
		if(onError == null) onError = function(e) trace(e);
		
		return function(i:tink.tcp.Incoming):Future<tink.tcp.Outgoing> {
			var trigger:SignalTrigger<Yield<Chunk, Noise>> = Signal.trigger();
			var outgoing = {
				stream: new SignalStream(trigger.asSignal()),
				allowHalfOpen: true,
			}
			
			i.stream.parse(IncomingHandshakeRequestHeader.parser())
				.handle(function(o) switch o {
					case Success({a: header, b: rest}):
						switch header.validate() {
							case Success(_): // ok
							case Failure(e): onError(e);
						}
						var reponseHeader = new OutgoingHandshakeResponseHeader(header.key);
						trigger.trigger(Data(@:privateAccess Chunk.ofString(reponseHeader.toString())));
						
						// outgoing
						var send = handler(rest.parseStream(new Parser()));
						send.forEach(function(chunk) {
							trigger.trigger(Data(chunk));
							return Resume;
						}).handle(function(_) trigger.trigger(End));
					case Failure(e):
						onError(e);
				});
			return Future.sync(outgoing);
		}
	}
}

