class Map
	attr_accessor :tiles, :warps, :specjals, :rooms, :sound, :lights
	def initialize(rooms)
    $game.map=self
		@rooms=rooms
		@tiles=[]
		@lights=[]
		@warps=[]
		@specjals=[]
		@mask=[]
		r=0
		@rooms.length.times{@mask<<{}}
		
		@room=$game.level['start'][2]
		rooms.length.times{@tiles << [] ; @lights << []}
		
		@rooms.each{|r|
		r['backlayer'].each{|o| place(o,@rooms.index(r))}
		r['frontlayer'].each{|o| place(o,@rooms.index(r))}
		r['objects'].each{|o| place(o,@rooms.index(r))}}
    
    @scene=Ashton::WindowBuffer.new
    @cover=Ashton::WindowBuffer.new
    @shadow=Ashton::Shader.new(vertex: :multitexture2, fragment: :stencil)
	end
	
	def place(o,r)
		pr=o.props
		case o.type
			when :block
			Tile.new(o.x,o.y,Tls["tiles/block",[32,32]][pr[0]],pr[1],nil,[pr[2],pr[3]],self,r)
			when :pipe
			Pipe.new(o.x,o.y,[Tls["tiles/pipes",[32,32]][pr[0]],Tls["tiles/pipes_flashing",[32,32]][pr[0]]],[255-pr[4],pr[1],pr[2],pr[3]],pr[5],pr[6],pr[7],[pr[8],pr[9]],Tls["tiles/pipes_mask",[32,32]][pr[0]],self,r)
			when :grass
			Tile.new(o.x,o.y,Tls["tiles/grass#{pr[1]+1}",[32,32]][pr[0]],pr[2],Tls["tiles/grassmask",[32,32]][pr[0]],[pr[3],pr[4]],self,r)
			when :ground
			Tile.new(o.x,o.y,Tls["tiles/ground#{pr[1]+1}",[32,32]][pr[0]],pr[2],Tls["tiles/groundmask",[32,32]][pr[0]],[pr[3],pr[4]],self,r)
			when :climb
			Climb.new(o.x,o.y,Tls["tiles/climb",[32,32]][pr[0]],[pr[1],pr[2]],r)
			when :ice
			Tile.new(o.x,o.y,Tls["tiles/ice",[32,32]][pr[0]],pr[3],Tls["tiles/icemask",[32,32]][pr[0]],[pr[1],pr[2]],self,r)
			when :water
			Water.new(o.x,o.y,Tls["tiles/water_tiles",[32,32]][pr[0]],[pr[1],pr[2]],r)
			when :sand
			Tile.new(o.x,o.y,Tls["tiles/sand",[32,32]][pr[0]],pr[1],Tls["tiles/sandmask",[32,32]][pr[0]],[pr[2],pr[3]],self,r)
			when :land
			Tile.new(o.x,o.y,Tls["tiles/land",[32,32]][pr[0]],pr[1],Tls["tiles/landmask",[32,32]][pr[0]],[pr[2],pr[3]],self,r)
			when :cloud
			Tile.new(o.x,o.y,Tls["tiles/clouds",[32,32]][pr[0]],pr[1],nil,[pr[2],pr[3]],self,r)
			when :factory
			Tile.new(o.x,o.y,Tls["tiles/factory",[32,32]][pr[0]],pr[1],Tls["tiles/factorymask",[32,32]][pr[0]],[pr[2],pr[3]],self,r)
			when :castle
			Tile.new(o.x,o.y,Tls["tiles/castle#{pr[2]+1}",[32,32]][pr[0]],pr[1],Tls["tiles/mask",[32,32]][0],[false],self,r,if pr[3]>0 then Tls["tiles/castlecovers",[32,32]][pr[0]+40*(pr[3]-1)] end,true)
			when :mini
			Tile.new(o.x,o.y,Tls["tiles/mini",[32,32]][pr[0]],pr[1],Tls["tiles/minimask",[32,32]][pr[0]],[pr[2],pr[3]],self,r)
			when :lava
			Water.new(o.x,o.y,[pr[0],pr[3]==1],[pr[1],pr[2]],r,false)
			when :wall
			Tile.new(o.x,o.y,Tls["tiles/wall#{pr[2]+1}",[32,32]][pr[0]],pr[1],Tls["tiles/wallmask",[32,32]][pr[0]],[pr[4],pr[5]],self,r,if pr[3]>0 then Tls["tiles/wallcovers",[32,32]][pr[0]+30*(pr[3]-1)] end)
			when :bonus
			Tile.new(o.x,o.y,Tls["tiles/bonus",[32,32]][pr[0]],pr[1],Tls["tiles/bonusmask",[32,32]][pr[0]],[pr[2],pr[3]],self,r)
			when :quick
			Quick.new(o.x,o.y,pr[0],pr[1],pr[2],[pr[3],pr[4]],self,r)
			when :pyramid
			Tile.new(o.x,o.y,Tls["tiles/pyramid",[32,32]][pr[0]],pr[1],Tls["tiles/pyramidmask",[32,32]][pr[0]],[pr[2],pr[3]],self,r)
			when :scenery
			Tile.new(o.x,o.y,Tls["tiles/scenery",[32,32]][pr[0]],pr[1],Tls["tiles/mask",[32,32]][0],[pr[2],pr[3]],self,r,nil,true)
			when :animscen
			Tile.new(o.x,o.y,Tls["tiles/anim_scen",[32,32]][((pr[0]*4)...(pr[0]*4+4))],pr[1],Tls["tiles/mask",[32,32]][0],[pr[2],pr[3]],self,r,nil,true)
			when :wooden
			Tile.new(o.x,o.y,Tls["tiles/wooden",[32,32]][pr[0]],pr[1],Tls["tiles/woodenmask",[32,32]][pr[0]],[pr[2],pr[3]],self,r)
			when :underwater
			Tile.new(o.x,o.y,Tls["tiles/underwater",[32,32]][pr[0]],pr[1],Tls["tiles/underwatermask",[32,32]][pr[0]],[pr[2],pr[3]],self,r)
			when :ghost
			Tile.new(o.x,o.y,Tls["tiles/ghost",[32,32]][pr[0]],pr[1],Tls["tiles/ghostmask",[32,32]][pr[0]],[pr[2],pr[3]],self,r)
			when :spikes
			Tile.new(o.x,o.y,Tls["tiles/spikes",[32,32]][pr[0]],pr[1],Tls["tiles/spikemask",[32,32]][pr[0]],[pr[2],pr[3]],self,r)
			
			when :bricks
			Bricks.new(o.x,o.y,pr[0],pr[1],r)
			when :powerupblock
			PowerUp_Block.new(o.x,o.y,pr[0]-1,pr[1],r)
			when :coin
			Coin.new(o.x,o.y,pr[0],false,r)
			when :onoff
			OnOff.new(o.x,o.y,Color.new([pr[0]*64,255].min,[pr[1]*64,255].min,[pr[2]*64,255].min),pr[3],pr[4],r)
			when :changing
			Changing.new(o.x,o.y,Color.new([pr[0]*64,255].min,[pr[1]*64,255].min,[pr[2]*64,255].min),pr[3],r)
			when :qswitch
			Qswitch.new(o.x,o.y,pr[0],pr[1],pr[2],pr[3],pr[4],[pr[5],pr[6]],r)
			when :door
			Door.new(o.x,o.y,pr[0],pr[1],Color.new([pr[2]*64,255].min,[pr[3]*64,255].min,[pr[4]*64,255].min),[pr[5],pr[6]],r)
			when :key
			Key.new(o.x,o.y,Color.new([pr[0]*64,255].min,[pr[1]*64,255].min,[pr[2]*64,255].min),[pr[3],pr[4]],r)
			when :spring
			Spring.new(o.x,o.y,pr[0],pr[1],r)
			when :pswitch
			Pswitch.new(o.x,o.y,pr[0],pr[1],pr[2],r)
			when :pblock
			PBlock.new(o.x,o.y,pr[0],r)
			when :eswitch
			Eswitch.new(o.x,o.y,pr[0],pr[4],pr[5],Color.new([pr[1]*64,255].min,[pr[2]*64,255].min,[pr[3]*64,255].min),r)
			when :objectblock
			ObjectBlock.new(o.x,o.y,pr[0],case pr[0]
				when 0
				[pr[1],pr[13],pr[14]]
				when 1
				[pr[2],pr[9],pr[10],pr[11],pr[15],pr[16],pr[17]]
				when 2
				[pr[9],pr[10],pr[11]]
				when 3
				[pr[9],pr[10],pr[11],Color.new([pr[6]*64,255].min,[pr[7]*64,255].min,[pr[8]*64,255].min)]
				when 4
				[[pr[3],pr[4]],Color.new([pr[6]*64,255].min,[pr[7]*64,255].min,[pr[8]*64,255].min)]
				when 5
				[pr[5],pr[10]]
			end,pr[12],r)
			when :saveflag
			SaveFlag.new(o.x,o.y,r)
			when :text
			TextBlock.new(o.x,o.y,pr[0],r)
			when :flip
			FlipBlock.new(o.x,o.y,pr[0],r)
			when :skull
			SkullBlock.new(o.x,o.y,pr[0],pr[1],r)
			when :shell
			Shell.new(o.x,o.y,pr[0],r,nil,:right)
			when :passtype
			PassType.new(o.x,o.y,pr[0],pr[1],pr[2].split(//),r)
			when :passcheck
			PassCheck.new(o.x,o.y,pr[0],pr[1],r)
			when :trigswitcher
			TriggerSwitcher.new(o.x,o.y,pr[0],pr[1],pr[2],pr[3],r)
			when :light
			if pr[0]==0 then Light.new(o.x,o.y,pr[1],[pr[2],pr[3]],self,r) else GlowBlock.new(o.x,o.y,pr[1],self,r) end
			when :brosblock
			BrosBlock.new(o.x,o.y,r)
			
			when :goomba
			Goomba.new(o.x,o.y,pr[0],pr[1],r)
			when :koopatroopa
			KoopaTroopa.new(o.x,o.y,pr[0],pr[1],[pr[2],pr[3]],pr[4],r)
			when :piranhaplant
			PiranhaPlant.new(o.x,o.y,pr[0],pr[1],pr[2],pr[3],pr[4],pr[5],pr[6],r)
			when :spiny
			Spiny.new(o.x,o.y,pr[1],pr[0],false,r)
			when :buzzybeetle
			BuzzyBeetle.new(o.x,o.y,pr[1],pr[0],r)
			when :bowser
			Bowser.new(o.x,o.y,pr[0],pr[1],pr[2],[pr[3],pr[4],pr[5],pr[6],pr[7],pr[8],pr[9],pr[10]],r)
			when :bullet_bill
			Blaster.new(o.x,o.y,pr[0],pr[1],pr[2],pr[3],pr[4],pr[5],pr[6],pr[7],r)
			when :rotor
			RotoBase.new(o.x,o.y,pr[4],pr[0],pr[1],pr[2],pr[3],r)
			when :podobo
			Podobo.new(o.x,o.y,pr[0],r)
			when :proj
			if pr[0]==0 then Fire.new(o.x,o.y,[:left,:right][pr[2]],pr[1],r,false) else Bullet_Bill.new(o.x,o.y,pr[2],false,pr[1],r,pr[0]==2) end
			when :cheepcheep
			CheepCheep.new(o.x,o.y,pr[0],pr[1],pr[2],r)
			when :pokey
			Pokey.new(o.x,o.y,pr[0],pr[1],pr[2],pr[3],r)
			when :boo
			Boo.new(o.x,o.y,pr[0],pr[1],pr[2],pr[3],pr[4],r)
			when :hammbro
			HammerBros.new(o.x,o.y,pr[0],pr[1],r)
			
			when :warp
			Warp.new(o.x,o.y,pr[0],pr[1],pr[2],pr[3],self,[pr[4],pr[5]],r)
			when :spec
			SpecjalSet.new(pr,self,r)
			when :platform
			Platform.new(o.x,o.y,pr[0],[pr[1],pr[2]],r)
			when :trigger
			Trigger.new(o.x,o.y,pr[0],pr[1],pr[2],pr[3],r)
			when :rampage
			RampageControl.new(pr[0],pr[1],r)
			when :spawn
			EnemySpawner.new(o.x,o.y,pr[0],pr[1],pr[2],pr[5],r)
			when :boss
			BossControl.new(pr[0],pr[1],pr[2],pr[3],pr[4],r)
			when :liqctrl
			LiquidControl.new(pr[0],pr[1],pr[2],pr[3],pr[4],pr[5],pr[6],r)
			when :sizectrl
			SizeControl.new(pr[0],pr[1],pr[2],pr[3],pr[4],r)
		end
	end
	
	def update
		if ![Msc[music],Msc['Switch1.ogg'],Msc['Switch2.ogg'],Msc['Rampage1.ogg'],Msc['Rampage2.ogg'],Msc['Boss1.ogg'],Msc['Boss2.ogg'],Msc['Boss3.ogg'],Msc['Fail.ogg'],Msc['Game Over.ogg'],Msc['Invincible.ogg'],Msc['TimeWarning.ogg'],Msc['StageClear.ogg']].find{|m| m.playing?} and !$game.player.end then Msc[music].play(true) end
	end
	
	def draw(sx,sy)
		room=$game.room
		if @rooms[room]['background'] then Img["backgrounds/#{@rooms[room]['background']}"].draw(0,0,-100) end
		@tiles[room].each{|t| t.draw(sx,sy)}
		
		if (spec=@specjals[room]).liquid==:water
			water=sx/32
			21.times{Tls['tiles/water',[32,32]][spec.water*4+(($count/8)%4)].draw(water*32-sx,(@rooms[room]['height']-spec.liqlevel)*32-sy,4,1,1,0xc0ffffff)
			water+=1}
			c=Img['tiles/water'].get_pixel(16,24+32*spec.water)
			c=Color.new(192,(c[0]*255).to_i,(c[1]*255).to_i,(c[2]*255).to_i)
			$screen.draw_quad(0,(@rooms[room]['height']-spec.liqlevel+1)*32-sy,c,640,(@rooms[room]['height']-spec.liqlevel+1)*32-sy,c,640,480,c,0,480,c,4)
		else
			lava=sx/32
			21.times{Tls['tiles/lava',[32,32]][spec.lava*4+(($count/8)%4)].draw(lava*32-sx,(@rooms[room]['height']-spec.liqlevel)*32-sy,1,1,1,0xffffffff)
			lava+=1}
			c=Img['tiles/lava'].get_pixel(16,31+32*spec.lava)
			c=Color.new(255,(c[0]*255).to_i,(c[1]*255).to_i,(c[2]*255).to_i)
			$screen.draw_quad(0,(@rooms[room]['height']-spec.liqlevel+1)*32-sy,c,640,(@rooms[room]['height']-spec.liqlevel+1)*32-sy,c,640,480,c,0,480,c,1)
		end
		
		if @room != $game.room then @room=$game.room
		@sound.stop if @sound
		@sound=nil end
		case @rooms[$game.room]['weather']
			when 1
			Fall.new(rand(640),0,Img['effects/rain'],190,10)
			@sound=Snd['rain1'].play(1,1,true) if not @sound
			when 2
			10.times {Fall.new(rand(960),0,Img['effects/rain+'],195+rand(11),15)}
			@sound=Snd['rain2'].play(1,1,true) if not @sound
			when 3
			2.times {Fall.new(rand(960),0,Tls['effects/snow',[8,8]][rand(3)],190+rand(16),5)}
			when 4
			5.times {Fall.new(rand(960),0,Tls['effects/snow+',[16,16]][rand(3)],210+rand(41),8)}
			when 5
			if $count%360==0 then Snd['thunder'].play and $game.flash(0xffffffff,4) end
			when 6
			8.times {Fall.new(rand(960),0,Img['effects/rain+'],195+rand(11),15)}
			@sound=Snd['rain1'].play(1,1,true) if not @sound
			if $count%360==0 then Snd['thunder'].play and $game.flash(0xffffffff,4) and Thunder.new(rand(640),1+rand(11)*0.1) end
			when 7
			5.times {Fall.new(640,-120+rand(640),Tls['effects/sandM',[16,16]][rand(2)],260+rand(21),11)}
			15.times {Fall.new(640,-120+rand(640),Tls['effects/sandS',[2,2]][rand(2)],260+rand(21),11)}
			when 8
			5.times {Fall.new(640,-120+rand(640),Tls['effects/sandL',[32,32]][rand(2)],260+rand(21),11)}
			15.times {Fall.new(640,-120+rand(640),Tls['effects/sandM',[16,16]][rand(2)],260+rand(21),11)}
			when 9
			if not @rooms[$game.room]['fog']
				@rooms[$game.room]['fog']=true
				(12+rand(13)).times{Fog.new(rand(640),rand(480),0.5+rand(4),Tls['effects/fog',[64,32]][rand(4)])}
			end
			when 10
			Img['effects/fog+'].draw(0,0,5)
			when 11
			Img['effects/underwater'].draw(-5+(($count/8)%11-5).abs,-5+(($count/8)%11-5).abs,5)
		end
	
		if @rooms[room]['dark'] and !$game.flashing
      @cover.clear
      @scene.clear
      
      @cover.render {$screen.draw_quad(0,0,c=0xff000000,640,0,c,640,480,c,0,480,c,1)}
      @scene.render{#$screen.draw_quad(0,0,c=0xff000000,640,0,c,640,480,c,0,480,c,0)
      @lights[room].each{|l| l.glow(sx,sy)} }
			#if (spec=@specjals[room]).liquid==:lava and ![3,4].include?(spec.lava) and sy+480>height-spec.liqlevel*32 then darkness.rect(0,height-(spec.liqlevel+4)*32-sy,640,480,:color=>[0,0,0,0], :fill => true) end
      @cover.draw(0,0, 5, shader: @shadow, multitexture: @scene)
		end
	end
	
	def solid?(x,y,down=false,room=@room)
		plat=nil
		max=x.to_i/640
		may=y.to_i/480
		if down then $game.entities[room][9].each{|p| if p.test(x,y)
			plat=p
			break end} end
		if plat
			return plat else
			if @mask[room][[max,may]] and x>=minx(room) and x<=width(room) and y>=miny(room) and y<=height(room)+32
				color=@mask[room][[max,may]][x%640,480-y%480]
				[Color::BLACK,Color::YELLOW,Color::FUCHSIA,Color::BLUE].include?(color)
			elsif !$game.player.end
				x<minx(room) or x>width(room) or (sp=@specjals[room]).upsolid && y<miny(room) && solid?(x,miny(room)+1)
			end
		end
	end
	
	def ice?(x,y,room=@room)
		max=x.to_i/640
		may=y.to_i/480
		if @mask[room][[max,may]] and x>=minx(room) and x<=width(room) and y>=miny(room) and y<=height(room)+32
			@mask[room][[max,may]][x%640,480-y%480]==Color::BLUE
		else
			nil
		end
	end
	
	def slope?(x,y,room=@room)
		max=x.to_i/640
		may=y.to_i/480
		if @mask[room][[max,may]] and x>=minx(room) and x<=width(room) and y>=miny(room) and y<=height(room)+32
			color=@mask[room][[max,may]][x%640,480-y%480]
			[color.red + color.green + color.blue == 510,color.blue/255.0]
		else
			[]
		end
	end
	
	def water?(x,y,room=@room)
		(@rooms[room]['weather']==11 or (sp=@specjals[$game.room]).liquid==:water && sp.liqlevel>0 && (height(room)/32-sp.liqlevel)*32+16<=y or y>height(room) && water?(x,height(room)-1) or $game.entities[$game.room][4].find{|e| e.swimable and e.x+32>=x and e.x<=x and e.y+32>=y and e.y<=y})
	end
	
	def lava?(x,y,room=@room)
		(sp=@specjals[room]).liquid==:lava && sp.liqlevel>0 && (height(room)/32-sp.liqlevel)*32+16<=y or $game.entities[$game.room][0].find{|e| e.swimable and e.x+32>=x and e.x<=x and e.y+32>=y and e.y+8<=y}
	end

	def harmful?(x,y,room=@room)
		max=x.to_i/640
		may=y.to_i/480
		if @mask[room][[max,may]] and x>=minx(room) and x<=width(room) and y>=miny(room) and y<=height(room)+32
			[Color::RED].include?(@mask[room][[max,may]][x%640,480-y%480])
		else
			nil
		end
	end
	
	def music
		['Overworld.ogg','Underground1.ogg','Underground2.ogg','Underwater1.ogg','Underwater2.ogg','Castle.ogg','Ghost House.ogg','Desert.ogg','Snow.ogg','Beach.ogg','Sky.ogg','Darkland.ogg','Starland.ogg','Factory.ogg','Space.ogg','Bonus.ogg','Athletic.ogg','Challenge.ogg','Tanks.ogg','Fastrun.ogg'][@rooms[$game.room]['music']]
	end

	def width(room=$game.room)
		@rooms[room]['width']*32
	end

	def height(room=$game.room)
		@rooms[room]['height']*32
	end

	def grav(room=$game.room)
		if @specjals[room]
			@specjals[room].gravity.to_f/10
		else
			1
		end
	end

	def world(id)
		[18,22,23,22][id]
	end

	def minx(room=$game.room)
		@specjals[room].width*32
	end

	def miny(room=$game.room)
		@specjals[room].height*32
	end

	def mask(room,id)
    id=[id[0].to_i,id[1].to_i]
    @mask[room][id]||=Ashton::WindowBuffer.new
    @mask[room][id]
	end
  
  def modify_mask(room,id,method,*value)
    x,y=value[1],value[2]
    mask(room,id).render{case method
      when :splice
      # img=(value.class==String ? Img[value] : Tls[value[0],value[1],value[2]][value[3]])
      img=value[0]
      img.draw(x%640,y%480,0)
      when :rect
      # $screen.draw_quad(x%640,y%480,value[2],x%640+value[0],y%480,value[2],x%640+value[0],y%480+value[1],value[2],x%640,y%480+value[1],value[2],value[3] ? value[3] : 0)
      $screen.draw_quad(x%640,y%480,value[2],x%512+value[0],y%512,value[2],x%512+value[0],y%512+value[1],value[2],x512640,y%512+value[1],value[2],0)
      # $screen.draw_quad(x%640,y%480,value[2],(x+value[0])%640,y%480,value[2],(x+value[0])%640,(y+value[1])%480,value[2],x%640,(y+value[1])%480,value[2],0)
    end}
  end
end

class Tile
	def initialize(x,y,img,layer,mask,qswitch,map,room,cover=nil,lower=nil)
		@x,@y,@img,@layer,@mask,@cover,@lower=x,y,img,layer,mask,cover,lower
		if layer==0 and qswitch[0]!=true then @solid=true else @solid=false end
		if qswitch[0] != false then @qswitchid=qswitch[1] and @qswitchtype=qswitch[0] else @qswitchtype=false end
		map.tiles[room] << self
		
		if @solid and !lower
			map.modify_mask(room,[@x/640,@y/480],:splice,if @mask then @mask else Tls['tiles/mask',[32,32]][1] end,@x%640,@y%480)
			@set=true
		end
	end
	
	def draw(sx,sy)
		if @solid and !@set
			$game.map.modify_mask($game.room,[@x/640,@y/480],:splice,if @mask then @mask else Tls['tiles/mask',[32,32]][1] end,@x%640,@y%480) if !@lower
			@set=true
		elsif !@solid and @set
			$game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][0],@x%640,@y%480) if !@lower
			@set=nil
		end
		return if not @x+32>sx && @x<sx+640 && @y+32>sy && @y<sy+480
			
		if @qswitchtype != false and $game.qswitches[@qswitchid]
			if @qswitchtype==true then @solid = @layer!=2 end
			if @qswitchtype==nil then @solid = false end
		elsif @qswitchtype != false
			if @qswitchtype==true then @solid = false end
			if @qswitchtype==nil then @solid = @layer!=2 end
		end
		if @img.class==Image then @img else @img[($count/12)%4] end.draw(@x-sx,@y-sy,3+z,1,1,if @layer==2 then 0xffc0c0c0 else 0xffffffff end) if cnd=(not @qswitchtype == true && !$game.qswitches[@qswitchid] and not @qswitchtype == nil && $game.qswitches[@qswitchid])
		@cover.draw(@x-sx,@y-sy,3+z,1,1,if @layer==2 then 0xffc0c0c0 else 0xffffffff end) if @cover and cnd
	end
	
	def z
		case @layer
			when 0
			if @lower then -2 else 0 end
			when 1
			1
			when 2
			if @lower then -3 else -2.01 end
		end
	end
