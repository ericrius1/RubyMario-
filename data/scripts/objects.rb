class Bricks < Entity
	def initialize(x,y,type,coins,room)
		@x,@y,@type,@coins,@solid,@y2=x,y,type,if coins>0 then coins else nil end,true,y
		@active=true
		init([:powable,:destroyable],room)
    $game.map.modify_mask(room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][1],@x%640,@y%480)
	end
	
	def update(sx,sy)
		if @y2<@y then @y2+=1 end
	end
	
	def pow(x,y,width,height,force)
		if !@coins
			if force and x+width>@x+2 and x<@x+30 and y<@y+32 and y+height>@y
				destroy
				$game.player.vy=$game.player.vy.abs/2
				$points+=10
				$game.entities[$game.room][7].each{|e| e.pow(@x,@y-16,32,32,true)}
			elsif $game.player.mode==:small or $game.player.mode==:mini and x+width>@x and x<@x+32 and y<@y+32 and y+height>@y
				Snd['bump'].play
				@y2-=8
				$game.entities[$game.room][7].each{|e| e.pow(@x,@y-16,32,32,true)}
			end
		elsif @coins>0
			if x+width>@x and x<@x+32 and y<@y+32 and y+height>@y
				$game.entities[$game.room][7].each{|e| e.pow(@x,@y-16,32,32,true)}
				Snd['coin'].play
				@y2=@y-8
				Coin.new(@x,@y,0,true,$game.room)
				@coins-=1
			end
		end
	end
	
	def draw(sx,sy)
		if @coins==0 then Tls['objects/powerupblock',[32,32]][4] else Tls['objects/bricks',[32,32]][@type] end.draw(@x-sx,@y2-sy,2)
	end

	def destroy
    $game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][0],@x%640,@y%480)
		Snd['breakblock'].play
		remove
		if @coins==0
			6.times{Particle.new(@x+rand(32),@y+rand(32),Img['effects/broken'],0xffc0c000)}
		else
			8.times{Particle.new(@x+rand(32),@y+rand(32),Tls['objects/bricks',[16,8]][@type*2])}
		end
		$points+=10
	end

	def size
		[32,32]
	end
end

class PowerUp_Block < Entity
	def initialize(x,y,item,hidden,room)
		@x,@y,@item,@hidden,@y2=x,y,item,hidden,y
		@solid,@active=!hidden,true
		if @item==2 then @light=Light.new(x,y,2,[false],$game.map,room) end
		init([:powable,:destroyable],room)
    $game.map.modify_mask(room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][1],@x%640,@y%480) if !hidden
	end
	
	def update(sx,sy)
		if @y2<@y then @y2+=1 end
		player=$game.player
		if @hidden and player.vy<0 and player.rightpos>@x+2 and player.leftpos<@x+30 and player.uppos<@y+32 and player.y+64>@y
			$game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][1],@x%640,@y%480)
			player.vy=player.vy.abs/2
			Snd['bump'].play if @item==-1
			pow(player.x,player.y,player.rightpos-player.leftpos,player.height,!player.small).class
		end
	end
	
	def pow(x,y,width,height,force)
		if @item>-1 and (x+width>@x+2 and x<@x+30 and y<@y+32 and y+height>@y)
			if @item !=7 then Snd['sprout'].play else Snd['coin'].play end
			case @item
				when 7
				Coin.new(@x,@y,0,true,$game.room)
				when 0,1,2,3,4,5,6,13
				if @light then @light.remove
					@light=nil end
				PowerUp.new(@x,@y,@item+1,if $game.player.x+16<@x+16 then :right else :left end,$game.room)
				when 8,9,10,11
				if !$game.player.small then PowerUp.new(@x,@y,@item+1,:right,$game.room) else PowerUp.new(@x,@y,1,if $game.player.x+32<@x+16 then :right else :left end,$game.room) end
				when 12,14
				PowerUp.new(@x,@y,@item+1,:right,$game.room)
			end
			@item=-1
			@y2-=8
			$game.entities[$game.room][7].each{|e| e.pow(@x,@y-16,32,32,true)}
			@hidden=nil
			@solid=true
		elsif @hidden and (x+width>@x+2 and x<@x+30 and y<@y+32 and y+height>@y)
			@hidden=nil
			@solid=true
			@y2-=8
		end
	end
	
	def draw(sx,sy)
		if @item>-1 and !@hidden
			Tls['objects/powerupblock',[32,32]][$count/8%4].draw(@x-sx,@y2-sy,2)
		elsif !@hidden
			Tls['objects/powerupblock',[32,32]][4].draw(@x-sx,@y2-sy,2)
		end
	end

	def destroy
			$game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][0],@x%640,@y%480)
		Snd['breakblock'].play
		remove
		6.times{Particle.new(@x+rand(32),@y+rand(32),Img['effects/broken'],0xffc0c000)}
		$points+=10
	end

	def size
		[32,32]
	end
end

class Coin < Entity
	def initialize(x,y,type,from,room)
		return if [1,2].include?(type) and $profile and $profile['collected'].find{|a| a[0]==$game.level['name'] and a[1]==room and a[2]==x and a[3]==y}
		@g=0
		@x,@y,@type,@from,@room=x,y,type,from,room
		if from then Points.new(@x+16,@y,200) and $coins+=1 and $points+=200 and @fly=0 end
		init([if @type==0 then :pswitchable end,if !from then :powish end],room)
	end
	
	def update(sx,sy)
		if !@from
			if @y+30>$game.player.uppos and @y+2<$game.player.y+64 and $game.player.rightpos>@x+2 and $game.player.leftpos<@x+30
				remove
				Sparkle.new(@x,@y,Tls['effects/coinsparks',[32,32]],[0,1,2,3,4,5,6],3)
				collect
			end
		else
			@y-=6
			@fly+=1
			if @fly==20 then remove
				Sparkle.new(@x,@y,Tls['effects/coinsparks',[32,32]],[0,1,2,3,4,5,6],3) end
		end
	end
	
	def draw(sx,sy)
		Tls['bonus/coin',[32,32]][@type*4+$count/8%4].draw(@x-sx,@y-sy,if @from then 4 else 2 end)
	end

	def change
		if @type==0
			PBlock.new(@x,@y,0,@room)
			remove
			return 'goodbye'
		end
	end
	
	def pow(x,y,width,height,force)
		if x+width>@x and x<@x+32 and y<@y+32 and y+height>@y
			collect
			@from=true
			@fly=6
		end
	end

	def collect
		Snd['coin'].play
		case @type
			when 0
			$coins+=1
			$points+=200
			when 1
			$coins+=3
			$points+=500
			if $profile
				$profile['gcoins']+=1
				$profile['collected']<<[$game.level['name'],@room,@x,@y]
				$profile['worlds'][$world]+=100.0/$game.map.world($world)
			end
			when 2
			$coins+=5
			$points+=500
			if $profile
				$profile['bcoins']+=1
				$profile['collected']<<[$game.level['name'],@room,@x,@y]
				$profile['worlds'][$world]+=100.0/$game.map.world($world)
			end
		end
	end
end

