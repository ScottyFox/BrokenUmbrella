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
	case 6://Client Used Skill
	Lib.println("client used action. x:" + Math.floor(client.position.x) + " y:" + Math.floor(client.position.y));
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
	case 4://Chat Message
	var IND:Int = 5;
	var LEG:Int = 0;
	var msg:String = "";
	while (Signal_BYTES.get(IND) != 0)
	{
	LEG++;
	IND++;
	}
	var msg:String = Signal_BYTES.getString(5, LEG);
	var k:Array<String> = msg.split(": ");
	if (k.length != 1)
	{
	trace(k);
	var c:Array<String> = k[1].split(" ");
	var id:String = StringTools.hex(Std.random(50),2).toLowerCase();
	trace(id);
	if (c[0] == "spawn")
	{
	SPAWN_CLASSIC(serv,client,5,2,Std.parseInt(c[1]),client.position.x,client.position.y,true,0,64);
	}else if (c[0] == "room")
	{
	serv.sendBytes(client.socket, HexTools.bitedecode("DEC0ADDE0C0000003A0000001200000000000000000000000000000000"+HexTools.Float2Double(Std.parseFloat(c[1]))+"0000000000007F4000000000000000400000000000007F40000000000000004001"));
	}
	/*else if (c[0] == "item")
	{//6076
	var it:String = Float2Double(Std.parseFloat(c[1]));
	var ix:String = Float2Double(CLIENTINFO.pos.x);
	var iy:String = Float2Double(CLIENTINFO.pos.y);
	trace(it);
	//Sys.sleep(1000);
	flushBytes(CLIENTINFO.s);
	sendBytes(CLIENTINFO.s, bitedecode("DEC0ADDE0C000000210000000C0000000000" + it + "40000000000000264000000080FB"+ix+"400000004090"+iy+"40"));
	sendBytes(CLIENTINFO.s, bitedecode("DEC0ADDE0C00000021000000190000000000" + it + "40000000000000264000000000000008400000000000000000"));
	}else if (c[0] == "respawn")
	{
	//Sys.sleep(1000);
	flushBytes(CLIENTINFO.s);
	sendBytes(CLIENTINFO.s, bitedecode("DEC0ADDE0C0000003A000000120000000000000000000000000000000000000000000032400000000000007F400000000000A0744000000000004087400000000000C0984000"));
	sendBytes(CLIENTINFO.s, bitedecode("DEC0ADDE0C000000210000000C00000000008055400000000000002440000000000090A0400000000000008340"));
	}else if (c[0] == "spawnboss")
	{
	//SPAWN_CLASSIC(CLIENTINFO, 5, 2, Std.parseInt(c[1]), 600, 330, true, 0, 64);
	SPAWN_BOSS(CLIENTINFO, Std.parseFloat(c[1]), 2, CLIENTINFO.pos.x,CLIENTINFO.pos.y, true, 0);
	}	*/
	
	}
	trace(msg);
	default:
	Lib.println("error pack:"+packetid+" sig:"+signalid);
	}
	}
	
	static public function SPAWN_CLASSIC( s:Server , c :RoRClient, o_id:Float, m_id:Float, card:Int, x:Float, y:Float, isElite:Bool, tier:Int, points:Int ):Void
	{
	var a_o_ind:String = HexTools.Float2Double(o_id);
	var a_m_ind:String = HexTools.Float2Double(m_id);
	var a_card:String = StringTools.hex(card,2);
	var a_x:String = HexTools.Float2Double(x);
	var a_y:String = HexTools.Float2Double(y);
	var a_bool:String = null;
	if (isElite) { a_bool = "01"; } else { a_bool = "00"; }
	var a_t:String = StringTools.hex(tier,2);
	var a_p:String = StringTools.hex(points,2);
	var ms:String = "DEC0ADDE0C0000002A0000000F" + a_o_ind  + a_m_ind + a_card + "00" + a_x + a_y + a_bool + a_t + "00" + a_p + "000100";
	Lib.println(ms);
	s.sendBytes(c.socket, HexTools.bitedecode(ms));
	}
	
}