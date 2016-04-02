package;
import haxe.io.Bytes;
import neko.Lib;
import neko.net.ThreadServer;
import oflmimic.utils.Object;
import signals.ClLib;
import signals.CommandLib;
import sys.net.Socket;
import utils.HexTools;

typedef Client = {
  var id : Int;
}

typedef Message = {
  var str : String;
}

typedef Room = {
  var CurrentMap :Bytes; //Double Bytes
}

class Server extends ThreadServer<Client, Message>
{
	public var CommandL : neko.vm.Thread;
	public var ServerTime : Int = 0;
	public static var max_clients:Int = 9;
	public static var serverisClient:Bool = true;
	//TO-DO// public var Parties:Array<Party> = new Array<Party>(); // Multiple Rooms at once 
	public var TestParty:Party = new Party(3);
	
	public static function main()
	{
		var server = new Server();
		 Lib.println("Risk of Rain Server!");
		 Lib.println("Running at ~60FPS");
		 server.run("192.168.1.2", 11100);//127.0.0.1//
	}
	override function update():Void
	{
	ServerTime++;
	}
	
 	function runCMD() 
	{
	while ( true ) 
	{
	CommandLib.CMD2EV(Sys.stdin().readLine(), this);
	}
	}
	
 	override function runTimer() 
		{
		CommandL = neko.vm.Thread.create(runCMD);
		var l = new neko.vm.Lock();
		while ( true ) {
			l.wait(1 / 60);
			work(update);
		}
		}
		
	override function clientConnected( s : Socket ) : Client
	{
	var CLIENT:RoRClient = TestParty.getAvailable();
	var num = null;
	if (CLIENT != null)
	{
	num = 100+CLIENT.ind;
    Lib.println("Client index :" + CLIENT.ind );
	CLIENT.socket = s;
	sendBytes(CLIENT.socket, ClLib.GM_HANDSHAKE);
	}else
	{
	Lib.println("Party is Full");
	}
	return { id: num };
	}
	
	override function clientDisconnected( c : Client )
	{
	if (c.id != null)
	{
	var CLPRinfo:Object  = Party.getClientParty(c.id);
	var CLIENT:RoRClient = TestParty.getClient(CLPRinfo.client);
	CLIENT.connected = false;
	CLIENT.socket = null;
    }
	Lib.println("client " + Std.string(c.id) + " disconnected");
	}
  

	override function readClientMessage(c:Client, buf:Bytes, pos:Int, len:Int)
	{
	var CLPRinfo:Object  = Party.getClientParty(c.id);
	var PARTY:Party = TestParty;
	var CLIENT:RoRClient = TestParty.getClient(CLPRinfo.client);
	if (buf.toHex().substring(0, 18) == "bebafeca0bb0adde10")
	{
	var HANDSHAKE:Bytes = HexTools.bitedecode("adbeafdeebbe0df00c000000");
	sendBytes(CLIENT.socket, HANDSHAKE);
	sendBytes(CLIENT.socket, ClLib.Cl_VERSION);
	sendBytes(CLIENT.socket, ClLib.Cl_NEWCLIENT);//002E < id
	sendBytes(CLIENT.socket, ClLib.Cl_SERVERCLIENTEXISTS);
	Lib.println("Client Handshake p:"+CLPRinfo.party+" c:"+CLPRinfo.client);
	} else {
	var Signals:Array<String> = buf.toHex().split(ClLib.Cl_FOOTER);
	if (Signals.length > 1)
	{
	for (i in 1... Signals.length)
	{
	CommandLib.CLISIG(Signals[i],CLIENT,PARTY, this);
	}
	}
	}
	return {msg: {str: buf.toString()}, bytes: pos+len};
	}

  override function clientMessage( c : Client, msg : Message )
  {
  //  Lib.println(c.id + " sent: " + msg.str);
  }
	
	//WILL MAKE A BUFFER-TYPE SYSTEM TO WHERE CLIENT WILL ONLY GET PINGED AFTER THE MATTER TO AVOID ERROR//
	public function sendBytes( s : sys.net.Socket, bytes:Bytes ) 
	{
		try {
	s.output.writeBytes(bytes,0,bytes.length);
	s.output.flush();
		} catch( e : Dynamic ) {
			stopClient(s);
		}
	}
}