end

class Pipe
	def initialize(x,y,img,color,rainbow,flash,layer,qswitch,mask,map,room)
		@x,@y,@img,@color,@rbow,@flash,@layer=x,y,img,if not rainbow then Color.new(if flash then 255 else color[0] end,color[1],color[2],color[3]) else Color.new(color[0],255,255,255) end,rainbow,flash,layer
		if qswitch[0] != false then @qswitchid=qswitch[1] and @qswitchtype=qswitch[0] else @qswitchtype=false end
		if layer==0 and qswitch[0]!=true then @solid=true else @solid=false end
		@color.saturation=50 if rainbow
		@mask=mask
		map.tiles[room] << self
		
		if @solid
			map.modify_mask(room,[@x/640,@y/480],:splice,if @mask then @mask else Tls['tiles/mask',[32,32]][1] end,@x%640,@y%480)
			@set=true
		end
	end
	
	def draw(sx,sy)
		if @solid and !@set
			$game.map.modify_mask($game.room,[@x/640,@y/480],:splice,if @mask then @mask else Tls['tiles/mask',[32,32]][1] end,@x%640,@y%480)
			@set=true
		elsif !@solid and @set
			$game.map.modify_mask($game.room,[@x/640,@y/480],:splice,Tls['tiles/mask',[32,32]][0],@x%640,@y%480)
			@set=nil
		end
		return if not @x+32>sx && @x<sx+640 && @y+32>sy && @y<sy+480
		if @qswitchtype != false and $game.qswitches[@qswitchid]
			if @qswitchtype==true then @solid = @layer!=2 end
			if @qswitchtype==nil then @solid = false end
		elsif @qswitchtype != false
			if @qswitchtype==true then @solid = false end
			if @qswitchtype==nil then @solid = @layer!=2 end
		end
		
		return if @qswitchtype == true && !$game.qswitches[@qswitchid] or @qswitchtype == nil && $game.qswitches[@qswitchid]
		if @rbow then @color.hue= ($count % 180)*2 end
		if @flash then @color.alpha=(($count*4)%511-255).abs end
		@img[0].draw(@x-sx,@y-sy,3+z,1,1,@color)
		@img[1].draw(@x-sx,@y-sy,3+z)
	end
	
	def z
		case @layer
			when 0
			0
			when 1
			1
			when 2
			-2
		end
	end
