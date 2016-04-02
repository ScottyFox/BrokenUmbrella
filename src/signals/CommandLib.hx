package signals;
import haxe.io.Bytes;
import neko.Lib;
import oflmimic.utils.Object;
import utils.HexTools;

/**
 * ...
 * @author TSLF
 */
class CommandLib
{
	public static function CMD2EV(inpt:String,serv:Server):Void//return Object if Buffer Event
	{
	var split:Array<String> = inpt.split(" ");
	switch split[0]
	{
    case "time":
	Lib.println("Server time ("+ Std.string(serv.ServerTime) +")");
    default:
	Lib.println("UNKNOWN COMMAND '"+split[0]+"'");
	}
	}
	public static function CLISIG(inpt:String,client:RoRClient,party:Party,serv:Server):Void
	{
	var Signal_BYTES:Bytes = HexTools.bitedecode(inpt);
	var signalid:Int = Signal_BYTES.get(0);
	var packetid:Int = Signal_BYTES.get(4);
	switch packetid
	{
	case 5://CLIENT JOINING//
	var INF:Array<String> = inpt.split(StringTools.hex(signalid,2).toLowerCase()+"00000005")[1].split("7c00");
	var DATA:String = INF[0].substring(0, 40);
	var DATAb:Bytes = HexTools.bitedecode(DATA);
	var dataint:Int = DATAb.get(0);
	trace("data num : " + dataint);
	if (dataint == 255)
	{
	var CLIENTNAME:String = HexTools.hex2str(inpt.split(DATA)[1].split("7c00")[0]);
	client.name = CLIENTNAME;
	Lib.println("Client name set : " + CLIENTNAME);
	}else if (dataint >= 0 && dataint <= 11)
	{
	Lib.println("Client has Choosen the survivor : " + dataint);
	serv.sendBytes(client.socket, HexTools.bitedecode("DEC0ADDE0C0000003A000000120000000000000000000000000000000000000000000032400000000000007F400000000000A074400000000000007F400000000000A0744001"));
	//serv.sendBytes(client.socket, HexTools.bitedecode("DEC0ADDE0C000000210000000C0000000000"+"3076"+"40000000000000264000000080FB007F400000004090A07440"+"DEC0ADDE0C00000021000000190000000000"+"3076"+"40000000000000264000000000000008400000000000000000"));
	//sendBytes(CLIENTINFO.s, bitedecode("DEC0ADDE0C000000210000000C0000000000f07b4000000000000024400000000000007F400000000000A07440"));
	}
	case 16	://REQUEST_REGULAR_PING
	if (signalid == 2)
	{//FIRST REQUEST//
	Lib.println("Client's First Ping");
	serv.sendBytes(client.socket, HexTools.bitedecode("DEC0ADDE0C00000012000000100000000000406A40000000000000084000"));
	}else{
	serv.sendBytes(client.socket, HexTools.CBytes([ClLib.Cl_PING, HexTools.bitedecode(HexTools.str2hex("1ms") + "00")]));
    }
	case 0://PositionData
	var x:String = inpt.substring(10,26);
	var y:String = inpt.substring(26, 42);

	client.t_oldpos.x = client.position.x;
	client.t_oldpos.y = client.position.y;
	client.position.x = HexTools.HexD2Float(x);
	client.position.y = HexTools.HexD2Float(y);
	
	if (client.t_debug)
	{
	Lib.println("client moved x:" + client.position.x + " y:" + client.position.y);
	if (client.t_servtime != 0)
	{
	Lib.println("Distance Traveled "+Std.string((client.position.x - client.t_oldpos.x) / (serv.ServerTime-client.t_servtime))+":"+Std.string((client.position.y - client.t_oldpos.y) / (serv.ServerTime-client.t_servtime)));
	}
	client.t_servtime = serv.ServerTime;
	}
	
	default:
	Lib.println("error pack:"+packetid+" sig:"+signalid);
	}
	}
}