class Goomba < Entity
	def initialize(x,y,type,dir,room,active=false)
		@active=active
		@x,@y,@type,@dir,@frame,@vy=x,y,type,dir,0,0
		init([:enemy,:powish],room)
	end
	
	def update(sx,sy)
		if @dead and @dead<120 then @dead+=1 elsif @dead then remove end
		if @y>$game.map.height+64 then remove end
		@vy+=$game.map.grav
		if @vy>0 and @y-64<$game.map.height
			@vy.to_i.times{if !$game.map.solid?(@x+2,@y+32,true) && !$game.map.solid?(@x+16,@y+32,true) && !$game.map.solid?(@x+30,@y+32,true) or @fall
			@y+=1 else @vy=0 and break end}
		elsif @vy<0
			@vy.to_i.abs.times{if !$game.map.solid?(@x+2,@y) && !$game.map.solid?(@x+16,@y) && !$game.map.solid?(@x+30,@y) or @fall
			@y-=1 else @vy=0 and break end}
		end
		
		return if !act(@x,@y,32,32,sx,sy) or @dead && !@fall
		@frame=($count/12)%2
		if @dir==1
			2.times{if !checkenemy(@x+36,@y+16) and !$game.map.solid?(@x+31,@y+1) && !$game.map.solid?(@x+31,@y+16) && !$game.map.solid?(@x+31,@y+31) or @fall
			@x+=1 else @dir=0 end}
		elsif @dir==0
			2.times{if !checkenemy(@x-4,@y+16) and !$game.map.solid?(@x+1,@y+1) && !$game.map.solid?(@x+1,@y+16) && !$game.map.solid?(@x+1,@y+31) or @fall
			@x-=1 else @dir=1 end}
		end
		if $game.map.solid?(@x+16,@y+16) and !@fall then kick(true) end
		
		det if !@dead
	end
	
	def draw(sx,sy)
		Tls['enemies/goomba',[32,32]][@frame+@type*3].draw(@x-sx,@y-sy+if@fall then 32 else 0 end,if !@fall then 2 else 4 end,1,if @fall then -1 else 1 end)
	end
	
	def stomp
		$game.player.vy=-12
		Snd['stomp'].play
		@frame=2
		$game.player.combo[0]+=1
		combo(@x+16,@y,$game.player.combo[0])
		@dead=0
	end
	
	def kick(bullet)
		Snd['kick'].play
		@vy=-8
		@frame=1
		if !bullet
			$game.player.combo[1]+=1
			combo(@x+16,@y,$game.player.combo[1])
		elsif bullet != :combo and bullet !=:star
			$points+=100
			Points.new(@x+16,@y,100)
		end
		if bullet==:star then $game.player.combo[2]+=1 and combo(@x+16,@y,$game.player.combo[2]) end
		@dead=0
		@fall=true
	end
	
	def pow(x,y,width,height,force)
		return if @dead
		if x+width>@x and x<@x+32 and y<@y+32 and y+height>@y
			kick(true)
		end
	end

	def size
		[32,32]
	end

	def det
		detect_player(@x,@y,32,32)
	end

	def froze
		remove
		@dead=true
		Frozen.new(@x,@y,Tls['enemies/goomba',[32,32]][@frame+@type*3],[1,1])
	end

	def down
		$game.map.solid?(@x+16,@y+33)
	end
end

class KoopaTroopa < Entity
	def initialize(x,y,smart,dir,movement,speed,room,active=false)
		@active=active
		@x,@y,@smart,@dir,@movement,@vy,@vx,@frame,@speed=x,y,smart,dir,movement,0,0,0,speed
		@depos=0
		init([:enemy,:powish],room)
	end

	def update(sx,sy)
		return if !act(@x,@y,32,48,sx,sy)
		if @y>$game.map.height+64 then remove end
		if @dead and @dead<120 then @dead+=1 and if @fall then @y+=8 end elsif @dead then remove end
		return if @dead && !@fall
		det if !@dead
		if @movement[0]<2
			@vy+=$game.map.grav
			if @vy>0 and @y-64<$game.map.height
				@vy.to_i.times{det if !@dead
				if !$game.map.solid?(@x+2,@y+48,true) and !$game.map.solid?(@x+16,@y+48,true) and !$game.map.solid?(@x+30,@y+48,true) or @fall
				@y+=1 else if @movement[0]==1 then @vy=-@movement[1] else @vy=0 end and break end}
			elsif @vy<0
				@vy.to_i.abs.times{det if !@dead
				if !$game.map.solid?(@x+2,@y) and !$game.map.solid?(@x+16,@y) and !$game.map.solid?(@x+30,@y) or @fall
				@y-=1 else @vy=0 and break end}
			end
		elsif @movement[0]==3
			if @dir==0 and @depos<@movement[1]*16
				@vy+=$game.map.grav if @vy<@speed
				@depos+=1
				@vy.to_i.times{det if !@dead
				if !checkenemy(@x+16,@y+52) and !$game.map.solid?(@x+2,@y+48) and !$game.map.solid?(@x+16,@y+48) and !$game.map.solid?(@x+30,@y+48)
					@y+=1 else @dir==1 and break end}
			elsif @dir==1 and @depos>-(@movement[1]*16)
				@vy-=1 if @vy>(-@speed)
				@depos-=1
				@vy.to_i.abs.times{det if !@dead
				if !checkenemy(@x+16,@y-4) and !$game.map.solid?(@x+2,@y) and !$game.map.solid?(@x+16,@y) and !$game.map.solid?(@x+30,@y)
					@y-=1 else @dir=0 and break end}
			else
				if @depos==-(@movement[1]*16) then @dir=0 elsif @depos==@movement[1]*16 then @dir=1 end
			end
		end
		
		@frame=($count/8)%2
		if @movement[0]<2
			if @dir==1
				@speed.times{if !checkenemy(@x+36,@y+32) and !$game.map.solid?(@x+31,@y+1) and !$game.map.solid?(@x+31,@y+47) and !$game.map.solid?(@x+31,@y+47) and !@smart || @smart && down && $game.map.solid?(@x+33,@y+49,true) || @smart && !down or @fall
				@x+=1 else @dir=0 end}
			elsif @dir==0
				@speed.times{if !checkenemy(@x-4,@y+32) and !$game.map.solid?(@x+1,@y+1) and !$game.map.solid?(@x+1,@y+47) and !$game.map.solid?(@x+1,@y+47) and !@smart || @smart && down && $game.map.solid?(@x-1,@y+49,true) || @smart && !down or @fall
				@x-=1 else @dir=1 end}
			end
		elsif @movement[0]==2
			if @dir==1 and @depos<@movement[1]*16
				@vx+=1 if @vx<@speed
				@depos+=1
				@vx.to_i.times{det
				if !checkenemy(@x+36,@y+32) and !$game.map.solid?(@x+32,@y+2) and !$game.map.solid?(@x+32,@y+24) and !$game.map.solid?(@x+32,@y+46)
					@x+=1 else @dir==0 and break end}
			elsif @dir==0 and @depos>-(@movement[1]*16)
				@vx-=1 if @vx>(-@speed)
				@depos-=1
				@vx.to_i.abs.times{det
				if !checkenemy(@x-4,@y+32) and !$game.map.solid?(@x,@y+2) and !$game.map.solid?(@x,@y+24) and !$game.map.solid?(@x,@y+46)
					@x-=1 else @dir=1 and break end}
			else
				if @depos==-(@movement[1]*16) then @dir=1 elsif @depos==@movement[1]*16 then @dir=0 end
			end
		end
		if @time and @time>0 then @time-=1 elsif @time then @time=nil end
		if $game.map.solid?(@x+16,@y+24) and !@fall then kick(true) end
	end

	def draw(sx,sy)
		offx=if @movement[0]!=3 && @dir==1 or @movement[0]==3 && $game.player.x>@x+16 then 32 else 0 end
		posx=if @movement[0]!=3 && @dir==1 or @movement[0]==3 && $game.player.x>@x+16 then -1 else 1 end
		if !@fall then Tls['enemies/koopa troopa',[32,48]][0+if @smart then 4 else 0 end+if @movement[0] != 0 then 2 else 0 end+@frame].draw(@x-sx+offx,@y-sy+if @fall then 32 else 0 end,2,posx,if @fall then -1 else 1 end) else
			Tls['enemies/shell',[32,32]][if @smart then 5 else 0 end].draw(@x-sx,@y-sy+32,4,1,-1) end
	end

	def stomp
		return if @time
		@time=5
		$game.player.vy=-12
		Snd['stomp'].play
		$game.player.combo[0]+=1
		combo(@x+16,@y,$game.player.combo[0])
		if @movement[0]>0
			@movement[0]=0
			@vy=0
		else
			@dead=true
			Shell.new(@x,@y+16,if @smart then 1 else 0 end,$game.room,@speed,@dir==0)
			remove
		end
	end
	
	def kick(bullet)
		@vy=-16
		Snd['kick'].play
		@frame=1
		if !bullet
			$game.player.combo[1]+=1
			combo(@x+16,@y,$game.player.combo[1])
		elsif bullet != :combo and bullet != :star
			$points+=200
			Points.new(@x+16,@y,200)
		end
		if bullet==:star then $game.player.combo[2]+=1 and combo(@x+16,@y,$game.player.combo[2]) end
		@dead=0
		@fall=true
		@movement[0]=0 if @movement.class==Array
	end
	
	def pow(x,y,width,height,force)
		return if @dead
		if x+width>@x and x<@x+32 and y<@y+48 and y+height>@y
			Snd['kick'].play
			@vy=-16
			@frame=1
			$points+=100
			Points.new(@x+16,@y,100)
			@dead=0
			@fall=true
		end
	end

	def size
		[32,48]
	end

	def det
		detect_player(@x,@y,32,48)
	end

	def froze
		remove
		@dead=true
		Frozen.new(@x,@y,Tls['enemies/koopa troopa',[32,48]][0+if @smart then 4 else 0 end+if @movement[0] != 0 then 2 else 0 end+@frame],[1,1.5])
	end

	def down
		$game.map.solid?(@x+16,@y+49)
	end