end

class Climb < Entity
	attr_accessor :x,:y,:climbable
	def initialize(x,y,img,qswitch,room)
		@x,@y,@img=x,y,img
		if qswitch[0] != false then @qswitchid=qswitch[1] and @qswitchtype=qswitch[0] else @qswitchtype=false end
		if qswitch[0]!=true then @climbable=true else @climbable=false end
		init([:climb],room)
	end
	
	def update(sx,sy)
		if @qswitchtype != false and $game.qswitches[@qswitchid]
			if @qswitchtype==true then @climbable = true end
			if @qswitchtype==nil then @climbable = false end
		elsif @qswitchtype != false
			if @qswitchtype==true then @climbable = false end
			if @qswitchtype==nil then @climbable = true end
		end
	end
	
	def draw(sx,sy)
		return if not @x+32>sx && @x<sx+640 && @y+32>sy && @y<sy+480
		return if @qswitchtype == true && !$game.qswitches[@qswitchid] or @qswitchtype == nil && $game.qswitches[@qswitchid]
		@img.draw(@x-sx,@y-sy,1)
	end

	def delete
		if (m=$game.map).solid?(@x+16,@y+4) and m.solid?(@x+16,@y+28) then remove end
	end
end

class Water < Entity
	attr_reader :swimable
	def initialize(x,y,img,qswitch,room,water=true)
		@x,@y,@img=x,y,img
		if qswitch[0] != false then @qswitchid=qswitch[1] and @qswitchtype=qswitch[0] else @qswitchtype=false end
		if qswitch[0]!=true then @swimable=true else @swimable=false end
		init([if water then :water else :lava end],room)
		@water=water
		if !@water then @light=Light.new(x,y,3,qswitch,$game.map,room) end
	end
	
	def update(sx,sy)
		if @qswitchtype != false and $game.qswitches[@qswitchid]
			if @qswitchtype==true then @swimable = true end
			if @qswitchtype==nil then @swimable = false end
		elsif @qswitchtype != false
			if @qswitchtype==true then @swimable = false end
			if @qswitchtype==nil then @swimable = true end
		end
	end
	
	def draw(sx,sy)
		return if !@swimable
		if @water
			@img.draw(@x-sx,@y-sy,2,1,1,0xc0ffffff)
		else
			Tls["tiles/lavatiles",[32,32]][if @img[1] then 16+@img[0] else @img[0]*4+($count/8)%4 end].draw(@x-sx,@y-sy,2)
		end
	end
