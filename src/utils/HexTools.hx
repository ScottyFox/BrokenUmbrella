package utils;
import haxe.crypto.BaseCode;
import haxe.io.Bytes;
import haxe.io.BytesData;
import neko.NativeString;

/**
 * ...
 * @author TSLF
 */
class HexTools
{
	//Converts String into Hex String//
	static public function str2hex(str:String):String
	{
	return Bytes.ofString(str).toHex();
	}
	
	//Converts Hex String into String//
	static public function hex2str(str:String):String
	{
	return bitedecode(str).toString();
	}
	
	//Converts String into Bytes//
	static public function str2bytes(str:String):Bytes
	{
	return Bytes.ofString(str);
	}
	
	//Converts Hex String(Double) into (Float)//
	static public function HexD2Float(d:String):Float
	{
	var b:Bytes = bitedecode(d);
	return b.getDouble(0);
	}
	
	//Converts Double(Float) into Hex String//
	static public function Float2Double(fl:Float):String
	{
	var dt:Bytes = Bytes.alloc(8);
	dt.setDouble(0, fl);
	return dt.toHex();
	}
	
	//Converts Double(Float) into Bytes//
	static public function Float2Bytes(fl:Float):Bytes
	{
	var dt:Bytes = Bytes.alloc(8);
	dt.setDouble(0, fl);
	return dt;
	}
	
	//Combines Multiple Bytes into a Single Bytes//
	static public function CBytes(l:Array<Bytes>):Bytes
	{
	if (l.length == 1)
	{
	return l[0];
	}else if (l.length > 1)
	{
	
	var mlength:Int = 0;
	var i:Int;
	var j:Int;
	for (i in 0... l.length)
	{
	mlength += l[i].length;
	}
	var nb:Bytes = Bytes.alloc(mlength);
	var pos:Int = 0;
	for (i in 0... l.length)
	{
	for (j in 0... l[i].length)
	{
	nb.set(pos, l[i].get(j));
	pos += 1;
	}
	//pos += l[i].length;
	}
	return nb;
	}
	return null;
	}
	
	//Converts Hex String into Bytes//
    static public function bitedecode(str:String):Bytes
	{
    var base = Bytes.ofString("0123456789abcdef");
    return new BaseCode(base).decodeBytes(Bytes.ofString(str.toLowerCase()));
    }
	
}