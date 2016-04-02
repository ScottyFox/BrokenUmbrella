package rooms;

/**
 * ...
 * @author TSLF
 */
class RoomController
{
	private var _servref:Server;
	private var _party:Int;
	public var currentMap:Float = 0;
	public var isActive:Bool = false;
	
	public function new(main:Server,partyind:Int):Void 
	{
	_servref = main;//reference to main class//
	_party = partyind;
	}
	
	public function update():Void
	{
		
	}
	
	public function setMap(f:Float):Void
	{
	
	}
}