class PowerUp < Entity
	def initialize(x,y,type,dir,room)
		@x,@y,@type,@dir,@vy=x,y,type,dir,0
		if @type==3 then @light=Light.new(x,y,1,[false],$game.map,room) end
		init([:powish],room)
	end
	
	def update(sx,sy)
		return if !act(@x,@y,32,32,sx,sy)
		if @y>$game.map.height+64 then remove end
		map=$game.map
		mp=map.solid?(@x+16,@y+31)
		if @dir!=:down
			case @type
				when 1,2,3,4,5,6,7,14
				if @dir==:left and not mp
					if not map.solid?(@x-2-if @type==14 then 2 elsif @type==6 then -8 else 0 end,@y+30) then @x-=if @type==14 then 4 else 2 end else @dir=:right end
				elsif not mp
					if not map.solid?(@x+34+if @type==14 then 2 elsif @type==6 then -8 else 0 end,@y+30) then @x+=if @type==14 then 4 else 2 end else @dir=:left end
				else
					@y-=1
				end
				@vy+=$game.map.grav
				if @vy>0 and @y-64<map.height
					@vy.to_i.times{if not map.solid?(@x+if @type==6 then 10 else 0 end,@y+32,true) and not map.solid?(@x+16,@y+32,true) and not map.solid?(@x+32-if @type==6 then 10 else 0 end,@y+32,true)
						@y+=1 else @vy=if @type==14 then -15 else 0 end end}
				elsif @vy<0
					@vy.to_i.abs.times{if not map.solid?(@x+if @type==6 then 10 else 0 end,@y) and not map.solid?(@x+16,@y) and not map.solid?(@x+32-if @type==6 then 10 else 0 end,@y)
						@y-=1 else @vy=0 end}
				end
				when 9,10,11,12,13,15
				if mp then @y-=1 end
			end
		else
			@y+=2
		end
		if @light then @light.x=@x and @light.y=@y end
		
		if !mp and @y+30>$game.player.uppos and @y+2<$game.player.y+64 and $game.player.rightpos>@x+2 and $game.player.leftpos<@x+30
			pl=$game.player
			if ![2,15,7,14,13].include?(@type) and [nil,:normal,nil,:glow,:swimmer,:ninja,:mini,nil,nil,:fire,:frosting,:bomb,:beet][@type] != pl.mode
				Snd['collectpowerup'].play
				pl.transforming=20
			end
		
			case @type
				when 1
				if [:small,:mini].include?(pl.mode)
					if pl.mode==:mini then $hold=:mini end
					pl.mode=:normal
				elsif !$hold
					Snd['holditem'].play
					$hold=:normal
				end
				if @dir!=:down
					Points.new(@x+16,@y,1000)
					$points+=1000
				end
				when 2
				Snd['1up'].play
				$lives+=1
				LifeUp.new(@x,@y,0)
				when 3
				if pl.mode != :small
					Snd['holditem'].play
					$hold=pl.mode
				end
				pl.mode=:glow
				pl.mode=:glow
				pl.light=Light.new(pl.x,pl.y+16,4,[false],$game.map,$game.room)
				if @dir!=:down
					Points.new(@x+16,@y,1000)
					$points+=1000
				end
				when 5
				if pl.mode != :small
					Snd['holditem'].play
					$hold=pl.mode
				end
				pl.mode=:ninja
				if @dir!=:down
					Points.new(@x+16,@y,1000)
					$points+=1000
				end
				when 6
				if pl.mode != :small
					Snd['holditem'].play
					$hold=pl.mode
				end
				pl.mode=:mini
				if @dir!=:down
					Points.new(@x+16,@y,1000)
					$points+=1000
				end
				when 7
				player_down
				Pop.new(@x+12,@y+13,Img['projectiles/firepop'],1.5,16)
				when 9
				if pl.mode != :small
					Snd['holditem'].play
					$hold=pl.mode
				end
				pl.mode=:fire
				if @dir!=:down
					Points.new(@x+16,@y,1000)
					$points+=1000
				end
				when 10
				if pl.mode != :small
					Snd['holditem'].play
					$hold=pl.mode
				end
				pl.mode=:frosting
				if @dir!=:down
					Points.new(@x+16,@y,1000)
					$points+=1000
				end
				when 11
				if pl.mode != :small
					Snd['holditem'].play
					$hold=pl.mode
				end
				pl.mode=:bomb
				if @dir!=:down
					Points.new(@x+16,@y,1000)
					$points+=1000
				end
				when 12
				if pl.mode != :small
					Snd['holditem'].play
					$hold=pl.mode
				end
				pl.mode=:beet
				if @dir!=:down
					Points.new(@x+16,@y,1000)
					$points+=1000
				end
				when 13
				if $game.time>=0 then $game.time+=50  end
				Snd['clock'].play
				when 14
				pl.starman=570
				Msc['Invincible.ogg'].play(true)
				when 15
				Snd['1up'].play
				$lives+=3
				LifeUp.new(@x,@y,1)
			end
			remove
		end
	end
	
	def draw(sx,sy)
		a=if @dir==:down then if $count%8<4 then 255 else 0 end else 255 end
		if @type==9
			Tls['bonus/flower',[32,32]][($count/4)%6].draw(@x-sx,@y-sy,1,1,1,Color.new(a,255,255,255))
		elsif @type==14
			Tls['bonus/star',[32,32]][($count/4)%4].draw(@x-sx,@y-sy,1,1,1,Color.new(a,255,255,255))
		else
			Tls['bonus/powerups',[32,32]][@type].draw(@x-sx,@y-sy,1,1,1,Color.new(a,255,255,255))
		end
	end

	def pow(x,y,width,height,force)
		if !$game.map.solid?(@x+16,@y+31) and x+width>@x and x<@x+32 and y<@y+32 and y+height>@y
			@vy-=15
			if @dir != :down
				if x+width>@x+16 then @dir=:left else @dir=:right end
			end
		end
	end
end

class OnOff < Entity
	def initialize(x,y,color,on,hidden,room)
		@x,@y,@color,@on,@solid,@y2=x,y,color,if on==0 then true else false end,!hidden,y
		init([:changeable,:powable],room)
    $game.map.modify_mask(room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][1],@x%640,@y%480) if @solid
	end
	
	def update(sx,sy)
		if @y2<@y then @y2+=1 end
		player=$game.player
		if !@solid and player.vy<0 and player.rightpos>@x+2 and player.leftpos<@x+30 and player.uppos<@y+32 and player.y+64>@y
			$game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][1],@x%640,@y%480)
			@solid=true
			player.vy=player.vy.abs/2
			pow(player.x,player.y,player.rightpos-player.leftpos,player.height,!player.small)
		end
	end
	
	def pow(x,y,width,height,force)
		if x<@x+30 and x+width>@x+2 and y<=@y+32 and y+height>=@y
			Snd['switchpress'].play
			$game.entities[$game.level['rooms'].length].each{|e| e.change(@color)}
			@change=true
			@y2-=8
			$game.entities[$game.room][7].each{|e| e.pow(@x,@y-16,32,32,true)}
		end
	end
	
	def draw(sx,sy)
		return if !@solid
		if @on then a=0 else a=1 end
		Tls['objects/changes',[32,32]][a].draw(@x-sx,@y2-sy,1,1,1,@color)
		Tls['objects/changes-const',[32,32]][a].draw(@x-sx,@y2-sy,1)
	end
	
	def change(color)
		if color.red==@color.red and color.blue==@color.blue and color.green==@color.green then @on=!@on end
	end
end

class Changing < Entity
	def initialize(x,y,color,on,room)
		@x,@y,@color,@solid=x,y,color,if on==0 then true else false end
		init([:changeable],room)
    $game.map.modify_mask(room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][1],@x%640,@y%480) if @solid
		@set=@solid
	end
	
	def update(sx,sy)
		if @solid and !@set
			$game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][1],@x%640,@y%480)
			@set=true
		elsif !@solid and @set
			$game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][0],@x%640,@y%480)
			@set=nil
		end
	end
	
	def draw(sx,sy)
		if @solid then a=2 else a=3 end
		Tls['objects/changes',[32,32]][a].draw(@x-sx,@y-sy,1,1,1,@color)
		if a==2 then Tls['objects/changes-const',[32,32]][2].draw(@x-sx,@y-sy,1) end
	end
	
	def change(color)
		if color.red==@color.red and color.blue==@color.blue and color.green==@color.green then @solid=!@solid end
	end
