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

