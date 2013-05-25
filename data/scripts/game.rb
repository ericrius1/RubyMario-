class Game
	attr_accessor :entities, :level, :map, :room, :player, :qswitches, :pswitch, :eswitch, :pause, :time, :triggers, :rampages, :boss, :passwords, :switch
	def initialize(level)
		$game=self
		@entities=[]
		@qswitches=[]
		@triggers=[]
		@rampages=[]
		@passwords=[]
		@level=Marshal.load(File.new("data/#{level}.mlv",'r'))
		@level['rooms'].length.times{@entities << [[],[],[],[],[],[],[],[],[],[],[]]}
		@time=@level['time']
		2.times{@entities << []}
		@map=Map.new(@level['rooms'])
		@room=if $saved then $saved[2] else @level['start'][2] end
		@player=Player.new(if $saved then $saved[0] else @level['start'][0] end,if $saved then $saved[1] else @level['start'][1] end)
		@switch=Player.new(@level['luigi'][0],@level['luigi'][1],:luigi) if @level['luigi'] if @level['luigi']
		@scx=@scy=0
		FlagPole.new(@level['finnish'][0],@level['finnish'][1],@level['finnish'][2],false)
		if @level['alter'] then FlagPole.new(@level['alter'][0],@level['alter'][1],@level['alter'][2],true) end
	end
	
	def update
		if $profile
			$profile['record']=[$profile['record'],$points].max
			Marshal.dump($profile,f=File.open("data/profiles/#{$profile['name']}.mup",'w'))
			f.close
		end
		if $randomized
			Marshal.dump([$randomized,$points].max,f=File.open('data/score.mrh','w'))
			f.close
		end
	
		if @pause
			@sng=Song.current_song
			@sng.pause if @sng
		elsif @sng
			@sng.play
			@sng=nil
		end
	
		if @over and !Msc['Game Over.ogg'].playing? then button_down(KbEscape) end
		return if @pause or @over
		@triggers.each{|t| if t and t>0 then @triggers[@triggers.index(t)]-=1 elsif t then @triggers[@triggers.index(t)]=nil end}
		if $coins>=100
			Snd['1up'].play
			$lives+=1
			LifeUp.new(@player.x+16,@player.uppos,0)
			$coins-=100
		end
		
		if Keypress['item',false]
			hold
		end
	
		if !@player.end and @time==99 and not @player.dead and ![Msc['Switch1.ogg'],Msc['Switch2.ogg']].find{|m| m.playing?} then Msc['TimeWarning.ogg'].play end
		if !@player.end and @time>0 and $count%30==0 then @time-=1 elsif !@player.end and @time==0 then @player.kill end
		@player.update(@scy)
		@switch.update(@scy) if @switch
		return if $game != self
		@map.update if not @player.dead || @player.end
		if not Msc['Switch1.ogg'].playing? || Msc['Switch2.ogg'].playing?
			i=-1
			@qswitches.length.times{i+=1 and if @qswitches[i]==true then @qswitches[i]=nil end}
			@eswitch=nil
			ps=@pswitch
			@pswitch=nil
			ps.update(@scx,@scy) if ps end
		@entities[@room].each{|e| e.update(@scx,@scy) if e.class != Array and not @player.end && ![Points,FlagPole,LifeUp,Particle,Sparkle,Fall,Thunder,Pop,Bubble].include?(e.class)} if not @player.dead
		if @shake and @shake[2]>0 then @shake[2]-=1 else @shake=nil end
	end

	def hold
		return if !$hold
		Snd['dropitem'].play
		PowerUp.new(@scx+304,@scy+28,[nil,:normal,nil,:glow,:swimmer,:ninja,:mini,nil,nil,:fire,:frosting,:bomb,:beet].index($hold),:down,@room)
		$hold=nil
	end
	
	def draw
		c=0xff000000
		if @scx<@map.minx then $screen.draw_quad(0,0,c,@map.minx-@scx,0,c,@map.minx-@scx,480,c,0,480,c,5) end
		if @scx+640>@map.width then $screen.draw_quad(w=(@map.width-@scx),0,c,640,0,c,640,480,c,w,480,c,5) end
		if @scy<@map.miny then $screen.draw_quad(0,0,c,640,0,c,640,@map.miny-@scy,c,0,@map.miny-@scy,c,5) end
		if @scy+480>@map.height then $screen.draw_quad(0,w=(@map.height-@scy),c,640,w,c,640,480,c,0,480,c,5) end
		@switch.draw(@scx,@scy) if @switch and @room==@switch.room
		@player.draw(@scx,@scy)
		@entities[@room].each{|e| e.draw(@scx,@scy) if e.class != Array}
		@map.draw(@scx,@scy)
    $screen.flush
		if @flash and !@pause
			$screen.draw_quad(0,0,@flash,640,0,@flash,640,480,@flash,0,480,@flash,5)
			if @flash.alpha-@speed>0 then @flash.alpha-=@speed else @flash=@speed=nil end
		end
		if @pause
			c=0xc0000000
			$screen.draw_quad(0,0,c,640,0,c,640,480,c,0,480,c,8)
			if @pause.class != Image
        Fnt['fonts/NINE.ttf',40].draw_rel("PAUSED",320,240,8,0.5,0.5,1,1,0xffff0000)
      else
        c=0xff000000
        $screen.draw_quad(160,120,c,160+@pause.width+20,120,c,160+@pause.width+20,120+@pause.height+10,c,160,120+@pause.height+10,c,15)
        @pause.draw(170,130,15)
      end
		end
		if @over
			Fnt['fonts/NINE.ttf',40].draw_rel("GAME OVER",320,240,8,0.5,0.5,1,1,0xffff0000)
		end
		Text[8,8,6,"mario x #{$lives}",0.8,16,20,0,255]
		Text[120,32,6,$points,0.8,16,20,0,255,:back]
		Text[400,8,6,"world#{if @time>=0 then" 			time" end}",0.8,16,20,0,255]
		Text[440,32,6,@level['name'],0.6,12,20,0,255,:center]
		Text[606,32,6,@time,0.8,16,20,0,255,:back] if @time>=0
		Text[214,28,6,"x",0.8,16,20,0,255]
		Text[264,28,6,$coins,0.8,16,20,0,255,:back]
		Tls['bonus/coin',[32,32]][$count/8%4].draw(190,28,6,0.5,0.5)
		Img['system/hold'].draw(292,16,6)
		Tls['bonus/powerups',[32,32]][[nil,:normal,nil,:glow,:swimmer,:ninja,:mini,nil,nil,:fire,:frosting,:bomb,:beet].index($hold)].draw(304,28,6)
	end
	
	def flash(color,speed)
		@flash=Color.new(color)
		@speed=speed
	end

	def shake(power,speed,time)
		@shake=[power,speed,time]
	end
	
	def screen(x,y)
		@scx=[[@player.x-304+x,@map.minx].max,[@map.width-640,0].max].min.to_i
		@scy=[[@player.y-214+y,@map.miny].max,[@map.height-480,0].max].min.to_i
		if @shake and rand(@shake[1]*4)>4
			@scx+=-@shake[0]+rand(@shake[0]*2)
			@scy+=-@shake[0]+rand(@shake[0]*2)
		end
	end

	def over
		@over=true
		Msc['Game Over.ogg'].play
	end

	def flashing
		@flash
	end
	
	def button_down(id)
		if id==KbReturn then Snd['pause'].play and @pause=!@pause end
		if id==KbEscape then $game=$temp and if @map.sound then @map.sound.stop end
			$saved=nil
			if $temp.class == Editor then $music-=1 and $game.musicchange else Msc['Menu.ogg'].play(true) end and $temp=nil end
		if id==KbE and $randomized then $game=Editor.new(@level['name']) end
	end
end