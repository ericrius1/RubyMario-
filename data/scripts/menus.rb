class Load
	def initialize
		if !File.exists?('data/score.mrh') then Marshal.dump(0,f=File.new('data/score.mrh','w'))
		f.close end
		require Dir.getwd+'/data/scripts/specjal'
		require Dir.getwd+'/data/scripts/editor/main'
		@cur=0
	end
	
	def update
		case @cur
			when 0
			@text='Scripts'
			when 1
			@text='Images'
			scr=Dir.getwd+'/data/scripts/'
			require scr+'specjal'
			require scr+'game'
			require scr+'player'
			require scr+'map'
			require scr+'objects'
			require scr+'enemies'
			require scr+'specs'
			require scr+'effects'
			require scr+'randomizer'

			scr=Dir.getwd+'/data/scripts/editor/'
			require scr+'main'
			require scr+'system'
			when 2
			@text='Music'
			Tls["tiles/grassmask",[32,32],true]
			Tls["tiles/groundmask",[32,32],true]
			Tls["tiles/sandmask",[32,32],true]
			Tls["tiles/pipes_mask",[32,32],true]
			Tls['tiles/icemask',[32,32],true]
			Tls['tiles/landmask',[32,32],true]
			Tls['tiles/factorymask',[32,32],true]
			Tls['tiles/minimask',[32,32],true]
			Tls['tiles/wallmask',[32,32],true]
			Tls['tiles/bonusmask',[32,32],true]
			Tls['tiles/pyramidmask',[32,32],true]
			Tls['tiles/woodenmask',[32,32],true]
			Tls['tiles/underwatermask',[32,32],true]
			Tls['tiles/ghostmask',[32,32],true]
			Tls['tiles/spikemask',[32,32],true]
			Tls['tiles/mask',[32,32],true]
			return @cur+=1
			if ARGV and !ARGV.include?('faster')
				ary=Dir.entries('gfx/backgrounds')
				ary.delete('.')
				ary.delete('..')
				ary.each{|a| Img["backgrounds/#{a}".chop.chop.chop.chop]}
				ary=Dir.entries('gfx/mario')
				ary.delete('.')
				ary.delete('..')
				ary.each{|a| Img["mario/#{a}".chop.chop.chop.chop]}
				ary=Dir.entries('gfx/luigi')
				ary.delete('.')
				ary.delete('..')
				ary.each{|a| Img["luigi/#{a}".chop.chop.chop.chop]}
			end
			Img['editor/cursor']
			Img['editor/zip_bar']
			Img['editor/platform']
			Img['editor/light']
			Tls['editor/warp',[16,16]]
			Tls['editor/check',[16,16]]
			Tls['editor/counter',[15,10]]
			Tls['editor/marks',[16,16]]
			Tls['editor/triggers',[16,16]]
			Tls['editor/liquid',[32,5]]
			Tls['system/star',[20,20]]
			Img['system/frame']
			Img['system/bar']
			Img['system/delebar']
			Img['system/barball']
			Img['system/title']
			Img['system/rem']
			Img['system/MainMenu']
			Img['system/LevelSelect']
			Img['system/selitem']
			Img['system/selected']
			Tls['system/health',[15,30]]
			Img['thumbnails/none']
			Img['thumbnails/random']
			Tls["editor/warp",[16,16]]
			Tls["tiles/climb",[32,32],true]
			Tls["tiles/grass1",[32,32],true]
			Tls["tiles/grass2",[32,32],true]
			Tls["tiles/grass3",[32,32],true]
			Tls["tiles/grass4",[32,32],true]
			Tls["tiles/grass5",[32,32],true]
			Tls["tiles/grass6",[32,32],true]
			Tls["tiles/grass7",[32,32],true]
			Tls["tiles/ground1",[32,32],true]
			Tls["tiles/ground2",[32,32],true]
			Tls["tiles/ground3",[32,32],true]
			Tls["tiles/ground4",[32,32],true]
			Tls["tiles/ground5",[32,32],true]
			Tls["tiles/ground6",[32,32],true]
			Tls["tiles/ground7",[32,32],true]
			Tls["tiles/ground8",[32,32],true]
			Tls["tiles/sand",[32,32],true]
			Tls["tiles/pipes",[32,32],true]
			Tls["tiles/pipes",[64,64]]
			Tls["tiles/pipes_flashing",[32,32],true]
			Tls["tiles/water",[32,32],true]
			Tls["tiles/block",[32,32],true]
			Tls['tiles/water_tiles',[32,32],true]
			Tls['tiles/land',[32,32],true]
			Tls['tiles/ice',[32,32],true]
			Tls['tiles/clouds',[32,32],true]
			Tls['tiles/factory',[32,32],true]
			Tls['tiles/castle1',[32,32],true]
			Tls['tiles/castle2',[32,32],true]
			Tls['tiles/castle3',[32,32],true]
			Tls['tiles/castle4',[32,32],true]
			Tls['tiles/castlecovers',[32,32],true]
			Tls['tiles/mini',[32,32],true]
			Tls['tiles/lava',[32,32],true]
			Tls['tiles/lavatiles',[32,32],true]
			Tls['tiles/wall1',[32,32],true]
			Tls['tiles/wall2',[32,32],true]
			Tls['tiles/wall3',[32,32],true]
			Tls['tiles/wall4',[32,32],true]
			Tls['tiles/bonus',[32,32],true]
			Tls['tiles/quick',[32,32],true]
			Tls['tiles/pyramid',[32,32],true]
			Tls['tiles/scenery',[32,32],true]
			Tls['tiles/anim_scen',[32,32],true]
			Tls['tiles/wooden',[32,32],true]
			Tls['tiles/underwater',[32,32],true]
			Tls['tiles/ghost',[32,32],true]
			Tls['tiles/spikes',[32,32],true]
			Tls["bonus/powerups",[32,32]]
			Tls["bonus/coin",[32,32]]
			Tls["bonus/star",[32,32]]
			Tls['bonus/flower',[32,32]]
			Img['objects/anchor']
			Tls["objects/bricks",[32,32]]
			Tls['objects/bricks',[16,8]]
			Tls["objects/powerupblock",[32,32]]
			Tls["objects/changes",[32,32]]
			Tls["objects/changes-const",[32,32]]
			Tls["objects/switches",[24,24]]
			Tls['objects/door',[54,80]]
			Tls['objects/door_anim',[54,80]]
			Tls['objects/minidoor_anim',[54,80]]
			Img['objects/lock']
			Img['objects/lock-const']
			Img['objects/key']
			Img['objects/key-const']
			Tls['objects/saveflag',[32,64]]
			Tls['objects/spring',[32,32]]
			Tls['objects/blocks',[32,32]]
			Tls['objects/flipblock',[32,32]]
			Tls['objects/passwordblock',[32,32]]
			Tls['objects/finnish_pole',[16,300]]
			Tls['objects/finnish_flag',[32,32]]
			Tls['enemies/goomba',[32,32]]
			Tls['enemies/koopa troopa',[32,48]]
			Tls['enemies/shell',[32,32]]
			Img['enemies/frozen']
			Tls['enemies/piranha plant head',[32,32]]
			Tls['enemies/piranha plant rest',[32,16]]
			Tls['enemies/piranha plant rest',[16,32]]
			Tls['enemies/spiny',[32,32]]
			Tls['enemies/buzzy beetle',[32,32]]
			Tls['enemies/bowser',[64,70]]
			Tls['enemies/fire',[68,30]]
			Tls['enemies/blaster',[32,32]]
			Tls['enemies/bullet bill',[32,28]]
			Tls['enemies/phanto',[32,32]]
			Tls['enemies/rotodisc',[32,32]]
			Tls['enemies/podobo',[28,32]]
			Tls['enemies/cheep cheep',[32,32]]
			Tls['enemies/pokey',[48,48]]
			Tls['enemies/boo',[32,32]]
			Tls['enemies/bigboo',[144,128]]
			Tls['enemies/hammerbros',[32,68]]
			Img['enemies/banzai bill']
			Img['enemies/balloonboo']
			Tls['projectiles/bomb',[28,38]]
			Tls['projectiles/explosion',[192,128]]
			Tls['projectiles/beet',[27,32]]
			Img['projectiles/fireball']
			Img['projectiles/firepop']
			Img['projectiles/wandblast']
			Img['projectiles/hammer']
			Img['projectiles/boomerang']
			Tls['effects/extralife',[38,16]]
			Tls['effects/poof',[48,48]]
			Tls['effects/splash',[32,32]]
			Tls['effects/splava',[84,26]]
			Tls['effects/bubble',[7,7]]
			Tls['effects/shellbounce',[40,40]]
			Img['effects/rain']
			Img['effects/rain+']
			Tls['effects/snow',[8,8]]
			Tls['effects/snow+',[16,16]]
			Tls['effects/thunder',[32,240]]
			Tls['effects/sandS',[2,2]]
			Tls['effects/sandM',[16,16]]
			Tls['effects/sandL',[32,32]]
			Tls['effects/fog',[64,32]]
			Img['effects/fog+']
			Img['effects/underwater']
			Img['effects/broken']
			when 3
			@text='Sounds'
			ary=Dir.entries('music')
			ary.delete('.')
			ary.delete('..')
			ary.each{|a| Msc[a]}
			when 4
			@text='Menu'
			ary=Dir.entries('sfx')
			ary.delete('.')
			ary.delete('..')
			ary.each{|a| Snd[a.chop.chop.chop.chop]}
			when 5
			$game=Mainmenu.new
		end
		@cur+=1
	end
	
	def draw
		Fnt['fonts/NINE.ttf',32].draw("Loading: #{@text}",0,448,0)
	end
	
	def button_down(id)
	end