end

class PiranhaPlant < Entity
	def initialize(x,y,type,dir,length,delay,speed,attack,penetrating,room,active=false)
		@active=active
		@x,@y,@type,@dir,@length,@delay,@speed,@attack,@penetrating=x,y,type,dir,length,delay,speed,attack,penetrating
		@pos,@turn,@cur,@atacking,@through=0,false,0,0,true
		init([:enemy],room)
	end

	def update(sx,sy)
		return if !act(@x,@y,size[0],size[1],sx,sy,true)
		if @y>$game.map.height+64 then remove end
		if @cur==0 and @atacking==0 and @type!=1
			case @dir
				when 0
				if !@turn
					@speed.times{if @pos<size[1] then @y-=1 and @pos+=1 else @turn=true and @atacking=@attack and @cur=@delay*20 and break end}
				else
					@speed.times{if @pos>0 then @y+=1 and @pos-=1 else @turn=false
						@cur=@delay*20 and break end}
				end
				when 1
				if !@turn
					@speed.times{if @pos<size[1] then @y+=1 and @pos+=1 else @turn=true and @atacking=@attack and @cur=@delay*20 and break end}
				else
					@speed.times{if @pos>0 then @y-=1 and @pos-=1 else @turn=false
						@cur=@delay*20 and break end}
				end
				when 2
				if !@turn
					@speed.times{if @pos<size[0] then @x-=1 and @pos+=1 else @turn=true and @atacking=@attack and @cur=@delay*20 and break end}
				else
					@speed.times{if @pos>0 then @x+=1 and @pos-=1 else @turn=false
						@cur=@delay*20 and break end}
				end
				when 3
				if !@turn
					@speed.times{if @pos<size[0] then @x+=1 and @pos+=1 else @turn=true and @atacking=@attack and @cur=@delay*20 and break end}
				else
					@speed.times{if @pos>0 then @x-=1 and @pos-=1 else @turn=false
						@cur=@delay*20 and break end}
				end
			end
		elsif @atacking==0 then @cur-=1 elsif $count%5==0
			case @type
				when 0,1
				@atacking=0
				when 2
				Snd['fireshot'].play
				case @dir
					when 0
					PiranhaFire.new(@x+16,@y,true,@penetrating,-7+rand(15),-1-rand(19))
					when 1
					PiranhaFire.new(@x+16,@y+32,true,@penetrating,-7+rand(15),0+rand(5))
					when 2
					PiranhaFire.new(@x,@y+16,true,@penetrating,-1-rand(19),-7+rand(15))
					when 3
					PiranhaFire.new(@x+32,@y+16,true,@penetrating,1+rand(19),-7+rand(15))
				end
				@atacking-=1
				when 3
				Snd['fireshot'].play
				case @dir
					when 0
					PiranhaFire.new(@x+16,@y+16,false,@penetrating)
					when 1
					PiranhaFire.new(@x+16,@y+16,false,@penetrating)
					when 2
					PiranhaFire.new(@x+16,@y+16,false,@penetrating)
					when 3
					PiranhaFire.new(@x+16,@y+16,false,@penetrating)
				end
				@atacking-=1
			end
		end
	end

	def draw(sx,sy)
		case @dir
			when 0
			head(Tls['enemies/piranha plant head',[32,32]][if @type<2 then 0 else (@type-1)*8 end+($count/8)%2],sx,sy)
			i=0
			@length.times{Tls['enemies/piranha plant rest',[32,16]][if @type<3 then 0 else 4 end].draw(@x-sx,@y+32+i*16-sy,2)
			i+=1}
			when 1
			head(Tls['enemies/piranha plant head',[32,32]][if @type<2 then 4 else 4+(@type-1)*8 end+($count/8)%2],sx,sy)
			i=0
			@length.times{Tls['enemies/piranha plant rest',[32,16]][if @type<3 then 2 else 6 end].draw(@x-sx,@y-16-i*16-sy,2)
			i+=1}
			when 2
			head(Tls['enemies/piranha plant head',[32,32]][if @type<2 then 6 else 6+(@type-1)*8 end+($count/8)%2],sx,sy)
			i=0
			@length.times{Tls['enemies/piranha plant rest',[16,32]][if @type<3 then 3 else 7 end].draw(@x+32+i*16-sx,@y-sy,2)
			i+=1}
			when 3
			head(Tls['enemies/piranha plant head',[32,32]][if @type<2 then 2 else 2+(@type-1)*8 end+($count/8)%2],sx,sy)
			i=0
			@length.times{Tls['enemies/piranha plant rest',[16,32]][if @type<3 then 2 else 6 end].draw(@x-16-i*16-sx,@y-sy,2)
			i+=1}
		end
	end

	def head(img,sx,sy)
		if @type<3
			img.draw(@x-sx,@y-sy,2)
		else
			pl=$game.player
			Tls['enemies/piranha plant head',[32,32]][16+($count/8)%2].draw_rot(@x-sx+16,@y-sy+16,2,angle(@x+9,@y+9,pl.x+16,pl.y+64-pl.height/2),0.5,0.5)
		end
	end

	def det
		case @dir
			when 0,2
			detect_player(@x,@y,size[0],size[1])
			when 1
			detect_player(@x,@y+32-size[1],size[0],size[1])
			when 3
			detect_player(@x+32-size[0],@y,size[0],size[1])
		end
	end

	def size
		if @dir==0 or @dir==1
			[32,32+@length*16]
		else
			[32+@length*16,32]
		end
	end

	def stomp
	end
	
	def kick(bullet)
		return if @type==1
		Snd['kick'].play
		if !bullet
			$game.player.combo[1]+=1
			combo(@x+16,@y,$game.player.combo[1])
		elsif bullet != :combo and bullet != :star
			$points+=200
			Points.new(@x+16,@y,200)
		end
		if bullet==:star then $game.player.combo[2]+=1 and combo(@x+16,@y,$game.player.combo[2]) end
		if @length>1
			case @dir
				when 0
				@y+=16
				when 1
				@y-=16
				when 2
				@x+=16
				when 3
				@x-=16
			end
			if @turn then @pos-=16 else @pos+=16 end
			@length-=1 else remove end
			@dead=true
	end
	
	def pow(x,y,width,height,force)
	end

	def detect(x,y,width,height)
		case @dir
			when 0,2
			x<@x+size[0] and x+width>@x and y<@y+size[1] and y+height>@y
			when 1
			x<@x+32 and x>@x and y<@y+32 and y>@y-size[1]
			when 3
			x<@x+32 and x+height>@x-size[0] and y<@y+32 and y+height>@y
		end
	end

	def froze
	end

	def down
		true
	end
