package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import helpers.IconName;
import objects.Frame;
import objects.Icon;
import objects.Tile;

class GameWithTweens extends FlxState
{
	// contants
	private final ROWS:Int = 9;
	private final COLS:Int = 8;
	private final GRID_X:Int = 60;
	private final GRID_Y:Int = 140;
	private final TILE_SIZE:Int = 60;
	private final TOTAL_ITEMS = 6; // up to 11 sprites included
	private final NOONE = -4;

	private var tile:Tile;
	private var tiles:Array<Array<Int>>;
	private var icon:Icon;
	private var icons:Array<Icon>;

	// debug output
	private var statusText:FlxText;

	// The frame of the selected tile
	private var frame:Frame;
	private var pickedRow:Int;
	private var pickedCol:Int;

	private var canGiveHints:Bool = false;

	override public function create()
	{
		super.create();

		// add the background
		add(new FlxSprite(0, 0, "assets/images/bg.png"));

		// add semi transparent square for head text
		var square = new FlxSprite();
		square.makeGraphic(FlxG.width, 35, FlxColor.WHITE);
		square.x = 0;
		square.y = 0;
		square.alpha = .75;
		add(square);

		var headText = new FlxText(0, 0, FlxG.width, "", 12);
		headText.color = FlxColor.RED;
		headText.alignment = FlxTextAlign.CENTER;
		headText.text = "Game prototype with tweens\n(WARNING: tweens are poorly implemented and are BUGGY)";
		add(headText);

		// Initilize new button
		var btn:FlxButton = new FlxButton(FlxG.width / 2 - 100, 50, "Click here to test\ncore mechanics\nwithout tween! (foolproofed code)", clickBtn);
		btn.label.setFormat(null, 12);
		btn.loadGraphic("assets/images/button.png", false, 200, 72);
		add(btn);

		// init game
		initGrid(ROWS, COLS);

		// add semi transparent square for status text
		var square = new FlxSprite();
		square.makeGraphic(FlxG.width, 82, FlxColor.BLACK);
		square.x = 0;
		square.y = FlxG.height - 80;
		square.alpha = .5;
		add(square);

		statusText = new FlxText(0, FlxG.height - 79, FlxG.width, "", 12);
		statusText.alignment = FlxTextAlign.CENTER;
		add(statusText);

		// The frame of the selected tile
		frame = new Frame();
		frame.visible = false;
		add(frame);

		// initially no tile is selected
		pickedRow = NOONE;
		pickedCol = NOONE;
	}

	function clickBtn():Void
	{
		// Switched state from current to PlayState
		FlxG.switchState(new GameNoTweens());
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.R)
			FlxG.resetGame();

		// manually fix if things get broken
		if (FlxG.keys.justPressed.C)
		{
			evalGrid();
			checkForChains();
		}

