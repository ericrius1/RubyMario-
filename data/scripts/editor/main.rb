class Editor
	attr_accessor :system, :panels, :level, :room, :selects, :probject, :objmode
	def initialize(level=nil)
		$game=self
		$mode=:small
		@system=[]
		@panels=[]
		@sets=[]
		@mode=:tiles
		@objmode=:free
		@grid=true
		@selects=0
		@visible=[true,true,true]
		if !$music then $music=-1 else $music-=1 end
		musicchange
		
		Panel.new(0,0,128,96)
		Panel.new(0,96,128,160)
		Panel.new(0,256,128,192)
		Panel.new(0,448,128,32)
		
		@width=Counter.new(6,120,1,9999)
		@width.val=20
		@height=Counter.new(60,120,1,9999)
		@height.val=15
		@time=Counter.new(10,30,-1,9999)
		@room=Counter.new(76,231,0,0)
		
		@save=Press.new(8,457,"Save")
		@load=Press.new(48,457,"Load")
		@quit=Press.new(88,457,"Quit")
		@props=Press.new(64,262,"Set")
		@grids=Press.new(92,262,"Grid")
		@start=Press.new(7,75,"Start")
		@end=Press.new(42,75,"End")
		@secret=Press.new(72,75,"Secret")
		@add=Press.new(6,232,"Add")
		@delete=Press.new(34,232,"Delete")
		
		@playable=Check.new(107,47,false)
		@playable.val=true
		@dark=Check.new(44,213,false)
		
		@moder=Changer.new(6,262,['Tiles','Objects','Enemies','Specjal'])
		@weather=Changer.new(60,200,['Nothing','Rain','Rain+','Snow','Snow+','Thunders','Storm','Sandstorm','Sandstorm+','Fog','Fog+','Underwater'])
		@music=Changer.new(38,180,['Overworld','Underground1','Underground2','Underwater1','Underwater2','Castle','Ghost House','Desert','Snow','Beach','Sky','Darkland','Starland','Factory','Space','Bonus','Athletic','Challenge','Tanks','Fastrun'])
		
		@name=TextField.new(6,8,16,116)
		@name.text='new_level'
		@back=TextField.new(6,160,12,116)
		
		@level={'name'=>'new_level','time'=>-1,'start'=>[0,0,0],'finnish'=>[8,4,0],'end'=>[false],'rooms'=>[{'width'=>20,'height'=>15,'music'=>0,'weather'=>0,'dark'=>false,'objects'=>[],'frontlayer'=>[],'backlayer'=>[]}]}
		@objects=@level['rooms'][@room.val]['objects']
		@scx=-128
		@scy=@safesave=0
		
		@objects=@fore=@bak=[]
		if level
			@load.trigg=true
			@name.val=level
			@level['name']=level
		end
	end
	
	def update(mx,my)
		@mtime-=1
		if !@started
			Obj.new(0,0,:spec,[0,0,10,0,0,false,0,0])
			Obj.new(0,0,:level,['','','','',false,false])
			@started=true
		end
		@safesave-=1
		@width.max=19200/[@height.val,15].max
		@height.max=19200/[@width.val,20].max
		if !@level['end'] then @level['end']=[false] end
		@level['next']=@level['rooms'][0]['objects'][1].props[0]
		@level['secret']=@level['rooms'][0]['objects'][1].props[1]
		@level['thumbnail']=@level['rooms'][0]['objects'][1].props[2]
		@level['password']=@level['rooms'][0]['objects'][1].props[3]
		@level['end']=[(pr=@level['rooms'][0]['objects'][1].props)[4],pr[5]]
		@room.max=@level['rooms'].length-1
		@objects=@level['rooms'][@room.val]['objects']
		@fore=@level['rooms'][@room.val]['frontlayer']
		@bak=@level['rooms'][@room.val]['backlayer']
		cur=@level['rooms'][@room.val]
		if Keypress[KbSpace] then speed=48 else speed=16 end
		if not $screen.text_input
			if Keypress[KbRight]
				speed.times{if @scx+640<40960 then @scx+=1 else break end}
			end
			if Keypress[KbLeft]
				speed.times{if @scx>-128 then @scx-=1 else break end}
			end
			if Keypress[KbUp]
				speed.times{if @scy>0 then @scy-=1 else break end}
			end
			if Keypress[KbDown]
				speed.times{if @scy+480<40960 then @scy+=1 else break end}
			end
		end
	
		if Keypress[KbBackspace] and !$screen.text_input
		@objects.each{|o| o.select(mx+@scx,my+@scy,false) and o.delete} if @visible[1]
		@fore.each{|o| o.select(mx+@scx,my+@scy,false) and o.delete} if @visible[2]
		@bak.each{|o| o.select(mx+@scx,my+@scy,false) and o.delete} if @visible[0] end
		if @moder.clicked then @select=nil end
		
		@level['name']=@name.val
		@level['time']=@time.val
		@level['playable']=@playable.val
		cur['width']=@width.val
		cur['height']=@height.val
		cur['music']=@music.val
		cur['weather']=@weather.val
		cur['dark']=@dark.val
		if File.exists?("gfx/backgrounds/#{@back.val}.png") then cur['background']=@back.val elsif @back.val=='' then cur['background']=nil end
		
		if @save.press
			@objects.each{|o| o.unselect}
			@fore.each{|o| o.unselect}
			@bak.each{|o| o.unselect}
			txt=@level['name'].split('/')
			if @safesave<0 and File.exists?("data/#{if txt.length<2 then "own_levels" else "worlds" end}/#{txt[0]}.mlv")
				Snd['fireball'].play
				@safesave=60
			else
				Snd['select'].play
				@level['name']=txt[0]
				Marshal.dump(@level,f=File.new("data/#{if txt.length<2 then "own_levels" else "worlds" end}/#{txt[0]}.mlv",'w'))
				f.close
			end
		end
		if @load.press
			@scx=-128
			@scy=0
			@objects.each{|o| o.unselect}
			@fore.each{|o| o.unselect}
			@bak.each{|o| o.unselect}
			txt=@level['name'].split('/')
			if File.exists?("data/#{f=if txt.length<3 then "own_levels" else "worlds" end}/#{txt[0]}.mlv")
				level=Marshal.load(File.new("data/#{f}/#{txt[0]}.mlv",'r'))
				if (ps=level['password']).length>0 && txt[1]==ps or ps.length==0
					Snd['select'].play
					@level=level
					@name.val=txt[0]
					@time.val=@level['time']
					@playable.val=@level['playable']
					@room.val=0
					@width.val=@level['rooms'][0]['width']
					@height.val=@level['rooms'][0]['height']
					@music.val=@level['rooms'][0]['music']
					@weather.val=@level['rooms'][0]['weather']
					@back.val=@level['rooms'][0]['background']
					@dark.val=@level['rooms'][0]['dark']
				else
					Snd['cancel'].play
				end
			else
				Snd['fireball'].play
			end
		end
		if @quit.press
			$screen.text_input=nil
			$game=Mainmenu.new
		end
		if @props.press and @probject
			@setting=!@setting
		end
		if @props.over
			Text[mx+8,my,5,"short: P",0.5,10,10,0,255]
		end
		if @grids.over
			Text[mx+8,my,5,"short: G",0.5,10,10,0,255]
		end
		if @start.over
			Text[mx+8,my,5,"press SHIFT for luigi",0.5,10,10,0,255]
		end
		if @grids.press
			@grid=!@grid
		end
		if @add.press
			@level['rooms'] << {'width'=>20,'height'=>15,'music'=>0,'weather'=>0,'dark'=>false,'objects'=>[],'frontlayer'=>[],'backlayer'=>[]}
			Obj.new(0,0,:spec,[0,0,10,0,0,false,0,0],@level['rooms'].length-1)
		end
		if @delete.press and @level['rooms'].length>1
			@level['rooms'].delete_at(@room.val)
			if @room.val==@level['rooms'].length then @room.val-=1 end
		end
		if @start.press
			@probject=@select=nil
			if Keypress[KbLeftShift]
				if !@level['luigi']
					@level['luigi']=[0,0,0]
					@luigi=true
					@objmode=:start
				else
					@level['luigi']=nil
				end
			else
				@objmode=:start
			end
		end
		if @end.press
			@probject=@select=nil
			@objmode=:end
		end
		if @secret.press
			if !@level['alter']
				@probject=@select=nil
				@objmode=:secret
				@level['alter']=[0,0,0]
			else
				@level['alter']=nil
			end
		end
		#Object individual lines
		if @probject and @probject.type==:spawn and @setting
			Text[130,108,5,"Enemies: #{@sets[5].length}",0.5,8,20,0,255]
			if@sets[3].press
				@temp=@objmode
				@objmode=:enemy
			end
			if@sets[4].press
				Snd['fireball'].play
				@sets[5].pop
			end
		elsif @probject and @probject.type==:spec and !@sets.empty?
			@sets[6].max=cur['width']-1
			@sets[7].max=cur['height']-1
		end
		@objects[0].props[6]=[@objects[0].props[6],cur['width']-1].min
		@objects[0].props[7]=[@objects[0].props[7],cur['height']-1].min
		
		@mode=[:tiles,:objects,:enemies,:specjal][@moder.val]
		if @selects==1 and @objmode!=:enemy then @objmode=:select elsif @objmode==:select then @objmode=:free end
		
		placing(mx,my) if [:free,:place].include?(@objmode)
		
		room=@room.val
		@system.each{|s| if not @sets.include?(s) then s.update(mx,my) elsif @setting then s.update(mx,my) end}
		if @room.val != room
			@objects.each{|o| o.unselect}
			@fore.each{|o| o.unselect}
			@bak.each{|o| o.unselect}
			@scx=-128
			@scy=0
			cur=@level['rooms'][@room.val]
			@width.val=cur['width']
			@height.val=cur['height']
			@weather.val=cur['weather']
			@music.val=cur['music']
			@back.val=cur['background']
			@dark.val=cur['dark']
		end
	
		if @objmode==:free then clearset
			@setting=nil end
		
		if @probject then i=0
		@sets.length.times{
		if ![Press,Array].include?(@sets[i].class)
			@probject.props[i]=@sets[i].val
		elsif @sets[i].class==Array
			@probject.props[i]=@sets[i]
		end
		i+=1} end
	
		@probject.unselect if @objmode==:place
	end
	
	def draw(mx,my)
		Text[128,470,10,(['Editor.ogg','Overworld.ogg','Underground1.ogg','Underground2.ogg','Underwater1.ogg','Underwater2.ogg','Castle.ogg','Ghost House.ogg','Desert.ogg','Snow.ogg','Beach.ogg','Sky.ogg','Darkland.ogg','Starland.xm','Factory.ogg','Space.ogg','Bonus.ogg','Athletic.ogg','Challenge.s3m','Tanks.xm','Fastrun.xm','Rampage1.ogg','Rampage2.ogg','Boss1.ogg','Boss2.ogg','Boss3.ogg','Invincible.ogg'][$music]),0.5,8,8,0,255] if @mtime>0
		cur=@level['rooms'][@room.val]
		i=[@objects[0].props[7]-@scy/32,0].max
		[(cur['height']-[@scy/32,@objects[0].props[7]].max).to_i,0].max.times{Img['editor/border'].draw(cur['width']*32-@scx,i*32+$count%32-16,4)
		i+=1}
		i=[@objects[0].props[6]-@scx/32,0].max
		[(cur['width']-[@scx/32,@objects[0].props[6]].max).to_i,0].max.times{Img['editor/border'].draw(i*32-$count%32+16,cur['height']*32-@scy,4)
		i+=1}
		i=[@objects[0].props[7]-@scy/32,0].max
		[(cur['height']-[@scy/32,@objects[0].props[7]].max).to_i,0].max.times{Img['editor/border'].draw(@objects[0].props[6]*32-@scx-16,i*32-$count%32+16,4)
		i+=1}
		i=[@objects[0].props[6]-@scx/32,0].max
		[(cur['width']-[@scx/32,@objects[0].props[6]].max).to_i,0].max.times{Img['editor/border'].draw(i*32+$count%32-16,@objects[0].props[7]*32-@scy-16,4)
		i+=1}

		if !@level['end'] then @level['end']=[false] end
		Tls['objects/finnish_pole',[16,300]][0].draw(if @objmode==:end then 32*((mx.to_i+@scx)/32)+8-@scx else @level['finnish'][0]-@scx end,if @objmode==:end then 16*((my.to_i)/16)+4 else @level['finnish'][1]-@scy end,2) if @room.val==@level['finnish'][2] or @objmode==:end
		Tls['objects/finnish_flag',[32,32]][($count/8)%4].draw(if @objmode==:end then 32*((mx.to_i+@scx)/32)+18-@scx else @level['finnish'][0]+10-@scx end-if @level['end'][0] then 4 else 0 end,if @objmode==:end then 16*((my.to_i)/16)+23 else @level['finnish'][1]+19-@scy end,2,if @level['end'][0] then -1 else 1 end) if @room.val==@level['finnish'][2] or @objmode==:end
		Tls['mario/normal',[32,64]][0].draw(if @objmode==:end then 32*((mx.to_i+@scx)/32)+if @level['end'][0] then -176 else 176 end-@scx else @level['finnish'][0]+if @level['end'][0] then -184 else 168 end-@scx end,if @objmode==:end then 16*((my.to_i)/16)+272 else @level['finnish'][1]+268-@scy end,2,1,1,0x80ffffff) if @room.val==@level['finnish'][2] or @objmode==:end
		Tls['objects/finnish_pole',[16,300]][1].draw(if @objmode==:secret then 32*((mx.to_i+@scx)/32)+8-@scx else @level['alter'][0]-@scx end,if @objmode==:secret then 16*((my.to_i)/16)+4 else @level['alter'][1]-@scy end,2) if @level['alter'] && @room.val==@level['alter'][2] or @objmode==:secret
		Tls['objects/finnish_flag',[32,32]][4+($count/8)%4].draw(if @objmode==:secret then 32*((mx.to_i+@scx)/32)+18-@scx else @level['alter'][0]+10-@scx end-if @level['end'][1] then 4 else 0 end,if @objmode==:secret then 16*((my.to_i)/16)+23 else @level['alter'][1]+19-@scy end,2,if @level['end'][1] then -1 else 1 end) if @level['alter'] && @room.val==@level['alter'][2] or @objmode==:secret
		Tls['mario/normal',[32,64]][0].draw(if @objmode==:secret then 32*((mx.to_i+@scx)/32)+if @level['end'][1] then -176 else 176 end-@scx else @level['alter'][0]+if @level['end'][1] then -184 else 168 end-@scx end,if @objmode==:secret then 16*((my.to_i)/16)+272 else @level['alter'][1]+268-@scy end,2,1,1,0x80ffffff) if @level['alter'] && @room.val==@level['alter'][2] or @objmode==:secret
		Tls['mario/normal',[32,64]][0].draw(if @objmode==:start and !@luigi then 16*((mx.to_i)/16) else @level['start'][0]-@scx end,if @objmode==:start and !@luigi then 16*((my.to_i)/16) else @level['start'][1]-@scy end,2) if @room.val==@level['start'][2] or @objmode==:start && !@luigi 
		Tls['luigi/normal',[32,64]][0].draw(if @objmode==:start and @luigi then 16*((mx.to_i)/16) else @level['luigi'][0]-@scx end,if @objmode==:start and @luigi then 16*((my.to_i)/16) else @level['luigi'][1]-@scy end,2) if @level['luigi'] && @room.val==@level['luigi'][2] or @objmode==:start && @luigi
		Img['editor/cursor'].draw(mx,my,5)
		Img["backgrounds/#{@level['rooms'][@room.val]['background']}"].draw(0,0,-1) if @level['rooms'][@room.val]['background']
		grid if @grid
		
		if (o=@objects[0]).props[0]>0
			i=-1
			17.times{Tls['editor/liquid',[32,5]][o.props[4]].draw(128+i*32+($count/4)%32,(@level['rooms'][@room.val]['height']-o.props[0])*32-@scy,3)
			i+=1}
		end
		
		@panels.each{|p| if p !=@setwindow then p.draw elsif @setting then p.draw end}
		@system.each{|s| if not @sets.include?(s) then s.draw elsif @setting then s.draw end}
	
		Text[60,34,4,'time',0.5,8,8,0,255]
		Text[40,52,4,'playable',0.5,8,8,0,255]
		Text[5,104,4,'width  height',0.5,8,8,0,255]
		Text[5,142,4,'background',0.5,8,8,0,255]
		Text[5,182,4,'mux:',0.5,8,8,0,255]
		Text[5,202,4,'weath:',0.5,8,8,0,255]
		Text[5,217,4,'dark:',0.5,8,8,0,255]
		Text[130,460,4,'any help from Editor Help.txt',0.8,16,30,0,255] if @setting
		
		@objects.each{|o| o.draw(@scx,@scy)} if @visible[1]
		@fore.each{|o| o.draw(@scx,@scy)} if @visible[2]
		@bak.each{|o| o.draw(@scx,@scy)} if @visible[0]
		if @setting then Text[130,8,4,@text,0.5,8,20,0,255,:normal,0.5] end
		@probject.draw(@scx,@scy) if @objmode==:place and mx>128
		
		if @select
			c=0xffff0000
			$screen.draw_quad(@select[0]*16+3,@select[1]*16+281,c,@select[0]*16+21,@select[1]*16+281,c,@select[0]*16+21,@select[1]*16+299,c,@select[0]*16+3,@select[1]*16+299,c,4)
		end
		
		case @mode
			when :tiles
			Tls['tiles/block',[32,32]][0].draw(4,282,4,0.5,0.5)
			Tls['tiles/pipes',[64,64]][1].draw(20,282,4,0.25,0.25)
			Tls['tiles/grass1',[32,32]][15].draw(36,282,4,0.5,0.5)
			Tls['tiles/ground1',[32,32]][5].draw(52,282,4,0.5,0.5)
			Tls['tiles/climb',[32,32]][5].draw(68,282,4,0.5,0.5)
			Tls['tiles/ice',[32,32]][21].draw(84,282,4,0.5,0.5)
			Tls['tiles/water_tiles',[32,32]][0].draw(100,282,4,0.5,0.5)
			Tls['tiles/sand',[32,32]][22].draw(4,298,4,0.5,0.5)
			Tls['tiles/land',[32,32]][0].draw(20,298,4,0.5,0.5)
			Tls['tiles/clouds',[32,32]][0].draw(36,298,4,0.5,0.5)
			Tls['tiles/factory',[32,32]][4].draw(52,298,4,0.5,0.5)
			Img['tiles/castle1'].draw(68,304,4,0.0625,0.0625)
			Tls['tiles/mini',[32,32]][0].draw(84,298,4,0.5,0.5)
			Tls['tiles/lavatiles',[32,32]][($count/8)%4].draw(100,298,4,0.5,0.5)
			Tls['tiles/wall1',[32,32]][2].draw(4,314,4,0.5,0.5)
			Tls['tiles/bonus',[32,32],true][11].draw(20,314,4,0.5,0.5)
			Tls['tiles/quick',[32,32],true][($count/8%4)].draw(36,314,4,0.5,0.5)
			Tls['tiles/pyramid',[32,32],true][35].draw(52,314,4,0.5,0.5)
			Tls['tiles/scenery',[32,32],true][7].draw(68,314,4,0.5,0.5)
			Tls['tiles/anim_scen',[32,32],true][60+($count/12)%4].draw(84,314,4,0.5,0.5)
			Tls['tiles/wooden',[32,32],true][48].draw(100,314,4,0.5,0.5)
			Tls['tiles/underwater',[32,32],true][0].draw(4,330,4,0.5,0.5)
			Tls['tiles/ghost',[32,32],true][1].draw(20,330,4,0.5,0.5)
			Tls['tiles/spikes',[32,32],true][4].draw(36,330,4,0.5,0.5)
			when :objects
			Tls['objects/bricks',[32,32]][0].draw(4,282,4,0.5,0.5)
			Tls['objects/powerupblock',[32,32]][$count/8%4].draw(20,282,4,0.5,0.5)
			Tls['bonus/coin',[32,32]][$count/8%4].draw(36,282,4,0.5,0.5)
			Tls['objects/changes',[32,32]][0].draw(52,282,4,0.5,0.5)
			Tls['objects/changes',[32,32]][3].draw(68,282,4,0.5,0.5)
			Tls['objects/switches',[24,24]][0].draw(85,282,4,0.66,0.66)
			Tls['objects/door',[54,80]][0].draw(103,283,4,0.2,0.2)
			Img['objects/key'].draw(4,298,4,0.5,0.5)
			Tls['objects/spring',[32,32]][0].draw(20,298,4,0.5,0.5)
			Tls['objects/switches',[24,24]][1].draw(37,298,4,0.66,0.66)
			Tls['objects/blocks',[32,32]][1].draw(52,298,4,0.5,0.5)
			Tls['objects/switches',[24,24]][2].draw(68,298,4,0.66,0.66)
			Tls['objects/powerupblock',[32,32]][$count/8%4].draw(84,298,4,0.5,0.5)
			Tls['objects/saveflag',[32,64]][$count/8%4].draw(104,298,4,0.25,0.25)
			Tls['objects/blocks',[32,32]][0].draw(4,314,4,0.5,0.5)
			Tls['objects/flipblock',[32,32]][0].draw(20,314,4,0.5,0.5)
			Tls['objects/blocks',[32,32]][5].draw(36,314,4,0.5,0.5)
			Tls['enemies/shell',[32,32]][0].draw(52,314,4,0.5,0.5)
			Tls['objects/passwordblock',[32,32]][4].draw(68,314,4,0.5,0.5)
			Tls['objects/passwordblock',[32,32]][$count/8%4].draw(84,314,4,0.5,0.5)
			Tls['objects/changes',[32,32]][0].draw(100,314,4,0.5,0.5,0xff00ff00)
			Tls['objects/changes-const',[32,32]][0].draw(100,314,4,0.5,0.5)
			Img['editor/light'].draw(4,330,4,0.5,0.5)
			Tls['objects/blocks',[32,32]][7].draw(20,330,4,0.5,0.5)
			when :enemies
			Tls['enemies/goomba',[32,32]][($count/8)%2].draw(4,282,4,0.5,0.5)
			Tls['enemies/koopa troopa',[32,48]][($count/8)%2].draw(24,282,4,0.33,0.33)
			Tls['enemies/piranha plant head',[32,32]][($count/8)%2].draw(36,282,4,0.5,0.5)
			Tls['enemies/spiny',[32,32]][($count/8)%2].draw(52,282,4,0.5,0.5)
			Tls['enemies/buzzy beetle',[32,32]][($count/8)%2].draw(68,282,4,0.5,0.5)
			Tls['enemies/bowser',[64,70]][0].draw(84,282,4,0.22,0.22)
			Tls['enemies/blaster',[32,32]][0].draw(100,282,4,0.5,0.5)
			Tls['enemies/rotodisc',[32,32]][($count/8)%21].draw(4,298,4,0.5,0.5)
			Tls['enemies/podobo',[28,32]][($count/8)%3].draw(21,298,4,0.5,0.5)
			Tls['enemies/fire',[68,30]][($count/8)%5].draw(36,302,4,0.24,0.24)
			Tls['enemies/cheep cheep',[32,32]][($count/8)%2].draw(52,298,4,0.5,0.5)
			Tls['enemies/pokey',[48,48]][1].draw(68,298,4,0.33,0.33)
			Tls['enemies/boo',[32,32]][2+($count/8)%2].draw(84,298,4,0.5,0.5)
			Tls['enemies/hammerbros',[32,68]][($count/8)%2].draw(104,298,4,0.24,0.24)
			when :specjal
			Tls['editor/warp',[16,16]][0].draw(4,282,4)
			Img['editor/platform'].draw(20,282,4,0.5,0.5)
			Tls['editor/triggers',[16,16]][0].draw(36,282,4,1,1)
			Tls['editor/triggers',[16,16]][1].draw(52,282,4,1,1)
			Tls['editor/triggers',[16,16]][2].draw(68,282,4,1,1)
			Tls['editor/triggers',[16,16]][3].draw(84,282,4,1,1)
			Tls['editor/triggers',[16,16]][4].draw(100,282,4,1,1)
			Tls['editor/triggers',[16,16]][5].draw(4,298,4,1,1)
		end
		Tls['editor/check',[16,16]][if @visible[0] then 1 else 2 end].draw(596,468,4,0.5,0.5)
		Tls['editor/check',[16,16]][if @visible[1] then 1 else 2 end].draw(612,468,4,0.5,0.5)
		Tls['editor/check',[16,16]][if @visible[2] then 1 else 2 end].draw(628,468,4,0.5,0.5)
	end
	
	def grid
		l=16
		c=0xff808080
		20.times{
		$screen.draw_line(l-@scx%32,0,c,l-@scx%32,480,c,0)
		l+=32}
		l=16
		15.times{
		$screen.draw_line(0,l-@scy%32,c,640,l-@scy%32,c,0)
		l+=32}
		c=0xffffffff
		l=32
		20.times{
		$screen.draw_line(l-@scx%32,0,c,l-@scx%32,480,c,0)
		l+=32}
		l=32
		15.times{
		$screen.draw_line(0,l-@scy%32,c,640,l-@scy%32,c,0)
		l+=32}
	end
	
	def placing(mx,my)
		if @objmode==:place
			case @eq
				when 0
				@probject.x=32*((mx.to_i+@scx)/32)
				@probject.y=32*((my.to_i+@scy)/32)
				when 1
				@probject.x=8*((mx.to_i+@scx)/8)
				@probject.y=8*((my.to_i+@scy)/8)
				when 2
				@probject.x=@probject.y=0
				when 3
				@probject.x=32*((mx.to_i+@scx)/32)+4
				@probject.y=32*((my.to_i+@scy)/32)+8
				when 4
				@probject.x=32*((mx.to_i+@scx)/32)
				@probject.y=32*((my.to_i+@scy)/32)+16
				when 5
				@probject.x=32*((mx.to_i+@scx)/32)+16
				@probject.y=32*((my.to_i+@scy)/32)
				when 6
				@probject.x=32*((mx.to_i+@scx)/32)
				@probject.y=32*((my.to_i+@scy)/32)-16
				when 7
				@probject.x=32*((mx.to_i+@scx)/32)+5
				@probject.y=32*((my.to_i+@scy)/32)+16
				when 8
				@probject.x=16*((mx.to_i+@scx)/16)
				@probject.y=16*((my.to_i+@scy)/16)
				when 9
				@probject.x=32*((mx.to_i+@scx)/32)
				@probject.y=32*((my.to_i+@scy)/32)-6
				when 10
				@probject.x=32*((mx.to_i+@scx)/32)+2
				@probject.y=32*((my.to_i+@scy)/32)
				when 11
				@probject.x=32*((mx.to_i+@scx)/32)+8
				@probject.y=32*((my.to_i+@scy)/32)-if @sets[2].val.even? then 16 else 0 end
				when 12
				@probject.x=32*((mx.to_i+@scx)/32)
				@probject.y=32*((my.to_i+@scy)/32)-36
			end
		end
		
		if mx>4 and mx<110 and my>287 and my<440 and Keypress[MsLeft] and !@setting
			@objects.each{|o| o.unselect}
			@fore.each{|o| o.unselect}
			@bak.each{|o| o.unselect}
			@select=[mx.to_i/16,my.to_i/16-18]
			clearset
			@probject=Obj.new(0,0,seltype,[])
			@seted=nil
			@objmode=:place
			props(seltype)
		end
		
		if Keypress[MsLeft] and mx>128 and mx<640 and my<480 and my>=0 and !@setting and @objmode==:place
			Obj.new(@probject.x,@probject.y,@probject.type,@probject.props.dup)
		end
	end
	
	def props(type)
		size=[0,0]
		@eq=0
		case type
			when :block
			size=[152,110]
			@sets[0]=Tileselector.new(178,26,Img['tiles/block'],[32,32])
			@sets[1]=Changer.new(190,86,['Solid','Foreground','Background'])
			@sets[2]=Check.new(200,44,true)
			@sets[3]=Counter.new(220,64,0,9999)
			@eq=0
			text="<Block>^Type:^?Switch:^?Switch id:^Layer:"
			when :pipe
			size=[330,286]
			@sets[0]=Tileselector.new(178,26,Img['tiles/pipes'],[32,32])
			@sets[1]=Zip.new(190,132,255)
			@sets[2]=Zip.new(190,152,255)
			@sets[3]=Zip.new(190,172,255)
			@sets[4]=Zip.new(190,192,255)
			@sets[5]=Check.new(204,206,false)
			@sets[6]=Check.new(204,226,false)
			@sets[7]=Changer.new(330,26,['Solid','Foreground','Background'])
			@sets[8]=Check.new(204,246,true)
			@sets[9]=Counter.new(220,264,0,9999)
			@eq=0
			text="<Pipes>^Type:                        Layer:^^^^^Red:^Green:^Blue:^Trans:^Rainbow:^Flash:^?Switch:^?Switch id:"
			when :grass
			size=[190,230]
			@sets[0]=Tileselector.new(178,26,Img['tiles/grass1'],[32,32])
			@sets[1]=Changer.new(178,145,['Grassland','Jungle','Forest','Starland','Chocolate','Snow','Ocean'])
			@sets[2]=Changer.new(185,205,['Solid','Foreground','Background'])
			@sets[3]=Check.new(196,166,true)
			@sets[4]=Counter.new(220,184,0,9999)
			@eq=0
			text="<Grass>^Type:^^^^^^Skin:^?Switch:^?Switch id:^Layer:"
			when :ground
			size=[220,190]
			@sets[0]=Tileselector.new(178,26,Img['tiles/ground1'],[32,32])
			@sets[1]=Changer.new(178,108,['Soil','Rock','Grass','Snow','Sand','Moon','Chocolate','Dark'])
			@sets[2]=Changer.new(185,166,['Solid','Foreground','Background'])
			@sets[3]=Check.new(196,128,true)
			@sets[4]=Counter.new(220,144,0,9999)
			@eq=0
			text="<Ground>^Type:^^^^Skin:^?Switch:^?Switch id:^Layer:"
			when :climb
			size=[148,128]
			@sets[0]=Tileselector.new(178,26,Img['tiles/climb'],[32,32])
			@sets[1]=Check.new(196,84,true)
			@sets[2]=Counter.new(220,104,0,9999)
			if Keypress[KbLeftControl] then @eq=4 elsif Keypress[KbLeftShift] then @eq=5 else @eq=0 end
			text="<Climb>^Type: ^^^?Switch:^?Switch id:"
			when :ice
			size=[148,168]
			@sets[0]=Tileselector.new(178,26,Img['tiles/ice'],[32,32])
			@sets[1]=Check.new(196,106,true)
			@sets[2]=Counter.new(220,126,0,9999)
			@sets[3]=Changer.new(185,146,['Solid','Foreground','Background'])
			if Keypress[KbLeftControl] then @eq=4 else @eq=0 end
			text="<Ice>^Type: ^^^^?Switch:^?Switch id:^Layer:"
			when :water
			size=[148,108]
			@sets[0]=Tileselector.new(178,26,Img['tiles/water_tiles'],[32,32])
			@sets[1]=Check.new(196,66,true)
			@sets[2]=Counter.new(220,86,0,9999)
			@eq=0
			text="<Water>^Type: ^^?Switch:^?Switch id:"
			when :sand
			size=[264,168]
			@sets[0]=Tileselector.new(178,26,Img['tiles/sand'],[32,32])
			@sets[1]=Changer.new(185,146,['Solid','Foreground','Background'])
			@sets[2]=Check.new(196,107,true)
			@sets[3]=Counter.new(220,125,0,9999)
			@eq=0
			text="<Sand>^Type:^^^^?Switch:^?Switch id:^Layer:"
			when :land
			size=[184,168]
			@sets[0]=Tileselector.new(178,26,Img['tiles/land'],[32,32])
			@sets[1]=Changer.new(185,146,['Solid','Foreground','Background'])
			@sets[2]=Check.new(196,107,true)
			@sets[3]=Counter.new(220,125,0,9999)
			@eq=0
			text="<Land>^Type:^^^^?Switch:^?Switch id:^Layer:"
			when :cloud
			size=[184,168]
			@sets[0]=Tileselector.new(178,26,Img['tiles/clouds'],[32,32])
			@sets[1]=Changer.new(185,146,['Solid','Foreground','Background'])
			@sets[2]=Check.new(196,107,true)
			@sets[3]=Counter.new(220,125,0,9999)
			@eq=0
			text="<Clouds>^Type:^^^^?Switch:^?Switch id:^Layer:"
			when :factory
			size=[328,168]
			@sets[0]=Tileselector.new(178,26,Img['tiles/factory'],[32,32])
			@sets[1]=Changer.new(185,146,['Solid','Foreground','Background'])
			@sets[2]=Check.new(196,107,true)
			@sets[3]=Counter.new(220,125,0,9999)
			@eq=0
			text="<Factory Tiles>^Type:^^^^?Switch:^?Switch id:^Layer:"
			when :castle
			size=[260,168]
			@sets[0]=Tileselector.new(178,26,Img['tiles/castle1'],[32,32])
			@sets[1]=Changer.new(185,146,['Higher','Foreground','Lower'])
			@sets[2]=Changer.new(185,107,['Bronze','Blue','Gray','Green'])
			@sets[3]=Changer.new(185,125,['Nothing','Snow','Sand','Vegetation'])
			@eq=0
			text="<Castle>^Type:^^^^Skin:^Cover:^Layer:"
			when :mini
			size=[264,168]
			@sets[0]=Tileselector.new(178,26,Img['tiles/mini'],[32,32])
			@sets[1]=Changer.new(185,146,['Solid','Foreground','Background'])
			@sets[2]=Check.new(196,107,true)
			@sets[3]=Counter.new(220,125,0,9999)
			@eq=0
			text="<Mini Tiles>^Type:^^^^?Switch:^?Switch id:^Layer:"
			when :lava
			size=[150,96]
			@sets[0]=Changer.new(178,26,['Normal','Acid','Poison','Simple'])
			@sets[3]=Changer.new(220,26,['Upper','Downer'])
			@sets[1]=Check.new(196,46,true)
			@sets[2]=Counter.new(220,66,0,9999)
			@eq=0
			text="<Lava Tiles>^Type:^?Switch:^?Switch id:"
			when :wall
			size=[170,214]
			@sets[0]=Tileselector.new(178,26,Img['tiles/wall1'],[32,32])
			@sets[1]=Changer.new(185,146,['Solid','Foreground','Background'])
			@sets[2]=Changer.new(185,107,['Gray','Blue','Bronze','Green'])
			@sets[3]=Changer.new(185,125,['Nothing','Snow','Sand','Vegetation'])
			@sets[4]=Check.new(196,165,true)
			@sets[5]=Counter.new(220,185,0,9999)
			@eq=0
			text="<Wall>^Type:^^^^Skin:^Cover:^Layer:^?Switch:^?Switch id:"
			when :bonus
			size=[264,168]
			@sets[0]=Tileselector.new(178,26,Img['tiles/bonus'],[32,32])
			@sets[1]=Changer.new(185,146,['Solid','Foreground','Background'])
			@sets[2]=Check.new(196,107,true)
			@sets[3]=Counter.new(220,125,0,9999)
			@eq=0
			text="<BonusRoom Tiles>^Type:^^^^?Switch:^?Switch id:^Layer:"
			when :quick
			size=[190,116]
			@sets[0]=Changer.new(178,26,['Sand','Mud','Vegetation','Crystalic'])
			@sets[1]=Changer.new(260,26,['Upper','Downer'])
			@sets[2]=Counter.new(220,46,1,16)
			@sets[3]=Check.new(196,66,true)
			@sets[4]=Counter.new(220,86,0,9999)
			@eq=0
			text="<Quick Tiles>^Skin:^Power^?Switch:^?Switch id:"
			when :pyramid
			size=[264,208]
			@sets[0]=Tileselector.new(178,26,Img['tiles/pyramid'],[32,32])
			@sets[1]=Changer.new(185,186,['Solid','Foreground','Background'])
			@sets[2]=Check.new(196,147,true)
			@sets[3]=Counter.new(220,165,0,9999)
			@eq=0
			text="<Pyramid Tiles>^Type:^^^^^^?Switch:^?Switch id:^Layer:"
			when :scenery
			size=[312,268]
			@sets[0]=Tileselector.new(178,26,Img['tiles/scenery'],[32,32])
			@sets[1]=Changer.new(185,246,['Higher','Foreground','Lower'])
			@sets[2]=Check.new(196,207,true)
			@sets[3]=Counter.new(220,225,0,9999)
			@eq=0
			text="<Scenery>^Type:^^^^^^^^^?Switch:^?Switch id:^Layer:"
			when :animscen
			size=[230,228]
			@sets[0]=Tileselector.new(140,46,Img['tiles/anim_scen_prev'],[32,32])
			@sets[1]=Changer.new(253,146,['Higher','Foreground','Lower'])
			@sets[2]=Check.new(264,107,true)
			@sets[3]=Counter.new(288,125,0,9999)
			@eq=0
			text="<Animated Scenery>^Type:^^^^              ?Switch:^              ?Switch id:^              Layer:"
			when :wooden
			size=[210,208]
			@sets[0]=Tileselector.new(178,26,Img['tiles/wooden'],[32,32])
			@sets[1]=Changer.new(190,186,['Solid','Foreground','Background'])
			@sets[2]=Check.new(200,144,true)
			@sets[3]=Counter.new(220,164,0,9999)
			@eq=0
			text="<Wooden Tiles>^Type:^^^^^^?Switch:^?Switch id:^Layer:"
			when :underwater
			size=[274,208]
			@sets[0]=Tileselector.new(178,26,Img['tiles/underwater'],[32,32])
			@sets[1]=Changer.new(190,186,['Solid','Foreground','Background'])
			@sets[2]=Check.new(200,144,true)
			@sets[3]=Counter.new(220,164,0,9999)
			@eq=0
			text="<Underwater Tiles>^Type:^^^^^^?Switch:^?Switch id:^Layer:"
			when :ghost
			size=[210,148]
			@sets[0]=Tileselector.new(178,26,Img['tiles/ghost'],[32,32])
			@sets[1]=Changer.new(190,126,['Solid','Foreground','Background'])
			@sets[2]=Check.new(200,87,true)
			@sets[3]=Counter.new(220,105,0,9999)
			@eq=0
			text="<Ghost House Tiles>^Type:^^^?Switch:^?Switch id:^Layer:"
			when :spikes
			size=[210,164]
			@sets[0]=Tileselector.new(178,26,Img['tiles/spikes'],[32,32])
			@sets[1]=Changer.new(190,142,['Solid','Foreground','Background'])
			@sets[2]=Check.new(200,103,true)
			@sets[3]=Counter.new(220,122,0,9999)
			@eq=0
			text="<Ghost House Tiles>^Type:^^^^?Switch:^?Switch id:^Layer:"
			
			when :bricks
			size=[120,70]
			text="<Bricks>^Type:^Coins:"
			@sets[0]=Tileselector.new(178,26,Img['objects/bricks'],[32,32])
			@sets[1]=Counter.new(184,47,0,9999)
			@eq=0
			when :powerupblock
			size=[182,86]
			@sets[0]=Tileselector.new(178,26,Img['bonus/powerups'],[32,32])
			@sets[1]=Check.new(192,66,false)
			text="<PowerUp Block>^Item:^^Hidden:"
			@eq=0
			when :coin
			size=[102,52]
			@sets[0]=Changer.new(178,26,['Yellow','Green','Blue'])
			text="<Coin>^Type:"
			@eq=0
			when :onoff,:changing
			size=[284,70]
			@sets[0]=Counter.new(170,26,0,4)
			@sets[1]=Counter.new(274,26,0,4)
			@sets[2]=Counter.new(362,26,0,4)
			@sets[3]=Changer.new(138,46,['On','Off'])
			@sets[4]=Check.new(214,46,false) if type==:onoff
			text="<On/Off Block>^Red:              Green:             Blue:#{if type==:onoff then "^      Hidden:" end}"
			@eq=0
			when :qswitch
			size=[224,116]
			@sets[0]=Counter.new(160,26,0,9999)
			@sets[1]=Changer.new(230,26,['Short','Long'])
			@sets[2]=Check.new(210,46,false)
			@sets[3]=Check.new(273,46,false)
			@sets[4]=Check.new(210,66,false)
			@sets[5]=Counter.new(210,86,-1,9999)
			@sets[6]=Counter.new(294,86,-1,9999)
			text="<?-Switch>^Id:^Anchored:      Once:^Still:^Trigger:               Off:"
			@eq=3
			when :door
			size=[346,110]
			@sets[0]=Changer.new(180,26,['Two-Way','Exit','Mini'])
			@sets[1]=Check.new(176,46,false)
			@sets[2]=Counter.new(235,46,0,4)
			@sets[3]=Counter.new(335,46,0,4)
			@sets[4]=Counter.new(423,46,0,4)
			@sets[5]=Check.new(196,66,true)
			@sets[6]=Counter.new(220,86,0,9999)
			text="<Door>^Type:^Lock:     Red:              Green:             Blue:^?Switch:^?Switch id:"
			@eq=7
			when :key
			size=[286,90]
			@sets[0]=Counter.new(170,26,0,4)
			@sets[1]=Counter.new(270,26,0,4)
			@sets[2]=Counter.new(358,26,0,4)
			@sets[3]=Counter.new(200,48,0,50)
			@sets[4]=Counter.new(244,66,0,50)
			text="<Key>^Red:             Green:             Blue:^Phantos:^Phanto Speed:"
			@eq=0
			when :spring
			size=[92,72]
			@sets[0]=Changer.new(178,26,['Green','Blue','Red'])
			@sets[1]=Check.new(196,46,false)
			text="<Spring>^Type:^Anchor:"
			@eq=0
			when :pswitch
			size=[92,92]
			@sets[0]=Changer.new(178,26,['Short','Long'])
			@sets[1]=Check.new(196,46,false)
			@sets[2]=Check.new(196,66,false)
			text="<P-Switch>^Time:^Anchor:^Once:"
			@eq=3
			when :pblock
			size=[92,52]
			@sets[0]=Changer.new(178,26,['Coin','Fall','Hover','Stone','Ghost'])
			text="<P-Block>^Type:"
			@eq=0
			when :eswitch
			size=[284,108]
			@sets[0]=Changer.new(178,26,['Short','Long'])
			@sets[1]=Counter.new(170,46,0,4)
			@sets[2]=Counter.new(274,46,0,4)
			@sets[3]=Counter.new(362,46,0,4)
			@sets[4]=Check.new(196,66,false)
			@sets[5]=Check.new(196,86,false)
			text="<!-Switch>^Time:^Red:              Green:             Blue:^Anchor:^Once:"
			@eq=3
			when :objectblock
			size=[510,210]
			@sets[0]=Changer.new(178,26,['Climb','?-Switch','P-Switch','!-Switch','Key','Spring','POW','MOb','A-BOMB'])
			@sets[1]=Tileselector.new(178,46,Img['tiles/climb'],[32,32]) #Skin
			@sets[2]=Counter.new(240,106,0,9999) #Id
			@sets[3]=Counter.new(242,126,0,9999) #Phantos
			@sets[4]=Counter.new(400,126,0,9999) #Phanto Speed
			@sets[5]=Changer.new(242,146,['Green','Blue','Red']) #Type
			@sets[6]=Counter.new(214,166,0,4) #Red
			@sets[7]=Counter.new(316,166,0,4) #Green
			@sets[8]=Counter.new(407,166,0,4) #Blue
			@sets[9]=Changer.new(496,166,['Short','Long']) #Time
			@sets[10]=Check.new(594,166,false) #Anchor
			@sets[11]=Check.new(180,186,false) #Once
			@sets[12]=Check.new(346,186,false) #Hidden
			@sets[13]=Counter.new(326,46,0,9999) #Length
			@sets[14]=Check.new(440,46,false) #Through
			@sets[15]=Check.new(338,106,false) #Still
			@sets[16]=Counter.new(426,106,-1,9999) #TrN
			@sets[17]=Counter.new(560,106,-1,9999) #TrF
			text="<Object Block>^Item:^Climb:                    Length:              Through:^^^?-Switch//Id:             Still:    Trig. On:             Trig. Off:^Key//Phantos:             Phanto Speed:^Spring//Type:      ^All//Red:              Green:              Blue:            Time:          Anchor:^Once:           //Block Hidden:"
			@eq=8
			when :saveflag
			size=[108,32]
			text="<Save Flag>"
			@eq=0
			when :text
			size=[510,52]
			@sets[0]=TextField.new(178,26,999,450)
			text="<Text Block>^Text:"
			@eq=0
			when :flip
			size=[108,52]
			@sets[0]=Counter.new(186,26,0,100)
			if !@seted then @sets[0].val=4 end
			text="<Flip Block>^Flips:"
			@eq=0
			when :skull
			size=[108,72]
			@sets[0]=Counter.new(186,26,0,9999)
			@sets[1]=Check.new(186,46,false)
			if !@seted then @sets[1].val=true end
			text="<Skull Block>^Id:^Exist:"
			@eq=0
			when :shell
			size=[108,56]
			@sets[0]=Changer.new(186,26,['Green','Red','Black'])
			text="<Shell>^Skin:"
			@eq=0
			when :passtype
			size=[174,88]
			@sets[0]=Counter.new(160,26,0,9999)
			@sets[1]=Counter.new(190,46,0,9999)
			@sets[2]=TextField.new(190,66,48,80)
			text="<Password Block-Type>^Id:^Index:^Chars:"
			@eq=0
			when :passcheck
			size=[174,88]
			@sets[0]=Counter.new(160,26,0,9999)
			@sets[1]=TextField.new(214,46,99,80)
			text="<Password Block-Check>^Id:^Password:"
			@eq=0
			when :trigswitcher
			size=[174,108]
			@sets[0]=Counter.new(196,26,0,9999)
			@sets[1]=Counter.new(196,46,0,9999)
			@sets[2]=Check.new(196,66,false)
			@sets[3]=Check.new(196,86,false)
			text="<Trigger-switcher>^On id:^Off id:^On:^Hidden:"
			@eq=0
			when :light
			size=[174,108]
			@sets[0]=Changer.new(196,26,['Static','Block'])
			@sets[1]=Counter.new(196,46,1,99)
			@sets[2]=Check.new(196,66,true)
			@sets[3]=Counter.new(220,86,0,9999)
			text="<Light>^Type:^Radius:^?Switch:^?Switch id:"
			@eq=0
			when :brosblock
			size=[120,32]
			text="<Bros. Block>"
			@eq=0
			
			when :goomba
			size=[118,68]
			text="<Goomba>^Skin:^Direction:"
			@sets[0]=Changer.new(184,26,['Brown','Blue','Grey'])
			@sets[1]=Changer.new(218,46,['Left','Right'])
			@eq=0
			when :koopatroopa
			size=[154,136]
			text="<Koopa Troopa>^Smart:^Direction:^Movement:^Move Value:^Speed:"
			@sets[0]=Check.new(180,26,false)
			@sets[1]=Changer.new(216,46,['Left','Right'])
			@sets[2]=Changer.new(214,66,['Walk','Jump','Fly Hor','Fly Ver'])
			@sets[3]=Counter.new(226,86,0,1000)
			@sets[4]=Counter.new(188,106,1,25)
			if !@seted then @sets[4].val=2 end
			@eq=6
			when :piranhaplant
			size=[136,170]
			text="<Piranha Plant>^Type:^Direction:^Length:^Delay:^Speed:^Attack:^Penetrating:"
			@sets[0]=Changer.new(180,26,['Normal','Still','Shoot','Aim'])
			@sets[1]=Changer.new(216,46,['Up','Down','Left','Right'])
			@sets[2]=Counter.new(198,66,0,100)
			if !@seted then @sets[2].val=1 end
			@sets[3]=Counter.new(198,86,0,120)
			if !@seted then @sets[3].val=2 end
			@sets[4]=Counter.new(198,106,0,250)
			if !@seted then @sets[4].val=2 end
			@sets[5]=Counter.new(198,126,0,250)
			@sets[6]=Check.new(230,146,false)
			@eq=8
			when :spiny
			size=[116,68]
			text="<Spiny>^Stone:^Direction:"
			@sets[0]=Check.new(182,26,false)
			@sets[1]=Changer.new(216,46,['Left','Right'])
			@eq=0
			when :buzzybeetle
			size=[124,68]
			text="<Buzzy Beetle>^Ceiling:^Direction:"
			@sets[0]=Check.new(198,26,false)
			@sets[1]=Changer.new(216,46,['Left','Right'])
			when :bowser
			size=[150,245]
			text="<Bowser>^Speed:^Jumpness:^Action freq:^ Single shot^ Triple shot^ Hammer rain^ Crushing punch^ Meteor^ Fireballs^ Cannon^ Homing bullet"
			@sets[0]=Counter.new(230,26,0,15)
			if !@seted then @sets[0].val=2 end
			@sets[1]=Counter.new(230,46,0,25)
			if !@seted then @sets[1].val=15 end
			@sets[2]=Counter.new(230,66,0,100)
			if !@seted then @sets[2].val=10 end
			@sets[3]=Check.new(250,86,false)
			if !@seted then @sets[3].val=true end
			@sets[4]=Check.new(250,106,false)
			@sets[5]=Check.new(250,126,false)
			@sets[6]=Check.new(250,146,false)
			@sets[7]=Check.new(250,166,false)
			@sets[8]=Check.new(250,186,false)
			@sets[9]=Check.new(250,206,false)
			@sets[10]=Check.new(250,226,false)
			@sets[5].val=@sets[6].val=@sets[7].val=@sets[8].val=nil
			@eq=9
			when :bullet_bill
			size=[124,192]
			text="<Bullet Bill>^Type:^Spec:^Height:^Delay:^Dir:^Stand^Random:^Attack:"
			@sets[0]=Changer.new(200,26,['Off','Bullet','Flame'])
			if !@seted then @sets[0].val=1 end
			@sets[1]=Check.new(200,46,false)
			@sets[2]=Counter.new(200,66,0,50)
			if !@seted then @sets[2].val=2 end
			@sets[3]=Counter.new(200,86,1,100)
			if !@seted then @sets[3].val=10 end
			@sets[4]=Changer.new(200,106,['Left','Rigth','Rand','Aim'])
			@sets[5]=Changer.new(200,126,['Down','Up'])
			@sets[6]=Check.new(200,146,false)
			@sets[7]=Counter.new(200,166,1,25)
			if !@seted then @sets[7].val=4 end
			@eq=0
			when :rotor
			size=[132,136]
			text="<Rotor>^Radius:^Speed:^Dir:^Count:^Type:"
			@sets[0]=Counter.new(196,26,1,100)
			if !@seted then @sets[0].val=8 end
			@sets[1]=Counter.new(196,46,1,50)
			if !@seted then @sets[1].val=2 end
			@sets[2]=Changer.new(196,66,['Clockwise','Counterclockwise'])
			@sets[3]=Counter.new(196,86,1,15)
			@sets[4]=Changer.new(196,106,['Disc','Fire'])
			@eq=0
			when :podobo
			size=[132,52]
			text="<Podobo>^Delay:"
			@sets[0]=Counter.new(196,26,1,100)
			if !@seted then @sets[0].val=6 end
			@eq=10
			when :proj
			size=[132,92]
			text="<Projectile>^Type:^Speed:^Dir:"
			@sets[0]=Changer.new(196,26,['Fire','Bullet','Banzai'])
			@sets[1]=Counter.new(196,46,1,50)
			if !@seted then @sets[1].val=4 end
			@sets[2]=Changer.new(196,66,['Left','Right'])
			@eq=8
			when :cheepcheep
			size=[132,92]
			text="<Cheep-Cheep>^Type:^Speed:^Dir:"
			@sets[0]=Changer.new(196,26,['Normal','Stone','Homing'])
			@sets[1]=Counter.new(196,46,1,50)
			if !@seted then @sets[1].val=3 end
			@sets[2]=Changer.new(196,66,['Left','Right'])
			@eq=0
			when :pokey
			size=[132,112]
			text="<Pokey>^Type:^Moving:^Height:^Regen:"
			@sets[0]=Changer.new(196,26,['Green','Yellow'])
			@sets[1]=Counter.new(196,46,0,50)
			@sets[2]=Counter.new(196,66,0,99)
			if !@seted then @sets[2].val=4 end
			@sets[3]=Counter.new(196,86,1,9999)
			if !@seted then @sets[3].val=8 end
			@eq=11
			when :boo
			size=[132,132]
			text="<Boo>^Skin:^Dir:^Ai:^Speed:^Type:"
			@sets[0]=Changer.new(196,26,['Scared','Crazy','Angry','Big','Balloon'])
			@sets[1]=Changer.new(196,46,['Left','Right'])
			@sets[2]=Changer.new(196,66,['Free','Active','Hide and seek','Escape'])
			@sets[3]=Counter.new(196,86,0,25)
			if !@seted then @sets[3].val=1 end
			@sets[4]=Changer.new(196,106,['Normal','Scenery','Transparent','Glowing','Disappearing'])
			@eq=0
			when :hammbro
			size=[132,72]
			text="<Hammer Bros>^Type:^Attack:"
			@sets[0]=Changer.new(196,26,['Hammer','Boomerang','Fireball'])
			@sets[1]=Counter.new(196,46,1,50)
			if !@seted then @sets[1].val=3 end
			@eq=12
		
			when :warp
			size=[184,128]
			@sets[0]=Changer.new(178,26,['Up','Down','Right','Left','Door'])
			@sets[1]=Counter.new(164,46,0,999)
			@sets[2]=Check.new(292,46,true)
			@sets[3]=Check.new(172,66,false)
			@sets[4]=Check.new(196,86,true)
			@sets[5]=Counter.new(220,104,0,9999)
			@eq=1
			text="<Warp>^Type:^Id:              Exit only: ^Mini: ^?Switch:^?Switch id:"
			when :spec
			size=[264,170]
			@sets[4]=Changer.new(232,26,['Water','Lava'])
			@sets[0]=Counter.new(240,46,0,@level['rooms'][@room.val]['height'])
			@sets[1]=Changer.new(232,66,['Clean','Ocean','Dark','Waves','Dirty','Sunset','Ghost','Swamp'])
			@sets[2]=Counter.new(232,86,0,50)
			if !@seted then @sets[2].val=10 end
			@sets[3]=Changer.new(320,66,['Surface','Volcano','Underground','Acid','Poison'])
			@sets[5]=Check.new(232,106,false)
			@sets[6]=Counter.new(232,126,0,999)
			@sets[7]=Counter.new(232,146,0,999)
			@eq=2
			text="<Room Specjal Properties>^Liquid:^Liquid level:^Skin//Water:           Lava:^Gravity:^Upper Solid:^Min width:^Min height:"
			when :level
			size=[240,128]
			@sets[0]=TextField.new(238,26,16,116)
			@sets[1]=TextField.new(238,46,16,116)
			@sets[2]=TextField.new(238,66,100,116)
			@sets[3]=TextField.new(238,86,8,116)
			@sets[4]=Check.new(248,106,false)
			@sets[5]=Check.new(328,106,false)
			@eq=2
			text="<Level Properties>^Next level:^Secret level:^Thumbnail:^Password:^Left//Finnish:      Secret:"
			when :platform
			size=[150,95]
			@sets[0]=Check.new(196,26,false)
			@sets[1]=Check.new(196,46,true)
			@sets[2]=Counter.new(220,66,0,9999)
			@eq=8
			text="<Platform>^Down:^?Switch:^?Switch id:"
			when :trigger
			size=[130,108]
			@sets[0]=Counter.new(196,26,0,9999)
			@sets[1]=Counter.new(196,46,1,1000)
			@sets[2]=Counter.new(196,66,1,1000)
			@sets[3]=Check.new(196,86,false)
			if !@seted then @sets[3].val=true end
			@eq=8
			text="<Trigger>^Id:^Width:^Height:^Once:"
			when :rampage
			size=[148,72]
			@sets[0]=Counter.new(224,26,0,9999)
			@sets[1]=Changer.new(224,46,['1','2'])
			@eq=8
			text="<Rampage Control>^Trigger:^Music:"
			when :spawn
			size=[148,136]
			@sets[0]=Counter.new(190,26,0,9999)
			@sets[1]=Counter.new(190,46,0,9999)
			@sets[2]=Counter.new(190,66,0,9999)
			@sets[3]=Press.new(136,86,'Add enemy')
			@sets[4]=Press.new(200,86,'Delete enemy')
			@sets[5]=[]
			@eq=8
			text="<Enemy Spawner>^Id:^Max:^Delay:"
			when :boss
			size=[148,136]
			@sets[0]=Counter.new(196,26,0,9999)
			@sets[1]=Changer.new(190,46,['1','2','3'])
			@sets[2]=Counter.new(196,66,1,40)
			if !@seted then @sets[2].val=5 end
			@sets[3]=Check.new(200,86,false)
			@sets[4]=Check.new(200,106,true)
			@eq=8
			text="<Boss Control>^Id:^Music:^Health:^Rampage:^Finnish:"
			when :liqctrl
			size=[170,176]
			@sets[0]=Counter.new(244,26,0,9999)
			@sets[1]=Changer.new(244,46,['Water','Lava'])
			@sets[2]=Changer.new(244,66,['Clean','Ocean','Dark','Waves','Dirty','Sunset','Ghost','Swamp'])
			@sets[3]=Changer.new(244,86,['Surface','Volcano','Underground','Acid','Poison'])
			@sets[4]=Counter.new(244,106,0,1000)
			@sets[5]=Changer.new(244,126,['Set','Add','Subtract'])
			@sets[6]=Counter.new(244,146,-100,1000)
			if !@seted then @sets[6].val=1 end
			@eq=8
			text="<Liquid Control>^Trigger id:^Type:^Skin water:^Skin lava:^Level Change:^Change:^Change timing:"
			when :sizectrl
			size=[170,126]
			@sets[0]=Counter.new(244,26,0,9999)
			@sets[1]=Counter.new(244,46,0,19200)
			@sets[2]=Changer.new(244,66,['Width','Min X','Height','Min Y'])
			@sets[3]=Changer.new(244,86,['Set','Add','Subtract'])
			@sets[4]=Counter.new(244,106,-100,1000)
			if !@seted then @sets[4].val=1 end
			@eq=8
			text="<Size Control>^Trigger id:^Value:^Type:^Change:^Change timing:"
		end
    return if size==[0,0]
		@seted=true
		@setwindow=Panel.new(130,0,size[0],size[1])
		@text=text
		@level['rooms'][@room.val]['objects'].delete(@probject) if @objmode==:place
		
		if !@select then i=0
		@sets.length.times{
		if ![Press,Array].include?(@sets[i].class)
			@sets[i].val=@probject.props[i]
		elsif @sets[i].class==Array
			@sets[i]=@probject.props[i]
		end
		i+=1} end
	end
	
	def seltype
		case @mode
			when :tiles
			case @select
				when [0,0]
				:block
				when [1,0]
				:pipe
				when [2,0]
				:grass
				when [3,0]
				:ground
				when [4,0]
				:climb
				when [5,0]
				:ice
				when [6,0]
				:water
				when [0,1]
				:sand
				when [1,1]
				:land
				when [2,1]
				:cloud
				when [3,1]
				:factory
				when [4,1]
				:castle
				when [5,1]
				:mini
				when [6,1]
				:lava
				when [0,2]
				:wall
				when [1,2]
				:bonus
				when [2,2]
				:quick
				when [3,2]
				:pyramid
				when [4,2]
				:scenery
				when [5,2]
				:animscen
				when [6,2]
				:wooden
				when [0,3]
				:underwater
				when [1,3]
				:ghost
				when [2,3]
				:spikes
			end
			
			when :objects
			case @select
				when [0,0]
				:bricks
				when [1,0]
				:powerupblock
				when [2,0]
				:coin
				when [3,0]
				:onoff
				when [4,0]
				:changing
				when [5,0]
				:qswitch
				when [6,0]
				:door
				when [0,1]
				:key
				when [1,1]
				:spring
				when [2,1]
				:pswitch
				when [3,1]
				:pblock
				when [4,1]
				:eswitch
				when [5,1]
				:objectblock
				when [6,1]
				:saveflag
				when [0,2]
				:text
				when [1,2]
				:flip
				when [2,2]
				:skull
				when [3,2]
				:shell
				when [4,2]
				:passtype
				when [5,2]
				:passcheck
				when [6,2]
				:trigswitcher
				when [0,3]
				:light
				when [1,3]
				:brosblock
			end
			
			when :enemies
			case @select
				when [0,0]
				:goomba
				when [1,0]
				:koopatroopa
				when [2,0]
				:piranhaplant
				when [3,0]
				:spiny
				when [4,0]
				:buzzybeetle
				when [5,0]
				:bowser
				when [6,0]
				:bullet_bill
				when [0,1]
				:rotor
				when [1,1]
				:podobo
				when [2,1]
				:proj
				when [3,1]
				:cheepcheep
				when [4,1]
				:pokey
				when [5,1]
				:boo
				when [6,1]
				:hammbro
			end
			
			when :specjal
			case @select
				when [0,0]
				:warp
				when [1,0]
				:platform
				when [2,0]
				:trigger
				when [3,0]
				:rampage
				when [4,0]
				:spawn
				when [5,0]
				:boss
				when [6,0]
				:liqctrl
				when [0,1]
				:sizectrl
			end
		end
	end
	
	def button_down(id,mx,my)
		if id==KbReturn and File.exists?("data/#{if (t=@name.val.split('/')).length==1 then "own_levels" else "worlds" end}/#{t[0]}.mlv") then $temp=self and Game.new("#{if t.length==1 then "own_levels" else "worlds" end}/#{t[0]}") and $thumb=TexPlay.create_blank_image($screen,160,120) end
		if not $screen.text_input
			if id==Kb1 then @visible[0]=!@visible[0] end
			if id==Kb2 then @visible[1]=!@visible[1] end
			if id==Kb3 then @visible[2]=!@visible[2] end
			if id==KbEnd
				@fore.clear
				@bak.clear
				if @room.val==0 then wr=@objects[1] end
				pr=@objects[0]
				@objects.clear
				@objects[0]=pr
				if wr then @objects[1]=wr end
			end
			if id==KbG then @grid=!@grid end
			if id==KbW and not @select || @probject || @setting
				@objects.each{|o| o.unselect}
				@fore.each{|o| o.unselect}
				@bak.each{|o| o.unselect}
				@level['rooms'][0]['objects'][1].select(8,8) and @setting=true elsif id==KbW and @setting
					@probject=@setting=nil
					@level['rooms'][0]['objects'][1].unselect end
			if id==KbQ and not @select || @probject || @setting
				@objects.each{|o| o.unselect}
				@fore.each{|o| o.unselect}
				@bak.each{|o| o.unselect}
				@objects[0].select(8,8) and @setting=true elsif id==KbQ and @setting
					@probject=@setting=nil
					@objects[0].unselect end
			if id==MsRight and !@setting
				@objects.each{|o| o.unselect}
				@fore.each{|o| o.unselect}
				@bak.each{|o| o.unselect}
				@probject=@select=nil
				@objmode=:free
			end
			
			if id==KbP and @probject
				@setting=!@setting
			end
			
			if id==KbC and @objmode==:select and @probject.type != :level
				@probject.unselect
				new=@probject.dup
				new.props=@probject.props.dup
				@probject=new
				@objmode=:place
			end
			
			if id==MsLeft and [:free,:select].include?(@objmode) || Keypress[KbLeftShift] and mx>128 and !@setting
				if @visible[1]
					@objects.each{|o| o.unselect} if !Keypress[KbLeftShift]
					@objects.each{|o| o.select(mx+@scx,my+@scy)}
				end
				if @visible[2]
					@fore.each{|o| o.unselect} if !Keypress[KbLeftShift]
					@fore.each{|o| o.select(mx+@scx,my+@scy)}
				end
				if @visible[0]
					@bak.each{|o| o.unselect} if !Keypress[KbLeftShift]
					@bak.each{|o| o.select(mx+@scx,my+@scy)}
				end
				@sected=nil
			end
			
			if id==KbDelete
				i=0
				while i<@objects.length
					i+=1 if !@objects[i].delete
				end
				i=0
				while i<@bak.length
					i+=1 if !@bak[i].delete
				end
				i=0
				while i<@fore.length
					i+=1 if !@fore[i].delete
				end
			end
			
			if id==MsLeft and mx>128 and @objmode==:start
				@objmode=:free
				s=if @luigi then 'luigi' else 'start' end
				@level[s][0]=16*((mx.to_i+@scx)/16)
				@level[s][1]=16*((my.to_i+@scy)/16)
				@level[s][2]=@room.val
				@luigi=nil
			end
			
			if id==MsLeft and mx>128 and @objmode==:end
				@objmode=:free
				@level['finnish'][0]=32*((mx.to_i+@scx)/32)+8
				@level['finnish'][1]=16*((my.to_i+@scy)/16)+4
				@level['finnish'][2]=@room.val
			end
			
			if id==MsLeft and mx>128 and @objmode==:secret
				@objmode=:free
				@level['alter'][0]=32*((mx.to_i+@scx)/32)+8
				@level['alter'][1]=16*((my.to_i+@scy)/16)+4
				@level['alter'][2]=@room.val
			end
		
			if id==MsLeft and mx>128 and @objmode==:enemy
				@objects.each{|o| if o != @probject and cnd=(o.select(mx+@scx,my+@scy,false)) and [:goomba,:koopatroopa,:piranhaplant,:spiny,:buzzybeetle,:pokey,:cheepcheep,:hammbro].include?(o.type) then
					Snd['choose'].play
					o.unselect
					@sets[5]<<o.dup
					@objmode=@temp and @temp=nil elsif cnd then o.unselect end}
			end
		
			if id==KbM then musicchange end
			if id==KbN then musicchange(true) end
		end
	end

	def clearset
		@panels.delete(@setwindow)
		@sets.each{|s| @system.delete(s)}
		@sets.clear
		@text=nil
	end

	def musicchange(subtract=false)
		if !subtract then if $music<26 then $music+=1 else $music=0 end else if $music>0 then $music-=1 else $music=26 end end
		@mtime=60
		Msc[['Editor.ogg','Overworld.ogg','Underground1.ogg','Underground2.ogg','Underwater1.ogg','Underwater2.ogg','Castle.ogg','Ghost House.ogg','Desert.ogg','Snow.ogg','Beach.ogg','Sky.ogg','Darkland.ogg','Starland.xm','Factory.ogg','Space.ogg','Bonus.ogg','Athletic.ogg','Challenge.s3m','Tanks.xm','Fastrun.xm','Rampage1.ogg','Rampage2.ogg','Boss1.ogg','Boss2.ogg','Boss3.ogg','Invincible.ogg'][$music]].play(true)
	end
end