end

class PiranhaFire < Entity
	def initialize(x,y,falling,penetrating,vx=nil,vy=nil)
		@x,@y,@falling,@penetrating,@vx,@vy=x,y,falling,penetrating,vx,vy
		@active=true
		@projectile=true
		if !falling
			pl=$game.player
			@vx=(offset_x(a=angle(@x+9,@y+9,pl.x+16,pl.y+64-pl.height/2),5+rand(5))).round
			@vy=(offset_y(a,5+rand(5))).round
		end
		init([:enemy],$game.room)
		@light=Light.new(x-8,y-9,0.5,[false],$game.map,$game.room)
	end

	def update(sx,sy)
		if @y>$game.map.height+64 then remove end
		if !@penetrating and $game.map.solid?(@x+8,@y+9) then Pop.new(@x+8,@y+9,Img['projectiles/firepop'],1,16) and remove end
		if @vx>0
			@vx.times{@x+=1 and det}
		elsif @vx<0
			@vx.abs.times{@x-=1 and det}
		end
		if @vy>0
			@vy.to_i.times{@y+=1 and det}
		else
			@vy.to_i.abs.times{@y-=1 and det}
		end
		@vy+=$game.map.grav if @falling
		@light.x=@x-8 if @light
		@light.y=@y-9 if @light
	end

	def draw(sx,sy)
		Img['projectiles/fireball'].draw_rot(@x+8-sx,@y-sy+9,3,if @vx>0 then ($count*8)%360 else -(($count*8)%360) end)
	end

	def det
		detect_player(@x,@y,16,18)
	end

	def size
		[16,18]
	end

	def stomp
	end

	def kick(a)
	end

	def pow(a,b,c,d,e)
	end
end

class Spiny < Entity
	def initialize(x,y,dir,stone,falling,room,active=false)
		@active=active
		@x,@y,@dir,@stone,@frame,@vy=x,y,dir,stone,if falling then 2 else 0 end,0
		init([:enemy,:powish],room)
	end
	
	def update(sx,sy)
		if @dead and @dead<120 then @dead+=1 elsif @dead then remove end
		if @y>$game.map.height+64 then remove end
		return if !act(@x,@y,32,32,sx,sy) or @dead && !@fall
		@vy+=$game.map.grav
		if @vy>0 and @y-64<$game.map.height
			@vy.to_i.times{if !$game.map.solid?(@x+2,@y+32,true) && !$game.map.solid?(@x+16,@y+32,true) && !$game.map.solid?(@x+30,@y+32,true) or @fall
			@y+=1 else @vy=0 and break end}
		elsif @vy<0
			@vy.to_i.abs.times{if !$game.map.solid?(@x+2,@y) && !$game.map.solid?(@x+16,@y) && !$game.map.solid?(@x+30,@y) or @fall
			@y-=1 else @vy=0 and break end}
		end
		
		if @frame != 2 then @frame=($count/12)%2 elsif down then @frame=0 end
		if @dir==1
			2.times{if !checkenemy(@x+36,@y+16) and !$game.map.solid?(@x+31,@y+1) && !$game.map.solid?(@x+31,@y+16) && !$game.map.solid?(@x+31,@y+31) or @fall
			@x+=1 else @dir=0 end}
		elsif @dir==0
			2.times{if !checkenemy(@x-4,@y+16) and !$game.map.solid?(@x+1,@y+1) && !$game.map.solid?(@x+1,@y+16) && !$game.map.solid?(@x+1,@y+31) or @fall
			@x-=1 else @dir=1 end}
		end
		if $game.map.solid?(@x+16,@y+16) and !@fall then kick(true) end
		
		det if !@dead
	end
	
	def draw(sx,sy)
		if @frame<2
			Tls['enemies/spiny',[32,32]][@frame+if @stone then 3 else 0 end].draw(@x-sx+[0,32][@dir],@y-sy+if@fall then 32 else 0 end,if !@fall then 2 else 4 end,[1,-1][@dir],if @fall then -1 else 1 end)
		else
			Tls['enemies/spiny',[32,32]][2+if @stone then 3 else 0 end].draw_rot(@x-sx+16,@y-sy+16,2,($count/8)%360)
		end
	end
	
	def stomp
	end
	
	def kick(bullet)
		if not bullet ==:fire && @stone
			Snd['kick'].play
			@vy=-8
			@frame=1
			if !bullet
				$game.player.combo[1]+=1
				combo(@x+16,@y,$game.player.combo[1])
			elsif bullet != :combo and bullet !=:star
				$points+=200
				Points.new(@x+16,@y,200)
			end
			if bullet==:star then $game.player.combo[2]+=1 and combo(@x+16,@y,$game.player.combo[2]) end
			@dead=0
			@fall=true
		else
			true
		end
	end
	
	def pow(x,y,width,height,force)
		return if @dead
		if x+width>@x and x<@x+32 and y<@y+32 and y+height>@y
			kick(true)
		end
	end

	def size
		[32,32]
	end

	def det
		detect_player(@x,@y,32,32)
	end

	def froze
		remove
		@dead=true
		Frozen.new(@x,@y,Tls['enemies/spiny',[32,32]][@frame+if @stone then 3 else 0 end],[1,1])
	end

	def down
		$game.map.solid?(@x+16,@y+33)
	end
