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
    @paddle.anchor.set_to(0.5, 0.5)
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
