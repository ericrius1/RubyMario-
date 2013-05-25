require 'gosu'
require 'texplay'
require 'ashton'
include Gosu

require Dir.getwd+'/data/scripts/menus'
class WindowMode < Window
	def initialize
		super(126,40,false)
		@font=Font.new(self,'fonts/nine.ttf',20)
		@yes=true
		@sel=Sample.new(self,'sfx/select.ogg')
		@ch=Sample.new(self,'sfx/choose.ogg')
	end

	def update
	end

	def draw
		@font.draw("Fullscreen?",0,0,0)
		@font.draw("Yes",0,20,0,1,1,if @yes then 0xffffffff else 0xff808080 end)
		@font.draw("No",60,20,0,1,1,if !@yes then 0xffffffff else 0xff808080 end)
	end

	def button_down(id)
		if id==KbLeft and !@yes then @yes=true
			@sel.play end
		if id==KbRight and @yes then @yes=false
			@sel.play end
		if id==KbReturn
			close
			$screen=Main.new(@yes)
			$screen.show end
	end
end

class Main < Window
	def initialize(full)
		super(640, 480, full)
		self.caption = "Super Duper Mario"
    Gosu::enable_undocumented_retrofication
	end

	def update
		$count+=1
		if $game.class != Editor
			$game.update
		else
			$game.update(mouse_x,mouse_y)
		end
  end

	def draw
		if $game.class != Editor
			$game.draw
		else
			$game.draw(mouse_x,mouse_y)
		end
	end
  
	def button_down(id)
		if $game.class != Editor
			$game.button_down(id)
		else
			$game.button_down(id,mouse_x,mouse_y)
		end
	end
  
	def button_up(id)
		$game.button_up(id) if $game.respond_to?(:button_up)
	end
end

$randomed=[]
$coins=0
$points=0
$lives=4
$count=0
if ARGV and ARGV.include?('true') or ARGV.include?('false') then $screen=Main.new(ARGV.include?('true')) else $screen=WindowMode.new end
$game=Load.new
$screen.show
$randomed.each{|r| File.delete("data/#{r}.mlv")}