end

class BuzzyBeetle < Entity
	def initialize(x,y,dir,ceiling,room,active=false)
		@active=active
		@x,@y,@dir,@ceiling,@frame,@vy=x,y,dir,ceiling,0,0
		init([:enemy,:powish],room)
	end
	
	def update(sx,sy)
		if @dead and @dead<120 then @dead+=1 elsif @dead then remove end
		return if !act(@x,@y,32,32,sx,sy) or @dead && !@fall
		if @y>$game.map.height+64 or @y+32<0 then remove end
		if @ceiling then @vy-=1 else @vy+=$game.map.grav end
		if @vy>0 and @y-64<$game.map.height
			@vy.to_i.times{if !$game.map.solid?(@x+2,@y+32,true) && !$game.map.solid?(@x+16,@y+32,true) && !$game.map.solid?(@x+30,@y+32,true) or @fall
			@y+=1 else @vy=0 and break end}
		elsif @vy<0
			@vy.to_i.abs.times{if !$game.map.solid?(@x+2,@y) && !$game.map.solid?(@x+16,@y) && !$game.map.solid?(@x+30,@y) or @fall
			@y-=1 else @vy=0 and break end}
		end
		if @ceiling and $game.player.x+32>@x-128 and $game.player.x<@x+160 and $game.player.y>@y+32
			Shell.new(@x,@y,2,$game.room,1,@dir==0)
			@dead=true
			remove
		end
		
		@frame=($count/12)%2
		if @dir==1
			2.times{if !checkenemy(@x+36,@y+16) and !$game.map.solid?(@x+31,@y+1) && !$game.map.solid?(@x+31,@y+16) && !$game.map.solid?(@x+31,@y+31) or @fall
			@x+=1 else @dir=0 end}
		elsif @dir==0
			2.times{if !checkenemy(@x-4,@y+16) and !$game.map.solid?(@x+1,@y+1) && !$game.map.solid?(@x+1,@y+16) && !$game.map.solid?(@x+1,@y+31) or @fall
			@x-=1 else @dir=1 end}
		end
		if $game.map.solid?(@x+16,@y+16) and !@fall then kick(true) end
		
		det if !@dead
	end
	
	def draw(sx,sy)
		Tls['enemies/buzzy beetle',[32,32]][@frame].draw(@x-sx+[0,32][@dir],@y-sy+if @fall or @ceiling then 32 else 0 end,if !@fall then 2 else 4 end,[1,-1][@dir],if @fall or @ceiling then -1 else 1 end)
	end
	
	def stomp
		$game.player.vy=-12
		Snd['stomp'].play
		$game.player.combo[0]+=1
		combo(@x+16,@y,$game.player.combo[0])
		Shell.new(@x,@y,2,$game.room,0,@dir==1)
		remove
	end
	
	def kick(bullet)
		if bullet !=:fire
			Snd['kick'].play
			@vy=-8
			@frame=1
			if !bullet
				$game.player.combo[1]+=1
				combo(@x+16,@y,$game.player.combo[1])
			elsif bullet != :combo and bullet !=:star
				$points+=200
				Points.new(@x+16,@y,200)
			end
			if bullet==:star then $game.player.combo[2]+=1 and combo(@x+16,@y,$game.player.combo[2]) end
			@dead=0
			@fall=true
		else
			true
		end
	end
	
	def pow(x,y,width,height,force)
		return if @dead
		if x+width>@x and x<@x+32 and y<@y+32 and y+height>@y
			kick(true)
		end
	end

	def size
		[32,32]
	end

	def det
		detect_player(@x,@y,32,32)
	end

	def froze
		remove
		@dead=true
		Frozen.new(@x,@y,Tls['enemies/buzzy beetle',[32,32]][@frame],[1,1])
	end

	def down
		$game.map.solid?(@x+16,@y+33)
	end
end

class Bowser < Entity
	def initialize(x,y,speed,jump,freq,attacks,room)
		@x,@y,@speed,@jump,@freq,@attacks=x,y,speed,jump,freq,attacks
		@anim,@time,@dir,@vy,@active,@look=Animation.new(Tls['enemies/bowser',[64,70]],[0,1,2,1]),0,:left,0,true,:left
		@fire,@freeze,@beet,@move,@seq=3,2,2,[120,0],:free
		init(nil,room)
	end

	def update(sx,sy)
		return if !$game.boss
		if @y>$game.map.height+64 then remove end
		if [:dead,:finnish,:secret].include?($game.boss) and !@unharm then @seq=:dying and @anim.seq=[9,10,11,12] and @unharm=true and @vy=-25 end
		if @froz and @froz>0 then @froz-=1 elsif @froz then @froz=nil end
		if !@init then remove
			init([:enemy],$game.room)
			@init=true end
		if $count%8==0 then @anim.next end
		@time-=1
		if @move[0]-1>0 then @move[0]-=1 else @move[1]=r=rand(3) and case r when 0 then @move[0]=120 when 1 then @move[0]=80 when 2 then @move[0]=30 end end
		if $game.player.x+16<@x+32 then @look=:left else @look=:right end
		
		if @move[1]==0 || @move[1]==1 && rand(80)<60 and !@unharm
			if @dir==:left
				@speed.times{det
				if !(map=$game.map).solid?(@x-1,@y) and !map.solid?(@x-1,@y+69) then @x-=1 else @dir=:right and break end}
			else
				@speed.times{det
				if !(map=$game.map).solid?(@x+65,@y) and !map.solid?(@x+65,@y+69) then @x+=1 else @dir=:left and break end}
			end
		end
		@vy+=$game.map.grav
		if @vy>0
			@vy.to_i.times{if !(map=$game.map).solid?(@x,@y+70) && !map.solid?(@x+64,@y+70) or @unharm then @y+=1 else @vy=0 and break end}
		elsif @vy<0
			(-@vy).to_i.times{if !(map=$game.map).solid?(@x,@y-1) and !map.solid?(@x+64,@y-1) then @y-=1 else @vy=0 and break end}
		end
		if @move[1]==1 && rand(60)==30 || @move[1]==2 && rand(30)==15 and $game.map.solid?(@x,@y+70) then @vy=-@jump end
		if rand(100)==50 then if @dir==:left then @dir=:right else @dir=:left end end
	
		if @fire==0 then damage and @fire=3 end
		if @freeze==0 then damage and @freeze=2 end
		if @beet==0 then damage and @beet=2 end
	
		if @seq==:free and rand(1000)<@freq and !@unharm
			while !@attacks[r=rand(6)]
			end
			case r
				when 0
				@anim.seq=[3,3,3,3,3,3,4,4]
				@seq=:flame
				when 1
				@anim.seq=[3,3,3,3,3,3,4,4]
				@seq=:flame3
			end
		end
	
		if @seq==:flame and !@shooted and @anim.cur==6
			Fire.new(@x,@y+4,@look,@speed*1.5,$game.room)
			@shooted=true
		end
		if @seq==:flame3 and !@shooted and @anim.cur==6
			Fire.new(@x,@y+4,@look,@speed*1.5,$game.room)
			Fire.new(@x,@y-32,@look,@speed*1.5,$game.room)
			Fire.new(@x,@y+40,@look,@speed*1.5,$game.room)
			@shooted=true
		end
		
		if @seq != :free and @anim.ended and !@unharm
			@anim.seq=[0,1,2,1]
			@shooted=false
			@seq=:free
		end
		
		if @attacks[6] and rand(1000)<@freq and !@unharm
			Bullet_Bill.new(@x+16,@y+10,if $game.player.x+16<@x+32 then 0 else 1 end,@attacks[7],@speed*1.5,$game.room)
		end
	
		if @unharm and [:finnish,:secret].include?($game.boss) and @y>$game.map.height then $game.player.end=:boss and remove
			$game.player.secret=true if ($game.boss)==:secret
			Msc['StageClear.ogg'].play end
		if @unharm and ![:finnish,:secret].include?($game.boss) and @y>$game.map.height
			remove
		end
	end

	def draw(sx,sy)
		return if !$game.boss
		@anim.frame.draw(@x-sx+if (d=@look==:left) then 0 else 64 end,@y-sy,2,if d then 1 else -1 end,1,if @time>0 and !@unharm then Color.new((($count*16)%511-255).abs,255,255,255) else 0xffffffff end)
		if @attacks[6] then Tls['enemies/blaster',[32,32]][0].draw(@x+16-sx,@y+8-sy,4) end
	end
	
	def stomp
		return if @time>0
		@vy=0
		$game.player.vy=-12
		damage
	end
	
	def kick(bullet)
		return true if @time>0
		if bullet==:fire then @fire-=1 and Snd['damage'].play end
		if bullet==:beet then @beet-=1 and Snd['damage'].play end
		if bullet==:bomb then damage end
		true if bullet != :combo
	end
	
	def pow(x,y,width,height,force)
	end

	def size
		[64,70]
	end

	def det
		detect_player(@x,@y,64,70)
	end

	def froze
		if @time<0 and !@froz
			@freeze-=1 
			Snd['damage'].play
		end
		@froz=30
	end

	def down
		$game.map.solid?(@x+16,@y+33)
	end

	def damage
		@time=120
		$game.boss.health-=1
		Snd['stun'].play
	end