end

class Qswitch < Entity
	attr_accessor :x,:y,:vx,:vy
	def initialize(x,y,id,time,anchor,once,still,trig,room,from=nil)
		@x,@y,@id,@time,@anchor,@once,@from,@still,@trigger=x,y,id,time,anchor,once,from,still,trig
		@vx=@vy=0
		init(if !anchor then [:carry] else nil end,room)
	end
	
	def update(sx,sy)
		return if !act(@x,@y,32,32,sx,sy)
		if @y>$game.map.height+64 then remove end
		player=$game.player
		if !@from and !$game.player.carry(self) and player.rightpos>@x and player.leftpos<@x+24 and player.y+64>@y and player.uppos<@y+24 and player.vy>0 and not @down
			Snd['button'].play
			@down=true
			Msc["Switch#{1+@time}.ogg"].play if !@still
			$game.qswitches[@id]=if @still then :true else true end
			if @trigger[0]>-1 then $game.triggers[@trigger[0]]=2 end
		end
		
		if !$game.qswitches[@id]
			if @down and @trigger[1]>-1 then $game.triggers[@trigger[1]]=2 end
			if @down and @once then remove
				Sparkle.new(@x-12,@y-12,Tls['effects/poof',[48,48]],[0,1,2,3],3) end
			@down=nil
		end
	
		if @from and @from>0
			@y-=2
			@from-=1
		elsif @from
			@from=nil
		end
	
		if @still and @down and @once then remove
				Sparkle.new(@x-12,@y-12,Tls['effects/poof',[48,48]],[0,1,2,3],3) end
		
		physics if not $game.player.carry(self) || @from
	end
	
	def draw(sx,sy)
		Tls['objects/switches',[24,24]][if @down then 4 else 0 end].draw(@x-sx,@y-sy,1)
		if @anchor then Img['objects/anchor'].draw(@x+10-sx,@y+17-sy,3) end
	end
	
	def room=(new)
		remove
		init([:carry],new)
	end

	def size
		[20,24]
	end
end

class Fireball < Entity
	def initialize(x,y,dir)
		@x,@y,@dir,@vy=x,y,dir,0
		@light=Light.new(x-8,y-9,0.5,[false],$game.map,$game.room)
		init(nil,$game.room)
	end

	def  update(sx,sy)
		if @dir==:right then @x+=6 else @x-=6 end
		@vy+=$game.map.grav if @vy<8
		if @vy>0
			@vy.to_i.times{if !$game.map.solid?(@x+8,@y+16,true) then @y+=1 else @vy=-10 end}
		elsif @vy<0
			@vy.to_i.abs.times{if !$game.map.solid?(@x+8,@y-1) then @y-=1 else pop and break end}
		end
		if @y-16>$game.map.height then remove end
		if f=$game.entities[$game.room][6].find{|e| e.active and !e.dead and e.respond_to?(:detect) && e.detect(@x,@y,18,19) || e.x<@x+16 && e.x+e.size[0]>@x && e.y<@y+16 && e.y+e.size[1]>@y}
		if f.kick(:fire) then pop end
	end
		if @y>$game.map.height or $game.map.solid?(@x,@y+9) or $game.map.solid?(@x+8,@y+2) or $game.map.solid?(@x+16,@y+8) then pop end
		@light.x=@x-8 if @light
		@light.y=@y-9 if @light
	end

	def draw(sx,sy)
		Img['projectiles/fireball'].draw_rot(@x+8-sx,@y-sy+9,2,if @dir==:right then ($count*8)%360 else -(($count*8)%360) end)
	end

	def pop
		return if !$game.entities[$game.room].include?(self)
		Pop.new(@x+8,@y+9,Img['projectiles/firepop'],1,16)
		$game.player.limit-=1
		remove
	end
end

class Shell < Entity
	attr_accessor :x,:y,:vx,:vy
	attr_reader :stand, :uncarry
	def initialize(x,y,type,room,speed,dir)
		@x,@y,@type,@anim,@stand,@vy=x,y,type,Animation.new(Tls['enemies/shell',[32,32]],[0]),if type==2 and speed==1 then false else true end,0
		@offing,@speed,@left,@time=if speed then 0 else nil end,speed,dir,5
		@combo,@start=0,if type==2 and speed==1 then [true,true] end
		@uncarry,@untime=true,0
		init([:enemy,:powish,:carry],room)
	end

	def update(sx,sy)
		@untime-=1
		if $game.player.carry(self)
			@time=15
			@untime=120
			@unharm==@through=true
			if killem_all
				$game.player.uncarry
				kick(true)
			end
		else
			@through=!@stand
			@unharm=(@stand or @untime>0)
		end
	
		if @fall then @uncarry=true else @uncarry=!@stand end
		return if !act(@x,@y,32,32,sx,sy) or $game.player.carry(self)
		if @y>$game.map.height+64 then remove end
		player=$game.player
		map=$game.map
		if map.solid?(@x+16,@y+16) and !@fall then kick(true) end
		if @stand then @combo=0 and det end
		if @stand then @anim.seq=[0+curnt] else @anim.seq=[2+curnt,3+curnt,4+curnt] end
		if @stand and !@fall and @y+32>player.uppos and @y+8<player.y+64 and player.rightpos>@x and player.leftpos<@x+32 and !@time
			Snd['kick'].play
			@stand=false
			if player.x+32<@x+16 then @left=false else @left=true end
			@time=10
		end
		if !@stand and if @start then !@start[0] else true end
			if !@left then 8.times{if !@time then det end
				if !map.solid?(@x+33,@y+31) and !map.solid?(@x+33,@y+16) and !map.solid?(@x+33,@y+1) or @fall then @x+=1 else @left=true and Sparkle.new(@x+12,@y-4,Tls['effects/shellbounce',[40,40]],[0,1,2,3],1) and Snd['bump'].play and $game.entities[$game.room][1].each{|e| e.pow(@x+4,@y,32,32,true)} and break end
			killem_all} end
			if @left then 8.times{ if !@time then det end
				if !map.solid?(@x-1,@y+31) and !map.solid?(@x-1,@y+16) and !map.solid?(@x-1,@y+1) or @fall then @x-=1 else @left=false
					Sparkle.new(@x-20,@y-4,Tls['effects/shellbounce',[40,40]],[0,1,2,3],1) and Snd['bump'].play and $game.entities[$game.room][1].each{|e| e.pow(@x-4,@y,32,32,true)} and break end
			killem_all} end
		end
		@vy+=$game.map.grav
		if @vy>0 and @y-64<map.rooms[$game.room]['height']*32
			@vy.to_i.times{if !map.solid?(@x+2,@y+32,true) and !map.solid?(@x+16,@y+32,true) and !map.solid?(@x+30,@y+32,true) or @fall
			@y+=1 and killem_all else
				if @start then @start[0]=nil end
				@vy=0 and break end}
		elsif @vy<0
			@vy.to_i.abs.times{if !map.solid?(@x+2,@y) and !map.solid?(@x+16,@y) and !map.solid?(@x+30,@y) or @fall
			@y-=1 and killem_all else $game.entities[$game.room][1].each{|e| e.pow(@x,@y-4,32,32,true)} and@vy=0 and break end}
		end
		if @time and @time>0 then @time-=1 elsif @time then @time=nil end
		if @offing
			if @stand and @vy>-1 and not @type==2 && @speed==1 then @offing+=1 else @offing=0 end
			if @offing>200 then @anim.seq=[curnt,curnt+1] end
			if @offing>240
				remove
				case @type
					when 0
					KoopaTroopa.new(@x,@y-16,false,if @left then 1 else 0 end,0,@speed,$game.room)
					when 1
					KoopaTroopa.new(@x,@y-16,true,if @left then 1 else 0 end,0,@speed,$game.room)
					when 2
					BuzzyBeetle.new(@x,@y,if @left then 1 else 0 end,false,$game.room)
				end
			end
		end
		if $count % 4 == 0 then @anim.next end
	end

	def draw(sx,sy)
		@anim.frame.draw(@x-sx,@y-sy+if @fall or @type==2 && @speed==1 then 32 else 0 end,if !@fall then 2 else 4 end,1,if @fall or @type==2 && @speed==1 then -1 else 1 end)
	end

	def curnt
		@type*5
	end

	def pow(x,y,width,height,force)
		if x+width>@x+2 and x<@x+30 and y<@y+32 and y+height>@y
			kick(false)
		end
	end

	def stomp
		return if @time
		@start=nil
		$game.player.vy=-12
		Snd['kick'].play
		@time=15
		if $game.player.x+32<@x+16 then @left=false else @left=true end
		@stand=!@stand
		$game.player.combo[0]+=1
		combo(@x+16,@y,$game.player.combo[0])
	end

	def kick(bullet)
		@vy=-10
		Snd['kick'].play
		@frame=1
		if !bullet
			$game.player.combo[1]+=1
			combo(@x+16,@y,$game.player.combo[1])
		else
			$points+=200
			Points.new(@x+16,@y,200)
		end
		@dead=0
		@fall=true
	end

	def size
		[32,32]
	end

	def killem_all
		return if @fall or @start
		if f=$game.entities[$game.room][6].find{|e| e != self and e.active and !e.dead and e.x<@x+16 and e.x+e.size[0]>@x and e.y<@y+16 and e.y+e.size[1]>@y}
			@combo+=1
			if f.kick(:combo) then combo(@x+16,@y,@combo) and return true end
		end
	end

	def det
		detect_player(@x,@y,32,32)
	end

	
	def room=(new)
		remove
		init([:enemy,:powish,:carry],new)
	end

	def vx=(val)
		if val>0 then @left=false else @left=true end
		@time=5
		@stand=false
	end

	def froze
		remove
		Frozen.new(@x,@y,@anim.frame,[1,1])
	end
