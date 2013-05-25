class Zip
	attr_accessor :val
	def initialize(x,y,div)
		@x,@y,@max,@val=x,y,div,0
		$game.system << self
	end
	
	def update(mx,my)
		if @my then $screen.set_mouse_position(mx,@my) end
		if mx>@x-1 and mx<@x+@max and my>@y-3 and my<@y+5 and Keypress[MsLeft]
			@my=my
			@val=(mx-@x).round
		elsif @my and mx<@x-1
			@val=0
		elsif @my and mx>@x+@max
			@val=@max
			Text[@x+@val,@y-14,5,@val,0.55,11,11,0,255,:center]
		elsif not Keypress[MsLeft]
			@my=nil
		end
	end
	
	def draw
			Text[@x+@val,@y-14,5,@val,0.55,11,11,0,255,:center] if @my
		$screen.draw_line(@x-1,@y,0xffc0c0c0,@x+@max+4,@y,0xffc0c0c0,4)
		$screen.draw_line(@x-1,@y+1,0xff808080,@x+@max+4,@y+1,0xff808080,4)
		Img['editor/zip_bar'].draw(@x+@val,@y-2,4)
	end
end

class TextField < TextInput
	attr_reader :val
	def initialize(x,y,chars,max)
		super()
		@x,@y,@chars,@max,@min,@pos=x,y,chars,max,0,max/9
		@val=self.text=""
		if @max>=450 then @smallit=true end
		@factor=1
		$game.system << self
	end
	
	def update(mx,my)
		@val=self.text
		if mx>@x-2 and mx<@x+@max+2 and my>@y-2 and my<@y+17 and Keypress[MsLeft]
			$screen.text_input=self
		end
		if Keypress[KbEscape] then $screen.text_input=nil end
		if self.text.length>@chars then self.text=self.text.chop end
	end
	
	def draw
		if @chars*9>@max
			if self.caret_pos>@pos then @pos+=1 and @min+=1 end
			if self.caret_pos<@min then @pos-=1 and @min-=1 end
		end
		c=0xffc0c0c0
		$screen.draw_quad(@x-2,@y-2,c,@x+@max+2,@y-2,c,@x+@max+2,@y+17,c,@x-2,@y+17,c,4)
		c=0xffd0d0d0
		$screen.draw_quad(@x,@y,c,@x+@max,@y,c,@x+@max,@y+15,c,@x,@y+15,c,4)
		
		if $screen.text_input==self
			pos_x = @x+(self.caret_pos-(@pos-@max/9))*9+1
			$screen.draw_quad(pos_x,@y+1,0xffffffff,pos_x+9,@y+1,0xffffffff,pos_x+9,@y+15,0xffffffff,pos_x,@y+15,0xffffffff,4) if milliseconds % 500 > 250
		end
		Text[@x,@y+3,4,@val[@min...@pos],0.45,9,9,0,255]
	end
	
	def val=(text)
		self.text=text
		@val=val
	end
end

class Press
	attr_writer :trigg
	def initialize(x,y,text)
		@x,@y,@text,@func=x,y,text,0
		$game.system << self
	end
	
	def update(mx,my)
		if mx>@x-2 and mx<@x+@text.length*6+2 and my>@y-2 and my<@y+17
			@func=1
			if Keypress[MsLeft]
				@func=2
			end
		else
			@func=0
		end
		@click=nil if not Keypress[MsLeft]
	end
	
	def draw
		case @func
			when 0
			c1=0xffa0a000
			c2=0xffc0c000
			when 1
			c1=0xff0000c0
			c2=0xff0000e0
			when 2
			c1=0xffc00000
			c2=0xffe00000
		end
		max=@text.length*6+1
		$screen.draw_quad(@x-2,@y-2,c1,@x+max+2,@y-2,c1,@x+max+2,@y+17,c1,@x-2,@y+17,c1,4)
		$screen.draw_quad(@x,@y,c2,@x+max,@y,c2,@x+max,@y+15,c2,@x,@y+15,c2,4)
		Text[@x,@y+4,4,@text,0.4,6,6,0,255]
	end
	
	def press
		if @func==2 and !@click or @trigg
			@trigg=nil
			@click=true
			true
		end
	end
	
	def over
		@func==1
	end
end