end

class Fire < Entity
	def initialize(x,y,dir,speed,room,active=false)
		@x,@y,@dir,@speed,@active,@projectile=x,y,dir,speed,active,true
		@light=Light.new(x+17,y-1,2,[false],$game.map,room)
		init([:enemy],room)
	end

	def update(sx,sy)
		return if !act(@x,@y,68,30,sx,sy)
		if !@playin then @playin=true and Snd['flame'].play end
		if @x+69<sx or @x>sx+640 then remove
			return end
		if @dir==:left then @speed.to_i.times{det
			@x-=1} end
		if @dir==:right then @speed.to_i.times{det
			@x+=1} end
		@light.x=@x+17
		@light.y=@y-1
	end

	def draw(sx,sy)
		Tls['enemies/fire',[68,30]][($count/4)%5].draw(@x-sx+if (d=@dir==:left) then 0 else 68 end,@y-sy,3,if d then 1 else -1 end)
	end

	def det
		detect_player(@x,@y,68,30)
	end

	def size
		[68,30]
	end

	def stomp
	end

	def kick(a)
		true
	end

	def pow(a,b,c,d,e)
	end
end

class Blaster < Entity
	def initialize(x,y,type,spec,height,freq,dir,stand,rand,att,room)
		@x,@y,@type,@spec,@height,@freq,@dir,@stand,@rand,@att=x,y,type,spec,height,freq,dir,stand,rand,att
		init(nil,room)
		i=0
		(@height+1).times{
    $game.map.modify_mask(room,[@x/640,(@y+i*32)/480],:splice,Tls['tiles/mask',[32,32]][1],@x%640,(@y+i*32)%480)
		i+=1}
	end

	def update(sx,sy)
		return if !act(@x,@y,32,32+@height*32,sx,sy,true) or @dead
		if @rand && rand(1500)<@freq or !@rand && $count% (@freq*5)==0
			Bullet_Bill.new(@x,@y+2,if @dir<2 then @dir elsif @dir==2 then rand(2) else if $game.player.x+16<@x+16 then 0 else 1 end end,@spec,@att,$game.room)
		end
	end

	def draw(sx,sy)
		Tls['enemies/blaster',[32,32]][0].draw(@x-sx,@y-sy,4)
		if @height>0
			Tls['enemies/blaster',[32,32]][1].draw(@x-sx,@y-sy+32,3)
		end
		if @height>0
			i=1
			(@height-1).times{i+=1 and Tls['enemies/blaster',[32,32]][2].draw(@x-sx,@y-sy+i*32,3)}
		end
	end
end

class Bullet_Bill < Entity
	def initialize(x,y,dir,homing,speed,room,banzai=false)
		@x,@y,@dir,@homing,@speed,@banzai=x,y,dir,homing,speed,banzai
		@angle,@time=[270,90][@dir],[32-@speed,1].max
		init([:enemy],room)
	end

	def update(sx,sy)
		return if !act(@x,@y,32,28,sx,sy)
		if !@playin then @playin=true and Snd['bulletbill'].play end
		if !@dead
			if !@homing
				@speed.round.times{if @dir==0 then @x-=1 else @x+=1 end and det}
			else
				if @angle<0 then @angle+=360 elsif @angle>=360 then @angle-=360 end
				ang=angle(@x+16,@y+14,(pl=$game.player).x+16,pl.y+(64-pl.height/2))
				@time-=1
				if @time>-180 and angle_diff(@angle,ang)>4
					@angle+=4
				elsif @time>-180 and angle_diff(@angle,ang)<-4
					@angle-=4
				end
				@speed.times{@x+=offset_x(@angle,1) and @y+=offset_y(@angle,1) and det}
			end
		else @y+=$game.map.grav*8 end
		if @x+32<sx-640 or @x>sx+1280 or @y>sy+480 or @y+28<sy-480 then remove end
		if @time<=0 and $game.map.solid?(@x+16,@y+14)
			Pop.new(@x+16,@y+14,Img['projectiles/firepop'],1,16)
			remove
		end
	end

	def draw(sx,sy)
		if !@homing and !@banzai
			Tls['enemies/bullet bill',[32,28]][($count/8)%3].draw(@x-sx+[0,32][@dir],@y-sy+if @dead then 32 else 0 end,if @dead then 5 else 3 end,[1,-1][@dir],if @dead then -1 else 1 end)
		elsif !@banzai
			Tls['enemies/bullet bill',[32,28]][($count/8)%3].draw_rot(@x+16-sx,@y+14-sy,3,@angle+90,0.5,0.5)
		else
			Img['enemies/banzai bill'].draw(@x-sx+[0,128][@dir],@y-sy,if @dead then 5 else 3 end,[1,-1][@dir])
		end
	end
	
	def stomp
		return if @homing
		$game.player.vy=-12
		Snd['stomp'].play
		$game.player.combo[0]+=1
		combo(@x+16,@y,$game.player.combo[0])
		@dead=true
	end
	
	def kick(bullet)
		return if bullet==:fire
		Snd['kick'].play
		if !bullet
			$game.player.combo[1]+=1
			combo(@x+16,@y,$game.player.combo[1])
		elsif bullet != :combo and bullet !=:star
			$points+=200
			Points.new(@x+16,@y,200)
		end
		if bullet==:star then $game.player.combo[2]+=1 and combo(@x+16,@y,$game.player.combo[2]) end
		@dead=0
		@fall=true
	end

	def size
		if !@banzai then [32,28] else [128,128] end
	end

	def det
		detect_player(@x,@y,size[0],size[1])
	end

	def froze
	end

	def down
	end
