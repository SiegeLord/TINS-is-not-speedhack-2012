/*
Copyright 2012 Pavel Sountsov

This file is part of TINSEngine.

TINSEngine is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

TINSEngine is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with TINSEngine.  If not, see <http://www.gnu.org/licenses/>.
*/
module game.components.SimpleAnimation;

import engine.MathTypes;
import engine.Config;
import engine.Sprite;
import engine.ComponentHolder;

import game.GameObject;

import game.components.Position;
import game.components.Direction;
import game.components.Moving;
import game.components.IWeapon;
import game.components.Destroyable;

import tango.io.Stdout;
import allegro5.allegro;
 
class CSimpleAnimation : CGameComponent
{
	override
	void WireUp(CComponentHolder holder)
	{
		RequireComponent(Position, holder, this);
		GetComponent(Direction, holder, this);
		GetComponent(Moving, holder, this);
		GetComponent(Weapon, holder, this);
		GetComponent(Destroyable, holder, this);
	}
	
	override
	void Load(CGameObject game_obj, CConfig config)
	{
		game_obj.Level.DrawEvent.Register(&Draw, 1);
		
		if(Direction !is null)
		{
			void load_type(ref CSprite[EDirection.NumDirections] sprites, const(char)[] suffix)
			{
				foreach(dir; 0..EDirection.NumDirections)
				{
					auto sprite_str = suffix ~ "_" ~ DirectionToString(cast(EDirection)dir);
					auto sprite_file = config.Get!(const(char)[])(ComponentName!(typeof(this)), sprite_str, "");
					if(sprite_file == "")
						throw new Exception(config.Filename.idup ~ ":" ~ ComponentName!(typeof(this)).idup ~ "needs " ~ sprite_str.idup);
					sprites[dir] = new CSprite(sprite_file, game_obj.Level.ConfigManager, game_obj.Level.BitmapManager);
				}
			}
			
			load_type(StandSprites, "stand");
			if(Moving !is null)
				load_type(WalkSprites, "walk");
			if(Weapon !is null)
				load_type(AttackSprites, "attack");
		}
		else
		{
			auto sprite_file = config.Get!(const(char)[])(ComponentName!(typeof(this)), "sprite", "");
			if(sprite_file == "")
				throw new Exception("'" ~ ComponentName!(typeof(this)) ~ "' needs a sprite file.");
			StandSprites[0] = new CSprite(sprite_file, game_obj.Level.ConfigManager, game_obj.Level.BitmapManager);
		}
		
		
		Time = &game_obj.Level.Game.Time;
	}
	
	override
	void Unload(CGameObject game_obj)
	{
		game_obj.Level.DrawEvent.UnRegister(&Draw);
	}
	
	void Draw()
	{
		CSprite sprite;
		if(Direction is null)
		{
			sprite = StandSprites[0];
		}
		else
		{
			if(Moving !is null && Moving.Moving)
			{
				sprite = WalkSprites[Direction.Direction];
			}
			else
			{
				sprite = StandSprites[Direction.Direction];
			}
			
			if(Weapon !is null && Weapon.Visible)
			{
				sprite = AttackSprites[Direction.Direction];
			}
		}
		
		auto color = al_map_rgb_f(1, 1, 1);
		
		if(Destroyable !is null && Destroyable.Immune() && (cast(int)(Time() / 0.25) % 2 == 0))
			color = al_map_rgba_f(0.25, 0.25, 0.25, 0.25);
		
		sprite.Draw(Time(), Position.X, Position.Y, color);
	}
protected:
	double delegate() Time;
	
	CSprite[EDirection.NumDirections] StandSprites;
	CSprite[EDirection.NumDirections] WalkSprites;
	CSprite[EDirection.NumDirections] AttackSprites;
	
	CSprite CurSprite;
	
	
	CPosition Position;
	CDirection Direction;
	CMoving Moving;
	IWeapon Weapon;
	CDestroyable Destroyable;
}