end

class Platform < Entity
	attr_reader :down
	def initialize(x,y,down,qswitch,room)
		@x,@y,@down=x,y,down
		if qswitch[0] != false then @qswitchid=qswitch[1] and @qswitchtype=qswitch[0] else @qswitchtype=false end
		if qswitch[0]!=true then @climbable=true else @climbable=false end
		init([:platform],room)
	end

	def update(sx,sy)
	end

	def draw(sx,sy)
	end

	def test(x,y)
		return if @qswitchtype == true && !$game.qswitches[@qswitchid] or @qswitchtype == nil && $game.qswitches[@qswitchid]
		x>@x and x<@x+32 and y>@y and y<@y+16
	end
end

class Quick
	attr_reader :x,:y
	def initialize(x,y,img,down,power,qswitch,map,room)
		@x,@y,@img,@down,@power=x,y,img,down,power
		if qswitch[0] != false then @qswitchid=qswitch[1] and @qswitchtype=qswitch[0] else @qswitchtype=false end
		map.tiles[room] << self
	end
	
	def draw(sx,sy)
		return if not @x+32>sx && @x<sx+640 && @y+32>sy && @y<sy+480
		if $count%(@power+1)==0 and (pl=$game.player).rightpos+32>@x and pl.leftpos<@x+32 and pl.uppos<@y+32 and pl.y+64>@y
			pl.vy=0
			pl.jumpable
		end
		if @qswitchtype != false and $game.qswitches[@qswitchid]
			if @qswitchtype==true then @solid = true end
			if @qswitchtype==nil then @solid = false end
		elsif @qswitchtype != false
			if @qswitchtype==true then @solid = false end
			if @qswitchtype==nil then @solid = true end
		end
		Tls["tiles/quick",[32,32]][if @down==1 then 16 else 0 end+@img*4+($count/(17-@power))%4].draw(@x-sx,@y-sy,3) if not @qswitchtype == true && !$game.qswitches[@qswitchid] and not @qswitchtype == nil && $game.qswitches[@qswitchid]
	end
end

class Light
	attr_accessor :x, :y
	def initialize(x,y,radius,qswitch,map,room)
		@x,@y,@radius,@room=x,y,radius,room
		@bright=true
		if qswitch[0] != false then @qswitchid=qswitch[1] and @qswitchtype=qswitch[0] else @qswitchtype=false end
		map.lights[room] << self
	end

	def glow(sx,sy)
		if @qswitchtype != false and $game.qswitches[@qswitchid]
			if @qswitchtype==true then @bright = true end
			if @qswitchtype==nil then @bright = false end
		elsif @qswitchtype != false
			if @qswitchtype==true then @bright = false end
			if @qswitchtype==nil then @bright = true end
		end
		if @bright and @x+16-@radius*64<sx+640 and @x+16+@radius*64>sx and @y+16-@radius*64<sy+480 and @y+16+@radius*64>sy
      Img['system/light',true].draw(@x+16-@radius*64-sx,@y+16-@radius*64-sy,0,@radius,@radius)
		end
	end

	def remove
		$game.map.lights[@room].delete(self)
	end

	def room
		if (r=$game.room)!=@room
			remove
			@room=$game.room
			$game.map.lights[r] << self
		end
	end
end