class Changer
	attr_accessor :val
	def initialize(x,y,texts)
		@x,@y,@texts,@func,@val=x,y,texts,0,0
		$game.system << self
	end
	
	def update(mx,my)
		if mx>@x-2 and mx<@x+@texts[@val].length*6+2 and my>@y-2 and my<@y+17
			@func=1
			if Keypress[MsLeft]
				@func=2
				@val+=1 if not @click
				@click=true
			elsif Keypress[MsRight]
				@func=2
				@val-=1 if not @click
				@click=true
			end
		else
			@func=0
		end
		if @val==@texts.length then @val=0 elsif @val==-1 then @val=@texts.length-1 end
		@click=nil if not Keypress[MsLeft] and not Keypress[MsRight]
	end
	
	def draw
		case @func
			when 0
			c1=0xff00a000
			c2=0xff00c000
			when 1
			c1=0xff0000c0
			c2=0xff0000e0
			when 2
			c1=0xffc00000
			c2=0xffe00000
		end
		max=@texts[@val].length*6+1
		$screen.draw_quad(@x-2,@y-2,c1,@x+max+2,@y-2,c1,@x+max+2,@y+17,c1,@x-2,@y+17,c1,4)
		$screen.draw_quad(@x,@y,c2,@x+max,@y,c2,@x+max,@y+15,c2,@x,@y+15,c2,4)
		Text[@x,@y+4,4,@texts[@val],0.4,6,6,0,255]
	end

	def clicked
		@func==2
	end
end

class Counter
	attr_accessor :val, :max
	def initialize(x,y,min,max)
		@x,@y,@min,@max,@val,@func=x,y,min,max,min,[0,3]
		$game.system << self
	end
	
	def update(mx,my)
		if @val>@max then @val-=1 end
		if mx>@x+32 and mx<@x+47 and my>@y-2 and my<@y+8
			@func[0]=1
			Text[mx+8,my-5,5,'try Shift or Control',0.5,10,10,0,255] if not Keypress[KbLeftShift] and not Keypress[KbLeftControl]
			if Keypress[MsLeft] and not Keypress[KbLeftShift] and not Keypress[KbLeftControl]
				@func[0]=2
				@val+=1 if @val<@max
			elsif Keypress[MsLeft] and not Keypress[KbLeftControl]
				@func[0]=2
				@val+=1 if @val<@max and not @limit
				@limit=true
			elsif Keypress[MsLeft]
				@func[0]=2
				if @val+49<@max then @val+=50 else @val=@max end
			end
		else
			@func[0]=0
		end
		
		if mx>@x+32 and mx<@x+47 and my>@y+8 and my<@y+18
			@func[1]=4
			Text[mx+8,my-5,5,'try Shift or Control',0.5,10,10,0,255] if not Keypress[KbLeftShift] and not Keypress[KbLeftControl]
			if Keypress[MsLeft]  and not Keypress[KbLeftShift] and not Keypress[KbLeftControl]
				@func[1]=5
				@val-=1 if @val>@min
			elsif Keypress[MsLeft] and not Keypress[KbLeftControl]
				@func[1]=5
				@val-=1 if @val>@min and not @limit
				@limit=true
			elsif Keypress[MsLeft]
				@func[1]=5
				if @val-49>@min then @val-=50 else @val=@min end
			end
		else
			@func[1]=3
		end
		@limit=false if not Keypress[MsLeft]
	end
	
	def draw
		c=0xffa0a0a0
		$screen.draw_quad(@x-2,@y-2,c,@x+32,@y-2,c,@x+32,@y+18,c,@x-2,@y+18,c,4)
		c=0xffc0c0c0
		$screen.draw_quad(@x,@y,c,@x+30,@y,c,@x+30,@y+16,c,@x,@y+16,c,4)
		Text[@x,@y+4,4,@val,0.4,7,7,0,255]
		
		Tls['editor/counter',[15,10],true][@func[0]].draw(@x+32,@y-2,4)
		Tls['editor/counter',[15,10],true][@func[1]].draw(@x+32,@y+8,4)
	end
end

class Check
	attr_accessor :val
	def initialize(x,y,neg)
		@x,@y,@neg,@val=x,y,neg,false
		$game.system << self
	end
	
	def update(mx,my)
		if mx>=@x and mx<=@x+16 and my>=@y and my<=@y+16 and Keypress[MsLeft] and not @click
			case @val
				when false
				@val=true
				when true
				if not @neg then @val=false else @val=nil end
				when nil
				@val=false
			end
			@click=true
		end
		@click=false if not Keypress[MsLeft]
	end
	
	def draw
		case @val
			when false
			t=0
			when true
			t=1
			when nil
			t=2
		end
		Tls['editor/check',[16,16]][t].draw(@x,@y,4)
	end
end

