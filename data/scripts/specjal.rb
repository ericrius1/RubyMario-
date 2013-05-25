class Keypress
	def Keypress.[](id,repeat=true)
		return if $game.class==Game and $game.player.end
		@@keys = [] unless defined?(@@keys)
		if id.class==String
			@@keys.each{|k| if !$screen.button_down?($keys[k]) then @@keys.delete(k) end}
			if repeat
				if !@@keys.include?(id) then @@keys << id else true end if $screen.button_down?($keys[id])
			elsif $screen.button_down?($keys[id]) and !@@keys.include?(id)
				@@keys << id
			end
		else
			$screen.button_down?(id)
		end
	end
end

class Img
  def Img.[](name,tileable=false)
	@@images = Hash.new unless defined?(@@images)
	if @@images[name.downcase]
	  @@images[name.downcase]
	else
	  @@images[name.downcase] = Image.new($screen, "gfx/"+name.downcase+".png",tileable)
	end
  end
end

class Tls
  def Tls.[](name,size,able=false)
	@@tiles = Hash.new unless defined?(@@tiles)
	if @@tiles[[name.downcase,size]]
	  @@tiles[[name.downcase,size]]
	else
	  @@tiles[[name.downcase,size]] = Image.load_tiles($screen, "gfx/"+name.downcase+".png", size[0], size[1], able)
	end
  end
end

class Snd
  def Snd.[](name)
	@@sounds = Hash.new unless defined?(@@sounds)
	if @@sounds[name.downcase]
	  @@sounds[name.downcase]
	else
	  @@sounds[name.downcase] = Sample.new($screen, "sfx/"+name.downcase+".ogg")
	end
  end
end

class Msc
  def Msc.[](name)
	@@music = Hash.new unless defined?(@@music)
	if @@music[name.downcase]
	  @@music[name.downcase]
	else
	  @@music[name.downcase] = Song.new($screen, "music/"+name.downcase)
	end
  end
end

class Fnt
  def Fnt.[](name,size)
	@@fonts = Hash.new unless defined?(@@fonts)
	if @@fonts[[name.downcase,size]]
	  @@fonts[[name.downcase,size]]
	else
	  @@fonts[[name.downcase,size]] = Font.new($screen, name.downcase, size)
	end
  end
end

class Text
	def Text.[](x,y,z,text,scale,xspacing,yspacing,max,alpha,mode=:normal,space=1)
		font=Tls['system/font',[20,20]]
		chars=['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','1','2','3','4','5','6','7','8','9','0','.','/',':','!','@','%','?','_','-',',','<','>','+']
		posx=0
		posy=0
		text.to_s.each_char{|c| if c != '^' and (cnd=chars.include?(c.upcase)) then font[chars.index(c.upcase)].draw(x+posx-if mode==:center then (xspacing*text.to_s.length)/2 elsif mode==:back then xspacing*text.to_s.length else 0 end,y+posy,z,scale,scale,Color.new(alpha,255,255,if c.upcase==c and !['1','2','3','4','5','6','7','8','9','0','.','/',':','!','@','%','?','_','-',',','<','>','+'].find{|char| char==c} then 0 else 255 end)) elsif c=='^' then posy+=yspacing and posx=0 end
		if max>0 and posx+xspacing>max then posy+=yspacing and posx=0 else posx+=xspacing*if !cnd then space else 1 end end}
	end
end