		// detect hints
		if (canGiveHints && statusText.text == "")
		{
			statusText.text = "Hints: ";
			for (r in 0...ROWS)
			{
				for (c in 0...COLS)
				{
					if (c < COLS - 1)
					{
						swapTiles(r, c, r, c + 1);
						if (isChain(r, c) || isChain(r, c + 1))
						{
							statusText.text += " " + Std.string(r) + "," + Std.string(c) + " -> " + Std.string(r) + "," + Std.string(c + 1) + " ";
						}
						swapTiles(r, c, r, c + 1);
					}
					if (r < ROWS - 1)
					{
						swapTiles(r, c, r + 1, c);
						if (isChain(r, c) || isChain(r + 1, c))
						{
							statusText.text += " " + Std.string(r) + "," + Std.string(c) + " -> " + Std.string(r + 1) + "," + Std.string(c) + " ";
						}
						swapTiles(r, c, r + 1, c);
					}
				}
			}
		}
	}

	/**
	 * Instantiates game objects, arrays and initializes the game
	 * @param row 
	 * @param col 
	 */
	function initGrid(row:Int, col:Int)
	{
		// draw the board and define the indexes of the icons
		tiles = new Array();
		for (c in 0...col)
		{
			tiles.push(new Array());
			for (r in 0...row)
			{
				var tile = new Tile();
				tile.x = GRID_X + c * TILE_SIZE;
				tile.y = GRID_Y + r * TILE_SIZE;
				tile.row = r;
				tile.col = c;
				tiles[c].push(Math.floor(Math.random() * TOTAL_ITEMS)); // index of icon
				add(tile);
				FlxMouseEventManager.add(tile, onTileMouseDown, onTileMouseUp, onTileMouseOver, onTileMouseOut);
			}
		}

		// create the icons
		icons = new Array(); // This is a sinlge dimension array. Its contents will be tracked via name property
		for (c in 0...col)
		{
			for (r in 0...row)
			{
				// avoid premature chains
				while (isChain(r, c))
				{
					tiles[c][r] = Math.floor(Math.random() * TOTAL_ITEMS);
				}

				var index = tiles[c][r];
				var skin:String = IconName.get(index);
				var asset:String = "assets/images/" + skin + ".png";
				var icon:Icon = new Icon(GRID_X + c * TILE_SIZE, -(GRID_Y + r * TILE_SIZE), asset);
				icon.skin = skin;
				icon.tween = null;
				// name it for reffering it when needed
				icon.name = Std.string(r) + " " + Std.string(c);

				icons.push(icon);
			}
		}

		var c = col;
		var d = 0; // tween delay
		var pos = icons.length; // position in array
		while (c > 0)
		{
			c--;
			var r = row;
			while (r > 0)
			{
				d++;
				r--;
				pos--;
				add(icons[pos]);

				FlxTween.tween(icons[pos], {y: GRID_Y + r * TILE_SIZE}, 0.5, {startDelay: Math.sqrt(d) / 10, ease: FlxEase.quintIn, type: ONESHOT});
			}
		}
		// now it's safe to access the arrays and check for hints
		canGiveHints = true;
	}

	//////////////////////////////////
	// listeners

	/**
	 * The actions that will be initiated when a [tile] is clicked
	 * @param tile 
	 */
	function onTileMouseDown(tile:Tile)
	{
		// if the picked tile is already selected, deselect it
		if ((pickedRow == tile.row) && (pickedCol == tile.col))
		{
			pickedRow = NOONE;
			pickedCol = NOONE;
			frame.visible = false;
		}
		// if the picked tile is not in adjacent tile of the selected tile, select the picked tile
		else if (!isAdjacent(tile.row, tile.col, pickedRow, pickedCol))
		{
			pickedRow = tile.row;
			pickedCol = tile.col;
			frame.x = tile.x;
			frame.y = tile.y;
			frame.visible = true;
		}
		// if the picked tile is not in adjacent tile of the selected tile, swap them
		else
		{
			swapIcons(pickedRow, pickedCol, tile.row, tile.col);
			pickedRow = NOONE;
			pickedCol = NOONE;
			frame.visible = false;
		}
		updateStatusText(tile);
	}

	/**
	 * Updates the debug text when mouse up on [tile] 
	 * @param tile 
	 */
	function onTileMouseUp(tile:Tile)
	{
		updateStatusText(tile);
	}

	/**
	 * Updates the debug text when the mouse starts hovering the [tile]
	 * @param tile 
	 */
	function onTileMouseOver(tile:Tile)
	{
		updateStatusText(tile);
	}

	/**
	 * Clears the debug text when the mouse stops hovering the [tile]
	 * @param tile 
	 */
	function onTileMouseOut(tile:Tile)
	{
		statusText.text = "";
	}

	//////////////////////////////////
	// debug

	/**
	 * Updates the debug text related to the [tile]
	 * @param tile 
	 */
	function updateStatusText(tile:Tile)
	{
		statusText.text = "selected row: " + ((pickedRow == NOONE) ? "-" : Std.string(pickedRow)) + " selected col: "
			+ ((pickedCol == NOONE) ? "-" : Std.string(pickedCol)) + "\n";
		statusText.text += "row: " + tile.row + " col: " + tile.col + " --\n";
		statusText.text += " id: " + tiles[tile.col][tile.row] + " - " + IconName.get(tiles[tile.col][tile.row]);
		if (getIconPos(tile.row, tile.col) != -1)
			statusText.text += "\nicon: " + icons[getIconPos(tile.row, tile.col)].name + " " + icons[getIconPos(tile.row, tile.col)].skin;
		else
			statusText.text += "\nicon: null";
		statusText.text += "\ntotal icons: " + icons.length;
	}

	//////////////////////////////////
	// Array manipulations

	/**
	 * Check if there is a chain at [row] and [col]
	 * @param row of tiles array to check
	 * @param col of tiles array to check
	 * @return Bool true if there is a chain
	 */
	function isChain(row:Int, col:Int):Bool
	{
		return rowChain(row, col) > 2 || colChain(row, col) > 2;
	}

	/**
	 * Check how many icons form a chain at [row] of [col]
	 * @param row of tiles array to check
	 * @param col of tiles array to check
	 * @return Int the number of icons that are in the chain
	 */
	function rowChain(row:Int, col:Int):Int
	{
		var current:Int = tiles[col][row];
		var chain:Int = 1;
		var tmp:Int = col;
		while (evalTile(current, row, tmp - 1))
		{
			tmp--;
			chain++;
		}
		tmp = col;
		while (evalTile(current, row, tmp + 1))
		{
			tmp++;
			chain++;
		}
		return chain;
	}

	/**
	 * Check how many icons form a chain at [col] of [row]
	 * @param row of tiles array to check
	 * @param col of tiles array to check
	 * @return Int the number of icons that are in the chain
	 */
	function colChain(row:Int, col:Int):Int
	{
		var current:Int = tiles[col][row];
		var chain:Int = 1;
		var tmp:Int = row;
		while (evalTile(current, tmp - 1, col))
		{
			tmp--;
			chain++;
		}
		tmp = row;
		while (evalTile(current, tmp + 1, col))
		{
			tmp++;
			chain++;
		}
		return chain;
	}

	/**
	 * check if the tiles at [col] and [row] has the same [index]
	 * @param index the index to check
	 * @param row the [row] of tiles
	 * @param col the [col] of tiles
	 * @return Bool true if the valueu of tiles at [col] and [row] are equal to [index]
	 */
	function evalTile(index:Int, row:Int, col:Int):Bool
	{
		if (col > COLS - 1 || col < 0)
			return false;

		if (row > ROWS - 1 || row < 0)
			return false;

		return index == tiles[col][row];
	}

	/**
	 * Check if the tiles at [row1], [col1] and at [row2], [col2] are adjacent
	 * @param row1 
	 * @param col1 
	 * @param row2 
	 * @param col2 
	 * @return Bool true if they are adjacent
	 */
	function isAdjacent(row1:Int, col1:Int, row2:Int, col2:Int):Bool
	{
		return Math.abs(row1 - row2) + Math.abs(col1 - col2) == 1;
	}

	/**
	 * swaps the values of tiles array [row1], [col1] and [row2], [col2]
	 * @param row1 
	 * @param col1 
	 * @param row2 
	 * @param col2 
	 */
	function swapTiles(row1:Int, col1:Int, row2:Int, col2:Int)
	{
		var tmp:Int = tiles[col1][row1];
		tiles[col1][row1] = tiles[col2][row2];
		tiles[col2][row2] = tmp;
	}

	/**
	 * Phisycally swaps the icons at [row1],[col1] and [row2], [col2] and their 
	 * representing index values in tiles array (via swapTiles function).
	 * @param row1 
	 * @param col1 
	 * @param row2 
	 * @param col2 
	 */
	function swapIcons(row1:Int, col1:Int, row2:Int, col2:Int)
	{
		// initiate swap
		var p1:Int = getIconPos(row1, col1);
		var p2:Int = getIconPos(row2, col2);
		var t:Float = 0.2;

		var options = {
			type: ONESHOT,
			onComplete: onSwapCompleted.bind(_, row1, col1, row2, col2)
		}

		// swap their on screen position
		if (col1 > col2)
		{
			FlxTween.tween(icons[p1], {x: icons[p1].x - TILE_SIZE}, t, options);
			FlxTween.tween(icons[p2], {x: icons[p2].x + TILE_SIZE}, t);
		}
		if (col1 < col2)
		{
			FlxTween.tween(icons[p1], {x: icons[p1].x + TILE_SIZE}, t, options);
			FlxTween.tween(icons[p2], {x: icons[p2].x - TILE_SIZE}, t);
		}
		if (row1 > row2)
		{
			FlxTween.tween(icons[p1], {y: icons[p1].y - TILE_SIZE}, t, options);
			FlxTween.tween(icons[p2], {y: icons[p2].y + TILE_SIZE}, t);
		}
		if (row1 < row2)
		{
			FlxTween.tween(icons[p1], {y: icons[p1].y + TILE_SIZE}, t, options);
			FlxTween.tween(icons[p2], {y: icons[p2].y - TILE_SIZE}, t);
		}
		// update their name
		icons[p1].name = Std.string(row2) + " " + Std.string(col2);
		icons[p2].name = Std.string(row1) + " " + Std.string(col1);
		// swap their position in array
		swapTiles(row1, col1, row2, col2);
	}

	/**
	 * Call back of the icons tweens of swapIcons function. If chain occurs will be removed else will swap back
	 * @param tween 
	 * @param row1 
	 * @param col1 
	 * @param row2 
	 * @param col2 
	 */
	function onSwapCompleted(tween:FlxTween, row1:Int, col1:Int, row2:Int, col2:Int):Void
	{
		// check if there is a chain after swapping and remove it
		if (isChain(row1, col1) || isChain(row2, col2))
		{
			if (isChain(row1, col1))
			{
				trace("will remove items1");
				removeIcons(row1, col1);
			}
			if (isChain(row2, col2))
			{
				trace("will remove items2");
				removeIcons(row2, col2);
			}
		}
		// else swap back
		else
		{
			var p1:Int = getIconPos(row1, col1);
			var p2:Int = getIconPos(row2, col2);
			var t:Float = 0.2;

			if (col1 > col2)
			{
				FlxTween.tween(icons[p1], {x: icons[p1].x - TILE_SIZE}, t);
				FlxTween.tween(icons[p2], {x: icons[p2].x + TILE_SIZE}, t);
			}
			if (col1 < col2)
			{
				FlxTween.tween(icons[p1], {x: icons[p1].x + TILE_SIZE}, t);
				FlxTween.tween(icons[p2], {x: icons[p2].x - TILE_SIZE}, t);
			}
			if (row1 > row2)
			{
				FlxTween.tween(icons[p1], {y: icons[p1].y - TILE_SIZE}, t);
				FlxTween.tween(icons[p2], {y: icons[p2].y + TILE_SIZE}, t);
			}
			if (row1 < row2)
			{
				FlxTween.tween(icons[p1], {y: icons[p1].y + TILE_SIZE}, t);
				FlxTween.tween(icons[p2], {y: icons[p2].y - TILE_SIZE}, t);
			}
			// update their name
			icons[p1].name = Std.string(row2) + " " + Std.string(col2);
			icons[p2].name = Std.string(row1) + " " + Std.string(col1);
			// swap back their position in array
			swapTiles(row1, col1, row2, col2);
		}
	}

	/**
	 * Sents the icon at [row],[col] for destroying
	 * @param row 
	 * @param col 
	 */
	function removeIcons(row:Int, col:Int)
	{
		if (@:privateAccess FlxTween.globalManager._tweens.length > 0)
		{
			haxe.Timer.delay(function()
			{
				removeIcons(row, col);
			}, 1);
		}
		else
		{
			var current:Int = tiles[col][row];

			var cacheRows = [];
			var cacheCols = [];
			cacheRows.push(row);
			cacheCols.push(col);

			destroyIcon(row, col);

			var tmp:Int;
			if (rowChain(row, col) > 2)
			{
				tmp = col;
				while (evalTile(current, row, tmp - 1))
				{
					tmp--;
					destroyIcon(row, tmp);
					cacheRows.push(row);
					cacheCols.push(tmp);
				}
				tmp = col;
				while (evalTile(current, row, tmp + 1))
				{
					tmp++;
					destroyIcon(row, tmp);
					cacheRows.push(row);
					cacheCols.push(tmp);
				}
			}
			if (colChain(row, col) > 2)
			{
				tmp = row;
				while (evalTile(current, tmp - 1, col))
				{
					tmp--;
					destroyIcon(tmp, col);
					cacheRows.push(tmp);
					cacheCols.push(col);
				}
				tmp = row;
				while (evalTile(current, tmp + 1, col))
				{
					tmp++;
					destroyIcon(tmp, col);
					cacheRows.push(tmp);
					cacheCols.push(col);
				}
			}
			for (i in 0...cacheRows.length)
			{
				tiles[cacheCols[i]][cacheRows[i]] = NOONE;
			}

			adjustIcons();
			addNewIcons();
		}
	}

	/**
	 * Get the position of icon in icons array from [row] and [col] of the tiles array
	 * @param row 
	 * @param col 
	 * @return Int
	 */
	function getIconPos(row, col):Int
	{
		var position:Int = -1;
		for (p in 0...icons.length)
		{
			if (icons[p].name == Std.string(row) + " " + Std.string(col))
				position = p;
		}
		return position;
	}

	/**
	 * Destroy the icon of [row] and [col] of the tiles array
	 * @param row 
	 * @param col 
	 */
	function destroyIcon(row, col)
	{
		var p:Int = getIconPos(row, col);
		var icon:Array<Icon> = icons.splice(p, 1);
		icon[0].destroyMe();
	}

	/**
	 * Moving icons downwards if the bellow tile is empty
	 */
	function adjustIcons()
	{
		for (c in 0...COLS)
		{
			var r = ROWS;
			while (r > 1)
			{
				// if an emty tile found...
				r--;
				if (tiles[c][r] == NOONE)
				{
					// here
					trace("empty tile found at row: " + r + " col: " + c);

					// ...start looking its collumn upwards...
					var rr = r;
					while (rr > 0)
					{
						rr--;
						if (tiles[c][rr] != NOONE)
						{
							trace("occupied tile found at row: " + rr + " col: " + c);
							break;
						}
					}
					// ... and find the first icon to move it downwards
					if (tiles[c][rr] != NOONE)
					{
						// update the tiles array
						tiles[c][r] = tiles[c][rr];
						tiles[c][rr] = NOONE;

						trace("moving from row " + rr + " to row " + r);
						var options = {
							type: ONESHOT,
							onComplete: onIconFallComplete.bind(_, r, c)
						};
						// make the icon fall

						var pos = getIconPos(rr, c);
						var icon = icons[pos];

						icon.tween = FlxTween.tween(icon, {y: r * TILE_SIZE + GRID_Y}, 0.2, options);

						icons[getIconPos(rr, c)].name = Std.string(r) + " " + Std.string(c);
					}
				}
			}
		}
	}

	/**
	 * Checks if chain occurs at icon's landing position [row], [col] 
	 * @param tween 
	 * @param row 
	 * @param cow
	 */
	function onIconFallComplete(tween:FlxTween, row:Int, col:Int)
	{
		checkForChainsAt(row, col);
	}

	/**
	 * Detects the empty tiles and fills them with new icons
	 */
	function addNewIcons()
	{
		// If other tweens still running, wait
		if (@:privateAccess FlxTween.globalManager._tweens.length > 0)
		{
			haxe.Timer.delay(function()
			{
				addNewIcons();
			}, 1);
		}
		else
		{
			for (c in 0...COLS)
			{
				var r = ROWS;
				while (r > 0)
				{
					r--;

					if (tiles[c][r] == NOONE)
					{
						var index:Int = Math.floor(Math.random() * TOTAL_ITEMS);
						var skin:String = IconName.get(index);
						var asset:String = "assets/images/" + skin + ".png";
						var icon:Icon = new Icon(GRID_X + c * TILE_SIZE, -(GRID_Y + r * TILE_SIZE), asset);
						icon.skin = skin;
						icon.name = Std.string(r) + " " + Std.string(c);
						icons.unshift(icon);

						tiles[c][r] = index;

						trace("adding new icon at row: " + r + " col: " + c);
						var options = {
							type: ONESHOT,
							onComplete: onAddedNewIcon.bind(_, r, c)
						};

						icon.tween = FlxTween.tween(icon, {y: GRID_Y + r * TILE_SIZE}, 0.5, {ease: FlxEase.quintIn});

						add(icon);
					}
				}
			}
		}
	}

	/**
	 * Check at the position of the newly added icon at [row] [col], if a new chain occurs
	 * @param tween 
	 * @param row 
	 * @param col 
	 */
	function onAddedNewIcon(tween:FlxTween, row, col)
	{
		checkForChainsAt(row, col);
	}

	/** 
	 * Check at the position [row] [col], if a new chain occurs and remove it
	 * @param row 
	 * @param col 
	 */
	function checkForChainsAt(row, col)
	{
		if (isChain(row, col))
		{
			removeIcons(row, col);
		}
	}

	/**
	 * Scans all rows and cols for chains
	 */
	function checkForChains()
	{
		if (@:privateAccess FlxTween.globalManager._tweens.length == 0)
		{
			for (cc in 0...COLS)
			{
				for (rr in 0...ROWS)
				{
					if (isChain(rr, cc))
					{
						removeIcons(rr, cc);
						break;
					}
				}
			}
		}
	}

	/**
	 * Evaluates the integrity of the arrays in case those are messed
	 */
	function evalGrid()
	{
		for (c in 0...COLS)
		{
			for (r in 0...ROWS)
			{
				var pos:Int = getIconPos(r, c);
				if (pos == -1)
				{
					trace("Corruption found");
					if (tiles[c][r] == NOONE)
					{
						tiles[c][r] = Math.floor(Math.random() * TOTAL_ITEMS);
					}
					var index = tiles[c][r];
					var skin:String = IconName.get(index);
					var asset:String = "assets/images/" + skin + ".png";
					var icon:Icon = new Icon(GRID_X + c * TILE_SIZE, -(GRID_Y + r * TILE_SIZE), asset);
					icon.skin = skin;
					icon.tween = null;
					// name it for reffering it when needed
					icon.name = Std.string(r) + " " + Std.string(c);

					icons.push(icon);
				}
				icons[getIconPos(r, c)].x = GRID_X + c * TILE_SIZE;
				icons[getIconPos(r, c)].y = GRID_Y + r * TILE_SIZE;
			}
		}

		trace("check done");
	}
}
