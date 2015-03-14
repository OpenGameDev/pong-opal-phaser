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

