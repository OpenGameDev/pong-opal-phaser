class Background
  def initialize(game)
    @game = game

    @sprite_key = 'background'
    @sprite_url = 'assets/starfield.png'
  end

  def preload
    @game.load.image(@sprite_key, @sprite_url)
  end

  def create
    @game.add.tile_sprite(0, 0, 480, 640, @sprite_key)
  end
end
