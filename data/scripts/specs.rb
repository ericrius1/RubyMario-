class Warp
	attr_reader :x,:y,:type,:room,:id,:exit
	def initialize(x,y,type,id,exit,mini,map,qswitch,room)
		@x,@y,@type,@exit,@mini,@id,@room=x,y,type,exit,mini,id,room
		if qswitch[0] != false then @qswitchid=qswitch[1] and @qswitchtype=qswitch[0] else @qswitchtype=false end
		map.warps << self
	end
	
	def check(x,y,type)
		warp=false
		cond=!(@qswitchtype == true && !$game.qswitches[@qswitchid] and not @qswitchtype == nil && $game.qswitches[@qswitchid])
		if cond and @room==$game.room and not $game.map.solid?(@x+8,@y+8) and @type==type and not @exit and !@mini || @mini && $game.player.mode==:mini and x>=@x-16 and x<=@x+32 and y>=@y-16 and y<=@y+32 and (if @type==4 and d=$game.entities[$game.room][8].find{|d| d.x==@x-19 and d.y==@y-64} then !d.lock else true end)
			if @type<4 then Snd['warp'].play else Snd['door'].play if d end
			warp=true
			$game.player.enter=self
		end
		
		if warp
			if d=$game.entities[$game.room][8].find{|d| d.x==@x-19 and d.y==@y-64} then d.open end
			choosen=[]
			$game.map.warps.each{|w| if w.id==@id and w.exit != nil and w != self and if w.type==4 and d=$game.entities[$game.room][8].find{|d| d.x==w.x-19 and d.y==w.y-64} then !d.lock else w end then choosen<<w end}
			if choosen.empty? then choosen << self end
			$game.player.exit=choosen[rand(choosen.length)]
		end
	end
end

class SpecjalSet
	def initialize(props,map,room)
		@props=props
		@props[0]=@props[0].to_f
		map.specjals[room]=self
	end

	def change(what,val)
		@props[what]=val
	end
	
	def liqlevel
		@props[0]
	end
	
	def water
		@props[1]
	end

	def gravity
		4
	end

	def liquid
		[:water,:lava][@props[4]]
	end

	def lava
		@props[3]
	end

	def upsolid
		@props[5]
	end

	def width
		@props[6]
	end

	def height
		@props[7]
	end
end

class Trigger < Entity
	def initialize(x,y,id,width,height,once,room)
		@x,@y,@id,@width,@height,@once=x,y,id,width,height,once
		init(nil,room)
	end

	def update(sx,sy)
		if (pl=$game.player).rightpos>@x+8 and pl.leftpos<@x+8+@width*8 and pl.uppos<@y+8+@height*8 and pl.y+64>@y+8 and !@used
			@used=true
			$game.triggers[@id]=2
			remove if @once
		elsif !((pl=$game.player).rightpos>@x+8 and pl.leftpos<@x+8+@width*8 and pl.uppos<@y+8+@height*8 and pl.y+64>@y+8)
			@used=nil
		end
	end
	
	def draw(sx,sy)
	end
end

class RampageControl < Entity
	attr_accessor :spawns
	def initialize(id,music,room)
		@id,@music,@spawns,@last,@time=id,music,[],0,0
		init(nil,room)
	end

	def update(sx,sy)
		if $game.triggers[@id] and !@on
			Msc["Rampage#{@music+1}.ogg"].play(true)
			$game.rampages[@id]=self
			@on=true
		end
		if @on
			@time+=1
			@last=0
			@spawns.each{|s| @last+=s.last}
			if @last==0 and @time>5
				Msc["Rampage#{@music+1}.ogg"].stop
				$game.rampages[@id]=nil
				remove
			end
		end
	end
	
		def draw(sx,sy)
			return if !@on
			Img['system/rem'].draw(390,170,6)
			Fnt['NINE.ttf',36].draw_rel(@last,635,193,6,1,0,1,1,0xff0000ff)
			Fnt['NINE.ttf',36].draw_rel(@last,632,190,6,1,0,1,1,0xffff0000)
		end
end

class EnemySpawner < Entity
	attr_reader :last
	def initialize(x,y,id,max,delay,enemies,room)
		@x,@y,@id,@max,@delay,@enemies=x,y,id,max,delay,enemies
		@time,@stand,@last=0,[],enemies.length
		init(nil,room)
	end

	def update(sx,sy)
		if $game.rampages[@id]
			@time+=1
			if !@ok then $game.rampages[@id].spawns << self and @ok=true end
			i=0
			@stand.length.times{if @stand[i].dead then @last-=1 and @stand.delete_at(i) else i+=1 end}
			if !@enemies.empty? and @stand.length<@max and @delay==0 || @time%(@delay*30)==0
				pr=@enemies[0].props
				case @enemies[0].type
					when :goomba
					@stand << Goomba.new(@x,@y,pr[0],pr[1],$game.room,true)
					when :koopatroopa
					@stand << KoopaTroopa.new(@x,@y,pr[0],pr[1],[pr[2],pr[3]],pr[4],$game.room,true)
					when :piranhaplant
					@stand << PiranhaPlant.new(@x,@y,pr[0],pr[1],pr[2],pr[3],pr[4],pr[5],pr[6],$game.room,:true)
					when :spiny
					@stand << Spiny.new(@x,@y,pr[1],pr[0],false,$game.room,true)
					when :buzzybeetle
					@stand << BuzzyBeetle.new(@x,@y,pr[1],pr[0],$game.room,true)
					when :pokey
					@stand << Pokey.new(@x,@y,pr[0],pr[1],pr[2],pr[3],$game.room,true)
					when :cheepcheep
					@stand << Pokey.new(@x,@y,pr[0],pr[1],pr[2],$game.room,true)
					when :hammbro
					@stand << HammerBros.new(@x,@y,pr[0],pr[1],$game.room,true)
				end
				@enemies.delete_at(0)
			end
		end
	end
	
	def draw(sx,sy)
	end