class Tileselector
	attr_reader :val
	def initialize(x,y,tiles,size)
		@x,@y,@tiles,@size,@val,@sel=x,y,tiles,size,0,[0,0]
		$game.system << self
	end
	
	def update(mx,my)
		if mx>@x and mx<@x+@tiles.width/2 and my>@y and my<@y+@tiles.height/2 and Keypress[MsLeft]
			select(mx.to_i,my.to_i)
		end
	end
	
	def draw
		@tiles.draw(@x,@y,4,0.5,0.5)
		c=0x80ffffff
		$screen.draw_quad(@x+@sel[0],@y+@sel[1],c,@x+@sel[0]+@size[0]/2,@y+@sel[1],c,@x+@sel[0]+@size[0]/2,@y+@sel[1]+@size[1]/2,c,@x+@sel[0],@y+@sel[1]+@size[1]/2,c,4) if milliseconds % 500>250
	end
	
	def select(x,y)
		@val=(x-@x)/(@size[0]/2)+(@tiles.width/@size[0])*((y-@y)/(@size[1]/2))
		@sel[0]=((x-@x)/(@size[0]/2))*@size[0]/2
		@sel[1]=((y-@y)/(@size[1]/2))*@size[1]/2
	end

	def val=(new)
		@val=new
		@sel[0]=0
		@sel[1]=0
		@val.times{@sel[0]+=@size[0]/2
		if @sel[0]>=(@tiles.width)/2 then @sel[1]+=@size[1]/2
			@sel[0]=0 end}
	end
end

class Panel
	def initialize(x,y,width,height)
		@x,@y,@width,@height=x,y,width,height
		@img=TexPlay.create_blank_image($screen,[width-4,0].max,[height-4,0].max)
		@img.rect(0,0,@img.width,@img.height,:fill=>true,:texture=>Tls["objects/bricks",[32,32]][rand(4)])
		$game.panels << self
	end
	
	def draw
		$screen.draw_quad(@x,@y,0xffff0000,@x+@width,@y,0xff00ff00,@x+@width,@y+@height,0xff0000ff,@x,@y+@height,0xffffff00,4)
		c=0xff808080
		@img.draw(@x+2,@y+2,4) if @img
	end
end

