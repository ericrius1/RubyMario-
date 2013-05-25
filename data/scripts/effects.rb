class Particle < Entity
	def initialize(x,y,img,color=0xffffffff)
		@x,@y,@img,@angle,@vex,@vey,@color=x,y,img,rand(360),6-rand(12),0-(rand(12)),color
		init(nil,$game.room)
	end
	
	def update(sx,sy)
		@x+=@vex
		@y+=@vey
		@vey+=1
		if @vex>=0 then @angle+=1 else @angle-=1 end
		if @y>sy+480 then remove end
	end
	
	def draw(sx,sy)
		@img.draw_rot(@x-sx,@y-sy,1,@angle,0.5,0.5,1,1,@color)
	end
end

class Sparkle < Entity
	def initialize(x,y,img,seq,time,scale=1)
		@x,@y,@frames,@time,@scale=x,y,Animation.new(img,seq),time,scale
		init(nil,$game.room)
	end
	
	def update(sx,sy)
		if @frames.ended then remove end
		if $count%@time==0 then @frames.next end
	end
	
	def draw(sx,sy)
		@frames.frame.draw(@x-sx,@y-sy,3,@scale,@scale)
	end
end

class Points < Entity
	def initialize(x,y,ammount)
		@x,@y,@ammount,@time=x,y,ammount,255
		init(nil,$game.room)
	end
	
	def update(sx,sy)
		@y-=3
		if @time-6>0 then @time-=6 else remove end
	end
	
	def draw(sx,sy)
		Fnt['fonts/NINE.ttf',20].draw_rel(@ammount,@x-sx,@y-sy,4,0.5,0)
	end
end

class Fall < Entity
	def initialize(x,y,type,dir,speed)
		@x,@y,@type,@dir,@speed=x,y,type,dir,speed
		init(nil,$game.room)
	end
	
	def update(sx,sy)
		@x+=vex=offset_x(@dir,@speed)
		@y+=vey=offset_y(@dir,@speed)
		if vex<0 && @x<0 or vex>0 && @x>640 or vey<0 && @y<sy or vey>0 && @y>480 then remove end
	end
	
	def draw(sx,sy)
		@type.draw_rot(@x,@y,5,@dir,0.5,0.5)
	end
end

class Thunder < Entity
	def initialize(x,scale)
		@x,@scale,@color=x,scale,Color.new(0xffffffff)
		init(nil,$game.room)
	end
	
	def update(sx,sy)
		if @color.alpha-8 > 0 then @color.alpha-=4 else remove end
	end
	
	def draw(sx,sy)
		Tls['effects/thunder',[32,240]][rand(5)].draw(@x-16,0,1,@scale,@scale)
	end
end

class Fog < Entity
	def initialize(x,y,scale,img)
		@x,@y,@scale,@img=x,y,scale,img
		init(nil,$game.room)
	end
	
	def update(sx,sy)
		if rand(50)==25
			case rand(3)
				when 0
				@x+=1
				when 1
				@y-=1
				when 2
				@x-=1
				when 3
				@y+=1
			end
		end
	end
	
	def draw(sx,sy)
		@img.draw(@x-sx/8,@y-sy/8,5,@scale,@scale)
	end
end

class LifeUp < Entity
	def initialize(x,y,three)
		@x,@y,@three,@time=x,y,three,255
		init(nil,$game.room)
	end
	
	def update(sx,sy)
		@y-=3
		if @time-6>0 then @time-=6 else remove end
	end
	
	def draw(sx,sy)
		Tls['effects/extralife',[38,16]][@three].draw(@x-19-sx,@y-sy,4)
	end
end

class Bubble < Entity
	def initialize(x,y)
		@x,@y,@x2=x,y,x
    init(nil,$game.room)
	end
	
	def update(sx,sy)
		if @pop and @pop+1<8 then @pop+=1 elsif @pop then remove end
		return if @pop
		if rand(50)==25 and @x<@x2+16 then @x+=1 end
		if rand(50)==25 and @x>@x2-16 then @x-=1 end
		@y-=2
		if !$game.map.water?(@x+3,@y+3) or $game.map.solid?(@x+3,@y+3)
			@pop=0
		end
	end
	
	def draw(sx,sy)
		Tls['effects/bubble',[7,7]][if @pop then (@pop/4)+1 else 0 end].draw(@x-sx,@y-sy,4)
	end
end

class Pop < Entity
	def initialize(x,y,img,scale,speed)
		@x,@y,@img,@scale,@speed=x,y,img,scale,speed
		@color=Color.new(0xffffffff)
		@light=Light.new(x-8,y-9,1,[false],$game.map,$game.room) if img==Img['projectiles/firepop']
		init(nil,$game.room)
	end

	def update(sx,sy)
		if @color.alpha-@speed>0 then @color.alpha-=@speed else remove end
	end

	def draw(sx,sy)
		@img.draw_rot(@x-sx,@y-sy,4,0,0.5,0.5,@scale*(@color.alpha.to_f/255),@scale*(@color.alpha.to_f/255),@color)
	end
end