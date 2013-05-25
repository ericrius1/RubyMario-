class Randomizer
	def initialize
		name=[]
		12.times{name << ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','1','2','3','4','5','6','7','8','9','0'][rand(35)]}
		@level={'name'=>name.join,'time'=>-1,'start'=>[0,384-rand(4)*32,0],'finnish'=>[0,116,0],'end'=>[false],'rooms'=>[],'playable'=>true,'password'=>''}
		@newroom=true
		while !@end
			if @newroom
				#,:desert,:castle,:factory,:classic,:cave
				@type=(a=[:hills,:snow,:starland]).shuffle[rand(a.length-1)]#[3]
				back=[['hills2','hills3','hills4','hills6'].shuffle[rand(4)],['snow1','snow2','snow3','snow4','snow5'].shuffle[rand(5)],['starland1','starland2','starland3','starland4','starland5'].shuffle[rand(5)],['cave1','cave2','mine'].shuffle[rand(2)]][id=a.index(@type)]
				music=[0,8,12,1][id]
				weather=[0,[0,3,4][rand(3)],0,0][id]
				upsol=[false,false,false,true][id]
				@level['rooms'] << {'width'=>100+rand(401),'height'=>15,'music'=>music,'weather'=>weather,'dark'=>false,'objects'=>[],'frontlayer'=>[],'backlayer'=>[],'background'=>back}
				@objects=(rs=@level['rooms'])[rs.length-1]['objects']
				@id=rs.length-1
				@x=0
				@y1=if @level['rooms'].length==1 then (480-@level['start'][1]-64)/32 else 1+rand(10)*32 end
				@y2=rand(5)
				
				@level['finnish'][0]=(@level['rooms'][@id]['width']-4)*32+8
				@objects << Obj.new(0,0,:spec,[0,0,10,0,0,upsol,0,0],0)
				@objects << Obj.new(0,0,:level,['','','','',false,false],0)
				@objects << Obj.new((@level['rooms'][@id]['width']-4)*32,416,:block,[0,0,false,0],0)
				@newroom=nil
			end
			case @type
				when :hills,:snow,:starland
				id=[:hills,:snow,:starland].index(@type)
				tiles=[[1,2,3,9,10,11,0,8],[29,30,31,37,38,39],[16,17,18,24,[25,25,32,25,25,33,25,25,34,25,25],26,19,27]][id]
				if !@gap
					if @gap==false then @y1=if @x==(@level['rooms'][@id]['width']-5)*32 then 1 else (y=[@y1+[6,6,6,6,6,6,6,4,2,-2,-6][@prevgap],10].min)-rand(y) end end
					i=0
					(@y1-1).times{@objects << Obj.new(@x,448-i*32,:land,[if @gap==false then tiles[3] else if id==2 then tiles[4][rand(11)] else tiles[4] end end,0,false,0],0) and i+=1}
					@objects << Obj.new(@x,448-i*32,:land,[if @gap==false then tiles[0] else tiles[1] end,0,false,0],0)
				
					construction([0,0,1][id]) if @x>=32 and @x<(@level['rooms'][@id]['width']-6)*32
					
					bonus([0,0,1][id]) if @x<(@level['rooms'][@id]['width']-6)*32
					
					enemy([0,0,0,0,1,1,1,2,3],[0,0,1][id]) if @gap==nil and @x>64 and @x<(@level['rooms'][@id]['width']-6)*32
				
					if @gap==false then @gap=nil end
				elsif @gap==0
					i=0
					(@y1-1).times{@objects << Obj.new(@x,448-i*32,:land,[tiles[5],0,false,0],0) and i+=1}
					@objects << Obj.new(@x,448-i*32,:land,[tiles[2],0,false,0],0)
					@gap+=1
				elsif @gap==:col
					if id !=1
						@y1=if @x==(@level['rooms'][@id]['width']-5)*32 then 1 else (y=[@y1+[6,6,6,6,6,6,6,4,2,-2,-6][@prevgap],10].min)-rand(y) end
						i=0
						(@y1-1).times{@objects << Obj.new(@x,448-i*32,:land,[tiles[7],0,false,0],0) and i+=1}
						@objects << Obj.new(@x,448-i*32,:land,[tiles[6],0,false,0],0)
						@gap=1
					else
						@gap=false
					end
				else
					@gap+=1
				end
				@x+=32
				
				if !@gap and @x<(@level['rooms'][@id]['width']-6)*32
					@gap=[nil,nil,nil,0].shuffle[rand(4)]
				elsif @gap and @gap<[nil,8,8,9,9,9,9,10,10,10,10][@y1]
					@prevgap=@gap
					@gap=if @x==(@level['rooms'][@id]['width']-5)*32 then false else [false,false,false,@gap,@gap,@gap,@gap,if id==1 then false else :col end].shuffle[rand(8)] end
				elsif @gap
					@prevgap=@gap
					@gap=[false,false,false,if id==1 then false else :col end].shuffle[rand(4)]
				end
			
				if @y1!=1 and !@gap and @x==(@level['rooms'][@id]['width']-6)*32 then @gap=0 end
				@end=true if @x>=@level['rooms'][@id]['width']*32
				
				when :cave
				tiles=[5,6,7,13,14,15,21,22,23]
				if !@gap2
					if @gap2==false then @y2=if @x>=(@level['rooms'][@id]['width']-5)*32 then 1 else rand(13-@y1-if @construction then @construction else 0 end) end end
					i=0
					(@y2-1).round.abs.times{@objects << Obj.new(@x,i*32,:land,[if @gap2==false then tiles[3] else tiles[4] end,0,false,0],0) and i+=1}
					@objects << Obj.new(@x,i*32,:land,[if @gap2==false then tiles[6] else tiles[7] end,0,false,0],0)
				
					if @gap2==false then @gap2=nil end
				elsif @gap2==0
					i=0
					(@y2-1).round.abs.times{@objects << Obj.new(@x,i*32,:land,[tiles[5],0,false,0],0) and i+=1}
					@objects << Obj.new(@x,i*32,:land,[tiles[8],0,false,0],0)
					@gap2+=1
				else
					@gap2+=1
				end
			
				if !@gap
					if @gap==false then @y1=if @x==(@level['rooms'][@id]['width']-5)*32 then 1 else (y=[@y1+6,13-@y2].min)-rand(y) end end
					i=0
					(@y1-1).round.abs.times{@objects << Obj.new(@x,448-i*32,:land,[if @gap==false then tiles[3] else tiles[4] end,0,false,0],0) and i+=1}
					@objects << Obj.new(@x,448-i*32,:land,[if @gap==false then tiles[0] else tiles[1] end,0,false,0],0)
				
					construction(1,true) if @x>=32 and @x<(@level['rooms'][@id]['width']-6)*32
					
					bonus(1,true) if @x<(@level['rooms'][@id]['width']-6)*32
					
					enemy([0,0,0,0,1,1,1,2,3],1) if @gap==nil and @x>64 and @x<(@level['rooms'][@id]['width']-6)*32
				
					if @gap==false then @gap=nil end
				elsif @gap==0
					i=0
					(@y1-1).round.abs.times{@objects << Obj.new(@x,448-i*32,:land,[tiles[5],0,false,0],0) and i+=1}
					@objects << Obj.new(@x,448-i*32,:land,[tiles[2],0,false,0],0)
					@gap+=1
				else
					@gap+=1
				end
				@x+=32
				
				if !@gap and @x<(@level['rooms'][@id]['width']-6)*32
					@gap=[nil,nil,nil,0].shuffle[rand(4)]
				elsif @gap
					@gap=if @x==(@level['rooms'][@id]['width']-5)*32 then false else [false,@gap][rand(2)] end
				end
				
				if !@gap2 and @x<(@level['rooms'][@id]['width']-6)*32
					@gap2=[nil,nil,nil,nil,0].shuffle[rand(5)]
				elsif @gap2
					@gap2=if @x==(@level['rooms'][@id]['width']-5)*32 then false else [false,@gap2][rand(2)] end
				end
			
				if @y1!=1 and !@gap and @x==(@level['rooms'][@id]['width']-6)*32 then @gap=0 end
				
				if @x==(@level['rooms'][@id]['width']-5)*32 and @y2>3 then if @gap2 then @gap2=false else @gap2=0 end end
				@end=true if @x>=@level['rooms'][@id]['width']*32
			end
		end
		
		Marshal.dump(@level,f=File.new("data/own_levels/#{@level['name']}.mlv",'w'))
		f.close
	end

	def name
		$randomed << n="own_levels/#{@level['name']}"
		n
	end

	def construction(block,ceil=false)
		if !@construction
			@construction=[nil,nil,nil,nil,nil,nil,nil,nil,nil,rand(7)].shuffle[rand(10)]
		else
			@construction=[nil,nil,rand(7)][rand(3)]
		end
		if ceil and @construction
			if @construction>=15-(@y1+@y2+2) then @construction=[15-(@y1+@y2),0].min end
		end
	
		if @gap==nil and @construction
			i=0
			@construction.times{@objects << Obj.new(@x,448-@y1*32-i*32,:block,[block,0,false,0],0) and i+=1}
		end
	end
	
	def bonus(brick,ceil=false)
		if !@bonus
			@bonus=[nil,nil,nil,nil,nil,nil,nil,nil,nil,rand(3)].shuffle[rand(10)]
		else
			@bonus=[nil,@bonus,@bonus][rand(3)]
		end
			
		if @gap==nil and @bonus and !@construction || @construction<6
			bonus=[0,0,0,1,1,2].shuffle[rand(6)]
			y=352-@y1*32-@bonus*32
			if @construction and (y2=448-@y1*32-@construction*32)<=y then y=y2-32 end
			while ceil and y<=@y2*32 do y+=32 end
			if ceil and y==480-@y1*32 then return end
			case bonus
				when 0
				@objects << Obj.new(@x,y,:bricks,[brick,[-1,-1,-1,-1,rand(16)][rand(5)]],0)
				@objects << Obj.new(@x,y-32,:coin,[0],0) if rand(6)==3
				when 1
				@objects << Obj.new(@x,y,:coin,[0],0)
				when 2
				@objects << Obj.new(@x,y,:powerupblock,[[1,1,1,1,2,2,3,3,4,4,5,5,6,6,7,7,7,8,8,8,8,8,8,8,8,8,8,9,9,9,9,9,10,10,10,11,11,12,12,12,12,13,14,14,15].shuffle[rand(45)],[false,false,false,false,true][rand(5)]],0)
				@objects << Obj.new(@x,y-32,:coin,[0],0) if rand(6)==3
			end
		end
	end

	def enemy(possibly,goomba)
		if !@enemy
			@enemy=[nil,nil,nil,nil,nil,nil,true].shuffle[rand(7)]
		else
			@enemy=[nil,nil,@enemy][rand(3)]
		end
				
		if @enemy
			enemy=possibly.shuffle[rand(possibly.length)]
			y=448-@y1*32
			if @construction and (y2=480-@y1*32-@construction*32)<=y then y=y2-32 end
			case enemy
				when 0
				@objects << Obj.new(@x,y,:goomba,[goomba,0],0)
				when 1
				@objects << Obj.new(@x,y-16,:koopatroopa,[[false,false,true][rand(3)],0,[0,0,0,0,1].shuffle[rand(5)],5+rand(20),[1,2,2,2,1+rand(9)].shuffle[rand(5)]],0)
				when 2
				@objects << Obj.new(@x,y,:spiny,[false,0],0)
				when 3
				@objects << Obj.new(@x,y,:buzzybeetle,[false,0],0)
			end
		end
	end
end