end

class BetweenLevels
	def initialize(thumb,level)
		Song.current_song.stop if Song.current_song
		@thumb,@level,@time=thumb,level,10
		$thumb=@thumb
	end

	def update
		if @time>0 then @time-=1 else Game.new(if @level.class==String then @level else Randomizer.new.name end) end
	end

	def draw
		Fnt['fonts/NINE.ttf',20].draw("Mario x #{$lives}",16,16,0)
		Fnt['fonts/NINE.ttf',20].draw($points,16,48,0)
		Tls["bonus/coin",[32,32]][0].draw(16,82,0,0.5,0.5)
		Fnt['fonts/NINE.ttf',20].draw(" x #{$coins}",32,80,0)
		Fnt['fonts/NINE.ttf',32].draw("Loading - #{if @level.class==String then @level.split('/')[1] else 'Randomized level' end}",0,448,0)
		@thumb.draw(240,180,0)
	end
	
	def button_down(id)
	end
end

class Mainmenu
	def initialize
		Msc['Menu.ogg'].play(true)
		@sel=@max=0
		$keys=Marshal.load(f=File.open('data/keys.mkc','r'))
		@keyed=$keys.dup
		f.close
		keys
	end
	
	def update
	end
	
	def draw
		Img['system/MainMenu'].draw(0,0,0)
		Img['system/title'].draw(136,16,0)
		n=255
		y=128
		if not @controls || @credits
			Text[320,230,1,'start',1,20,20,0,if @sel==0 then n else y end,:center]
			Text[320,260,1,'controls',1,20,20,0,if @sel==1 then n else y end,:center]
			Text[320,290,1,'editor',1,20,20,0,if @sel==2 then n else y end,:center]
			Text[320,320,1,'credits',1,20,20,0,if @sel==3 then n else y end,:center]
			Text[320,350,1,'quit',1,20,20,0,if @sel==4 then n else y end,:center]
		elsif @controls
			Text[230,208,1,"up (#{if @newkey != 'up' then key($keys['up']) else "press new key" end})",1,20,20,0,if @sel==0 then n else y end]
			Text[190,238,1,"down (#{if @newkey != 'down' then key($keys['down']) else "press new key" end})",1,20,20,0,if @sel==1 then n else y end]
			Text[190,268,1,"left (#{if @newkey != 'left' then key($keys['left']) else "press new key" end})",1,20,20,0,if @sel==2 then n else y end]
			Text[170,298,1,"right (#{if @newkey != 'right' then key($keys['right']) else "press new key" end})",1,20,20,0,if @sel==3 then n else y end]
			Text[190,328,1,"jump (#{if @newkey != 'jump' then key($keys['jump']) else "press new key" end})",1,20,20,0,if @sel==4 then n else y end]
			Text[170,358,1,"shoot (#{if @newkey != 'shoot' then key($keys['shoot']) else "press new key" end})",1,20,20,0,if @sel==5 then n else y end]
			Text[190,388,1,"item (#{if @newkey != 'item' then key($keys['item']) else "press new key" end})",1,20,20,0,if @sel==6 then n else y end]
			Text[200,418,1,"accept",1,20,20,0,if @sel==7 then n else y end]
			Text[340,418,1,"cancel",1,20,20,0,if @sel==8 then n else y end]
		else
			Text[320,180,1,"Credits",1.5,30,20,0,255,:center]
			Text[50,220,1," Game made by Tomek Chabora <so me>^and all scripts are mine.^Sprites are from different Mario^series, but most of them I've got^from Super Mario War. Others are^from SpritersResources.com and my^edited.Music from Marios,^Castlevania:DoS, Kirby,^FLaiL and Serious Sam.",0.8,16,18,0,255]
		end
	end
	
	def button_down(id)
		if !@newkey
			if id==KbDown and @sel<if @controls then 8 elsif !@credits then 4 else 0 end then @sel+=1 and Snd['select'].play end
			if id==KbUp and @sel>0 then @sel-=1 and Snd['select'].play end
			if id==KbEscape and @controls then Snd['cancel'].play and $keys=@keyed.dup and @sel=0 and @controls=nil end
			if id==KbEscape and @credits then Snd['cancel'].play and @credits=nil end
			if id==KbReturn and !@controls
				Snd['choose'].play
				case @sel
					when 0
					$game=LevelSelect.new
					when 1
					@sel=0
					@controls=true
					when 2
					Editor.new
					when 3
					@sel=0
					@credits=true
					when 4
					$screen.close
				end
			elsif id==KbReturn
				Snd['choose'].play
				if @sel<7
					@newkey=['up','down','left','right','jump','shoot','item'][@sel]
				else
					if @sel==7
						@keyed=$keys.dup
						Marshal.dump($keys,f=File.open('data/keys.mkc','w'))
						f.close
					else
						$keys=@keyed.dup
					end
					@controls=nil
					@sel=0
				end
			end
		else
			$keys[@newkey]=id
			@newkey=nil
		end
	end
	
	def key(val)
		@keys.each{|k|
		if Gosu.const_get(k)==val
		@return=k and break end}
		@return.to_s
	end
	
	def keys
		@keys=Gosu.constants
		@keys.delete(:VERSION)
		@keys.delete(:MAJOR_VERSION)
		@keys.delete(:MINOR_VERSION)
		@keys.delete(:POINT_VERSION)
		@keys.delete(:Color)
		@keys.delete(:Font)
		@keys.delete(:GLTexInfo)
		@keys.delete(:Image)
		@keys.delete(:SampleInstance)
		@keys.delete(:Sample)
		@keys.delete(:Song)
		@keys.delete(:KbRangeBegin)
		@keys.delete(:KbRangeEnd)
		@keys.delete(:MsRangeBegin)
		@keys.delete(:MsRangeEnd)
		@keys.delete(:GpRangeBegin)
		@keys.delete(:GpRangeEnd)
		@keys.delete(:NoButton)
		@keys.delete(:Button)
		@keys.delete(:Window)
		@keys.delete(:TextInput)
	end
