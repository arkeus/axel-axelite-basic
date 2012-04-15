package {
	import org.axgl.Ax;
	import org.axgl.AxRect;
	import org.axgl.AxSprite;
	import org.axgl.AxVector;
	import org.axgl.input.AxKey;

	public class Player extends AxSprite {
		public function Player(x:Number, y:Number, worldWidth:Number, worldHeight:Number) {
			super(x, y);
			
			load(Resource.PLAYER, 32, 32);
			addAnimation("stand", [0, 4, 0, 5], 4, true);
			addAnimation("walk", [1,2,3,4, 5], 16, true);
			addAnimation("jump", [2], 1, false);
			addAnimation("fall", [3], 1, false);
			
			maxVelocity = new AxVector(220, 350);
			drag.x = 300;
			acceleration.y = 650;
			worldBounds = new AxRect(0, 0, worldWidth, worldHeight);
			bounds(24, 20, 4, 12);
		}
		
		override public function update():void {
			if (Ax.keys.down(AxKey.RIGHT)) {
				acceleration.x = 850;
				facing = RIGHT;
			} else if (Ax.keys.down(AxKey.LEFT)) {
				acceleration.x = -850;
				facing = LEFT;
			} else {
				acceleration.x = 0;
			}
			
			if (Ax.keys.pressed(AxKey.SPACE) && isTouching(DOWN)) {
				velocity.y = -360;
			}
			
			if (velocity.y < 0) {
				animate("jump");
			} else if (velocity.y > 0) {
				animate("fall");
			} else if (velocity.x != 0) {
				animate("walk");
				animationDelay = 1 / Math.max(6, (Math.abs(velocity.x) / maxVelocity.x) * 16);
			} else {
				animate("stand");
			}
			
			var t:Number = Ax.now / 500;
			setColor((Math.sin(t * 0.9) + 1) / 2 + 0.5, (Math.sin(t * 1.3) + 1) / 2 + 0.5, (Math.sin(t * 1.7) + 1) / 2 + 0.5);
			
			super.update();
		}
	}
}