end

class Phanto < Entity
	def initialize(sx,sy,speed,key)
		@speed,@skin,@key=speed,rand(4),key
		case rand(4)
			when 0
			@x=sx-32
			@y=sy+rand(448)
			@angle=(45...135).to_a[rand(90)]
			when 1
			@x=sx+640
			@y=sy+rand(448)
			@angle=(225...315).to_a[rand(90)]
			when 2
			@x=sx+rand(608)
			@y=sy-32
			@angle=(135...225).to_a[rand(90)]
			when 3
			@x=sx+rand(608)
			@y=sy+480
			@angle=((315...360).to_a+(0...45).to_a)[rand(90)]
		end
		init([:enemy],$game.room)
	end

	def update(sx,sy)
		if @key.ph and !@end
			ang=angle(@x+16,@y+14,(pl=$game.player).x+16,pl.y+(64-pl.height/2))
		elsif !@end
			ang=@end=@angle+180
		else
			ang=@end
		end
		
		if @angle<0 then @angle+=360 elsif @angle>=360 then @angle-=360 end
		if angle_diff(@angle,ang)>3
			@angle+=2
		elsif angle_diff(@angle,ang)<-3
			@angle-=2
		end
		if @end and @x<sx-32 || @x>sx+640 || @y>sy+480 || @y<sy-32 then remove end
		@speed.times{@x+=offset_x(@angle,1) and @y+=offset_y(@angle,1) and det}
	end

	def draw(sx,sy)
		Tls['enemies/phanto',[32,32]][@skin].draw(@x-sx,@y-sy,4)
	end
	
	def stomp
	end
	
	def kick(bullet)
	end

	def size
		[32,32]
	end

	def det
		detect_player(@x,@y,32,32)
	end

	def froze
	end

	def down
	end
end

class RotoBase < Entity
	def initialize(x,y,type,radius,speed,dir,count,room)
		@x,@y,@type,@radius,@speed,@dir=x,y,type,radius,speed,dir
		@control,@angle=[],0
		[count,count*radius][type].times{@control << Rotor.new(type,room)}
		init(nil,room)
	end

	def update(sx,sy)
		if @type==0
			@speed.times{@angle+=[1,-1][@dir]
			i=0
			@control.length.times{c=@control[i]
			angl=(360.0/@control.length)*i
			c.x=@x+offset_x(@angle+angl,@radius*16)
			c.y=@y+offset_y(@angle+angl,@radius*16)
			c.det
			i+=1}}
		else
			@speed.times{@angle+=[1,-1][@dir]
			i=0
			(@control.length/(@radius)).times{angl=(360.0/@control.length)*i
			j=0
			(@radius).times{c=@control[i+j]
			c.x=@x+8+offset_x(@angle+angl,j*16)
			c.y=@y+8+offset_y(@angle+angl,j*16)
			c.det
			j+=1}
			i+=@radius}}
		end
	end

	def draw(sx,sy)
	end
end

class Rotor < Entity
	attr_accessor :x, :y
	def initialize(type,room)
		@type=type
		@active=@projectile=true
		@x=@y=0
		@light=Light.new(x-8,y-9,1,[false],$game.map,room)
		init([:enemy],room)
	end

	def update(sx,sy)
		@light.x=@x-8
		@light.y=@y-9
		det
	end

	def draw(sx,sy)
		if @type==0 then Tls['enemies/rotodisc',[32,32]][($count/8)%21].draw(@x-sx,@y-sy,3) else Img['projectiles/fireball'].draw_rot(@x-sx+8,@y-sy+9,3,($count*8)%360) end
	end

	def det
		detect_player(@x,@y,size[0],size[1])
	end

	def size
		[[32,32],[16,18]][@type]
	end

	def stomp
	end

	def kick(a)
	end

	def pow(a,b,c,d,e)
	end
end

class Podobo < Entity
	def initialize(x,y,delay,room)
		@x,@y,@delay,@jump=x,y,delay,y+32
		@vy=0
		init([:enemy],room)
		@light=Light.new(x-2,y,3,[false],$game.map,room)
	end

	def update(sx,sy)
		return if !act(@x,@y,28,32,sx,sy)
		if @vy and @vy>=0
			@vy+=0.25 if @vy<10
			(@vy+1).to_i.times{det
			@y+=1
			if $game.map.lava?(@x+16,@y+32) and !@targ
				Sparkle.new(@x-28,@y+6,Tls['effects/splava',[84,26]],[0,1,2,3,4],4)
				@targ=@y+32
			end
			if @y==@targ or @y>$game.map.height
				@targ=nil
				@vy=nil
				@wait=0
				@light.remove
        break
			end}
		elsif !@vy and @wait<@delay*15
			@wait+=1
		elsif !@vy
			@wait=nil
			@vy=-10
			@light=Light.new(@x-2,@y,3,[false],$game.map,$game.room)
		elsif @vy<0
			(-@vy+1).to_i.times{det
			@y-=1
			if @y<=@jump
				@vy+=0.25
			end}
		end
		@light.x=@x-2
		@light.y=@y
	end

	def draw(sx,sy)
    cnd=(@vy and @vy>=0)
		Tls['enemies/podobo',[28,32]][($count/8)%3].draw(@x-sx,@y-sy+if cnd then 32 else 0 end,0,1,if cnd then -1 else 1 end)
	end

	def det
		detect_player(@x,@y,28,32)
	end

	def size
		[28,32]
	end

	def stomp
	end

	def kick(a)
	end

	def pow(a,b,c,d,e)
	end
end

