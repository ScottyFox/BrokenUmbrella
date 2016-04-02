package;
import haxe.Json;
import neko.Lib;
import oflmimic.utils.Object;
import rooms.RoomController;

/**
 * ...
 * @author TSLF
 */
class Party
{
	public var Clients:Array<RoRClient> = new Array<RoRClient>();
	public var maxPlayers:Int;
	public var world:RoomController;
	public var inLobby:Bool = true;
	public var currentMap:Float = 0;
	
	public function new(maxplay:Int) 
	{
	for (i in 0... maxplay)
	{
	var cl:RoRClient = new RoRClient(i);
	Clients.push(cl);
	}
	}
	
	public function setupworld(serverref:Server, partyind:Int):Void
	{
	world = new RoomController(serverref, partyind);
	}
	
	public function getClient(ind:Int):RoRClient
	{
	return Clients[ind];
	}
	
	public function getAvailable():RoRClient
	{
	var client:RoRClient = null;
	var i:Int = 0;
	while (i < Clients.length)
	{
	if (!Clients[i].connected)
	{
	client = Clients[i];
	i = Clients.length;
	}
	i++;
	}
	return client;
	}
	
	public static function getClientParty(ID:Int):Object
	{
	var partyid:Int = Math.floor(ID / 100);
	var clientid:Int = ID - (partyid*100);
	return { "party":partyid, "client":clientid };
	}
}