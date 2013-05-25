class Player
	attr_accessor :x,:y,:vx,:vy,:enter,:exit,:mode,:transforming,:dead,:jumpheight,:jump,:combo,:limit,:starman,:end,:secret, :light,:dir,:mario,:room
	def initialize(x,y,char=:mario)
		@x,@y,@mode=x,y,$mode
		@modes={:small=>Animation.new(Tls["#{char.to_s}/small",[32,64]],[1]),
		:normal=>Animation.new(Tls["#{char.to_s}/normal",[32,64]],[1]),
		:fire=>Animation.new(Tls["#{char.to_s}/fire",[32,64]],[0]),
		:beet=>Animation.new(Tls["#{char.to_s}/beet",[32,64]],[0]),
		:frosting=>Animation.new(Tls["#{char.to_s}/frosting",[32,64]],[0]),
		:bomb=>Animation.new(Tls["#{char.to_s}/bomb",[32,64]],[0]),
		:ninja=>Animation.new(Tls["#{char.to_s}/ninja",[32,64]],[0]),
		:glow=>Animation.new(Tls["#{char.to_s}/glow",[32,64]],[0]),
		:swimmer=>Animation.new(Tls["#{char.to_s}/swimmer",[32,64]],[0]),
		:mini=>Animation.new(Tls["#{char.to_s}/mini",[32,64]],[0])}
		@dir=:right
		@vx=@vy=@warping=0
		@max=6
		@combo=[0,0,0]
		@limit=0
		@lookup=0
		@color=Color.new(0xffffffff)
		if @mode==:glow then @light=Light.new(@x,@y+16,4,[false],$game.map,$game.room) end
		@mario=char != :luigi
		@room=if @mario then $game.room else $game.level['luigi'][2] end
	end
	
	def update(sy)
		@room=$game.room if $game.player==self and $game.class==Game
		$mode=@mode
		map=$game.map
		if @dead and $count%16==0 then if @dir==:left then @dir=:right else @dir=:left end end
		if @dead then anim.seq=[27] and @y+=@vy.to_i and @vy+=0.1 end
		if @dead and !Msc['Fail.ogg'].playing? and $lives>0 then $lives-=1
			$mode=:small
			$game=BetweenLevels.new($thumb,"#{if !$profile then "own_levels" else "worlds" end}/#{$game.level['name']}")
		elsif @dead and !Msc['Fail.ogg'].playing?
			$mode=:small
			$game.over
		end
		return if @dead
		if @enter and @carry then carry_pos end
		if @enter
			@vx,@jump=@vy=0,nil
			if @warping<32
				case @enter.type
					when 0
					anim.seq=[if @carry then 6 else 0 end] if not @climb
					@x=@enter.x-8
					@y+=2
					when 1
					anim.seq=[if @carry then 6 else 0 end] if not @climb
					@x=@enter.x-8
					@y-=2
					when 2
					anim.seq=[if @carry then 6 else 1 end] and @dir=:left
					@y=if @mode==:mini then @enter.y-48 else @enter.y-24 end
					@x-=1
					when 3
					anim.seq=[if @carry then 6 else 1 end] and @dir=:right
					@y=if @mode==:mini then @enter.y-48 else @enter.y-24 end
					@x+=1
					when 4
					anim.seq=[if @carry then 6 else 0 end]
					@x=@enter.x-8
					@color.alpha-=7
				end
				@warping+=1
			elsif @warping<64
				$game.room=@exit.room
				case @exit.type
					when 0
					if not @set then @y=@exit.y+16 and @x=@exit.x-8 and Snd['warp'].play and $game.screen(0,-64) end
					anim.seq=[if @carry then 6 else 0 end] if not @climb
					@x=@exit.x-8
					@y-=2
					@color.alpha=255
					when 1
					if not @set then @y=@exit.y-64 and @x=@exit.x-8 and Snd['warp'].play and $game.screen(0,64) end
					anim.seq=[if @carry then 6 else 0 end] if not @climb
					@x=@exit.x-8
					@y+=2
					@color.alpha=255
					when 2
					if not @set then @x=@exit.x-32 and @y=if @mode==:mini then @exit.y-48 else@exit.y-24 end and Snd['warp'].play and $game.screen(32,0) end
					anim.seq=[if @carry then 6 else 1 end] and @dir=:right
					@y=if @mode==:mini then @exit.y-48 else@exit.y-24 end
					@x+=1
					@color.alpha=255
					when 3
					if not @set then @x=@exit.x+16 and @y=if @mode==:mini then @exit.y-48 else@exit.y-24 end and Snd['warp'].play and $game.screen(-32,0) end
					anim.seq=[if @carry then 6 else 1 end] and @dir=:left
					if @mode==:mini then @exit.y-48 else@exit.y-24 end
					@x-=1
					@color.alpha=255
					when 4
					anim.seq=[if @carry then 6 else 0 end]
					if not @set then @x=@exit.x-8 and @y=@exit.y-48 and $game.screen(0,0)
						@color.alpha=31
						if d=$game.entities[$game.room][8].find{|d| d.x==@exit.x-19 and d.y==@exit.y-64} then Snd['door'].play and d.open end end
					@color.alpha+=7
				end
				@warping+=1
				@set=true
			else
				@enter=@set=nil
				@warping=0
			end
		end
		
		return if @enter
		if @starman and @starman>0 then @starman-=1 elsif @starman then Msc['Invincible.ogg'].stop
			@combo[2]=0 and @starman=nil end
		if anim.sequence==[9] and @lookup>-360
			@lookup-=2
		elsif @lookup<0
			@lookup+=2
		end
		$game.screen(0,0+if @lookup<-120 then @lookup+120 else 0 end)
		if dn=down then @combo[0]=0 end
		ddn=(deep_down or @downed)
		p=up
		dp=deep_up
		sl=slope
		@combo[1]=0 if !slide
		if @mode==:mini and map.water?(@x+16,@y+79,@room) and map.rooms[$game.room]['weather'] != 11 and !up then @y-=1 end
		#Jump
		jmp=if @mode==:ninja then 14 else 8 end
    spd=if @mode==:ninja then [10,7] else [6,4] end
		if !@swim and !@climb
			if dn.class==Platform and dn.down and crouch and Keypress['jump'] and $game.player==self then @y+=16 end
			#if @vy==0 && !ddn then @y-=1 end
			if ddn and Keypress['jump',false] and $game.player==self and !@jump and not dn.class==Platform && dn.down && crouch && Keypress['jump'] && $game.player==self
				if small then Snd['jump_lo'].play else Snd['jump_hi'].play end
				@downjump=crouch
				@jump=true
				@vy=-12
				@jumpheight=0
			elsif @jump and Keypress['jump'] and $game.player==self and (@max==spd[1] && @jumpheight<jmp or @max==spd[0] && @jumpheight<jmp+@vx.abs/4) and !p
				@jumpheight+=1
			else
				@jump=nil
			end
			@vy+=$game.map.grav if not @jump and @vy<24
			if @vy>0
				if (not (@mode==:ninja and (Keypress['left'] && $game.player==self && left(false) or Keypress['right'] && $game.player==self && right(false))))
					@vy.to_i.times{$game.entities[$game.room][6].each{|e| e.det}
					if @vy>0 and !down then @y+=1 else if @vy>0 then @vy=0 end and break end}
				elsif !dn and !@downjump and !@carry
          @vy=2
					2.times{$game.entities[$game.room][6].each{|e| e.det}
					if @vy>0 and !down then @y+=1 else if @vy>0 then @vy=0 end and break end}
          @ice=false
					Snd['skid'].play
					Sparkle.new(@x+if @dir==:left then -8 else 24 end,@y+22,Tls['effects/frictionsmoke',[16,16]],[0,1,2,3],2)
          if anim.sequence==[27] and Keypress['jump',false] and $game.player==self then @vy=-12 and @jump=true and @jumpheight=9 and @vx=if @dir==:left then 6 else -6 end and @ice=true and Snd['bump'].play end
				end
			elsif @vy<0
				@vy.to_i.abs.times{$game.entities[$game.room][6].each{|e| e.det}
				if !up then @y-=1 else
					$game.entities[$game.room][1].each{|e| e.pow(leftpos,uppos-3,width,height,!small)}
					@vy=@vy.abs/2 and break end}
			end
			#Sliding
			if sl and !slide and map.solid?(@x-4,@y+64,false,@room) and @vx<2 then @vx+=0.5+sl elsif sl and !slide and map.solid?(@x+36,@y+64,false,@room) and @vx>-2 then @vx-=0.5+sl end
			if slide and map.solid?(@x-4,@y+62,false,@room)
				if @vx<12 then @vx+=0.75 end
				@y+=if sl==0 then @vx else @vx*1.4 end
				@vy=0
				while map.solid?(@x+16,@y+64-height/2,false,@room)
					@y-=1 end end
			if slide and map.solid?(@x+36,@y+62,false,@room)
				if @vx>-12 then @vx-=0.75 end
					@y-=if sl==0 then @vx else @vx*1.4 end
					@vy=0
					while map.solid?(@x+16,@y+64-height/2,false,@room)
						@y-=1 end end
			if slide and Keypress['right'] && $game.player==self || Keypress['left'] && $game.player==self then anim.seq=[0] end
			#Walking
			if dn then @ice=($game.map.ice?(leftpos,@y+80,@room) or $game.map.ice?(@x+16,@y+80,@room) or $game.map.ice?(rightpos,@y+80,@room)) end
			if Keypress['right'] and $game.player==self and not crouch && !@downjump then @dir=:right end
			if Keypress['left'] and $game.player==self and not crouch && !@downjump then @dir=:left end
			if Keypress['right'] and $game.player==self and not crouch && !@downjump and @vx<=@max then @vx+=if !@ice then 0.6 else 0.1 end elsif !(Keypress['right'] && $game.player==self) || crouch && !@downjump and @vx>0 then @vx-=if !@ice then 0.2 else 0.05 end end
			if Keypress['left'] and $game.player==self and not crouch && !@downjump and @vx.abs<=@max then @vx-=if !@ice then 0.6 else 0.1 end elsif !(Keypress['left'] && $game.player==self) || crouch && !@downjump and @vx<0 then @vx+=if !@ice then 0.2 else 0.05 end end
			if Keypress['shoot'] and $game.player==self then @max=spd[0] else @max=spd[1] end
			if @vx>0
				@vx.to_i.times{$game.entities[$game.room][6].each{|e| e.det}
				if not right(true)
					if map.solid?(@x+32,@y+63,true,@room) then @y-=0.5 end
					if map.solid?(@x+32,@y+62,true,@room) then @y-=0.5 end
					@x+=1
				else
					@vx=0 and break end}
			elsif @vx<0
				@vx.abs.to_i.times{$game.entities[$game.room][6].each{|e| e.det}
				if not left(true)
					if map.solid?(@x,@y+63,true,@room) then @y-=0.5 end
					if map.solid?(@x,@y+62,true,@room) then @y-=0.5 end
					@x-=1
				else
					@vx=0 and break end}
			end
			#Crouch
			if crouch and dp and not Keypress['down'] && $game.player==self and $game.player==self and @mode != :mini then if @dir==:left then @x+=2 else @x-=2 end end
			if crouch and @vx.to_i>0 || @vx.to_i<0 and not @downjump then friction end
			if dn && Keypress['down'] && $game.player==self || @downjump || !small && dp and not slide then anim.seq=if !@carry then [13] else [12] end end
			if sl and Keypress['down'] and $game.player==self
				anim.seq=if !@carry then [8] else [12] end
			end
			#Carry1
			if !@carry and Keypress['shoot'] and $game.player==self and o=$game.entities[$game.room][5].find{|e| !e.uncarry and not !(cnd=e.respond_to?(:solid)) && $game.map.solid?(e.x+e.size[0]/2,e.y+e.size[1]/2,false,@room) and e.x+e.size[0]+if cnd then 4 else 0 end>leftpos and e.x-if cnd then 4 else 0 end<rightpos and e.y+e.size[1]+if cnd then 4 else 0 end>uppos and e.y-if cnd then 4 else 0 end<@y+64 and cnd && @y+64<=e.y+1 && crouch || cnd && @y+64>e.y || !cnd }
				Snd['grab'].play
				@carry=o
			elsif @carry and Keypress['shoot'] && $game.player==self || @dir==:left && map.solid?(@carry.x,@carry.y+@carry.size[1],false,@room) || @dir==:right && map.solid?(@carry.x+@carry.size[0],@carry.y+@carry.size[1],false,@room)
				carry_pos
			elsif @carry and $game.player==self
				if crouch
					@carry.vy=0
					@carry=nil
				elsif not dn && Keypress['up'] && $game.player==self and !@kicked
					Snd['kick'].play
					@kicked=true
					@carry.vx=if @dir==:left then -8 else 8 end
					@carry.vy=-8
				elsif dn and Keypress['up'] and $game.player==self and !@kicked
					Snd['kick'].play
					@kicked=true
					@carry.vy=-24
				elsif @kicked
					@carry=@kicked=nil
				end
			end
			#shoot1
			if Keypress['shoot'] and $game.player==self and !small and !crouch and !@shoot
				case @mode
					when :fire
					if @limit<2
						Snd['fireball'].play
						Fireball.new(@x+if @dir==:right then 32 else 0 end,@y+30,@dir)
						@shooted=6
						@limit+=1
					end
					when :frosting
					if @limit<1
						Snd['wand'].play
						WandBlast.new(@x+if @dir==:right then 32 else 0 end,@y+20,@dir)
						@shooted=30
						@limit+=1
					end
					when :bomb
					if @limit<1
						Snd['pickup'].play
						@carry=Bomb.new(@x,@y)
						@limit+=1
					end
					when :beet
					if @limit<2
						Snd['fireshot'].play
						Beet.new(@x+if @dir==:right then 32 else 0 end,@y+30,@dir)
						@shooted=6
						@limit+=1
					end
				end
				@shoot=true
			elsif not Keypress['shoot'] && $game.player==self
				@shoot=nil
			end
			
			if !@climb and !@carry and Keypress['up'] and $game.player==self and e=$game.entities[$game.room][2].find{|e| e.climbable and e.x+24>leftpos and e.x+8<rightpos and e.y+32>uppos and e.y<@y+64}
				@x=e.x
				@climb=true
			end
			if not @swim and w=map.water?(@x,@y+48,@room)
				Sparkle.new(@x,if w.class !=Water then ($game.level['rooms'][$game.room]['height']-$game.map.specjals[$game.room].liqlevel)*32-32 else w.y-24 end,Tls['effects/splash',[32,32]],[0,1,2,3],4) if $game.map.rooms[$game.room]['weather'] != 11
				@swim=true
				anim.seq=[14,16,18]
				@vy=0
			end
		elsif @swim
			#Swim
			if not map.water?(@x+16,@y+48,@room) and @swim
				@jump=true
				@vy=if Keypress['up'] and $game.player==self then -12 else -6 end
				@jumpheight=if @mode==:ninja then 0 else 4 end
				test=map.water?(@x+16,@y+64,@room)
				Sparkle.new(@x,if test.class != Water and $game.map.specjals[$game.room] then ($game.level['rooms'][$game.room]['height']-$game.map.specjals[$game.room].liqlevel)*32-32 else test.y-24 end,Tls['effects/splash',[32,32]],[0,1,2,3],4) if $game.map.rooms[$game.room]['weather'] != 11 and $game.map.specjals[$game.room] || test
				@swim=false
			end
			if $count%30 == 0 and rand(100)<35 then Bubble.new(@x+width/2,uppos+8) end
			
			@vy+=0.2*$game.map.grav if @vy<4
			if @vy>4 then @vy-=0.4 end
			if @vx>@max then @vx-=0.1 end
			if @vx<-@max then @vx+=0.1 end
			if @vy>0
				@vy.to_i.times{if not down then @y+=1 else @vy=0 and break end}
			elsif @vy<0
				@vy.abs.to_i.times{if not up then @y-=1 else
				$game.entities[$game.room][1].each{|e| e.pow(leftpos,uppos-3,rightpos-leftpos,height,!small)}
				@vy=@vy.abs/2 and break end}
			end
			
			if dn then @max=if @mode==:ninja then 3 else 2 end else @max=if @mode==:ninja then 6 else 4 end end
			if Keypress['right'] and $game.player==self then @dir=:right end
			if Keypress['left'] and $game.player==self then @dir=:left end
			if Keypress['right'] and $game.player==self and @vx<=@max and !crouch then @vx+=0.2 elsif not Keypress['right'] && $game.player==self and @vx>0 then @vx-=0.4 end
			if Keypress['left'] and $game.player==self and @vx.abs<=@max and !crouch then @vx-=0.2 elsif not Keypress['left'] && $game.player==self and @vx<0 then @vx+=0.4 end
			if @vx.to_i !=0 and dn then anim.seq=[1,2] elsif @vx.to_i==0 and dn then anim.seq=[1] elsif anim.sequence !=[20,22,24,20,22,24] then anim.seq=[14,16,18] end
			
			if @vx>0
				@vx.to_i.times{if not right(false) then @x+=1 else @vx=0 and break end}
			elsif @vx<0
				@vx.abs.to_i.times{if not left(false) then @x-=1 else @vx=0 and break end}
			end
			if Keypress['jump'] and $game.player==self and !@swimming and @y>$game.map.miny-64 then @vy=if @mode==:ninja then -8 else -6 end and @swimming=true and Snd['swim'].play and if !@carry then anim.seq=[20,22,24,20,22,24] end end
			if anim.sequence==[20,22,24,20,22,24] and anim.ended then anim.seq=[14,16,18] end
			@swimming=false if not Keypress['jump'] && $game.player==self
	  if Keypress['down'] and $game.player==self and dn then anim.seq=[13] end
			
			#Carry2
			if not @carry and Keypress['shoot'] and $game.player==self and o=$game.entities[$game.room][5].find{|e| !e.uncarry and not cnd=!e.respond_to?(:solid) && $game.map.solid?(e.x+e.size[0]/2,e.y+e.size[1]/2,false,@room) and e.x+e.size[0]+if !cnd then 4 else 0 end>leftpos and e.x-if !cnd then 4 else 0 end<rightpos and e.y+e.size[1]+if !cnd then 4 else 0 end>uppos and e.y-if !cnd then 4 else 0 end<@y+64}
				Snd['grab'].play
				@carry=o
			elsif @carry and Keypress['shoot'] && $game.player==self || @dir==:left && map.solid?(@carry.x,@carry.y+@carry.size[1],false,@room) || @dir==:right && map.solid?(@carry.x+@carry.size[0],@carry.y+@carry.size[1],false,@room)
				@vy-=0.35 if map.water?(@x+16,uppos,@room)
				carry_pos
			elsif @carry and $game.player==self
				@carry.vx=0
				@carry.vy=0
				@carry=nil
			end
			#shoot2
			if Keypress['shoot'] and $game.player==self and !small and !crouch and !@shoot
				case @mode
					when :fire
					if @limit<2
						Snd['fireball'].play
						Fireball.new(@x+if @dir==:right then 32 else 0 end,@y+30,@dir)
						@shooted=6
						@limit+=1
					end
					when :frosting
					if @limit<1
						Snd['wand'].play
						WandBlast.new(@x+if @dir==:right then 32 else 0 end,@y+20,@dir)
						@shooted=30
						@limit+=1
					end
					when :bomb
					if @limit<1
						Snd['pickup'].play
						@carry=Bomb.new(@x,@y)
						@limit+=1
					end
					when :beet
					if @limit<2
						Snd['fireshot'].play
						Beet.new(@x+if @dir==:right then 32 else 0 end,@y+30,@dir)
						@shooted=6
						@limit+=1
					end
				end
				@shoot=true
			elsif not Keypress['shoot'] && $game.player==self
				@shoot=nil
			end
			if @shooted and @shooted-1>0 then if dn then anim.seq=[27] else anim.seq=[14] end  and @shooted-=1 elsif @shooted then @shooted=nil end
		else
			#Climb
			anim.seq=[26]
			if Keypress['up'] and $game.player==self
				3.times{if !up and @y+64>0 and $game.entities[$game.room][2].find{|e| e.climbable and e.x+32>leftpos and e.x<rightpos and e.y+if @mode==:mini then 56 else 32 end>uppos and e.y<@y+48} then @y-=1 end}
				@dir=[:left,:right][($count/8)%2]
				Snd['climbing'].play if $count%8==0
			elsif Keypress['down'] and $game.player==self
				3.times{if !down and $game.entities[$game.room][2].find{|e| e.climbable and e.x+32>leftpos and e.x<rightpos and e.y+if @mode==:mini then 28 else 8 end>uppos and e.y<@y+64} then @y+=1 end}
				@dir=[:left,:right][($count/8)%2]
				Snd['climbing'].play if $count%8==0
			end
			if Keypress['jump',false] and $game.player==self
				if !small then Snd['jump_hi'].play else Snd['jump_lo'].play end
				@unclimb=true
				@climb=false
				@jump=true
				@vy=-12
				@jumpheight=6
				if Keypress['right'] and $game.player==self then @vx=4 elsif Keypress['left'] and $game.player==self then @vx=-4 else @vx=0 end
			end
		end
		
		#Animations
		if !@swim and !@climb
			if Keypress['right'] and $game.player==self and @vx.to_i<0 and not crouch then anim.seq=[11]
				friction if dn and not crouch end
			if Keypress['left'] and $game.player==self and @vx.to_i>0 and not crouch then anim.seq=[11]
				friction if dn and not crouch end
			if @vx.to_i !=0 and not (Keypress['right'] && $game.player==self && @vx<0 or Keypress['left'] && $game.player==self && @vx>0) and not slide and not crouch then anim.seq=if !@carry then [1,2] else [6,5] end elsif @vx.to_i==0 and not crouch && (dp && @mode !=:mini || Keypress['down']) then anim.seq=if !@carry then [1] else [6] end end
			if dn and @vx.to_i==0 and Keypress['up'] and $game.player==self and not crouch && (dp && @mode !=:mini || Keypress['down'] && $game.player==self) then anim.seq=if @carry then [10] else [9] end end
			if !ddn and !crouch then anim.seq=if !@carry then [3] else [4] end end
			if !dn and !@downjump and !@carry and (@mode==:ninja and (Keypress['left'] && $game.player==self && left(false) or Keypress['right'] && $game.player==self && right(false))) then anim.seq=[27] end
			if @downjump and dn && @vy>=0 then @downjump=nil end
			if @kicked then anim.seq=[7] end
			if @shooted and @shooted-1>0 then anim.seq=[27] and @shooted-=1 elsif @shooted then @shooted=nil end
		end
		if $count % 8==0 then anim.next end
		#Warps
		if Keypress['down'] and $game.player==self and map.solid?(@x+16,@y+65,false,@room) || @y+64>=map.rooms[$game.room]['height']*32 && @climb then map.warps.each{|w| w.check(@x+16,@y+64,0)} end
		if Keypress['up'] and $game.player==self and map.solid?(@x+16,uppos-1,false,@room) || @y<=$game.map.miny && @climb then map.warps.each{|w| w.check(@x+16,uppos,1)} end
		if Keypress['left'] and $game.player==self and map.solid?(leftpos-4,@y+64-height/2,false,@room) then map.warps.each{|w| w.check(@x,@y+(64-height/2),2)} end
		if Keypress['right'] and $game.player==self and map.solid?(rightpos+4,@y+64-height/2,false,@room) then map.warps.each{|w| w.check(@x+32,@y+(64-height/2),3)} end
		if Keypress['up'] and $game.player==self then map.warps.each{|w| w.check(@x+16,@y+56,4)} end
		
		if @light and @mode != :glow
			@light.remove
			@light=nil
		end
		if @light then @light.x=@x and @light.y=@y+16 and @light.room end
	#puts map.mask(1,[1072/512,320/512]).get_pixel(560-512,320).join' '
		if !@end and map.solid?(@x+16,@y+64-height/2,false,@room) or @y>map.rooms[@room]['height']*32+32 or map.lava?(@x+16,@y+64,@room) then kill end
		if map.harmful?(@x+16,@y+63,@room) or map.harmful?(leftpos+1,@y+63,@room) or map.harmful?(rightpos-1,@y+63,@room) or map.harmful?(@x+16,uppos+height/2,@room) or map.harmful?(leftpos+1,uppos+height/2,@room) or map.harmful?(rightpos-1,uppos+height/2,@room) or map.harmful?(@x+16,uppos+1,@room) or map.harmful?(leftpos+1,uppos+1,@room) or map.harmful?(rightpos-1,uppos+1,@room) then Entity.unbonus end
		endit if @end
		@downed=nil
	end
	
	def draw(sx,sy)
		if @transforming and @transforming>0 and $count%8<4 then return elsif @transforming==0 then @transforming=nil end
		@transforming-=1 if @transforming
		if @dir==:left
			off=1
			pos=0
		else
			off=-1
			pos=32
		end
		anim.frame.draw(@x+pos-sx,@y-sy,if !@dead then 2 else 4 end,off,1,if !@starman then @color else Color.from_hsv(rand(360),1,1) end)
		if swim then anim.for_swim.draw(@x-(pos-32)-sx,@y-sy,2,off,1,if !@starman then @color else Color.from_hsv(rand(360),1,1) end) end
	end
	
	def right(upper)
		map=$game.map
		case height
			when 64
			map.solid?(@x+32,@y+6,false,@room) or map.solid?(@x+32,@y+32,false,@room) or map.solid?(@x+32,@y+ if upper then 40 else 63 end,false,@room)
			
			when 42
			map.solid?(@x+32,@y+28,false,@room) or map.solid?(@x+32,@y+ if upper then 40 else 63 end,false,@room)
			
			when 32
			map.solid?(@x+32,@y+38,false,@room) or map.solid?(@x+32,@y+ if upper then 40 else 63 end,false,@room)
			
			when 12
			map.solid?(@x+21,@y+52,false,@room) or map.solid?(@x+21,@y+ if upper then 55 else 63 end,false,@room)
		end
	end
	
	def left(upper)
		map=$game.map
		case height
			when 64
			map.solid?(@x,@y+6,false,@room) or map.solid?(@x,@y+32,false,@room) or map.solid?(@x,@y+ if upper then 40 else 63 end,false,@room)
			
			when 42
			map.solid?(@x,@y+28,false,@room) or map.solid?(@x,@y+ if upper then 40 else 63 end,false,@room)
			
			when 32
			map.solid?(@x,@y+38,false,@room) or map.solid?(@x,@y+ if upper then 40 else 63 end,false,@room)
			
			when 12
			map.solid?(@x+11,@y+52,false,@room) or map.solid?(@x+11,@y+ if upper then 55 else 63 end,false,@room)
		end
	end
	
	def down
		map=$game.map
		if height !=12
			if o=map.solid?(@x+6,@y+64,true,@room) or o=map.solid?(@x+16,@y+64,true,@room) or o=map.solid?(@x+26,@y+64,true,@room)
				o
			end
		else
			if o=map.solid?(@x+12,@y+64,true,@room) or o=map.solid?(@x+16,@y+64,true,@room) or o=map.solid?(@x+20,@y+64,true,@room) or o=map.water?(@x+16,@y+58,@room) or (o=map.water?(@x+16,@y+80,@room)) && o.class != Water
				o
			end
		end
	end
	
	def deep_down
		map=$game.map
		if height !=12
			map.solid?(@x+7,@y+72,true,@room) or map.solid?(@x+16,@y+72,true,@room) or map.solid?(@x+26,@y+72,true,@room)
		else
			map.solid?(@x+12,@y+72,true,@room) or map.solid?(@x+16,@y+72,true,@room) or map.solid?(@x+20,@y+72,true,@room) or map.water?(@x+16,@y+72,@room) or o=map.water?(@x+16,@y+92,@room) && o.class != :water
		end
	end
	
	def slope
		map=$game.map
		x=8
		slop=false
		3.times{y=66 and 5.times{
		if map.slope?(@x+x,@y+y,@room)[0]
			slop=map.slope?(@x+x,@y+y,@room)[1]
			break
			else y+=2 end} and x+=8}
		slop
	end
	
	def up
		map=$game.map
		if height !=12
			map.solid?(@x+6,@y+(64-height)+5,false,@room) or map.solid?(@x+16,@y+(64-height)+5,false,@room) or map.solid?(@x+26,@y+(64-height)+5,false,@room)
		else
			map.solid?(@x+12,@y+51,false,@room) or map.solid?(@x+16,@y+51,false,@room) or map.solid?(@x+20,@y+51,false,@room)
		end
	end
	
	def deep_up
		map=$game.map
		@mode != :mini and map.solid?(@x+6,@y+8,false,@room) or map.solid?(@x+16,@y+8,false,@room) or map.solid?(@x+26,@y+8,false,@room)
	end
	
	def uppos
		@y+(64-height)
	end
	
	def leftpos
		if @mode==:mini then @x+10 else @x+4 end
	end
	
	def rightpos
		if @mode==:mini then @x+22 else @x+28 end
	end
	
	def height
		if @mode!=:mini && crouch
			32
		elsif @mode==:small
			42
		elsif @mode==:mini
			12
		else
			64
		end
	end
	
	def width
		rightpos-leftpos
	end
	
	def crouch
		[12,13].include?(anim.index)
	end
	
	def slide
		anim.index==8
	end
	
	def swim
		[14,16,18,20,22,24].include?(anim.index)
	end
	
	def carry(obj) 
		(@carry==obj)
	end
	
	def anim
		@modes[@mode]
	end
	
	def small
		(@mode==:small || @mode==:mini)
	end
	
	def kill
		return if @dead or @end
		Msc['Fail.ogg'].play
		@mode=:small if @mode != :mini
		@dead=true
		@vy=-6 if @y<$game.map.height+16
	end

	def carry_pos
		@carry.room=$game.room
		@carry.x=if @dir==:right then @x+24 else @x-@carry.size[0]+6 end
		@carry.y=if !small and !crouch then @y+50-@carry.size[1] elsif !small then @y+58-@carry.size[1] elsif @mode != :mini and !crouch then @y+58-@carry.size[1] else @y+64-@carry.size[1] end
	end

	def uncarry
		@carry=nil
	end

	def endit
		lefd=(!@secret && $game.level['end'][0] or @secret && $game.level['end'][1])
		@dir=if lefd then :left else :right end
		if @end.class==Fixnum
			if !down
				@vy=4
				@vx=0
				anim.seq=[8] if @end==0
			end
			if @end<60 and down
				@vx=if lefd then -4 else 4 end
			elsif down
			 @vx=0
			 anim.seq=[0]
			end
			@end+=1 if down
		else
			@vx=if lefd then -4 else 4 end
		end
		
		if !Msc['StageClear.ogg'].playing? and $game.time>0
			Snd['timecount'].play
			$game.time-=1
			$points+=50
		elsif !Msc['StageClear.ogg'].playing?
			$saved=nil
			if !$randomized
				if File.exists?("data/#{w=if $profile then "worlds" else "own_levels" end}/#{$game.level[if @secret then 'secret' else 'next' end]}.mlv")
					if $profile and $world>-1 and !$profile['done'].find{|l| l[0]==$game.level['name'] and l[1]==@secret}
						$profile['done'] << [$game.level['name'],@secret]
						$profile['worlds'][$world]+=100.0/$game.map.world($world)
						if $game.level['next'][2]=='1' and !$profile['worlds'][$world+1] then $profile['worlds'][$world+1]=0 end
					end
					another=Marshal.load(File.open("data/#{w=if $profile then "worlds" else "own_levels" end}/#{$game.level[if @secret then 'secret' else 'next' end]}.mlv"))
					th=if $profile then Image.new($screen,"data/worlds/thumbs/#{another['thumbnail']}.png") else Img["thumbnails/#{another['thumbnail']}"] end
					$game=BetweenLevels.new(th,"#{w=if $profile then "worlds" else "own_levels" end}/#{$game.level[if @secret then 'secret' else 'next' end]}")
				else
					$game.button_down(KbEscape)
				end
			else
				$game=BetweenLevels.new(Img['thumbnails/random'],:random)
			end
		end
	end

	def friction
		Snd['skid'].play_pan(0)
		Sparkle.new(@x+if @mode==:mini then 14 else 8 end,@y+if @mode==:mini then 60 else 48 end,Tls['effects/frictionsmoke',[16,16]],[0,1,2,3],2,if @mode==:mini then 0.2 else 1 end)
	end

	def jumpable
		@downed=true
	end
end