class CheepCheep < Entity
	def initialize(x,y,type,speed,dir,room,active=false)
		@x,@y,@type,@speed,@dir,@active=x,y,type,speed,dir,active
		@movy,@vy=(-5+rand(11)).to_f/(rand(50)+1),0.0
		init([:enemy],room)
	end

	def update(sx,sy)
		return if !act(@x,@y,32,32,sx,sy)
		if @y>$game.map.height+64 then remove end
		if @dead and @dead<120 then @dead+=1 and if @fall then @y+=8 end elsif @dead then remove end
		if @type==0
			if rand(80)==40
				@movy=(-5+rand(11)).to_f/(rand(50)+1)
			end
			@speed.times{det
			if @dir==0 then @x-=1 else @x+=1 end
			@y+=@movy/@speed}
			if !$game.map.water?(@x+16,@y-1)
				@movy=rand(6).to_f/(rand(50)+1)
			end
		elsif @type==1
			@speed.times{det
			if @dir==0 then @x-=1 else @x+=1 end
			if @dir==0 and $game.map.solid?(@x-1,@y+16) then @dir=1 elsif @dir==1 and $game.map.solid?(@x+33,@y+16) then @dir=0 end}
		else
			if $game.player.x+32<@x+280 and $game.player.x>@x-280 and $game.player.y+64<@y+200 and $game.player.y>@y-200
				angl=angle(@x+16,@y+16,$game.player.x+16,$game.player.y+32)
				if angl<180 then @dir=1 else @dir=0 end
				offx=offset_x(angl,1)
				offy=offset_y(angl,1)
				@speed.times{det
				if $game.map.water?(@x+16+offx,@y+16) then @x+=offx end
				if $game.map.water?(@x+16,@y+16+offy) then @y+=offy end}
			end
		end
		@vy+=1 if @vy!=0
		@y+=@vy.to_i
	end

	def draw(sx,sy)
		Tls['enemies/cheep cheep',[32,32]][if !@dead then @type*2+($count/8)%2 else @type*2 end].draw(@x-sx+[0,32][@dir],@y-sy+if @dead then 32 else 0 end,if @dead then 5 else 3 end,[1,-1][@dir],if @dead then -1 else 1 end)
	end

	def det
		detect_player(@x,@y,32,32)
	end

	def size
		[32,32]
	end

	def stomp
		return if $game.map.water?(@x+16,@y+16)
	end

	def kick(bullet)
		if not bullet ==:fire && @type==1
			Snd['kick'].play
			@vy=-8.1
			if !bullet
				$game.player.combo[1]+=1
				combo(@x+16,@y,$game.player.combo[1])
			elsif bullet != :combo and bullet !=:star
				$points+=200
				Points.new(@x+16,@y,200)
			end
			if bullet==:star then $game.player.combo[2]+=1 and combo(@x+16,@y,$game.player.combo[2]) end
			@dead=0
			@fall=true
		else
			true
		end
	end

	def pow(a,b,c,d,e)
	end
end

class Pokey < Entity
	def initialize(x,y,type,speed,height,regen,room,active=false)
		@x,@y,@type,@move,@height,@regen,@active=x,y,type,speed,height,regen,active
		@dir,@parts,@reg=[:left,:right][rand(2)],[],0
		(@height+1).times{@parts << (-4+rand(9))}
		init([:enemy],room)
	end

	def update(sx,sy)
		return if !act(@x,@y,48,size[1],sx,sy)
		@reg+=1 if @height<@parts.length-1
		if @reg==@regen*15 then @height+=1 and @y-=48 and @reg=0 end
		if $count%8==0
			i=0
			@parts.length.times{if @parts[i]<4 then @parts[i]+=1 else @parts[i]=-4 end and i+=1}
		end
		if rand(100)<@move then if @dir==:right then @x+=1 else @x-=1 end end
		i,s1=-1,nil
		@parts.length.times{i+=1 and if $game.map.solid?(@x-1,@y+24+i*48) then s1=true end}
		i,s2=-1,nil
		@parts.length.times{i+=1 and if $game.map.solid?(@x+49,@y+24+i*48) then s2=true end}
		if s1 or !s2 && $game.player.x<@x+148 && $game.player.x>@x+48 then @dir=:right end
		if s2 or !s1 && $game.player.x>@x-100 && $game.player.x<@x then @dir=:left end
		if !$game.map.solid?(@x+24,@y+48+@height*48,true) and !$game.map.solid?(@x+4,@y+48+@height*48,true) and !$game.map.solid?(@x+44,@y+48+@height*48,true) then @y+=1 end
	end

	def draw(sx,sy)
		Tls['enemies/pokey',[48,48]][@type].draw(@x-sx+@parts[0],@y-sy,2)
		i=0
		@height.times{i+=1 and Tls['enemies/pokey',[48,48]][2+@type].draw(@x-sx+@parts[i],@y-sy+i*48,2)}
	end

	def det
		detect_player(@x,@y,48,size[1])
	end

	def size
		[48,48+@height*48]
	end

	def stomp
		if @type==0
			$game.player.vy=-12
			Snd['stomp'].play
			if @height==0
				$game.player.combo[0]+=1
				combo(@x+16,@y,$game.player.combo[0])
				@dead=true
				remove
			else
				@height-=1
				@y+=48
				@reg=0
			end
		end
	end

	def kick(bullet)
		Snd['kick'].play
		if @height==0
			if !bullet
				$game.player.combo[1]+=1
				combo(@x+16,@y,$game.player.combo[1])
			elsif bullet != :combo and bullet !=:star
				$points+=200
				Points.new(@x+16,@y,200)
			end
			if bullet==:star then $game.player.combo[2]+=1 and combo(@x+16,@y,$game.player.combo[2]) end
			remove
			@dead=true
		else
			@height-=1
			@y+=48
			Particle.new(@x,@y+48+rand(48*@height),Tls['enemies/pokey',[48,48]][2+@type])
			@reg=0
		end
	end

	def pow(a,b,c,d,e)
	end

	def froze
	end
end

class Boo < Entity
	def initialize(x,y,skin,dir,ai,speed,type,room)
		@x,@y,@skin,@dir,@ai,@speed,@type=x,y,skin,dir,ai,speed,type
		@action,@angle=0,90+@dir*180
		@unharm=(@type==1)
		if @type==3
			wd=[32,32,32,144,65][@skin]
			hg=[32,32,32,128,6][@skin]
			@light=Light.new(@x+wd/2-16,@y+hg/2-16,[2,2,2,5,3][@skin],[false],$game.map,room)
		end
		if @skin==4 then @air=0 end
		init([:enemy],room)
	end

	def update(sx,sy)
		return if !act(@x,@y,size[0],size[1],sx,sy)
		wd=[32,32,32,144,65][@skin]
		hg=[32,32,32,128,6][@skin]
		if @angle<=180 then @dir=1 else @dir=0 end
		if $game.player.x+16<@x+wd/2 then @dirion=:left else @dirion=:right end
		if @x+wd>$game.map.width or @x<$game.map.minx or @y+hg>$game.map.height or  @y<$game.map.miny then @angle+=180 end
		if @light then @light.x=@x+wd/2-16 and @light.y=@y+hg/2-16 end
		if @type==4 and rand(100)==50 then @unharm=!@unharm end
		case @ai
			when 0
			if @action==0 and rand(80)==40 then @action=1 end
			if @action==1 and rand(70)==35 then @action=0 elsif @action==1
				if rand(100)==50 then @angle=rand(360) end
				vx=offset_x(@angle,1)
				vy=offset_y(@angle,1)
				@speed.times{det
				@x+=vx and @y+=vy}
			end
			when 1
			@action=1
			if rand(80)==40 then @angle=rand(360) end
			vx=offset_x(@angle,1)
			vy=offset_y(@angle,1)
			@speed.times{det
			@x+=vx and @y+=vy}
			when 2
			if @dirion==$game.player.dir then @action=1 else @action=0 end
			if @action==1
				@angle=angle(@x+wd/2,@y+hg/2,$game.player.x+16,$game.player.y+(64-$game.player.height/2))
				vx=offset_x(@angle,1)
				vy=offset_y(@angle,1)
				@speed.times{det
				@x+=vx and @y+=vy}
			end
			when 3
			rang=300-[@speed,4].min*60
			if (pl=$game.player).rightpos>@x-rang and pl.leftpos<@x+wd+rang and pl.uppos<@y+hg+rang and pl.y+64>@y-rang
				@angle=(angle(@x+wd/2,@y+hg/2,$game.player.x+16,$game.player.y+(64-$game.player.height/2))+180)%360
				@action=1
			else @action=0 end
			if @action==1
				vx=offset_x(@angle,1)
				vy=offset_y(@angle,1)
				@speed.times{det
				@x+=vx and @y+=vy}
			end
		end
	end

	def draw(sx,sy)
		wd=[32,32,32,144,65][@skin]
		if @skin<3 then Tls['enemies/boo',[32,32]][@skin*2+if @action==1 then if @ai==2 then 1 else ($count/10)%2 end else 0 end] elsif @skin==3 then Tls['enemies/bigboo',[144,128]][0] else Img['enemies/balloonboo'] end.draw(@x-sx+if (d=(@dir==0)) then wd else 0 end,@y-sy,if @type==1 then 1 else 2 end,if d then -1 else 1 end,1,case @type when 0 then 0xffffffff when 1 then 0x40c0c0c0 when 2 then 0x80ffffff when 3 then 0xffc0c0ff when 4 then if @unharm then 0x60c0c0c0  else 0xffffffff end end)
	end

	def det
		detect_player(@x,@y,size[0],size[1])
	end

	def size
		case @skin
			when 0,1,2
			[32,32]
			when 3
			[144,128]
		end
	end

	def stomp
	end

	def kick(bullet)
	end

	def pow(a,b,c,d,e)
	end