end

class Door < Entity
	attr_accessor :lock, :lockolor
	def initialize(x,y,type,lock,lockolor,qswitch,room)
		@x,@y,@type,@lock,@lockolor=x,y,type,lock,if lock then lockolor end
		if @type==0 then @anim=Animation.new(Tls['objects/door_anim',[54,80]],[0]) elsif @type==2 then @anim=Animation.new(Tls['objects/minidoor_anim',[54,80]],[0]) end
		if qswitch[0] != false then @qswitchid=qswitch[1] and @qswitchtype=qswitch[0] else @qswitchtype=false end
		init([:door],room)
	end

	def update(sx,sy)
		if @anim and $count % 5==0 then @anim.next end
		if @anim and @anim.ended then @anim.seq=[0] end
	end

	def draw(sx,sy)
		return if not cond
		if @anim
			@anim.frame.draw(@x-sx,@y-sy,1)
		else
			Tls['objects/door',[54,80]][@type].draw(@x-sx,@y-sy,1)
		end
		if @lock
			Img['objects/lock'].draw(@x+11-sx,@y+40-sy,1,1,1,@lockolor)
			Img['objects/lock-const'].draw(@x+11-sx,@y+40-sy,1)
		end
	end

	def open
		return if @type==1
		@anim.set(0)
		@anim.seq=[1,2,3,4,5,5,4,3,2,1]
	end

	def cond
		(not @qswitchtype == true && !$game.qswitches[@qswitchid] and not @qswitchtype == nil && $game.qswitches[@qswitchid])
	end
end

class Key < Entity
	attr_accessor :x,:y,:vx,:vy, :ph
	def initialize(x,y,color,phanto,room,from=nil)
		@x,@y,@color,@phanto,@from=x,y,color,phanto,from
		@vx=@vy=0
		init([:carry],room)
	end

	def update(sx,sy)
		return if !act(@x,@y,32,32,sx,sy)
		if @y>$game.map.height+64 then remove end
		if d=$game.entities[$game.room][8].find{|d| d.lock and col(d.lockolor) and d.cond and d.x+27<@x+32 and d.x+27>@x and d.y+64<@y+32 and d.y+64>@y}
			Snd['open'].play
			d.lock=nil
			$game.player.uncarry
			remove
			Sparkle.new(@x-8,@y-8,Tls['effects/poof',[48,48]],[0,1,2,3],3)
		end
		if $game.player.carry(self) and !@ph
			@phanto[0].times{Phanto.new(sx,sy,@phanto[1],self)}
			@ph=true
		end
	
		if @from and @from>0
			@y-=2
			@from-=1
		elsif @from
			@from=nil
		end
		if not $game.player.carry(self) || @from
		physics
		@ph=nil end
	end

	def draw(sx,sy)
		Img['objects/key'].draw(@x-sx,@y-sy,2,1,1,@color)
		Img['objects/key-const'].draw(@x-sx,@y-sy,2)
	end

	def size
		[32,32]
	end

	def room=(new)
		remove
		init([:carry],new)
	end

	def col(color)
		@color.red==color.red and @color.green==color.green and @color.blue==color.blue
	end
end

class Spring < Entity
	attr_accessor :x,:y,:vx,:vy
	def initialize(x,y,type,anchor,room,from=nil)
		@x,@y,@type,@anchor,@from=x,y,type,anchor,from
		@vx=@vy=0
		@anim=Animation.new(Tls['objects/spring',[32,32]],[@type*3])
		init(if !anchor then [:carry] else nil end,room)
	end

	def update(sx,sy)
		return if !act(@x,@y,32,32,sx,sy)
		if @y>$game.map.height+64 then remove end
		player=$game.player
		if player.carry(self) and player.y+64<@y+player.vy && player.vy>0 || @anim.sequence==[@type*3+1,@type*3+2,@type*3+1] then player.uncarry end
	
		if @from and @from>0
			@y-=2
			@from-=1
		elsif @from
			@from=nil
		end

		if not player.carry(self) || @from
			physics
		
			if player.vy>1 and player.y+64>@y and player.uppos<@y+16 and player.leftpos<@x+32 and player.rightpos>@x
				if !Keypress['jump']
					Snd['bump'].play
					player.vy=-12
				else
					Snd['springjump'].play
					case @type
						when 0
						player.vy=-18
						player.jumpheight=4
						player.jump=true
						when 1
						player.vy=-21
						player.jumpheight=2
						player.jump=true
						when 2
						player.vy=-26
						player.jumpheight=0
						player.jump=true
					end
				end
				fr=@type*3
				@anim.seq=[fr+1,fr+2,fr+1]
			end
		end
		if $count % 6 == 0 then @anim.next end
		fr=@type*3
		if @anim.sequence==[fr+1,fr+2,fr+1] and @anim.ended then @anim.set(fr) and @anim.seq=[fr] end
	end

	def draw(sx,sy)
		@anim.frame.draw(@x-sx,@y-sy,2)
		if @anchor then Img['objects/anchor'].draw(@x+14-sx,@y+25-sy,3) end
	end

	def size
		[32,32]
	end

	def room=(new)
		remove
		init([:carry],new)
	end
end

