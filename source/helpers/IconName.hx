package helpers;

class IconName
{
	public static inline final EMPTY = "empty";

	static inline final WAFFLE_WHITE = "waffle white";
	static inline final START_RED = "star red";
	static inline final COOKIE = "cookie";
	static inline final DONUT = "donut";
	static inline final CUP_CAKE = "cup cake";
	static inline final CROISSANT = "croissant";
	static inline final WAFFLE_BLUE = "waffle blue";
	static inline final MACARON = "macaron";
	static inline final ECLAIR = "eclair";
	static inline final STAR_YELLOW = "star yellow";
	static inline final BROWN_COOKIE = "brown cookie";
	static inline final MINI_PIE = "mini pie";

	public static function get(index:Int):String
	{
		switch (index)
		{
			case 0:
				return MINI_PIE;
			case 1:
				return BROWN_COOKIE;
			case 2:
				return STAR_YELLOW;
			case 3:
				return ECLAIR;
			case 4:
				return MACARON;
			case 5:
				return WAFFLE_BLUE;
			case 6:
				return CROISSANT;
			case 7:
				return CUP_CAKE;
			case 8:
				return DONUT;
			case 9:
				return COOKIE;
			case 10:
				return START_RED;
			case 11:
				return WAFFLE_WHITE;
			default:
				return EMPTY;
		}
	}
}