class Entity
	attr_reader :x, :y, :dead, :projectile, :active, :through, :uncarry
	def remove(light=true)
		if @light and light then @light.remove end
		$game.entities[@room].each{|e| if e.class==Array
			e.delete(self) end}
		$game.entities[@room].delete(self)
		$game.entities[$game.level['rooms'].length].delete(self)
		$game.entities[$game.level['rooms'].length+1].delete(self)
	end
  
	def init(type,room)
		if type
			type.each{|t|
			case t
				when :lava
				$game.entities[room][0] << self
				when :powable
				$game.entities[room][1] << self
				when :climb
				$game.entities[room][2] << self
				when :water
				$game.entities[room][4] << self
				when :carry
				$game.entities[room][5] << self
				when :enemy
				@inv=0
				$game.entities[room][6] << self
				when :powish
				$game.entities[room][7] << self
				when :door
				$game.entities[room][8] << self
				when :platform
				$game.entities[room][9] << self
				when :destroyable
				$game.entities[room][10] << self
				when :changeable
				$game.entities[$game.level['rooms'].length] << self
				when :pswitchable
				$game.entities[$game.level['rooms'].length+1] << self
			end}
		end
		$game.entities[room] << self
		@room=room
	end
	
	def detect_player(x,y,width,height)
		@inv-=1
		return if @inv>0 or @dead
		player=$game.player
		if !player.transforming and !player.slide and !player.starman and player.y+56>y and player.leftpos<x+width and player.rightpos>x and player.uppos<y+height
			player_down
		elsif player.starman and player.y+64>y and player.leftpos<x+width and player.rightpos>x and player.uppos<y+height
			kick(:star)
		elsif !player.starman and !player.slide and player.vy>-5 and player.y+64>=y and player.leftpos<x+width and player.rightpos>x and player.y+64<=y+size[1]/4
			@inv=15
			stomp
			if Keypress['jump'] then player.jumpheight=0 and player.jump=true end
		elsif player.slide and player.y+64>y and player.leftpos<x+width and player.rightpos>x and player.uppos<y+height
			@inv=15
			kick(false)
		end
	end

	def player_down
		return if (player=$game.player).end or @unharm or player.enter
		Entity.unbonus
	end

	def Entity.unbonus
		return if (player=$game.player).starman or player.transforming
		if ![:small,:mini].include?(player.mode)
			$game.hold
			Snd['powerdown'].play
			player.transforming=60
			player.mode=:small
		else
			player.kill
		end
	end

	def combo(x,y,amm)
		if amm<8
			ar=[nil,200,400,800,1000,2000,4000,8000]
			$points+=ar[amm]
			Points.new(x,y,ar[amm])
		else
			Snd['1up'].play
			$lives+=1
			LifeUp.new(x,y,0)
		end
	end

	def act(x,y,width,height,sx,sy,screen=false)
		if !@active and x<sx+640 and y<sy+480 and x+width>sx and y+height>sy
			@active=true
		elsif screen and @active==true and not x<sx+640 && y<sy+480 && x+width>sx && y+height>sy
			@active = false
		end
		@active
	end

	def checkenemy(x,y)
		$game.entities[$game.room][6].find{|e| e !=self and !e.through and !e.dead and !e.projectile and e.x<x and e.x+e.size[0]>x and e.y<y and e.y+e.size[1]>y}
	end

	def physics(width=size[0],height=size[1])
		@vy+=$game.map.grav
		if @vy>0 and @y-64<$game.map.height
			@vy.to_i.times{if !$game.map.solid?(@x+2,@y+height,true) and !$game.map.solid?(@x+width/2,@y+height,true) and !$game.map.solid?(@x+width-2,@y+height,true)
			@y+=1 else @vy=0 and break end}
		elsif @vy<0
			@vy.to_i.abs.times{if !$game.map.solid?(@x+2,@y) and !$game.map.solid?(@x+width/2,@y) and !$game.map.solid?(@x+width-2,@y)
			@y-=1 else @vy=0 and break end}
		end
		if @vx>0
			@vx.to_i.times{if !$game.map.solid?(@x+width-1,@y) and !$game.map.solid?(@x+width-1,@y+height/2) and !$game.map.solid?(@x+width-1,@y+height)
			@x+=1 else @vx=0 and break end}
		elsif @vx<0
			@vx.to_i.abs.times{if !$game.map.solid?(@x+1,@y) and !$game.map.solid?(@x+1,@y+height/2) and !$game.map.solid?(@x+1,@y+height)
			@x-=1 else @vx=0 and break end}
		end
		if @vx.to_i>0 then @vx-=0.05 elsif @vx.to_i<0 then @vx+=0.05 end
	end
end

class Animation
	def initialize(frames,sequence)
		@frames,@sequence,@cur=frames,sequence,0
	end
  
	def next
		@cur+=1
	end
  
	def prev
		@cur-=1
	end
  
	def set(frame)
		@cur=frame
	end
  
	def frame
		if @cur>=@sequence.length then @cur=0 and @end=true end
		if @cur<=-1 then @cur=@sequence.length-1 end
		@frames[@sequence[@cur]]
	end
	
	def for_swim
		@frames[@sequence[@cur]+1]
	end
	
	def seq=(new)
		@sequence=new
		@end=false
	end
	
	def index
		if @cur>=@sequence.length then @cur=0 and @end=true end
		if @cur<=-1 then @cur=@sequence.length-1 end
		@sequence[@cur]
	end
	
	def ended
		@end
	end
	
	def sequence
		@sequence
	end

	def cur
		@cur
	end
end