class Pswitch < Entity
	attr_accessor :x,:y,:vx,:vy
	def initialize(x,y,time,anchor,once,room,from=nil)
		@x,@y,@time,@anchor,@once,@from=x,y,time,anchor,once,from
		@vx=@vy=0
		init([if !anchor then :carry else nil end],room)
	end
	
	def update(sx,sy)
		return if !act(@x,@y,32,32,sx,sy) and !@down
		if @y>$game.map.height+64 then remove end
		player=$game.player
		if !@from and !$game.player.carry(self) and player.rightpos>@x and player.leftpos<@x+24 and player.y+64>@y and player.uppos<@y+24 and player.vy>0 and !@down
			Snd['button'].play
			@down=true
			Msc["Switch#{1+@time}.ogg"].play
			$game.pswitch=self
			switch
		end
		
		if !$game.pswitch
			switch if @down
			if @down and @once then remove
				Sparkle.new(@x-12,@y-12,Tls['effects/poof',[48,48]],[0,1,2,3],3) end
			@down=nil
		end
	
		if @from and @from>0
			@y-=2
			@from-=1
		elsif @from
			@from=nil
		end
		
		physics if !$game.player.carry(self)
	end
	
	def draw(sx,sy)
		Tls['objects/switches',[24,24]][if @down then 5 else 1 end].draw(@x-sx,@y-sy,1)
		if @anchor then Img['objects/anchor'].draw(@x+10-sx,@y+17-sy,3) end
	end
	
	def room=(new)
		remove
		init([:carry],new)
	end

	def size
		[20,24]
	end

	def switch
		i=0
		$game.entities[$game.level['rooms'].length+1].length.times{if $game.entities[$game.level['rooms'].length+1][i].change !='goodbye' then i+=1 end}
	end
end

class PBlock < Entity
	attr_accessor :x, :y, :vx, :vy
	def initialize(x,y,type,room)
		@x,@y,@type,@changed,@room=x,y,type,room
		@vx=@vy=0
		init([:pswitchable,if @type != 0 then :carry else nil end],room)
		@solid=(@type != 4)
    $game.map.modify_mask(room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][1],@x%640,@y%480) if @solid
		@set=@solid
	end

	def update(sx,sy)
		@solid=(@type != 4)
		if !$game.player.carry(self)
			@set=true
			if @solid && @vx.to_i==0 && $game.map.solid?(@x+16,@y+33) || @type==2 and !@spliced
        @spliced=true
        $game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][1],@x%640,@y%480)
			end
		else
			if @set then $game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][0],@x%640,@y%480)
				@set=nil end
			@solid=nil
		end
    @spliced=nil if !@solid
		return if !act(@x,@y,32,32,sx,sy)
		if @y>$game.map.height+64 then remove end
		if !$game.player.carry(self) and ![0,2].include?(@type)
			@vy+=$game.map.grav
			if @vy>0 and @y-64<$game.map.height
				@vy.to_i.times{if !$game.map.solid?(@x+2,@y+32,true) and !$game.map.solid?(@x+16,@y+32,true) and !$game.map.solid?(@x+30,@y+32,true)
				@y+=1 else @vy=0 and break end}
			elsif @vy<0
				@vy.to_i.abs.times{if !$game.map.solid?(@x+2,@y-1) and !$game.map.solid?(@x+16,@y-1) and !$game.map.solid?(@x+30,@y-1)
				@y-=1 else @vy=0 and break end}
			end
			if @vx>0
				@vx.to_i.times{if !$game.map.solid?(@x+33,@y) and !$game.map.solid?(@x+33,@y+16) and !$game.map.solid?(@x+33,@y+32)
				@x+=1 else @vx=0 and break end}
			elsif @vx<0
				@vx.to_i.abs.times{if !$game.map.solid?(@x-1,@y) and !$game.map.solid?(@x-1,@y+16) and !$game.map.solid?(@x-1,@y+32)
				@x-=1 else @vx=0 and break end}
			end
			if @vx.to_i>0 then @vx-=0.25 elsif @vx.to_i<0 then @vx+=0.25 end
		end
	end

	def draw(sx,sy)
		Tls['objects/blocks',[32,32]][if cnd=@type<4 then 1+@type else 4 end].draw(@x-sx,@y-sy,1,1,1,if !cnd then 0x80ffffff else 0xffffffff end)
	end

	def change
		case @type
			when 0
			$game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][0],@x%640,@y%480)
			Coin.new(@x,@y,0,false,@room)
			remove
			return 'goodbye'
			when 1
			@type=2
			when 2
			$game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][0],@x%640,@y%480)
			@type=1
			when 3
			$game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][0],@x%640,@y%480)
			@type=4
			when 4
			@type=3
		end
	end

	def size
		[32,32]
	end

	def room=(new)
		remove
		init([:pswitchable,:carry],new)
	end
end

class Eswitch < Entity
	attr_accessor :x,:y,:vx,:vy
	def initialize(x,y,time,anchor,once,color,room,from=nil)
		@x,@y,@time,@anchor,@once,@color,@from=x,y,time,anchor,once,color,from
		@vx=@vy=0
		init([if !anchor then :carry else nil end],room)
	end
	
	def update(sx,sy)
		return if !act(@x,@y,32,32,sx,sy) and !@down
		if @y>$game.map.height+64 then remove end
		player=$game.player
		if !@from and !$game.player.carry(self) and player.rightpos>@x and player.leftpos<@x+24 and player.y+64>@y and player.uppos<@y+24 and player.vy>0 and !@down
			Snd['button'].play
			@down=true
			Msc["Switch#{1+@time}.ogg"].play
			$game.eswitch=true
			switch
		end
		
		if !$game.eswitch
			switch if @down
			if @down and @once then remove
				Sparkle.new(@x-12,@y-12,Tls['effects/poof',[48,48]],[0,1,2,3],3) end
			@down=nil
		end
	
		if @from and @from>0
			@y-=2
			@from-=1
		elsif @from
			@from=nil
		end
		
		physics if !$game.player.carry(self)
	end
	
	def draw(sx,sy)
		Tls['objects/switches',[24,24]][if @down then 6 else 2 end].draw(@x-sx,@y-sy,1,1,1,@color)
		Tls['objects/switches',[24,24]][if @down then 7 else 3 end].draw(@x-sx,@y-sy,1)
		if @anchor then Img['objects/anchor'].draw(@x+10-sx,@y+17-sy,3) end
	end
	
	def room=(new)
		remove
		init([:carry],new)
	end

	def size
		[20,24]
	end

	def switch
		$game.entities[$game.level['rooms'].length].each{|e| e.change(@color)}
	end
end

