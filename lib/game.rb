require 'opal'
require 'opal-phaser'

require 'ball'
require 'paddle'
require 'background'
require 'physics_component'

class Game
  def initialize
    preload
    create
    update
    render

    Phaser::Game.new(width: 480, height: 640, renderer: Phaser::AUTO, state: state)
  end

  def preload
    state.preload do |game|
      WORLD_CENTER_Y = game.world.y_center
      WORLD_CENTER_X = game.world.x_center

      instantiate_objects(game)

      game.time.advanced_timing = true

      @background.preload
      @ball.preload
      @player_paddle.preload
    end
  end

  def create
    state.create do
      @physics_component.create

      @background.create
      @ball.create

      @player_paddle.create
      @computer_paddle.create
    end
  end

  def update
    state.update do |game|
      @player_paddle.control_player_paddle
      @computer_paddle.control_computer_paddle(@ball.game_object)

      @physics_component.update(@ball, @player_paddle, @computer_paddle)

      @ball.update
    end
  end

  def render
    state.render do |game|
      game.debug.text(game.time.fps || '--', 2, 14, "#00ff00")
    end
  end

  def instantiate_objects(game)
    @ball            = Ball.new(game)
    @player_paddle   = Paddle.new(game, position: [Game::WORLD_CENTER_X, 624])
    @computer_paddle = Paddle.new(game, computer_paddle_speed: 190,
                                        position: [Game::WORLD_CENTER_X, 16])

    @physics_component = PhysicsComponent.new(game)

    @background = Background.new(game)
  end

  def state
    @state ||= Phaser::State.new
  end
end