end

class HammerBros < Entity
	def initialize(x,y,type,attack,room,active=false)
		@active,@dir,@startx,@move,@falling=active,rand(2),x,0,0
		@x,@y,@type,@attack,@vy=x,y,type,attack,0
		init([:enemy,:powish],room)
	end
	
	def update(sx,sy)
		@falling-=1
		if @dead and @dead<120 then @dead+=1 elsif @dead then remove end
		if @y>$game.map.height+64 then remove end
		@vy+=$game.map.grav
		if @vy>0 and @y-64<$game.map.height
			@vy.to_i.times{if !$game.map.solid?(@x+2,@y+68,true) && !$game.map.solid?(@x+16,@y+68,true) && !$game.map.solid?(@x+30,@y+68,true) or @fall or @falling>0
			@y+=1 else @vy=0 and break end}
		elsif @vy<0
			@vy.to_i.abs.times{@y-=1 and det}
		end
		
		return if !act(@x,@y,32,32,sx,sy) or @dead or @fall
		if $game.player.x+16<@x+16 then @dir=0 else @dir=1 end
		if rand(101-@attack*2)==0 and !@weapon and @x<sx+640 and @x+32>sx and @y>sy and @y+68<sy+480
			@weapon=0
		elsif @weapon and @weapon<14
			@weapon+=1
		elsif @weapon
			[Snd['hammer'],nil,Snd['fireball']][@type].play if @type != 1
			HammerBrosProjectile.new(@x+16,@y+28,@type,@dir,self)
			@weapon=nil
		end
		if rand(110)==55 and down and @vy<=0
			if rand(2)==0 and !$game.map.solid?(@x+16,@y+108)
				@falling=10
			else
				@vy=-20
			end
		end
		if rand(18)==9 then @moving=[true,false][rand(2)] end
		if @moving
			if rand(14)==7 then @move=rand(2) end
			if @move==0 and @x>@startx-64 and !$game.map.solid?(@x-1,@y+16) then @x-=2 elsif @move==1 and @x<@startx+64 and !$game.map.solid?(@x+33,@y+16) then @x+=1 end
		end
		
		det if !@dead
	end
	
	def draw(sx,sy)
		Tls['enemies/hammerbros',[32,68]][if @weapon then 2+@type else ($count/8)%2 end].draw(@x-sx+[0,32][@dir],@y-sy+if@fall then 68 else 0 end,4,[1,-1][@dir],if @fall then -1 else 1 end)
	end
	
	def stomp
		$game.player.vy=-12
		Snd['stomp'].play
		$game.player.combo[0]+=1
		combo(@x+16,@y,$game.player.combo[0])
		@dead=0
		@fall=true
	end
	
	def kick(bullet)
		Snd['kick'].play
		@vy=-8
		if !bullet
			$game.player.combo[1]+=1
			combo(@x+16,@y,$game.player.combo[1])
		elsif bullet != :combo and bullet !=:star
			$points+=800
			Points.new(@x+16,@y,800)
		end
		if bullet==:star then $game.player.combo[2]+=1 and combo(@x+16,@y,$game.player.combo[2]) end
		@dead=0
		@fall=true
	end
	
	def pow(x,y,width,height,force)
		return if @dead
		if x+width>@x and x<@x+32 and y<@y+68 and y+height>@y
			kick(true)
		end
	end

	def size
		[32,68]
	end

	def det
		detect_player(@x,@y,32,68)
	end

	def froze
		remove
		@dead=true
		Frozen.new(@x,@y,Tls['enemies/hammerbros',[32,68]][if @weapon then 2+@type else ($count/8)%2 end],[1,2,125])
	end

	def down
		$game.map.solid?(@x+16,@y+68)
	end
end

class HammerBrosProjectile < Entity
	def initialize(x,y,type,dir,bro)
		@x,@y,@type=x,y,type
		@active=true
		@projectile=true
		init([:enemy],$game.room)
		case @type
			when 0
			@vx=(4+rand(7))*[-1,1][dir]
			@vy=-10-rand(10)
			when 1
			@dir=dir
			@vx=[-12,12][dir]
			@vy=-6
			when 2
			@vx=[-6,6][dir]
			@vy=0
		end
		@light=Light.new(x-8,y-9,0.5,[false],$game.map,$game.room) if @type==2
		if @type==1
			@startx=x
			@starty=bro.y
			@brox=bro
		end
	end

	def update(sx,sy)
		if @y>$game.map.height+64 or @type==1 && @y<$game.map.miny-64 then remove end
		if @vx>0
			@vx.to_i.times{@x+=1 and det}
		elsif @vx<0
			@vx.to_i.abs.times{@x-=1 and det}
		end
		if @vy>0
			@vy.to_i.times{@y+=1 and det
			if @type==2 and $game.map.solid?(@x+8,@y+18) then @vy=-12 end}
		else
			@vy.to_i.abs.times{@y-=1 and det}
		end
	
		case @type
			when 0,2
			@vy+=$game.map.grav
			when 1
			if @dir==0 && @vx<0 or @dir==1 && @vx>0
				@vy+=0.2
			else
				@vy-=0.2
			end
			if @dir==0 then @vx+=0.2 else @vx-=0.2 end
		end
		if @type==1 and [180,0].include?(($count*12)%360) then Snd['boomerang'].play end
		@light.x=@x-8 if @light
		@light.y=@y-9 if @light
		if @type==1 and @dir==0 && @vx>0 || @dir==1 && @vx<0 and @x==@startx and @brox.y==@starty then remove end
	end

	def draw(sx,sy)
		img=Img["projectiles/#{['hammer','boomerang','fireball'][@type]}"]
		img.draw_rot(@x+img.width/2-sx,@y-sy+img.height/2,3,if @type !=1 and @vx>0 then ($count*12)%360 else -(($count*12)%360) end)
	end

	def det
		detect_player(@x,@y,16,18)
	end

	def size
		[16,18]
	end

	def stomp
	end

	def kick(a)
	end

	def pow(a,b,c,d,e)
	end
end