end

class LevelSelect
	def initialize
		@sel=@max=0
		@mode=:type
		@del=144
	end
	
	def update
		$randomized=nil
	end
	
	def draw
		Img['system/LevelSelect'].draw(0,0,0)
		n=255
		y=128
		case @mode
			when :type
			@max=3
			Text[320,230,1,'start game',1,20,20,0,if @sel==0 then n else y end,:center]
			Text[320,260,1,'custom level',1,20,20,0,if @sel==1 then n else y end,:center]
			Text[320,290,1,'random level',1,20,20,0,if @sel==2 then n else y end,:center]
			Text[320,320,1,'back',1,20,20,0,if @sel==3 then n else y end,:center]
			Text[10,450,1,"random highscore: #{Marshal.load(f=File.new('data/score.mrh','r'))}",1,20,20,0,255]
			f.close
		
			when :prof
			Text[320,190,1,'select profile',1.5,30,20,0,n,:center]
			p=0
			@f=Dir.entries('data/profiles')
			@f.delete('.')
			@f.delete('..')
			@f.each{|t| t.chop!.chop!.chop!.chop!}
			@max=@f.length+1
			@f.length.times{Text[320,240+p*30,1,@f[p],1,20,20,0,if @sel==p then n else y end,:center]
			p+=1}
			Text[320,240+p*30,1,'new',1,20,20,0,if @sel==@f.length then n else y end,:center]
			Text[320,270+p*30,1,'back',1,20,20,0,if @sel==@f.length+1 then n else y end,:center]
			Text[20,455,1,'hold Delete to remove',1,20,20,0,255] if @sel<@max-1
			$screen.text_input.draw(p) if $screen.text_input
			if Keypress[KbDelete] and @sel<@max-1 and @del>0
				@del-=2
				Img['system/delebar'].draw(460,457,0)
				Img['system/barball'].draw(460+(144-@del),457,0)
			elsif Keypress[KbDelete] and @sel<@max-1
				@del=144
				Snd['breakblock'].play
				File.delete("data/profiles/#{@f[@sel]}.mup")
				@f.delete_at(@sel)
			else
				@del=144
			end
			
			when :promenu
			@max=3
			Text[320,190,1,$profile['name'],1.5,30,20,0,n,:center]
			Text[320,230,1,'start world',1,20,20,0,if @sel==0 then n else y end,:center]
			Text[320,260,1,'bonus levels',1,20,20,0,if @sel==1 then n else y end,:center]
			Text[320,290,1,'choose item',1,20,20,0,if @sel==2 then n else y end,:center]
			Text[320,320,1,'back',1,20,20,0,if @sel==3 then n else y end,:center]
			Text[20,440,1,"Best score: #{$profile['record']}",1,20,20,0,255]
		
			when :world
			@max=$profile['worlds'].length
			Text[320,96,1,'select world',1.5,30,20,0,n,:center]
			i=0
			@max.times{
			Text[320,150+i*22,1,"world #{i+1}",1,20,20,0,if @sel==i then n else y end,:center]
			j=-1
			5.times{j+=1 and Tls['system/star',[20,20]][1].draw(420+j*20,150+i*22,1)}
			j=-1
			($profile['worlds'][i]/20).to_i.times{j+=1 and Tls['system/star',[20,20]][0].draw(420+j*20,150+i*22,1)}
			i+=1}
			Text[320,160+i*22,1,"back",1,20,20,0,if @sel==@max then n else y end,:center]
			
			when :bonus
			@ar=['Demo','Murky Cave']
			@rq=[4,10]
			@max=@ar.length
			Text[320,96,1,'select level',1.5,30,20,0,n,:center]
			i=0
			@max.times{
			Text[320,150+i*22,1,if $profile['gcoins']>=@rq[i] then @ar[i] else '???' end,1,20,20,0,if @sel==i then n else y end,:center]
			i+=1}
			Text[320,160+i*22,1,"back",1,20,20,0,if @sel==@max then n else y end,:center]
			Text[40,440,1,"#{$profile['gcoins']}#{if @sel<@max then "/#{@rq[@sel]}" end}",1,20,20,0,255]
			Tls['bonus/coin',[32,32]][4+$count/8%4].draw(8,428,1)
			
			when :item
			i=-1
			@ar=[Proc.new{@start[0]=:small},Proc.new{@start[0]=:normal},Proc.new{@start[0]=:fire},Proc.new{@start[1]=5},Proc.new{@start[0]=:beet}]
			@rq=[0,5,10,15,20,25,30,35,40,45,50,55,60,65]
			@max=12
			12.times{i+=1 and Tls["objects/powerupblock",[32,32]][$count/8%4].draw(32+i*48,240,1)
			if $profile['bcoins']>=@rq[i] then Tls["objects/powerupblock",[32,32]][4].draw(32+i*48,240,1)
				Tls["bonus/powerups",[32,32]][[0,1,9,2,12][i]].draw(32+i*48,240,1) end}
			if @sel>0 then Img['system/selitem'].draw(28+(@sel-1)*48,236,1) end
			Img['system/selected'].draw(38+(@start[2])*48,202,1)
			Text[32,280,1,"back",1,20,20,0,if @sel==0 then n else y end]
			Text[40,440,1,"#{$profile['bcoins']}#{if @sel>0 then "/#{@rq[@sel-1]}" end}",1,20,20,0,255]
			Tls['bonus/coin',[32,32]][8+$count/8%4].draw(8,428,1)
			Tls["mario/#{['small','normal','fire','small','beet'][@start[2]]}",[32,64]][0].draw(16,16,1)
			Text[48,42,1," x #{@start[1]}",1,20,20,0,255]
			
			when :own
			Text[320,190,1,'choose level',1.5,30,20,0,n,:center]
			if @sel<@max
				Img['system/bar'].draw(100,240,0)
				Img['system/barball'].draw(100,240+[(@sel*(144.0/if @max>1 then (@max-1).to_f else 1.0 end)),144].min,0)
			end
			Text[20,455,1,'hold Delete to remove',1,20,20,0,255] if @sel<@max
			if Keypress[KbDelete] and @sel<@max and @del>0
				@del-=2
				Img['system/delebar'].draw(460,457,0)
				Img['system/barball'].draw(460+(144-@del),457,0)
			elsif Keypress[KbDelete] and @sel<@max
				@del=144
				Snd['breakblock'].play
				File.delete("data/own_levels/#{@f[@sel]}.mlv")
				@f.delete_at(@sel)
			else
				@del=144
			end
			
			if !@set
				@thumbs=[]
				f=Dir.entries('data/own_levels')
				f.delete('.')
				f.delete('..')
				i=0
				f.length.times{if !((lv=Marshal.load(g=File.open("data/own_levels/#{f[i]}",'r')))['playable'])
					f.delete(f[i])
				else
					f[i].chop!.chop!.chop!.chop!
					i+=1
					if File.exists?("gfx/thumbnails/#{lv['thumbnail']}.png")
						@thumbs << Img["thumbnails/#{lv['thumbnail']}"]
					else
						@thumbs << Img["thumbnails/none"]
					end
				end
				g.close}
				@f=f
				@max=f.length
				@set=true
			end
			
			if @f.length<=5
				p=0
				@f.length.times{Text[320,240+p*35,1,@f[p],1,20,20,0,if @sel==p then n else y end,:center]
				p+=1}
			else
				if @sel>2 then if @sel<@max-2 then p=@sel-2 else p=@sel-(5-(@max-@sel)) end else p=0 end
				5.times{Text[320,240+(if @sel>2 then (p+2+(if @sel<@max-2 then 0 elsif @sel==@max-2 then 1 elsif @sel==@max-1 then 2 else 3 end)-@sel) else p end)*35,1,@f[p],1,20,20,0,if @sel==p then n else y end,:center]
				p+=1}
			end
			Text[320,420,1,'back',1,20,20,0,if @sel==@max then n else y end,:center]
			@thumbs[@sel].draw(16,16,0) if @sel<@max
			Img['system/frame'].draw(14,14,0) if @sel<@max
		end
	end
	
	def button_down(id)
		@wait=nil
		if !$screen.text_input 
			if [KbDown,KbRight].include?(id) and @sel<@max then @sel+=1 and Snd['select'].play end
			if [KbUp,KbLeft].include?(id) and @sel>0 then @sel-=1 and Snd['select'].play end
			if id==KbReturn then func end
			if id==KbEscape and [:prof,:own].include?(@mode)
				Snd['cancel'].play
				@sel=[:prof,:own].index(@mode)
				@mode=:type
			elsif id==KbEscape and [:world,:bonus,:item].include?(@mode)
				Snd['cancel'].play
				@mode=:promenu
				@sel=0
			elsif id==KbEscape and @mode==:promenu
				Snd['cancel'].play
				$profile=nil
				@mode=:prof
				@sel=0
			elsif id==KbEscape
				Snd['cancel'].play
				$game=Mainmenu.new
			end
		end
		if !@wait and id==KbReturn and $screen.text_input then Snd['select'].play
		hsh={'name'=>$screen.text_input.text,'worlds'=>[0.0],'gcoins'=>0,'bcoins'=>0,'collected'=>[],'done'=>[],'record'=>0}
		Marshal.dump(hsh,f=File.new("data/profiles/#{$screen.text_input.text}.mup",'w'))
		f.close
		Snd['newprofile'].play and $screen.text_input=nil end
		if id==KbEscape and $screen.text_input then $screen.text_input=nil
			Snd['cancel'].play end
	end
	
	def func
		Snd['choose'].play
		case [@mode,@sel]
			when [:type,0]
			@mode=:prof
			@sel=0
			when [:type,1]
			@mode=:own
			@sel=0
			@set=nil
			when [:own,@max]
			@mode=:type
			@sel=0
			when [:own,@sel]
			$lives=4
			$points=0
			$coins=0
			$mode=:small
			$temp=self
			$saved=nil
			$game=BetweenLevels.new(@thumbs[@sel],"own_levels/#{@f[@sel]}")
			when [:type,3]
			$game=Mainmenu.new
			when [:type,2]
			$randomized=Marshal.load(f=File.new('data/score.mrh','r'))
			f.close
			$lives=4
			$points=0
			$coins=0
			$mode=:small
			$temp=self
			$saved=nil
			$game=BetweenLevels.new(Img['thumbnails/random'],:random)
			when [:prof,@max-1]
			$screen.text_input=TypeProfile.new
			@wait=true
			when [:prof,@max]
			@mode=:type
			@sel=0
			when [:prof,@sel]
			$profile=Marshal.load(f=File.open("data/profiles/#{@f[@sel]}.mup"))
			f.close
			@start=[:small,4,0]
			@sel=0
			@mode=:promenu
			when [:promenu,0]
			@mode=:world
			@sel=0
			when [:promenu,1]
			@mode=:bonus
			@sel=0
			when [:promenu,2]
			@mode=:item
			@sel=0
			when [:promenu,3]
			$profile=nil
			@mode=:prof
			@sel=0
			when [:world,@max],[:bonus,@max],[:item,0]
			@sel=0
			@mode=:promenu
			when [:world,@sel]
			$points=0
			$coins=0
			$temp=self
			$saved=nil
			$world=@sel
			$mode=:small
			$hold=if @start[0] !=:small then @start[0] else nil end
			$lives=@start[1]
			$game=BetweenLevels.new(Image.new($screen,"data/worlds/thumbs/#{@sel+1}-1.png",false),"worlds/#{@sel+1}-1")
			when [:bonus,@sel]
			if $profile['gcoins']>=@rq[@sel]
				$points=0
				$coins=0
				$temp=self
				$saved=nil
				$world=-1
				$mode=:small
				$hold=if @start[0] !=:small then @start[0] else nil end
				$lives=@start[1]
				$game=BetweenLevels.new(Image.new($screen,"data/worlds/thumbs/#{@ar[@sel]}.png",false),"worlds/#{['1-1 level','murky cave'][@sel]}")
			else
				3.times{Snd['cancel'].play}
			end
			when [:item,@sel]
			reset
		end
	end

	def reset
		if $profile['bcoins']>=@rq[@sel-1]
			@start[0]=:small
			@start[1]=4
			@start[2]=@sel-1
			@ar[@sel-1].call
		else 3.times{Snd['cancel'].play} end
	end
end

class TypeProfile < TextInput
	def initialize
		super
		self.text="New profile"
	end
	
	def draw(p)
		a=362+Fnt['fonts/NINE.ttf',32].text_width(self.text)
		b=240+p*32
		c=0xffffffff
		$screen.draw_quad(a,b,c,a+16,b,c,a+16,b+32,c,a,b+32,c,0) if $count % 32 > 16
		Fnt['fonts/NINE.ttf',32].draw(self.text,360,240+p*32,0)
	end
end