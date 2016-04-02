package;
import items.Ibuff;
import sys.net.Socket;
import utils.V2D;

/**
 * ...
 * @author TSLF
 */
class RoRClient
{
	public var socket:Socket;
	public var name:String;
	public var connected:Bool = false;
	public var inlobby:Bool = true;
	public var position:V2D = new V2D();
	public var ItemBuffs:Array<Ibuff> = new Array<Ibuff>();
	public var ind:Int;
	public var isServer:Bool = false;
	
	public var t_debug:Bool = false;
	public var t_servtime:Int = 0;
	public var t_oldpos:V2D = new V2D();
	//public var SkillBuffs:Array<Ibuff> = new Array<Ibuff>();//TO-DO//
	
	public function new(i:Int) 
	{
	ind = i;
	}
	
}