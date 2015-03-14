require 'opal'
require 'opal-phaser'
require 'pp'

class Ball
  attr_reader :game_object

  def initialize(game)
    @game = game

    @ball_speed    = 300
    @ball_released = false

    @sprite_key = 'ball'
    @sprite_url = 'assets/ball.png'
  end

  def preload
    @game.load.image(@sprite_key, @sprite_url)
  end

  def create
    @game_object = @game.add.sprite(Game::WORLD_CENTER_X, Game::WORLD_CENTER_Y, @sprite_key)

    @game.physics.arcade.enable(@game_object)

    @game_object.body.collideWorldBounds = true
    @game_object.anchor.setTo(0.5, 0.5)
    @game_object.body.bounce.setTo(1, 1)

    @game.input.onDown.add(ball_listener)
  end

  def update
    if @game_object.y < 13
      ball_listener.call
    elsif @game_object.y > 629
      ball_listener.call
    end
  end

  def ball_listener
    proc do
      if @ball_released
        @game_object.x = Game::WORLD_CENTER_X
        @game_object.y = Game::WORLD_CENTER_Y

        ball_velocity(0, 0)

        @ball_released = false
      else
        ball_velocity(@ball_speed, -@ball_speed)

        @ball_released = true
      end
    end
  end

  def ball_velocity(x, y)
   @game_object.body.velocity.x = x
   @game_object.body.velocity.y = y
  end
end

class Paddle
  attr_reader :paddle

  def initialize(game, opts = {})
    @game = game

    @sprite_key = 'paddle'
    @sprite_url = 'assets/paddle.png'

    @x, @y = opts[:position]
    @computer_paddle_speed = opts[:computer_paddle_speed]
  end

  def preload
    @game.load.image(@sprite_key, @sprite_url)
  end

  def create
    @paddle = @game.add.sprite(@x, @y, @sprite_key);

    @game.physics.arcade.enable(@paddle)

    @paddle.body.collideWorldBounds = true
    @paddle.anchor.setTo(0.5, 0.5)
    @paddle.body.bounce.setTo(1, 1)
    @paddle.body.immovable = true
  end

  def paddle_center
    @paddle.width / 2
  end

  def control_player_paddle
    @paddle.x = @game.input.x

    if @paddle.x < paddle_center
      @paddle.x = paddle_center
    elsif @paddle.x > @game.width - paddle_center
      @paddle.x = @game.width - paddle_center
    end
  end

  def control_computer_paddle(ball)
    if @paddle.x - ball.x < -15
      @paddle.body.velocity.x = @computer_paddle_speed
    elsif @paddle.x - ball.x > 15
      @paddle.body.velocity.x = -@computer_paddle_speed
    else
      @paddle.body.velocity.x = 0;
    end
  end
end

class PhysicsComponent
  def initialize(game, game_objects = {})
    @game = game
  end

  def create
    @game.physics.start_system(Phaser::Physics::ARCADE)
    @game.physics.arcade.check_collision.up   = false
    @game.physics.arcade.check_collision.down = false
  end

  def update(ball, player_paddle, computer_paddle)
    collide(ball.game_object, computer_paddle.paddle)
    collide(ball.game_object, player_paddle.paddle)
  end

  private
  def collide(ball, paddle)
    ball_hits_paddle = proc do |ball, paddle|
      ball   = Phaser::Sprite.new(ball)
      paddle = Phaser::Sprite.new(paddle)

      diff = 0

      case
      when ball.x < paddle.x
        diff = paddle.x - ball.x
      when ball.x > paddle.x
        diff = ball.x - paddle.x
        ball.body.velocity.x = 10 * diff
      else
        ball.body.velocity.x = 2 + rand * 8
      end
    end

    @game.physics.arcade.collide(ball, paddle, ball_hits_paddle)
  end
end

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

      game.time.advancedTiming = true

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