class ObjectBlock < Entity
	def initialize(x,y,item,properts,hidden,room)
		@x,@y,@item,@hidden,@y2,@props=x,y,item,hidden,y,properts
		@solid,@active=!hidden,true
		init([:powable,:destroyable],room)
    $game.map.modify_mask(room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][1],@x%640,@y%480) if !hidden
	end

	def update(sx,sy)
		if @y2<@y then @y2+=1 end
		player=$game.player
		if @hidden and player.vy<0 and player.rightpos>@x+2 and player.leftpos<@x+30 and player.uppos<@y+32 and player.y+64>@y
			$game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][1],@x%640,@y%480)
			@hidden=nil
			@solid=true
			player.vy=player.vy.abs/2
			Snd['bump'].play if @item==-1
			pow(player.x,player.y,player.rightpos-player.leftpos,player.height,!player.small)
		end
		
		if @climbs
			@climbs << Climb.new(@x,@y,Tls["tiles/climb",[32,32]][img],[false,0],$game.room) if @climbs.length<@props[1] and $count%16==0
			@climbs.each{|c| c.y-=2}
			
			if @climbs.length==@props[1] && $count%16==15 or !@props[2] && @climbs[1] && $game.map.solid?(@climbs[1].x+16,@climbs[1].y)
				@climbs.each{|c| c.delete}
				@climbs=nil
			end
		end
	end
	
	def pow(x,y,width,height,force)
		if @item>-1 and x+width>@x+2 and x<@x+30 and y<@y+32 and y+height>@y
			if @item !=0 then Snd['sprout'].play else Snd['vine'].play end
			@hidden=nil
			@solid=true
			case @item
				when 0
				@climbs=[]
				when 1
				Qswitch.new(@x+4,@y+4,@props[0],@props[1],@props[2],@props[3],@props[4],[@props[5],@props[6]],$game.room,14)
				when 2
				Pswitch.new(@x+4,@y+4,@props[0],@props[1],@props[2],$game.room,14)
				when 3
				Eswitch.new(@x+4,@y+4,@props[0],@props[1],@props[2],@props[3],$game.room,14)
				when 4
				Key.new(@x,@y,@props[1],@props[0],$game.room,16)
				when 5
				Spring.new(@x,@y,@props[0],@props[1],$game.room,16)
			end
			@item=-1
			@y2-=8
			$game.entities[$game.room][7].each{|e| e.pow(@x,@y-16,32,32,true)}
		end
	end
	
	def draw(sx,sy)
		if @item>-1 and not @hidden
			Tls['objects/powerupblock',[32,32]][$count/8%4].draw(@x-sx,@y2-sy,3)
		elsif not @hidden
			Tls['objects/powerupblock',[32,32]][4].draw(@x-sx,@y2-sy,3)
		end
	end

	def img
		if @climbs.count>0
			case @props[0]
				when 0,1,2,3
				r=@props[0]+5
				when 10
				r=11
			end
			if r
				r
			else
				@props[0]
			end
		else
			@props[0]
		end
	end

	def destroy
    $game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][0],@x%640,@y%480)
		Snd['breakblock'].play
		remove
		6.times{Particle.new(@x+rand(32),@y+rand(32),Img['effects/broken'],0xffc0c000)}
		$points+=10
	end

	def size
		[32,32]
	end
end

class SaveFlag < Entity
	def initialize(x,y,room)
		@x,@y,@vy=x,y,0
		init(nil,room)
	end

	def update(sx,sy)
		if @vy==0 and @y+64>$game.player.uppos and @y<$game.player.y+64 and $game.player.rightpos>@x and $game.player.leftpos<@x+32
			Snd['save'].play
			$saved=[$game.player.x,$game.player.y,$game.room]
			@vy=-10
		end
		@vy+=1.1 if @vy !=0
		if @vy>0
			@vy.to_i.times{@y+=1}
		elsif @vy<0
			@vy.to_i.abs.times{@y-=1}
		end
		if @vy>0 and @y>sy+480 then remove end
	end

	def draw(sx,sy)
		Tls['objects/saveflag',[32,64]][$count/8%4].draw(@x-sx,@y-sy,5)
	end
end

class TextBlock < Entity
	def initialize(x,y,text,room)
		@x,@y,@text,@solid,@y2=x,y,Image.from_text($screen,text+"\n \nPress Enter",'fonts/NINE.ttf',20,4,300,:justify),true,y
		@active=true
		init([:powable,:destroyable],room)
    $game.map.modify_mask(room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][1],@x%640,@y%480)
	end
	
	def update(sx,sy)
		if @y2<@y then @y2+=1 end
		if @show and !$game.pause then @show=nil end
	end
	
	def pow(x,y,width,height,force)
		if x+width>@x+2 and x<@x+30 and y<@y+32 and y+height>@y
			@y2=@y-8
			@show=true
			$game.pause=@text
			Snd['pause'].play
		end
	end
	
	def draw(sx,sy)
		Tls['objects/blocks',[32,32]][0].draw(@x-sx,@y2-sy,2)
	end

	def destroy
    $game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][0],@x%640,@y%480)
		Snd['breakblock'].play
		remove
		3.times{Particle.new(@x+rand(32),@y+rand(32),Img['effects/broken'],0xff0000ff)}
		3.times{Particle.new(@x+rand(32),@y+rand(32),Img['effects/broken'],0xffff8000)}
		$points+=10
	end

	def size
		[32,32]
	end
end

class WandBlast < Entity
	def initialize(x,y,dir)
		@x,@y,@dir,@x2=x,y,dir,x
		init(nil,$game.room)
	end

	def  update(sx,sy)
		if f=$game.entities[$game.room][6].find{|e| e.active and !e.projectile and !e.dead and e.respond_to?(:detect) && e.detect(@x,@y,32,32) || e.x<@x+16 && e.x+e.size[0]>@x && e.y<@y+16 && e.y+e.size[1]>@y}
			f.froze
		end
		if @dir==:right then @x+=6 else @x-=6 end
		if @x<@x2-640 or @x>@x2+640 or @x+32<0 or @x>$game.map.width then remove
			$game.player.limit=0 end
	end

	def draw(sx,sy)
		Img['projectiles/wandblast'].draw_rot(@x+16-sx,@y-sy+16,2,if @dir==:right then ($count*8)%360 else -(($count*8)%360) end)
	end
end

class Frozen < Entity
	attr_accessor :x,:y,:vx,:vy
	attr_reader :stand
	def initialize(x,y,img,size)
		@x,@y,@img,@stand,@vy,@size,@combo,@active=x,y,img,true,0,size,0,true
		@untime=0
		init([:enemy,:powish,:carry],$game.room)
	end

	def update(sx,sy)
		@untime-=1
		if $game.player.carry(self)
			@time=15
			@untime=120
			@unharm==@through=true
			if killem_all
				$game.player.uncarry
				kick(true)
			end
		else
			@through=!@stand
			@unharm=(@stand or @untime>0)
		end
	
		if @y>$game.map.height+64 then remove end
		return if $game.player.carry(self)
		player=$game.player
		map=$game.map
		if map.solid?(@x+16,@y+16) and !@fall then kick(true) end
		if @stand then det end
		if @stand and @y+32>player.uppos and @y+4<player.y+64 and player.rightpos>@x and player.leftpos<@x+32 and !@time
			Snd['kick'].play
			@stand=false
			if player.x+32<@x+16 then @left=false else @left=true end
			@time=10
		end
		if !@stand
			if !@left then 8.times{if !@time then det end
				if !map.solid?(@x+size[0],@y+31) and !map.solid?(@x+size[0],@y+16) and !map.solid?(@x+size[0],@y+1) or @fall then @x+=1 else crash and $game.entities[$game.room][1].each{|e| e.pow(@x+4,@y,32,32,true)} and break end
			killem_all} end
			if @left then 8.times{ if !@time then det end
				if !map.solid?(@x-1,@y+31) and !map.solid?(@x-1,@y+16) and !map.solid?(@x-1,@y+1) or @fall then @x-=1 else crash and $game.entities[$game.room][1].each{|e| e.pow(@x-4,@y,32,32,true)} and break end
			killem_all} end
		end
		@vy+=$game.map.grav
		if @vy>0 and @y-64<map.height
			@vy.to_i.times{if !map.solid?(@x+2,@y+size[1],true) and !map.solid?(@x+16,@y+size[1],true) and !map.solid?(@x+30,@y+size[1],true) or @fall
			@y+=1 and killem_all elsif @vy>4 then crash else @vy=0 end}
		elsif @vy<0
			@vy.to_i.abs.times{if !map.solid?(@x+2,@y) and !map.solid?(@x+16,@y) and !map.solid?(@x+30,@y) or @fall
			@y-=1 and killem_all else $game.entities[$game.room][1].each{|e| e.pow(@x,@y-4,32,32,true)} and crash end}
		end
		if @time and @time>0 then @time-=1 elsif @time then @time=nil end
	end

	def draw(sx,sy)
		@img.draw(@x-sx,@y-sy,2)
		Img['enemies/frozen'].draw(@x-sx,@y-sy,2,@size[0],@size[1])
	end

	def pow(x,y,width,height,force)
		if x+width>@x+2 and x<@x+30 and y<@y+32 and y+height>@y
			crash
		end
	end

	def stomp
		$game.player.vy=-12
		crash
	end

	def kick(bullet)
		crash
		true
	end

	def size
		[32*@size[0],32*@size[1]]
	end

	def killem_all
		if f=$game.entities[$game.room][6].find{|e| e != self and e.active and !e.dead and e.x<@x+16 and e.x+e.size[0]>@x and e.y<@y+16 and e.y+e.size[1]>@y}
			@combo+=1
			if f.kick(:combo) then combo(@x+16,@y,@combo) and return true end
		end
	end

	def det
		detect_player(@x,@y,32,32)
	end

	
	def room=(new)
		remove
		init([:enemy,:powish,:carry],new)
	end

	def vx=(val)
		if val>0 then @left=false else @left=true end
		@time=5
		@stand=false
	end

	def froze
	end

	def crash
		return if @crash
		@crash=true
		Snd['breakblock'].play
		6.times{Particle.new(@x+rand(32*@size[0]),@y+rand(32*@size[1]),Img['effects/broken'],0xff00c0ff)}
		$points+=200
		Points.new(@x+16,@y,200)
		remove
	end