end

class BossControl < Entity
	attr_accessor :health,:id
	def initialize(id,music,health,rampage,finnish,room)
		@id,@music,@health,@rampage,@finnish=id,music,health,rampage,finnish
		init(nil,room)
	end

	def update(sx,sy)
		if $game.triggers[@id] and !@on
			Msc["Boss#{@music+1}.ogg"].play(true)
			$game.boss=self
			@on=true
		end
		if @health==0
			$game.boss=if @finnish==false then :dead elsif @finnish then :finnish else :secret end
			Msc["Boss#{@music+1}.ogg"].stop
			Snd['bossdown'].play
			remove
		end
	end
	
	def draw(sx,sy)
		return if !@on
		Img['system/boss_panel'].draw(452,90,6)
		x=577
		([@health,8].min).times{Tls['system/health',[15,30]][0].draw(x,100,6)
		x-=17}
		x=577
		([@health-8,8].min).times{Tls['system/health',[15,30]][1].draw(x,100,6)
		x-=17}
		x=577
		([@health-16,8].min).times{Tls['system/health',[15,30]][2].draw(x,100,6)
		x-=17}
		x=577
		([@health-24,8].min).times{Tls['system/health',[15,30]][3].draw(x,100,6)
		x-=17}
		x=577
		([@health-32,8].min).times{Tls['system/health',[15,30]][4].draw(x,100,6)
		x-=17}
	end
end

class LiquidControl < Entity
	def initialize(id,type,skin1,skin2,changeval,change,changetime,room)
		@id,@type,@skin1,@skin2,@changeval,@change,@changetime=id,type,skin1,skin2,changeval,change,changetime
		init(nil,room)
	end

	def update(sx,sy)
		spec=$game.map.specjals[$game.room]
		if $game.triggers[@id] and !@on
			@start=$game.map.specjals[$game.room].liqlevel
			$game.map.specjals[$game.room].change(4,@type)
			$game.map.specjals[$game.room].change(1,@skin1)
			$game.map.specjals[$game.room].change(3,@skin2)
			@on=true
		end
	
		if @on then (if @changetime>=0 then 1 else @changetime.abs end).times{lv=$game.map.specjals[$game.room].liqlevel
			if not @change==0 && lv==@changeval || @change==1 && lv==@start+@changeval || @change==2 && lv==@start-@changeval
				case @change
					when 0
					if lv<@changeval and @changetime<=0 || ($count*32)%@changetime==0 then spec.change(0,lv+1.0/32) elsif lv>@changeval and @changetime<=0 || ($count*32)%@changetime==0 then spec.change(0,lv-1.0/32) end
					when 1
					if @changetime<=0 || ($count*32)%@changetime==0 then spec.change(0,lv+1.0/32) end
					when 2
					if @changetime<=0 || ($count*32)%@changetime==0 then spec.change(0,lv-1.0/32) end
				end
			elsif @on
				@on=nil
			end} end
	end

	def draw(sx,sy)
	end
end

class SizeControl < Entity
	def initialize(id,changeval,val,change,changetime,room)
		@id,@val,@changeval,@change,@changetime=id,val,changeval,change,changetime
		init(nil,room)
	end

	def update(sx,sy)
		spec=$game.map.specjals[$game.room]
		if $game.triggers[@id] and !@on
			@start=[$game.map.rooms[$game.room]['width'],$game.map.specjals[$game.room].width,$game.map.rooms[$game.room]['height'],$game.map.specjals[$game.room].height][@val]
			@on=true
		end
	
		if @on then (if @changetime>=0 then 1 else @changetime.abs end).times{lv=[$game.map.rooms[$game.room]['width'],$game.map.specjals[$game.room].width,$game.map.rooms[$game.room]['height'],$game.map.specjals[$game.room].height][@val]
			if not @change==0 && lv==@changeval || @change==1 && lv==@start+@changeval || @change==2 && lv==@start-@changeval
				case @change
					when 0
					if lv<@changeval and @changetime<=0 || ($count*32)%@changetime==0 then change(lv,nil) elsif lv>@changeval and @changetime<=0 || ($count*32)%@changetime==0 then change(lv,true) end
					when 1
					if @changetime<=0 || ($count*32)%@changetime==0 then change(lv,nil) end
					when 2
					if @changetime<=0 || ($count*32)%@changetime==0 then change(lv,true) end
				end
			elsif @on
				@on=nil
			end} end
	end

	def change(lv,sub)
		if ![1,3].include?(@val) then if @val==0 then $game.map.rooms[$game.room]['width']=lv+((1.0/32)*if sub then -1 else 1 end) else $game.map.rooms[$game.room]['height']=lv+((1.0/32)*if sub then -1 else 1 end) end else $game.map.specjals[$game.room].change([nil,6,nil,7][@val],lv+((1.0/32)*if sub then -1 else 1 end)) end
	end

	def draw(sx,sy)
	end
end