class Obj
	attr_accessor :x,:y,:type,:props,:selected
	def initialize(x,y,type,props,room=$game.room.val)
		@x,@y,@type,@props=x,y,type,props
		return if $game.class != Editor
		case layer
			when 0
			$game.level['rooms'][room]['objects'].each{|o| if o.x==x and o.y==y and o.type==type then $game.level['rooms'][room]['objects'].delete(o) end}
			if type != :spec then $game.level['rooms'][room]['objects'] << self else
				$game.level['rooms'][room]['objects'][0]=self end
			when 1
			$game.level['rooms'][room]['frontlayer'].each{|o| if o.x==x and o.y==y and o.type==type then $game.level['rooms'][room]['frontlayer'].delete(o) end}
			$game.level['rooms'][room]['frontlayer'] << self
			when 2
			$game.level['rooms'][room]['backlayer'].each{|o| if o.x==x and o.y==y and o.type==type then $game.level['rooms'][room]['backlayer'].delete(o) end}
			$game.level['rooms'][room]['backlayer'] << self
		end
	end
	
	def draw(sx,sy)
		return if !@selected and !screen(sx,sy)
		if not @selected or milliseconds % 500>250
			trans=if layer==0 then 0xffffffff elsif layer==1 then 0xd8ffffff else 0xffc0c0c0 end
			case @type
				when :block
				if @props[0]<5 then Tls['tiles/block',[32,32]][@props[0]].draw(@x-sx,@y-sy,1+z,1,1,trans) else Tls['tiles/block',[32,32]][2].draw(@x-sx,@y-sy,1+z,1,1,0x80ffffff) end
				if @props[2]!=false then Tls['editor/check',[16,16]][if @props[2]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,2) end
				when :pipe
				color=Color.new(255-@props[4],@props[1],@props[2],@props[3])
				Tls['tiles/pipes',[32,32]][@props[0]].draw(@x-sx,@y-sy,1+z,1,1,color)
				Tls['tiles/pipes_flashing',[32,32]][@props[0]].draw(@x-sx,@y-sy,1+z)
				if @props[8]!=false then Tls['editor/check',[16,16]][if @props[8]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,2) end
				if @props[5] then Tls['editor/marks',[16,16]][0].draw(@x-sx+8,@y-sy+8,2) end
				if @props[6] then Tls['editor/marks',[16,16]][1].draw(@x-sx+8,@y-sy+8,2) end
				when :grass
				Tls["tiles/grass#{@props[1]+1}",[32,32]][@props[0]].draw(@x-sx,@y-sy,1+z,1,1,trans)
				if @props[3]!=false then Tls['editor/check',[16,16]][if @props[3]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,2) end
				when :ground
				Tls["tiles/ground#{@props[1]+1}",[32,32]][@props[0]].draw(@x-sx,@y-sy,1+z,1,1,trans)
				if @props[3]!=false then Tls['editor/check',[16,16]][if @props[3]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,2) end
				when :climb
				Tls["tiles/climb",[32,32]][@props[0]].draw(@x-sx,@y-sy,1)
				if @props[1]!=false then Tls['editor/check',[16,16]][if @props[1]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,2) end
				when :ice
				Tls["tiles/ice",[32,32]][@props[0]].draw(@x-sx,@y-sy,1+z,1,1,trans)
				if @props[1]!=false then Tls['editor/check',[16,16]][if @props[1]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,2) end
				when :water
				Tls["tiles/water_tiles",[32,32]][@props[0]].draw(@x-sx,@y-sy,0,1,1,0xc0ffffff)
				if @props[1]!=false then Tls['editor/check',[16,16]][if @props[1]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,2) end
				when :sand
				Tls["tiles/sand",[32,32]][@props[0]].draw(@x-sx,@y-sy,1+z,1,1,trans)
				if @props[2]!=false then Tls['editor/check',[16,16]][if @props[2]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,2) end
				when :land
				Tls["tiles/land",[32,32]][@props[0]].draw(@x-sx,@y-sy,1+z,1,1,trans)
				if @props[2]!=false then Tls['editor/check',[16,16]][if @props[2]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,2) end
				when :cloud
				Tls["tiles/clouds",[32,32]][@props[0]].draw(@x-sx,@y-sy,1+z,1,1,trans)
				if @props[2]!=false then Tls['editor/check',[16,16]][if @props[2]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,2) end
				when :factory
				Tls["tiles/factory",[32,32]][@props[0]].draw(@x-sx,@y-sy,1+z,1,1,trans)
				if @props[2]!=false then Tls['editor/check',[16,16]][if @props[2]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,2) end
				when :castle
				Tls["tiles/castle#{@props[2]+1}",[32,32]][@props[0]].draw(@x-sx,@y-sy,1+z,1,1,trans)
				if @props[3]>0 then Tls["tiles/castlecovers",[32,32]][@props[0]+40*(@props[3]-1)].draw(@x-sx,@y-sy,1+z) end
				when :mini
				Tls["tiles/mini",[32,32]][@props[0]].draw(@x-sx,@y-sy,1+z,1,1,trans)
				if @props[2]!=false then Tls['editor/check',[16,16]][if @props[2]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,2) end
				when :lava
				Tls["tiles/lavatiles",[32,32]][if @props[3]==1 then 16+@props[0] else @props[0]*4+($count/8)%4 end].draw(@x-sx,@y-sy,1+z)
				if @props[1]!=false then Tls['editor/check',[16,16]][if @props[1]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,2) end
				when :wall
				Tls["tiles/wall#{@props[2]+1}",[32,32]][@props[0]].draw(@x-sx,@y-sy,1+z,1,1,trans)
				if @props[3]>0 then Tls["tiles/wallcovers",[32,32]][@props[0]+30*(@props[3]-1)].draw(@x-sx,@y-sy,1+z) end
				if @props[4]!=false then Tls['editor/check',[16,16]][if @props[4]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,2) end
				when :bonus
				Tls["tiles/bonus",[32,32]][@props[0]].draw(@x-sx,@y-sy,1+z,1,1,trans)
				if @props[2]!=false then Tls['editor/check',[16,16]][if @props[2]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,2) end
				when :quick
				Tls["tiles/quick",[32,32]][if @props[1]==1 then 16 else 0 end+@props[0]*4+($count/(17-@props[2]))%4].draw(@x-sx,@y-sy,1)
				if @props[3]!=false then Tls['editor/check',[16,16]][if @props[3]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,2) end
				when :pyramid
				Tls["tiles/pyramid",[32,32]][@props[0]].draw(@x-sx,@y-sy,1+z,1,1,trans)
				if @props[2]!=false then Tls['editor/check',[16,16]][if @props[2]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,2) end
				when :scenery
				Tls["tiles/scenery",[32,32]][@props[0]].draw(@x-sx,@y-sy,0.01+z,1,1,trans)
				if @props[2]!=false then Tls['editor/check',[16,16]][if @props[2]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,1) end
				when :animscen
				Tls["tiles/anim_scen",[32,32]][@props[0]*4+($count/12)%4].draw(@x-sx,@y-sy,0.01+z,1,1,trans)
				if @props[2]!=false then Tls['editor/check',[16,16]][if @props[2]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,1) end
				when :wooden
				Tls["tiles/wooden",[32,32]][@props[0]].draw(@x-sx,@y-sy,1+z,1,1,trans)
				if @props[2]!=false then Tls['editor/check',[16,16]][if @props[2]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,12) end
				when :underwater
				Tls["tiles/underwater",[32,32]][@props[0]].draw(@x-sx,@y-sy,1+z,1,1,trans)
				if @props[2]!=false then Tls['editor/check',[16,16]][if @props[2]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,12) end
				when :ghost
				Tls["tiles/ghost",[32,32]][@props[0]].draw(@x-sx,@y-sy,1+z,1,1,trans)
				if @props[2]!=false then Tls['editor/check',[16,16]][if @props[2]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,12) end
				when :spikes
				Tls["tiles/spikes",[32,32]][@props[0]].draw(@x-sx,@y-sy,1+z,1,1,trans)
				if @props[2]!=false then Tls['editor/check',[16,16]][if @props[2]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,12) end
				
				when :bricks
				Tls['objects/bricks',[32,32]][@props[0]].draw(@x-sx,@y-sy,1)
				Tls['bonus/coin',[32,32]][0].draw(@x-sx+8,@y-sy+8,1,0.5,0.5) if @props[1]>0
				when :powerupblock
				Tls['objects/powerupblock',[32,32]][if @props[0]>0 then $count/8%4 else 4 end].draw(@x-sx,@y-sy,1,1,1, if @props[1] then 0x80ffffff else 0xffffffff end)
				Tls['bonus/powerups',[32,32]][@props[0]].draw(@x+8-sx,@y+8-sy,1,0.5,0.5)
				if @props[0]==3
					$screen.draw_line(@x-64-sx,@y+16-sy,c=Color.new((($count*4)%511-255).abs,0,255,0),@x+32+64-sx,@y+16-sy,c,3)
					$screen.draw_line(@x+16-sx,@y-64-sy,c,@x+16-sx,@y+32+64-sy,c,3)
					$screen.draw_line(@x-8-32-sx,@y-8-32-sy,c,@x+40+32-sx,@y+40+32-sy,c,3)
					$screen.draw_line(@x-8-32-sx,@y+40+32-sy,c,@x+40+32-sx,@y-8-32-sy,c,3)
				end
				when :coin
				Tls['bonus/coin',[32,32]][@props[0]*4+$count/8%4].draw(@x-sx,@y-sy,1)
				when :onoff
				color=Color.new([@props[0]*64,255].min,[@props[1]*64,255].min,[@props[2]*64,255].min)
				if @props[4] then color.alpha=128 end
				Tls['objects/changes',[32,32]][@props[3]].draw(@x-sx,@y-sy,1,1,1,color)
				Tls['objects/changes-const',[32,32]][@props[3]].draw(@x-sx,@y-sy,1)
				when :changing
				color=Color.new([@props[0]*64,255].min,[@props[1]*64,255].min,[@props[2]*64,255].min)
				Tls['objects/changes',[32,32]][@props[3]+2].draw(@x-sx,@y-sy,1,1,1,color)
				if @props[3]==0 then Tls['objects/changes-const',[32,32]][2].draw(@x-sx,@y-sy,1) end
				when :qswitch
				Tls['objects/switches',[24,24]][0].draw(@x-sx,@y-sy,1)
				if @props[2] then Img['objects/anchor'].draw(@x+10-sx,@y+17-sy,3) end
				if @props[3] then Tls['editor/marks',[16,16]][2].draw(@x-sx+4,@y-sy+4,2) end
				when :door
				Tls['objects/door',[54,80]][@props[0]].draw(@x-sx,@y-sy,1)
				if @props[1] then Img['objects/lock'].draw(@x+11-sx,@y+40-sy,1,1,1,Color.new([@props[2]*64,255].min,[@props[3]*64,255].min,[@props[4]*64,255].min)) and Img['objects/lock-const'].draw(@x+11-sx,@y+40-sy,1) end
				if @props[5]!=false then Tls['editor/check',[16,16]][if @props[5]==nil then 2 else 1 end].draw(@x-sx+19,@y-sy+32,2) end
				when :key
				Img['objects/key'].draw(@x-sx,@y-sy,1,1,1,Color.new([@props[0]*64,255].min,[@props[1]*64,255].min,[@props[2]*64,255].min)) and Img['objects/key-const'].draw(@x-sx,@y-sy,1)
				when :spring
				Tls['objects/spring',[32,32]][@props[0]*3].draw(@x-sx,@y-sy,1)
				if @props[1] then Img['objects/anchor'].draw(@x+14-sx,@y+25-sy,3) end
				when :pswitch
				Tls['objects/switches',[24,24]][1].draw(@x-sx,@y-sy,1)
				if @props[1] then Img['objects/anchor'].draw(@x+10-sx,@y+17-sy,3) end
				if @props[2] then Tls['editor/marks',[16,16]][2].draw(@x-sx+4,@y-sy+4,2) end
				when :pblock
				Tls['objects/blocks',[32,32]][if cnd=@props[0]<4 then 1+@props[0] else 4 end].draw(@x-sx,@y-sy,1,1,1,if !cnd then 0x80ffffff else 0xffffffff end)
				when :eswitch
				Tls['objects/switches',[24,24]][2].draw(@x-sx,@y-sy,1,1,1,Color.new([@props[1]*64,255].min,[@props[2]*64,255].min,[@props[3]*64,255].min)) and Tls['objects/switches',[24,24]][3].draw(@x-sx,@y-sy,1)
				if @props[4] then Img['objects/anchor'].draw(@x+10-sx,@y+17-sy,3) end
				if @props[5] then Tls['editor/marks',[16,16]][2].draw(@x-sx+4,@y-sy+4,2) end
				when :objectblock
				Tls['objects/powerupblock',[32,32]][$count/8%4].draw(@x-sx,@y-sy,1,1,1, if @props[12] then 0x80ffffff else 0xffffffff end)
				case @props[0]
					when 0
					Tls["tiles/climb",[32,32]][@props[1]].draw(@x-sx+8,@y-sy+8,1,0.5,0.5)
					when 1
					Tls['objects/switches',[24,24]][0].draw(@x-sx+4,@y-sy+4,1)
					when 2
					Tls['objects/switches',[24,24]][1].draw(@x-sx+4,@y-sy+4,1)
					when 3
					Tls['objects/switches',[24,24]][2].draw(@x-sx+4,@y-sy+4,1,1,1,Color.new([@props[6]*64,255].min,[@props[7]*64,255].min,[@props[8]*64,255].min)) and Tls['objects/switches',[24,24]][3].draw(@x-sx+4,@y-sy+4,1)
					when 4
					Img['objects/key'].draw(@x-sx+8,@y-sy+8,1,0.5,0.5,Color.new([@props[6]*64,255].min,[@props[7]*64,255].min,[@props[8]*64,255].min)) and Img['objects/key-const'].draw(@x-sx+8,@y-sy+8,1,0.5,0.5)
					when 5
					Tls['objects/spring',[32,32]][@props[5]*3].draw(@x-sx+8,@y-sy+8,1,0.5,0.5)
				end
				when :saveflag
				Tls['objects/saveflag',[32,64]][$count/8%4].draw(@x-sx,@y-sy,1)
				when :text
				Tls['objects/blocks',[32,32]][0].draw(@x-sx,@y-sy,1)
				when :flip
				Tls['objects/flipblock',[32,32]][0].draw(@x-sx,@y-sy,1)
				when :skull
				Tls['objects/blocks',[32,32]][5].draw(@x-sx,@y-sy,1,1,1,if @props[1] then 0xffffffff else 0x80ffffff end)
				when :shell
				Tls['enemies/shell',[32,32]][@props[0]*5].draw(@x-sx,@y-sy,1)
				when :passtype
				Tls['objects/passwordblock',[32,32]][4].draw(@x-sx,@y-sy,1)
				Fnt['fonts/nine.ttf',8].draw_rel("#{@props[0]}/#{@props[1]}",@x-sx+16,@y-sy+12,1,0.5,0,1,1,0xffff0000)
				when :passcheck
				Tls['objects/passwordblock',[32,32]][$count/8%4].draw(@x-sx,@y-sy,1)
				Fnt['fonts/nine.ttf',8].draw_rel(@props[0],@x-sx+16,@y-sy+12,1,0.5,0,1,1,0xffff0000)
				when :trigswitcher
				Tls['objects/changes',[32,32]][if @props[2] then 0 else 1 end].draw(@x-sx,@y-sy,1,1,1,Color.new(if @props[3] then 128 else 255 end,if @props[2] then 0 else 255 end,if @props[2] then 255 else 0 end,0))
				Tls['objects/changes-const',[32,32]][if @props[2] then 0 else 1 end].draw(@x-sx,@y-sy,1)
				when :light
				if @props[0]==0 then Img['editor/light'] else Tls['objects/blocks',[32,32]][6] end.draw(@x-sx,@y-sy,1)
				$screen.draw_line(@x-@props[1]*32-sx,@y+16-sy,c=Color.new((($count*4)%511-255).abs,0,255,0),@x+32+@props[1]*32-sx,@y+16-sy,c,3)
				$screen.draw_line(@x+16-sx,@y-@props[1]*32-sy,c,@x+16-sx,@y+32+@props[1]*32-sy,c,3)
				$screen.draw_line(@x-8-@props[1]*16-sx,@y-8-@props[1]*16-sy,c,@x+40+@props[1]*16-sx,@y+40+@props[1]*16-sy,c,3)
				$screen.draw_line(@x-8-@props[1]*16-sx,@y+40+@props[1]*16-sy,c,@x+40+@props[1]*16-sx,@y-8-@props[1]*16-sy,c,3)
				if @props[2]!=false then Tls['editor/check',[16,16]][if @props[2]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,12) end
				when :brosblock
				Tls['objects/blocks',[32,32]][7].draw(@x-sx,@y-sy,1)
				
				when :goomba
				Tls['enemies/goomba',[32,32]][@props[0]*3+($count/8)%2].draw(@x-sx,@y-sy,1)
				when :koopatroopa
				Tls['enemies/koopa troopa',[32,48]][0+if @props[0] then 4 else 0 end+if @props[2] != 0 then 2 else 0 end+($count/8)%2].draw(@x-sx+if @props[1]==1 then 32 else 0 end,@y-sy,1,if @props[1]==1 then -1 else 1 end)
				when :piranhaplant
				piranha(sx,sy)
				when :spiny
				Tls['enemies/spiny',[32,32]][if @props[0] then 3 else 0 end+($count/8)%2].draw(@x-sx+if @props[1]==1 then 32 else 0 end,@y-sy,1,if @props[1]==1 then -1 else 1 end)
				when :buzzybeetle
				Tls['enemies/buzzy beetle',[32,32]][($count/8)%2].draw(@x-sx+if @props[1]==1 then 32 else 0 end,@y-sy+if @props[0] then 32 else 0 end,1,if @props[1]==1 then -1 else 1 end,if @props[0] then -1 else 1 end)
				when :bowser
				Tls['enemies/bowser',[64,70]][0].draw(@x-sx,@y-sy,1)
				when :bullet_bill
				Tls['enemies/blaster',[32,32]][0].draw(@x-sx,@y-sy,1)
				if @props[2]>0
					Tls['enemies/blaster',[32,32]][1].draw(@x-sx,@y-sy+32,1)
				end
				if @props[2]>1
					i=1
					(@props[2]-1).times{i+=1 and Tls['enemies/blaster',[32,32]][2].draw(@x-sx,@y-sy+i*32,1)}
				end
				when :rotor
				if @props[4]==0 then Tls['enemies/rotodisc',[32,32]][($count/8)%21].draw(@x-sx,@y-sy,1) else Img['projectiles/fireball'].draw_rot(@x+16-sx,@y-sy+16,1,($count*8)%360) end
				$screen.draw_line(@x+16-sx,@y+16-sy,0xffff0000,@x+16-sx+offset_x(($count*@props[1])%360*if @props[2]==1 then -1 else 1 end,@props[0]*16),@y-sy+16+offset_y(($count*@props[1])%360*if @props[2]==1 then -1 else 1 end,@props[0]*16),0xffff0000,1)
				when :podobo
				Tls['enemies/podobo',[28,32]][($count/8)%3].draw(@x-sx,@y-sy,1)
				when :proj
				right=(@props[2]==1)
				w=[68,32][@props[0]]
				h=[30,28][@props[0]]
				f=[5,3][@props[0]]
				if @props[0] != 2 then Tls["enemies/#{["fire","bullet bill"][@props[0]]}",[w,h]][($count/8)%f] else Img['enemies/banzai bill'] end.draw(@x-sx+if right then w else 0 end,@y-sy,1,if right then -1 else 1 end)
				when :cheepcheep
				Tls['enemies/cheep cheep',[32,32]][@props[0]*2+($count/8)%2].draw(@x-sx+if @props[2]==1 then 32 else 0 end,@y-sy,1,if @props[2]==1 then -1 else 1 end)
				when :pokey
				Tls['enemies/pokey',[48,48]][@props[0]].draw(@x-sx,@y-sy,1)
				i=0
				@props[2].times{i+=1 and Tls['enemies/pokey',[48,48]][2+@props[0]].draw(@x-sx,@y-sy+i*48,1)}
				when :boo
				wd=[32,32,32,144,65][@props[0]]
				if (pr=@props[0])<3 then Tls['enemies/boo',[32,32]][pr*2] elsif pr==3 then Tls['enemies/bigboo',[144,128]][0] else Img['enemies/balloonboo'] end.draw(@x-sx+if (d=(@props[1]==0)) then wd else 0 end,@y-sy,1,if d then -1 else 1 end)
				when :hammbro
				Tls['enemies/hammerbros',[32,68]][2+@props[0]].draw(@x-sx,@y-sy,1)
				
				when :warp
				Tls['editor/warp',[16,16]][@props[0]].draw(@x-sx,@y-sy,2)
				Fnt['fonts/NINE.ttf',14].draw_rel(@props[1],@x+8-sx,@y-sy+1,2,0.5,0,1,1,if @props[2] then 0xffff0000 elsif @props[2]==false then 0xffff00ff else 0xff0000ff end)
				when :platform
				Img['editor/platform'].draw(@x-sx,@y-sy,2)
				if @props[1]!=false then Tls['editor/check',[16,16]][if @props[1]==nil then 2 else 1 end].draw(@x-sx+8,@y-sy+8,2) end
				if @props[0] then Tls['editor/marks',[16,16]][3].draw(@x-sx+8,@y-sy,2) end
				when :trigger
				Tls['editor/triggers',[16,16]][0].draw(@x-sx,@y-sy,3)
				$screen.draw_quad(@x+8-sx,@y+8-sy,c=0x800000ff,@x+8+@props[1]*8-sx,@y+8-sy,c,@x+8+@props[1]*8-sx,@y+8+@props[2]*8-sy,c,@x+8-sx,@y+8+@props[2]*8-sy,c,3)
				when :rampage,:spawn,:boss,:liqctrl,:sizectrl
				Tls['editor/triggers',[16,16]][[nil,:rampage,:spawn,:boss,:liqctrl,:sizectrl].index(@type)].draw(@x-sx,@y-sy,3)
			end
		end
	end
	
	def select(mx,my,new=true)
		if @selected then unselect end
		width,height=size
		if @type != :piranhaplant
			if mx>@x and mx<@x+width and my>@y and my<@y+height
				@selected=true
			end
		else
			if @props[1]==0 || @props[1]==2 and mx>@x and mx<@x+width and my>@y and my<@y+height or @props[1]==1 && mx>@x && mx<@x+32 && my>@y-@props[2]*16 && my<@y+32 or @props[1]==3 && mx>@x-@props[2]*16 && mx<@x+32 && my>@y && my<@y+32
				@selected=true
			end
		end
		$game.selects+=1 if @selected
		if @selected and new
			$game.clearset
			$game.probject=self
			$game.props(@type)
		elsif @selected
			return true
		end
	end
	
	def unselect
		$game.selects-=1 if @selected
		@selected=false
	end
	
	def delete
		return if [:spec,:level].include?(@type)
		$game.selects-=1 if @selected
		if @selected
			case layer
				when 0
				$game.level['rooms'][$game.room.val]['objects'].delete(self)
				when 1
				$game.level['rooms'][$game.room.val]['frontlayer'].delete(self)
				when 2
				$game.level['rooms'][$game.room.val]['backlayer'].delete(self)
			end
		end
		@selected
	end
	
	def z
		case layer
			when 0
			0
			when 1
			1
			when 2
			-1
		end
	end
	
	def layer
		if @props[0]!=nil or [:saveflag,:brosblock].include?(@type)
			if [:block,:sand,:land,:cloud,:factory,:mini,:castle,:wall,:bonus,:pyramid,:scenery,:animscen,:wooden,:underwater,:ghost].include?(@type)
				@props[1]
			elsif @type==:pipe
				@props[7]
			elsif [:ground,:grass].include?(@type)
				@props[2]
			elsif @type==:ice
				@props[3]
			elsif [:water,:lava].include?(@type)
				2
			else
				0
			end
		else
			nil
		end
	end

	def piranha(sx,sy)
		case @props[1]
			when 0
			Tls['enemies/piranha plant head',[32,32]][if @props[0]<2 then 0 else (@props[0]-1)*8 end+($count/8)%2].draw(@x-sx,@y-sy,1)
			i=0
			@props[2].times{Tls['enemies/piranha plant rest',[32,16]][if @props[0]<3 then 0 else 4 end].draw(@x-sx,@y+32+i*16-sy,1)
			i+=1}
			when 1
			Tls['enemies/piranha plant head',[32,32]][if @props[0]<2 then 4 else 4+(@props[0]-1)*8 end+($count/8)%2].draw(@x-sx,@y-sy,1)
			i=0
			@props[2].times{Tls['enemies/piranha plant rest',[32,16]][if @props[0]<3 then 2 else 6 end].draw(@x-sx,@y-16-i*16-sy,1)
			i+=1}
			when 2
			Tls['enemies/piranha plant head',[32,32]][if @props[0]<2 then 6 else 6+(@props[0]-1)*8 end+($count/8)%2].draw(@x-sx,@y-sy,1)
			i=0
			@props[2].times{Tls['enemies/piranha plant rest',[16,32]][if @props[0]<3 then 3 else 7 end].draw(@x+32+i*16-sx,@y-sy,1)
			i+=1}
			when 3
			Tls['enemies/piranha plant head',[32,32]][if @props[0]<2 then 2 else 2+(@props[0]-1)*8 end+($count/8)%2].draw(@x-sx,@y-sy,1)
			i=0
			@props[2].times{Tls['enemies/piranha plant rest',[16,32]][if @props[0]<3 then 2 else 6 end].draw(@x-16-i*16-sx,@y-sy,1)
			i+=1}
		end
	end

	def size
		width=height=32
		case @type
			when :warp,:spec,:level,:trigger,:rampage,:spawn,:boss,:liqctrl,:sizectrl
			width=height=16
			when :qswitch,:pswitch,:eswitch
			width=height=24
			when :koopatroopa
			width=32
			height=48
			when :door
			width=54
			height=80
			when :bullet_bill
			width=32
			height=32+@props[2]*32
			when :piranhaplant
			if @props[1]==0 or @props[1]==1
				width=32
				height=32+@props[2]*16
			else
				width=32+@props[2]*16
				height=32
			end
			when :platform
			width=32
			height=16
			when :bowser
			width=64
			height=70
			when :proj
			width=[68,32,128][@props[0]]
			height=[30,28,128][@props[0]]
			when :pokey
			width=48
			height=48+@props[2]*48
			when :hammbro
			width=32
			height=68
		end
		[width,height]
	end

	def screen(sx,sy)
		@x+size[0]>sx+128 and @x<sx+640 and @y+size[1]>sy and @y<sy+480
	end
end