end

class FlipBlock < Entity
	def initialize(x,y,flips,room)
		@x,@y,@y2,@flips,@solid=x,y,y,flips,true
		@active=true
		init([:powable,:destroyable],room)
    $game.map.modify_mask(room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][1],@x%640,@y%480)
		@set=true
	end
	
	def update(sx,sy)
		@y2+=1 if @y>@y2
		if @solid and !@set
			$game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][1],@x%640,@y%480)
			@set=true
		elsif !@solid and @set
			$game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][0],@x%640,@y%480)
			@set=nil
		end
		if !@solid
			@flip+=1
		else
			@flip=0
			@fliped=0
		end
		if !@solid and (@flip/8)%4==0
			@fliped+=1
		end
		if @fliped>=@flips*8
			@solid=true
		end
	end
	
	def pow(x,y,width,height,force)
		if @solid and x+width>@x+2 and x<@x+30 and y<@y+32 and y+height>@y
			$game.entities[$game.room][7].each{|e| e.pow(@x,@y-16,32,32,true)}
			@y2-=8
			@solid=false
		end
	end
	
	def draw(sx,sy)
		if @solid
			Tls['objects/flipblock',[32,32]][0].draw(@x-sx,@y2-sy,2)
		else
			Tls['objects/flipblock',[32,32]][(@flip/8)%4].draw(@x-sx,@y2-sy,2)
		end
	end
	
	def size
		[32,32]
	end

	def destroy
    $game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][0],@x%640,@y%480)
		Snd['breakblock'].play
		remove
		6.times{Particle.new(@x+rand(32),@y+rand(32),Img['effects/broken'],0xffffff00)}
		$points+=10
	end
end

class FlagPole < Entity
	def initialize(x,y,room,secret)
		@x,@y,@secret,@y2=x,y,secret,y+19
		init(nil,room)
	end

	def update(sx,sy)
		left=(!@secret && $game.level['end'][0] or @secret && $game.level['end'][1])
		if $game.player.mario and !$game.player.end and left && $game.player.leftpos<@x+8 || !left && $game.player.rightpos>@x and $game.player.y<@y+300 and $game.player.y>@y-128
			Snd['flagdown'].play
			$game.player.x=if left then @x else @x-17 end
			$game.player.end=0
			$game.player.secret=@secret
			if (h=($game.player.y+64)-@y)<=0
				Snd['1up'].play
				$lives+=1
				LifeUp.new(@x-19,@y,0)
			elsif h<=70
				$points+=5000
				Points.new(@x+32,@y+280,5000)
			elsif h<=140
				$points+=2000
				Points.new(@x+32,@y+280,2000)
			elsif h<=180
				$points+=800
				Points.new(@x+32,@y+280,2000)
			elsif h<=220
				$points+=400
				Points.new(@x+32,@y+280,400)
			else
				$points+=200
				Points.new(@x+32,@y+280,200)
			end
			Msc['StageClear.ogg'].play
			@flag=true
		end
		if @flag and @y2<@y+260 then @y2+=4 end
	end

	def draw(sx,sy)
		left=($game.level['end'][0] or @secret && $game.level['end'][1])
		Tls['objects/finnish_pole',[16,300]][if @secret then 1 else 0 end].draw(@x-sx,@y-sy,1)
		Tls['objects/finnish_flag',[32,32]][if @secret then 4 else 0 end+($count/8)%4].draw(@x+10-if left then 4 else 0 end-sx,@y2-sy,1,if left then -1 else 1 end)
	end
end

class SkullBlock < Entity
	def initialize(x,y,id,exist,room)
		@x,@y,@id,@solid=x,y,id,exist
		init(nil,room)
    $game.map.modify_mask(room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][1],@x%640,@y%480) if @solid
		@set=@solid
	end
	
	def update(sx,sy)
		if @solid and !@set
			$game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][1],@x%640,@y%480)
			@set=true
		end
		if $game.rampages[@id] or cnd=($game.boss.class==BossControl && $game.boss.id==@id)
			if cnd then @boss=true end
			@on=true
		end
		if @on and !@solid and rand(30)==15
			Snd['breakblock'].play
			5.times{Particle.new(@x+rand(32),@y+rand(32),Img['effects/broken'],0xffffffff)}
			@solid=true
		end
		if @on and (!@boss && !$game.rampages[@id] or @boss && $game.boss.class==Symbol) and rand(30)==15
			$game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][0],@x%640,@y%480)
			Snd['breakblock'].play
			5.times{Particle.new(@x+rand(32),@y+rand(32),Img['effects/broken'],0xffffffff)}
			remove
		end
	end
	
	def draw(sx,sy)
		if @solid then Tls['objects/blocks',[32,32]][5].draw(@x-sx,@y-sy,2) end
	end
end

class Bomb < Entity
	attr_accessor :vx,:vy,:x,:y
	def initialize(x,y)
		@x,@y,@vx,@vy,@time=x,y,0,0,180
		init([:carry],$game.room)
	end

	def update(sx,sy)
		if @y>$game.map.height+64 then $game.player.limit-=1 and remove end
		@time-=1 if @fuse
		if !$game.player.carry(self)
			physics 
			@fuse=true
		end
		if @time==0
			if (pl=$game.player).carry(self) then pl.uncarry end
			Snd['bomb'].play
			remove
			$game.player.limit-=1
			Explosion.new(@x-82,@y-45)
			$game.shake(5,4,8)
		end
	end

	def draw(sx,sy)
		if @fuse
			Tls['projectiles/bomb',[28,38]][if @time>60 then ($count/4)%3 else 3+($count/4)%2 end]
		else
			Tls["bonus/powerups",[32,32]][11]
		end.draw(@x-sx,@y-sy,2)
	end
	
	def room=(new)
		remove
		init([:carry],new)
	end

	def size
		[28,38]
	end
end

class Explosion < Entity
	def initialize(x,y)
		@x,@y,@time=x,y,30
		init(nil,$game.room)
	end

	def update(sx,sy)
		if @time>0 then @time-=1 else remove end
		$game.entities[$game.room][6].each{|e| if e.active and !e.dead and e.respond_to?(:detect) && e.detect(@x,@y,192,128) || e.x<@x+192 and e.x+e.size[0]>@x and e.y<@y+128 and e.y+e.size[1]>@y
			e.kick(:bomb) end}
		$game.entities[$game.room][10].each{|e| if e.active and e.x<@x+192 and e.x+e.size[0]>@x and e.y<@y+128 and e.y+e.size[1]>@y
			e.destroy end}
	end

	def draw(sx,sy)
		Tls['projectiles/explosion',[192,128]][($count/4)%2].draw(@x-sx,@y-sy,3)
	end
	
	def room=(new)
		remove
		init([:carry],new)
	end

	def size
		[28,38]
	end
