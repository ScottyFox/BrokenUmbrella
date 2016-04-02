package rooms;
import utils.V2D;

/**
 * ...
 * @author TSLF
 */
class Renemy
{
	public var enemy_type:String;
	public var m_id:Float;
	public var is_elite:Bool;
	public var elite_type:Int;
	public var position:V2D;
	public var maxHealth:Int;
	public var currentHealth:Int;
	public function new(POSITION:V2D, M_ID:Float, IS_ELITE:Bool, ELITE_TYPE:Int = 0,O_ID:Float) 
	{
	position = POSITION;
	m_id = M_ID;
	is_elite = IS_ELITE;
	elite_type = ELITE_TYPE;
	}
	
}