end

class Beet < Entity
	def initialize(x,y,dir)
		@x,@y,@dir,@vy,@bounces=x,y,dir,-13,0
		init(nil,$game.room)
	end

	def  update(sx,sy)
		if @dir==:right then @x+=3 else @x-=3 end
		@vy+=$game.map.grav
		cnd=@bounces<3
		if @vy>0
			@vy.to_i.times{if !$game.map.solid?(@x+13,@y+32,true) or !cnd then @y+=1 else bounce and Sparkle.new(@x-7,@y+12,Tls['effects/shellbounce',[40,40]],[0,1,2,3],1) and break end}
		elsif @vy<0
			@vy.to_i.abs.times{if !$game.map.solid?(@x+13,@y) or !cnd then @y-=1 else @bounce and Sparkle.new(@x-7,@y-20,Tls['effects/shellbounce',[40,40]],[0,1,2,3],1) and break end}
		end
		if @y>$game.map.height then $game.player.limit-=1 and remove end
		if cnd and d=$game.map.solid?(@x+26,@y+16) || !d=!$game.map.solid?(@x+1,@y+16) then bounce and Sparkle.new(@x+if d then -20 else 7 end,@y-4,Tls['effects/shellbounce',[40,40]],[0,1,2,3],1) end
		if cnd and f=$game.entities[$game.room][6].find{|e| e.active and !e.dead and e.respond_to?(:detect) && e.detect(@x,@y,27,32) || e.x<@x+27 && e.x+e.size[0]>@x && e.y<@y+32 && e.y+e.size[1]>@y}
			if f.kick(:beet) then bounce and Sparkle.new(@x-7,@y-4,Tls['effects/shellbounce',[40,40]],[0,1,2,3],1) end end
		if cnd and f=$game.entities[$game.room][10].find{|e| e.class==Bricks and e.active and e.x<@x+29 && e.x+e.size[0]>@x-1 && e.y<@y+34 && e.y+e.size[1]>@y-1}
			f.pow(f.x+8,f.y+8,16,16,true)
			Sparkle.new(@x-7,@y-4,Tls['effects/shellbounce',[40,40]],[0,1,2,3],1)
			bounce
		end
		if cnd then $game.entities[$game.room][1].each{|e| e.pow(@x-1,@y-1,29,34,true)} end
	end

	def draw(sx,sy)
		Tls['projectiles/beet',[27,32]][[0,1,2,1][($count/8)%3]].draw(@x-sx,@y-sy,3)
	end

	def bounce
		Snd['stun'].play
		@vy=-13
		if @dir==:right then @dir=:left else @dir=:right end
		@bounces+=1
	end
end

class PassType < Entity
	def initialize(x,y,id,index,chars,room)
		@x,@y,@y2,@id,@index,@chars,@cur=x,y,y,id,index,chars,0
		$game.passwords[@id]=[]
		init([:powable],room)
    $game.map.modify_mask(room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][1],@x%640,@y%480)
	end

	def update(sx,sy)
		$game.passwords[@id][@index]=@chars[@cur]
		if @y2<@y then @y2+=1 end
	end

	def draw(sx,sy)
		Tls['objects/passwordblock',[32,32]][4].draw(@x-sx,@y2-sy,2)
		Text[@x+6-sx,@y2+6-sy,2,@chars[@cur],1,20,20,0,255]
	end

	def pow(x,y,width,height,force)
		if x<@x+30 and x+width>@x+2 and y<=@y+32 and y+height>=@y
			Snd['switchpress'].play
			@y2-=8
			$game.entities[$game.room][7].each{|e| e.pow(@x,@y-16,32,32,true)}
			if @cur+1==@chars.length then @cur=0 else @cur+=1 end
		end
	end
end


class PassCheck < Entity
	def initialize(x,y,id,pass,room)
		@x,@y,@id,@pass=x,y,id,pass
		init(nil,room)
    $game.map.modify_mask(room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][1],@x%640,@y%480)
	end

	def update(sx,sy)
		if $game.passwords[@id]==@pass.split(//) then destroy end
	end

	def draw(sx,sy)
		Tls['objects/passwordblock',[32,32]][$count/8%4].draw(@x-sx,@y-sy,2)
	end

	def destroy
    $game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][0],@x%640,@y%480)
		Snd['breakblock'].play
		remove
		8.times{Particle.new(@x+rand(32),@y+rand(32),Img['effects/broken'],0xffc0c0c0)}
		$points+=25
	end
end

class TriggerSwitcher < Entity
	def initialize(x,y,id1,id2,on,hidden,room)
		@x,@y,@id1,@id2,@on,@solid,@y2=x,y,id1,id2,on,!hidden,y
		init([:powable],room)
    $game.map.modify_mask(room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][1],@x%640,@y%480)
	end
	
	def update(sx,sy)
		if @y2<@y then @y2+=1 end
		player=$game.player
		if !@solid and player.vy<0 and player.rightpos>@x+2 and player.leftpos<@x+30 and player.uppos<@y+32 and player.y+64>@y
			$game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][1],@x%640,@y%480)
			@solid=true
			player.vy=player.vy.abs/2
			pow(player.x,player.y,player.rightpos-player.leftpos,player.height,!player.small)
		end
	end
	
	def pow(x,y,width,height,force)
		if x<@x+30 and x+width>@x+2 and y<=@y+32 and y+height>=@y
			Snd['switchpress'].play
			if @on then $game.triggers[@id2]=2 else $game.triggers[@id1]=2 end
			@on=!@on
			@y2-=8
			$game.entities[$game.room][7].each{|e| e.pow(@x,@y-16,32,32,true)}
		end
	end
	
	def draw(sx,sy)
		return if !@solid
		if @on then a=0 else a=1 end
		Tls['objects/changes',[32,32]][a].draw(@x-sx,@y2-sy,2,1,1,if @on then 0xff00ff00 else 0xffff0000 end)
		Tls['objects/changes-const',[32,32]][a].draw(@x-sx,@y2-sy,2)
	end
end

class GlowBlock < Entity
	attr_accessor :vx,:vy,:x,:y
	def initialize(x,y,radius,map,room)
		@x,@y,@light=x,y,Light.new(x,y,radius,[false],map,room)
		@vx=@vy=0
		init([:carry],room)
	end

	def update(sx,sy)
		if @y>$game.map.height+64 then remove end
		if !$game.player.carry(self)
			physics
		end
		@light.x=@x
		@light.y=@y
	end

	def draw(sx,sy)
		Tls['objects/blocks',[32,32]][6].draw(@x-sx,@y-sy,2)
	end
	
	def room=(new)
		remove(false)
		init([:carry],new)
		@light.room
	end

	def size
		[32,32]
	end
end

class BrosBlock < Entity
	def initialize(x,y,room)
		@x,@y,@y2=x,y,y
		init([:powable],room)
    $game.map.modify_mask(room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][1],@x%640,@y%480)
	end
	
	def update(sx,sy)
		if @y2<@y then @y2+=1 end
	end
	
	def pow(x,y,width,height,force)
		if x<@x+30 and x+width>@x+2 and y<=@y+32 and y+height>=@y
			Snd[if $game.player.mario then 'luigi' else 'mario' end].play
			@y2-=8
			$game.entities[$game.room][7].each{|e| e.pow(@x,@y-16,32,32,true)}
			chg=$game.player
			$game.player=$game.switch
			$game.switch=chg
			$game.room=$game.player.room
		end
	end
	
	def draw(sx,sy)
		Tls['objects/blocks',[32,32]][if $game.player.mario then 7 else 8 end].draw(@x-sx,@y2-sy,2)
	end
end